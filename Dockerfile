# Use specific digest for base image to prevent supply chain attacks
FROM node:22.16.0@sha256:71bcbb3b215b3fa84b5b167585675072f4c270855e37a599803f1a58141a0716 as build
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
WORKDIR /usr/src/app
# Copy package files first to leverage Docker layer caching
COPY --chown=node:node package.json pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile --ignore-scripts
# Copy only needed files for build
COPY --chown=node:node tsconfig.json ./
COPY --chown=node:node src/ ./src/
# Set production environment for optimized build
ENV NODE_ENV=production
RUN pnpm build

# Use slim image for smaller size
FROM node:22.16.0-slim@sha256:048ed02c5fd52e86fda6fbd2f6a76cf0d4492fd6c6fee9e2c463ed5108da0e34 AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
WORKDIR /usr/src/app

FROM base AS prod-deps
# Install only necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
COPY --chown=node:node package.json pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile --ignore-scripts

FROM base
# Set production environment
ENV NODE_ENV=production
# Copy dumb-init
COPY --from=prod-deps /usr/bin/dumb-init /usr/bin/dumb-init
# Set up non-root user early
USER node
# Copy only what's needed for runtime
COPY --chown=node:node --from=build /usr/src/app/build /usr/src/app/build
COPY --chown=node:node --from=prod-deps /usr/src/app/node_modules /usr/src/app/node_modules
# Set secure defaults
ENV NODE_OPTIONS="--max-old-space-size=2048 --no-experimental-fetch"
# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
# Add healthcheck
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["node", "build/index.js"]

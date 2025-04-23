FROM node:22.15.0 as build
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
RUN ls -la
RUN ls -la src
RUN pnpm build

FROM node:22.15.0-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
WORKDIR /usr/src/app

FROM base AS prod-deps
# Combine RUN commands to reduce layers
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
CMD ["node", "build/index.js"]

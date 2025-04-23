# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Build: `pnpm build` or `pnpm compile`
- Development: `pnpm dev` (run) or `pnpm dev:watch` (watch mode) 
- Test: `pnpm test` (all tests) or `pnpm jest path/to/test.ts` (single test)
- Lint/Fix: `pnpm lint` (check) or `pnpm fix` (auto-fix)
- Clean: `pnpm clean`

## Code Style Guidelines
- **Formatting**: Follow Google TypeScript Style (GTS) with Prettier
- **Imports**: Sort using pattern `^node:/(.*)$`, `^[./]` with blank lines between groups
- **Types**: Use strict TypeScript with explicit return types and no unchecked indexed access
- **Naming**: camelCase for variables/functions, descriptive boolean parameters
- **Error Handling**: Throw errors with descriptive messages for invalid states
- **Modules**: Use ESM modules (not CommonJS)
- **Structure**: Keep utility functions in `src/utils/`, maintain index.ts files for exports
- **Tests**: Write Jest tests with descriptive test names

After making changes, always run `pnpm lint` to verify code quality.
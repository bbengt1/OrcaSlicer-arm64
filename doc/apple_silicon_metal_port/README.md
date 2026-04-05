# Apple Silicon Metal Port

This directory tracks the internal Apple Silicon Metal migration for the macOS fork.

## Build documentation

- [Apple Silicon fork build guide](./apple_silicon_build.md)

## Current implementation status

- Added renderer backend selection via `app_config` key `renderer_backend` or environment variable `SLIC3R_RENDERER_BACKEND`.
- Added experimental Metal renderer scaffolding behind `SLIC3R_EXPERIMENTAL_METAL`.
- Added native macOS `CAMetalLayer` host implementation in `MetalRenderViewHost`.
- Added renderer diagnostics to system info output.
- Standardized the Apple Silicon migration backlog into epic and story files.

## How to exercise the new scaffolding

1. Build on Apple Silicon using the pinned toolchain in [apple_silicon_build.md](./apple_silicon_build.md).
2. Set `SLIC3R_RENDERER_BACKEND=metal` before launching to force backend selection.
3. Confirm logs report `Renderer backend selected: Metal`.
4. Use Xcode GPU Frame Capture and Metal API Validation while iterating on the next milestones.

## Current limitation

The experimental Metal host is present, but the production viewport still renders through OpenGL. This milestone establishes the backend seam and native Metal surface needed for the next migration phases.

# Epic 01: Apple Silicon Baseline and Build System

## Goal

Establish a dedicated Apple Silicon fork baseline that builds natively as `arm64`, reports renderer backend selection, and removes macOS target ambiguity.

## Status

Epic status: In progress

Story status summary:
- `1.1`: Complete
- `1.2`: Complete
- `1.3`: Complete

## Progress notes

- Native `arm64` app builds have been validated on Apple Silicon.
- The current local validation binary is `/tmp/orcaslicer-metal-app/src/Snapmaker_Orca`.
- Deployment target has been normalized to `12.0` in the app build and macOS CI workflows.
- Experimental Metal backend selection and diagnostics are implemented.
- A dedicated Apple Silicon fork build guide now exists in `doc/apple_silicon_metal_port/apple_silicon_build.md`.
- The production viewport still links `OpenGL.framework`; Epic 1 only establishes the baseline and activation model, not the renderer migration itself.

## User stories

### Story 1.1: Native arm64 baseline

Status: Complete

As a platform engineer, I need an Apple Silicon-first build path so the team can iterate on Metal without carrying Intel release constraints in each milestone.

Acceptance criteria:
- `build_release_macos.sh -a arm64` is the default local workflow.
- CI and docs agree on the same minimum macOS deployment target.
- Renderer backend selection is logged at startup.

Example:
- Local build on an M-series Mac produces an `arm64` app bundle without Rosetta.

Completed work:
- Native `arm64` binary build validated for `Snapmaker_Orca`.
- Startup/backend diagnostics were added through the app backend selection work.
- Minimum deployment target alignment was applied to the repo and CI configuration.

### Story 1.2: Toolchain contract

Status: Complete

As a build engineer, I need the required Apple tooling documented so another engineer can reproduce the Metal work without guessing versions.

Acceptance criteria:
- Repo docs specify Xcode, CMake, Ninja, Homebrew, Instruments, and GPU Frame Capture.
- The repo contains a migration README in `doc/apple_silicon_metal_port`.

Completed work:
- Added the canonical fork setup guide at `doc/apple_silicon_metal_port/apple_silicon_build.md`.
- Linked the fork guide from `doc/apple_silicon_metal_port/README.md`.
- Updated `doc/developer-reference/How-to-build.md` to point Apple Silicon fork work at the dedicated guide.
- Documented the validated toolchain, required packages, exact configure/build commands, and prototype limitations.

### Story 1.3: Backend selection contract

Status: Complete

As a maintainer, I need a single backend-selection mechanism so experimental Metal work can be enabled without destabilizing the default OpenGL path.

Acceptance criteria:
- `renderer_backend=metal` is available in app config.
- `SLIC3R_RENDERER_BACKEND=metal` overrides config for local testing.
- Unsupported platforms safely fall back to OpenGL.

Completed work:
- Added `renderer_backend` config support.
- Added `SLIC3R_RENDERER_BACKEND=metal` environment override.
- Added backend reporting/diagnostics to system info.
- Preserved the existing OpenGL path as the default renderer.
- Added explicit warning-and-fallback behavior when `metal` is requested in a build that does not support it.
- Updated CMake to prefer bundled Apple Silicon dependency-prefix libraries for PNG, JPEG, Freetype, and OpenSSL instead of drifting to Homebrew-provided runtime dylibs.

Residual note:
- The generated app link still includes Homebrew `libzstd` through the OpenVDB or Blosc dependency chain. That is a packaging cleanup item, but it is no longer treated as a blocker for the backend-selection contract in story 1.3.

Tools:
- Xcode 26.4+
- CMake 4.3.x
- Ninja
- Homebrew

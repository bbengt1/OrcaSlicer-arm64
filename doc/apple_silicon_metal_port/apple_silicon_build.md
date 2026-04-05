# Apple Silicon Fork Build Guide

This guide is the canonical local setup document for the internal Apple Silicon Metal fork.

It covers the exact toolchain, local prerequisites, build commands, and current prototype limitations needed to reproduce the fork on an M-series Mac.

## Supported host

- Apple Silicon Mac (`arm64`)
- macOS with full Xcode installed

Intel Macs and universal builds are not the target for this fork guide.

## Required toolchain

- Xcode `26.4` or newer activated with `xcode-select`
- macOS SDK from the active Xcode install
- CMake `4.3.x`
- GNU Make or Ninja
- Git
- Homebrew

This fork has already been validated locally with:

- `Xcode 26.4`
- `MacOSX26.4.sdk`
- `CMake 4.3.1`

## Required packages

Install the command-line dependencies used by the dependency build:

```bash
brew install gettext libtool automake autoconf texinfo ninja
```

If `git-lfs` is required for your checkout, install it and pull the large files:

```bash
brew install git-lfs
git lfs pull
```

## Xcode setup

Install full Xcode, open it once, then select it as the active developer directory:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Verify the active toolchain:

```bash
xcodebuild -version
xcrun --sdk macosx --show-sdk-path
cmake --version
```

Expected result:

- `xcodebuild` reports the full Xcode version, not Command Line Tools
- `xcrun --sdk macosx --show-sdk-path` points into `/Applications/Xcode.app/.../MacOSX*.sdk`
- `cmake` reports `4.3.x`

## Fork-specific build options

The Apple Silicon Metal fork currently uses:

- deployment target `12.0`
- architecture `arm64`
- experimental Metal seam enabled with `-DSLIC3R_EXPERIMENTAL_METAL=ON`
- optional renderer selection override through `SLIC3R_RENDERER_BACKEND=metal`

## Dependency build

Build the dependency prefix first:

```bash
cmake -S deps -B /tmp/orcaslicer-metal-deps \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0

cmake --build /tmp/orcaslicer-metal-deps --target dep_Boost --parallel
cmake --build /tmp/orcaslicer-metal-deps --target dep_TBB --parallel
cmake --build /tmp/orcaslicer-metal-deps --target dep_GLEW --parallel
cmake --build /tmp/orcaslicer-metal-deps --target dep_GLFW --parallel
cmake --build /tmp/orcaslicer-metal-deps --target dep_Cereal --parallel
cmake --build /tmp/orcaslicer-metal-deps --target dep_NLopt --parallel
cmake --build /tmp/orcaslicer-metal-deps --target dep_OpenVDB --parallel
cmake --build /tmp/orcaslicer-metal-deps --target dep_CGAL --parallel
cmake --build /tmp/orcaslicer-metal-deps --target dep_OpenCV --parallel
cmake --build /tmp/orcaslicer-metal-deps --target dep_OCCT --parallel
cmake --build /tmp/orcaslicer-metal-deps --target dep_libnoise --parallel
cmake --build /tmp/orcaslicer-metal-deps --target dep_wxWidgets --parallel
```

The installed dependency prefix will be:

```bash
/tmp/orcaslicer-metal-deps/destdir/usr/local
```

## App configure

Configure the app build against that prefix:

```bash
cmake -S . -B /tmp/orcaslicer-metal-app \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/tmp/orcaslicer-metal-deps/destdir/usr/local \
  -DSLIC3R_EXPERIMENTAL_METAL=ON \
  -Wno-dev
```

## App build

Build the main app target:

```bash
cmake --build /tmp/orcaslicer-metal-app --target Snapmaker_Orca -- -j1
```

`-j1` is recommended while stabilizing the fork because it makes the first failing compile or link step much easier to isolate.

## Optional renderer override

To force the experimental backend selection at runtime:

```bash
export SLIC3R_RENDERER_BACKEND=metal
```

The same backend can also be selected through the app config key:

```text
renderer_backend=metal
```

## Output

The current build produces:

```bash
/tmp/orcaslicer-metal-app/src/Snapmaker_Orca
```

You can verify it is native Apple Silicon with:

```bash
file /tmp/orcaslicer-metal-app/src/Snapmaker_Orca
```

Expected result:

```text
Mach-O 64-bit executable arm64
```

## Current prototype constraints

- The build is native `arm64`, but the production viewport still links `OpenGL.framework`.
- The Metal work in this milestone is scaffolding only: render host, backend selection, and build integration.
- The binary also links `Metal.framework`, but that does not mean the plater has been ported to Metal yet.
- Some non-fatal linker warnings remain because Homebrew-provided runtime libraries such as `jpeg`, `freetype`, `zstd`, and `openssl` were built against a newer SDK than the fork deployment target.

## Signing and notarization expectations

This guide is for local development and validation.

At this stage:

- code signing is not required for local compile validation
- notarization is not part of the baseline build acceptance for story 1.2
- release packaging should continue to be validated separately through the macOS release workflow and `build_release_macos.sh`

## Recommended debugging tools

Use the full Xcode toolchain while working on later epics:

- Metal API Validation
- Xcode GPU Frame Capture
- Instruments Time Profiler
- Instruments Allocations
- Instruments Leaks
- Instruments Metal System Trace

## Acceptance for story 1.2

Story 1.2 is considered complete when a contributor can use this document to:

1. install the required toolchain on an Apple Silicon Mac
2. configure the dependency prefix
3. configure the app build
4. build `Snapmaker_Orca` as a native `arm64` binary
5. understand the current prototype limitations before starting renderer work

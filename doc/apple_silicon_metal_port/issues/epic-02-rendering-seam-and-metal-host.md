# Epic 02: Rendering Seam and Metal Host

## Goal

Create the first internal renderer seam and a native macOS Metal view host that can be expanded into the full viewport migration.

## Status

Epic status: Complete

Story status summary:
- `2.1`: Complete
- `2.2`: Complete
- `2.3`: Complete

## Progress notes

- Shared renderer backend primitives already exist in the GUI layer and are wired into app-level backend selection.
- `RenderViewHost` can create a `MetalRenderViewHost` on supported Apple Silicon builds and falls back to a placeholder host otherwise.
- `MetalRenderViewHost` owns a real `CAMetalLayer`, resizes `drawableSize`, and issues a clear pass.
- `View3D`, `Preview`, and `AssembleView` now mount the visible `RenderViewHost` when the Metal backend is selected.
- The Metal path keeps a hidden compatibility `wxGLCanvas` or `GLCanvas3D` alive so existing plater logic can continue to call legacy canvas APIs while rendering is migrated incrementally.
- The visible viewport output is currently the Metal clear-pass host; full scene rendering, picking, and toolbar migration are explicitly deferred to later renderer epics.

## User stories

### Story 2.1: Render backend types

Status: Complete

As a renderer engineer, I need shared backend primitives so future Metal work does not reintroduce OpenGL assumptions at every call site.

Acceptance criteria:
- `RendererBackend`, `RenderContext`, and `RenderDevice` exist in the GUI layer.
- New code can reason about backend identity without consulting OpenGL code paths.

Example:
- Diagnostic code reports `OpenGL` or `Metal` through the same API.

Completed work:
- Added `RendererBackend`, `RenderContext`, and `RenderDevice` to the GUI layer.
- Wired backend identity through app configuration and diagnostics so new code does not need to inspect OpenGL state directly.

### Story 2.2: Metal-native view host

Status: Complete

As a graphics engineer, I need a native macOS render host so the fork has a real `CAMetalLayer` surface to iterate on.

Acceptance criteria:
- A `RenderViewHost` abstraction exists.
- `MetalRenderViewHost` creates a `CAMetalLayer` and performs a clear pass.
- The host resizes correctly when the containing wx window resizes.

Example:
- Resizing the window updates `drawableSize` and the next frame clears successfully.

Implemented so far:
- Added `RenderViewHost` and `MetalRenderViewHost`.
- `MetalRenderViewHost` creates a `CAMetalLayer`, resizes it with the wx host panel, and performs a clear pass.
- `View3D`, `Preview`, and `AssembleView` now mount the host as the visible surface when the Metal backend is selected.
- The Metal path preserves a hidden compatibility `wxGLCanvas` so existing `GLCanvas3D`-based logic does not immediately crash during the migration.
- `RenderViewHost` now exposes resize and frame callbacks so later renderer migration work can attach to host lifecycle events instead of tunneling back through `wxGLCanvas`.
- The preview panels wire those callbacks to keep the hidden compatibility canvas sized with the visible Metal host.

Deferred to later epics:
- Route scene rendering through the Metal host instead of the hidden OpenGL compatibility canvas.
- Replace OpenGL-driven toolbar, interaction, and repaint assumptions with host-level rendering callbacks.

### Story 2.3: Fallback safety

Status: Complete

As a developer, I need unsupported backends to fail safely so enabling Metal scaffolding never blocks the existing app.

Acceptance criteria:
- Unsupported backends create a placeholder host instead of crashing.
- OpenGL remains the default production path.

Completed work:
- Unsupported backends create an `UnsupportedRenderViewHost` placeholder panel instead of crashing.
- OpenGL remains the default backend selection path.
- Preview and plater integration now guard direct `wxGLCanvas` event hookup so the app does not assume a visible GL canvas is always present.

Tools:
- Metal API Validation
- Xcode GPU Frame Capture
- Instruments Metal System Trace

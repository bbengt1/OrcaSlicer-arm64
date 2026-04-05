# Epic 02: Rendering Seam and Metal Host

## Goal

Create the first internal renderer seam and a native macOS Metal view host that can be expanded into the full viewport migration.

## User stories

### Story 2.1: Render backend types

As a renderer engineer, I need shared backend primitives so future Metal work does not reintroduce OpenGL assumptions at every call site.

Acceptance criteria:
- `RendererBackend`, `RenderContext`, and `RenderDevice` exist in the GUI layer.
- New code can reason about backend identity without consulting OpenGL code paths.

Example:
- Diagnostic code reports `OpenGL` or `Metal` through the same API.

### Story 2.2: Metal-native view host

As a graphics engineer, I need a native macOS render host so the fork has a real `CAMetalLayer` surface to iterate on.

Acceptance criteria:
- A `RenderViewHost` abstraction exists.
- `MetalRenderViewHost` creates a `CAMetalLayer` and performs a clear pass.
- The host resizes correctly when the containing wx window resizes.

Example:
- Resizing the window updates `drawableSize` and the next frame clears successfully.

### Story 2.3: Fallback safety

As a developer, I need unsupported backends to fail safely so enabling Metal scaffolding never blocks the existing app.

Acceptance criteria:
- Unsupported backends create a placeholder host instead of crashing.
- OpenGL remains the default production path.

Tools:
- Metal API Validation
- Xcode GPU Frame Capture
- Instruments Metal System Trace

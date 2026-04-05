# Epic 03: Shader and GPU Resources

## Goal

Replace the first layer of hard-coded OpenGL resource management with backend-neutral shader and GPU resource abstractions that can be used by the Metal renderer path.

## Status

Epic status: Complete

Story status summary:
- `3.1`: Complete
- `3.2`: Complete
- `3.3`: Complete

## Progress notes

- Added backend-neutral `ShaderLibrary`, `RenderBuffer`, and `RenderTexture` abstractions to the GUI layer.
- Added a real Metal-backed `RenderDevice` that reports device and command queue availability instead of using a null stub.
- Added Metal implementations for shader library, pipeline caching, buffer upload, and texture upload.
- The Metal host now renders through `SceneRenderer` plus the new shader and buffer abstractions instead of issuing a raw clear-only pass directly.
- A small Metal debug scene is now drawn through the shader library and render buffer seam, proving the abstractions are live instead of dead scaffolding.

## User stories

### Story 3.1: Shader compilation and pipeline caching

Status: Complete

As a renderer engineer, I need a backend-neutral shader library so viewport rendering has a replacement for direct GLSL program management.

Acceptance criteria:
- A `ShaderLibrary` abstraction exists in the GUI layer.
- Metal builds can resolve a pipeline from a material or shader key.
- Pipeline creation is cached instead of rebuilt every frame.

Completed work:
- Added `ShaderLibrary` with backend-neutral pipeline lookup.
- Added `MetalShaderLibrary` with cached pipeline creation for the `flat` material path.
- Switched the experimental Metal viewport host to render through the shader library.

### Story 3.2: Buffer abstractions

Status: Complete

As a renderer engineer, I need backend-neutral GPU buffer wrappers so geometry upload no longer assumes OpenGL VBO semantics.

Acceptance criteria:
- A `RenderBuffer` abstraction exists.
- Metal builds can allocate and upload vertex data through that abstraction.
- The experimental Metal path draws geometry through the new buffer seam.

Completed work:
- Added `RenderBuffer` and Metal-backed upload support.
- Added a `SceneRenderer` factory and Metal scene renderer implementation.
- The Metal host now draws a debug triangle through the new render buffer path.

### Story 3.3: Texture abstractions

Status: Complete

As a renderer engineer, I need backend-neutral texture wrappers so later viewport work can move bed and UI textures off direct OpenGL ownership.

Acceptance criteria:
- A `RenderTexture` abstraction exists.
- Metal builds can allocate and upload RGBA texture data through that abstraction.
- Texture ownership is no longer defined only in OpenGL-specific classes.

Completed work:
- Added `RenderTexture` and a Metal-backed RGBA8 upload path.
- The Metal renderer path now creates a debug texture through the abstraction, establishing the texture resource seam for later viewport work.

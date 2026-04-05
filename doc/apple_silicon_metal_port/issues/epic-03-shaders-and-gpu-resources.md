# Epic 03: Shaders and GPU Resource Migration

## Goal

Replace GL-specific shader and resource ownership with Metal-ready abstractions while preserving the existing scene math and higher-level workflow logic.

## User stories

### Story 3.1: Shader library contract

As a renderer engineer, I need a Metal-ready shader library abstraction so pipeline creation can move out of `GLShadersManager`.

Acceptance criteria:
- A dedicated shader-library contract is defined before any production shader port starts.
- Existing shader families are enumerated and mapped to future Metal pipelines:
  - `flat`
  - `flat_texture`
  - `gouraud_light`
  - thumbnail/picking

Example:
- A future `flat` pipeline lookup uses the same semantic key currently used for GLSL shader retrieval.

### Story 3.2: Buffer ownership migration

As a renderer engineer, I need explicit buffer ownership boundaries so `GLModel` and viewer code can be ported incrementally.

Acceptance criteria:
- Static mesh, dynamic, and instance-buffer cases are documented and split into separate tasks.
- Large allocations are measurable during prototype work.

### Story 3.3: Texture migration

As a renderer engineer, I need a Metal texture path for bed textures, thumbnails, and UI surfaces so OpenGL texture upload code can be retired cleanly.

Acceptance criteria:
- Texture upload requirements are documented: mipmaps, dimensions, format, and reuse.
- Large texture pressure is included in profiling scenarios.

Tools:
- Xcode GPU Frame Capture
- Instruments Allocations
- Instruments Leaks

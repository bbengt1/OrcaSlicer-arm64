# Epic 04: Main Viewport Bring-Up

## Goal

Use the new renderer seam to reach a visible, interactive Metal viewport for the plater.

## User stories

### Story 4.1: Bed rendering

As a user, I need the print bed to render through Metal so the experimental viewport is visually grounded and testable.

Acceptance criteria:
- The bed renders in the Metal viewport with stable clear color and depth configuration.
- Resize and redraw are reliable.

### Story 4.2: Model rendering

As a user, I need loaded models to appear in the Metal viewport so the port is functionally meaningful.

Acceptance criteria:
- A basic model mesh path renders through Metal.
- Camera transforms match existing `Camera` behavior.

### Story 4.3: Interactive camera

As a tester, I need pan/orbit/zoom behavior to match the current viewport well enough that non-graphics engineers can validate scenes.

Acceptance criteria:
- Repeated camera movement does not stall the event loop.
- Frame pacing remains stable during simple interaction.

Tools:
- Time Profiler
- Metal System Trace
- benchmark scenes: empty bed, medium model, dense scene

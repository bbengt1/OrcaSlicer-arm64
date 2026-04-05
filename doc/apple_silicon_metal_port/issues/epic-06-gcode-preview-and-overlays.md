# Epic 06: G-code Preview and Specialized Renderers

## Goal

Port the heavier rendering clients after the base viewport is stable.

## User stories

### Story 6.1: G-code preview

As a user, I need G-code preview to render with correct colors and path grouping so the Metal fork remains useful for print validation.

Acceptance criteria:
- Batched and instanced preview paths render through Metal.
- Blending and path coloring are visually correct for approved benchmark files.

### Story 6.2: Overlays and helper rendering

As a user, I need selection rectangles, helper lines, and text overlays so interactive inspection remains usable.

Acceptance criteria:
- Overlay elements remain legible at common zoom levels.
- Overlay redraw does not introduce noticeable frame spikes.

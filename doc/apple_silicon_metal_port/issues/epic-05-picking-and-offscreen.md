# Epic 05: Picking and Offscreen Rendering

## Goal

Restore framebuffer-dependent workflows needed for object interaction and thumbnails.

## User stories

### Story 5.1: Picking pass

As a user, I need click selection in the Metal viewport so the port supports real editing instead of passive viewing.

Acceptance criteria:
- Picking returns stable object/instance IDs.
- Hit results remain correct after resize and camera movement.

### Story 5.2: Thumbnail rendering

As a user, I need generated thumbnails and export previews to keep working so slice/export workflows remain intact.

Acceptance criteria:
- Thumbnail output is deterministic for approved test scenes.
- Existing orthographic preview variants are reproduced.

### Story 5.3: Deterministic offscreen pipeline

As a developer, I need deterministic offscreen rendering so snapshot testing and CI comparison become possible.

Acceptance criteria:
- Fixed viewport sizes and clear colors are used in test mode.
- Result images are stable enough for regression comparison.

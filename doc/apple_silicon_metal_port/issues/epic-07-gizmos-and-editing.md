# Epic 07: Gizmos and Interactive Editing

## Goal

Restore transform and editing tools once the Metal viewport is functionally stable.

## User stories

### Story 7.1: Move/rotate/scale

As a user, I need the core transform gizmos to work so object manipulation remains available in the Metal viewport.

Acceptance criteria:
- Move, rotate, and scale gizmos support hover, click, drag, and update feedback.
- Cursor state and visual feedback match the current viewport closely enough for QA signoff.

### Story 7.2: Advanced gizmos

As a power user, I need cut, measure, and support-related gizmos restored so advanced workflows can migrate gradually.

Acceptance criteria:
- Each advanced gizmo is tracked as a separate implementation task.
- Unsupported gizmos are clearly reported during transition builds.

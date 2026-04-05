# Epic 09: Packaging, Signing, and Release Readiness

## Goal

Ship a native Apple Silicon build with explicit quality gates once Metal parity reaches release level.

## User stories

### Story 9.1: Apple Silicon packaging

As a release engineer, I need DMG, signing, and notarization steps aligned to the Metal fork so builds can be distributed safely.

Acceptance criteria:
- Packaging docs describe the Apple Silicon release path.
- dSYM handling remains defined if Sentry is restored.

### Story 9.2: QA checklist

As a QA lead, I need a release checklist covering viewport, slicing, export, preview, and printer/web flows so renderer parity is verified before release.

Acceptance criteria:
- Smoke checklist covers startup, project open, viewport interaction, slice, export, thumbnails, G-code preview, and printer/web panels.

### Story 9.3: Rollout gates

As a product owner, I need staged rollout gates so the Metal fork can move from internal prototype to public Apple Silicon release with controlled risk.

Acceptance criteria:
- Stages are defined: internal prototype, internal daily-use beta, limited external alpha, public release.

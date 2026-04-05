# Epic 08: Diagnostics, Performance, and Memory Stability

## Goal

Make the Apple Silicon Metal fork observable, profileable, and stable under real workloads.

## User stories

### Story 8.1: Renderer diagnostics

As a developer, I need backend diagnostics in logs and support data so Apple-Silicon-specific bugs are actionable.

Acceptance criteria:
- Renderer backend is visible in startup logs and system info.
- Device name, frame counters, and drawable metrics are available during testing.

### Story 8.2: Memory instrumentation

As a user, I need the app not to lock up or balloon RAM during interaction so the fork is viable for real scenes.

Acceptance criteria:
- Texture, buffer, thumbnail, and redraw-storm hotspots are measurable.
- Repeated camera movement and preview refresh show bounded memory growth.

### Story 8.3: Benchmark scenarios

As a performance engineer, I need reproducible benchmark scenes so performance regressions are measurable over time.

Acceptance criteria:
- Benchmark set includes empty bed, medium multi-part scene, dense preview, repeated thumbnail generation.
- Profiling instructions are stored with the migration docs.

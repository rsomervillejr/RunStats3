<!--
SYNC IMPACT REPORT
==================
Version change: (none) → 1.0.0
Modified principles: N/A (initial ratification)
Added sections:
  - I. Code Quality
  - II. Test-First Development
  - III. UX Consistency
  - IV. Performance
  - Development Workflow
  - Governance
Templates requiring updates:
  ✅ plan-template.md — Constitution Check gates align with principles below
  ✅ spec-template.md — no structural changes required
  ✅ tasks-template.md — no structural changes required
Follow-up TODOs: none
-->

# RunStats3 Constitution

## Core Principles

### I. Code Quality

Swift code MUST follow Swift API Design Guidelines and idiomatic SwiftUI patterns.
MVVM separation is non-negotiable: Views own no business logic; ViewModels own no
layout. Models are plain value types (structs) unless identity semantics require
a class.

- Every type MUST have a single, clear responsibility
- Force-unwrap (`!`) is PROHIBITED except in test code and `@IBOutlet`/`@IBAction`
- Magic literals MUST be extracted to named constants or enums
- Complexity MUST be justified — if a simpler approach exists, use it

### II. Test-First Development

Tests are written before implementation. No feature is considered complete without
passing XCTest coverage for its ViewModel and Service layers.

- TDD cycle: write failing test → implement → refactor (Red-Green-Refactor)
- ViewModels MUST be unit-tested in isolation (no UIKit/SwiftUI dependencies)
- UI tests (XCUITest) are reserved for critical user journeys, not exhaustive coverage
- A task is not "done" until its tests pass; tests that are skipped MUST be tracked
  as follow-up tasks, never silently removed

### III. UX Consistency

Every screen MUST feel native to iOS/iPadOS. Deviations from Human Interface
Guidelines require explicit justification recorded in the feature spec.

- Typography, spacing, and color MUST use SwiftUI's system defaults
  (`Font.body`, `.primary`, `Color.accentColor`) unless a design token overrides
- Navigation patterns MUST be consistent across the app (NavigationStack throughout)
- Loading, empty, and error states MUST be handled in every view that fetches data
- Accessibility: all interactive elements MUST carry a meaningful `accessibilityLabel`

### IV. Performance

The app MUST maintain 60 fps scrolling and a cold-launch time under 1 second on
a supported device.

- Views MUST NOT perform synchronous I/O or heavy computation on the main thread
- SwiftData/CoreData fetches MUST be paginated or scoped — no unbounded fetches
- Images and large assets MUST be loaded asynchronously; use `AsyncImage` or
  equivalent
- Memory footprint MUST NOT grow unboundedly during a session; instrument with
  Xcode Memory Graph before marking a feature complete

## Development Workflow

Features follow the Spec Kit cycle: `specify → clarify → plan → tasks → implement`.

- Every feature starts on a numbered branch (`001-feature-name`)
- A feature MUST have a spec before a plan; a plan MUST exist before tasks are generated
- Constitution Check gates in `plan.md` MUST be verified before Phase 0 research
  and re-verified after Phase 1 design
- PRs to `main` require all XCTest targets passing and no unresolved TODO items
  in the implementation scope

## Governance

This constitution supersedes all informal conventions and ad-hoc decisions. When a
technical decision conflicts with a principle, the principle wins unless an amendment
is ratified.

**Amendment procedure**:
1. Open a spec describing the proposed change and its rationale
2. Record the old principle and the replacement in the Sync Impact Report comment
3. Increment version (MAJOR for removals/redefinitions, MINOR for additions,
   PATCH for clarifications)
4. Update `LAST_AMENDED_DATE`

**Compliance**: Every PR description MUST include a Constitution Check section
confirming each principle is satisfied or explicitly noting any justified deviation.
Complexity violations require a Complexity Tracking entry in `plan.md`.

**Version**: 1.0.0 | **Ratified**: 2026-05-25 | **Last Amended**: 2026-05-25

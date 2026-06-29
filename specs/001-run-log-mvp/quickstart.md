# Quickstart: RunStats Runner's Log MVP

**Feature Branch**: `001-run-log-mvp`
**Date**: 2026-06-29

## Prerequisites

- Xcode with iOS/iPadOS 26.5 SDK
- No third-party packages — all frameworks are Apple system frameworks

## Build & Run

```bash
# Command-line build
xcodebuild -scheme RunStats3 -configuration Debug -derivedDataPath build

# Run tests (after RunStats3Tests target is created)
xcodebuild test -scheme RunStats3 -destination 'platform=iOS Simulator,name=iPhone 16'
```

For interactive development: open `RunStats3.xcodeproj`, select scheme RunStats3, Cmd+R to run, Cmd+U to test.

## First Task: Add Test Target

No test target exists yet. Before any ViewModel implementation:

1. Xcode → File → New Target → Unit Testing Bundle
2. Name: `RunStats3Tests`
3. Host Application: `RunStats3`
4. Add `RunStats3Tests` to scheme Test action
5. Verify `Cmd+U` runs (empty suite passes)

## Frameworks

| Framework | Import | Purpose |
|---|---|---|
| SwiftUI | `import SwiftUI` | All UI; views, forms, navigation |
| SwiftData | `import SwiftData` | Local persistence; `@Model`, `@Query` |
| Swift Charts | `import Charts` | `BarMark` pace chart |
| XCTest | `import XCTest` | ViewModel and Service unit tests |

## TDD Flow (required by constitution)

```
1. Write failing XCTest
2. Run Cmd+U → red
3. Implement minimum production code
4. Run Cmd+U → green
5. Refactor → still green
6. Commit
```

## Key Files by Concern

| Concern | File |
|---|---|
| App entry point + ModelContainer | `RunStats3/RunStats3App.swift` |
| Mode toggle (View/Edit) | `RunStats3/Views/AppCoordinatorView.swift` |
| Run data model | `RunStats3/Models/Run.swift` |
| Split data model + pace calculation | `RunStats3/Models/Split.swift` |
| History list logic | `RunStats3/ViewModels/RunListViewModel.swift` |
| Split detail + chart data | `RunStats3/ViewModels/RunDetailViewModel.swift` |
| Create/edit + validation | `RunStats3/ViewModels/RunEditViewModel.swift` |
| SwiftData persistence | `RunStats3/Services/RunStore.swift` |
| Pace bar chart component | `RunStats3/Views/Components/PaceBarChart.swift` |

## Distance Validation Rule

All distance comparisons use centimile (hundredths of a mile) integer arithmetic to avoid floating-point drift:

```swift
// Valid when splits sum to total distance:
run.splitsDistanceCentimiles == run.totalDistanceCentimiles

// Where:
var splitsDistanceCentimiles: Int { Int(round(splits.reduce(0.0) { $0 + $1.distance } * 100)) }
var totalDistanceCentimiles: Int { Int(round(totalDistance * 100)) }
```

Always round user-entered distances to 2 decimal places before storing.

## MVVM Boundaries (constitution requirement)

```
Views        → observe ViewModels; no business logic; no direct model access
ViewModels   → hold state, derived values, commands; no SwiftUI imports
Models       → plain Swift structs/classes; no view knowledge
RunStore     → SwiftData operations only; injected into ViewModels via protocol
```

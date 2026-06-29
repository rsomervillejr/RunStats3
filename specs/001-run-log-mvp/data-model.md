# Data Model: RunStats Runner's Log MVP

**Feature Branch**: `001-run-log-mvp`
**Date**: 2026-06-29

## Entities

### Run

Represents a single running activity.

| Field | Type | Constraints |
|---|---|---|
| `id` | UUID | Auto-generated; primary key |
| `date` | Date | Required |
| `runType` | RunType | Required; `.race` or `.workout` |
| `venue` | Venue | Required; `.outdoor` or `.treadmill` |
| `totalDistance` | Double | Required; > 0; miles rounded to 2 decimal places at input |
| `splits` | [Split] | Min 1 (FR-013); ordered by `position`; cascade delete on Run deletion |

**Invariant (FR-016)**: `Int(round(splits.map(\.distance).reduce(0,+) * 100)) == Int(round(totalDistance * 100))` — enforced as hard block at save time.

### Split

Represents one distance segment within a run.

| Field | Type | Constraints |
|---|---|---|
| `id` | UUID | Auto-generated; primary key |
| `position` | Int | 1-based; unique per run; determines display order |
| `distance` | Double | > 0; miles rounded to 2 decimal places at input; fractional values allowed (e.g., 0.10) |
| `durationSeconds` | Int | > 0; total seconds for this segment |
| `run` | Run? | Required parent; set on creation |

**Derived (not stored)**:

| Computed property | Formula | Unit |
|---|---|---|
| `pace` | `Double(durationSeconds) / 60.0 / distance` | minutes per mile |
| `formattedDuration` | `MM:SS` string from durationSeconds | display |
| `formattedPace` | `MM:SS /mi` string from pace | display |

### RunType

```swift
enum RunType: String, CaseIterable, Codable {
    case race    = "Race"
    case workout = "Workout"
}
```

### Venue

```swift
enum Venue: String, CaseIterable, Codable {
    case outdoor   = "Outdoor"
    case treadmill = "Treadmill"
}
```

## Relationships

```
Run ──< Split    (one-to-many; @Relationship deleteRule: .cascade)
Split >── Run    (inverse; optional on Split to satisfy SwiftData requirements)
```

## Validation Rules

| Rule | Trigger | Response |
|---|---|---|
| `totalDistance > 0` | Run form input | Reject zero or negative; inline error |
| `splits.count >= 1` | Save attempt | Hard block (FR-013); show message |
| `split.distance > 0` | Per-split input | Reject zero or negative; inline error |
| `split.durationSeconds > 0` | Per-split input | Reject zero or negative; inline error |
| Split sum == total distance | Save attempt | Hard block (FR-016); show discrepancy in miles |

**Discrepancy display** (FR-016): When `splitSumCentimiles != totalDistanceCentimiles`, show:
- If sum < total: "X.XX miles still unaccounted for"
- If sum > total: "X.XX miles over total distance"

where `X.XX = abs(splitSum - totalDistance)` formatted to 2 decimal places.

## SwiftData Schema Reference

```swift
// Models/Run.swift
@Model
final class Run {
    var id: UUID = UUID()
    var date: Date = Date()
    var runType: RunType = RunType.workout
    var venue: Venue = Venue.outdoor
    var totalDistance: Double = 0.0

    @Relationship(deleteRule: .cascade, inverse: \Split.run)
    var splits: [Split] = []

    // Helpers
    var splitsSorted: [Split] { splits.sorted { $0.position < $1.position } }
    var splitsDistanceCentimiles: Int { Int(round(splits.reduce(0.0) { $0 + $1.distance } * 100)) }
    var totalDistanceCentimiles: Int { Int(round(totalDistance * 100)) }
    var isDistanceValid: Bool { splitsDistanceCentimiles == totalDistanceCentimiles }
    var isSaveable: Bool { !splits.isEmpty && isDistanceValid }
}

// Models/Split.swift
@Model
final class Split {
    var id: UUID = UUID()
    var position: Int = 0
    var distance: Double = 1.0
    var durationSeconds: Int = 0
    var run: Run?

    var pace: Double {
        guard distance > 0 else { return 0 }
        return Double(durationSeconds) / 60.0 / distance
    }
    var formattedDuration: String {
        let m = durationSeconds / 60; let s = durationSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
    var formattedPace: String {
        let total = Int(pace * 60); let m = total / 60; let s = total % 60
        return String(format: "%d:%02d /mi", m, s)
    }
}
```

## ModelContainer Configuration

```swift
// RunStats3App.swift
@main
struct RunStats3App: App {
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
        }
        .modelContainer(for: [Run.self, Split.self])
    }
}
```

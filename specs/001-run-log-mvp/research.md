# Research: RunStats Runner's Log MVP

**Feature Branch**: `001-run-log-mvp`
**Date**: 2026-06-29

## Persistence Layer

**Decision**: SwiftData
**Rationale**: SwiftData is the modern Swift-native persistence framework (iOS 17+). The project targets iOS/iPadOS 26.5, well above the minimum. SwiftData uses the `@Model` macro (declarative), integrates natively with SwiftUI via `@Query` and `@Environment(\.modelContext)`, and eliminates CoreData's NSManagedObject/NSFetchRequest boilerplate. Relationships are declared with `@Relationship(deleteRule:)`.
**Alternatives considered**: CoreData — mature and battle-tested but requires Objective-C bridging patterns that conflict with idiomatic Swift MVVM. Significant boilerplate with no benefit over SwiftData at the target OS version.

## Charting

**Decision**: Swift Charts (`import Charts`) — specifically `BarMark`
**Rationale**: Apple-native, SwiftUI-native, available since iOS 16 (far below target 26.5). `BarMark` renders a bar chart from a data array in ~10 lines of SwiftUI code. Fully accessible (VoiceOver descriptions generated automatically) and composable with standard SwiftUI modifiers. No third-party dependency.
**Alternatives considered**: Custom SwiftUI `Canvas` drawing — complete control over rendering but ~10× more implementation effort. Not justified for a standard bar chart.

## Distance Precision and Split Validation

**Decision**: Store split and run distances as `Double`. Round to 2 decimal places (centimile precision) on input. Validate by comparing integer centimile values: `Int(round(splitSum * 100)) == Int(round(totalDistance * 100))`.
**Rationale**: User input is always entered to at most 2 decimal places (e.g., 3.10, 0.10). Rounding to centimiles before storage means the sum of stored centimile-rounded values will always be exact when compared as integers. No floating-point epsilon needed. `Double` is SwiftData's native numeric type (no encoding overhead). The centimile comparison is a single integer equality check — simple and fast.
**Alternatives considered**:
- `Decimal` type — exact decimal arithmetic but requires Codable serialization in SwiftData (stored as JSON), complicates SwiftUI TextField bindings, and adds complexity for no benefit given 2-decimal-place inputs.
- `Int` (centimiles only, multiply by 100) — exact but awkward for display and form bindings; would require manual conversion everywhere.

## Split Duration Storage

**Decision**: Store split duration as `Int` (total seconds).
**Rationale**: Integer seconds are exact, compact, and trivially formatted as MM:SS. Pace is computed at read time as `Double(durationSeconds) / 60.0 / distance` — not stored. No precision loss for any realistic split time.
**Alternatives considered**: `TimeInterval` (Double seconds) — unnecessary sub-second precision for running splits. `DateComponents` — significant overhead and serialization complexity.

## App Mode (View / Edit)

**Decision**: App-level boolean state `isEditMode: Bool` held as `@State` in `AppCoordinatorView` (the root view), passed into child views via environment.
**Rationale**: The spec (FR-005, SC-006) describes two modes as a global toggle with a one-tap switch. A single `@State` at the NavigationStack root is the idiomatic SwiftUI pattern for app-level state without over-engineering. Passes cleanly into `RunListView` to control whether tapping a run navigates to detail (View mode) or edit form (Edit mode).
**Alternatives considered**:
- `@AppStorage` (persistent across launches) — users should land in View mode on launch; persisting mode choice adds surprising behavior.
- Separate TabView tabs — heavier UX than a simple toggle; the spec describes modes, not destinations.
- `@EnvironmentObject` — appropriate if mode state needed deep in the hierarchy, but for this feature `@State` + environment value is sufficient and simpler.

## Test Target

**Decision**: Add a new `RunStats3Tests` XCTest unit test target to the Xcode project.
**Rationale**: No test target exists in the project. Constitution Principle II mandates XCTest coverage for ViewModel and Service layers before marking any feature complete. This is a prerequisite task that must be completed before any ViewModel implementation begins.
**Setup**: In Xcode → File → New Target → Unit Testing Bundle → `RunStats3Tests`. Set host app to `RunStats3`. Add to scheme's Test action.

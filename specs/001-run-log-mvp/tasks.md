# Tasks: RunStats Runner's Log MVP

**Input**: Design documents from `specs/001-run-log-mvp/`
**Branch**: `001-run-log-mvp`

**Tests**: Included per Constitution Principle II — TDD is mandatory. Write failing test → implement → refactor (Red-Green-Refactor). Every ViewModel and Service task has a corresponding test task that MUST precede it.

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to
- All Swift source files live under `RunStats3/` and must be added to the Xcode project target. Use Xcode's File → New File or drag-to-project to ensure they compile.

---

## Phase 1: Setup

**Purpose**: Xcode project initialization required before any implementation can begin.

- [ ] T001 Add RunStats3Tests unit test target via Xcode: File → New Target → Unit Testing Bundle, name `RunStats3Tests`, host application `RunStats3`; add to scheme Test action; verify Cmd+U runs (empty suite passes)
- [ ] T002 [P] Create source folders on disk: `RunStats3/Models/`, `RunStats3/ViewModels/`, `RunStats3/Views/`, `RunStats3/Views/Components/`, `RunStats3/Services/`; add matching Xcode groups to the RunStats3 target
- [ ] T003 [P] Create test folders on disk: `RunStats3Tests/Models/`, `RunStats3Tests/ViewModels/`, `RunStats3Tests/Services/`; add matching Xcode groups to the RunStats3Tests target

**Checkpoint**: `Cmd+U` passes with zero tests. Ready for foundational work.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Data layer, persistence service, and app shell. MUST complete before any user story implementation.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T004 [P] Create `RunType` enum (`case race = "Race"`, `case workout = "Workout"`) conforming to `String, CaseIterable, Codable` in `RunStats3/Models/RunType.swift`
- [ ] T005 [P] Create `Venue` enum (`case outdoor = "Outdoor"`, `case treadmill = "Treadmill"`) conforming to `String, CaseIterable, Codable` in `RunStats3/Models/Venue.swift`
- [ ] T006 Create `Run` `@Model` class per `data-model.md` schema: fields `id`, `date`, `runType`, `venue`, `totalDistance`; `@Relationship(deleteRule: .cascade, inverse: \Split.run)` splits array; computed helpers `splitsSorted`, `splitsDistanceCentimiles`, `totalDistanceCentimiles`, `isDistanceValid`, `isSaveable` in `RunStats3/Models/Run.swift`
- [ ] T007 Create `Split` `@Model` class per `data-model.md` schema: fields `id`, `position`, `distance`, `durationSeconds`, `run: Run?`; computed `pace`, `formattedDuration` (MM:SS), `formattedPace` (MM:SS /mi) in `RunStats3/Models/Split.swift`
- [ ] T008 [P] Write failing unit tests for Run and Split computed properties using an in-memory `ModelContainer`; cover: `Run.isDistanceValid` (centimile match), `Run.isSaveable` (no splits → false), `Split.pace` (correct formula), `Split.formattedPace` (correct string); run Cmd+U → red in `RunStats3Tests/Models/RunModelTests.swift`
- [ ] T009 Run `Cmd+U`; fix `Run` and `Split` until all `RunModelTests` pass → green
- [ ] T010 Update `RunStats3/RunStats3App.swift`: add `.modelContainer(for: [Run.self, Split.self])` to `WindowGroup` scene; replace `ContentView()` with `AppCoordinatorView()`
- [ ] T011 Create `AppCoordinatorView` with `@State private var isEditMode = false`; embed `RunListView` inside `NavigationStack`; add toolbar `Button` ("Edit" / "Done") that toggles `isEditMode`; pass `isEditMode` into `RunListView` via environment or binding in `RunStats3/Views/AppCoordinatorView.swift`

**Checkpoint**: App builds and launches to a NavigationStack shell with a mode-toggle toolbar button. Ready for user story implementation.

---

## Phase 3: User Story 1 — View Run History (Priority: P1) 🎯 MVP

**Goal**: App opens in View mode showing a scrollable list of all logged runs sorted newest-first, each row showing date, type, venue, and total distance. Empty state shown when no runs exist.

**Independent Test**: Seed 3 runs with different dates using an in-memory `ModelContainer`; open `RunListView` in a preview or simulator; verify rows are ordered newest-first with correct date, type, venue, and distance; verify empty state message appears when runs array is empty.

### Tests for User Story 1 ⚠️ Write FIRST — must FAIL before implementation

- [ ] T012 [US1] Write failing `RunListViewModel` unit tests: fetch returns runs sorted by date descending; `isEmpty` is `true` when no runs; `isEmpty` is `false` when runs exist; `runs` array count matches inserted count; use in-memory `ModelContainer`; run Cmd+U → red in `RunStats3Tests/ViewModels/RunListViewModelTests.swift`

### Implementation for User Story 1

- [ ] T013 [US1] Implement `RunListViewModel` (`@Observable` class): `init(modelContext: ModelContext)`; `var runs: [Run]` populated via `FetchDescriptor<Run>(sortBy: [SortDescriptor(\.date, order: .reverse)])`; `var isEmpty: Bool`; `func fetchRuns()` called on init; no SwiftUI imports in `RunStats3/ViewModels/RunListViewModel.swift`; run Cmd+U → green
- [ ] T014 [US1] Create `RunListView`: accepts `isEditMode: Bool` and `modelContext`; uses `@State var viewModel: RunListViewModel`; shows `List` of run rows displaying date (formatted), `runType.rawValue`, `venue.rawValue`, total distance (e.g., "3.10 mi"); shows empty-state `ContentUnavailableView` when `viewModel.isEmpty` in `RunStats3/Views/RunListView.swift`
- [ ] T015 [US1] Add `accessibilityLabel` to each list row (e.g., "\(date), \(type), \(venue), \(distance) miles") and to the empty-state view in `RunStats3/Views/RunListView.swift`

**Checkpoint**: `Cmd+U` passes all US1 tests. Simulator: empty state visible on launch; seeded runs appear in date-descending order.

---

## Phase 4: User Story 2 — View Run Detail with Split Chart (Priority: P1)

**Goal**: In View mode, tapping a run navigates to a detail screen showing all splits in order (distance, time, pace) and a `BarMark` pace chart — one bar per split.

**Independent Test**: Seed a run with 4 splits (3 × 1.00 mi + 1 × 0.10 mi); tap it; verify 4 rows appear in position order with correct distance/time/pace values; verify chart renders 4 bars.

### Tests for User Story 2 ⚠️ Write FIRST — must FAIL before implementation

- [ ] T016 [P] [US2] Write failing `RunDetailViewModel` unit tests: `sortedSplits` returns splits in position order; `chartData` count matches split count; `chartData[i].pace` equals `Split.pace` for each split; use in-memory `ModelContainer` with pre-seeded run; run Cmd+U → red in `RunStats3Tests/ViewModels/RunDetailViewModelTests.swift`

### Implementation for User Story 2

- [ ] T017 [US2] Implement `RunDetailViewModel` (`@Observable` class): `init(run: Run)`; `var sortedSplits: [Split]` (by position); `var chartData: [(position: Int, pace: Double)]` derived from sortedSplits; no SwiftUI imports in `RunStats3/ViewModels/RunDetailViewModel.swift`; run Cmd+U → green
- [ ] T018 [P] [US2] Create `SplitRowView`: displays "Mile \(position)" label, distance (e.g., "1.00 mi"), `formattedDuration`, `formattedPace`; `accessibilityLabel` with all values in `RunStats3/Views/Components/SplitRowView.swift`
- [ ] T019 [P] [US2] Create `PaceBarChart` using `import Charts`; `BarMark(x: .value("Split", item.position), y: .value("Pace", item.pace))`; axis labels: split number (x), "min/mi" (y); `accessibilityLabel` on chart describing pace range in `RunStats3/Views/Components/PaceBarChart.swift`
- [ ] T020 [US2] Create `RunDetailView`: accepts `Run`; creates `RunDetailViewModel`; shows `ScrollView` with run header (date, type, venue, total distance), `List` of `SplitRowView` items, and `PaceBarChart` below the list in `RunStats3/Views/RunDetailView.swift`
- [ ] T021 [US2] Add `navigationDestination(for: Run.self)` in `AppCoordinatorView` or `RunListView` navigating to `RunDetailView` when `isEditMode == false` and a run row is tapped in `RunStats3/Views/RunListView.swift`

**Checkpoint**: `Cmd+U` passes all US2 tests. Simulator: tapping a seeded run in View mode shows split rows and pace bar chart.

---

## Phase 5: User Story 3 — Log a New Run (Priority: P2)

**Goal**: In Edit mode, user can create a new run by entering total distance, run type, venue, date, and one or more splits (each with distance and time). Saving is hard-blocked until all split distances sum (at centimile precision) to the entered total run distance.

**Independent Test**: Enter total distance 3.10; add splits 1.00, 1.00, 0.90; verify Save blocked and discrepancy "0.20 miles under total" shown; change last split to 1.10; verify Save enabled; save; verify run appears in list with correct data.

### Tests for User Story 3 ⚠️ Write FIRST — must FAIL before implementation

- [ ] T022 [US3] Write failing `RunEditViewModel` tests (create mode): `isValid` false when no splits; `isValid` false when split sum ≠ total (centimile comparison); `isValid` true when sum matches; `discrepancyMiles` correct sign and value; `save()` inserts Run into ModelContext; run Cmd+U → red in `RunStats3Tests/ViewModels/RunEditViewModelTests.swift`

### Implementation for User Story 3

- [ ] T023 [US3] Implement `RunEditViewModel` (create mode, `init(modelContext: ModelContext, run: Run? = nil)`): `@Observable`; form state properties `date`, `runType`, `venue`, `totalDistanceText: String`; `splits: [SplitDraft]` (value type with `distance: Double`, `durationSeconds: Int`); `addSplit()`, `removeSplit(at:)`; computed `totalDistanceCentimiles`, `splitSumCentimiles`, `discrepancyMiles: Double`, `isValid: Bool`; `func save() throws` creating and inserting `Run` + `Split` objects in `RunStats3/ViewModels/RunEditViewModel.swift`; run Cmd+U → green
- [ ] T024 [US3] Create `SplitDraft` value type (struct: `id: UUID`, `distance: Double`, `durationSeconds: Int`) in `RunStats3/Models/SplitDraft.swift` for use in `RunEditViewModel` form state
- [ ] T025 [US3] Create `RunEditView`: accepts `RunEditViewModel`; form with `DatePicker` (date), `Picker` (runType), `Picker` (venue), `TextField` (total distance); dynamic split list with per-split distance and time fields; `Button("Add Split")`; validation error banner showing `discrepancyMiles` when `!viewModel.isValid`; `Save` button disabled when `!viewModel.isValid`; `Cancel` button in `RunStats3/Views/RunEditView.swift`
- [ ] T026 [US3] Add accessibilityLabel to all `RunEditView` form controls and the discrepancy error banner in `RunStats3/Views/RunEditView.swift`
- [ ] T027 [US3] Add "New Run" toolbar button in `AppCoordinatorView` (visible when `isEditMode == true`) that presents `RunEditView` with a fresh `RunEditViewModel`; on save dismiss and call `viewModel.fetchRuns()` in `RunStats3/Views/AppCoordinatorView.swift`

**Checkpoint**: `Cmd+U` passes all US3 tests. Simulator: in Edit mode tap "New Run", enter splits that don't match total → Save disabled with discrepancy message; fix splits → Save enabled; new run appears in list.

---

## Phase 6: User Story 4 — Edit an Existing Run (Priority: P3)

**Goal**: In Edit mode, tapping a run row opens `RunEditView` pre-populated with the run's current data. Saving writes changes back. Cancel leaves data unchanged.

**Independent Test**: Seed a run with 3 splits; tap it in Edit mode; verify all fields pre-populated; change split 2 time; save; verify updated time reflected in detail view and correct pace.

### Tests for User Story 4 ⚠️ Write FIRST — must FAIL before implementation

- [ ] T028 [US4] Extend `RunEditViewModelTests` with edit-mode tests: init with existing Run pre-populates all fields; `save()` updates existing Run in ModelContext (no new Run inserted); cancel leaves ModelContext unchanged; run Cmd+U → red in `RunStats3Tests/ViewModels/RunEditViewModelTests.swift`

### Implementation for User Story 4

- [ ] T029 [US4] Extend `RunEditViewModel.init(modelContext:run:)`: when `run != nil`, pre-populate `date`, `runType`, `venue`, `totalDistanceText`, and `splits` from the existing `Run`; `save()` updates fields on existing Run object instead of inserting new one in `RunStats3/ViewModels/RunEditViewModel.swift`; run Cmd+U → green
- [ ] T030 [US4] Add `navigationDestination` in `AppCoordinatorView` or `RunListView` for Edit mode: when `isEditMode == true` and a run row is tapped, navigate to `RunEditView(viewModel: RunEditViewModel(modelContext:, run: tappedRun))` in `RunStats3/Views/RunListView.swift`

**Checkpoint**: `Cmd+U` passes all US4 tests. Simulator: tap a run in Edit mode → opens pre-populated form; change a split → save → detail view reflects updated values.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Hardening, previews, and performance validation before marking MVP complete.

- [ ] T031 [P] Add `#Preview` macros with sample data to `RunListView`, `RunDetailView`, `RunEditView`, `SplitRowView`, `PaceBarChart`, and `AppCoordinatorView` so Xcode canvas previews work without running the simulator
- [ ] T032 [P] Validate all 4 user story acceptance scenarios from `spec.md` end-to-end in iPhone simulator; record any failing scenarios and create follow-up tasks
- [ ] T033 Seed 200+ runs and verify RunListView scrolls at 60 fps using Instruments Time Profiler (Constitution IV — SC-002)
- [ ] T034 Profile memory with Xcode Memory Graph after 10+ minutes of navigation (list → detail → edit → back); confirm no unbounded growth (Constitution IV)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 (T001 must exist before T008 can compile) — **BLOCKS all user stories**
- **Phase 3 (US1)**: Depends on Phase 2 complete
- **Phase 4 (US2)**: Depends on Phase 2 complete; can run in parallel with US1 if staffed
- **Phase 5 (US3)**: Depends on Phase 2 complete; US3 navigation (T027) requires US1 RunListView
- **Phase 6 (US4)**: Depends on Phase 5 (RunEditViewModel and RunEditView must exist)
- **Phase 7 (Polish)**: Depends on all desired user stories complete

### User Story Dependencies

- **US1 (P1)**: No story dependencies; needs foundational layer only
- **US2 (P1)**: No story dependencies; can start in parallel with US1 after Phase 2
- **US3 (P2)**: Navigation task T027 requires RunListView from US1
- **US4 (P3)**: Requires RunEditViewModel and RunEditView from US3

### Within Each Phase (TDD Order)

1. Write failing test first (Cmd+U → red)
2. Implement minimum code to pass
3. Refactor (Cmd+U → still green)
4. Commit

### Parallel Opportunities

Within Phase 2: T004 and T005 [P] (enum files — no dependency on each other)
Within Phase 4: T016, T018, T019 [P] (ViewModel test, SplitRowView, PaceBarChart — separate files)

---

## Parallel Example: Phase 2 Foundation

```text
Start simultaneously:
  T004 — RunType.swift
  T005 — Venue.swift

Then sequentially:
  T006 → T007 (Split needs Run reference) → T008 (tests) → T009 (fix models)
  T010 → T011 (AppCoordinatorView needs App wired first)
```

## Parallel Example: User Story 2

```text
After T016 (test) is written and failing:
  Launch simultaneously:
    T018 — SplitRowView.swift  [P]
    T019 — PaceBarChart.swift  [P]

Then sequentially:
  T017 (RunDetailViewModel) → T020 (RunDetailView) → T021 (navigation)
```

---

## Implementation Strategy

### MVP (User Stories 1 + 2 only — both P1)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: US1 (view run list)
4. Complete Phase 4: US2 (view run detail + chart)
5. **STOP and VALIDATE**: All US1 + US2 acceptance scenarios pass
6. Demo/review as MVP

### Full Feature Delivery

After MVP validation:
1. Phase 5: US3 (create new run)
2. Phase 6: US4 (edit existing run)
3. Phase 7: Polish + performance validation

### Parallel Team Strategy

After Phase 2 complete:
- Developer A: Phase 3 (US1)
- Developer B: Phase 4 (US2)
Stories merge independently; US3/US4 begin after both P1 stories complete.

---

## Notes

- `[P]` = different file, no dependency on an incomplete sibling task — safe to run in parallel
- Every `[USn]` test task MUST complete (Cmd+U → red) before its matching implementation task
- Constitution: no force-unwrap (`!`) in production code; all ViewModels import only SwiftData/Observation, not SwiftUI
- Distance comparison always uses centimile integer check: `Int(round(x * 100))`
- New Swift files must be added to the correct Xcode target (RunStats3 or RunStats3Tests) — use Xcode's File → New File or project navigator drag

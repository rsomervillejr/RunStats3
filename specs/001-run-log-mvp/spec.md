# Feature Specification: RunStats Runner's Log MVP

**Feature Branch**: `001-run-log-mvp`  
**Created**: 2026-06-26  
**Status**: Draft  

## Clarifications

### Session 2026-06-29

- Q: Is "total distance of the entire run" a separately entered field, or derived as the sum of splits? → A: Total distance is a separately entered field on the Run; splits must sum to it.
- Q: When split distances don't sum to the entered total run distance, what should the app do? → A: Hard block — saving is prevented until split distances sum exactly to total run distance; app displays the discrepancy.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Run History (Priority: P1)

A runner opens the app and immediately sees a chronological list of all their logged runs, newest first. Each entry in the list shows enough information to identify the run at a glance: date, run type, venue, and total distance.

**Why this priority**: This is the primary read path. Without a history list, the app has no value as a log. All other features depend on this foundation being in place.

**Independent Test**: Open the app with at least one run logged. Verify a list appears with runs ordered newest-to-oldest. Delivers value as a read-only running journal.

**Acceptance Scenarios**:

1. **Given** the app has at least one run logged, **When** the user opens the app in View mode, **Then** a scrollable list of runs appears ordered by date descending, showing date, type (Race/Workout), venue (Outdoor/Treadmill), and total distance for each entry.
2. **Given** the app has no runs logged, **When** the user opens the app in View mode, **Then** an empty-state message is displayed indicating no runs have been logged yet.
3. **Given** the user is in View mode with a long list, **When** they scroll the list, **Then** all entries remain accessible without performance degradation.

---

### User Story 2 - View Run Detail with Split Chart (Priority: P1)

A runner selects a run from the history list and sees the full breakdown: every split's distance and time, calculated pace per split, and a bar chart visualizing how pace varied across the run.

**Why this priority**: The per-split detail and chart are the core analytical value proposition of the app over a simple notes app. This is what makes RunStats a statistical tool.

**Independent Test**: Select any run from the list. Verify splits are listed in order and a bar chart of pace per split renders. Delivers the core analytical capability independently of edit functionality.

**Acceptance Scenarios**:

1. **Given** a run with multiple splits, **When** the user selects it from the history list, **Then** a detail view shows each split in order with its distance, time, and pace, followed by a bar chart where each bar represents one split's pace.
2. **Given** a run detail view is open, **When** the user examines the bar chart, **Then** each bar corresponds to a split and the bar height reflects the pace (slower pace = taller bar or clearly distinguished visually).
3. **Given** a run detail view is open, **When** the user wants to return to the list, **Then** they can navigate back without losing their place in the history list.

---

### User Story 3 - Log a New Run (Priority: P2)

A runner completes a run and opens the app in Edit mode to record it. They enter the date, the total distance of the run, categorize it as a race or workout, note whether it was on a treadmill or outdoors, and enter the distance and time for each split. The app confirms that split distances sum to the total run distance before allowing the entry to be saved.

**Why this priority**: Data entry is essential, but the view experience (P1 stories) can be validated with seed data first. Edit mode follows once the display layer is proven.

**Independent Test**: Switch to Edit mode, create a new run with a total distance and at least 3 splits (including one fractional), verify save is blocked when splits don't sum to total, correct the splits, save, then confirm the run appears correctly in View mode.

**Acceptance Scenarios**:

1. **Given** the user is in Edit mode, **When** they choose to create a new run, **Then** a form appears allowing them to input date, total distance (in miles, decimal supported), run type (Race or Workout), venue (Outdoor or Treadmill), and one or more splits each with a distance and time.
2. **Given** the user is entering splits, **When** the sum of split distances does not equal the total run distance, **Then** saving is prevented and the app displays the discrepancy (the amount by which splits are over or under the total distance).
3. **Given** the sum of split distances exactly equals the total run distance, **When** the user saves the entry, **Then** the new run appears in the history list in the correct chronological position.
4. **Given** the user starts a new run form but does not save, **When** they cancel or navigate away, **Then** no partial entry is saved.

---

### User Story 4 - Edit an Existing Run (Priority: P3)

A runner notices a data entry error in a previously logged run and wants to correct it. In Edit mode, they select the run, modify the incorrect field, and save the correction.

**Why this priority**: Corrections are important for data integrity but are secondary to the core log-and-view workflow. The app delivers value even if editing requires deleting and re-entering.

**Independent Test**: Open an existing run in Edit mode, change a split distance or time, save, and verify the detail view reflects the corrected values and the bar chart updates accordingly.

**Acceptance Scenarios**:

1. **Given** the user is in Edit mode with existing runs present, **When** they select a run to edit, **Then** the run entry form opens pre-populated with the existing data.
2. **Given** the user has modified one or more fields, **When** they save the changes, **Then** the updated data is reflected in both the history list summary and the detail view.
3. **Given** the user opens a run for editing but makes no changes, **When** they cancel, **Then** the original data is unchanged.

---

### Edge Cases

- What happens when the user saves a run with no splits entered?
- How does the app handle a run date entered in the future?
- What does the bar chart display if a run has only one split?
- What happens if the user switches modes mid-entry without saving?
- What happens when the sum of split distances exceeds the total run distance?
- What happens when splits are entered but their sum is less than the total run distance (incomplete splits)?
- How does the app handle rounding when summing decimal split distances (e.g., 3 × 1.033... miles)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: App MUST display all logged runs in a scrollable list ordered by date, newest first, in View mode.
- **FR-002**: Each run row in the history list MUST show the run date, type (Race or Workout), venue (Outdoor or Treadmill), and the entered total distance for the run.
- **FR-003**: Selecting a run from the list MUST navigate to a detail view showing all splits in order with their individual distance, time, and calculated pace per split.
- **FR-004**: The run detail view MUST include a bar chart where each bar represents one split and bar height encodes the pace for that split.
- **FR-005**: App MUST support a View mode (read-only browsing of run history) and an Edit mode (creating and modifying run entries), with a clear mechanism to switch between them.
- **FR-006**: In Edit mode, users MUST be able to create a new run entry specifying date, total distance, run type, venue, and one or more splits each with a distance and time.
- **FR-007**: In Edit mode, users MUST be able to open an existing run entry, modify any field, and save the changes.
- **FR-008**: Each run MUST be classified as exactly one type: Race or Workout.
- **FR-009**: Each run MUST be classified as performed at exactly one venue: Outdoor or Treadmill.
- **FR-010**: All run data MUST be stored persistently on the device and survive app restarts.
- **FR-011**: App MUST NOT require user login, account creation, or network connectivity to function.
- **FR-012**: Users MUST be able to add an arbitrary number of splits to a run entry during creation or editing.
- **FR-013**: App MUST prevent saving a run entry with zero splits and inform the user.
- **FR-014**: Each split MUST have a user-specified distance in miles; decimal values (e.g., 0.10) MUST be supported to allow fractional splits such as a final partial mile.
- **FR-015**: Each run MUST have a user-entered total distance field (in miles; decimal values supported) representing the full intended distance of the run.
- **FR-016**: App MUST prevent saving a run entry when the sum of all split distances does not equal the total run distance; the app MUST display the discrepancy (amount over or under) until the mismatch is resolved.

### Key Entities

- **Run**: A single running activity. Attributes: date, type (Race or Workout), venue (Outdoor or Treadmill), total distance (in miles, decimal), ordered list of splits.
- **Split**: One distance segment within a run. Attributes: sequential position, distance in miles (decimal; e.g., 1.00 for a full mile or 0.10 for a tenth-mile final segment), time to complete that segment. Pace is derived from time ÷ distance (minutes per mile).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A runner can log a complete run with up to 10 splits (including fractional) in under 3 minutes from opening the app.
- **SC-002**: The history list loads and scrolls smoothly with 200 or more logged runs without noticeable lag.
- **SC-003**: The split detail view and bar chart appear within 1 second of selecting a run from the list.
- **SC-004**: 100% of run data entered in one app session is present and accurate when the app is relaunched.
- **SC-005**: A runner can locate a specific run by date, open it in Edit mode, correct a split, and save the correction in under 2 minutes.
- **SC-006**: The mode switch between View and Edit is accomplished in a single interaction (one tap).

## Assumptions

- No user authentication, cloud sync, or network connectivity is required in this version; all data is local to the device.
- The app is intended for a single runner on a single device (no multi-user or shared data).
- Distance is measured in miles; pace is expressed as minutes per mile.
- Race distances are not constrained to standard competition distances; the runner records however many splits the run contains with any distances that sum to the entered total.
- The app does not import data from external fitness devices or services (Garmin, Apple Watch, Health app) in this version.
- "Edit mode" is a global app state, not a per-entry toggle; switching modes affects how the history list behaves (view-only vs. tappable-to-edit).
- The history list does not need search or filter capability in this MVP; ordering by date is sufficient.
- Runs cannot be deleted in this MVP; only created and edited.

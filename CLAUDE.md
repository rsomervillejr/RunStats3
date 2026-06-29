# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

iOS/iPadOS SwiftUI app for tracking running statistics. Third iteration of the RunStats project. Early development stage — only boilerplate exists currently.

## Tech Stack

- **Language:** Swift 5.0
- **UI:** SwiftUI (declarative, MVVM-ready)
- **Build:** Xcode (open `RunStats3.xcodeproj`)
- **Deployment Target:** iOS/iPadOS 26.5 (`TARGETED_DEVICE_FAMILY = "1,2"`)
- **Bundle ID:** `com.runstats.RunStats3`

## Build & Run

```bash
# Command-line build
xcodebuild -scheme RunStats3 -configuration Debug -derivedDataPath build

# Run tests (when test target exists)
xcodebuild test -scheme RunStats3 -destination 'platform=iOS Simulator,name=iPhone 16'
```

For interactive dev, open `RunStats3.xcodeproj` in Xcode and use Cmd+R to run.

## Architecture

Entry point: `RunStats3/RunStats3App.swift` — `@main` struct, defines `WindowGroup` scene.

Root view: `RunStats3/ContentView.swift` — currently boilerplate.

SwiftUI preview (`#Preview`) is enabled — use Xcode canvas for rapid UI iteration without running the simulator.

Expected future layers:
- **Models** — `Run`, `RunStatistics` (distance, time, pace, date)
- **ViewModels** — observable objects driving views
- **Services** — data persistence (CoreData or SwiftData), location/GPS
- **Views** — run list, run detail, statistics/charts

## Spec Kit Workflow

This project uses **Spec Kit** (`.specify/`) for specification-driven development. Features follow the full cycle: `specify → clarify → plan → tasks → implement`.

Skills available via the `Skill` tool:

| Skill | Purpose |
|---|---|
| `speckit-specify` | Generate spec from feature description |
| `speckit-clarify` | Clarify ambiguities before planning |
| `speckit-plan` | Generate implementation plan from spec |
| `speckit-tasks` | Break plan into discrete tasks |
| `speckit-implement` | Implement tasks from the task list |
| `speckit-analyze` | Analyze existing code/specs |
| `speckit-checklist` | Generate review checklist |
| `speckit-constitution` | Manage project constitution |
| `speckit-taskstoissues` | Sync tasks to GitHub issues |
| `speckit-git-feature` | Create numbered feature branch |
| `speckit-git-commit` | Commit with Spec Kit conventions |
| `speckit-git-initialize` | Initialize repo with Spec Kit structure |
| `speckit-git-remote` | Configure remote |
| `speckit-git-validate` | Validate branch/commit state |

Git branching uses sequential numbering (`001-feature-name`). Feature branches are created automatically before `specify`. Constitution is at `.specify/memory/constitution.md` — **ratified v1.0.0 (2026-05-25)**.

## Constitution Rules (Non-Negotiable)

Ratified v1.0.0. Full text at `.specify/memory/constitution.md`.

- **MVVM hard boundary**: Views own no business logic; ViewModels own no layout; Models are structs unless identity requires class
- **No force-unwrap** (`!`) except in test code and `@IBOutlet`/`@IBAction`
- **TDD required**: write failing XCTest → implement → refactor; no feature is done without passing ViewModel/Service tests
- **Native UX**: use system defaults (`Font.body`, `.primary`, `Color.accentColor`, `NavigationStack`); HIG deviations must be justified in the spec
- **No main-thread I/O**: async all fetches; SwiftData/CoreData fetches must be paginated
- **PRs to `main`**: all XCTest targets must pass, no unresolved TODOs in scope; PR description must include a Constitution Check section

## Related Projects

- `~/Documents/RunStats/` — original Garmin TCX parser (Python/pandas)
- `~/Documents/RunStats2/` — Flask REST API for running stats (Python/Flask/SQLAlchemy)

## Active Technologies
- Swift 5.0 + SwiftUI (UI), Swift Charts (bar chart), SwiftData (persistence) — all system frameworks, no third-party packages (001-run-log-mvp)
- SwiftData, local device only (001-run-log-mvp)

## Recent Changes
- 001-run-log-mvp: Added Swift 5.0 + SwiftUI (UI), Swift Charts (bar chart), SwiftData (persistence) — all system frameworks, no third-party packages

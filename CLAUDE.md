# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

iOS/iPadOS SwiftUI app for tracking running statistics. Third iteration of the RunStats project. Early development stage — only boilerplate exists currently.

## Tech Stack

- **Language:** Swift
- **UI:** SwiftUI (declarative, MVVM-ready)
- **Build:** Xcode (open `RunStats3.xcodeproj`)
- **Deployment Target:** iOS 26.5
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

This project uses **Spec Kit** (`.specify/`) for specification-driven development. Features go through: specify → plan → tasks → implement.

Skills available via the `Skill` tool:

| Skill | Purpose |
|---|---|
| `speckit-specify` | Generate spec from feature description |
| `speckit-plan` | Generate implementation plan from spec |
| `speckit-tasks` | Break plan into discrete tasks |
| `speckit-implement` | Implement tasks from the task list |
| `speckit-clarify` | Clarify ambiguities before implementation |
| `speckit-analyze` | Analyze existing code/specs |
| `speckit-checklist` | Generate review checklist |

Git branching uses sequential numbering (`001-feature-name`). Feature branches are created automatically before `specify`. Constitution template is at `.specify/memory/constitution.md` — not yet filled in for this project.

## Related Projects

- `~/Documents/RunStats/` — original Garmin TCX parser (Python/pandas)
- `~/Documents/RunStats2/` — Flask REST API for running stats (Python/Flask/SQLAlchemy)

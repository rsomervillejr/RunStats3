import Foundation
import SwiftData
import Observation

@Observable
final class RunEditViewModel {
    private let modelContext: ModelContext
    private let existingRun: Run?

    var date: Date = Date()
    var runType: RunType = .workout
    var venue: Venue = .outdoor
    var totalDistanceText: String = ""
    var splits: [SplitDraft] = []

    init(modelContext: ModelContext, run: Run? = nil) {
        self.modelContext = modelContext
        self.existingRun = run
        if let run {
            date = run.date
            runType = run.runType
            venue = run.venue
            totalDistanceText = String(format: "%.2f", run.totalDistance)
            splits = run.splitsSorted.map { split in
                var draft = SplitDraft()
                draft.distanceText = String(format: "%.2f", split.distance)
                draft.minutesText = String(split.durationSeconds / 60)
                draft.secondsText = String(format: "%02d", split.durationSeconds % 60)
                return draft
            }
        }
    }

    var isEditMode: Bool { existingRun != nil }

    var totalDistance: Double {
        (Double(totalDistanceText) ?? 0).rounded(to: 2)
    }

    var totalDistanceCentimiles: Int {
        Int(round(totalDistance * 100))
    }

    var splitSumCentimiles: Int {
        Int(round(splits.reduce(0.0) { $0 + $1.distance } * 100))
    }

    var discrepancyMiles: Double {
        let diff = splits.reduce(0.0) { $0 + $1.distance } - totalDistance
        return (diff * 100).rounded() / 100
    }

    var hasAtLeastOneSplit: Bool { !splits.isEmpty }

    var allSplitsValid: Bool { splits.allSatisfy(\.isValid) }

    var isValid: Bool {
        hasAtLeastOneSplit &&
        allSplitsValid &&
        splitSumCentimiles == totalDistanceCentimiles &&
        totalDistance > 0
    }

    func addSplit() {
        splits.append(SplitDraft())
    }

    func removeSplit(at offsets: IndexSet) {
        splits.remove(atOffsets: offsets)
    }

    func save() throws {
        if let existing = existingRun {
            existing.date = date
            existing.runType = runType
            existing.venue = venue
            existing.totalDistance = totalDistance
            // Remove old splits and replace with new ones
            for split in existing.splits { modelContext.delete(split) }
            existing.splits = []
            for (i, draft) in splits.enumerated() {
                let split = Split(
                    position: i + 1,
                    distance: draft.distance.rounded(to: 2),
                    durationSeconds: draft.durationSeconds
                )
                split.run = existing
                modelContext.insert(split)
                existing.splits.append(split)
            }
        } else {
            let run = Run(date: date, runType: runType, venue: venue, totalDistance: totalDistance)
            modelContext.insert(run)
            for (i, draft) in splits.enumerated() {
                let split = Split(
                    position: i + 1,
                    distance: draft.distance.rounded(to: 2),
                    durationSeconds: draft.durationSeconds
                )
                split.run = run
                modelContext.insert(split)
                run.splits.append(split)
            }
        }
        try modelContext.save()
    }
}

private extension Double {
    func rounded(to places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}

import Foundation
import SwiftData

@Model
final class Run {
    var id: UUID = UUID()
    var date: Date = Date()
    var runType: RunType = RunType.workout
    var venue: Venue = Venue.outdoor
    var totalDistance: Double = 0.0

    @Relationship(deleteRule: .cascade, inverse: \Split.run)
    var splits: [Split] = []

    init(
        date: Date = Date(),
        runType: RunType = .workout,
        venue: Venue = .outdoor,
        totalDistance: Double = 0.0
    ) {
        self.id = UUID()
        self.date = date
        self.runType = runType
        self.venue = venue
        self.totalDistance = totalDistance
        self.splits = []
    }

    var splitsSorted: [Split] {
        splits.sorted { $0.position < $1.position }
    }

    var splitsDistanceCentimiles: Int {
        Int(round(splits.reduce(0.0) { $0 + $1.distance } * 100))
    }

    var totalDistanceCentimiles: Int {
        Int(round(totalDistance * 100))
    }

    var isDistanceValid: Bool {
        splitsDistanceCentimiles == totalDistanceCentimiles
    }

    var isSaveable: Bool {
        !splits.isEmpty && isDistanceValid
    }

    var discrepancyMiles: Double {
        let diff = splits.reduce(0.0) { $0 + $1.distance } - totalDistance
        return (diff * 100).rounded() / 100
    }
}

import Foundation
import SwiftData

@Model
final class Split {
    var id: UUID = UUID()
    var position: Int = 0
    var distance: Double = 1.0
    var durationSeconds: Int = 0
    var run: Run?

    init(position: Int, distance: Double = 1.0, durationSeconds: Int = 0, run: Run? = nil) {
        self.id = UUID()
        self.position = position
        self.distance = distance
        self.durationSeconds = durationSeconds
        self.run = run
    }

    var pace: Double {
        guard distance > 0, durationSeconds > 0 else { return 0 }
        return Double(durationSeconds) / 60.0 / distance
    }

    var formattedDuration: String {
        let m = durationSeconds / 60
        let s = durationSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var formattedPace: String {
        guard pace > 0 else { return "--:-- /mi" }
        let totalSeconds = Int(pace * 60)
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        return String(format: "%d:%02d /mi", m, s)
    }
}

import Foundation

struct SplitDraft: Identifiable {
    var id: UUID = UUID()
    var distanceText: String = "1.00"
    var minutesText: String = ""
    var secondsText: String = ""

    var distance: Double {
        Double(distanceText) ?? 0
    }

    var durationSeconds: Int {
        let m = Int(minutesText) ?? 0
        let s = Int(secondsText) ?? 0
        return m * 60 + s
    }

    var isDistanceValid: Bool { distance > 0 }
    var isDurationValid: Bool { durationSeconds > 0 }
    var isValid: Bool { isDistanceValid && isDurationValid }
}

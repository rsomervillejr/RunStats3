import Foundation
import Observation

@Observable
final class RunDetailViewModel {
    private let run: Run

    init(run: Run) {
        self.run = run
    }

    var sortedSplits: [Split] {
        run.splitsSorted
    }

    var chartData: [(position: Int, pace: Double)] {
        run.splitsSorted.map { (position: $0.position, pace: $0.pace) }
    }

    var run_: Run { run }
}

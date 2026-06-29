import XCTest
import SwiftData
@testable import RunStats3

final class RunDetailViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Run.self, Split.self, configurations: config)
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    private func makeRun() -> Run {
        let run = Run(date: Date(), runType: .race, venue: .outdoor, totalDistance: 3.10)
        context.insert(run)
        let s1 = Split(position: 1, distance: 1.00, durationSeconds: 510)
        let s2 = Split(position: 2, distance: 1.00, durationSeconds: 525)
        let s3 = Split(position: 3, distance: 0.10, durationSeconds: 52)
        s1.run = run; s2.run = run; s3.run = run
        run.splits = [s3, s1, s2] // deliberately unordered
        return run
    }

    func test_sortedSplits_returnsSplitsInPositionOrder() {
        let run = makeRun()
        let vm = RunDetailViewModel(run: run)
        let sorted = vm.sortedSplits
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].position, 1)
        XCTAssertEqual(sorted[1].position, 2)
        XCTAssertEqual(sorted[2].position, 3)
    }

    func test_chartData_countMatchesSplitCount() {
        let run = makeRun()
        let vm = RunDetailViewModel(run: run)
        XCTAssertEqual(vm.chartData.count, 3)
    }

    func test_chartData_paceMatchesSplitPace() {
        let run = makeRun()
        let vm = RunDetailViewModel(run: run)
        let sorted = run.splitsSorted
        for (i, item) in vm.chartData.enumerated() {
            XCTAssertEqual(item.pace, sorted[i].pace, accuracy: 0.001)
        }
    }

    func test_chartData_positionMatchesSplitPosition() {
        let run = makeRun()
        let vm = RunDetailViewModel(run: run)
        let sorted = run.splitsSorted
        for (i, item) in vm.chartData.enumerated() {
            XCTAssertEqual(item.position, sorted[i].position)
        }
    }
}

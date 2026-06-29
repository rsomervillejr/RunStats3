import XCTest
import SwiftData
@testable import RunStats3

final class RunListViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var viewModel: RunListViewModel!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Run.self, Split.self, configurations: config)
        context = container.mainContext
        viewModel = RunListViewModel(modelContext: context)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        container = nil
        context = nil
    }

    func test_isEmpty_withNoRuns_returnsTrue() {
        XCTAssertTrue(viewModel.isEmpty)
    }

    func test_isEmpty_afterInsertingRun_returnsFalse() throws {
        let run = Run(date: Date(), runType: .workout, venue: .outdoor, totalDistance: 3.0)
        context.insert(run)
        viewModel.fetchRuns()
        XCTAssertFalse(viewModel.isEmpty)
    }

    func test_runs_countMatchesInsertedRuns() throws {
        context.insert(Run(date: Date(), runType: .workout, venue: .outdoor, totalDistance: 3.0))
        context.insert(Run(date: Date(), runType: .race, venue: .treadmill, totalDistance: 5.0))
        context.insert(Run(date: Date(), runType: .workout, venue: .outdoor, totalDistance: 1.0))
        viewModel.fetchRuns()
        XCTAssertEqual(viewModel.runs.count, 3)
    }

    func test_runs_sortedByDateDescending() throws {
        let older = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let middle = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        let newer = Date()
        context.insert(Run(date: middle, runType: .workout, venue: .outdoor, totalDistance: 2.0))
        context.insert(Run(date: older, runType: .race, venue: .outdoor, totalDistance: 5.0))
        context.insert(Run(date: newer, runType: .workout, venue: .treadmill, totalDistance: 1.0))
        viewModel.fetchRuns()
        XCTAssertEqual(viewModel.runs.count, 3)
        XCTAssertTrue(viewModel.runs[0].date >= viewModel.runs[1].date)
        XCTAssertTrue(viewModel.runs[1].date >= viewModel.runs[2].date)
    }
}

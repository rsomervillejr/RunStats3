import XCTest
import SwiftData
@testable import RunStats3

final class RunEditViewModelTests: XCTestCase {
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

    // MARK: - Create mode: validation

    func test_isValid_withNoSplits_returnsFalse() {
        let vm = RunEditViewModel(modelContext: context)
        vm.totalDistanceText = "3.10"
        XCTAssertFalse(vm.isValid)
    }

    func test_isValid_whenSplitsSumMatchesTotal_returnsTrue() {
        let vm = RunEditViewModel(modelContext: context)
        vm.totalDistanceText = "2.00"
        vm.splits = [
            makeDraft(distance: "1.00", minutes: "8", seconds: "30"),
            makeDraft(distance: "1.00", minutes: "8", seconds: "45")
        ]
        XCTAssertTrue(vm.isValid)
    }

    func test_isValid_whenSplitsSumDoesNotMatchTotal_returnsFalse() {
        let vm = RunEditViewModel(modelContext: context)
        vm.totalDistanceText = "3.10"
        vm.splits = [
            makeDraft(distance: "1.00", minutes: "8", seconds: "30"),
            makeDraft(distance: "1.00", minutes: "8", seconds: "45")
        ]
        XCTAssertFalse(vm.isValid)
    }

    func test_isValid_withFractionalSplitSummingToTotal_returnsTrue() {
        let vm = RunEditViewModel(modelContext: context)
        vm.totalDistanceText = "3.10"
        vm.splits = [
            makeDraft(distance: "1.00", minutes: "8", seconds: "30"),
            makeDraft(distance: "1.00", minutes: "8", seconds: "45"),
            makeDraft(distance: "1.10", minutes: "9", seconds: "30")
        ]
        XCTAssertTrue(vm.isValid)
    }

    // MARK: - Discrepancy

    func test_discrepancyMiles_whenSplitsSumLessThanTotal_returnsNegative() {
        let vm = RunEditViewModel(modelContext: context)
        vm.totalDistanceText = "3.10"
        vm.splits = [
            makeDraft(distance: "1.00", minutes: "8", seconds: "00"),
            makeDraft(distance: "1.00", minutes: "8", seconds: "00")
        ]
        XCTAssertLessThan(vm.discrepancyMiles, 0)
        XCTAssertEqual(abs(vm.discrepancyMiles), 1.10, accuracy: 0.01)
    }

    func test_discrepancyMiles_whenSplitsSumExceedsTotal_returnsPositive() {
        let vm = RunEditViewModel(modelContext: context)
        vm.totalDistanceText = "2.00"
        vm.splits = [
            makeDraft(distance: "1.00", minutes: "8", seconds: "00"),
            makeDraft(distance: "1.00", minutes: "8", seconds: "00"),
            makeDraft(distance: "0.50", minutes: "4", seconds: "00")
        ]
        XCTAssertGreaterThan(vm.discrepancyMiles, 0)
        XCTAssertEqual(vm.discrepancyMiles, 0.50, accuracy: 0.01)
    }

    // MARK: - Save (create mode)

    func test_save_createMode_insertsRunIntoContext() throws {
        let vm = RunEditViewModel(modelContext: context)
        vm.totalDistanceText = "1.00"
        vm.runType = .race
        vm.venue = .outdoor
        vm.splits = [makeDraft(distance: "1.00", minutes: "8", seconds: "30")]
        try vm.save()
        let descriptor = FetchDescriptor<Run>()
        let runs = try context.fetch(descriptor)
        XCTAssertEqual(runs.count, 1)
        XCTAssertEqual(runs[0].totalDistance, 1.00, accuracy: 0.001)
        XCTAssertEqual(runs[0].splits.count, 1)
    }

    // MARK: - Edit mode: pre-population

    func test_editMode_prePopulatesFields() throws {
        let run = Run(date: Date(), runType: .race, venue: .treadmill, totalDistance: 2.00)
        context.insert(run)
        let s1 = Split(position: 1, distance: 1.00, durationSeconds: 510)
        let s2 = Split(position: 2, distance: 1.00, durationSeconds: 525)
        s1.run = run; s2.run = run
        run.splits = [s1, s2]

        let vm = RunEditViewModel(modelContext: context, run: run)
        XCTAssertEqual(vm.totalDistanceText, "2.00")
        XCTAssertEqual(vm.runType, .race)
        XCTAssertEqual(vm.venue, .treadmill)
        XCTAssertEqual(vm.splits.count, 2)
    }

    // MARK: - Save (edit mode)

    func test_save_editMode_updatesExistingRunNotInsertingNew() throws {
        let run = Run(date: Date(), runType: .workout, venue: .outdoor, totalDistance: 1.00)
        context.insert(run)
        let s1 = Split(position: 1, distance: 1.00, durationSeconds: 600)
        s1.run = run
        run.splits = [s1]

        let vm = RunEditViewModel(modelContext: context, run: run)
        vm.splits[0].minutesText = "9"
        vm.splits[0].secondsText = "00"
        try vm.save()

        let descriptor = FetchDescriptor<Run>()
        let runs = try context.fetch(descriptor)
        XCTAssertEqual(runs.count, 1) // no new run inserted
        XCTAssertEqual(runs[0].splits.first?.durationSeconds, 540)
    }

    // MARK: - Helpers

    private func makeDraft(distance: String, minutes: String, seconds: String) -> SplitDraft {
        var draft = SplitDraft()
        draft.distanceText = distance
        draft.minutesText = minutes
        draft.secondsText = seconds
        return draft
    }
}

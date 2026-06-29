import XCTest
import SwiftData
@testable import RunStats3

final class RunModelTests: XCTestCase {
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

    // MARK: - Run.isDistanceValid

    func test_isDistanceValid_whenSplitsSumMatchesTotal_returnsTrue() throws {
        let run = Run(date: Date(), runType: .race, venue: .outdoor, totalDistance: 3.10)
        context.insert(run)
        let s1 = Split(position: 1, distance: 1.00, durationSeconds: 510)
        let s2 = Split(position: 2, distance: 1.00, durationSeconds: 525)
        let s3 = Split(position: 3, distance: 1.10, durationSeconds: 580)
        s1.run = run; s2.run = run; s3.run = run
        run.splits = [s1, s2, s3]
        XCTAssertTrue(run.isDistanceValid)
    }

    func test_isDistanceValid_whenSplitsSumDoesNotMatchTotal_returnsFalse() throws {
        let run = Run(date: Date(), runType: .workout, venue: .treadmill, totalDistance: 3.10)
        context.insert(run)
        let s1 = Split(position: 1, distance: 1.00, durationSeconds: 510)
        let s2 = Split(position: 2, distance: 1.00, durationSeconds: 525)
        s1.run = run; s2.run = run
        run.splits = [s1, s2]
        XCTAssertFalse(run.isDistanceValid)
    }

    func test_isDistanceValid_withFractionalSplitsSummingExactly_returnsTrue() throws {
        let run = Run(date: Date(), runType: .race, venue: .outdoor, totalDistance: 3.10)
        context.insert(run)
        let s1 = Split(position: 1, distance: 1.00, durationSeconds: 500)
        let s2 = Split(position: 2, distance: 1.00, durationSeconds: 500)
        let s3 = Split(position: 3, distance: 0.10, durationSeconds: 50)
        s1.run = run; s2.run = run; s3.run = run
        run.splits = [s1, s2, s3]
        XCTAssertTrue(run.isDistanceValid)
    }

    // MARK: - Run.isSaveable

    func test_isSaveable_withNoSplits_returnsFalse() throws {
        let run = Run(date: Date(), runType: .workout, venue: .outdoor, totalDistance: 3.0)
        context.insert(run)
        XCTAssertFalse(run.isSaveable)
    }

    func test_isSaveable_withValidSplits_returnsTrue() throws {
        let run = Run(date: Date(), runType: .workout, venue: .outdoor, totalDistance: 1.0)
        context.insert(run)
        let s1 = Split(position: 1, distance: 1.0, durationSeconds: 600)
        s1.run = run
        run.splits = [s1]
        XCTAssertTrue(run.isSaveable)
    }

    // MARK: - Split.pace

    func test_pace_calculatesCorrectly() {
        let split = Split(position: 1, distance: 1.0, durationSeconds: 600)
        XCTAssertEqual(split.pace, 10.0, accuracy: 0.001)
    }

    func test_pace_withFractionalDistance_calculatesCorrectly() {
        let split = Split(position: 1, distance: 0.10, durationSeconds: 60)
        XCTAssertEqual(split.pace, 10.0, accuracy: 0.001)
    }

    func test_pace_withZeroDistance_returnsZero() {
        let split = Split(position: 1, distance: 0.0, durationSeconds: 300)
        XCTAssertEqual(split.pace, 0.0)
    }

    // MARK: - Split.formattedPace

    func test_formattedPace_tenMinuteMile_formatsCorrectly() {
        let split = Split(position: 1, distance: 1.0, durationSeconds: 600)
        XCTAssertEqual(split.formattedPace, "10:00 /mi")
    }

    func test_formattedPace_eightThirtyMile_formatsCorrectly() {
        let split = Split(position: 1, distance: 1.0, durationSeconds: 510)
        XCTAssertEqual(split.formattedPace, "8:30 /mi")
    }

    // MARK: - Run.splitsSorted

    func test_splitsSorted_returnsSplitsInPositionOrder() throws {
        let run = Run(date: Date(), runType: .race, venue: .outdoor, totalDistance: 2.0)
        context.insert(run)
        let s2 = Split(position: 2, distance: 1.0, durationSeconds: 530)
        let s1 = Split(position: 1, distance: 1.0, durationSeconds: 510)
        s1.run = run; s2.run = run
        run.splits = [s2, s1]
        let sorted = run.splitsSorted
        XCTAssertEqual(sorted[0].position, 1)
        XCTAssertEqual(sorted[1].position, 2)
    }
}

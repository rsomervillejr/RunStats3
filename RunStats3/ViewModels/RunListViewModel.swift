import Foundation
import SwiftData
import Observation

@Observable
final class RunListViewModel {
    private let modelContext: ModelContext
    private(set) var runs: [Run] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchRuns()
    }

    var isEmpty: Bool { runs.isEmpty }

    func fetchRuns() {
        let descriptor = FetchDescriptor<Run>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        runs = (try? modelContext.fetch(descriptor)) ?? []
    }
}

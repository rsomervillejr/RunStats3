import SwiftUI
import SwiftData

struct RunListView: View {
    let isEditMode: Bool
    let modelContext: ModelContext
    @State private var viewModel: RunListViewModel

    init(isEditMode: Bool, modelContext: ModelContext) {
        self.isEditMode = isEditMode
        self.modelContext = modelContext
        _viewModel = State(initialValue: RunListViewModel(modelContext: modelContext))
    }

    var body: some View {
        Group {
            if viewModel.isEmpty {
                ContentUnavailableView(
                    "No Runs Yet",
                    systemImage: "figure.run",
                    description: Text("Switch to Edit mode and tap + to log your first run.")
                )
                .accessibilityLabel("No runs logged yet. Switch to Edit mode to add one.")
            } else {
                List(viewModel.runs) { run in
                    runRow(run: run)
                }
                .listStyle(.plain)
            }
        }
        .onAppear { viewModel.fetchRuns() }
    }

    @ViewBuilder
    private func runRow(run: Run) -> some View {
        let rowLabel = "\(run.date.formatted(date: .abbreviated, time: .omitted)), \(run.runType.rawValue), \(run.venue.rawValue), \(String(format: "%.2f", run.totalDistance)) miles"
        if isEditMode {
            NavigationLink {
                RunEditView(viewModel: RunEditViewModel(modelContext: modelContext, run: run))
            } label: {
                RunRowContent(run: run)
            }
            .accessibilityLabel(rowLabel)
        } else {
            NavigationLink {
                RunDetailView(run: run)
            } label: {
                RunRowContent(run: run)
            }
            .accessibilityLabel(rowLabel)
        }
    }
}

private struct RunRowContent: View {
    let run: Run

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(run.date.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)
            HStack {
                Text(run.runType.rawValue)
                    .foregroundStyle(.secondary)
                Text("·")
                    .foregroundStyle(.secondary)
                Text(run.venue.rawValue)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.2f mi", run.totalDistance))
                    .foregroundStyle(.primary)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Run.self, Split.self, configurations: config)
    let run = Run(date: Date(), runType: .race, venue: .outdoor, totalDistance: 3.10)
    container.mainContext.insert(run)
    return NavigationStack {
        RunListView(isEditMode: false, modelContext: container.mainContext)
            .navigationTitle("RunStats")
    }
    .modelContainer(container)
}

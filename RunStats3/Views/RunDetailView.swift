import SwiftUI
import SwiftData

struct RunDetailView: View {
    let run: Run
    @State private var viewModel: RunDetailViewModel

    init(run: Run) {
        self.run = run
        _viewModel = State(initialValue: RunDetailViewModel(run: run))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                runHeaderSection
                Divider()
                splitsSection
                Divider()
                chartSection
            }
            .padding()
        }
        .navigationTitle("Run Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var runHeaderSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(run.date.formatted(date: .long, time: .omitted))
                .font(.title2)
                .fontWeight(.semibold)
            HStack(spacing: 16) {
                Label(run.runType.rawValue, systemImage: run.runType == .race ? "flag.checkered" : "figure.run")
                Label(run.venue.rawValue, systemImage: run.venue == .treadmill ? "treadmill" : "leaf")
                Label(String(format: "%.2f mi", run.totalDistance), systemImage: "map")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(run.date.formatted(date: .long, time: .omitted)), \(run.runType.rawValue), \(run.venue.rawValue), \(String(format: "%.2f", run.totalDistance)) miles")
    }

    private var splitsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Splits")
                .font(.headline)
            ForEach(viewModel.sortedSplits, id: \.id) { split in
                SplitRowView(split: split)
            }
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pace by Split")
                .font(.headline)
            if viewModel.chartData.isEmpty {
                Text("No splits to chart.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                PaceBarChart(chartData: viewModel.chartData)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Run.self, Split.self, configurations: config)
    let run = Run(date: Date(), runType: .race, venue: .outdoor, totalDistance: 3.10)
    container.mainContext.insert(run)
    let s1 = Split(position: 1, distance: 1.00, durationSeconds: 510)
    let s2 = Split(position: 2, distance: 1.00, durationSeconds: 525)
    let s3 = Split(position: 3, distance: 1.10, durationSeconds: 570)
    s1.run = run; s2.run = run; s3.run = run
    run.splits = [s1, s2, s3]
    return NavigationStack {
        RunDetailView(run: run)
    }
    .modelContainer(container)
}

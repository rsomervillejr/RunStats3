import SwiftUI

struct RunEditView: View {
    @State var viewModel: RunEditViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            runInfoSection
            splitsSection
            validationSection
        }
        .navigationTitle(viewModel.isEditMode ? "Edit Run" : "New Run")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
                    .accessibilityLabel("Cancel without saving")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    try? viewModel.save()
                    dismiss()
                }
                .disabled(!viewModel.isValid)
                .accessibilityLabel("Save run")
                .accessibilityHint(viewModel.isValid ? "" : "Fix split distances before saving")
            }
        }
    }

    private var runInfoSection: some View {
        Section("Run Info") {
            DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                .accessibilityLabel("Run date")
            Picker("Type", selection: $viewModel.runType) {
                ForEach(RunType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .accessibilityLabel("Run type")
            Picker("Venue", selection: $viewModel.venue) {
                ForEach(Venue.allCases, id: \.self) { venue in
                    Text(venue.rawValue).tag(venue)
                }
            }
            .accessibilityLabel("Venue")
            HStack {
                Text("Total Distance (mi)")
                Spacer()
                TextField("0.00", text: $viewModel.totalDistanceText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .accessibilityLabel("Total run distance in miles")
            }
        }
    }

    private var splitsSection: some View {
        Section {
            ForEach($viewModel.splits) { $draft in
                SplitDraftRow(draft: $draft)
            }
            .onDelete { viewModel.removeSplit(at: $0) }
            Button(action: viewModel.addSplit) {
                Label("Add Split", systemImage: "plus.circle")
            }
            .accessibilityLabel("Add a new split")
        } header: {
            Text("Splits")
        } footer: {
            Text("Each split's distances must sum to total run distance.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var validationSection: some View {
        if !viewModel.splits.isEmpty && !viewModel.isValid {
            Section {
                let diff = viewModel.discrepancyMiles
                if diff < 0 {
                    Label(
                        String(format: "%.2f mi still unaccounted for", abs(diff)),
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(.orange)
                    .accessibilityLabel(String(format: "%.2f miles still unaccounted for in splits", abs(diff)))
                } else if diff > 0 {
                    Label(
                        String(format: "%.2f mi over total distance", diff),
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(.orange)
                    .accessibilityLabel(String(format: "Splits exceed total by %.2f miles", diff))
                } else if viewModel.splits.isEmpty {
                    Label("Add at least one split.", systemImage: "info.circle")
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("At least one split is required")
                }
            }
        }
    }
}

private struct SplitDraftRow: View {
    @Binding var draft: SplitDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Distance (mi)")
                    .font(.subheadline)
                Spacer()
                TextField("1.00", text: $draft.distanceText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
                    .accessibilityLabel("Split distance in miles")
            }
            HStack {
                Text("Time")
                    .font(.subheadline)
                Spacer()
                TextField("0", text: $draft.minutesText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 40)
                    .accessibilityLabel("Minutes")
                Text("m")
                    .foregroundStyle(.secondary)
                TextField("00", text: $draft.secondsText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 40)
                    .accessibilityLabel("Seconds")
                Text("s")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Run.self, Split.self, configurations: config)
    return NavigationStack {
        RunEditView(viewModel: RunEditViewModel(modelContext: container.mainContext))
    }
    .modelContainer(container)
}

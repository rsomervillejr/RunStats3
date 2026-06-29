import SwiftUI
import SwiftData

struct AppCoordinatorView: View {
    @State private var isEditMode = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            RunListView(isEditMode: isEditMode, modelContext: modelContext)
                .navigationTitle("RunStats")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(isEditMode ? "Done" : "Edit") {
                            isEditMode.toggle()
                        }
                        .accessibilityLabel(isEditMode ? "Exit edit mode" : "Enter edit mode")
                    }
                    if isEditMode {
                        ToolbarItem(placement: .topBarLeading) {
                            NavigationLink {
                                RunEditView(viewModel: RunEditViewModel(modelContext: modelContext))
                            } label: {
                                Label("New Run", systemImage: "plus")
                            }
                            .accessibilityLabel("Add new run")
                        }
                    }
                }
        }
    }
}

#Preview {
    AppCoordinatorView()
        .modelContainer(for: [Run.self, Split.self], inMemory: true)
}

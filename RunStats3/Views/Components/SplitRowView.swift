import SwiftUI

struct SplitRowView: View {
    let split: Split

    var body: some View {
        HStack {
            Text("Mile \(split.position)")
                .font(.body)
                .frame(minWidth: 60, alignment: .leading)
            Text(String(format: "%.2f mi", split.distance))
                .foregroundStyle(.secondary)
                .font(.subheadline)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(split.formattedDuration)
                    .font(.body.monospacedDigit())
                Text(split.formattedPace)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Mile \(split.position), \(String(format: "%.2f", split.distance)) miles, \(split.formattedDuration), pace \(split.formattedPace)")
    }
}

#Preview {
    let split = Split(position: 1, distance: 1.00, durationSeconds: 510)
    return SplitRowView(split: split)
        .padding()
}

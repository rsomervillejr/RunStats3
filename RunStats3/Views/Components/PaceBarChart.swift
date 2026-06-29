import SwiftUI
import Charts

struct PaceBarChart: View {
    let chartData: [(position: Int, pace: Double)]

    private var paceRange: ClosedRange<Double> {
        let paces = chartData.map(\.pace)
        let minPace = (paces.min() ?? 0) * 0.95
        let maxPace = (paces.max() ?? 12) * 1.05
        return minPace...maxPace
    }

    var body: some View {
        Chart(chartData, id: \.position) { item in
            BarMark(
                x: .value("Mile", item.position),
                y: .value("Pace (min/mi)", item.pace)
            )
            .foregroundStyle(Color.accentColor)
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: chartData.map(\.position)) { value in
                AxisValueLabel {
                    if let pos = value.as(Int.self) {
                        Text("\(pos)")
                            .font(.caption)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let pace = value.as(Double.self) {
                        Text(formattedAxisPace(pace))
                            .font(.caption)
                    }
                }
            }
        }
        .chartYScale(domain: paceRange)
        .frame(height: 200)
        .accessibilityLabel(accessibilitySummary)
    }

    private func formattedAxisPace(_ pace: Double) -> String {
        let totalSeconds = Int(pace * 60)
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private var accessibilitySummary: String {
        guard !chartData.isEmpty else { return "Pace chart, no data" }
        let paces = chartData.map(\.pace)
        let minPace = paces.min() ?? 0
        let maxPace = paces.max() ?? 0
        let minFormatted = formattedAxisPace(minPace)
        let maxFormatted = formattedAxisPace(maxPace)
        return "Pace bar chart, \(chartData.count) splits, fastest \(minFormatted) per mile, slowest \(maxFormatted) per mile"
    }
}

#Preview {
    PaceBarChart(chartData: [
        (position: 1, pace: 8.5),
        (position: 2, pace: 8.75),
        (position: 3, pace: 8.67),
        (position: 4, pace: 8.0)
    ])
    .padding()
}

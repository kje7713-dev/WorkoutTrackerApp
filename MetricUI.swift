import SwiftUI
import Charts

// MARK: - Metric model

struct MetricPoint: Identifiable {
    enum Series: String {
        case expected = "Expected"
        case actual = "Actual"
    }

    let id = UUID()
    let week: Int
    let value: Double
    let series: Series

    static func makeSeries(
        weeks: [Int],
        expected: [Double],
        actual: [Double]
    ) -> [MetricPoint] {
        var result: [MetricPoint] = []

        for (index, week) in weeks.enumerated() {
            if index < expected.count {
                result.append(
                    MetricPoint(
                        week: week,
                        value: expected[index],
                        series: .expected
                    )
                )
            }
            if index < actual.count {
                result.append(
                    MetricPoint(
                        week: week,
                        value: actual[index],
                        series: .actual
                    )
                )
            }
        }

        return result
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let title: String
    let subtitle: String
    let points: [MetricPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Chart {
                ForEach(points) { point in
                    LineMark(
                        x: .value("Week", point.week),
                        y: .value("Percent", point.value)
                    )
                    .symbol(Circle())
                    .interpolationMethod(.monotone)
                    .foregroundStyle(by: .value("Series", point.series.rawValue))
                }
            }
            .chartYAxisLabel("% complete")
            .chartXAxis {
                AxisMarks(values: .stride(by: 1))
            }
            .frame(height: 180)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

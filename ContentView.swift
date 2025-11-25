import SwiftUI
import Charts   // iOS 16+ (you’re targeting iOS 17, so this is fine)

// MARK: - Models

struct WorkoutBlock {
    let name: String
    let currentDayName: String
    let weeks: [Int]          // e.g. 1,2,3,4
    let expectedExercises: [Double] // % per week
    let actualExercises: [Double]
    let expectedVolume: [Double]
    let actualVolume: [Double]
    
    // Convert to chart-ready points
    var exerciseCompletionPoints: [MetricPoint] {
        MetricPoint.makeSeries(
            weeks: weeks,
            expected: expectedExercises,
            actual: actualExercises
        )
    }
    
    var volumeCompletionPoints: [MetricPoint] {
        MetricPoint.makeSeries(
            weeks: weeks,
            expected: expectedVolume,
            actual: actualVolume
        )
    }
    
    // Sample data just so the dashboard shows something
    static let sampleBlock = WorkoutBlock(
        name: "SBD Block 1 – 4 Week Strength",
        currentDayName: "Week 2 • Day 3 – Heavy Lower",
        weeks: [1, 2, 3, 4],
        expectedExercises: [25, 50, 75, 100],
        actualExercises:   [20, 48, 60, 0],  // 0 for future weeks
        expectedVolume:    [25, 50, 75, 100],
        actualVolume:      [22, 47, 55, 0]
    )
}

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
                    MetricPoint(week: week,
                                value: expected[index],
                                series: .expected)
                )
            }
            if index < actual.count {
                result.append(
                    MetricPoint(week: week,
                                value: actual[index],
                                series: .actual)
                )
            }
        }
        
        return result
    }
}

// MARK: - Views

struct DashboardView: View {
    @State private var block = WorkoutBlock.sampleBlock
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 🔥 Quote header card
                    QuoteHeader()
                    
                    // Block + Day header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(block.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(block.currentDayName)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    // Exercise completion chart
                    MetricCard(
                        title: "% Exercises Completed in Block",
                        subtitle: "Expected vs Actual",
                        points: block.exerciseCompletionPoints
                    )
                    
                    // Volume (weight moved) completion chart
                    MetricCard(
                        title: "% Volume Completed in Block",
                        subtitle: "Expected vs Actual",
                        points: block.volumeCompletionPoints
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            // small, neutral nav bar; quote lives in the content
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct QuoteHeader: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("We are what we repeatedly do")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Every session is a rep for who you’re becoming.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

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

// MARK: - Entry point

struct ContentView: View {
    var body: some View {
        DashboardView()
    }
}

#Preview {
    ContentView()
}
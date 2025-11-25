import SwiftUI
import Charts   // iOS 16+ (you’re targeting iOS 17, so this is fine)

// MARK: - Models

struct WorkoutExercise: Identifiable {
    let id = UUID()
    let name: String
    let sets: Int
    let reps: Int
    let weight: Int      // in lb for now
}

struct WorkoutDay: Identifiable {
    let id = UUID()
    let index: Int        // 1–7
    let name: String      // e.g. "Heavy Lower"
    let description: String
    let exercises: [WorkoutExercise]
}

struct WorkoutBlock {
    let name: String
    let currentDayName: String
    let currentWeek: Int
    let days: [WorkoutDay]          // 1–7 days in the block
    let weeks: [Int]                // e.g. 1,2,3,4
    let expectedExercises: [Double]
    let actualExercises: [Double]
    let expectedVolume: [Double]
    let actualVolume: [Double]
    
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
    
    static let sampleBlock = WorkoutBlock(
        name: "SBD Block 1 – 4 Week Strength",
        currentDayName: "Week 2 • Day 3 – Heavy Lower",
        currentWeek: 2,
        days: [
            WorkoutDay(
                index: 1,
                name: "Heavy Upper",
                description: "Bench press + upper-body accessories. Focus on heavy triples and controlled eccentrics.",
                exercises: [
                    WorkoutExercise(name: "Bench Press", sets: 5, reps: 3, weight: 245),
                    WorkoutExercise(name: "Incline DB Press", sets: 4, reps: 8, weight: 75),
                    WorkoutExercise(name: "Barbell Row", sets: 4, reps: 8, weight: 185)
                ]
            ),
            WorkoutDay(
                index: 2,
                name: "Volume Lower",
                description: "Back squats and Romanian deadlifts in the 5–8 rep range. Build volume and positional strength.",
                exercises: [
                    WorkoutExercise(name: "Back Squat", sets: 4, reps: 6, weight: 285),
                    WorkoutExercise(name: "RDL", sets: 4, reps: 8, weight: 245),
                    WorkoutExercise(name: "Walking Lunge", sets: 3, reps: 10, weight: 95)
                ]
            ),
            WorkoutDay(
                index: 3,
                name: "Heavy Lower",
                description: "Primary squat or deadlift variation heavy for low reps. Finish with targeted posterior chain work.",
                exercises: [
                    WorkoutExercise(name: "Deadlift", sets: 5, reps: 3, weight: 365),
                    WorkoutExercise(name: "Paused Squat", sets: 3, reps: 5, weight: 265),
                    WorkoutExercise(name: "Back Extension", sets: 3, reps: 12, weight: 45)
                ]
            ),
            WorkoutDay(
                index: 4,
                name: "Accessory / Conditioning",
                description: "Single-leg work, core, and conditioning intervals. Keep RPE moderate so you’re fresh for the next heavy day.",
                exercises: [
                    WorkoutExercise(name: "Bulgarian Split Squat", sets: 3, reps: 10, weight: 65),
                    WorkoutExercise(name: "Hanging Leg Raise", sets: 3, reps: 12, weight: 0),
                    WorkoutExercise(name: "Bike Intervals", sets: 6, reps: 30, weight: 0) // 30s hard
                ]
            )
            // Add days 5–7 later if you want them
        ],
        weeks: [1, 2, 3, 4],
        expectedExercises: [25, 50, 75, 100],
        actualExercises:   [20, 48, 60, 0],
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
                    
                    QuoteHeader()
                    
                    // Tap this card to go to the block detail screen
                    NavigationLink {
                        BlockDetailView(block: block)
                    } label: {
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
                    }
                    
                    MetricCard(
                        title: "% Exercises Completed in Block",
                        subtitle: "Expected vs Actual",
                        points: block.exerciseCompletionPoints
                    )
                    
                    MetricCard(
                        title: "% Volume Completed in Block",
                        subtitle: "Expected vs Actual",
                        points: block.volumeCompletionPoints
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Detail screen for a specific block
struct BlockDetailView: View {
    let block: WorkoutBlock
    
    @State private var selectedDayIndex: Int
    @State private var selectedWeek: Int
    @State private var dragOffset: CGFloat = 0
    
    init(block: WorkoutBlock) {
        self.block = block
        _selectedDayIndex = State(initialValue: block.days.first?.index ?? 1)
        _selectedWeek = State(initialValue: block.currentWeek)
    }
    
    private var selectedDay: WorkoutDay? {
        block.days.first { $0.index == selectedDayIndex }
    }
    
    private var sortedWeeks: [Int] {
        block.weeks.sorted()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Week + current day summary
                VStack(alignment: .leading, spacing: 6) {
                    Text("Week \(selectedWeek)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let day = selectedDay {
                        Text("Day \(day.index) – \(day.name)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Select a day")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("Swipe left or right to change weeks.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                
                // Day selector (1–7, based on days defined in the block)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(block.days) { day in
                            Button {
                                selectedDayIndex = day.index
                            } label: {
                                Text("Day \(day.index)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(
                                        Capsule().fill(
                                            selectedDayIndex == day.index
                                            ? Color.accentColor
                                            : Color(.secondarySystemBackground)
                                        )
                                    )
                                    .foregroundColor(
                                        selectedDayIndex == day.index ? .white : .primary
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Day description
                if let day = selectedDay {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workout Description")
                            .font(.headline)
                        
                        Text(day.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    // 🔹 Summary-level exercise list
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's Exercises")
                            .font(.headline)
                        
                        ForEach(day.exercises) { exercise in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text("\(exercise.sets) x \(exercise.reps) @ \(exercise.weight) lb")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 80
                    var newWeek = selectedWeek
                    
                    if value.translation.width < -threshold {
                        // Swipe left → next week
                        if let next = sortedWeeks.first(where: { $0 > selectedWeek }) {
                            newWeek = next
                        }
                    } else if value.translation.width > threshold {
                        // Swipe right → previous week
                        if let prev = sortedWeeks.reversed().first(where: { $0 < selectedWeek }) {
                            newWeek = prev
                        }
                    }
                    
                    withAnimation(.spring()) {
                        selectedWeek = newWeek
                        dragOffset = 0
                    }
                }
        )
        .navigationTitle(block.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct QuoteHeader: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("\"WE ARE WHAT WE REPEATEDLY DO\"")
                .font(.title)            // match SBD header size
                .fontWeight(.bold)       // match SBD header weight
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

// MARK: - Entry point

struct ContentView: View {
    var body: some View {
        DashboardView()
    }
}

#Preview {
    ContentView()
}
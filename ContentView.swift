import SwiftUI
import Charts   // iOS 16+ (you’re targeting iOS 17, so this is fine)
import SwiftData

// MARK: - Models (UI-level)

// These are UI-only structs, not the SwiftData models.

struct WorkoutExercise: Identifiable {
    let id = UUID()
    let name: String
    let sets: Int
    let reps: Int
    let weight: Int      // expected / planned weight in lb
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
        name: "SBD BLOCK 1 – 4 WEEK STRENGTH",
        currentDayName: "Week 2 • Day 3 – Heavy Lower",
        currentWeek: 2,
        days: [
            WorkoutDay(
                index: 1,
                name: "Heavy Upper",
                description: "Bench press + upper-body accessories. Focus on heavy triples and controlled eccentrics.",
                exercises: [
                    WorkoutExercise(name: "Bench Press",        sets: 5, reps: 3,  weight: 245),
                    WorkoutExercise(name: "Incline DB Press",   sets: 4, reps: 8,  weight: 75),
                    WorkoutExercise(name: "Barbell Row",        sets: 4, reps: 8,  weight: 185)
                ]
            ),
            WorkoutDay(
                index: 2,
                name: "Volume Lower",
                description: "Back squats and Romanian deadlifts in the 5–8 rep range. Build volume and positional strength.",
                exercises: [
                    WorkoutExercise(name: "Back Squat",         sets: 4, reps: 6,  weight: 285),
                    WorkoutExercise(name: "RDL",                sets: 4, reps: 8,  weight: 245),
                    WorkoutExercise(name: "Walking Lunge",      sets: 3, reps: 10, weight: 95)
                ]
            ),
            WorkoutDay(
                index: 3,
                name: "Heavy Lower",
                description: "Primary squat or deadlift variation heavy for low reps. Finish with targeted posterior chain work.",
                exercises: [
                    WorkoutExercise(name: "Deadlift",           sets: 5, reps: 3,  weight: 365),
                    WorkoutExercise(name: "Paused Squat",       sets: 3, reps: 5,  weight: 265),
                    WorkoutExercise(name: "Back Extension",     sets: 3, reps: 12, weight: 45)
                ]
            ),
            WorkoutDay(
                index: 4,
                name: "Accessory / Conditioning",
                description: "Single-leg work, core, and conditioning intervals. Keep RPE moderate so you’re fresh for the next heavy day.",
                exercises: [
                    WorkoutExercise(name: "Bulgarian Split Squat", sets: 3, reps: 10, weight: 65),
                    WorkoutExercise(name: "Hanging Leg Raise",     sets: 3, reps: 12, weight: 0),
                    WorkoutExercise(name: "Bike Intervals",        sets: 6, reps: 30, weight: 0) // 30s hard
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

// MARK: - Views (Dashboard + Block)

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

// MARK: - Block Detail (Week/day + summary)

struct BlockDetailView: View {
    let block: WorkoutBlock
    
    @State private var selectedDayIndex: Int
    @State private var selectedWeek: Int
    @State private var dragOffset: CGFloat = 0
    
    @Environment(\.modelContext) private var context
    
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
                
                // Day description + summary-level exercises + Start button
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
                    
                    // Summary-level exercise list
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
                    
                    // Start workout → get/create session in SwiftData, then go to detail view
                    NavigationLink {
                        let session = existingOrNewSession(for: day)
                        WorkoutSessionView(session: session, day: day)
                    } label: {
                        Text("Start This Workout")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.top, 4)
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
    
    // MARK: - SwiftData helpers
    
    private func existingOrNewSession(for day: WorkoutDay) -> WorkoutSession {
        if let existing = fetchSession(for: day) {
            return existing
        } else {
            return createSession(for: day)
        }
    }
    
    private func fetchSession(for day: WorkoutDay) -> WorkoutSession? {
        // Capture simple values so the predicate operates on Ints, not key paths on WorkoutDay
        let week = selectedWeek
        let dayIndex = day.index
        
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { session in
                session.weekIndex == week && session.dayIndex == dayIndex
            }
        )
        
        do {
            let results = try context.fetch(descriptor)
            return results.first
        } catch {
            print("Error fetching session: \(error)")
            return nil
        }
    }
    
    private func createSession(for day: WorkoutDay) -> WorkoutSession {
        // Create a new WorkoutSession for this week/day
        let session = WorkoutSession(
            weekIndex: selectedWeek,
            dayIndex: day.index
        )
        
        // Build exercises + sets from the template
        for (exerciseOrder, ex) in day.exercises.enumerated() {
            let sessionExercise = SessionExercise(
                orderIndex: exerciseOrder,
                session: session,
                exerciseTemplate: nil,
                nameOverride: ex.name
            )
            
            // Create sets for this exercise
            for setIdx in 1...ex.sets {
                let set = SessionSet(
                    setIndex: setIdx,
                    targetReps: ex.reps,
                    targetWeight: Double(ex.weight),
                    targetRPE: nil,
                    actualReps: ex.reps,
                    actualWeight: Double(ex.weight),
                    actualRPE: nil,
                    completed: false,
                    timestamp: nil,
                    notes: nil,
                    sessionExercise: sessionExercise
                )
                sessionExercise.sets.append(set)
            }
            
            session.exercises.append(sessionExercise)
        }
        
        context.insert(session)
        do {
            try context.save()
        } catch {
            print("Error saving new session: \(error)")
        }
        
        return session
    }
}

// MARK: - Workout Session (per-set expected vs actual)
// Uses SwiftData models: WorkoutSession, SessionExercise, SessionSet

struct WorkoutSessionView: View {
    @Bindable var session: WorkoutSession
    let day: WorkoutDay
    
    @Environment(\.modelContext) private var context
    
    private var totalSets: Int {
        session.exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    private var totalCompletedSets: Int {
        session.exercises.reduce(0) { partial, exercise in
            partial + exercise.sets.filter { $0.completed }.count
        }
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Day \(day.index) – \(day.name)")
                        .font(.headline)
                    Text(day.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                
                // Overall progress (by sets)
                if totalSets > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Session Progress")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ProgressView(
                            value: Double(totalCompletedSets),
                            total: Double(totalSets)
                        )
                        
                        Text("\(totalCompletedSets) of \(totalSets) sets completed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
            
            Section(header: Text("Exercises")) {
                ForEach($session.exercises) { $exercise in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.nameOverride ?? exercise.exerciseTemplate?.name ?? "Exercise")
                            .font(.headline)
                        
                        ForEach($exercise.sets) { $set in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Set \(set.setIndex)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Toggle(isOn: $set.completed) {
                                        Text("Completed")
                                            .font(.caption)
                                    }
                                    .toggleStyle(.switch)
                                    .labelsHidden()
                                }
                                
                                Text("Expected: \(set.targetReps) reps @ \(Int(set.targetWeight)) lb")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                // Actual reps & weight for this set
                                HStack {
                                    Stepper(
                                        "Reps: \(set.actualReps)",
                                        value: $set.actualReps,
                                        // allow more reps than target, cap grows as needed
                                        in: 0...(max(set.targetReps, set.actualReps) + 10)
                                    )
                                }
                                .font(.caption)
                                
                                HStack {
                                    Stepper(
                                        "Weight: \(Int(set.actualWeight)) lb",
                                        value: $set.actualWeight,
                                        in: 0.0...1000.0,
                                        step: 5.0
                                    )
                                }
                                .font(.caption)
                                
                                // Visual dots / label for completion
                                HStack(spacing: 6) {
                                    Circle()
                                        .frame(width: 10, height: 10)
                                        .foregroundColor(set.completed ? .green : .gray.opacity(0.3))
                                    
                                    Text(set.completed ? "Set logged" : "Not logged yet")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        
                        // Add Set button for this exercise
                        Button {
                            addSet(to: exercise)
                        } label: {
                            Text("Add Set")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Workout Session")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            do {
                try context.save()
            } catch {
                print("Error saving session on disappear: \(error)")
            }
        }
    }
    
    private func addSet(to exercise: SessionExercise) {
        let nextIndex = (exercise.sets.last?.setIndex ?? 0) + 1
        let template = exercise.sets.last
        
        let newSet = SessionSet(
            setIndex: nextIndex,
            targetReps: template?.targetReps ?? 5,
            targetWeight: template?.targetWeight ?? 135.0,
            targetRPE: template?.targetRPE,
            actualReps: template?.actualReps ?? template?.targetReps ?? 5,
            actualWeight: template?.actualWeight ?? template?.targetWeight ?? 135.0,
            actualRPE: template?.actualRPE,
            completed: false,
            timestamp: nil,
            notes: nil,
            sessionExercise: exercise
        )
        
        exercise.sets.append(newSet)
    }
}

// MARK: - Shared UI Pieces

struct QuoteHeader: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("\"WE ARE WHAT WE REPEATEDLY DO\"")
                .font(.title)
                .fontWeight(.bold)
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
import SwiftUI

// MARK: - Run Mode Container

struct BlockRunModeView: View {
    let block: Block

    @State private var weeks: [RunWeekState]
    @State private var currentWeekIndex: Int = 0
    @State private var currentDayIndex: Int = 0

    @State private var lastCommittedWeekIndex: Int = 0
    @State private var pendingWeekIndex: Int? = nil
    @State private var showSkipAlert: Bool = false

    init(block: Block) {
        self.block = block
        _weeks = State(initialValue: BlockRunModeView.buildWeeks(from: block))
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if weeks.isEmpty || block.days.isEmpty {
                Text("This block has no days configured.")
                    .padding()
                Spacer()
            } else {
                TabView(selection: $currentWeekIndex) {
                    ForEach(weeks.indices, id: \.self) { weekIndex in
                        WeekRunView(
                            week: $weeks[weekIndex],
                            allDays: block.days,
                            currentDayIndex: $currentDayIndex
                        )
                        .tag(weekIndex)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentWeekIndex) { _, newValue in
    handleWeekChange(newWeekIndex: newValue)
}
                .alert("You can skip — but champions don’t.", isPresented: $showSkipAlert) {
                    Button("Stay on Track", role: .cancel) {
                        pendingWeekIndex = nil
                    }
                    Button("Continue") {
                        if let target = pendingWeekIndex {
                            currentWeekIndex = target
                            lastCommittedWeekIndex = target
                            pendingWeekIndex = nil
                        }
                    }
                } message: {
                    Text("Week \(lastCommittedWeekIndex + 1) still has work open. Move forward anyway?")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Top Bar

private var topBar: some View {
    VStack(alignment: .leading, spacing: 6) {
        // Brand line
        Text("SAVAGE BY DESIGN")
            .font(.caption2)
            .fontWeight(.semibold)
            .textCase(.uppercase)
            .foregroundColor(.secondary)
            .kerning(1.0)

        // Block name
        Text(block.name)
            .font(.title2)
            .fontWeight(.bold)

        // Week + day line
        let dayShortCode: String = {
            guard block.days.indices.contains(currentDayIndex) else { return "" }
            return block.days[currentDayIndex].shortCode ?? ""
        }()

        Text("Week \(currentWeekIndex + 1) — \(dayShortCode)")
            .font(.footnote)
            .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 16)
    .padding(.top, 8)
    .padding(.bottom, 4)
}

    // MARK: - Week Change Logic

    private func handleWeekChange(newWeekIndex: Int) {
        // Only warn if user is trying to move forward
        guard newWeekIndex > lastCommittedWeekIndex else {
            lastCommittedWeekIndex = newWeekIndex
            return
        }

        // If any previous week is not completed, show warning
        let earlierIncomplete = weeks[0...lastCommittedWeekIndex].contains { !$0.isCompleted }
        if earlierIncomplete {
            pendingWeekIndex = newWeekIndex
            // snap back to last committed until they confirm
            currentWeekIndex = lastCommittedWeekIndex
            showSkipAlert = true
        } else {
            lastCommittedWeekIndex = newWeekIndex
        }
    }

    // MARK: - Build Initial Run State

    private static func buildWeeks(from block: Block) -> [RunWeekState] {
        guard !block.days.isEmpty else {
            return []
        }

        let weeksCount = max(block.numberOfWeeks, 1)

        return (0..<weeksCount).map { weekIndex in
            let dayStates: [RunDayState] = block.days.map { day in
    let exerciseStates: [RunExerciseState] = day.exercises.map { exercise in
        let sets: [RunSetState]

        switch exercise.type {
        case .strength:
            let strengthSets = exercise.strengthSets ?? []
            sets = strengthSets.enumerated().map { idx, set in
                let repsText = set.reps.map { "Reps: \($0)" } ?? ""
                let weightText = set.weight.map { "Weight: \($0)" } ?? ""

                let combined = [repsText, weightText]
                    .filter { !$0.isEmpty }
                    .joined(separator: " • ")

                let plannedReps = set.reps
                let plannedWeight = set.weight

                return RunSetState(
                    indexInExercise: idx,
                    displayText: combined.isEmpty ? "Strength set" : combined,
                    type: .strength,
                    plannedReps: plannedReps,
                    plannedWeight: plannedWeight,
                    actualReps: plannedReps,
                    actualWeight: plannedWeight
                )
            }

        case .conditioning:
            let condSets = exercise.conditioningSets ?? []
            sets = condSets.enumerated().map { idx, set in
                var parts: [String] = []

                if let dur = set.durationSeconds {
                    if dur % 60 == 0 {
                        let mins = dur / 60
                        parts.append("\(mins) min")
                    } else {
                        parts.append("\(dur) sec")
                    }
                }
                if let dist = set.distanceMeters {
                    parts.append("\(Int(dist)) m")
                }
                if let cal = set.calories {
                    parts.append("\(Int(cal)) cal")
                }
                if let rounds = set.rounds {
                    parts.append("\(rounds) rounds")
                }

                let combined = parts.isEmpty ? "Conditioning" : parts.joined(separator: " • ")

                let plannedTime = set.durationSeconds.map(Double.init)
                let plannedDistance = set.distanceMeters
                let plannedCalories = set.calories
                let plannedRounds = set.rounds

                return RunSetState(
                    indexInExercise: idx,
                    displayText: combined,
                    type: .conditioning,
                    plannedTimeSeconds: plannedTime,
                    plannedDistanceMeters: plannedDistance,
                    plannedCalories: plannedCalories,
                    plannedRounds: plannedRounds,
                    actualTimeSeconds: plannedTime,
                    actualDistanceMeters: plannedDistance,
                    actualCalories: plannedCalories,
                    actualRounds: plannedRounds
                )
            }

        default:
            sets = [
                RunSetState(
                    indexInExercise: 0,
                    displayText: "Set",
                    type: exercise.type
                )
            ]
        }

        let name = exercise.customName ?? "Exercise"
        let notes = exercise.notes ?? ""

        return RunExerciseState(
            name: name,
            type: exercise.type,
            notes: notes,
            sets: sets
        )
    }

    return RunDayState(
        name: day.name,
        shortCode: day.shortCode ?? "",
        exercises: exerciseStates
    )
}
}

// MARK: - Week View

// MARK: - Week View

struct WeekRunView: View {
    @Binding var week: RunWeekState
    let allDays: [DayTemplate]
    @Binding var currentDayIndex: Int

    var body: some View {
        VStack(spacing: 0) {
            DayTabBar(days: allDays, currentDayIndex: $currentDayIndex)
            Divider()
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        if week.days.indices.contains(currentDayIndex) {
            DayRunView(day: $week.days[currentDayIndex])
        } else {
            Text("No days configured for this week.")
                .padding()
        }
    }
}

// MARK: - Day Tabs

struct DayTabBar: View {
    let days: [DayTemplate]
    @Binding var currentDayIndex: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    dayButton(for: day, index: index)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private func dayButton(for day: DayTemplate, index: Int) -> some View {
        let isSelected = index == currentDayIndex
        let label: String

        if let short = day.shortCode, !short.isEmpty {
            label = short
        } else {
            label = day.name
        }

        return Button(action: {
            currentDayIndex = index
        }) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.black : Color.clear
                )
                .foregroundColor(isSelected ? Color.white : Color.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: isSelected ? 0 : 1)
                )
                .cornerRadius(16)
        }
    }
}

struct DayRunView: View {
    @Binding var day: RunDayState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach($day.exercises) { $exercise in
                    ExerciseRunCard(exercise: $exercise)
                }

                Button {
                    let newExerciseIndex = day.exercises.count + 1
                    let newExercise = RunExerciseState(
                    name: "New Exercise \(newExerciseIndex)",
                    type: .strength,
                    notes: "",   // 🔹 start with empty notes
                    sets: [
                        RunSetState(
                            indexInExercise: 0,
                            displayText: "Set 1",
                             type: .strength
        )
    ]
)
                    day.exercises.append(newExercise)
                } label: {
                    Label("Add Exercise", systemImage: "plus")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.primary, lineWidth: 1)
                        )
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
            .padding(.vertical)
        }
    }
}

struct ExerciseRunCard: View {
    @Binding var exercise: RunExerciseState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Editable exercise name
            TextField("Exercise name", text: $exercise.name)
                .font(.headline)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)

            // Existing notes from the template (if any)
            if !exercise.notes.isEmpty {
                Text(exercise.notes)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            // Editable notes during the session
            TextField("Add notes (RPE, cues, etc.)",
                      text: $exercise.notes,
                      axis: .vertical)
                .lineLimit(1...3)
                .font(.footnote)
                .textFieldStyle(.roundedBorder)

            // Sets
            ForEach($exercise.sets) { $set in
                SetRunRow(set: $set)
            }

            // Add/remove set controls
            HStack {
                Button {
                    let newIndex = exercise.sets.count
                    let newSet = RunSetState(
                        indexInExercise: newIndex,
                        displayText: "Set \(newIndex + 1)",
                        type: exercise.type
                    )
                    exercise.sets.append(newSet)
                } label: {
                    Label("Add Set", systemImage: "plus")
                        .font(.caption.bold())
                }

                Spacer()

                if exercise.sets.count > 1 {
                    Button {
                        _ = exercise.sets.popLast()
                    } label: {
                        Label("Remove Set", systemImage: "minus")
                            .font(.caption)
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding()
    }
}

struct SetRunRow: View {
    @Binding var runSet: RunSetState    // ⬅️ renamed from `set`

    // Strength helpers
    private var repsValue: Int {
        runSet.actualReps ?? runSet.plannedReps ?? 0
    }

    private var weightValue: Double {
        runSet.actualWeight ?? runSet.plannedWeight ?? 0
    }

    // Conditioning helpers (we show minutes for time)
    private var timeMinutesValue: Int {
        let seconds = runSet.actualTimeSeconds ?? runSet.plannedTimeSeconds ?? 0
        return Int(seconds / 60)
    }

    private var caloriesValue: Int {
        Int(runSet.actualCalories ?? runSet.plannedCalories ?? 0)
    }

    private var roundsValue: Int {
        runSet.actualRounds ?? runSet.plannedRounds ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Text("Set \(runSet.indexInExercise + 1)")
                .font(.subheadline).bold()

            // Planned summary
            if !runSet.displayText.isEmpty {
                Text("Planned: \(runSet.displayText)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            // Controls depend on type
            if runSet.type == .strength {
                strengthControls
            } else if runSet.type == .conditioning {
                conditioningControls
            }

            // Complete / Undo
            HStack {
                Spacer()
                if runSet.isCompleted {
                    Button("Undo") {
                        runSet.isCompleted = false
                    }
                    .font(.caption)
                } else {
                    Button("Complete") {
                        runSet.isCompleted = true
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary, lineWidth: 1)
                    )
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        // Completed ribbon overlay
        .overlay(
            Group {
                if runSet.isCompleted {
                    Text("COMPLETED")
                        .font(.caption2).bold()
                        .padding(6)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(22))
                        .offset(x: 8, y: -8)
                }
            },
            alignment: .topTrailing
        )
        .padding(.vertical, 2)
    }

    // MARK: - Strength UI

    private var strengthControls: some View {
        HStack(spacing: 12) {
            // Reps clicker
            HStack(spacing: 4) {
                Button {
                    let new = max(0, repsValue - 1)
                    runSet.actualReps = new
                } label: {
                    Image(systemName: "minus.circle")
                }

                Text("\(repsValue)")
                    .font(.body.monospacedDigit())
                    .frame(width: 32)

                Button {
                    let new = repsValue + 1
                    runSet.actualReps = new
                } label: {
                    Image(systemName: "plus.circle")
                }
            }

            Text("reps")
                .font(.caption2)
                .foregroundColor(.secondary)

            // Weight clicker
            HStack(spacing: 4) {
                Button {
                    let step = 5.0
                    let new = max(0, weightValue - step)
                    runSet.actualWeight = new
                } label: {
                    Image(systemName: "minus.circle")
                }

                Text(weightValue == 0 ? "-" : String(format: "%.0f", weightValue))
                    .font(.body.monospacedDigit())
                    .frame(width: 44)

                Button {
                    let step = 5.0
                    let new = weightValue + step
                    runSet.actualWeight = new
                } label: {
                    Image(systemName: "plus.circle")
                }
            }

            Text("lb")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Conditioning UI

    private var conditioningControls: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Time (minutes)
            HStack(spacing: 6) {
                Text("Time")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Button {
                    let mins = max(0, timeMinutesValue - 1)
                    runSet.actualTimeSeconds = Double(mins * 60)
                } label: {
                    Image(systemName: "minus.circle")
                }

                Text("\(timeMinutesValue)")
                    .font(.body.monospacedDigit())
                    .frame(width: 32)

                Button {
                    let mins = timeMinutesValue + 1
                    runSet.actualTimeSeconds = Double(mins * 60)
                } label: {
                    Image(systemName: "plus.circle")
                }

                Text("min")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            // Calories
            HStack(spacing: 6) {
                Text("Cal")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Button {
                    let new = max(0, caloriesValue - 5)
                    runSet.actualCalories = Double(new)
                } label: {
                    Image(systemName: "minus.circle")
                }

                Text("\(caloriesValue)")
                    .font(.body.monospacedDigit())
                    .frame(width: 40)

                Button {
                    let new = caloriesValue + 5
                    runSet.actualCalories = Double(new)
                } label: {
                    Image(systemName: "plus.circle")
                }
            }

            // Rounds
            HStack(spacing: 6) {
                Text("Rounds")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Button {
                    let new = max(0, roundsValue - 1)
                    runSet.actualRounds = new
                } label: {
                    Image(systemName: "minus.circle")
                }

                Text("\(roundsValue)")
                    .font(.body.monospacedDigit())
                    .frame(width: 32)

                Button {
                    let new = roundsValue + 1
                    runSet.actualRounds = new
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
}

// MARK: - Run State Models

struct RunWeekState: Identifiable {
    let id = UUID()
    let index: Int
    var days: [RunDayState]

    var isCompleted: Bool {
        for day in days {
            for exercise in day.exercises {
                if exercise.sets.contains(where: { !$0.isCompleted }) {
                    return false
                }
            }
        }
        return true
    }
}

struct RunDayState: Identifiable {
    let id = UUID()
    let name: String
    let shortCode: String
    var exercises: [RunExerciseState]
}

struct RunExerciseState: Identifiable {
    let id = UUID()
    var name: String              // editable in run mode
    let type: ExerciseType
    var notes: String             // 🔹 shared notes for strength + conditioning
    var sets: [RunSetState]
}

struct RunSetState: Identifiable {
    let id = UUID()
    let indexInExercise: Int
    let displayText: String
    let type: ExerciseType

    // Strength planned/actual
    var plannedReps: Int?
    var plannedWeight: Double?
    var actualReps: Int?
    var actualWeight: Double?

    // Conditioning planned/actual (seconds / meters)
    var plannedTimeSeconds: Double?
    var plannedDistanceMeters: Double?
    var plannedCalories: Double?
    var plannedRounds: Int?

    var actualTimeSeconds: Double?
    var actualDistanceMeters: Double?
    var actualCalories: Double?
    var actualRounds: Int?

    var isCompleted: Bool = false

    init(
        indexInExercise: Int,
        displayText: String,
        type: ExerciseType,
        plannedReps: Int? = nil,
        plannedWeight: Double? = nil,
        actualReps: Int? = nil,
        actualWeight: Double? = nil,
        plannedTimeSeconds: Double? = nil,
        plannedDistanceMeters: Double? = nil,
        plannedCalories: Double? = nil,
        plannedRounds: Int? = nil,
        actualTimeSeconds: Double? = nil,
        actualDistanceMeters: Double? = nil,
        actualCalories: Double? = nil,
        actualRounds: Int? = nil,
        isCompleted: Bool = false
    ) {
        self.indexInExercise = indexInExercise
        self.displayText = displayText
        self.type = type
        self.plannedReps = plannedReps
        self.plannedWeight = plannedWeight
        self.actualReps = actualReps
        self.actualWeight = actualWeight
        self.plannedTimeSeconds = plannedTimeSeconds
        self.plannedDistanceMeters = plannedDistanceMeters
        self.plannedCalories = plannedCalories
        self.plannedRounds = plannedRounds
        self.actualTimeSeconds = actualTimeSeconds
        self.actualDistanceMeters = actualDistanceMeters
        self.actualCalories = actualCalories
        self.actualRounds = actualRounds
        self.isCompleted = isCompleted
    }
}
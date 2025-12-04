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
        VStack(alignment: .leading, spacing: 4) {
            Text("SAVAGE BY DESIGN")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Text(block.name)
                .font(.headline)

            let dayShortCode: String = {
                guard block.days.indices.contains(currentDayIndex) else { return "" }
                return block.days[currentDayIndex].shortCode ?? ""
            }()

            Text("Week \(currentWeekIndex + 1) — \(dayShortCode)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
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
                            let repsText = "Reps: \(set.reps)"
                            let weightText: String
                            if let weight = set.weight {
                                weightText = "Weight: \(weight)"
                            } else {
                                weightText = ""
                            }
                            let combined = [repsText, weightText]
                                .filter { !$0.isEmpty }
                                .joined(separator: " • ")

                            return RunSetState(
                                indexInExercise: idx,
                                displayText: combined.isEmpty ? "Strength set" : combined
                            )
                        }

                    case .conditioning:
                        let condSets = exercise.conditioningSets ?? []
                        sets = condSets.enumerated().map { idx, set in
                            var parts: [String] = []
                            if let dur = set.durationSeconds {
                                parts.append("\(dur) sec")
                            }
                            if let cal = set.calories {
                                parts.append("\(Int(cal)) cal")
                            }
                            if let rounds = set.rounds {
                                parts.append("\(rounds) rounds")
                            }
                            let combined = parts.isEmpty ? "Conditioning" : parts.joined(separator: " • ")
                            return RunSetState(
                                indexInExercise: idx,
                                displayText: combined
                            )
                        }

                    default:
                        sets = [
                            RunSetState(indexInExercise: 0, displayText: "Set")
                        ]
                    }

                    let name = exercise.customName ?? "Exercise"
                    return RunExerciseState(
                        name: name,
                        type: exercise.type,
                        sets: sets
                    )
                }

                return RunDayState(
    name: day.name,
    shortCode: day.shortCode ?? "",
    exercises: exerciseStates
)
            }

            return RunWeekState(index: weekIndex, days: dayStates)
        }
    }
}

// MARK: - Week View

struct WeekRunView: View {
    @Binding var week: RunWeekState
    let allDays: [DayTemplate]
    @Binding var currentDayIndex: Int

    var body: some View {
        VStack(spacing: 0) {
            DayTabBar(days: allDays, currentDayIndex: $currentDayIndex)
            Divider()

            if week.days.indices.contains(currentDayIndex) {
                DayRunView(day: $week.days[currentDayIndex])
            } else {
                Text("No days configured for this week.")
                    .padding()
            }
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
                    let isSelected = index == currentDayIndex

                    Button {
                        currentDayIndex = index
                    } label: {
                        Text(day.shortCode)
                            .font(.subheadline)
                            .fontWeight(isSelected ? .bold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Group {
                                    if isSelected {
                                        Color.black
                                    } else {
                                        Color.clear
                                    }
                                }
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
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Day View

struct DayRunView: View {
    @Binding var day: RunDayState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach($day.exercises) { $exercise in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name)
                            .font(.headline)

                        ForEach($exercise.sets) { $set in
                            SetRunRow(set: $set)
                        }
                    }
                    .padding()
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Set Row with COMPLETED Stamp

struct SetRunRow: View {
    @Binding var set: RunSetState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Set \(set.indexInExercise + 1)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(set.displayText)
                    .font(.subheadline)
            }

            Spacer()

            if !set.isCompleted {
                Button("Complete") {
                    set.isCompleted = true
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
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            Group {
                if set.isCompleted {
                    Text("COMPLETED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary.opacity(0.7))
                        .rotationEffect(.degrees(22))
                }
            }
        )
    }
}

    private var rowContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Set \(set.indexInExercise + 1)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(set.displayText)
                    .font(.subheadline)
            }
            Spacer()

            if !set.isCompleted {
                Button("Complete") {
                    set.isCompleted = true
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
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }

    private var completedStamp: some View {
        Text("COMPLETED")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(Color.primary.opacity(0.7))
            .rotationEffect(.degrees(22))
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
    let name: String
    let type: ExerciseType
    var sets: [RunSetState]
}

struct RunSetState: Identifiable {
    let id = UUID()
    let indexInExercise: Int
    let displayText: String
    var isCompleted: Bool = false
}
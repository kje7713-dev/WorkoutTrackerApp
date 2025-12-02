import SwiftUI

// MARK: - Live, per-session state models

struct LiveSet: Identifiable {
    var id: UUID = UUID()
    var setIndex: Int
    var reps: Int
    var weight: Double?
    var timeSeconds: Int?
    var isCompleted: Bool = false
}

struct LiveExercise: Identifiable {
    var id: UUID = UUID()
    var name: String
    var isConditioning: Bool
    var notes: String
    var sets: [LiveSet]
}

// MARK: - Day Detail UI

struct DayDetailView: View {
    let block: BlockTemplate
    let day: DayTemplate
    let week: Int

    @State private var liveExercises: [LiveExercise] = []

    init(block: BlockTemplate, day: DayTemplate, week: Int) {
        self.block = block
        self.day = day
        self.week = week
        _liveExercises = State(initialValue: DayDetailView.buildLiveExercises(block: block, day: day, week: week))
    }

    var body: some View {
        List {
            ForEach(liveExercises.indices, id: \.self) { exIndex in
                let exercise = liveExercises[exIndex]

                Section(exercise.name) {
                    if !exercise.notes.isEmpty {
                        Text(exercise.notes)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(exercise.sets.indices, id: \.self) { setIndex in
                        HStack(spacing: 12) {
                            Button {
                                liveExercises[exIndex].sets[setIndex].isCompleted.toggle()
                            } label: {
                                Image(systemName: liveExercises[exIndex].sets[setIndex].isCompleted ? "checkmark.circle.fill" : "circle")
                                    .imageScale(.large)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Set \(liveExercises[exIndex].sets[setIndex].setIndex)")
                                    .font(.caption)

                                HStack {
                                    TextField(
                                        "Reps",
                                        value: $liveExercises[exIndex].sets[setIndex].reps,
                                        format: .number
                                    )
                                    .keyboardType(.numberPad)
                                    .frame(width: 60)

                                    if exercise.isConditioning {
                                        TextField(
                                            "Time (sec)",
                                            value: $liveExercises[exIndex].sets[setIndex].timeSeconds,
                                            format: .number
                                        )
                                        .keyboardType(.numberPad)
                                        .frame(width: 90)
                                    } else {
                                        TextField(
                                            "Weight",
                                            value: $liveExercises[exIndex].sets[setIndex].weight,
                                            format: .number
                                        )
                                        .keyboardType(.decimalPad)
                                        .frame(width: 90)
                                    }
                                }
                            }

                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationTitle("\(day.name) – Week \(week)")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Progression logic

    static func buildLiveExercises(block: BlockTemplate, day: DayTemplate, week: Int) -> [LiveExercise] {
        let weekOffset = max(0, week - 1)

        return day.exercises.map { ex in
            switch block.progression {
            case .weight:
                // Same sets, +5 lbs each week (if base weight exists)
                let liveSets: [LiveSet] = ex.sets.map { s in
                    LiveSet(
                        setIndex: s.setIndex,
                        reps: s.reps ?? 0,
                        weight: s.weight.map { $0 + Double(5 * weekOffset) },
                        timeSeconds: s.timeSeconds,
                        isCompleted: false
                    )
                }
                return LiveExercise(
                    name: ex.name,
                    isConditioning: ex.isConditioning,
                    notes: ex.notes,
                    sets: liveSets
                )

            case .volume:
                // Add one extra set per week after week 1
                var baseSets: [LiveSet] = ex.sets.map { s in
                    LiveSet(
                        setIndex: s.setIndex,
                        reps: s.reps ?? 0,
                        weight: s.weight,
                        timeSeconds: s.timeSeconds,
                        isCompleted: false
                    )
                }

                if weekOffset > 0, let last = baseSets.last {
                    for i in 0..<weekOffset {
                        baseSets.append(
                            LiveSet(
                                setIndex: last.setIndex + i + 1,
                                reps: last.reps,
                                weight: last.weight,
                                timeSeconds: last.timeSeconds,
                                isCompleted: false
                            )
                        )
                    }
                }

                return LiveExercise(
                    name: ex.name,
                    isConditioning: ex.isConditioning,
                    notes: ex.notes,
                    sets: baseSets
                )
            }
        }
    }
}
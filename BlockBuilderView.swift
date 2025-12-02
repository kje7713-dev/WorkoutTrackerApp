import SwiftUI

// MARK: - Editable builder-only types

struct EditableSet: Identifiable, Hashable {
    var id = UUID()
    var setIndex: Int = 1
    var reps: String = ""
    var weight: String = ""
    var timeSeconds: String = ""
}

struct EditableExercise: Identifiable, Hashable {
    var id = UUID()
    var name: String = ""
    var isConditioning: Bool = false
    var notes: String = ""
    var sets: [EditableSet] = [EditableSet()]
}

struct EditableDay: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var exercises: [EditableExercise] = []
}

// MARK: - Block Builder UI

struct BlockBuilderView: View {
    @EnvironmentObject var store: ProgramStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var weeks: Int = 4
    @State private var daysCount: Int = 3
    @State private var progression: ProgressionType = .weight
    @State private var days: [EditableDay] = []

    var body: some View {
        Form {
            blockInfoSection
            daysSection
            generateSection
        }
        .navigationTitle("Build Block")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if days.isEmpty {
                syncDays(to: daysCount)
            }
        }
    }

    // MARK: - Subsections

    @ViewBuilder
    private var blockInfoSection: some View {
        Section("Block Info") {
            TextField("Block name", text: $name)

            Stepper("Weeks: \(weeks)", value: $weeks, in: 1...52)

            Stepper("Days per week: \(daysCount)", value: $daysCount, in: 1...7)
                .onChange(of: daysCount) { _, newValue in
                    syncDays(to: newValue)
                }

            Picker("Progression", selection: $progression) {
                ForEach(ProgressionType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
        }
    }

    @ViewBuilder
    private var daysSection: some View {
        Section("Days & Exercises") {
            if days.isEmpty {
                Text("Days will be created automatically based on the count above.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                // Use indices + small subviews to keep the compiler happy.
                ForEach(days.indices, id: \.self) { index in
                    DayEditorView(day: $days[index])
                }
            }
        }
    }

    @ViewBuilder
    private var generateSection: some View {
        Section {
            Button {
                generateBlockAndDismiss()
            } label: {
                Text("Generate Block")
                    .frame(maxWidth: .infinity)
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || days.isEmpty)
        }
    }

    // MARK: - Logic

    private func syncDays(to count: Int) {
        var updated: [EditableDay] = days

        if updated.count < count {
            for i in updated.count..<count {
                updated.append(EditableDay(name: "Day \(i + 1)"))
            }
        } else if updated.count > count {
            updated = Array(updated.prefix(count))
        }

        days = updated
    }

    private func generateBlockAndDismiss() {
        let finalDays: [DayTemplate] = days.map { editableDay in
            let exercises: [ExerciseTemplate] = editableDay.exercises.map { ex in
                let sets: [WorkoutSetTemplate] = ex.sets.map { s in
                    WorkoutSetTemplate(
                        id: s.id,
                        setIndex: s.setIndex,
                        reps: Int(s.reps),
                        weight: Double(s.weight),
                        timeSeconds: Int(s.timeSeconds)
                    )
                }

                return ExerciseTemplate(
                    id: ex.id,
                    name: ex.name.isEmpty ? "Untitled" : ex.name,
                    isConditioning: ex.isConditioning,
                    notes: ex.notes,
                    sets: sets
                )
            }

            return DayTemplate(
                id: editableDay.id,
                name: editableDay.name,
                exercises: exercises
            )
        }

        let block = BlockTemplate(
            id: UUID(),
            name: name.isEmpty ? "Untitled Block" : name,
            weeks: weeks,
            progression: progression,
            days: finalDays
        )

        store.blocks.append(block)
        dismiss()
    }
}

// MARK: - Day Editor

private struct DayEditorView: View {
    @Binding var day: EditableDay

    var body: some View {
        DisclosureGroup(day.name) {
            TextField("Day name", text: $day.name)

            ForEach(day.exercises.indices, id: \.self) { idx in
                ExerciseEditorView(exercise: $day.exercises[idx])
            }

            Button {
                day.exercises.append(EditableExercise())
            } label: {
                Label("Add Exercise", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
    }
}

// MARK: - Exercise Editor

private struct ExerciseEditorView: View {
    @Binding var exercise: EditableExercise

    var body: some View {
        DisclosureGroup(exercise.name.isEmpty ? "New Exercise" : exercise.name) {
            TextField("Exercise name", text: $exercise.name)

            Toggle("Conditioning (time-based)", isOn: $exercise.isConditioning)

            TextField("Notes / text", text: $exercise.notes, axis: .vertical)
                .lineLimit(1...3)

            ForEach(exercise.sets.indices, id: \.self) { idx in
                SetEditorView(
                    set: $exercise.sets[idx],
                    isConditioning: exercise.isConditioning
                )
            }

            Button {
                let nextIndex = (exercise.sets.last?.setIndex ?? 0) + 1
                exercise.sets.append(EditableSet(setIndex: nextIndex))
            } label: {
                Label("Add Set", systemImage: "plus.circle")
            }
            .buttonStyle(.borderless)
            .padding(.top, 4)
        }
    }
}

// MARK: - Set Editor

private struct SetEditorView: View {
    @Binding var set: EditableSet
    var isConditioning: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Set \(set.setIndex)")
                .font(.caption)

            HStack {
                TextField("Reps", text: $set.reps)
                    .keyboardType(.numberPad)

                if isConditioning {
                    TextField("Time (sec)", text: $set.timeSeconds)
                        .keyboardType(.numberPad)
                } else {
                    TextField("Weight", text: $set.weight)
                        .keyboardType(.decimalPad)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
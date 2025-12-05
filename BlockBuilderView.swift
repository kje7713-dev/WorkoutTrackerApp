//
//  BlockBuilderView.swift
//  Savage By Design
//
//  Phase 6: Manual Block Builder (template only, no sessions yet)
//

import SwiftUI

// MARK: - Editable Models (local to the builder)

struct EditableExercise: Identifiable, Equatable {
    let id: UUID = UUID()

    var name: String = ""
    var type: ExerciseType = .strength  // .strength or .conditioning

    // Strength fields
    var strengthSetsCount: Int = 3
    var strengthReps: Int = 5
    var strengthWeight: Double? = nil

    // Conditioning fields
    var conditioningDurationSeconds: Int? = nil
    var conditioningRounds: Int? = nil
    var conditioningCalories: Double? = nil

    var notes: String = ""
}

struct EditableDay: Identifiable, Equatable {
    let id: UUID = UUID()

    var name: String
    var shortCode: String
    var exercises: [EditableExercise] = []

    init(index: Int) {
        self.name = "Day \(index + 1)"
        self.shortCode = "D\(index + 1)"
    }
}

// MARK: - Block Builder View

struct BlockBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme

    @EnvironmentObject private var blocksRepository: BlocksRepository

    // Block-level fields
    @State private var blockName: String = ""
    @State private var blockDescription: String = ""
    @State private var numberOfWeeks: Int = 4

    // Progression
    @State private var progressionType: ProgressionType = .weight
    @State private var deltaWeightText: String = ""
    @State private var deltaSetsText: String = ""
    @State private var selectedDayIndex: Int = 0
    // Days + exercises
    @State private var days: [EditableDay] = [
        EditableDay(index: 0),
        EditableDay(index: 1),
        EditableDay(index: 2),
        EditableDay(index: 3)
    ]

    // Validation alert
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            Form {
                blockInfoSection
                progressionSection
                daysSection
            }
        }
        .navigationTitle("New Block")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveBlock()
                }
                .fontWeight(.bold)
            }
        }
        .alert("Cannot Save Block", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
    }

    // MARK: - Sections

    private var blockInfoSection: some View {
        Section("Block Info") {
            TextField("Block name", text: $blockName)

            TextField("Description (optional)", text: $blockDescription, axis: .vertical)
                .lineLimit(1...3)

            Stepper(value: $numberOfWeeks, in: 1...52) {
                Text("Number of weeks: \(numberOfWeeks)")
            }
        }
    }

    private var progressionSection: some View {
        Section("Progression") {
            Picker("Progression type", selection: $progressionType) {
                Text("Weight").tag(ProgressionType.weight)
                Text("Volume").tag(ProgressionType.volume)
                Text("Custom").tag(ProgressionType.custom)
            }
            .pickerStyle(.segmented)

            if progressionType == .weight {
                TextField("Weight change per week (e.g. 5)", text: $deltaWeightText)
                    .keyboardType(.decimalPad)
            } else if progressionType == .volume {
                TextField("Additional sets per week (e.g. 1)", text: $deltaSetsText)
                    .keyboardType(.numberPad)
            } else {
                Text("Custom progression will be interpreted later. You can leave the fields empty.")
                    .font(.footnote)
                    .foregroundColor(theme.mutedText)
            }
        }
    }

    private var daysSection: some View {
    Section("Days in Block") {
        // Horizontal day selector
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(days.indices, id: \.self) { index in
                    let isSelected = index == selectedDayIndex

                    Button {
                        selectedDayIndex = index
                    } label: {
                        Text("Day \(index + 1)")
                            .font(.subheadline)
                            .fontWeight(isSelected ? .bold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.black : Color.clear)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .foregroundColor(isSelected ? .white : .primary)
                    }
                }
            }
            .padding(.vertical, 4)
        }

        // Editor for the currently selected day
        if days.indices.contains(selectedDayIndex) {
            DayEditorView(day: $days[selectedDayIndex])
        } else {
            Text("No day selected.")
                .foregroundColor(.secondary)
        }

        // Add a new day, and auto-select it
        Button {
            addDay()
            selectedDayIndex = max(days.count - 1, 0)
        } label: {
            Label("Add Day", systemImage: "plus")
        }

        // Delete the currently selected day (if more than one)
        if days.count > 1 {
            Button(role: .destructive) {
                let indexToDelete = selectedDayIndex
                deleteDays(at: IndexSet(integer: indexToDelete))
                // keep selection in bounds after delete
                selectedDayIndex = min(indexToDelete, max(days.count - 1, 0))
            } label: {
                Label("Delete Day", systemImage: "trash")
            }
        }
    }
}

        // Editor for the currently selected day
        if days.indices.contains(selectedDayIndex) {
            DayEditorView(day: $days[selectedDayIndex])
        } else {
            Text("No day selected.")
                .foregroundColor(.secondary)
        }

        // Add a new day, and auto-select it
        Button {
            addDay()
            selectedDayIndex = max(days.count - 1, 0)
        } label: {
            Label("Add Day", systemImage: "plus")
        }
    }
}

    // MARK: - Actions

    private func addDay() {
        let index = days.count
        days.append(EditableDay(index: index))
    }

    private func deleteDays(at offsets: IndexSet) {
        days.remove(atOffsets: offsets)
        // Re-label days to keep names/codes tidy
        for (idx, _) in days.enumerated() {
            days[idx].name = "Day \(idx + 1)"
            days[idx].shortCode = "D\(idx + 1)"
        }
    }

    private func saveBlock() {
        // Basic validation
        guard !blockName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationMessage = "Please enter a block name."
            showValidationAlert = true
            return
        }

        let nonEmptyDays = days.filter { day in
            !day.exercises.isEmpty
        }

        guard !nonEmptyDays.isEmpty else {
            validationMessage = "Add at least one day with at least one exercise."
            showValidationAlert = true
            return
        }

        // Build progression rule
        let deltaWeight = Double(deltaWeightText)
        let deltaSets = Int(deltaSetsText)

        let progressionRule = ProgressionRule(
            type: progressionType,
            deltaWeight: deltaWeight,
            deltaSets: deltaSets,
            deloadWeekIndexes: nil,
            customParams: nil
        )

        // Map editable structures into real models
        let dayTemplates: [DayTemplate] = nonEmptyDays.map { editableDay in
            let exerciseTemplates: [ExerciseTemplate] = editableDay.exercises.map { editableExercise in

                // Strength set(s)
                var strengthSets: [StrengthSetTemplate]? = nil
                var conditioningSets: [ConditioningSetTemplate]? = nil
                var conditioningType: ConditioningType? = nil

                if editableExercise.type == .strength {
                    let baseSet = StrengthSetTemplate(
                        index: 0,
                        reps: editableExercise.strengthReps,
                        weight: editableExercise.strengthWeight,
                        percentageOfMax: nil,
                        rpe: nil,
                        rir: nil,
                        tempo: nil,
                        restSeconds: nil,
                        notes: editableExercise.notes
                    )
                    let count = max(editableExercise.strengthSetsCount, 1)
                    strengthSets = (0..<count).map { idx in
                        var copy = baseSet
                        copy.index = idx
                        return copy
                    }
                } else if editableExercise.type == .conditioning {
                    conditioningType = .monostructural
                    let baseSet = ConditioningSetTemplate(
                        index: 0,
                        durationSeconds: editableExercise.conditioningDurationSeconds,
                        distanceMeters: nil,
                        calories: editableExercise.conditioningCalories,
                        rounds: editableExercise.conditioningRounds,
                        targetPace: nil,
                        effortDescriptor: nil,
                        restSeconds: nil,
                        notes: editableExercise.notes
                    )
                    conditioningSets = [baseSet]
                }

                return ExerciseTemplate(
                    exerciseDefinitionId: nil,
                    customName: editableExercise.name,
                    type: editableExercise.type,
                    category: nil,
                    conditioningType: conditioningType,
                    notes: editableExercise.notes,
                    setGroupId: nil,
                    strengthSets: strengthSets,
                    conditioningSets: conditioningSets,
                    genericSets: nil,
                    progressionRule: progressionRule
                )
            }

            return DayTemplate(
                name: editableDay.name,
                shortCode: editableDay.shortCode,
                goal: nil,
                notes: nil,
                exercises: exerciseTemplates
            )
        }

        let block = Block(
            name: blockName,
            description: blockDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : blockDescription,
            numberOfWeeks: numberOfWeeks,
            goal: nil,
            days: dayTemplates,
            source: .user,
            aiMetadata: nil
        )

        blocksRepository.add(block)
        dismiss()
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        colorScheme == .dark ? theme.backgroundDark : theme.backgroundLight
    }
}

// MARK: - Day Editor

struct DayEditorView: View {
    @Binding var day: EditableDay
    @Environment(\.sbdTheme) private var theme

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                TextField("Day name", text: $day.name)
                TextField("Short code", text: $day.shortCode)

                if day.exercises.isEmpty {
                    Text("No exercises yet.")
                        .font(.footnote)
                        .foregroundColor(theme.mutedText)
                }

                ForEach($day.exercises) { $exercise in
                    ExerciseEditorRow(exercise: $exercise)
                }
                .onDelete { offsets in
                    day.exercises.remove(atOffsets: offsets)
                }

                Button {
                    day.exercises.append(EditableExercise())
                } label: {
                    Label("Add Exercise", systemImage: "plus")
                }
                .padding(.top, 4)
            }
        } header: {
            Text(day.name)
        }
    }
}

// MARK: - Exercise Editor Row

struct ExerciseEditorRow: View {
    @Binding var exercise: EditableExercise
    @Environment(\.sbdTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Exercise name", text: $exercise.name)

            Picker("Type", selection: $exercise.type) {
                Text("Strength").tag(ExerciseType.strength)
                Text("Conditioning").tag(ExerciseType.conditioning)
            }
            .pickerStyle(.segmented)

            if exercise.type == .strength {
                strengthEditor
            } else {
                conditioningEditor
            }

            if !exercise.notes.isEmpty {
                TextEditor(text: $exercise.notes)
                    .frame(minHeight: 40, maxHeight: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                TextField("Notes (optional)", text: $exercise.notes, axis: .vertical)
                    .lineLimit(1...3)
            }
        }
        .padding(.vertical, 4)
    }

    private var strengthEditor: some View {
        VStack(alignment: .leading, spacing: 4) {
            Stepper(value: $exercise.strengthSetsCount, in: 1...10) {
                Text("Sets: \(exercise.strengthSetsCount)")
            }

            Stepper(value: $exercise.strengthReps, in: 1...30) {
                Text("Reps: \(exercise.strengthReps)")
            }

            TextField("Weight (optional)", value: $exercise.strengthWeight, format: .number)
                .keyboardType(.decimalPad)
        }
    }

    private var conditioningEditor: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(
                "Duration (seconds, optional)",
                value: $exercise.conditioningDurationSeconds,
                format: .number
            )
            .keyboardType(.numberPad)

            TextField(
                "Calories (optional)",
                value: $exercise.conditioningCalories,
                format: .number
            )
            .keyboardType(.numberPad)

            TextField(
                "Rounds (optional)",
                value: $exercise.conditioningRounds,
                format: .number
            )
            .keyboardType(.numberPad)

            Text("Use notes for details like EMOM / AMRAP / pacing.")
                .font(.footnote)
                .foregroundColor(theme.mutedText)
        }
    }
}
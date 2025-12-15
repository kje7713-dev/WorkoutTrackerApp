//
//  BlockBuilderView.swift
//  Savage By Design
//
//  Phase 6 / 6.5: Manual Block Builder (template only, no sessions yet)
//

import SwiftUI

enum BlockBuilderMode {
    case new
    case edit(Block)
    case clone(Block)   // "Edit as next block" / version-forward
}

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
    @EnvironmentObject private var sessionsRepository: SessionsRepository

    // What are we doing?
    private let mode: BlockBuilderMode

    // Block-level fields
    @State private var blockName: String = ""
    @State private var blockDescription: String = ""
    @State private var numberOfWeeks: Int = 4

    // Progression
    @State private var progressionType: ProgressionType = .weight
    @State private var deltaWeightText: String = ""
    @State private var deltaSetsText: String = ""

    // Days + exercises
    @State private var days: [EditableDay] = [
        EditableDay(index: 0),
        EditableDay(index: 1),
        EditableDay(index: 2),
        EditableDay(index: 3)
    ]
    @State private var selectedDayIndex: Int = 0

    // Validation alert
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    
    // Confirmation for overwriting sessions
    @State private var showSessionOverwriteConfirmation: Bool = false
    @State private var pendingSave: (() -> Void)? = nil

    // MARK: - Init with mode

    init(mode: BlockBuilderMode = .new) {
        self.mode = mode

        switch mode {
        case .new:
            // leave defaults as-is (empty builder)
            break

        case .edit(let block),
             .clone(let block):
            // Map Block → editable state
            let initial = BlockBuilderView.makeInitialState(from: block)

            _blockName       = State(initialValue: initial.blockName)
            _blockDescription = State(initialValue: initial.blockDescription)
            _numberOfWeeks   = State(initialValue: initial.numberOfWeeks)
            _progressionType = State(initialValue: initial.progressionType)
            _deltaWeightText = State(initialValue: initial.deltaWeightText)
            _deltaSetsText   = State(initialValue: initial.deltaSetsText)
            _days            = State(initialValue: initial.days)
            _selectedDayIndex = State(initialValue: 0)
        }
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            Form {
                blockInfoSection
                progressionSection
                daysSection
            }
        }
        .navigationTitle(navigationTitle)
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
        .alert("Overwrite Existing Sessions?", isPresented: $showSessionOverwriteConfirmation) {
            Button("Cancel", role: .cancel) {
                pendingSave = nil
            }
            Button("Continue", role: .destructive) {
                pendingSave?()
                pendingSave = nil
            }
        } message: {
            Text("This block already has workout sessions with logged progress. Regenerating sessions will overwrite any existing run data. Continue?")
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .new:
            return "New Block"
        case .edit:
            return "Edit Block"
        case .clone:
            return "Next Block"
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

            // Add Day
            Button {
                addDay()
                selectedDayIndex = max(days.count - 1, 0)
            } label: {
                Label("Add Day", systemImage: "plus")
            }

            // Delete Day
            if days.count > 1, days.indices.contains(selectedDayIndex) {
                Button(role: .destructive) {
                    deleteCurrentDay()
                } label: {
                    Label("Delete Day", systemImage: "trash")
                }
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

        // Clamp selected index so it always points at a valid day
        if !days.isEmpty {
            selectedDayIndex = min(selectedDayIndex, days.count - 1)
        } else {
            selectedDayIndex = 0
        }
    }

    private func deleteCurrentDay() {
        guard days.indices.contains(selectedDayIndex) else { return }
        let indexSet = IndexSet(integer: selectedDayIndex)
        deleteDays(at: indexSet)
    }

    private func saveBlock() {
        // Basic validation
        let trimmedName = blockName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            validationMessage = "Please enter a block name."
            showValidationAlert = true
            return
        }

        // ✅ First, strip out exercises whose name is blank
        let cleanedDays: [EditableDay] = days.map { day in
            var copy = day
            copy.exercises = day.exercises.filter {
                !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            return copy
        }

        let nonEmptyDays = cleanedDays.filter { !$0.exercises.isEmpty }

        guard !nonEmptyDays.isEmpty else {
            validationMessage = "Add at least one day with at least one exercise."
            showValidationAlert = true
            return
        }

        // If cloning, require a new name vs the original
        if case .clone(let original) = mode {
            let originalTrimmed = original.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if originalTrimmed == trimmedName {
                validationMessage = "Enter a new name so this block can be saved as a separate template."
                showValidationAlert = true
                return
            }
        }

        // Build progression rule (unchanged)
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

                // Strength / conditioning sets
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

        let newBlock = Block(
            name: trimmedName,
            description: blockDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : blockDescription,
            numberOfWeeks: numberOfWeeks,
            goal: nil,
            days: dayTemplates,
            source: .user,
            aiMetadata: nil
        )

        // Determine which block instance to use for session generation:
        var savedBlock: Block

        switch mode {
        case .new,
             .clone:
            // New template = new row
            blocksRepository.add(newBlock)
            savedBlock = newBlock

        case .edit(let original):
            // Keep id / source / aiMetadata; replace content
            var updated = original
            updated.name = newBlock.name
            updated.description = newBlock.description
            updated.numberOfWeeks = newBlock.numberOfWeeks
            updated.days = newBlock.days
            // source & aiMetadata stay as-is
            blocksRepository.update(updated)
            savedBlock = updated
        }

        // Check if block already has sessions with logged data
        if case .edit = mode {
            let existingSessions = sessionsRepository.sessions(forBlockId: savedBlock.id)
            let hasLoggedData = existingSessions.contains { session in
                session.exercises.contains { exercise in
                    exercise.loggedSets.contains { $0.isCompleted }
                }
            }
            
            if hasLoggedData {
                // Show confirmation dialog before overwriting
                pendingSave = {
                    self.performSessionRegeneration(for: savedBlock)
                }
                showSessionOverwriteConfirmation = true
                return // Wait for user confirmation
            }
        }
        
        // No existing data or new block - proceed with regeneration
        performSessionRegeneration(for: savedBlock)
        dismiss()
    }
    
    private func performSessionRegeneration(for block: Block) {
        // Phase 8: Generate sessions for this block
        let factory = SessionFactory()
        let generated = factory.makeSessions(for: block)

        // Persist sessions for this block
        sessionsRepository.replaceSessions(forBlockId: block.id, with: generated)

        #if DEBUG
        print("🔵 Save button persisted block id: \(block.id) with \(generated.count) sessions")
        #endif
        
        dismiss()
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        colorScheme == .dark ? theme.backgroundDark : theme.backgroundLight
    }

    // MARK: - Block → Editable mapping

    private struct InitialState {
        var blockName: String
        var blockDescription: String
        var numberOfWeeks: Int
        var progressionType: ProgressionType
        var deltaWeightText: String
        var deltaSetsText: String
        var days: [EditableDay]
    }

    private static func makeInitialState(from block: Block) -> InitialState {
        // Derive progression from the first exercise that has a rule
        var derivedType: ProgressionType = .weight
        var derivedDeltaWeight: String = ""
        var derivedDeltaSets: String = ""

        outer: for day in block.days {
            for exercise in day.exercises {
                let rule = exercise.progressionRule
                derivedType = rule.type
                if let dw = rule.deltaWeight {
                    derivedDeltaWeight = String(dw)
                }
                if let ds = rule.deltaSets {
                    derivedDeltaSets = String(ds)
                }
                break outer
            }
        }

        let editableDays: [EditableDay] = block.days.enumerated().map { (idx, dayTemplate) in
            var editableDay = EditableDay(index: idx)
            editableDay.name = dayTemplate.name
            editableDay.shortCode = dayTemplate.shortCode ?? "D\(idx + 1)"

            editableDay.exercises = dayTemplate.exercises.map { exercise in
                var e = EditableExercise()
                e.name = exercise.customName ?? ""
                e.type = exercise.type
                e.notes = exercise.notes ?? ""

                // Strength mapping
                if exercise.type == .strength,
                   let sets = exercise.strengthSets,
                   let first = sets.first {
                    e.strengthSetsCount = sets.count
                    e.strengthReps = first.reps ?? e.strengthReps
                    e.strengthWeight = first.weight
                }

                // Conditioning mapping
                if exercise.type == .conditioning,
                   let sets = exercise.conditioningSets,
                   let first = sets.first {
                    e.conditioningDurationSeconds = first.durationSeconds
                    e.conditioningCalories = first.calories
                    e.conditioningRounds = first.rounds
                }

                return e
            }

            return editableDay
        }

        return InitialState(
            blockName: block.name,
            blockDescription: block.description ?? "",
            numberOfWeeks: block.numberOfWeeks,
            progressionType: derivedType,
            deltaWeightText: derivedDeltaWeight,
            deltaSetsText: derivedDeltaSets,
            days: editableDays
        )
    }
} // <--- FIX: This closes the BlockBuilderView struct

// MARK: - Day Editor

struct DayEditorView: View { // <--- This is the missing struct
    @Binding var day: EditableDay
    @Environment(\.sbdTheme) private var theme

    var body: some View {
        Group { 
            // Day name / code are each their own form rows
            TextField("Day name", text: $day.name)
            TextField("Short code", text: $day.shortCode)

            if day.exercises.isEmpty {
                Text("No exercises yet.")
                    .font(.footnote)
                    .foregroundColor(theme.mutedText)
            }

            // One row per exercise
            ForEach($day.exercises) { $exercise in
                let exerciseID = exercise.id

                ExerciseEditorRow(
                    exercise: $exercise,
                    onDelete: {
                        if let idx = day.exercises.firstIndex(where: { $0.id == exerciseID }) {
                            day.exercises.remove(at: idx)
                        }
                    }
                )
            }

            // Add Exercise is a clean, separate row
            Button {
                day.exercises.append(EditableExercise())
            } label: {
                Label("Add Exercise", systemImage: "plus")
            }
        }
    }
}


// MARK: - Exercise Editor Row

struct ExerciseEditorRow: View {
    @Binding var exercise: EditableExercise
    @Environment(\.sbdTheme) private var theme
    var onDelete: (() -> Void)? = nil

    @State private var showDeleteConfirm = false

    // Shows MINUTES in the UI, stores SECONDS in conditioningDurationSeconds
    private var durationMinutesBinding: Binding<String> {
        Binding<String>(
            get: {
                guard let secs = exercise.conditioningDurationSeconds, secs > 0 else {
                    return ""
                }
                return String(secs / 60)
            },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                guard let minutes = Int(trimmed), minutes > 0 else {
                    exercise.conditioningDurationSeconds = nil
                    return
                }
                exercise.conditioningDurationSeconds = minutes * 60
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Simple name row – no trash here anymore
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

            // 🔻 Delete row – clearly separated at the bottom
            if let onDelete {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("Delete Exercise", systemImage: "trash")
                        .font(.footnote)
                }
                .padding(.top, 4)
                .alert("Delete this exercise?", isPresented: $showDeleteConfirm) {
                    Button("Delete", role: .destructive) {
                        onDelete()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will remove the exercise and its settings from this day.")
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Strength Editor

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

    // MARK: - Conditioning Editor (minutes-based)

    private var conditioningEditor: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(
                "Duration (minutes, optional)",
                text: durationMinutesBinding
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

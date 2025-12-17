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
    var strengthPercentageOfMax: Double? = nil
    var strengthRPE: Double? = nil
    var strengthRIR: Double? = nil
    var strengthTempo: String = ""
    var strengthRestSeconds: Int? = nil

    // Conditioning fields
    var conditioningDurationSeconds: Int? = nil
    var conditioningDistanceMeters: Double? = nil
    var conditioningRounds: Int? = nil
    var conditioningCalories: Double? = nil
    var conditioningTargetPace: String = ""
    var conditioningEffortDescriptor: String = ""
    var conditioningRestSeconds: Int? = nil

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
    
    // Success notification
    @State private var showSuccessAlert: Bool = false
    @State private var successMessage: String = ""
    
    // Confirmation for overwriting sessions
    @State private var showSessionOverwriteConfirmation: Bool = false
    @State private var pendingSave: (() -> Void)? = nil
    
    // AI Generation state
    @State private var showAIPromptSheet: Bool = false
    @State private var aiPrompt: String = ""
    @State private var aiSelectedModel: String = "gpt-3.5-turbo"
    @State private var isGenerating: Bool = false
    @State private var generatedText: String = ""
    @State private var showAIPreview: Bool = false
    @State private var aiError: String?
    private let chatGPTClient = ChatGPTClient()

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
                aiGenerationSection
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
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(successMessage)
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

    private var aiGenerationSection: some View {
        Section("AI Generation") {
            Button {
                showAIPromptSheet = true
            } label: {
                Label("Generate with ChatGPT", systemImage: "sparkles")
            }
            .disabled(isGenerating)
            
            if isGenerating {
                HStack {
                    ProgressView()
                    Text("Generating...")
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showAIPromptSheet) {
            aiPromptSheet
        }
        .sheet(isPresented: $showAIPreview) {
            aiPreviewSheet
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

    // MARK: - AI Prompt Sheet
    
    private var aiPromptSheet: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                Form {
                    Section("Your Request") {
                        TextEditor(text: $aiPrompt)
                            .frame(minHeight: 150)
                        
                        Text("Example: Create a 4-week hypertrophy block with 4 days per week focusing on push/pull/legs split")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Section("Model") {
                        Picker("Model", selection: $aiSelectedModel) {
                            Text("GPT-3.5 Turbo").tag("gpt-3.5-turbo")
                            Text("GPT-4").tag("gpt-4")
                            Text("GPT-4 Turbo").tag("gpt-4-turbo-preview")
                        }
                    }
                    
                    Section {
                        Button("Generate") {
                            generateWithAI()
                        }
                        .disabled(aiPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .navigationTitle("AI Block Generation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAIPromptSheet = false
                    }
                }
            }
        }
    }
    
    // MARK: - AI Preview Sheet
    
    private var aiPreviewSheet: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack {
                    if isGenerating {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Generating workout block...")
                                .font(.headline)
                            Text("Streaming response from ChatGPT")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if let error = aiError {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Error", systemImage: "exclamationmark.triangle")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                    Text(error)
                                        .font(.body)
                                        .foregroundColor(.red)
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            if !generatedText.isEmpty {
                                Text(generatedText)
                                    .font(.system(.body, design: .monospaced))
                                    .textSelection(.enabled)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Generated Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        chatGPTClient.cancel()
                        showAIPreview = false
                        isGenerating = false
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    if !isGenerating && !generatedText.isEmpty && aiError == nil {
                        Menu {
                            Button("Accept & Use") {
                                acceptGeneratedBlock()
                            }
                            Button("Regenerate") {
                                regenerateBlock()
                            }
                        } label: {
                            Text("Actions")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - AI Generation Methods
    
    private func generateWithAI() {
        guard let apiKey = KeychainHelper.shared.loadOpenAIAPIKey(), !apiKey.isEmpty else {
            aiError = "No API key found. Please configure your OpenAI API key in settings."
            showAIPromptSheet = false
            return
        }
        
        isGenerating = true
        generatedText = ""
        aiError = nil
        showAIPromptSheet = false
        showAIPreview = true
        
        let messages = [
            ChatMessage(role: "system", content: ChatGPTPrompts.systemPrompt),
            ChatMessage(role: "user", content: aiPrompt)
        ]
        
        chatGPTClient.streamCompletion(
            messages: messages,
            model: aiSelectedModel,
            apiKey: apiKey,
            temperature: 0.7,
            maxTokens: 3000,
            onChunk: { chunk in
                DispatchQueue.main.async {
                    self.generatedText += chunk
                }
            },
            onComplete: { result in
                DispatchQueue.main.async {
                    self.isGenerating = false
                    
                    switch result {
                    case .success(let fullText):
                        self.generatedText = fullText
                    case .failure(let error):
                        self.aiError = error.localizedDescription
                    }
                }
            }
        )
    }
    
    private func regenerateBlock() {
        generateWithAI()
    }
    
    private func acceptGeneratedBlock() {
        let parser = ChatGPTBlockParser()
        
        do {
            let parsedBlock = try parser.parseBlock(from: generatedText)
            
            // Update the form with parsed data
            blockName = parsedBlock.name
            blockDescription = parsedBlock.description ?? ""
            numberOfWeeks = parsedBlock.numberOfWeeks
            
            // Convert days to editable format
            days = parsedBlock.days.enumerated().map { (idx, dayTemplate) in
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
                        e.strengthPercentageOfMax = first.percentageOfMax
                        e.strengthRPE = first.rpe
                        e.strengthRIR = first.rir
                        e.strengthTempo = first.tempo ?? ""
                        e.strengthRestSeconds = first.restSeconds
                    }
                    
                    // Conditioning mapping
                    if exercise.type == .conditioning,
                       let sets = exercise.conditioningSets,
                       let first = sets.first {
                        e.conditioningDurationSeconds = first.durationSeconds
                        e.conditioningDistanceMeters = first.distanceMeters
                        e.conditioningCalories = first.calories
                        e.conditioningRounds = first.rounds
                        e.conditioningTargetPace = first.targetPace ?? ""
                        e.conditioningEffortDescriptor = first.effortDescriptor ?? ""
                        e.conditioningRestSeconds = first.restSeconds
                    }
                    
                    return e
                }
                
                return editableDay
            }
            
            // Extract progression from first exercise
            if let firstExercise = parsedBlock.days.first?.exercises.first {
                let rule = firstExercise.progressionRule
                progressionType = rule.type
                deltaWeightText = rule.deltaWeight.map { String($0) } ?? ""
                deltaSetsText = rule.deltaSets.map { String($0) } ?? ""
            }
            
            // Close the preview
            showAIPreview = false
            
            // Show success message
            successMessage = "AI block loaded successfully! Review and save when ready."
            showSuccessAlert = true
            
        } catch {
            aiError = "Failed to parse generated block: \(error.localizedDescription)"
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
                        percentageOfMax: editableExercise.strengthPercentageOfMax,
                        rpe: editableExercise.strengthRPE,
                        rir: editableExercise.strengthRIR,
                        tempo: editableExercise.strengthTempo.isEmpty ? nil : editableExercise.strengthTempo,
                        restSeconds: editableExercise.strengthRestSeconds,
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
                        distanceMeters: editableExercise.conditioningDistanceMeters,
                        calories: editableExercise.conditioningCalories,
                        rounds: editableExercise.conditioningRounds,
                        targetPace: editableExercise.conditioningTargetPace.isEmpty ? nil : editableExercise.conditioningTargetPace,
                        effortDescriptor: editableExercise.conditioningEffortDescriptor.isEmpty ? nil : editableExercise.conditioningEffortDescriptor,
                        restSeconds: editableExercise.conditioningRestSeconds,
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
                    e.strengthPercentageOfMax = first.percentageOfMax
                    e.strengthRPE = first.rpe
                    e.strengthRIR = first.rir
                    e.strengthTempo = first.tempo ?? ""
                    e.strengthRestSeconds = first.restSeconds
                }

                // Conditioning mapping
                if exercise.type == .conditioning,
                   let sets = exercise.conditioningSets,
                   let first = sets.first {
                    e.conditioningDurationSeconds = first.durationSeconds
                    e.conditioningDistanceMeters = first.distanceMeters
                    e.conditioningCalories = first.calories
                    e.conditioningRounds = first.rounds
                    e.conditioningTargetPace = first.targetPace ?? ""
                    e.conditioningEffortDescriptor = first.effortDescriptor ?? ""
                    e.conditioningRestSeconds = first.restSeconds
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

            // Exercise name picker with dropdown support
            ExerciseNamePicker(exerciseName: $exercise.name, exerciseType: exercise.type)
                .id(exercise.type) // Force refresh when type changes

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
            
            TextField("% of Max (0-100, optional)", value: $exercise.strengthPercentageOfMax, format: .number)
                .keyboardType(.decimalPad)
            
            TextField("RPE (1-10, optional)", value: $exercise.strengthRPE, format: .number)
                .keyboardType(.decimalPad)
            
            TextField("RIR (0-5, optional)", value: $exercise.strengthRIR, format: .number)
                .keyboardType(.decimalPad)
            
            TextField("Tempo (e.g., 3010, optional)", text: $exercise.strengthTempo)
            
            TextField("Rest seconds (optional)", value: $exercise.strengthRestSeconds, format: .number)
                .keyboardType(.numberPad)
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
                "Distance (meters, optional)",
                value: $exercise.conditioningDistanceMeters,
                format: .number
            )
            .keyboardType(.decimalPad)

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
            
            TextField("Target pace (e.g., 2:00/500m, optional)", text: $exercise.conditioningTargetPace)
            
            TextField("Effort (e.g., easy, moderate, hard, optional)", text: $exercise.conditioningEffortDescriptor)
            
            TextField("Rest seconds (optional)", value: $exercise.conditioningRestSeconds, format: .number)
                .keyboardType(.numberPad)

            Text("Use notes for details like EMOM / AMRAP / pacing.")
                .font(.footnote)
                .foregroundColor(theme.mutedText)
        }
    }
}

// MARK: - Exercise Name Picker with Dropdown

struct ExerciseNamePicker: View {
    @Binding var exerciseName: String
    let exerciseType: ExerciseType
    @EnvironmentObject private var exerciseLibrary: ExerciseLibraryRepository
    
    @State private var showingDropdown = false
    @State private var isCustomEntry = false
    
    private var availableExercises: [ExerciseDefinition] {
        exerciseLibrary.all().filter { $0.type == exerciseType }
    }
    
    private var selectedExerciseDefinition: ExerciseDefinition? {
        availableExercises.first { $0.name == exerciseName }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if isCustomEntry || availableExercises.isEmpty {
                    // Free-form text entry
                    TextField("Exercise name", text: $exerciseName)
                        .textFieldStyle(.roundedBorder)
                } else {
                    // Dropdown picker
                    Menu {
                        // Standard exercises from library
                        ForEach(availableExercises) { exercise in
                            Button(action: {
                                exerciseName = exercise.name
                            }) {
                                Text(exercise.name)
                            }
                        }
                        
                        Divider()
                        
                        // Option to enter custom exercise
                        Button(action: {
                            isCustomEntry = true
                            // Preserve the current exercise name for editing
                        }) {
                            Label("Custom Exercise", systemImage: "pencil")
                        }
                    } label: {
                        HStack {
                            Text(exerciseName.isEmpty ? "Select exercise" : exerciseName)
                                .foregroundColor(exerciseName.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.separator), lineWidth: 1)
                        )
                    }
                }
                
                // Toggle between custom and dropdown
                if !availableExercises.isEmpty {
                    Button(action: {
                        isCustomEntry.toggle()
                        // Preserve the exercise name when toggling modes
                    }) {
                        Image(systemName: isCustomEntry ? "list.bullet" : "pencil")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(6)
                    }
                }
            }
        }
    }
}

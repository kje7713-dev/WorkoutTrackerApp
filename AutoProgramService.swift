import Foundation
import SwiftData

// MARK: - Auto-program config

// ✅ Now matches how the UI uses it (allCases, Identifiable, Codable)
enum BlockGoal: String, CaseIterable, Identifiable, Codable {
    case strength
    case hypertrophy
    case peaking
    
    var id: String { rawValue }
}

struct AutoProgramConfig {
    let name: String                 // "SBD Block 1 – 4 Week Strength"
    let goal: BlockGoal
    let weeksCount: Int             // e.g. 4
    let daysPerWeek: Int            // e.g. 4
    let mainLifts: [String]         // e.g. ["Squat", "Bench", "Deadlift"]
    
    /// Training maxes for main lifts (same names as mainLifts)
    let trainingMaxes: [String: Double]  // ["Squat": 405, "Bench": 285, ...]
}

// MARK: - Auto-programming service

enum AutoProgramError: Error {
    case noTrainingMax(String)
}

struct AutoProgramService {
    
    /// Generates a BlockTemplate (+ days/exercises/sets) and saves it to SwiftData.
    /// Returns the created BlockTemplate so you can use it in UI.
    @discardableResult
    static func generateBlock(
        in context: ModelContext,
        config: AutoProgramConfig
    ) throws -> BlockTemplate {
        
        // 1. Create the block
        let block = BlockTemplate(
            name: config.name,
            weeksCount: config.weeksCount,
            createdAt: .now,
            createdByUser: true,
            notes: "Auto-programmed \(config.goal.rawValue.capitalized) block"
        )
        
        context.insert(block)
        
        // 2. Define a simple weekly % pattern based on goal
        let percentPattern: [Double]
        switch config.goal {
        case .strength:
            // training block ramp
            percentPattern = [0.70, 0.75, 0.80, 0.85]
        case .hypertrophy:
            // a bit lighter, more volume
            percentPattern = [0.65, 0.70, 0.70, 0.75]
        case .peaking:
            // heavier, taper last week
            percentPattern = [0.80, 0.85, 0.90, 0.70]
        }
        
        // 3. Simple day “roles” for 4-day SBD style block
        // (Can expand later)
        let dayRoles = [
            1: "Heavy Upper",
            2: "Volume Lower",
            3: "Heavy Lower",
            4: "Accessory / Conditioning"
        ]
        
        // 4. Ensure we have (or create) ExerciseTemplate entries
        var exerciseTemplatesByName: [String: ExerciseTemplate] = [:]
        
        func template(for name: String, category: String?) -> ExerciseTemplate {
            if let cached = exerciseTemplatesByName[name] {
                return cached
            }
            // Try to find existing template in store
            let descriptor = FetchDescriptor<ExerciseTemplate>(
                predicate: #Predicate { $0.name == name }
            )
            let existing = try? context.fetch(descriptor).first
            if let existing {
                exerciseTemplatesByName[name] = existing
                return existing
            }
            
            let tmpl = ExerciseTemplate(
                name: name,
                category: category,
                defaultReps: nil,
                defaultSets: nil,
                defaultRPE: nil,
                defaultTempo: nil,
                notes: nil
            )
            context.insert(tmpl)
            exerciseTemplatesByName[name] = tmpl
            return tmpl
        }
        
        // 5. Build weeks & days
        for weekIndex in 1...config.weeksCount {
            // Clamp % array if weeksCount > pattern size
            let pct = percentPattern[min(weekIndex - 1, percentPattern.count - 1)]
            
            for dayIndex in 1...config.daysPerWeek {
                let role = dayRoles[dayIndex] ?? "Day \(dayIndex)"
                
                let day = DayTemplate(
                    weekIndex: weekIndex,
                    dayIndex: dayIndex,
                    title: role,
                    dayDescription: description(for: role, goal: config.goal),
                    orderIndex: dayIndex,
                    block: block
                )
                block.days.append(day)
                
                // Decide which lifts live on this day
                let plannedLifts = liftsForDay(
                    role: role,
                    mainLifts: config.mainLifts
                )
                
                for (exerciseOrder, lift) in plannedLifts.enumerated() {
                    let exerciseName = lift.name
                    let category = lift.category
                    let sets = lift.sets
                    let reps = lift.reps
                    
                    let tm = config.trainingMaxes[lift.tmKey]
                    if tm == nil && lift.usesTM {
                        throw AutoProgramError.noTrainingMax(lift.tmKey)
                    }
                    
                    let eTemplate = template(for: exerciseName, category: category)
                    
                    let planned = PlannedExercise(
                        orderIndex: exerciseOrder,
                        exerciseTemplate: eTemplate,
                        day: day,
                        notes: nil
                    )
                    day.exercises.append(planned)
                    
                    // Build prescribed sets
                    for setIndex in 1...sets {
                        let weight: Double
                        if lift.usesTM, let tm {
                            weight = tm * pct
                        } else {
                            weight = lift.fixedWeight ?? 0
                        }
                        
                        let set = PrescribedSet(
                            setIndex: setIndex,
                            targetReps: reps,
                            targetWeight: weight,
                            targetRPE: lift.targetRPE,
                            tempo: nil,
                            notes: nil,
                            plannedExercise: planned
                        )
                        planned.prescribedSets.append(set)
                    }
                }
            }
        }
        
        try context.save()
        return block
    }
    
    // MARK: - Helpers
    
    /// Simple description templates
    private static func description(for role: String, goal: BlockGoal) -> String {
        switch (role, goal) {
        case ("Heavy Upper", .strength):
            return "Primary bench variation heavy for low reps plus upper-body accessories."
        case ("Volume Lower", .strength):
            return "Squat-focused volume work in moderate rep ranges."
        case ("Heavy Lower", .strength):
            return "Primary squat or deadlift heavy for low reps with posterior chain accessories."
        case ("Accessory / Conditioning", _):
            return "Single-leg work, core, and conditioning intervals. Keep RPE moderate."
        default:
            return "\(role) session focused on \(goal.rawValue)."
        }
    }
    
    /// A tiny internal “template” to drive per-day exercise choices.
    private struct DayLift {
        let name: String
        let category: String?
        let sets: Int
        let reps: Int
        let usesTM: Bool
        let tmKey: String
        let fixedWeight: Double?
        let targetRPE: Double?
    }
    
    private static func liftsForDay(
        role: String,
        mainLifts: [String]
    ) -> [DayLift] {
        let squat = mainLifts.first { $0.lowercased().contains("squat") } ?? "Back Squat"
        let bench = mainLifts.first { $0.lowercased().contains("bench") } ?? "Bench Press"
        let dead  = mainLifts.first { $0.lowercased().contains("dead")  } ?? "Deadlift"
        
        switch role {
        case "Heavy Upper":
            return [
                DayLift(name: bench, category: "Press", sets: 5, reps: 3,
                        usesTM: true, tmKey: bench, fixedWeight: nil, targetRPE: 8.0),
                DayLift(name: "Incline DB Press", category: "Press", sets: 4, reps: 8,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0),
                DayLift(name: "Barbell Row", category: "Pull", sets: 4, reps: 8,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0)
            ]
            
        case "Volume Lower":
            return [
                DayLift(name: squat, category: "Squat", sets: 4, reps: 6,
                        usesTM: true, tmKey: squat, fixedWeight: nil, targetRPE: 7.5),
                DayLift(name: "RDL", category: "Hinge", sets: 4, reps: 8,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0),
                DayLift(name: "Walking Lunge", category: "Single-leg", sets: 3, reps: 10,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0)
            ]
            
        case "Heavy Lower":
            return [
                DayLift(name: dead, category: "Hinge", sets: 5, reps: 3,
                        usesTM: true, tmKey: dead, fixedWeight: nil, targetRPE: 8.0),
                DayLift(name: "Paused Squat", category: "Squat", sets: 3, reps: 5,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 8.0),
                DayLift(name: "Back Extension", category: "Accessory", sets: 3, reps: 12,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0)
            ]
            
        case "Accessory / Conditioning":
            return [
                DayLift(name: "Bulgarian Split Squat", category: "Single-leg", sets: 3, reps: 10,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0),
                DayLift(name: "Hanging Leg Raise", category: "Core", sets: 3, reps: 12,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0),
                DayLift(name: "Bike Intervals", category: "Conditioning", sets: 6, reps: 30,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0)
            ]
            
        default:
            // fallback: just cycle main lifts
            return [
                DayLift(name: squat, category: "Squat", sets: 4, reps: 5,
                        usesTM: true, tmKey: squat, fixedWeight: nil, targetRPE: 7.5),
                DayLift(name: bench, category: "Press", sets: 4, reps: 5,
                        usesTM: true, tmKey: bench, fixedWeight: nil, targetRPE: 7.5),
                DayLift(name: dead, category: "Hinge", sets: 3, reps: 3,
                        usesTM: true, tmKey: dead, fixedWeight: nil, targetRPE: 8.0)
            ]
        }
    }
}

import SwiftUI
import Charts
import SwiftData

// MARK: - Metric model

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

// MARK: - Block builder UI enums / helpers

enum BlockBuilderMode: String, CaseIterable, Identifiable {
    case template = "Templates"
    case custom   = "Custom"
    case ai       = "AI"

    var id: String { rawValue }
}

// ⛔️ Removed the redundant BlockGoal extension here

// MARK: - Block list

struct BlockListView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \BlockTemplate.name, order: .forward)
    private var blocks: [BlockTemplate]

    @State private var showingBuilder = false

    var body: some View {
        NavigationStack {
            List {
                if blocks.isEmpty {
                    Text("No blocks yet.\nTap + to create one.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(blocks) { blockTemplate in
                        NavigationLink(blockTemplate.name) {
                            DashboardView(block: blockTemplate)
                        }
                    }
                    .onDelete(perform: deleteBlocks)
                }
            }
            .navigationTitle("Blocks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingBuilder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingBuilder) {
                BlockBuilderView()
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private func deleteBlocks(at offsets: IndexSet) {
        for index in offsets {
            let block = blocks[index]
            context.delete(block)
        }
        do {
            try context.save()
        } catch {
            print("Error deleting blocks: \(error)")
        }
    }
}

// MARK: - Block Builder

struct BlockBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var mode: BlockBuilderMode = .ai   // default to AI

    // Shared basic fields
    @State private var name: String = ""
    @State private var weeks: Int = 4
    @State private var daysPerWeek: Int = 4

    // AI-specific fields
    @State private var goal: BlockGoal = .strength
    @State private var squatTM: String = "405"
    @State private var benchTM: String = "285"
    @State private var deadliftTM: String = "495"

    @State private var errorMessage: String?
    @State private var isGenerating = false

    var body: some View {
        NavigationStack {
            Form {
                // Mode picker
                Section {
                    Picker("Mode", selection: $mode) {
                        ForEach(BlockBuilderMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Basic") {
                    TextField("Block name (required, e.g. SBD Block 1…)", text: $name)
                        .textInputAutocapitalization(.words)

                    Stepper("Weeks: \(weeks)", value: $weeks, in: 1...12)
                    Stepper("Days per week: \(daysPerWeek)", value: $daysPerWeek, in: 1...7)
                }

                if mode == .template {
                    Section("Templates") {
                        Text("Template library UI to come.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if mode == .custom {
                    Section("Custom Block") {
                        Text("Manual day + exercise builder UI to come.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                if mode == .ai {
                    aiSection
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("New Block")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - AI section

    private var aiSection: some View {
        Section("AI Auto Programming") {
            Picker("Goal", selection: $goal) {
                ForEach(BlockGoal.allCases) { goal in
                    Text(goal.rawValue.capitalized).tag(goal)
                }
            }

            Text("Training Maxes")
                .font(.subheadline)

            HStack {
                Text("Squat")
                Spacer()
                TextField("e.g. 405", text: $squatTM)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
            }

            HStack {
                Text("Bench")
                Spacer()
                TextField("e.g. 285", text: $benchTM)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
            }

            HStack {
                Text("Deadlift")
                Spacer()
                TextField("e.g. 495", text: $deadliftTM)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
            }

            Button {
                generateAIBlock()
            } label: {
                if isGenerating {
                    ProgressView()
                } else {
                    Text("Generate Block")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .disabled(isGenerating || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    // MARK: - Actions

    private func generateAIBlock() {
        errorMessage = nil

        guard
            let squat = Double(squatTM),
            let bench = Double(benchTM),
            let dead  = Double(deadliftTM)
        else {
            errorMessage = "Please enter valid numbers for training maxes."
            return
        }

        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Block name is required."
            return
        }

        isGenerating = true

        let config = AutoProgramConfig(
            name: name,
            goal: goal,
            weeksCount: weeks,
            daysPerWeek: daysPerWeek,
            mainLifts: ["Back Squat", "Bench Press", "Deadlift"],
            trainingMaxes: [
                "Back Squat": squat,
                "Bench Press": bench,
                "Deadlift": dead
            ]
        )

        do {
            _ = try AutoProgramService.generateBlock(in: context, config: config)
            isGenerating = false
            dismiss()
        } catch {
            isGenerating = false
            errorMessage = "Failed to generate block: \(error)"
        }
    }
}

// MARK: - Dashboard (per block)

struct DashboardView: View {
    let block: BlockTemplate

    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutSession.weekIndex)
    private var allSessions: [WorkoutSession]

    // Sessions whose weekIndex is within this block’s week range.
    // (We don’t yet have an explicit block relationship on WorkoutSession.)
    private var sessionsForBlock: [WorkoutSession] {
        allSessions.filter { $0.weekIndex >= 1 && $0.weekIndex <= block.weeksCount }
    }

    // All weeks for this block
    private var weeks: [Int] {
        guard block.weeksCount > 0 else { return [] }
        return Array(1...block.weeksCount)
    }

    // Expected reps / volume from the PROGRAM (Plan) /////////////////////////

    private var expectedRepsPerWeek: [Int: Double] {
        var dict: [Int: Double] = [:]
        for day in block.days {
            let reps = day.exercises
                .flatMap { $0.prescribedSets }
                .reduce(0.0) { $0 + Double($1.targetReps) }
            dict[day.weekIndex, default: 0] += reps
        }
        return dict
    }

    private var expectedVolumePerWeek: [Int: Double] {
        var dict: [Int: Double] = [:]
        for day in block.days {
            let vol = day.exercises
                .flatMap { $0.prescribedSets }
                .reduce(0.0) { partial, set in
                    partial + (Double(set.targetReps) * set.targetWeight)
                }
            dict[day.weekIndex, default: 0] += vol
        }
        return dict
    }

    private var totalExpectedRepsInBlock: Double {
        expectedRepsPerWeek.values.reduce(0, +)
    }

    private var totalExpectedVolumeInBlock: Double {
        expectedVolumePerWeek.values.reduce(0, +)
    }

    // Expected % curves (always end at 100)

    private var expectedExercisePctByWeek: [Int: Double] {
        guard totalExpectedRepsInBlock > 0 else { return [:] }
        var dict: [Int: Double] = [:]
        var cumulative = 0.0
        for week in weeks {
            cumulative += expectedRepsPerWeek[week] ?? 0
            dict[week] = (cumulative / totalExpectedRepsInBlock) * 100.0
        }
        return dict
    }

    private var expectedVolumePctByWeek: [Int: Double] {
        guard totalExpectedVolumeInBlock > 0 else { return [:] }
        var dict: [Int: Double] = [:]
        var cumulative = 0.0
        for week in weeks {
            cumulative += expectedVolumePerWeek[week] ?? 0
            dict[week] = (cumulative / totalExpectedVolumeInBlock) * 100.0
        }
        return dict
    }

    // Actual % curves from logged sessions ///////////////////////////////////

    private var actualExercisePctByWeek: [Int: Double] {
        guard totalExpectedRepsInBlock > 0 else { return [:] }
        var dict: [Int: Double] = [:]

        for week in weeks {
            let weeksUpTo = sessionsForBlock.filter { $0.weekIndex <= week }
            let completedSets = weeksUpTo
                .flatMap { $0.exercises }
                .flatMap { $0.sets }
                .filter { $0.completed }

            let reps = completedSets.reduce(0.0) { $0 + Double($1.actualReps) }
            dict[week] = (reps / totalExpectedRepsInBlock) * 100.0
        }

        return dict
    }

    private var actualVolumePctByWeek: [Int: Double] {
        guard totalExpectedVolumeInBlock > 0 else { return [:] }
        var dict: [Int: Double] = [:]

        for week in weeks {
            let weeksUpTo = sessionsForBlock.filter { $0.weekIndex <= week }
            let completedSets = weeksUpTo
                .flatMap { $0.exercises }
                .flatMap { $0.sets }
                .filter { $0.completed }

            let volume = completedSets.reduce(0.0) { partial, set in
                partial + (Double(set.actualReps) * set.actualWeight)
            }
            dict[week] = (volume / totalExpectedVolumeInBlock) * 100.0
        }

        return dict
    }

    private var exerciseCompletionPoints: [MetricPoint] {
        guard !weeks.isEmpty else { return [] }
        let expected = weeks.map { expectedExercisePctByWeek[$0] ?? 0 }
        let actual   = weeks.map { actualExercisePctByWeek[$0]   ?? 0 }
        return MetricPoint.makeSeries(weeks: weeks, expected: expected, actual: actual)
    }

    private var volumeCompletionPoints: [MetricPoint] {
        guard !weeks.isEmpty else { return [] }
        let expected = weeks.map { expectedVolumePctByWeek[$0] ?? 0 }
        let actual   = weeks.map { actualVolumePctByWeek[$0]   ?? 0 }
        return MetricPoint.makeSeries(weeks: weeks, expected: expected, actual: actual)
    }

    // “Current day” label – just first day in block for now
    private var currentDayLabel: String {
        guard let firstDay = block.days.sorted(by: {
            if $0.weekIndex == $1.weekIndex {
                return $0.dayIndex < $1.dayIndex
            }
            return $0.weekIndex < $1.weekIndex
        }).first else {
            return "No days defined"
        }

        return "Week \(firstDay.weekIndex) • Day \(firstDay.dayIndex) – \(firstDay.title)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    QuoteHeader()

                    NavigationLink {
                        BlockDetailView(block: block)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(block.name)
                                .font(.title)
                                .fontWeight(.bold)

                            Text(currentDayLabel)
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
                        points: exerciseCompletionPoints
                    )

                    MetricCard(
                        title: "% Volume Completed in Block",
                        subtitle: "Expected vs Actual",
                        points: volumeCompletionPoints
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

// MARK: - Block Detail (week/day + summary)

struct BlockDetailView: View {
    let block: BlockTemplate

    @State private var selectedDayIndex: Int
    @State private var selectedWeek: Int
    @State private var dragOffset: CGFloat = 0

    @Environment(\.modelContext) private var context

    private var weeks: [Int] {
        let unique = Set(block.days.map { $0.weekIndex })
        return unique.sorted()
    }

    private func days(for week: Int) -> [DayTemplate] {
        block.days
            .filter { $0.weekIndex == week }
            .sorted { $0.dayIndex < $1.dayIndex }
    }

    private var selectedDay: DayTemplate? {
        block.days.first {
            $0.weekIndex == selectedWeek && $0.dayIndex == selectedDayIndex
        }
    }

    init(block: BlockTemplate) {
        self.block = block

        let sortedWeeks = Set(block.days.map { $0.weekIndex }).sorted()
        let initialWeek = sortedWeeks.first ?? 1
        _selectedWeek = State(initialValue: initialWeek)

        let firstDayIndex = block.days
            .filter { $0.weekIndex == initialWeek }
            .map { $0.dayIndex }
            .sorted()
            .first ?? 1
        _selectedDayIndex = State(initialValue: firstDayIndex)
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
                        Text("Day \(day.dayIndex) – \(day.title)")
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

                // Day selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(days(for: selectedWeek)) { day in
                            Button {
                                selectedDayIndex = day.dayIndex
                            } label: {
                                Text("Day \(day.dayIndex)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(
                                        Capsule().fill(
                                            selectedDayIndex == day.dayIndex
                                            ? Color.accentColor
                                            : Color(.secondarySystemBackground)
                                        )
                                    )
                                    .foregroundColor(
                                        selectedDayIndex == day.dayIndex ? .white : .primary
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

                        Text(day.dayDescription)
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

                        ForEach(day.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { planned in
                            let sets = planned.prescribedSets.count
                            let reps = planned.prescribedSets.first?.targetReps ?? 0
                            let weight = planned.prescribedSets.first?.targetWeight ?? 0

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(planned.exerciseTemplate?.name ?? "Exercise")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)

                                    Text("\(sets) x \(reps) @ \(Int(weight)) lb")
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
                        // swipe left
                        if let next = weeks.first(where: { $0 > selectedWeek }) {
                            newWeek = next
                        }
                    } else if value.translation.width > threshold {
                        // swipe right
                        if let prev = weeks.reversed().first(where: { $0 < selectedWeek }) {
                            newWeek = prev
                        }
                    }

                    withAnimation(.spring()) {
                        selectedWeek = newWeek
                        // reset selected day to first in that week
                        if let first = days(for: newWeek).first {
                            selectedDayIndex = first.dayIndex
                        }
                        dragOffset = 0
                    }
                }
        )
        .navigationTitle(block.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - SwiftData helpers

    private func existingOrNewSession(for day: DayTemplate) -> WorkoutSession {
        if let existing = fetchSession(for: day) {
            return existing
        } else {
            return createSession(for: day)
        }
    }

    private func fetchSession(for day: DayTemplate) -> WorkoutSession? {
        let week = day.weekIndex
        let dayIndex = day.dayIndex

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

    private func createSession(for day: DayTemplate) -> WorkoutSession {
        let session = WorkoutSession(
            weekIndex: day.weekIndex,
            dayIndex: day.dayIndex
        )

        for planned in day.exercises.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            let sessionExercise = SessionExercise(
                orderIndex: planned.orderIndex,
                session: session,
                exerciseTemplate: planned.exerciseTemplate,
                nameOverride: planned.exerciseTemplate?.name
            )

            for pSet in planned.prescribedSets.sorted(by: { $0.setIndex < $1.setIndex }) {
                let set = SessionSet(
                    setIndex: pSet.setIndex,
                    targetReps: pSet.targetReps,
                    targetWeight: pSet.targetWeight,
                    targetRPE: pSet.targetRPE,
                    actualReps: pSet.targetReps,
                    actualWeight: pSet.targetWeight,
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

// MARK: - Workout Session view (per-set logging)

struct WorkoutSessionView: View {
    @Bindable var session: WorkoutSession
    let day: DayTemplate

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
                    Text("Day \(day.dayIndex) – \(day.title)")
                        .font(.headline)
                    Text(day.dayDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)

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

                                HStack {
                                    Stepper(
                                        "Reps: \(set.actualReps)",
                                        value: $set.actualReps,
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
        BlockListView()
    }
}

#Preview {
    ContentView()
}
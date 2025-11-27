import SwiftUI
import Charts
import SwiftData

// MARK: - UI Metric model (kept)

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

//
// MARK: - Block list + Builder
//

enum BlockBuilderMode: String, CaseIterable, Identifiable {
    case template = "Templates"
    case custom   = "Custom"
    case ai       = "AI"
    
    var id: String { rawValue }
}

struct BlockListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BlockTemplate.name, order: .forward) private var blocks: [BlockTemplate]
    
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
                            DashboardView(blockTemplate: blockTemplate)
                        }
                    }
                    .onDelete(perform: deleteBlocks)
                }
            }
            .navigationTitle("Blocks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
        try? context.save()
    }
}

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
                    TextField("Block name (required, e.g. SBD Block 1 – 4 Week Strength)", text: $name)
                    
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
                ForEach(BlockGoal.allCases, id: \.self) { goal in
                    Text(goal.rawValue.capitalized).tag(goal)
                }
            }
            
            Text("Training Maxes")
                .font(.subheadline)
            
            HStack {
                Text("Squat")
                Spacer()
                TextField("lb", text: $squatTM)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
            }
            
            HStack {
                Text("Bench")
                Spacer()
                TextField("lb", text: $benchTM)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
            }
            
            HStack {
                Text("Deadlift")
                Spacer()
                TextField("lb", text: $deadliftTM)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
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
            .disabled(isGenerating)
        }
    }
    
    // MARK: - Actions
    
    private func generateAIBlock() {
        errorMessage = nil
        
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Block name is required."
            return
        }
        
        guard
            let squat = Double(squatTM),
            let bench = Double(benchTM),
            let dead  = Double(deadliftTM)
        else {
            errorMessage = "Please enter valid numbers for training maxes."
            return
        }
        
        isGenerating = true
        
        let config = AutoProgramConfig(
            name: name,
            goal: goal,
            weeksCount: weeks,
            daysPerWeek: daysPerWeek,
            mainLifts: ["Squat", "Bench", "Deadlift"],
            trainingMaxes: [
                "Squat": squat,
                "Bench": bench,
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

//
// MARK: - Dashboard for a specific BlockTemplate
//

struct DashboardView: View {
    let blockTemplate: BlockTemplate
    
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutSession.weekIndex) private var sessions: [WorkoutSession]
    
    private var weeks: [Int] {
        let count = max(blockTemplate.weeksCount, 1)
        return Array(1...count)
    }
    
    /// Total expected reps across the whole block, from templates
    private var totalExpectedRepsInBlock: Double {
        blockTemplate.days
            .flatMap { $0.exercises }
            .flatMap { $0.prescribedSets }
            .reduce(0.0) { $0 + Double($1.targetReps) }
    }
    
    /// Total expected volume (reps * weight) across the whole block
    private var totalExpectedVolumeInBlock: Double {
        blockTemplate.days
            .flatMap { $0.exercises }
            .flatMap { $0.prescribedSets }
            .reduce(0.0) { total, set in
                total + Double(set.targetReps) * set.targetWeight
            }
    }
    
    // Expected = straight line from 0 → 100 over N weeks
    // Actual   = completed reps / total expected reps in block
    private var exerciseCompletionPointsComputed: [MetricPoint] {
        guard totalExpectedRepsInBlock > 0 else { return [] }
        
        var expected: [Double] = []
        var actual: [Double] = []
        let weekCount = Double(weeks.count)
        
        for week in weeks {
            let weeksUpTo = sessions.filter { $0.weekIndex <= week }
            let completedSets = weeksUpTo
                .flatMap { $0.exercises }
                .flatMap { $0.sets }
                .filter { $0.completed }
            
            let actualRepsToWeek = completedSets.reduce(0.0) { $0 + Double($1.actualReps) }
            let actualPct = (actualRepsToWeek / totalExpectedRepsInBlock) * 100.0
            actual.append(actualPct)
            
            let expectedPct = (Double(week) / weekCount) * 100.0
            expected.append(expectedPct)
        }
        
        return MetricPoint.makeSeries(
            weeks: weeks,
            expected: expected,
            actual: actual
        )
    }
    
    // Same idea but for volume
    private var volumeCompletionPointsComputed: [MetricPoint] {
        guard totalExpectedVolumeInBlock > 0 else { return [] }
        
        var expected: [Double] = []
        var actual: [Double] = []
        let weekCount = Double(weeks.count)
        
        for week in weeks {
            let weeksUpTo = sessions.filter { $0.weekIndex <= week }
            let completedSets = weeksUpTo
                .flatMap { $0.exercises }
                .flatMap { $0.sets }
                .filter { $0.completed }
            
            let actualVolumeToWeek = completedSets.reduce(0.0) { partial, set in
                partial + Double(set.actualReps) * set.actualWeight
            }
            let actualPct = (actualVolumeToWeek / totalExpectedVolumeInBlock) * 100.0
            actual.append(actualPct)
            
            let expectedPct = (Double(week) / weekCount) * 100.0
            expected.append(expectedPct)
        }
        
        return MetricPoint.makeSeries(
            weeks: weeks,
            expected: expected,
            actual: actual
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    QuoteHeader()
                    
                    // Card for this block
                    NavigationLink {
                        BlockDetailView(blockTemplate: blockTemplate)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(blockTemplate.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("\(blockTemplate.weeksCount)-week block")
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
                        points: exerciseCompletionPointsComputed
                    )
                    
                    MetricCard(
                        title: "% Volume Completed in Block",
                        subtitle: "Expected vs Actual",
                        points: volumeCompletionPointsComputed
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

// MARK: - Block Detail (week/day + summary) using BlockTemplate

struct BlockDetailView: View {
    let blockTemplate: BlockTemplate
    
    @State private var selectedWeek: Int
    @State private var selectedDayIndex: Int
    @State private var dragOffset: CGFloat = 0
    
    @Environment(\.modelContext) private var context
    
    init(blockTemplate: BlockTemplate) {
        self.blockTemplate = blockTemplate
        
        let initialWeek = max(blockTemplate.weeksCount > 0 ? 1 : 0, 1)
        _selectedWeek = State(initialValue: initialWeek)
        
        let firstDayIndex = blockTemplate.days
            .filter { $0.weekIndex == initialWeek }
            .map { $0.dayIndex }
            .sorted()
            .first ?? 1
        _selectedDayIndex = State(initialValue: firstDayIndex)
    }
    
    private var weeks: [Int] {
        let count = max(blockTemplate.weeksCount, 1)
        return Array(1...count)
    }
    
    private var daysInSelectedWeek: [DayTemplate] {
        blockTemplate.days
            .filter { $0.weekIndex == selectedWeek }
            .sorted { $0.dayIndex < $1.dayIndex }
    }
    
    private var selectedDay: DayTemplate? {
        daysInSelectedWeek.first { $0.dayIndex == selectedDayIndex }
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
                        ForEach(daysInSelectedWeek) { day in
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
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(planned.exerciseTemplate?.name ?? "Exercise")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    if let firstSet = planned.prescribedSets.sorted(by: { $0.setIndex < $1.setIndex }).first {
                                        let setCount = planned.prescribedSets.count
                                        Text("\(setCount) x \(firstSet.targetReps) @ \(Int(firstSet.targetWeight)) lb")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
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
                    
                    // Start workout
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
                        if let next = weeks.first(where: { $0 > selectedWeek }) {
                            newWeek = next
                        }
                    } else if value.translation.width > threshold {
                        // Swipe right → previous week
                        if let prev = weeks.reversed().first(where: { $0 < selectedWeek }) {
                            newWeek = prev
                        }
                    }
                    
                    withAnimation(.spring()) {
                        selectedWeek = newWeek
                        // reset selected day to first day in new week
                        let firstDay = blockTemplate.days
                            .filter { $0.weekIndex == newWeek }
                            .map { $0.dayIndex }
                            .sorted()
                            .first
                        if let firstDay {
                            selectedDayIndex = firstDay
                        }
                        dragOffset = 0
                    }
                }
        )
        .navigationTitle(blockTemplate.name)
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
        
        // Build exercises + sets from the day template
        for planned in day.exercises.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            let sessionExercise = SessionExercise(
                orderIndex: planned.orderIndex,
                session: session,
                exerciseTemplate: planned.exerciseTemplate,
                nameOverride: planned.exerciseTemplate?.name
            )
            
            for prescribed in planned.prescribedSets.sorted(by: { $0.setIndex < $1.setIndex }) {
                let set = SessionSet(
                    setIndex: prescribed.setIndex,
                    targetReps: prescribed.targetReps,
                    targetWeight: prescribed.targetWeight,
                    targetRPE: prescribed.targetRPE,
                    actualReps: prescribed.targetReps,
                    actualWeight: prescribed.targetWeight,
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
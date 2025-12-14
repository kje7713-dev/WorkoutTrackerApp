import SwiftUI

// MARK: - Run Mode Container

struct BlockRunModeView: View {
    let block: Block
    
    @Environment(\.dismiss) private var dismiss

    @State private var weeks: [RunWeekState]
    @State private var currentWeekIndex: Int = 0
    @State private var currentDayIndex: Int = 0

    @State private var lastCommittedWeekIndex: Int = 0
    @State private var pendingWeekIndex: Int? = nil
    @State private var showSkipAlert: Bool = false
    
    // Debounce work item to prevent excessive saves during rapid edits
    @State private var saveDebounceWorkItem: DispatchWorkItem? = nil

    init(block: Block) {
        self.block = block

        if let persisted = BlockRunModeView.loadPersistedWeeks(for: block.id) {
            _weeks = State(initialValue: persisted)
        } else {
            _weeks = State(initialValue: BlockRunModeView.buildWeeks(from: block))
        }
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
                            currentDayIndex: $currentDayIndex,
                            onSave: saveWeeks
                        )
                        .tag(weekIndex)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentWeekIndex) { _, newValue in
                    handleWeekChange(newWeekIndex: newValue)
                }
                .onChange(of: weeks.map { week in
                    week.days.map { day in
                        day.exercises.map { exercise in
                            exercise.sets.map(\.isCompleted)
                        }
                    }
                }) { _, _ in
                    print("🔵 Set completion changed - auto-saving")
                    saveWeeks()
                }
                .alert("You can skip â but champions donât.", isPresented: $showSkipAlert) {
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    print("🔵 Toolbar 'Back to Blocks' button pressed")
                    commitAndSave()
                    print("🔵 Dismissing after save")
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Blocks")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.accentColor)
                }
                .accessibilityLabel("Go back to Blocks")
                .accessibilityHint("Saves current progress and returns to the Blocks view")
            }
        }
        .onDisappear {
            print("🔵 BlockRunModeView onDisappear - saving state")
            // Cancel any pending debounced saves and do a final save
            saveDebounceWorkItem?.cancel()
            commitAndSave()
        }
    }

    private var topBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Block name BIG
            Text(block.name)
                .font(.largeTitle)
                .fontWeight(.black)
                .textCase(.uppercase)
                .kerning(1.2)

            // Full day name (primary)
            let fullDay: String = {
                guard block.days.indices.contains(currentDayIndex) else { return "" }
                return block.days[currentDayIndex].name
            }()

            Text(fullDay)
                .font(.headline)
                .fontWeight(.semibold)

            // Short code + week in secondary role
            let short: String = {
                guard block.days.indices.contains(currentDayIndex) else { return "" }
                return block.days[currentDayIndex].shortCode ?? ""
            }()

            Text("Week \(currentWeekIndex + 1) â¢ \(short.uppercased())")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .kerning(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Save Helpers
    
    /// Commits all pending binding changes and performs an immediate save.
    /// This method should be called when we need to ensure all state is synchronized
    /// before performing critical operations like navigation or app backgrounding.
    private func commitAndSave() {
        print("🔵 commitAndSave() called - forcing state synchronization")
        
        // Cancel any pending debounced saves
        saveDebounceWorkItem?.cancel()
        saveDebounceWorkItem = nil
        
        // Force SwiftUI to process any pending binding updates using a minimal
        // async dispatch. This ensures all nested bindings have propagated their
        // changes to the parent @State before we proceed with the save operation.
        // We use a semaphore to make this synchronous so the save happens after
        // state synchronization is complete.
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            // At this point, all pending SwiftUI state updates have been processed
            semaphore.signal()
        }
        semaphore.wait()
        
        // Log validation data before save
        validateAndLogWeeksData()
        
        // Perform the save
        print("🔵 Performing immediate save after commit")
        BlockRunModeView.saveWeeks(weeks, for: block.id)
    }
    
    /// Debounced save that prevents excessive file I/O during rapid edits.
    /// This is called by onChange handlers during normal editing.
    private func saveWeeks() {
        print("🔵 Instance saveWeeks() called - debouncing save")
        
        // Cancel existing pending save
        saveDebounceWorkItem?.cancel()
        
        // Schedule new save after a short delay using DispatchQueue for more reliable timing
        // that won't be blocked by UI interactions
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            print("🔵 Debounced save executing")
            self.validateAndLogWeeksData()
            BlockRunModeView.saveWeeks(self.weeks, for: self.block.id)
        }
        
        saveDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    /// Validates and logs the current weeks data structure to help diagnose save issues.
    private func validateAndLogWeeksData() {
        print("🔵 Validating weeks data before save:")
        print("   - Total weeks: \(weeks.count)")
        
        for (weekIdx, week) in weeks.enumerated() {
            let completedSets = week.days.flatMap { $0.exercises }.flatMap { $0.sets }.filter { $0.isCompleted }.count
            let totalSets = week.days.flatMap { $0.exercises }.flatMap { $0.sets }.count
            print("   - Week \(weekIdx): \(completedSets)/\(totalSets) sets completed")
        }
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
                                .joined(separator: " â¢ ")

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

                            let combined = parts.isEmpty ? "Conditioning" : parts.joined(separator: " â¢ ")

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

            return RunWeekState(index: weekIndex, days: dayStates)
        }
    }

    // MARK: - Persistence

    private static func persistenceURL(for blockId: BlockID) -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("runstate-\(blockId.uuidString).json")
    }

    private static func loadPersistedWeeks(for blockId: BlockID) -> [RunWeekState]? {
        let url = persistenceURL(for: blockId)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([RunWeekState].self, from: data)
        } catch {
            print("â ï¸ Failed to load RunWeekState for block \(blockId): \(error)")
            return nil
        }
    }

    private static func saveWeeks(_ weeks: [RunWeekState], for blockId: BlockID) {
        let url = persistenceURL(for: blockId)
        let backupURL = url.deletingLastPathComponent().appendingPathComponent("runstate-\(blockId.uuidString).backup.json")
        
        print("🔵 Static saveWeeks() called for block \(blockId)")
        print("🔵 Saving to: \(url.path)")
        
        do {
            // Create backup of existing file before overwriting
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: backupURL)
                try? FileManager.default.copyItem(at: url, to: backupURL)
                print("🔵 Created backup at: \(backupURL.path)")
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(weeks)
            
            print("🔵 Encoded \(data.count) bytes of data")
            
            // Validate data before writing by decoding it back
            let validated = try JSONDecoder().decode([RunWeekState].self, from: data)
            print("🔵 Validation successful - decoded \(validated.count) weeks")
            
            // Additional validation: compare counts
            if validated.count != weeks.count {
                let error = "Week count validation failed: decoded \(validated.count) weeks but expected \(weeks.count)"
                print("❌ ERROR: \(error)")
                throw NSError(domain: "BlockRunModeView", code: 1, userInfo: [NSLocalizedDescriptionKey: error])
            }
            
            // Validate set completion status is preserved
            for (idx, week) in validated.enumerated() {
                let originalCompleted = weeks[idx].days.flatMap { $0.exercises }.flatMap { $0.sets }.filter { $0.isCompleted }.count
                let validatedCompleted = week.days.flatMap { $0.exercises }.flatMap { $0.sets }.filter { $0.isCompleted }.count
                if originalCompleted != validatedCompleted {
                    let error = "Week \(idx) set completion validation failed: original \(originalCompleted) sets, validated \(validatedCompleted) sets"
                    print("❌ ERROR: \(error)")
                    throw NSError(domain: "BlockRunModeView", code: 2, userInfo: [NSLocalizedDescriptionKey: error])
                }
            }
            
            // Write atomically to prevent corruption
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            print("✅ Successfully saved state for block \(blockId): \(weeks.count) weeks, \(data.count) bytes")
            
            // Clean up old backup after successful write
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try? FileManager.default.removeItem(at: backupURL)
            }
        } catch let encodingError as EncodingError {
            print("⚠️ Failed to encode RunWeekState for block \(blockId): \(encodingError)")
            restoreFromBackup(from: backupURL, to: url, for: blockId)
        } catch {
            print("⚠️ Failed to save RunWeekState for block \(blockId): \(error)")
            restoreFromBackup(from: backupURL, to: url, for: blockId)
        }
    }
    
    private static func restoreFromBackup(from backupURL: URL, to url: URL, for blockId: BlockID) {
        if FileManager.default.fileExists(atPath: backupURL.path) {
            print("🔄 Attempting to restore run state for block \(blockId) from backup...")
            do {
                try FileManager.default.copyItem(at: backupURL, to: url)
                print("✅ Successfully restored run state from backup")
            } catch {
                print("❌ Failed to restore run state from backup: \(error)")
            }
        }
    }
} // <--- BlockRunModeView ends here

// MARK: - Week View

struct WeekRunView: View {
    @Binding var week: RunWeekState
    let allDays: [DayTemplate]
    @Binding var currentDayIndex: Int
    let onSave: () -> Void

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
            DayRunView(day: $week.days[currentDayIndex], onSave: onSave)
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
    let onSave: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach($day.exercises) { $exercise in
                    ExerciseRunCard(exercise: $exercise, onSave: onSave)
                }

                Button {
                    let newExerciseIndex = day.exercises.count + 1
                    let newExercise = RunExerciseState(
                        name: "New Exercise \(newExerciseIndex)",
                        type: .strength,
                        notes: "",
                        sets: [
                            RunSetState(
                                indexInExercise: 0,
                                displayText: "Set 1",
                                type: .strength
                            )
                        ]
                    )
                    day.exercises.append(newExercise)
                    onSave()
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
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Editable exercise name
            TextField("Exercise name", text: $exercise.name)
                .font(.headline)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .onChange(of: exercise.name) { _, _ in
                    onSave()
                }

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
                .onChange(of: exercise.notes) { _, _ in
                    onSave()
                }

            // Sets
            ForEach($exercise.sets) { $set in
                SetRunRow(runSet: $set, onSave: onSave)

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
                    onSave()
                } label: {
                    Label("Add Set", systemImage: "plus")
                        .font(.caption.bold())
                }

                Spacer()

                if exercise.sets.count > 1 {
                    Button {
                        _ = exercise.sets.popLast()
                        onSave()
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

// MARK: - Helper Struct for Reusability (SetControlView is imported from SetControls.swift)

struct SetRunRow: View {
    @Binding var runSet: RunSetState
    let onSave: () -> Void

    // Strength helpers (keeping these for clarity, though not directly used in the new UI)
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

    // Common formatter for whole numbers (Reps, Rounds, Minutes)
    private static let integerFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.maximumFractionDigits = 0
        f.minimumFractionDigits = 0
        return f
    }()

    // Common formatter for weight (allows one decimal for precision, but minimal 0)
    private static let weightFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.maximumFractionDigits = 1
        f.minimumFractionDigits = 0
        return f
    }()


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
                        onSave()
                    }
                    .font(.caption)
                } else {
                    Button("Complete") {
                        runSet.isCompleted = true
                        onSave()
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
        .onChange(of: runSet.actualReps) { _, _ in
            onSave()
        }
        .onChange(of: runSet.actualWeight) { _, _ in
            onSave()
        }
        .onChange(of: runSet.actualTimeSeconds) { _, _ in
            onSave()
        }
        .onChange(of: runSet.actualDistanceMeters) { _, _ in
            onSave()
        }
        .onChange(of: runSet.actualCalories) { _, _ in
            onSave()
        }
        .onChange(of: runSet.actualRounds) { _, _ in
            onSave()
        }
    }

    // MARK: - Strength UI (Modified to use VStack and SetControlView)

    private var strengthControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Reps Control
            SetControlView(
                label: "REPETITIONS",
                unit: "reps",
                // FIX: Used the correct call to the extension method
                value: $runSet.actualReps.toDouble(),
                step: 1.0,
                formatter: Self.integerFormatter,
                min: 0.0
            )

            // Weight Control
            SetControlView(
                label: "WEIGHT",
                unit: "lb",
                value: $runSet.actualWeight,
                step: 5.0,
                formatter: Self.weightFormatter,
                min: 0.0
            )
        }
    }

    // MARK: - Conditioning UI (Modified to use SetControlView where possible)

    private var conditioningControls: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Time (minutes) - Kept original implementation to avoid complex secondary binding
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


            // Calories Control
            SetControlView(
                label: "CALORIES",
                unit: "cal",
                value: $runSet.actualCalories,
                step: 5.0,
                formatter: Self.integerFormatter,
                min: 0.0
            )

            // Rounds Control
            SetControlView(
                label: "ROUNDS",
                unit: "rounds",
                // FIX: Used the correct call to the extension method
                value: $runSet.actualRounds.toDouble(),
                step: 1.0,
                formatter: Self.integerFormatter,
                min: 0.0
            )
        }
    }
}

// MARK: - Run State Models (No changes here)

struct RunWeekState: Identifiable, Codable {
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

struct RunDayState: Identifiable, Codable{
    let id = UUID()
    let name: String
    let shortCode: String
    var exercises: [RunExerciseState]
}

struct RunExerciseState: Identifiable, Codable {
    let id = UUID()
    var name: String
    let type: ExerciseType
    var notes: String
    var sets: [RunSetState]
}

struct RunSetState: Identifiable, Codable {
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


// MARK: - BINDING EXTENSIONS (Imported from SetControls.swift)

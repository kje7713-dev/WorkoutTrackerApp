import SwiftUI

// MARK: - Run Mode Errors

enum BlockRunModeError: Error, LocalizedError {
    case weekCountMismatch(expected: Int, actual: Int)
    case setCompletionMismatch(week: Int, expected: Int, actual: Int)
    case saveVerificationFailed(expected: Int, actual: Int)
    case totalSetCountMismatch(expected: Int, actual: Int)
    case saveVerificationUnableToReload
    
    var errorDescription: String? {
        switch self {
        case .weekCountMismatch(let expected, let actual):
            return "Week count validation failed: expected \(expected) weeks but got \(actual)"
        case .setCompletionMismatch(let week, let expected, let actual):
            return "Week \(week) set completion validation failed: expected \(expected) completed sets but got \(actual)"
        case .saveVerificationFailed(let expected, let actual):
            return "Save verification failed. Expected \(expected) completed sets but found \(actual). Please try closing again."
        case .totalSetCountMismatch(let expected, let actual):
            return "Save verification failed. Total set count mismatch (expected \(expected), got \(actual)). Please try closing again."
        case .saveVerificationUnableToReload:
            return "Could not verify save. Please try closing the session again."
        }
    }
}

// MARK: - Run Mode Container

struct BlockRunModeView: View {
    let block: Block
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sessionsRepository: SessionsRepository

    @State private var weeks: [RunWeekState] = []
    @State private var currentWeekIndex: Int = 0
    @State private var currentDayIndex: Int = 0

    @State private var lastCommittedWeekIndex: Int = 0
    @State private var pendingWeekIndex: Int? = nil
    @State private var showSkipAlert: Bool = false
    @State private var showCloseConfirmation: Bool = false
    @State private var saveError: Error? = nil
    @State private var showSaveError: Bool = false
    @State private var backgroundSaveError: Error? = nil
    
    // Week completion modal state
    @State private var showWeekCompletionModal: Bool = false
    @State private var recentlyCompletedWeekIndex: Int? = nil

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
                }) { oldValue, newValue in
                    print("🔵 Set completion changed - auto-saving")
                    
                    // Capture previous state for week completion detection
                    let previousWeeks = weeks
                    
                    // Perform the save
                    saveWeeks()
                    
                    // Check for week completion after save
                    checkForWeekCompletion(previousWeeks: previousWeeks, currentWeeks: weeks)
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
        .onAppear {
            initializeWeeks()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    print("🔵 Toolbar 'Close Session' button pressed")
                    showCloseConfirmation = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Close Session")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.accentColor)
                }
                .accessibilityLabel("Close Session")
                .accessibilityHint("Saves all progress and closes the workout session")
            }
        }
        .alert("Close Workout Session?", isPresented: $showCloseConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Save & Close") {
                closeSessionWithSave()
            }
        } message: {
            Text("Your progress will be saved before closing.")
        }
        .alert("Save Error", isPresented: $showSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = saveError {
                Text("Failed to save workout session: \(error.localizedDescription)")
            } else {
                Text("An unknown error occurred while saving.")
            }
        }
        .onDisappear {
            print("🔵 BlockRunModeView onDisappear - performing final save")
            // Ensure state is saved even if view is dismissed programmatically
            // Use the instance saveWeeks() method for consistent error handling
            saveWeeks()
            // Note: Errors from saveWeeks are logged but cannot be shown to user
            // since the view is already disappearing
            if let error = saveError {
                backgroundSaveError = error
            }
        }
        .overlay {
            if showWeekCompletionModal, let weekIndex = recentlyCompletedWeekIndex {
                WeekCompletionModal(weekNumber: weekIndex + 1) {
                    showWeekCompletionModal = false
                    recentlyCompletedWeekIndex = nil
                }
            }
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

    // MARK: - Initialization
    
    /// Initialize weeks from SessionsRepository or generate new sessions if none exist
    private func initializeWeeks() {
        print("🔵 Initializing weeks from SessionsRepository for block \(block.id)")
        
        // Load sessions for this block from repository
        var blockSessions = sessionsRepository.sessions(forBlockId: block.id)
        
        // If no sessions exist, generate them
        if blockSessions.isEmpty {
            print("🔵 No sessions found, generating new sessions via SessionFactory")
            let factory = SessionFactory()
            blockSessions = factory.makeSessions(for: block)
            
            // Save the generated sessions to repository
            sessionsRepository.replaceSessions(forBlockId: block.id, with: blockSessions)
            print("✅ Generated and saved \(blockSessions.count) sessions")
        }
        
        // Convert sessions to run state
        weeks = RunStateMapper.sessionsToRunWeeks(blockSessions, block: block)
        print("✅ Initialized \(weeks.count) weeks from sessions")
    }
    
    // MARK: - Save Helpers
    
    /// Performs an immediate synchronous save to repository.
    /// This is called by onChange handlers, toolbar buttons, and view lifecycle events.
    private func saveWeeks() {
        print("🔵 Instance saveWeeks() called - saving to SessionsRepository")
        validateAndLogWeeksData()
        
        // Get original sessions from repository
        let originalSessions = sessionsRepository.sessions(forBlockId: block.id)
        
        // Convert run state back to sessions
        let updatedSessions = RunStateMapper.runWeeksToSessions(
            weeks,
            originalSessions: originalSessions,
            block: block
        )
        
        // Replace sessions in repository
        sessionsRepository.replaceSessions(forBlockId: block.id, with: updatedSessions)
        print("✅ Saved \(updatedSessions.count) sessions to repository")
    }
    
    /// Closes the session with robust save confirmation.
    /// Shows error alert if save fails, otherwise dismisses the view.
    private func closeSessionWithSave() {
        print("🔵 closeSessionWithSave() called - performing final save before close")
        validateAndLogWeeksData()
        
        // Cache data structure metrics before save for verification
        let originalMetrics = computeDataMetrics(for: weeks)
        
        // Perform the save
        saveWeeks()
        
        // Verify the save by reloading from repository
        let reloadedSessions = sessionsRepository.sessions(forBlockId: block.id)
        let reloadedWeeks = RunStateMapper.sessionsToRunWeeks(reloadedSessions, block: block)
        let reloadedMetrics = computeDataMetrics(for: reloadedWeeks)
        
        // Verify multiple data integrity checks
        if originalMetrics.weekCount != reloadedMetrics.weekCount {
            print("❌ Week count mismatch - showing error to user")
            saveError = BlockRunModeError.weekCountMismatch(expected: originalMetrics.weekCount, actual: reloadedMetrics.weekCount)
            showSaveError = true
        } else if originalMetrics.completedSetCount != reloadedMetrics.completedSetCount {
            print("❌ Completed set count mismatch - showing error to user")
            saveError = BlockRunModeError.saveVerificationFailed(expected: originalMetrics.completedSetCount, actual: reloadedMetrics.completedSetCount)
            showSaveError = true
        } else if originalMetrics.totalSetCount != reloadedMetrics.totalSetCount {
            print("❌ Total set count mismatch - showing error to user")
            saveError = BlockRunModeError.totalSetCountMismatch(expected: originalMetrics.totalSetCount, actual: reloadedMetrics.totalSetCount)
            showSaveError = true
        } else {
            print("✅ Save verification successful: \(originalMetrics.completedSetCount) completed sets")
            // Verification passed, safe to dismiss
            dismiss()
        }
    }
    
    /// Data structure for holding verification metrics
    private struct DataMetrics {
        let weekCount: Int
        let totalSetCount: Int
        let completedSetCount: Int
    }
    
    /// Computes data metrics for verification in a single pass
    private func computeDataMetrics(for weeks: [RunWeekState]) -> DataMetrics {
        var totalSets = 0
        var completedSets = 0
        
        for week in weeks {
            for day in week.days {
                for exercise in day.exercises {
                    for set in exercise.sets {
                        totalSets += 1
                        if set.isCompleted {
                            completedSets += 1
                        }
                    }
                }
            }
        }
        
        return DataMetrics(
            weekCount: weeks.count,
            totalSetCount: totalSets,
            completedSetCount: completedSets
        )
    }
    
    /// Validates and logs the current weeks data structure to help diagnose save issues.
    private func validateAndLogWeeksData() {
        let metrics = computeDataMetrics(for: weeks)
        print("🔵 Validating weeks data before save:")
        print("   - Total weeks: \(metrics.weekCount)")
        print("   - Total sets: \(metrics.totalSetCount)")
        print("   - Completed sets: \(metrics.completedSetCount)")
        
        // Log individual week details for debugging (single pass)
        for (weekIdx, week) in weeks.enumerated() {
            var weekTotalSets = 0
            var weekCompletedSets = 0
            for day in week.days {
                for exercise in day.exercises {
                    for set in exercise.sets {
                        weekTotalSets += 1
                        if set.isCompleted {
                            weekCompletedSets += 1
                        }
                    }
                }
            }
            print("   - Week \(weekIdx): \(weekCompletedSets)/\(weekTotalSets) sets completed")
        }
    }
    
    // MARK: - Week Completion Detection
    
    /// Checks for week completion transitions (false -> true) and shows modal if detected.
    /// Called after set completion changes to detect when a week becomes fully completed.
    ///
    /// - Parameters:
    ///   - previousWeeks: The week states before the change
    ///   - currentWeeks: The week states after the change
    private func checkForWeekCompletion(previousWeeks: [RunWeekState], currentWeeks: [RunWeekState]) {
        guard previousWeeks.count == currentWeeks.count else {
            // Week count changed, skip detection
            return
        }
        
        // Check each week for completion transition
        for (index, currentWeek) in currentWeeks.enumerated() {
            let previousWeek = previousWeeks[index]
            
            // Detect transition from incomplete to complete
            if !previousWeek.isCompleted && currentWeek.isCompleted {
                print("✅ Week \(index + 1) just completed!")
                recentlyCompletedWeekIndex = index
                showWeekCompletionModal = true
                // Only show modal for the first detected completion in this batch
                return
            }
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


    // MARK: - Old Persistence (DISABLED - Now using SessionsRepository)
    
    // NOTE: The old runstate-*.json file persistence has been disabled.
    // All workout session data is now persisted via SessionsRepository to sessions.json.
    // This provides a single source of truth for all workout data.
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
    
    @State private var showExerciseTypeSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach($day.exercises) { $exercise in
                    ExerciseRunCard(exercise: $exercise, onSave: onSave)
                }

                Button {
                    showExerciseTypeSheet = true
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
        .confirmationDialog("Select Exercise Type", isPresented: $showExerciseTypeSheet) {
            Button("Strength") {
                addExercise(type: .strength)
            }
            Button("Conditioning") {
                addExercise(type: .conditioning)
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - Helper Functions
    
    private func addExercise(type: ExerciseType) {
        let newExerciseIndex = day.exercises.count + 1
        let newExercise = RunExerciseState(
            name: "New Exercise \(newExerciseIndex)",
            type: type,
            notes: "",
            sets: [
                RunSetState(
                    indexInExercise: 0,
                    displayText: "Set 1",
                    type: type
                )
            ]
        )
        day.exercises.append(newExercise)
        onSave()
    }
}

struct ExerciseRunCard: View {
    @Binding var exercise: RunExerciseState
    let onSave: () -> Void
    
    @State private var showTypeChangeConfirmation = false
    @State private var pendingNewType: ExerciseType?

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

            // Exercise type picker
            Picker("Type", selection: Binding(
                get: { exercise.type },
                set: { newType in
                    // Check if there are any completed sets or logged values
                    let hasProgress = exercise.sets.contains { set in
                        set.isCompleted ||
                        set.actualReps != nil ||
                        set.actualWeight != nil ||
                        set.actualTimeSeconds != nil ||
                        set.actualDistanceMeters != nil ||
                        set.actualCalories != nil ||
                        set.actualRounds != nil
                    }
                    
                    if hasProgress && newType != exercise.type {
                        pendingNewType = newType
                        showTypeChangeConfirmation = true
                    } else {
                        updateExerciseType(to: newType)
                    }
                }
            )) {
                Text("Strength").tag(ExerciseType.strength)
                Text("Conditioning").tag(ExerciseType.conditioning)
            }
            .pickerStyle(.segmented)

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
                    let newSet = createNewSet(
                        indexInExercise: newIndex,
                        exerciseType: exercise.type,
                        previousSets: exercise.sets
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
        .alert("Change Exercise Type?", isPresented: $showTypeChangeConfirmation) {
            Button("Cancel", role: .cancel) {
                pendingNewType = nil
            }
            Button("Change Type") {
                if let newType = pendingNewType {
                    updateExerciseType(to: newType)
                    pendingNewType = nil
                }
            }
        } message: {
            Text("Changing the exercise type will reset all sets and lose logged values. This cannot be undone.")
        }
    }
    
    // MARK: - Helper Functions
    
    /// Updates the exercise type and regenerates sets with the new type
    private func updateExerciseType(to newType: ExerciseType) {
        // Store the current set count
        let currentSetCount = exercise.sets.count
        
        // Update the exercise type
        exercise.type = newType
        
        // Regenerate all sets with the new type
        exercise.sets = (0..<currentSetCount).map { index in
            RunSetState(
                indexInExercise: index,
                displayText: "Set \(index + 1)",
                type: newType
            )
        }
        
        onSave()
    }
    
    // MARK: - Helper: Create New Set with Prefilled Values
    
    /// Creates a new set, prefilling weight/reps from the most recent set if available.
    /// Falls back to default values if no previous sets exist.
    private func createNewSet(
        indexInExercise: Int,
        exerciseType: ExerciseType,
        previousSets: [RunSetState]
    ) -> RunSetState {
        // Find the most recent set (last in the array)
        guard let lastSet = previousSets.last else {
            // No previous sets - use default values
            return RunSetState(
                indexInExercise: indexInExercise,
                displayText: "Set \(indexInExercise + 1)",
                type: exerciseType
            )
        }
        
        // Copy values from the most recent set based on exercise type
        switch exerciseType {
        case .strength:
            return RunSetState(
                indexInExercise: indexInExercise,
                displayText: buildDisplayText(
                    reps: lastSet.actualReps,
                    weight: lastSet.actualWeight
                ),
                type: exerciseType,
                plannedReps: lastSet.plannedReps,
                plannedWeight: lastSet.plannedWeight,
                actualReps: lastSet.actualReps,
                actualWeight: lastSet.actualWeight
            )
            
        case .conditioning:
            return RunSetState(
                indexInExercise: indexInExercise,
                displayText: buildConditioningDisplayText(
                    time: lastSet.actualTimeSeconds,
                    distance: lastSet.actualDistanceMeters,
                    calories: lastSet.actualCalories,
                    rounds: lastSet.actualRounds
                ),
                type: exerciseType,
                plannedTimeSeconds: lastSet.plannedTimeSeconds,
                plannedDistanceMeters: lastSet.plannedDistanceMeters,
                plannedCalories: lastSet.plannedCalories,
                plannedRounds: lastSet.plannedRounds,
                actualTimeSeconds: lastSet.actualTimeSeconds,
                actualDistanceMeters: lastSet.actualDistanceMeters,
                actualCalories: lastSet.actualCalories,
                actualRounds: lastSet.actualRounds
            )
            
        case .mixed, .other:
            // For mixed and other types, use default values
            // Mixed types should be handled by the UI allowing users to specify values manually
            return RunSetState(
                indexInExercise: indexInExercise,
                displayText: "Set \(indexInExercise + 1)",
                type: exerciseType
            )
        }
    }
    
    /// Builds display text for strength sets
    private func buildDisplayText(reps: Int?, weight: Double?) -> String {
        let repsText = reps.map { "Reps: \($0)" } ?? ""
        let weightText = weight.map { "Weight: \($0)" } ?? ""
        let parts = [repsText, weightText].filter { !$0.isEmpty }
        return parts.isEmpty ? "Strength set" : parts.joined(separator: " • ")
    }
    
    /// Builds display text for conditioning sets
    private func buildConditioningDisplayText(
        time: Double?,
        distance: Double?,
        calories: Double?,
        rounds: Int?
    ) -> String {
        var parts: [String] = []
        
        if let dur = time.map({ Int($0) }) {
            if dur % 60 == 0 {
                let mins = dur / 60
                parts.append("\(mins) min")
            } else {
                parts.append("\(dur) sec")
            }
        }
        if let dist = distance {
            parts.append("\(Int(dist)) m")
        }
        if let cal = calories {
            parts.append("\(Int(cal)) cal")
        }
        if let rnds = rounds {
            parts.append("\(rnds) rounds")
        }
        
        return parts.isEmpty ? "Conditioning" : parts.joined(separator: " • ")
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
        .onChange(of: runSet.isCompleted) { _, _ in
            print("🔵 Set isCompleted changed - triggering save")
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
    var type: ExerciseType
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

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
    @EnvironmentObject var subscriptionManager: SubscriptionManager

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
    
    // Completion modal state
    @State private var showWeekCompletionModal: Bool = false
    @State private var showBlockCompletionModal: Bool = false
    @State private var recentlyCompletedWeekIndex: Int? = nil
    
    // Whiteboard view mode
    @State private var showWhiteboard: Bool = false
    
    // Paywall state
    @State private var showingPaywall: Bool = false

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
                            currentDayIndex: $currentDayIndex,
                            onSave: saveWeeks,
                            block: block
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
                .alert("You can skip • but champions don't.", isPresented: $showSkipAlert) {
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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if subscriptionManager.hasAccess {
                        showWhiteboard = true
                    } else {
                        showingPaywall = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        if !subscriptionManager.hasAccess {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Image(systemName: "rectangle.and.text.magnifyingglass")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Whiteboard")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.accentColor)
                }
                .accessibilityLabel(subscriptionManager.hasAccess ? "View Whiteboard" : "View Whiteboard (Pro Feature)")
                .accessibilityHint("Open full-screen whiteboard view for current day")
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
        .overlay(
            Group {
                if showWeekCompletionModal || showBlockCompletionModal {
                    WeekCompletionModal(
                        title: showBlockCompletionModal ? "BLOCK COMPLETE" : "WEEK COMPLETE",
                        message: showBlockCompletionModal ? "Fuck yeah — block built." : "Solid work — keep grinding.",
                        isBlockCompletion: showBlockCompletionModal,
                        onDismiss: {
                            DispatchQueue.main.async {
                                showBlockCompletionModal = false
                                showWeekCompletionModal = false
                                recentlyCompletedWeekIndex = nil
                            }
                        }
                    )
                    .transition(.opacity)
                }
            }
        )
        .animation(.easeInOut(duration: 0.3), value: showWeekCompletionModal)
        .animation(.easeInOut(duration: 0.3), value: showBlockCompletionModal)
        .fullScreenCover(isPresented: $showWhiteboard) {
            WhiteboardFullScreenDayView(
                unifiedBlock: BlockNormalizer.normalize(block: block),
                weekIndex: currentWeekIndex,
                dayIndex: currentDayIndex
            )
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(subscriptionManager)
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

            // Full day name (primary) - get from current week's state
            let fullDay: String = {
                guard weeks.indices.contains(currentWeekIndex),
                      weeks[currentWeekIndex].days.indices.contains(currentDayIndex) else { return "" }
                return weeks[currentWeekIndex].days[currentDayIndex].name
            }()

            Text(fullDay)
                .font(.headline)
                .fontWeight(.semibold)

            // Short code + week in secondary role - get from current week's state
            let short: String = {
                guard weeks.indices.contains(currentWeekIndex),
                      weeks[currentWeekIndex].days.indices.contains(currentDayIndex) else { return "" }
                return weeks[currentWeekIndex].days[currentDayIndex].shortCode
            }()

            Text("Week \(currentWeekIndex + 1) • \(short.uppercased())")
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
        
        // Set currentWeekIndex to the first incomplete week (auto-navigate to active week)
        currentWeekIndex = findActiveWeekIndex()
        print("🔵 Set currentWeekIndex to \(currentWeekIndex) (active week)")
    }
    
    /// Find the index of the first incomplete week, or the last week if all are complete
    /// This is the "active" week where the user should resume training
    /// - Returns: 0-based index of the active week, or 0 if weeks array is empty
    private func findActiveWeekIndex() -> Int {
        // Handle empty weeks array
        guard !weeks.isEmpty else {
            return 0
        }
        
        // Find the first week that is not completed
        if let firstIncompleteIndex = weeks.firstIndex(where: { !$0.isCompleted }) {
            return firstIncompleteIndex
        }
        
        // If all weeks are completed, return the last week
        // This allows users to review their completed work
        return weeks.count - 1
    }
    
    // MARK: - Save Helpers
    
    /// Performs an immediate synchronous save to repository.
    /// This is called by onChange handlers, toolbar buttons, and view lifecycle events.
    private func saveWeeks() {
        print("🔵 Instance saveWeeks() called - saving to SessionsRepository")
        validateAndLogWeeksData()
        
        // Get original sessions from repository and convert to weeks for comparison
        let originalSessions = sessionsRepository.sessions(forBlockId: block.id)
        let previousWeeks = RunStateMapper.sessionsToRunWeeks(originalSessions, block: block)
        
        // Convert run state back to sessions
        let updatedSessions = RunStateMapper.runWeeksToSessions(
            weeks,
            originalSessions: originalSessions,
            block: block
        )
        
        // Replace sessions in repository
        sessionsRepository.replaceSessions(forBlockId: block.id, with: updatedSessions)
        print("✅ Saved \(updatedSessions.count) sessions to repository")
        
        // Check for completion transitions after successful save
        checkForCompletionTransition(
            previousWeeks: previousWeeks,
            currentWeeks: weeks,
            block: block
        )
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
    
    /// Checks for completion transitions and shows appropriate modals
    /// - Parameters:
    ///   - previousWeeks: Week state before the change
    ///   - currentWeeks: Week state after the change
    ///   - block: The current training block
    private func checkForCompletionTransition(
        previousWeeks: [RunWeekState],
        currentWeeks: [RunWeekState],
        block: Block
    ) {
        // Find the first week that transitioned from incomplete to complete
        for (index, currentWeek) in currentWeeks.enumerated() {
            guard index < previousWeeks.count else { continue }
            
            let previousWeek = previousWeeks[index]
            let wasCompleted = previousWeek.isCompleted
            let isNowCompleted = currentWeek.isCompleted
            
            // Detect transition from incomplete to complete
            if !wasCompleted && isNowCompleted {
                print("🎉 Week \(index) just completed!")
                recentlyCompletedWeekIndex = index
                
                // Check if all weeks are now completed (block completion)
                let allWeeksCompleted = currentWeeks.allSatisfy { $0.isCompleted }
                let hadIncompleteWeeks = !previousWeeks.allSatisfy { $0.isCompleted }
                
                if allWeeksCompleted && hadIncompleteWeeks {
                    print("🎉🎉 BLOCK COMPLETED! All weeks are done!")
                    // Block completion takes precedence
                    showBlockCompletionModal = true
                    showWeekCompletionModal = false
                } else {
                    print("🎉 Week completed (block not yet complete)")
                    showWeekCompletionModal = true
                }
                
                // Only show modal for the first completed week found in this save
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
            // Determine which day templates to use for this week
            let dayTemplates: [DayTemplate]
            
            if let weekTemplates = block.weekTemplates, !weekTemplates.isEmpty {
                // Week-specific mode: use templates for this specific week
                if weekIndex < weekTemplates.count {
                    dayTemplates = weekTemplates[weekIndex]
                } else {
                    // Fallback: If numberOfWeeks exceeds weekTemplates.count, repeat the last week's template
                    dayTemplates = weekTemplates.last ?? block.days
                }
            } else {
                // Standard mode: replicate block.days for all weeks
                dayTemplates = block.days
            }
            
            let dayStates: [RunDayState] = dayTemplates.map { day in
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
                                .joined(separator: " • ")

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
                                // Use HH:MM:SS format
                                parts.append(TimeFormatter.formatTime(dur))
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

                            let combined = parts.isEmpty ? "Conditioning" : parts.joined(separator: " • ")

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
                        sets: sets,
                        setGroupId: exercise.setGroupId,
                        videoUrls: exercise.videoUrls
                    )
                }
                
                // Build segment states if segments are present
                let segmentStates: [RunSegmentState]? = day.segments?.map { segment in
                    let drillItemNames = segment.drillPlan?.items.map { $0.name } ?? []
                    
                    // Extract technique names for summary
                    let techniqueNames = segment.techniques.map { $0.name }
                    
                    // Extract safety notes
                    let safetyNotes = segment.safety?.contraindications ?? []
                    
                    // Extract partner goals
                    let attackerGoal = segment.partnerPlan?.roles?.attackerGoal ?? segment.roles?.attackerGoal
                    let defenderGoal = segment.partnerPlan?.roles?.defenderGoal ?? segment.roles?.defenderGoal
                    
                    // Extract resistance level
                    let resistance = segment.partnerPlan?.resistance ?? segment.resistance
                    
                    // Extract quality targets
                    let targetSuccessRate = segment.partnerPlan?.qualityTargets?.successRateTarget ?? segment.qualityTargets?.successRateTarget
                    let targetCleanReps = segment.partnerPlan?.qualityTargets?.cleanRepsTarget ?? segment.qualityTargets?.cleanRepsTarget
                    
                    return RunSegmentState(
                        segmentId: segment.id,
                        name: segment.name,
                        segmentType: segment.segmentType,
                        durationMinutes: segment.durationMinutes,
                        objective: segment.objective,
                        notes: segment.notes,
                        totalRounds: segment.roundPlan?.rounds ?? segment.partnerPlan?.rounds,
                        roundDurationSeconds: segment.roundPlan?.roundDurationSeconds ?? segment.partnerPlan?.roundDurationSeconds,
                        restSeconds: segment.roundPlan?.restSeconds ?? segment.partnerPlan?.restSeconds,
                        drillItems: drillItemNames,
                        techniqueNames: techniqueNames,
                        coachingCues: segment.coachingCues,
                        constraints: segment.constraints,
                        attackerGoal: attackerGoal,
                        defenderGoal: defenderGoal,
                        resistance: resistance,
                        targetSuccessRate: targetSuccessRate,
                        targetCleanReps: targetCleanReps,
                        safetyNotes: safetyNotes
                    )
                }

                return RunDayState(
                    name: day.name,
                    shortCode: day.shortCode ?? "",
                    exercises: exerciseStates,
                    segments: segmentStates
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
    @Binding var currentDayIndex: Int
    let onSave: () -> Void
    let block: Block

    var body: some View {
        VStack(spacing: 0) {
            // Week completion toggle banner
            weekCompletionBanner
            
            DayTabBar(days: week.days, currentDayIndex: $currentDayIndex)
            Divider()
            content
        }
    }
    
    private var weekCompletionBanner: some View {
        HStack {
            Text("Week \(week.index + 1)")
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                if week.weekCompletedAt != nil {
                    // Uncomplete the week
                    week.weekCompletedAt = nil
                } else {
                    // Complete the week
                    week.weekCompletedAt = Date()
                }
                onSave()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: week.weekCompletedAt != nil ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(week.weekCompletedAt != nil ? .green : .gray)
                    
                    Text(week.weekCompletedAt != nil ? "Week Complete" : "Mark Week Complete")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .accessibilityLabel(week.weekCompletedAt != nil ? "Unmark week as complete" : "Mark week as complete")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            week.weekCompletedAt != nil
                ? Color.green.opacity(0.1)
                : Color(.systemBackground)
        )
    }

    @ViewBuilder
    private var content: some View {
        if week.days.indices.contains(currentDayIndex) {
            DayRunView(
                day: $week.days[currentDayIndex],
                onSave: onSave,
                block: block,
                weekIndex: week.index,
                dayIndex: currentDayIndex
            )
        } else {
            Text("No days configured for this week.")
                .padding()
        }
    }
}

// MARK: - Day Tabs

struct DayTabBar: View {
    let days: [RunDayState]
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

    private func dayButton(for day: RunDayState, index: Int) -> some View {
        let isSelected = index == currentDayIndex
        let label: String

        if !day.shortCode.isEmpty {
            label = day.shortCode
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
    let block: Block
    let weekIndex: Int
    let dayIndex: Int
    
    @EnvironmentObject var blocksRepository: BlocksRepository
    @EnvironmentObject var sessionsRepository: SessionsRepository
    @EnvironmentObject var exerciseLibrary: ExerciseLibraryRepository
    
    @State private var showExerciseTypeSheet = false
    @State private var persistToFutureWeeks = false
    
    // Constants for superset group styling
    private let supersetBackgroundOpacityDark: Double = 0.3
    private let supersetBackgroundOpacityLight: Double = 0.5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Render segments if present
                if let segments = day.segments, !segments.isEmpty {
                    ForEach(bindingsForSegments(segments)) { $segment in
                        SegmentRunCard(segment: $segment, onSave: onSave)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                    }
                }
                
                // Group exercises by setGroupId and render them
                let groups = groupExercises(day.exercises)
                
                // Calculate superset group labels upfront
                var supersetLabels: [Int: String] = [:]
                var supersetIndex = 0
                for (index, group) in groups.enumerated() {
                    if group.groupId != nil {
                        // This is a superset group, assign it a letter (A, B, C, etc.)
                        // Supports A-Z (26 groups), then AA-AZ (27-52), BA-BZ (53-78), etc.
                        if supersetIndex < 26 {
                            // Single letter: A-Z
                            supersetLabels[index] = String(Character(UnicodeScalar(65 + supersetIndex)!))
                        } else {
                            // Double letter: AA, AB, AC... (Excel-style column naming)
                            let offset = supersetIndex - 26
                            let firstLetter = Character(UnicodeScalar(65 + (offset / 26))!)
                            let secondLetter = Character(UnicodeScalar(65 + (offset % 26))!)
                            supersetLabels[index] = "\(firstLetter)\(secondLetter)"
                        }
                        supersetIndex += 1
                    }
                }
                
                ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
                    if let groupId = group.groupId, let groupLabel = supersetLabels[index] {
                        // Superset/Circuit group
                        SupersetGroupView(
                            exercises: bindingsForExercises(group.exercises),
                            groupId: groupId,
                            groupLabel: groupLabel,
                            onSave: onSave,
                            backgroundOpacity: supersetBackgroundOpacityDark,
                            backgroundOpacityLight: supersetBackgroundOpacityLight
                        )
                    } else {
                        // Individual exercises
                        ForEach(bindingsForExercises(group.exercises)) { $exercise in
                            ExerciseRunCard(exercise: $exercise, onSave: onSave)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                )
                        }
                    }
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
        .sheet(isPresented: $showExerciseTypeSheet) {
            AddExerciseSheet(
                persistToFutureWeeks: $persistToFutureWeeks,
                canPersist: weekIndex < (block.numberOfWeeks - 1),
                onAddExercise: { type, name in
                    addExercise(type: type, name: name)
                    showExerciseTypeSheet = false
                }
            )
        }
    }
    
    // MARK: - Helper Functions
    
    private func bindingsForSegments(_ segments: [RunSegmentState]) -> [Binding<RunSegmentState>] {
        segments.indices.map { index in
            Binding(
                get: { day.segments![index] },
                set: { day.segments![index] = $0; onSave() }
            )
        }
    }
    
    private func addExercise(type: ExerciseType, name: String) {
        let newExercise = RunExerciseState(
            name: name,
            type: type,
            notes: "",
            sets: [
                RunSetState(
                    indexInExercise: 0,
                    displayText: "Set 1",
                    type: type
                )
            ],
            setGroupId: nil,  // New exercises don't belong to a group
            videoUrls: nil
        )
        day.exercises.append(newExercise)
        
        // If user chose to persist, add to block template and future sessions
        if persistToFutureWeeks {
            addExerciseToBlockTemplate(type: type, name: name)
        }
        
        onSave()
        
        // Reset the toggle for next time
        persistToFutureWeeks = false
    }
    
    private func addExerciseToBlockTemplate(type: ExerciseType, name: String) {
        // Get the current block
        var updatedBlock = block
        
        // Ensure dayIndex is valid
        guard dayIndex < updatedBlock.days.count else {
            print("⚠️ Invalid dayIndex: \(dayIndex) for block with \(updatedBlock.days.count) days")
            return
        }
        
        print("🔵 addExerciseToBlockTemplate: Adding '\(name)' (\(type)) to day \(dayIndex)")
        print("   - Block '\(updatedBlock.name)' has \(updatedBlock.days[dayIndex].exercises.count) exercises before append")
        
        // Create a new exercise template
        let newTemplate = ExerciseTemplate(
            customName: name,
            type: type,
            progressionRule: ProgressionRule(type: .custom)
        )
        
        // Add to the day template
        updatedBlock.days[dayIndex].exercises.append(newTemplate)
        print("   - Day now has \(updatedBlock.days[dayIndex].exercises.count) exercises after append")
        
        // Update the block in repository (synchronous operation)
        blocksRepository.update(updatedBlock)
        print("   - Block updated in repository")
        
        // Re-read the committed block from repository to ensure we use the repository's version
        // This is defensive programming: the view's 'block' binding may not reflect the update
        // immediately, so we explicitly fetch the persisted state for regeneration
        guard let committedBlock = blocksRepository.getBlock(id: updatedBlock.id) else {
            print("❌ Failed to read back committed block from repository")
            return
        }
        print("   - Committed block read back: \(committedBlock.days[dayIndex].exercises.count) exercises in day \(dayIndex)")
        
        // Regenerate sessions for future weeks using the committed block
        regenerateSessionsForFutureWeeks(newTemplate: newTemplate, fromBlock: committedBlock, currentWeekIndex: weekIndex)
    }
    
    private func regenerateSessionsForFutureWeeks(
        newTemplate: ExerciseTemplate,
        fromBlock: Block,
        currentWeekIndex: Int
    ) {
        let factory = SessionFactory()
        
        // Validate dayIndex before proceeding
        guard dayIndex < fromBlock.days.count else {
            print("⚠️ Invalid dayIndex: \(dayIndex) for block with \(fromBlock.days.count) days in regenerateSessionsForFutureWeeks")
            return
        }
        
        print("🔵 regenerateSessionsForFutureWeeks: Processing future weeks")
        print("   - Current week index: \(currentWeekIndex) (0-based)")
        print("   - Block has \(fromBlock.numberOfWeeks) weeks")
        print("   - Template: '\(newTemplate.customName ?? "unnamed")' (\(newTemplate.type))")
        
        // Get all existing sessions for this block
        var allSessions = sessionsRepository.sessions(forBlockId: fromBlock.id)
        print("   - Fetched \(allSessions.count) sessions from repository")
        
        // For each future week (starting from next week), add the new exercise
        // Note: weekIndex in RunWeekState is 0-based, but WorkoutSession.weekIndex is 1-based
        let currentWeekNumber = currentWeekIndex + 1 // Convert to 1-based
        let dayTemplateId = fromBlock.days[dayIndex].id
        
        var updatedWeekCount = 0
        
        for futureWeekNumber in (currentWeekNumber + 1)...fromBlock.numberOfWeeks {
            // Find the session for this week and day
            if let sessionIndex = allSessions.firstIndex(where: {
                $0.blockId == fromBlock.id &&
                $0.weekIndex == futureWeekNumber &&
                $0.dayTemplateId == dayTemplateId
            }) {
                // Check if exercise already exists to avoid duplicates
                let exerciseAlreadyExists = allSessions[sessionIndex].exercises.contains { exercise in
                    exercise.customName == newTemplate.customName &&
                    exercise.exerciseTemplateId == newTemplate.id
                }
                
                if exerciseAlreadyExists {
                    print("   - Week \(futureWeekNumber): Exercise already exists, skipping")
                    continue
                }
                
                // Create a new SessionExercise from the template
                let expectedSets = factory.makeSessionSetsFromTemplate(newTemplate, weekIndex: futureWeekNumber)
                // Create independent copies for logged sets (SessionSet is a value type struct)
                // This ensures modifications to logged sets don't affect expected sets
                let loggedSets = expectedSets.map { SessionSet(
                    id: UUID(),
                    index: $0.index,
                    expectedReps: $0.expectedReps,
                    expectedWeight: $0.expectedWeight,
                    expectedTime: $0.expectedTime,
                    expectedDistance: $0.expectedDistance,
                    expectedCalories: $0.expectedCalories,
                    expectedRounds: $0.expectedRounds,
                    loggedReps: $0.loggedReps,
                    loggedWeight: $0.loggedWeight,
                    loggedTime: $0.loggedTime,
                    loggedDistance: $0.loggedDistance,
                    loggedCalories: $0.loggedCalories,
                    loggedRounds: $0.loggedRounds,
                    rpe: $0.rpe,
                    rir: $0.rir,
                    tempo: $0.tempo,
                    restSeconds: $0.restSeconds,
                    notes: $0.notes,
                    isCompleted: $0.isCompleted,
                    completedAt: $0.completedAt
                ) }
                
                let newSessionExercise = SessionExercise(
                    id: UUID(),
                    exerciseTemplateId: newTemplate.id,
                    exerciseDefinitionId: newTemplate.exerciseDefinitionId,
                    customName: newTemplate.customName,
                    expectedSets: expectedSets,
                    loggedSets: loggedSets
                )
                
                // Add to the session's exercises
                allSessions[sessionIndex].exercises.append(newSessionExercise)
                updatedWeekCount += 1
                print("   - Week \(futureWeekNumber): Added exercise with \(expectedSets.count) sets")
            } else {
                print("   - Week \(futureWeekNumber): Session not found for day template \(dayTemplateId)")
            }
        }
        
        // Save all updated sessions
        sessionsRepository.replaceSessions(forBlockId: fromBlock.id, with: allSessions)
        print("✅ regenerateSessionsForFutureWeeks: Updated \(updatedWeekCount) future week sessions")
    }
    
    // MARK: - Exercise Grouping Helpers
    
    /// Groups exercises by setGroupId for superset/circuit display
    private func groupExercises(_ exercises: [RunExerciseState]) -> [ExerciseGroup] {
        var groups: [ExerciseGroup] = []
        var currentGroup: [RunExerciseState] = []
        var currentGroupId: SetGroupID? = nil
        
        for exercise in exercises {
            if let groupId = exercise.setGroupId {
                // This exercise belongs to a group
                if groupId == currentGroupId {
                    // Add to current group
                    currentGroup.append(exercise)
                } else {
                    // New group - save previous group if any
                    if !currentGroup.isEmpty {
                        groups.append(ExerciseGroup(groupId: currentGroupId, exercises: currentGroup))
                        currentGroup = []
                    }
                    // Start new group
                    currentGroupId = groupId
                    currentGroup.append(exercise)
                }
            } else {
                // This exercise doesn't belong to a group
                // Save previous group if any
                if !currentGroup.isEmpty {
                    groups.append(ExerciseGroup(groupId: currentGroupId, exercises: currentGroup))
                    currentGroup = []
                    currentGroupId = nil
                }
                // Add as individual exercise
                groups.append(ExerciseGroup(groupId: nil, exercises: [exercise]))
            }
        }
        
        // Don't forget the last group
        if !currentGroup.isEmpty {
            groups.append(ExerciseGroup(groupId: currentGroupId, exercises: currentGroup))
        }
        
        return groups
    }
    
    /// Helper to create bindings for grouped exercises
    /// Directly looks up each exercise in day.exercises by ID
    /// - Parameter exercises: Array of exercises to create bindings for
    /// - Returns: Array of bindings for exercises found in day.exercises
    /// - Note: Uses O(n) lookup per exercise. For typical workout days (3-8 exercises), this has negligible performance impact
    private func bindingsForExercises(_ exercises: [RunExerciseState]) -> [Binding<RunExerciseState>] {
        return exercises.compactMap { exercise in
            // Find the index of this exercise in day.exercises
            guard let index = day.exercises.firstIndex(where: { $0.id == exercise.id }) else {
                AppLogger.warning("Could not find binding for exercise '\(exercise.name)' with id \(exercise.id)", subsystem: .session, category: "DayRunView")
                return nil
            }
            return $day.exercises[index]
        }
    }
    
    /// Helper structure for grouping exercises
    private struct ExerciseGroup {
        let groupId: SetGroupID?
        let exercises: [RunExerciseState]
    }
}

// MARK: - Superset Group View

struct SupersetGroupView: View {
    let exercises: [Binding<RunExerciseState>]
    let groupId: SetGroupID
    let groupLabel: String  // e.g., "A", "B", "C"
    let onSave: () -> Void
    let backgroundOpacity: Double
    let backgroundOpacityLight: Double
    
    @Environment(\.colorScheme) private var colorScheme
    
    /// Generate execution instruction text based on number of exercises
    private var executionInstruction: String {
        let exerciseLabels = (1...exercises.count).map { "\(groupLabel)\($0)" }
        let sequence = exerciseLabels.joined(separator: " → ")
        return "Complete \(sequence), then rest"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Group header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "link.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text("Superset \(groupLabel)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Spacer()
                }
                
                // Execution instructions
                Text(executionInstruction)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
            )
            
            // Exercises in the group with labels
            VStack(spacing: 12) {
                ForEach(Array(exercises.enumerated()), id: \.offset) { index, _ in
                    VStack(alignment: .leading, spacing: 4) {
                        // Exercise label (A1, A2, etc.)
                        Text("\(groupLabel)\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.top, 8)
                        
                        ExerciseRunCard(exercise: exercises[index], onSave: onSave)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.blue.opacity(0.3), lineWidth: 2)
                    )
                }
            }
            
            // Rest instruction at the bottom
            HStack {
                Image(systemName: "pause.circle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))
                Text("Rest after completing all exercises in this superset")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.orange.opacity(0.1))
            )
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(colorScheme == .dark ? backgroundOpacity : backgroundOpacityLight))
        )
    }
}

struct ExerciseRunCard: View {
    @Binding var exercise: RunExerciseState
    let onSave: () -> Void
    
    @State private var showTypeChangeConfirmation = false
    @State private var pendingNewType: ExerciseType?
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with exercise name and expand/collapse button
            HStack(spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                .accessibilityLabel(isExpanded ? "Collapse exercise details" : "Expand exercise details")
                
                TextField("Exercise name", text: $exercise.name)
                    .font(.headline)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .onChange(of: exercise.name) { _, _ in
                        onSave()
                    }
            }
            
            // Show progress summary when collapsed
            if !isExpanded {
                ExerciseProgressSummary(exercise: exercise)
            }
            
            // Show details only when expanded
            if isExpanded {
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

                // Video URLs section (if present)
                if let videoUrls = exercise.videoUrls, !videoUrls.isEmpty {
                    Text("Videos")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(videoUrls, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                Link(destination: url) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "play.rectangle.fill")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                        Text("Technique demo")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "arrow.up.forward.square")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(.systemBackground).opacity(0.5))
                                    )
                                }
                            }
                        }
                    }
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
            // Use HH:MM:SS format
            parts.append(TimeFormatter.formatTime(dur))
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

// MARK: - Helper Views

/// Displays a progress summary for an exercise showing completed/total sets
struct ExerciseProgressSummary: View {
    let exercise: RunExerciseState
    
    private var completedSets: Int {
        exercise.sets.filter(\.isCompleted).count
    }
    
    private var totalSets: Int {
        exercise.sets.count
    }
    
    private var allSetsCompleted: Bool {
        completedSets == totalSets && totalSets > 0
    }
    
    var body: some View {
        HStack {
            Text("\(completedSets)/\(totalSets) sets completed")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if allSetsCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .accessibilityLabel("All sets completed")
            }
        }
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

    // Conditioning helpers
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
            
            // Per-set notes field
            TextField("Notes (RPE, cues, etc.)", text: Binding(
                get: { runSet.notes ?? "" },
                set: { runSet.notes = $0.isEmpty ? nil : $0 }
            ), axis: .vertical)
                .lineLimit(1...3)
                .font(.footnote)
                .textFieldStyle(.roundedBorder)

            // Complete / Undo
            HStack {
                Spacer()
                if runSet.isCompleted {
                    // Show completion date if available
                    if let completedDate = runSet.completedAt {
                        Text(formatShortDate(completedDate))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Undo") {
                        runSet.isCompleted = false
                        runSet.completedAt = nil
                        onSave()
                    }
                    .font(.caption)
                } else {
                    Button("Complete") {
                        runSet.isCompleted = true
                        runSet.completedAt = Date()
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
        .onChange(of: runSet.rpe) { _, _ in
            onSave()
        }
        .onChange(of: runSet.rir) { _, _ in
            onSave()
        }
        .onChange(of: runSet.tempo) { _, _ in
            onSave()
        }
        .onChange(of: runSet.restSeconds) { _, _ in
            onSave()
        }
        .onChange(of: runSet.notes) { _, _ in
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
            
            // RPE Control
            SetControlView(
                label: "RPE (1-10)",
                unit: "",
                value: $runSet.rpe,
                step: 0.5,
                formatter: Self.weightFormatter,
                min: 0.0,
                max: 10.0
            )
            
            // RIR Control
            SetControlView(
                label: "RIR (0-5)",
                unit: "",
                value: $runSet.rir,
                step: 0.5,
                formatter: Self.weightFormatter,
                min: 0.0,
                max: 5.0
            )
            
            // Tempo field
            TextField("Tempo (e.g., 3010)", text: Binding(
                get: { runSet.tempo ?? "" },
                set: { runSet.tempo = $0.isEmpty ? nil : $0 }
            ))
            .font(.caption)
            .textFieldStyle(.roundedBorder)
            
            // Rest seconds
            SetControlView(
                label: "REST",
                unit: "sec",
                value: $runSet.restSeconds.toDouble(),
                step: 15.0,
                formatter: Self.integerFormatter,
                min: 0.0
            )
        }
    }

    // MARK: - Conditioning UI (Using HH:MM:SS time picker)

    private var conditioningControls: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Time (HH:MM:SS) - Using new time picker control
            TimePickerControlDouble(
                label: "TIME (HH:MM:SS)",
                totalSeconds: $runSet.actualTimeSeconds
            )

            // Distance Control
            SetControlView(
                label: "DISTANCE",
                unit: "m",
                value: $runSet.actualDistanceMeters,
                step: 50.0,
                formatter: Self.integerFormatter,
                min: 0.0
            )

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
            
            // Rest (HH:MM:SS) - Using time picker
            TimePickerControlDouble(
                label: "REST (HH:MM:SS)",
                totalSeconds: $runSet.restSeconds.toDouble()
            )
        }
    }
    
    // MARK: - Date Formatting Helper
    
    /// Formats a date as a short date string (e.g., "12/20/24" in US locale)
    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Run State Models (No changes here)

struct RunWeekState: Identifiable, Codable {
    var id = UUID()
    let index: Int
    var days: [RunDayState]
    
    /// Timestamp when the week was manually marked as complete
    var weekCompletedAt: Date?

    var isCompleted: Bool {
        // If manually marked complete, return true
        if weekCompletedAt != nil {
            return true
        }
        
        // Otherwise check if all sets and segments are completed
        for day in days {
            // Check exercises
            for exercise in day.exercises {
                if exercise.sets.contains(where: { !$0.isCompleted }) {
                    return false
                }
            }
            // Check segments
            if let segments = day.segments {
                if segments.contains(where: { !$0.isCompleted }) {
                    return false
                }
            }
        }
        return true
    }
}

struct RunDayState: Identifiable, Codable{
    var id = UUID()
    let name: String
    let shortCode: String
    var exercises: [RunExerciseState]
    var segments: [RunSegmentState]?  // Added for segment-based days
}

struct RunExerciseState: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: ExerciseType
    var notes: String
    var sets: [RunSetState]
    var setGroupId: SetGroupID?  // For superset/circuit grouping
    var videoUrls: [String]?
}

struct RunSetState: Identifiable, Codable {
    var id = UUID()
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

    // Effort / metadata fields
    var rpe: Double?
    var rir: Double?
    var tempo: String?
    var restSeconds: Int?
    var notes: String?

    var isCompleted: Bool = false
    var completedAt: Date?

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
        rpe: Double? = nil,
        rir: Double? = nil,
        tempo: String? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil
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
        self.rpe = rpe
        self.rir = rir
        self.tempo = tempo
        self.restSeconds = restSeconds
        self.notes = notes
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}

// MARK: - Segment Run State

struct RunSegmentState: Identifiable, Codable {
    var id = UUID()
    let segmentId: SegmentID?
    let name: String
    let segmentType: SegmentType
    let durationMinutes: Int?
    let objective: String?
    let notes: String?
    
    // Round tracking
    let totalRounds: Int?
    let roundDurationSeconds: Int?
    let restSeconds: Int?
    var currentRound: Int = 0
    var completedRounds: Int = 0
    
    // Drill tracking
    let drillItems: [String]  // Simplified drill item names
    var currentDrillIndex: Int = 0
    
    // Quality tracking
    var successfulReps: Int = 0
    var totalAttempts: Int = 0
    var notes_logged: String = ""
    
    // Timing
    var startTime: Date?
    var endTime: Date?
    var isCompleted: Bool = false
    
    // Summary details for tracking (added for issue: segments lack detail)
    let techniqueNames: [String]  // Names of techniques covered
    let coachingCues: [String]    // Key coaching cues
    let constraints: [String]     // Training constraints
    let attackerGoal: String?     // Partner drill attacker goal
    let defenderGoal: String?     // Partner drill defender goal
    let resistance: Int?          // Resistance level (0-100)
    let targetSuccessRate: Double?  // Target success rate (0-1)
    let targetCleanReps: Int?     // Target clean reps
    let safetyNotes: [String]     // Safety contraindications
    
    init(
        segmentId: SegmentID? = nil,
        name: String,
        segmentType: SegmentType,
        durationMinutes: Int? = nil,
        objective: String? = nil,
        notes: String? = nil,
        totalRounds: Int? = nil,
        roundDurationSeconds: Int? = nil,
        restSeconds: Int? = nil,
        drillItems: [String] = [],
        isCompleted: Bool = false,
        techniqueNames: [String] = [],
        coachingCues: [String] = [],
        constraints: [String] = [],
        attackerGoal: String? = nil,
        defenderGoal: String? = nil,
        resistance: Int? = nil,
        targetSuccessRate: Double? = nil,
        targetCleanReps: Int? = nil,
        safetyNotes: [String] = []
    ) {
        self.segmentId = segmentId
        self.name = name
        self.segmentType = segmentType
        self.durationMinutes = durationMinutes
        self.objective = objective
        self.notes = notes
        self.totalRounds = totalRounds
        self.roundDurationSeconds = roundDurationSeconds
        self.restSeconds = restSeconds
        self.drillItems = drillItems
        self.isCompleted = isCompleted
        self.techniqueNames = techniqueNames
        self.coachingCues = coachingCues
        self.constraints = constraints
        self.attackerGoal = attackerGoal
        self.defenderGoal = defenderGoal
        self.resistance = resistance
        self.targetSuccessRate = targetSuccessRate
        self.targetCleanReps = targetCleanReps
        self.safetyNotes = safetyNotes
    }
}


// MARK: - Add Exercise Sheet

struct AddExerciseSheet: View {
    @Binding var persistToFutureWeeks: Bool
    let canPersist: Bool
    let onAddExercise: (ExerciseType, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var exerciseLibrary: ExerciseLibraryRepository
    
    @State private var selectedType: ExerciseType = .strength
    @State private var exerciseName: String = ""
    @State private var isCustomEntry: Bool = false
    
    private var availableExercises: [ExerciseDefinition] {
        exerciseLibrary.all().filter { $0.type == selectedType }
    }
    
    private var trimmedExerciseName: String {
        exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isExerciseNameEmpty: Bool {
        trimmedExerciseName.isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add Exercise")
                    .font(.headline)
                    .padding(.top)
                
                // Type selector
                Picker("Type", selection: $selectedType) {
                    Text("Strength").tag(ExerciseType.strength)
                    Text("Conditioning").tag(ExerciseType.conditioning)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedType) {
                    // Reset exercise name when type changes
                    exerciseName = ""
                }
                
                // Exercise name picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Exercise")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
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
                    .padding(.horizontal)
                }
                
                if canPersist {
                    Divider()
                        .padding(.vertical, 8)
                    
                    Toggle("Add to this day in all future weeks", isOn: $persistToFutureWeeks)
                        .padding(.horizontal)
                        .font(.subheadline)
                }
                
                // Add button
                Button {
                    if !isExerciseNameEmpty {
                        onAddExercise(selectedType, trimmedExerciseName)
                        dismiss()
                    }
                } label: {
                    Text("Add Exercise")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isExerciseNameEmpty ? Color.gray : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isExerciseNameEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Segment Run Card

struct SegmentRunCard: View {
    @Binding var segment: RunSegmentState
    let onSave: () -> Void
    
    @State private var showingWhiteboardHint: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with segment name and type
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(segment.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        // Segment type badge
                        Text(segment.segmentType.rawValue.uppercased())
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(segmentTypeColor())
                            )
                            .foregroundColor(.white)
                        
                        // Duration if present
                        if let duration = segment.durationMinutes {
                            Text("\(duration) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Completion checkbox
                Button {
                    segment.isCompleted.toggle()
                    if segment.isCompleted {
                        segment.endTime = Date()
                        if segment.startTime == nil {
                            segment.startTime = Date()
                        }
                    } else {
                        segment.endTime = nil
                    }
                    onSave()
                } label: {
                    Image(systemName: segment.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(segment.isCompleted ? .green : .gray)
                }
            }
            
            // Objective if present
            if let objective = segment.objective {
                Text("Objective: \(objective)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            }
            
            // Techniques summary (if present)
            if !segment.techniqueNames.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Techniques")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(segment.techniqueNames, id: \.self) { techniqueName in
                        HStack(spacing: 6) {
                            Image(systemName: "target")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(techniqueName)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            
            // Coaching cues (if present)
            if !segment.coachingCues.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Key Cues")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(segment.coachingCues, id: \.self) { cue in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .font(.caption)
                            Text(cue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            
            // Partner roles (if present)
            if segment.attackerGoal != nil || segment.defenderGoal != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Partner Roles")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if let attackerGoal = segment.attackerGoal {
                        HStack(alignment: .top, spacing: 6) {
                            Text("⚔️")
                                .font(.caption)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Attacker:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(attackerGoal)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if let defenderGoal = segment.defenderGoal {
                        HStack(alignment: .top, spacing: 6) {
                            Text("🛡️")
                                .font(.caption)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Defender:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(defenderGoal)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Resistance level if present
                    if let resistance = segment.resistance {
                        HStack(spacing: 8) {
                            Text("Resistance:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack(spacing: 4) {
                                ForEach(0..<5) { index in
                                    Rectangle()
                                        .fill(index < Int(Double(resistance) / 20.0) ? Color.orange : Color.gray.opacity(0.3))
                                        .frame(width: 20, height: 8)
                                        .cornerRadius(2)
                                }
                            }
                            Text("\(resistance)%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
            }
            
            // Constraints (if present)
            if !segment.constraints.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Constraints")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(segment.constraints, id: \.self) { constraint in
                        HStack(alignment: .top, spacing: 6) {
                            Text("⚠️")
                                .font(.caption)
                            Text(constraint)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            
            // Quality targets (if present)
            if segment.targetSuccessRate != nil || segment.targetCleanReps != nil {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quality Targets")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if let targetRate = segment.targetSuccessRate {
                        HStack(spacing: 6) {
                            Image(systemName: "percent")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("Success Rate: \(Int(targetRate * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let targetReps = segment.targetCleanReps {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.shield")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("Clean Reps: \(targetReps)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            
            // Round tracking if present
            if let totalRounds = segment.totalRounds {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rounds: \(segment.completedRounds) / \(totalRounds)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let roundDuration = segment.roundDurationSeconds {
                        Text("Round Duration: \(TimeFormatter.formatTime(roundDuration))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Round controls
                    HStack(spacing: 12) {
                        Button {
                            if segment.completedRounds > 0 {
                                segment.completedRounds -= 1
                                onSave()
                            }
                        } label: {
                            Image(systemName: "minus.circle")
                                .font(.title3)
                        }
                        .disabled(segment.completedRounds == 0)
                        
                        Button {
                            if segment.completedRounds < totalRounds {
                                segment.completedRounds += 1
                                onSave()
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                        .disabled(segment.completedRounds >= totalRounds)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
            
            // Quality tracking
            if segment.totalAttempts > 0 || segment.successfulReps > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quality Tracking")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 16) {
                        // Successful reps
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Clean Reps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                Button {
                                    if segment.successfulReps > 0 {
                                        segment.successfulReps -= 1
                                        onSave()
                                    }
                                } label: {
                                    Image(systemName: "minus.circle")
                                }
                                
                                Text("\(segment.successfulReps)")
                                    .font(.headline)
                                    .frame(minWidth: 30)
                                
                                Button {
                                    segment.successfulReps += 1
                                    onSave()
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                }
                            }
                        }
                        
                        // Total attempts
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Attempts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                Button {
                                    if segment.totalAttempts > 0 {
                                        segment.totalAttempts -= 1
                                        onSave()
                                    }
                                } label: {
                                    Image(systemName: "minus.circle")
                                }
                                
                                Text("\(segment.totalAttempts)")
                                    .font(.headline)
                                    .frame(minWidth: 30)
                                
                                Button {
                                    segment.totalAttempts += 1
                                    onSave()
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                }
                            }
                        }
                    }
                    
                    // Success rate
                    if segment.totalAttempts > 0 {
                        let successRate = Double(segment.successfulReps) / Double(segment.totalAttempts)
                        Text("Success Rate: \(Int(successRate * 100))%")
                            .font(.caption)
                            .foregroundColor(successRate >= 0.7 ? .green : .secondary)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
            
            // Drill items if present
            if !segment.drillItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Drills")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(Array(segment.drillItems.enumerated()), id: \.offset) { index, drillName in
                        HStack {
                            Image(systemName: segment.currentDrillIndex > index ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(segment.currentDrillIndex > index ? .green : .gray)
                            Text(drillName)
                                .font(.subheadline)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if segment.currentDrillIndex == index {
                                segment.currentDrillIndex = index + 1
                            } else if segment.currentDrillIndex > index {
                                segment.currentDrillIndex = index
                            }
                            onSave()
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
            
            // Safety notes (if present)
            if !segment.safetyNotes.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Safety")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    ForEach(segment.safetyNotes, id: \.self) { note in
                        HStack(alignment: .top, spacing: 6) {
                            Text("🚨")
                                .font(.caption)
                            Text(note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.1))
                )
            }
            
            // Notes if present
            if let notes = segment.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            }
            
            // Whiteboard hint
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "rectangle.and.text.magnifyingglass")
                        .font(.caption)
                    Text("Tap 'Whiteboard' for full details")
                        .font(.caption)
                }
                .foregroundColor(.accentColor)
                .padding(.vertical, 4)
                Spacer()
            }
        }
        .padding()
    }
    
    private func segmentTypeColor() -> Color {
        switch segment.segmentType {
        case .warmup, .mobility:
            return Color.orange
        case .technique:
            return Color.blue
        case .drill, .practice:
            return Color.purple
        case .positionalSpar, .rolling:
            return Color.red
        case .cooldown, .breathwork:
            return Color.green
        case .lecture, .presentation:
            return Color.gray
        case .review, .assessment:
            return Color.cyan
        case .demonstration:
            return Color.indigo
        case .discussion:
            return Color.teal
        case .other:
            return Color.secondary
        }
    }
}

// MARK: - BINDING EXTENSIONS (Imported from SetControls.swift)

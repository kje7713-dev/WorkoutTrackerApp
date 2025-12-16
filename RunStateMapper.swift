//
//  RunStateMapper.swift
//  Savage By Design
//
//  Bidirectional mapping between WorkoutSession (repository model) and RunWeekState (UI model)
//

import Foundation

/// Helper for converting between repository sessions and run mode UI state
struct RunStateMapper {
    
    // MARK: - Sessions → RunWeekState
    
    /// Convert WorkoutSessions to RunWeekState array for UI
    /// Groups sessions by weekIndex and creates run state for each week
    /// NOTE: WorkoutSession.weekIndex is 1-based (starts at 1), RunWeekState.index is 0-based (starts at 0)
    static func sessionsToRunWeeks(
        _ sessions: [WorkoutSession],
        block: Block
    ) -> [RunWeekState] {
        // Group sessions by week
        let sessionsByWeek = Dictionary(grouping: sessions) { $0.weekIndex }
        
        // Sort week indices
        let weekIndices = sessionsByWeek.keys.sorted()
        
        guard !weekIndices.isEmpty else {
            return []
        }
        
        // Create RunWeekState for each week
        return weekIndices.map { weekIndex in
            // Validate weekIndex is 1-based as expected
            assert(weekIndex >= 1, "WorkoutSession.weekIndex must be 1-based (>= 1)")
            
            let weekSessions = sessionsByWeek[weekIndex] ?? []
            let dayStates = createRunDayStates(
                from: weekSessions,
                block: block
            )
            
            return RunWeekState(
                index: weekIndex - 1, // Convert 1-based storage to 0-based UI index
                days: dayStates
            )
        }
    }
    
    private static func createRunDayStates(
        from sessions: [WorkoutSession],
        block: Block
    ) -> [RunDayState] {
        // Map each day template to its corresponding session
        return block.days.map { dayTemplate in
            // Find the session for this day template
            guard let session = sessions.first(where: { $0.dayTemplateId == dayTemplate.id }) else {
                // No session found, create empty state
                return RunDayState(
                    name: dayTemplate.name,
                    shortCode: dayTemplate.shortCode ?? "",
                    exercises: []
                )
            }
            
            // Convert session exercises to run exercise states
            let exerciseStates = session.exercises.map { sessionExercise in
                createRunExerciseState(from: sessionExercise, dayTemplate: dayTemplate)
            }
            
            return RunDayState(
                name: dayTemplate.name,
                shortCode: dayTemplate.shortCode ?? "",
                exercises: exerciseStates
            )
        }
    }
    
    private static func createRunExerciseState(
        from sessionExercise: SessionExercise,
        dayTemplate: DayTemplate
    ) -> RunExerciseState {
        // Get exercise name
        let name = sessionExercise.customName ?? "Exercise"
        
        // Find the exercise template to determine type
        let exerciseTemplate = dayTemplate.exercises.first { $0.id == sessionExercise.exerciseTemplateId }
        let type = exerciseTemplate?.type ?? .strength
        
        // Get notes from first set if available (sets don't have individual notes in run state)
        let notes = sessionExercise.loggedSets.first?.notes ?? ""
        
        // Convert logged sets to run set states
        let sets = sessionExercise.loggedSets.map { sessionSet in
            createRunSetState(from: sessionSet, type: type)
        }
        
        return RunExerciseState(
            name: name,
            type: type,
            notes: notes,
            sets: sets
        )
    }
    
    private static func createRunSetState(
        from sessionSet: SessionSet,
        type: ExerciseType
    ) -> RunSetState {
        // Build display text based on expected values
        let displayText = buildDisplayText(from: sessionSet, type: type)
        
        return RunSetState(
            indexInExercise: sessionSet.index,
            displayText: displayText,
            type: type,
            plannedReps: sessionSet.expectedReps,
            plannedWeight: sessionSet.expectedWeight,
            actualReps: sessionSet.loggedReps,
            actualWeight: sessionSet.loggedWeight,
            plannedTimeSeconds: sessionSet.expectedTime,
            plannedDistanceMeters: sessionSet.expectedDistance,
            plannedCalories: sessionSet.expectedCalories,
            plannedRounds: sessionSet.expectedRounds,
            actualTimeSeconds: sessionSet.loggedTime,
            actualDistanceMeters: sessionSet.loggedDistance,
            actualCalories: sessionSet.loggedCalories,
            actualRounds: sessionSet.loggedRounds,
            rpe: sessionSet.rpe,
            rir: sessionSet.rir,
            tempo: sessionSet.tempo,
            restSeconds: sessionSet.restSeconds,
            notes: sessionSet.notes,
            isCompleted: sessionSet.isCompleted
        )
    }
    
    private static func buildDisplayText(from sessionSet: SessionSet, type: ExerciseType) -> String {
        switch type {
        case .strength:
            let repsText = sessionSet.expectedReps.map { "Reps: \($0)" } ?? ""
            let weightText = sessionSet.expectedWeight.map { "Weight: \($0)" } ?? ""
            let parts = [repsText, weightText].filter { !$0.isEmpty }
            return parts.isEmpty ? "Strength set" : parts.joined(separator: " • ")
            
        case .conditioning:
            var parts: [String] = []
            if let dur = sessionSet.expectedTime.map({ Int($0) }) {
                if dur % 60 == 0 {
                    parts.append("\(dur / 60) min")
                } else {
                    parts.append("\(dur) sec")
                }
            }
            if let dist = sessionSet.expectedDistance {
                parts.append("\(Int(dist)) m")
            }
            if let cal = sessionSet.expectedCalories {
                parts.append("\(Int(cal)) cal")
            }
            if let rounds = sessionSet.expectedRounds {
                parts.append("\(rounds) rounds")
            }
            return parts.isEmpty ? "Conditioning" : parts.joined(separator: " • ")
            
        default:
            return "Set"
        }
    }
    
    // MARK: - RunWeekState → Sessions
    
    /// Convert RunWeekState array back to WorkoutSessions
    /// Updates existing sessions with logged values from run state
    /// NOTE: RunWeekState.index is 0-based (starts at 0), WorkoutSession.weekIndex is 1-based (starts at 1)
    static func runWeeksToSessions(
        _ weeks: [RunWeekState],
        originalSessions: [WorkoutSession],
        block: Block
    ) -> [WorkoutSession] {
        var updatedSessions: [WorkoutSession] = []
        
        for week in weeks {
            // Validate week.index is 0-based as expected
            assert(week.index >= 0, "RunWeekState.index must be 0-based (>= 0)")
            
            let weekIndex = week.index + 1 // Convert 0-based UI to 1-based storage
            
            // Process each day in the week
            for (dayIndex, runDay) in week.days.enumerated() {
                guard dayIndex < block.days.count else { continue }
                let dayTemplate = block.days[dayIndex]
                
                // Find the original session for this week/day
                guard let originalSession = originalSessions.first(where: {
                    $0.weekIndex == weekIndex && $0.dayTemplateId == dayTemplate.id
                }) else {
                    continue
                }
                
                // Update the session with logged values from run state
                let updatedSession = updateSession(
                    originalSession,
                    with: runDay,
                    dayTemplate: dayTemplate
                )
                
                updatedSessions.append(updatedSession)
            }
        }
        
        return updatedSessions
    }
    
    private static func updateSession(
        _ session: WorkoutSession,
        with runDay: RunDayState,
        dayTemplate: DayTemplate
    ) -> WorkoutSession {
        var updatedSession = session
        
        // Update exercises with logged values
        updatedSession.exercises = session.exercises.enumerated().map { (exerciseIndex, sessionExercise) in
            guard exerciseIndex < runDay.exercises.count else {
                return sessionExercise
            }
            
            let runExercise = runDay.exercises[exerciseIndex]
            var updatedExercise = sessionExercise
            
            // Update logged sets with values from run state
            updatedExercise.loggedSets = sessionExercise.loggedSets.enumerated().map { (setIndex, sessionSet) in
                guard setIndex < runExercise.sets.count else {
                    return sessionSet
                }
                
                let runSet = runExercise.sets[setIndex]
                var updatedSet = sessionSet
                
                // Update performance fields (reps, weight, time, etc.)
                updatedSet.loggedReps = runSet.actualReps
                updatedSet.loggedWeight = runSet.actualWeight
                updatedSet.loggedTime = runSet.actualTimeSeconds
                updatedSet.loggedDistance = runSet.actualDistanceMeters
                updatedSet.loggedCalories = runSet.actualCalories
                updatedSet.loggedRounds = runSet.actualRounds
                
                // Update training metadata (effort, tempo, rest, notes)
                updatedSet.rpe = runSet.rpe
                updatedSet.rir = runSet.rir
                updatedSet.tempo = runSet.tempo
                updatedSet.restSeconds = runSet.restSeconds
                updatedSet.notes = runSet.notes
                
                // Update completion status
                updatedSet.isCompleted = runSet.isCompleted
                
                return updatedSet
            }
            
            return updatedExercise
        }
        
        // Update session status based on completion
        updatedSession.status = calculateSessionStatus(for: updatedSession)
        
        return updatedSession
    }
    
    private static func calculateSessionStatus(for session: WorkoutSession) -> SessionStatus {
        // Check if all sets are completed
        let allCompleted = session.exercises.allSatisfy { exercise in
            exercise.loggedSets.allSatisfy { $0.isCompleted }
        }
        
        if allCompleted {
            return .completed
        }
        
        // Check if any set is completed (in progress)
        let anyCompleted = session.exercises.contains { exercise in
            exercise.loggedSets.contains { $0.isCompleted }
        }
        
        return anyCompleted ? .inProgress : .notStarted
    }
}

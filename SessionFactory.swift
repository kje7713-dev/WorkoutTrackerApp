//
//  SessionFactory.swift
//  Savage By Design
//
//  Phase 8: Session Generation
//
//  Responsibilities (per Architecture.md / Requirements.md):
//  - Given a Block, generate WorkoutSessions for all (weekIndex, dayTemplate) pairs.
//  - Each WorkoutSession contains SessionExercises with SessionSets.
//  - Logged values MUST initially equal expected values (FR-SESSGEN-3).
//
//  NOTE:
//  - Uses existing domain models: Block, DayTemplate, ExerciseTemplate,
//    WorkoutSession, SessionExercise, SessionSet.
//  - Assumes ExerciseTemplate currently uses strengthSets / conditioningSets
//    as seen in BlockBuilderView.
//  - No changes to existing models or repositories.
//

import Foundation

public struct SessionFactory {

    public init() {}

    // MARK: - Public API

    /// Generate all WorkoutSessions for a Block across all weeks and day templates.
    /// FR-SESSGEN-1 / FR-SESSGEN-2 / FR-SESSGEN-3.
    /// 
    /// Supports two modes:
    /// 1. Standard mode: Uses `block.days` replicated for all weeks with progression
    /// 2. Week-specific mode: Uses `block.weekTemplates` for per-week exercise variations with progression
    public func makeSessions(for block: Block) -> [WorkoutSession] {
        guard block.numberOfWeeks > 0 else { return [] }

        var sessions: [WorkoutSession] = []

        // Log which mode we're using
        if let weekTemplates = block.weekTemplates, !weekTemplates.isEmpty {
            AppLogger.info("🏋️ Generating sessions in week-specific mode: \(weekTemplates.count) week templates for \(block.numberOfWeeks) weeks", subsystem: .session, category: "SessionFactory")
        } else {
            AppLogger.info("🏋️ Generating sessions in standard mode: replicating \(block.days.count) days for \(block.numberOfWeeks) weeks", subsystem: .session, category: "SessionFactory")
        }

        for weekIndex in 1...block.numberOfWeeks {
            // Determine which day templates to use for this week
            let dayTemplates: [DayTemplate]
            
            if let weekTemplates = block.weekTemplates, !weekTemplates.isEmpty {
                // Week-specific mode: use templates for this specific week
                let weekArrayIndex = weekIndex - 1
                if weekArrayIndex < weekTemplates.count {
                    dayTemplates = weekTemplates[weekArrayIndex]
                    AppLogger.debug("  Week \(weekIndex): using week-specific templates (\(dayTemplates.count) days)", subsystem: .session, category: "SessionFactory")
                } else {
                    // Fallback: If numberOfWeeks exceeds weekTemplates.count, repeat the last week's template
                    // This handles cases where a block specifies 12 weeks but only provides 4 weeks of templates
                    // (e.g., a 4-week cycle repeated 3 times)
                    dayTemplates = weekTemplates.last ?? block.days
                    AppLogger.debug("  Week \(weekIndex): repeating last week template (\(dayTemplates.count) days)", subsystem: .session, category: "SessionFactory")
                }
            } else {
                // Standard mode: replicate block.days for all weeks
                dayTemplates = block.days
            }
            
            for dayTemplate in dayTemplates {
                let exercises = makeSessionExercises(
                    from: dayTemplate,
                    in: block,
                    weekIndex: weekIndex
                )
                
                // Convert segments from day template to session segments
                let segments = makeSessionSegments(from: dayTemplate)

                let session = WorkoutSession(
                    id: UUID(),
                    blockId: block.id,
                    weekIndex: weekIndex,
                    dayTemplateId: dayTemplate.id,
                    date: nil,                      // FR-SESSGEN-4: set on first open, in UI flow
                    status: .notStarted,            // Enum as defined in DataDictionary
                    exercises: exercises,
                    segments: segments.isEmpty ? nil : segments
                )

                sessions.append(session)
                
                // Log segment creation for debugging
                if !segments.isEmpty {
                    AppLogger.debug("  Created session with \(segments.count) segments for day '\(dayTemplate.name)'", subsystem: .session, category: "SessionFactory")
                }
            }
        }

        // Count total segments across all sessions
        let totalSegments = sessions.reduce(0) { $0 + ($1.segments?.count ?? 0) }
        if totalSegments > 0 {
            AppLogger.info("✅ Generated \(sessions.count) total sessions (\(totalSegments) segments) for block '\(block.name)'", subsystem: .session, category: "SessionFactory")
        } else {
            AppLogger.info("✅ Generated \(sessions.count) total sessions for block '\(block.name)'", subsystem: .session, category: "SessionFactory")
        }
        return sessions
    }

    // MARK: - Helpers: DayTemplate → [SessionExercise]

    private func makeSessionExercises(
        from dayTemplate: DayTemplate,
        in block: Block,
        weekIndex: Int
    ) -> [SessionExercise] {
        dayTemplate.exercises.map { exerciseTemplate in
            let expectedSets = makeSessionSets(
                from: exerciseTemplate,
                weekIndex: weekIndex
            )

            // FR-SESSGEN-3: logged MUST initially equal expected.
            let loggedSets = expectedSets

            return SessionExercise(
                id: UUID(),
                exerciseTemplateId: exerciseTemplate.id,
                exerciseDefinitionId: exerciseTemplate.exerciseDefinitionId,
                customName: exerciseTemplate.customName,
                expectedSets: expectedSets,
                loggedSets: loggedSets
            )
        }
    }

    // MARK: - Helpers: DayTemplate → [SessionSegment]
    
    /// Convert segments from a day template to session segments for tracking
    private func makeSessionSegments(from dayTemplate: DayTemplate) -> [SessionSegment] {
        guard let segments = dayTemplate.segments else { return [] }
        
        return segments.map { segment in
            SessionSegment(
                id: UUID(),
                segmentId: segment.id,
                name: segment.name,
                segmentType: segment.segmentType,
                startTime: nil,
                endTime: nil,
                isCompleted: false,
                actualDurationMinutes: segment.durationMinutes,
                successRate: nil,
                cleanReps: nil,
                decisionSpeed: nil,
                controlTime: nil,
                roundsCompleted: nil,
                drillItemsCompleted: nil,
                notes: nil,
                coachFeedback: nil
            )
        }
    }

    // MARK: - Helpers: ExerciseTemplate → [SessionSet]
    
    /// Public method to generate session sets from a template for a specific week
    /// This is useful when adding new exercises during a workout
    public func makeSessionSetsFromTemplate(
        _ template: ExerciseTemplate,
        weekIndex: Int
    ) -> [SessionSet] {
        return makeSessionSets(from: template, weekIndex: weekIndex)
    }
    
    // MARK: - Helper: Progression Calculations
    
    /// Calculate the number of additional sets to add for volume progression
    private func calculateAdditionalSets(
        rule: ProgressionRule,
        multiplier: Int
    ) -> Int {
        if rule.type == .volume, let deltaSets = rule.deltaSets {
            return deltaSets * multiplier
        }
        return 0
    }
    
    /// Calculate progressed weight based on progression rule
    private func calculateProgressedWeight(
        baseWeight: Double?,
        rule: ProgressionRule,
        multiplier: Int
    ) -> Double? {
        guard rule.type == .weight,
              let base = baseWeight,
              let delta = rule.deltaWeight else {
            return baseWeight
        }
        return base + (delta * Double(multiplier))
    }

    private func makeSessionSets(
        from template: ExerciseTemplate,
        weekIndex: Int
    ) -> [SessionSet] {
        var result: [SessionSet] = []
        
        // Apply progression logic based on weekIndex and progressionRule
        // Determine if this is a deload week
        let isDeloadWeek = template.progressionRule.deloadWeekIndexes?.contains(weekIndex) ?? false
        
        // Calculate progression multiplier based on weekIndex
        // Week 1 = baseline (0 progression), Week 2 = 1x progression, Week 3 = 2x, etc.
        let progressionMultiplier = isDeloadWeek ? 0 : max(0, weekIndex - 1)

        if let strengthSets = template.strengthSets, !strengthSets.isEmpty {
            // Determine base number of sets and additional sets from progression
            let additionalSets = calculateAdditionalSets(
                rule: template.progressionRule,
                multiplier: progressionMultiplier
            )
            
            // Create base sets from template
            for strength in strengthSets {
                // Apply weight progression if applicable
                let progressedWeight = calculateProgressedWeight(
                    baseWeight: strength.weight,
                    rule: template.progressionRule,
                    multiplier: progressionMultiplier
                )
                
                let set = SessionSet(
                    id: UUID(),
                    index: strength.index,
                    expectedReps: strength.reps,
                    expectedWeight: progressedWeight,
                    expectedTime: nil,
                    expectedDistance: nil,
                    expectedCalories: nil,
                    expectedRounds: nil,
                    loggedReps: strength.reps,
                    loggedWeight: progressedWeight,
                    loggedTime: nil,
                    loggedDistance: nil,
                    loggedCalories: nil,
                    loggedRounds: nil,
                    rpe: strength.rpe,
                    rir: strength.rir,
                    tempo: strength.tempo,
                    restSeconds: strength.restSeconds,
                    notes: strength.notes,
                    isCompleted: false
                )
                result.append(set)
            }
            
            // Add additional sets for volume progression
            if additionalSets > 0, let lastSet = strengthSets.last {
                // Apply weight progression to additional sets as well
                let progressedWeight = calculateProgressedWeight(
                    baseWeight: lastSet.weight,
                    rule: template.progressionRule,
                    multiplier: progressionMultiplier
                )
                
                for i in 0..<additionalSets {
                    let newIndex = strengthSets.count + i
                    let set = SessionSet(
                        id: UUID(),
                        index: newIndex,
                        expectedReps: lastSet.reps,
                        expectedWeight: progressedWeight,
                        expectedTime: nil,
                        expectedDistance: nil,
                        expectedCalories: nil,
                        expectedRounds: nil,
                        loggedReps: lastSet.reps,
                        loggedWeight: progressedWeight,
                        loggedTime: nil,
                        loggedDistance: nil,
                        loggedCalories: nil,
                        loggedRounds: nil,
                        rpe: lastSet.rpe,
                        rir: lastSet.rir,
                        tempo: lastSet.tempo,
                        restSeconds: lastSet.restSeconds,
                        notes: lastSet.notes,
                        isCompleted: false
                    )
                    result.append(set)
                }
            }
        }

        if let conditioningSets = template.conditioningSets, !conditioningSets.isEmpty {
            // Conditioning exercises typically don't use weight progression,
            // but we could apply volume progression (additional sets/rounds)
            let additionalSets = calculateAdditionalSets(
                rule: template.progressionRule,
                multiplier: progressionMultiplier
            )
            
            for conditioning in conditioningSets {
                let set = SessionSet(
                    id: UUID(),
                    index: conditioning.index,
                    expectedReps: nil,
                    expectedWeight: nil,
                    expectedTime: conditioning.durationSeconds.map { Double($0) },
                    expectedDistance: conditioning.distanceMeters,
                    expectedCalories: conditioning.calories,
                    expectedRounds: conditioning.rounds,
                    loggedReps: nil,
                    loggedWeight: nil,
                    loggedTime: conditioning.durationSeconds.map { Double($0) },
                    loggedDistance: conditioning.distanceMeters,
                    loggedCalories: conditioning.calories,
                    loggedRounds: conditioning.rounds,
                    rpe: nil,
                    rir: nil,
                    tempo: nil,
                    restSeconds: conditioning.restSeconds,
                    notes: conditioning.notes,
                    isCompleted: false
                )
                result.append(set)
            }
            
            // Add additional sets for volume progression
            if additionalSets > 0, let lastSet = conditioningSets.last {
                for i in 0..<additionalSets {
                    let newIndex = conditioningSets.count + i
                    let set = SessionSet(
                        id: UUID(),
                        index: newIndex,
                        expectedReps: nil,
                        expectedWeight: nil,
                        expectedTime: lastSet.durationSeconds.map { Double($0) },
                        expectedDistance: lastSet.distanceMeters,
                        expectedCalories: lastSet.calories,
                        expectedRounds: lastSet.rounds,
                        loggedReps: nil,
                        loggedWeight: nil,
                        loggedTime: lastSet.durationSeconds.map { Double($0) },
                        loggedDistance: lastSet.distanceMeters,
                        loggedCalories: lastSet.calories,
                        loggedRounds: lastSet.rounds,
                        rpe: nil,
                        rir: nil,
                        tempo: nil,
                        restSeconds: lastSet.restSeconds,
                        notes: lastSet.notes,
                        isCompleted: false
                    )
                    result.append(set)
                }
            }
        }

        return result
    }
}

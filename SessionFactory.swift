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
    /// 1. Standard mode: Uses `block.days` replicated for all weeks
    /// 2. Week-specific mode: Uses `block.weekTemplates` for per-week exercise variations
    public func makeSessions(for block: Block) -> [WorkoutSession] {
        guard block.numberOfWeeks > 0 else { return [] }

        var sessions: [WorkoutSession] = []

        for weekIndex in 1...block.numberOfWeeks {
            // Determine which day templates to use for this week
            let dayTemplates: [DayTemplate]
            
            if let weekTemplates = block.weekTemplates, !weekTemplates.isEmpty {
                // Week-specific mode: use templates for this specific week
                let weekArrayIndex = weekIndex - 1
                if weekArrayIndex < weekTemplates.count {
                    dayTemplates = weekTemplates[weekArrayIndex]
                } else {
                    // Fallback: If numberOfWeeks exceeds weekTemplates.count, repeat the last week's template
                    // This handles cases where a block specifies 12 weeks but only provides 4 weeks of templates
                    // (e.g., a 4-week cycle repeated 3 times)
                    dayTemplates = weekTemplates.last ?? block.days
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

                let session = WorkoutSession(
                    id: UUID(),
                    blockId: block.id,
                    weekIndex: weekIndex,
                    dayTemplateId: dayTemplate.id,
                    date: nil,                      // FR-SESSGEN-4: set on first open, in UI flow
                    status: .notStarted,            // Enum as defined in DataDictionary
                    exercises: exercises
                )

                sessions.append(session)
            }
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

    // MARK: - Helpers: ExerciseTemplate → [SessionSet]
    
    /// Public method to generate session sets from a template for a specific week
    /// This is useful when adding new exercises during a workout
    public func makeSessionSetsFromTemplate(
        _ template: ExerciseTemplate,
        weekIndex: Int
    ) -> [SessionSet] {
        return makeSessionSets(from: template, weekIndex: weekIndex)
    }

    private func makeSessionSets(
        from template: ExerciseTemplate,
        weekIndex: Int
    ) -> [SessionSet] {
        var result: [SessionSet] = []

        // NOTE:
        // We are intentionally *not* applying complex progression logic here yet.
        // For Phase 8 v1, we:
        //  - Reflect the template’s planned sets directly into expected* fields.
        //  - Copy those values into logged* fields.
        //  - Leave advanced week-based adjustments to ProgressionEngine in a later pass.

        if let strengthSets = template.strengthSets {
            for strength in strengthSets {
                let set = SessionSet(
                    id: UUID(),
                    index: strength.index,
                    expectedReps: strength.reps,
                    expectedWeight: strength.weight,
                    expectedTime: nil,
                    expectedDistance: nil,
                    expectedCalories: nil,
                    expectedRounds: nil, // Note: Rounds field is for conditioning
                    loggedReps: strength.reps,
                    loggedWeight: strength.weight,
                    loggedTime: nil,
                    loggedDistance: nil,
                    loggedCalories: nil,
                    loggedRounds: nil, // Note: Rounds field is for conditioning
                    // 🚨 FIX: Ensure RPE/RIR/Tempo/RestSeconds are mapped from the template
                    rpe: strength.rpe,
                    rir: strength.rir,
                    tempo: strength.tempo,
                    restSeconds: strength.restSeconds,
                    notes: strength.notes,
                    isCompleted: false
                    
                )
                result.append(set)
            }
        }

        if let conditioningSets = template.conditioningSets {
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
                    // 🚨 FIX: Ensure RPE/RIR/Tempo/RestSeconds are mapped from the template (if they exist on the template model)
                    rpe: nil,
                    rir: nil,
                    tempo: nil,
                    restSeconds: conditioning.restSeconds, // Rest is the most common shared field
                    notes: conditioning.notes,
                    isCompleted: false
                )
                result.append(set)
            }
        }

        // If you later make use of genericSets on ExerciseTemplate,
        // you can add a third branch here that maps those into SessionSets
        // using the same expected*/logged* pattern.

        return result
    }
}

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
    public func makeSessions(for block: Block) -> [WorkoutSession] {
        guard block.numberOfWeeks > 0 else { return [] }

        var sessions: [WorkoutSession] = []

        for weekIndex in 1...block.numberOfWeeks {
            for dayTemplate in block.days {
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
                    loggedReps: strength.reps,
                    loggedWeight: strength.weight,
                    loggedTime: nil,
                    loggedDistance: nil,
                    loggedCalories: nil,
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
                    expectedTime: conditioning.durationSeconds,
                    expectedDistance: conditioning.distanceMeters,
                    expectedCalories: conditioning.calories,
                    loggedReps: nil,
                    loggedWeight: nil,
                    loggedTime: conditioning.durationSeconds,
                    loggedDistance: conditioning.distanceMeters,
                    loggedCalories: conditioning.calories,
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

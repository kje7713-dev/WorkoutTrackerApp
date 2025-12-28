//
//  BlockNormalizer.swift
//  Savage By Design
//
//  Service to normalize various block schemas into UnifiedBlock
//

import Foundation

public final class BlockNormalizer {
    
    // MARK: - Normalize from App Models
    
    /// Normalize a Block model into UnifiedBlock
    public static func normalize(block: Block) -> UnifiedBlock {
        let weeks: [[UnifiedDay]]
        
        // Determine which day templates to use per week
        if let weekTemplates = block.weekTemplates, !weekTemplates.isEmpty {
            // Week-specific mode: use templates for each specific week
            weeks = weekTemplates.map { dayTemplates in
                dayTemplates.map { normalizeDay($0) }
            }
        } else {
            // Standard mode: replicate block.days for all weeks
            let normalizedDays = block.days.map { normalizeDay($0) }
            weeks = Array(repeating: normalizedDays, count: max(block.numberOfWeeks, 1))
        }
        
        return UnifiedBlock(
            title: block.name,
            numberOfWeeks: max(block.numberOfWeeks, 1),
            weeks: weeks
        )
    }
    
    /// Normalize a DayTemplate into UnifiedDay
    private static func normalizeDay(_ day: DayTemplate) -> UnifiedDay {
        return UnifiedDay(
            name: day.name,
            goal: day.goal?.rawValue,
            exercises: day.exercises.map { normalizeExercise($0) }
        )
    }
    
    /// Normalize an ExerciseTemplate into UnifiedExercise
    private static func normalizeExercise(_ exercise: ExerciseTemplate) -> UnifiedExercise {
        let strengthSets = (exercise.strengthSets ?? []).map { set in
            UnifiedStrengthSet(
                reps: set.reps,
                restSeconds: set.restSeconds,
                rpe: set.rpe,
                notes: set.notes
            )
        }
        
        let conditioningSets = (exercise.conditioningSets ?? []).map { set in
            UnifiedConditioningSet(
                durationSeconds: set.durationSeconds,
                distanceMeters: set.distanceMeters,
                calories: set.calories,
                rounds: set.rounds,
                effortDescriptor: set.effortDescriptor,
                restSeconds: set.restSeconds,
                notes: set.notes
            )
        }
        
        return UnifiedExercise(
            name: exercise.customName ?? "Exercise",
            type: exercise.type.rawValue,
            category: exercise.category?.rawValue,
            notes: exercise.notes,
            strengthSets: strengthSets,
            conditioningType: exercise.conditioningType?.rawValue,
            conditioningSets: conditioningSets,
            setGroupId: exercise.setGroupId?.uuidString,
            setGroupKind: nil,
            progressionType: exercise.progressionRule.type.rawValue,
            progressionDeltaWeight: exercise.progressionRule.deltaWeight,
            progressionDeltaSets: exercise.progressionRule.deltaSets
        )
    }
    
    // MARK: - Normalize from Authoring JSON
    
    /// Normalize authoring JSON (AI/manual block creation) into UnifiedBlock
    public static func normalize(authoringBlock: AuthoringBlock) -> UnifiedBlock {
        let title = authoringBlock.Title ?? "Untitled Block"
        let numberOfWeeks = authoringBlock.NumberOfWeeks ?? 1
        
        let weeks: [[UnifiedDay]]
        
        if let weeksData = authoringBlock.Weeks {
            // Week-specific days
            weeks = weeksData.map { weekDays in
                weekDays.map { normalizeAuthoringDay($0) }
            }
        } else if let daysData = authoringBlock.Days {
            // Multi-day repeated across weeks
            let normalizedDays = daysData.map { normalizeAuthoringDay($0) }
            weeks = Array(repeating: normalizedDays, count: numberOfWeeks)
        } else if let exercisesData = authoringBlock.Exercises {
            // Single day with exercises
            let day = UnifiedDay(
                name: "Day 1",
                goal: authoringBlock.Goal,
                exercises: exercisesData.map { normalizeAuthoringExercise($0) }
            )
            weeks = Array(repeating: [day], count: numberOfWeeks)
        } else {
            // Empty block
            weeks = []
        }
        
        return UnifiedBlock(
            title: title,
            numberOfWeeks: numberOfWeeks,
            weeks: weeks
        )
    }
    
    /// Normalize an authoring day
    private static func normalizeAuthoringDay(_ day: AuthoringDay) -> UnifiedDay {
        return UnifiedDay(
            name: day.name,
            goal: day.goal,
            exercises: day.exercises.map { normalizeAuthoringExercise($0) }
        )
    }
    
    /// Normalize an authoring exercise
    private static func normalizeAuthoringExercise(_ exercise: AuthoringExercise) -> UnifiedExercise {
        let type = exercise.type
        var strengthSets: [UnifiedStrengthSet] = []
        var conditioningSets: [UnifiedConditioningSet] = []
        
        // Parse setsReps for strength exercises
        if type == "strength", let setsReps = exercise.setsReps {
            strengthSets = parseSetsReps(setsReps, restSeconds: exercise.restSeconds)
        }
        
        // Create conditioning sets if applicable
        if type == "conditioning" {
            conditioningSets = [
                UnifiedConditioningSet(
                    durationSeconds: exercise.durationSeconds,
                    distanceMeters: exercise.distanceMeters,
                    calories: nil,
                    rounds: exercise.rounds,
                    effortDescriptor: exercise.effortDescriptor,
                    restSeconds: exercise.restSeconds,
                    notes: exercise.notes
                )
            ]
        }
        
        return UnifiedExercise(
            name: exercise.name,
            type: type,
            category: exercise.category,
            notes: exercise.notes,
            strengthSets: strengthSets,
            conditioningType: exercise.conditioningType,
            conditioningSets: conditioningSets
        )
    }
    
    /// Parse "5x5" or "3x8-10" into strength sets
    private static func parseSetsReps(_ setsReps: String, restSeconds: Int?) -> [UnifiedStrengthSet] {
        // Simple parser for "NxM" format
        let components = setsReps.components(separatedBy: "x")
        guard components.count == 2,
              let setCount = Int(components[0].trimmingCharacters(in: .whitespaces)),
              let reps = Int(components[1].trimmingCharacters(in: .whitespaces).components(separatedBy: "-").first ?? "")
        else {
            return []
        }
        
        return (0..<setCount).map { _ in
            UnifiedStrengthSet(
                reps: reps,
                restSeconds: restSeconds,
                rpe: nil,
                notes: nil
            )
        }
    }
    
    // MARK: - Normalize from Export JSON
    
    /// Normalize app export JSON into UnifiedBlock
    public static func normalize(exportData: AppDataExport, blockIndex: Int = 0) -> UnifiedBlock? {
        guard blockIndex < exportData.blocks.count else { return nil }
        
        let exportBlock = exportData.blocks[blockIndex]
        return normalize(block: exportBlock)
    }
}

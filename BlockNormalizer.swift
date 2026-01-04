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
        let targetWeekCount = max(block.numberOfWeeks, 1)
        
        // Determine which day templates to use per week
        if let weekTemplates = block.weekTemplates, !weekTemplates.isEmpty {
            // Week-specific mode: use templates for each specific week
            let normalizedWeekTemplates = weekTemplates.map { dayTemplates in
                dayTemplates.map { normalizeDay($0) }
            }
            
            // Handle mismatch between weekTemplates count and numberOfWeeks
            if normalizedWeekTemplates.count < targetWeekCount {
                // Pad by cycling through available week templates
                // Example: If we have 2 templates and need 4 weeks, use [template0, template1, template0, template1]
                weeks = (0..<targetWeekCount).map { weekIndex in
                    // Use modulo to cycle through templates: week 0→template0, week 1→template1, week 2→template0, etc.
                    normalizedWeekTemplates[weekIndex % normalizedWeekTemplates.count]
                }
            } else if normalizedWeekTemplates.count > targetWeekCount {
                // Only use the first numberOfWeeks entries
                weeks = Array(normalizedWeekTemplates.prefix(targetWeekCount))
            } else {
                // Counts match - use as-is
                weeks = normalizedWeekTemplates
            }
        } else {
            // Standard mode: replicate block.days for all weeks
            let normalizedDays = block.days.map { normalizeDay($0) }
            weeks = Array(repeating: normalizedDays, count: targetWeekCount)
        }
        
        return UnifiedBlock(
            title: block.name,
            numberOfWeeks: targetWeekCount,
            weeks: weeks
        )
    }
    
    /// Normalize a DayTemplate into UnifiedDay
    private static func normalizeDay(_ day: DayTemplate) -> UnifiedDay {
        let exercises = day.exercises.map { normalizeExercise($0) }
        let segments = day.segments?.map { normalizeSegment($0) } ?? []
        
        return UnifiedDay(
            name: day.name,
            goal: day.goal?.rawValue,
            exercises: exercises,
            segments: segments
        )
    }
    
    /// Normalize a Segment into UnifiedSegment
    private static func normalizeSegment(_ segment: Segment) -> UnifiedSegment {
        // Extract drill items if present
        let drillItems = segment.drillPlan?.items.map { item in
            UnifiedDrillItem(
                name: item.name,
                workSeconds: item.workSeconds,
                restSeconds: item.restSeconds,
                notes: item.notes
            )
        } ?? []
        
        // Extract techniques with all fields
        let techniques = segment.techniques.map { tech in
            UnifiedTechnique(
                name: tech.name,
                variant: tech.variant,
                keyDetails: tech.keyDetails,
                commonErrors: tech.commonErrors,
                counters: tech.counters,
                followUps: tech.followUps,
                videoUrls: tech.videoUrls
            )
        }
        
        // Extract flow sequence items
        let flowSequence = segment.flowSequence.map { step in
            UnifiedFlowStep(
                poseName: step.poseName,
                holdSeconds: step.holdSeconds,
                transitionCue: step.transitionCue
            )
        }
        
        // Extract scoring information
        var scoringStrings: [String] = []
        if let scoring = segment.scoring {
            scoringStrings.append(contentsOf: scoring.attackerScoresIf.map { "Attacker: \($0)" })
            scoringStrings.append(contentsOf: scoring.defenderScoresIf.map { "Defender: \($0)" })
        }
        
        // Extract starting state
        let startingStateGrips = segment.startingState?.grips ?? []
        let startingStateRoles = segment.startingState?.roles ?? []
        
        // Build unified segment
        return UnifiedSegment(
            name: segment.name,
            segmentType: segment.segmentType.rawValue,
            domain: segment.domain?.rawValue,
            durationMinutes: segment.durationMinutes,
            objective: segment.objective,
            constraints: segment.constraints,
            coachingCues: segment.coachingCues,
            positions: segment.positions,
            techniques: techniques,
            rounds: segment.roundPlan?.rounds ?? segment.partnerPlan?.rounds,
            roundDurationSeconds: segment.roundPlan?.roundDurationSeconds ?? segment.partnerPlan?.roundDurationSeconds,
            restSeconds: segment.roundPlan?.restSeconds ?? segment.partnerPlan?.restSeconds,
            workSeconds: nil,
            resistance: segment.resistance ?? segment.partnerPlan?.resistance,
            attackerGoal: segment.roles?.attackerGoal ?? segment.partnerPlan?.roles?.attackerGoal,
            defenderGoal: segment.roles?.defenderGoal ?? segment.partnerPlan?.roles?.defenderGoal,
            successRateTarget: segment.qualityTargets?.successRateTarget ?? segment.partnerPlan?.qualityTargets?.successRateTarget,
            cleanRepsTarget: segment.qualityTargets?.cleanRepsTarget ?? segment.partnerPlan?.qualityTargets?.cleanRepsTarget,
            decisionSpeedSeconds: segment.qualityTargets?.decisionSpeedSeconds ?? segment.partnerPlan?.qualityTargets?.decisionSpeedSeconds,
            controlTimeSeconds: segment.qualityTargets?.controlTimeSeconds ?? segment.partnerPlan?.qualityTargets?.controlTimeSeconds,
            startPosition: segment.startPosition,
            endCondition: segment.endCondition,
            scoring: scoringStrings,
            winConditions: segment.roundPlan?.winConditions ?? [],
            resetRule: segment.roundPlan?.resetRule,
            intensityCue: segment.roundPlan?.intensityCue,
            switchEverySeconds: segment.partnerPlan?.switchEverySeconds,
            breathworkStyle: segment.breathwork?.style,
            breathworkPattern: segment.breathwork?.pattern,
            breathworkDurationSeconds: segment.breathwork?.durationSeconds,
            breathCount: segment.breathCount,
            holdSeconds: segment.holdSeconds,
            intensityScale: segment.intensityScale?.rawValue,
            props: segment.props,
            flowSequence: flowSequence,
            notes: segment.notes,
            contraindications: segment.safety?.contraindications ?? [],
            stopIf: segment.safety?.stopIf ?? [],
            intensityCeiling: segment.safety?.intensityCeiling,
            drillItems: drillItems,
            startingStateGrips: startingStateGrips,
            startingStateRoles: startingStateRoles,
            mediaVideoUrl: segment.media?.videoUrl,
            mediaImageUrl: segment.media?.imageUrl,
            mediaDiagramAssetId: segment.media?.diagramAssetId
        )
    }
    
    /// Normalize an ExerciseTemplate into UnifiedExercise
    private static func normalizeExercise(_ exercise: ExerciseTemplate) -> UnifiedExercise {
        let strengthSets = (exercise.strengthSets ?? []).map { set in
            UnifiedStrengthSet(
                reps: set.reps,
                weight: set.weight,
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
        let exercises = day.exercises?.map { normalizeAuthoringExercise($0) } ?? []
        let segments = day.segments?.map { normalizeAuthoringSegment($0) } ?? []
        
        return UnifiedDay(
            name: day.name,
            goal: day.goal,
            exercises: exercises,
            segments: segments
        )
    }
    
    /// Normalize an authoring segment
    private static func normalizeAuthoringSegment(_ segment: AuthoringSegment) -> UnifiedSegment {
        // Extract drill items
        let drillItems = segment.drillPlan?.items?.map { item in
            UnifiedDrillItem(
                name: item.name,
                workSeconds: item.workSeconds,
                restSeconds: item.restSeconds,
                notes: item.notes
            )
        } ?? []
        
        // Extract techniques with all fields
        let techniques = segment.techniques?.map { tech in
            UnifiedTechnique(
                name: tech.name,
                variant: tech.variant,
                keyDetails: tech.keyDetails ?? [],
                commonErrors: tech.commonErrors ?? [],
                counters: tech.counters ?? [],
                followUps: tech.followUps ?? [],
                videoUrls: tech.videoUrls
            )
        } ?? []
        
        // Extract flow sequence items
        let flowSequence = segment.flowSequence?.map { step in
            UnifiedFlowStep(
                poseName: step.poseName,
                holdSeconds: step.holdSeconds,
                transitionCue: step.transitionCue
            )
        } ?? []
        
        // Extract scoring
        var scoringStrings: [String] = []
        if let scoring = segment.scoring {
            scoringStrings.append(contentsOf: (scoring.attackerScoresIf ?? []).map { "Attacker: \($0)" })
            scoringStrings.append(contentsOf: (scoring.defenderScoresIf ?? []).map { "Defender: \($0)" })
        }
        
        // Extract starting state
        let startingStateGrips = segment.startingState?.grips ?? []
        let startingStateRoles = segment.startingState?.roles ?? []
        
        return UnifiedSegment(
            name: segment.name,
            segmentType: segment.segmentType,
            domain: segment.domain,
            durationMinutes: segment.durationMinutes,
            objective: segment.objective,
            constraints: segment.constraints ?? [],
            coachingCues: segment.coachingCues ?? [],
            positions: segment.positions ?? [],
            techniques: techniques,
            rounds: segment.roundPlan?.rounds ?? segment.partnerPlan?.rounds,
            roundDurationSeconds: segment.roundPlan?.roundDurationSeconds ?? segment.partnerPlan?.roundDurationSeconds,
            restSeconds: segment.roundPlan?.restSeconds ?? segment.partnerPlan?.restSeconds,
            workSeconds: nil,
            resistance: segment.resistance ?? segment.partnerPlan?.resistance,
            attackerGoal: segment.roles?.attackerGoal ?? segment.partnerPlan?.roles?.attackerGoal,
            defenderGoal: segment.roles?.defenderGoal ?? segment.partnerPlan?.roles?.defenderGoal,
            successRateTarget: segment.qualityTargets?.successRateTarget ?? segment.partnerPlan?.qualityTargets?.successRateTarget,
            cleanRepsTarget: segment.qualityTargets?.cleanRepsTarget ?? segment.partnerPlan?.qualityTargets?.cleanRepsTarget,
            decisionSpeedSeconds: segment.qualityTargets?.decisionSpeedSeconds ?? segment.partnerPlan?.qualityTargets?.decisionSpeedSeconds,
            controlTimeSeconds: segment.qualityTargets?.controlTimeSeconds ?? segment.partnerPlan?.qualityTargets?.controlTimeSeconds,
            startPosition: segment.startPosition,
            endCondition: segment.endCondition,
            scoring: scoringStrings,
            winConditions: segment.roundPlan?.winConditions ?? [],
            resetRule: segment.roundPlan?.resetRule,
            intensityCue: segment.roundPlan?.intensityCue,
            switchEverySeconds: segment.partnerPlan?.switchEverySeconds,
            breathworkStyle: segment.breathwork?.style,
            breathworkPattern: segment.breathwork?.pattern,
            breathworkDurationSeconds: segment.breathwork?.durationSeconds,
            breathCount: segment.breathCount,
            holdSeconds: segment.holdSeconds,
            intensityScale: segment.intensityScale,
            props: segment.props ?? [],
            flowSequence: flowSequence,
            notes: segment.notes,
            contraindications: segment.safety?.contraindications ?? [],
            stopIf: segment.safety?.stopIf ?? [],
            intensityCeiling: segment.safety?.intensityCeiling,
            drillItems: drillItems,
            startingStateGrips: startingStateGrips,
            startingStateRoles: startingStateRoles,
            mediaVideoUrl: segment.media?.videoUrl,
            mediaImageUrl: segment.media?.imageUrl,
            mediaDiagramAssetId: segment.media?.diagramAssetId
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

//
//  WhiteboardFormatter.swift
//  Savage By Design
//
//  Service to format UnifiedExercises into WhiteboardSections
//

import Foundation

public final class WhiteboardFormatter {
    
    // MARK: - Public API
    
    /// Format a unified day into whiteboard sections
    public static func formatDay(_ day: UnifiedDay) -> [WhiteboardSection] {
        var sections: [WhiteboardSection] = []
        
        // Format segments first (if present)
        if !day.segments.isEmpty {
            let segmentSections = formatSegments(day.segments)
            sections.append(contentsOf: segmentSections)
        }
        
        // Partition exercises
        let (strengthExercises, conditioningExercises) = partitionExercises(day.exercises)
        
        // Further partition strength into main lifts vs accessories
        let (mainLifts, accessories) = partitionStrengthExercises(strengthExercises)
        
        // Build sections
        if !mainLifts.isEmpty {
            sections.append(WhiteboardSection(
                title: "Strength",
                items: mainLifts.map { formatStrengthExercise($0) }
            ))
        }
        
        if !accessories.isEmpty {
            sections.append(WhiteboardSection(
                title: "Accessory",
                items: accessories.map { formatStrengthExercise($0) }
            ))
        }
        
        if !conditioningExercises.isEmpty {
            sections.append(WhiteboardSection(
                title: "Conditioning",
                items: conditioningExercises.map { formatConditioningExercise($0) }
            ))
        }
        
        return sections
    }
    
    // MARK: - Segment Formatting
    
    /// Format segments into whiteboard sections
    private static func formatSegments(_ segments: [UnifiedSegment]) -> [WhiteboardSection] {
        var sections: [WhiteboardSection] = []
        
        // Group segments by type
        let warmupSegments = segments.filter { $0.segmentType == "warmup" || $0.segmentType == "mobility" }
        let techniqueSegments = segments.filter { $0.segmentType == "technique" }
        let drillSegments = segments.filter { $0.segmentType == "drill" }
        let sparringSegments = segments.filter { $0.segmentType == "positionalSpar" || $0.segmentType == "rolling" }
        let cooldownSegments = segments.filter { $0.segmentType == "cooldown" || $0.segmentType == "breathwork" }
        let otherSegments = segments.filter { 
            !["warmup", "mobility", "technique", "drill", "positionalSpar", "rolling", "cooldown", "breathwork"].contains($0.segmentType)
        }
        
        if !warmupSegments.isEmpty {
            sections.append(WhiteboardSection(
                title: "Warm-Up / Mobility",
                items: warmupSegments.map { formatSegment($0) }
            ))
        }
        
        if !techniqueSegments.isEmpty {
            sections.append(WhiteboardSection(
                title: "Technique Development",
                items: techniqueSegments.map { formatSegment($0) }
            ))
        }
        
        if !drillSegments.isEmpty {
            sections.append(WhiteboardSection(
                title: "Drilling",
                items: drillSegments.map { formatSegment($0) }
            ))
        }
        
        if !sparringSegments.isEmpty {
            sections.append(WhiteboardSection(
                title: "Live Training",
                items: sparringSegments.map { formatSegment($0) }
            ))
        }
        
        if !cooldownSegments.isEmpty {
            sections.append(WhiteboardSection(
                title: "Cool Down",
                items: cooldownSegments.map { formatSegment($0) }
            ))
        }
        
        if !otherSegments.isEmpty {
            sections.append(WhiteboardSection(
                title: "Additional Work",
                items: otherSegments.map { formatSegment($0) }
            ))
        }
        
        return sections
    }
    
    /// Format a single segment into a whiteboard item
    private static func formatSegment(_ segment: UnifiedSegment) -> WhiteboardItem {
        var bullets: [String] = []
        
        // Add objective
        if let objective = segment.objective {
            bullets.append("Objective: \(objective)")
        }
        
        // Add positions if present
        if !segment.positions.isEmpty {
            bullets.append("Positions: \(segment.positions.joined(separator: ", "))")
        }
        
        // Add techniques
        for technique in segment.techniques {
            var techString = "• \(technique.name)"
            if let variant = technique.variant {
                techString += " (\(variant))"
            }
            bullets.append(techString)
            if !technique.keyDetails.isEmpty {
                bullets.append(contentsOf: technique.keyDetails.map { "  - \($0)" })
            }
        }
        
        // Add drill items
        for item in segment.drillItems {
            let timeStr = formatSeconds(item.workSeconds)
            let restStr = item.restSeconds > 0 ? " / \(formatSeconds(item.restSeconds)) rest" : ""
            bullets.append("• \(item.name): \(timeStr)\(restStr)")
        }
        
        // Add constraints
        if !segment.constraints.isEmpty {
            bullets.append("Constraints:")
            bullets.append(contentsOf: segment.constraints.map { "  - \($0)" })
        }
        
        // Add coaching cues
        if !segment.coachingCues.isEmpty {
            bullets.append("Cues:")
            bullets.append(contentsOf: segment.coachingCues.map { "  - \($0)" })
        }
        
        // Add quality targets
        if let successRate = segment.successRateTarget {
            bullets.append("Target success rate: \(Int(successRate * 100))%")
        }
        if let cleanReps = segment.cleanRepsTarget {
            bullets.append("Target clean reps: \(cleanReps)")
        }
        
        // Add roles for partner work
        if let attackerGoal = segment.attackerGoal {
            bullets.append("Attacker: \(attackerGoal)")
        }
        if let defenderGoal = segment.defenderGoal {
            bullets.append("Defender: \(defenderGoal)")
        }
        if let resistance = segment.resistance {
            bullets.append("Resistance: \(resistance)%")
        }
        
        // Add scoring
        if !segment.scoring.isEmpty {
            bullets.append("Scoring:")
            bullets.append(contentsOf: segment.scoring.map { "  - \($0)" })
        }
        
        // Add safety notes
        if !segment.contraindications.isEmpty {
            bullets.append("⚠️ Safety:")
            bullets.append(contentsOf: segment.contraindications.map { "  - \($0)" })
        }
        
        // Build primary line (segment name)
        let primary = segment.name
        
        // Build secondary line (time + rounds)
        var secondaryParts: [String] = []
        if let duration = segment.durationMinutes {
            secondaryParts.append("\(duration) min")
        }
        if let rounds = segment.rounds, let roundDuration = segment.roundDurationSeconds {
            let roundTime = formatSeconds(roundDuration)
            secondaryParts.append("\(rounds) rounds × \(roundTime)")
        } else if let rounds = segment.rounds {
            secondaryParts.append("\(rounds) rounds")
        }
        
        let secondary = secondaryParts.isEmpty ? nil : secondaryParts.joined(separator: " • ")
        
        // Build tertiary line (rest period)
        var tertiary: String? = nil
        if let rest = segment.restSeconds, rest > 0 {
            tertiary = "Rest: \(formatSeconds(rest))"
        }
        
        // Add notes to bullets if present
        if let notes = segment.notes {
            bullets.append("Notes: \(notes)")
        }
        
        return WhiteboardItem(
            primary: primary,
            secondary: secondary,
            tertiary: tertiary,
            bullets: bullets
        )
    }
    
    // MARK: - Partitioning
    
    /// Partition exercises into strength and conditioning
    private static func partitionExercises(_ exercises: [UnifiedExercise]) -> ([UnifiedExercise], [UnifiedExercise]) {
        var strength: [UnifiedExercise] = []
        var conditioning: [UnifiedExercise] = []
        
        for exercise in exercises {
            if exercise.type == "conditioning" || !exercise.conditioningSets.isEmpty {
                conditioning.append(exercise)
            } else {
                strength.append(exercise)
            }
        }
        
        return (strength, conditioning)
    }
    
    /// Partition strength exercises into main lifts vs accessories
    private static func partitionStrengthExercises(_ exercises: [UnifiedExercise]) -> ([UnifiedExercise], [UnifiedExercise]) {
        var mainLifts: [UnifiedExercise] = []
        var accessories: [UnifiedExercise] = []
        
        for exercise in exercises {
            if isMainLift(exercise) {
                mainLifts.append(exercise)
            } else {
                accessories.append(exercise)
            }
        }
        
        return (mainLifts, accessories)
    }
    
    /// Heuristic to determine if an exercise is a main lift
    private static func isMainLift(_ exercise: UnifiedExercise) -> Bool {
        // Main lift categories
        let mainLiftCategories = ["squat", "hinge", "pressHorizontal", "pressVertical", "olympic"]
        
        if let category = exercise.category, mainLiftCategories.contains(category) {
            return true
        }
        
        // Check set count (5+ sets typically indicates main work)
        if exercise.strengthSets.count >= 5 {
            return true
        }
        
        // Check if grouped exercises (supersets/circuits are usually accessories)
        if exercise.setGroupId != nil {
            return false
        }
        
        return false
    }
    
    // MARK: - Strength Formatting
    
    /// Format a strength exercise into a whiteboard item
    private static func formatStrengthExercise(_ exercise: UnifiedExercise) -> WhiteboardItem {
        let primary = exercise.name
        
        // Format secondary (prescription)
        let secondary = formatStrengthPrescription(exercise)
        
        // Format tertiary (rest)
        let tertiary = formatRest(exercise.strengthSets.first?.restSeconds)
        
        return WhiteboardItem(
            primary: primary,
            secondary: secondary,
            tertiary: tertiary,
            bullets: []
        )
    }
    
    /// Format strength prescription (sets x reps @ weight/intensity)
    private static func formatStrengthPrescription(_ exercise: UnifiedExercise) -> String? {
        let sets = exercise.strengthSets
        
        guard !sets.isEmpty else {
            return nil
        }
        
        // Check if all reps are the same
        let repsValues = sets.compactMap { $0.reps }
        let allSame = Set(repsValues).count == 1
        
        let prescription: String
        if allSame, let reps = repsValues.first {
            prescription = "\(sets.count) × \(reps)"
        } else if !repsValues.isEmpty {
            let repsString = repsValues.map { String($0) }.joined(separator: "/")
            prescription = "\(sets.count) sets: \(repsString)"
        } else {
            prescription = "\(sets.count) sets"
        }
        
        // Add weight if present (check if any sets have weight)
        let weightValues = sets.compactMap { $0.weight }
        var result = prescription
        
        if !weightValues.isEmpty {
            // Check if all weights are the same
            let uniqueWeights = Set(weightValues)
            if uniqueWeights.count == 1, let weight = weightValues.first {
                result += " @ \(formatWeight(weight)) lbs"
            } else if weightValues.count == sets.count {
                // All sets have weights but they vary - show breakdown
                let weightsString = weightValues.map { formatWeight($0) }.joined(separator: "/")
                result += " @ \(weightsString) lbs"
            }
        }
        
        // Add intensity cue from notes if present
        if let notes = exercise.notes, notes.contains("RPE") {
            result += " \(notes)"
        }
        
        return result
    }
    
    /// Format weight value (remove .0 if it's a whole number)
    private static func formatWeight(_ weight: Double) -> String {
        return weight.truncatingRemainder(dividingBy: 1) == 0 
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }
    
    // MARK: - Conditioning Formatting
    
    /// Format a conditioning exercise into a whiteboard item
    private static func formatConditioningExercise(_ exercise: UnifiedExercise) -> WhiteboardItem {
        let primary = exercise.name
        let condType = exercise.conditioningType ?? "other"
        
        var secondary: String?
        var bullets: [String] = []
        
        guard let firstSet = exercise.conditioningSets.first else {
            return WhiteboardItem(primary: primary)
        }
        
        switch condType.lowercased() {
        case "amrap":
            secondary = formatAMRAP(firstSet)
            bullets = combineNotesIntoBullets(exerciseNotes: exercise.notes, setNotes: firstSet.notes)
            
        case "emom":
            secondary = formatEMOM(firstSet)
            bullets = combineNotesIntoBullets(exerciseNotes: exercise.notes, setNotes: firstSet.notes)
            
        case "intervals":
            secondary = formatIntervals(firstSet)
            bullets = formatIntervalBullets(firstSet)
            
        case "roundsfortime":
            secondary = formatRoundsForTime(firstSet)
            bullets = combineNotesIntoBullets(exerciseNotes: exercise.notes, setNotes: firstSet.notes)
            
        case "fortime":
            secondary = formatForTime(firstSet)
            bullets = combineNotesIntoBullets(exerciseNotes: exercise.notes, setNotes: firstSet.notes)
            
        case "fordistance":
            secondary = formatForDistance(firstSet)
            bullets = combineNotesIntoBullets(exerciseNotes: exercise.notes, setNotes: firstSet.notes)
            
        case "forcalories":
            secondary = formatForCalories(firstSet)
            bullets = combineNotesIntoBullets(exerciseNotes: exercise.notes, setNotes: firstSet.notes)
            
        default:
            secondary = formatGenericConditioning(firstSet)
            bullets = combineNotesIntoBullets(exerciseNotes: exercise.notes, setNotes: firstSet.notes)
        }
        
        let tertiary = formatRest(firstSet.restSeconds)
        
        return WhiteboardItem(
            primary: primary,
            secondary: secondary,
            tertiary: tertiary,
            bullets: bullets
        )
    }
    
    /// Format AMRAP prescription
    private static func formatAMRAP(_ set: UnifiedConditioningSet) -> String {
        if let duration = set.durationSeconds {
            let minutes = duration / 60
            return "\(minutes) min AMRAP"
        }
        return "AMRAP"
    }
    
    /// Format EMOM prescription
    private static func formatEMOM(_ set: UnifiedConditioningSet) -> String {
        if let duration = set.durationSeconds {
            let minutes = duration / 60
            return "EMOM \(minutes) min"
        }
        return "EMOM"
    }
    
    /// Format intervals prescription
    private static func formatIntervals(_ set: UnifiedConditioningSet) -> String {
        if let rounds = set.rounds {
            return "\(rounds) rounds"
        }
        return "Intervals"
    }
    
    /// Format interval bullets (work/rest)
    private static func formatIntervalBullets(_ set: UnifiedConditioningSet) -> [String] {
        var bullets: [String] = []
        
        if let duration = set.durationSeconds {
            let effort = set.effortDescriptor ?? ""
            bullets.append(":\(formatSeconds(duration)) \(effort)".trimmingCharacters(in: .whitespaces))
        }
        
        if let rest = set.restSeconds {
            bullets.append(":\(formatSeconds(rest)) rest")
        }
        
        if let notes = set.notes, !notes.isEmpty {
            bullets.append(notes)
        }
        
        return bullets
    }
    
    /// Format rounds for time
    private static func formatRoundsForTime(_ set: UnifiedConditioningSet) -> String {
        if let rounds = set.rounds {
            return "\(rounds) Rounds For Time"
        }
        return "For Time"
    }
    
    /// Format for time
    private static func formatForTime(_ set: UnifiedConditioningSet) -> String {
        var parts: [String] = []
        
        if let distance = set.distanceMeters {
            parts.append("\(Int(distance))m")
        }
        
        if let duration = set.durationSeconds {
            parts.append("\(formatSeconds(duration))")
        }
        
        if parts.isEmpty {
            return "For Time"
        }
        
        return "For Time — \(parts.joined(separator: " • "))"
    }
    
    /// Format for distance
    private static func formatForDistance(_ set: UnifiedConditioningSet) -> String {
        if let distance = set.distanceMeters {
            return "For Distance — \(Int(distance))m"
        }
        return "For Distance"
    }
    
    /// Format for calories
    private static func formatForCalories(_ set: UnifiedConditioningSet) -> String {
        if let calories = set.calories {
            return "For Calories — \(Int(calories)) cal"
        }
        return "For Calories"
    }
    
    /// Format generic conditioning
    private static func formatGenericConditioning(_ set: UnifiedConditioningSet) -> String? {
        var parts: [String] = []
        
        if let duration = set.durationSeconds {
            parts.append(formatSeconds(duration))
        }
        
        if let distance = set.distanceMeters {
            parts.append("\(Int(distance))m")
        }
        
        if let calories = set.calories {
            parts.append("\(Int(calories)) cal")
        }
        
        if let rounds = set.rounds {
            parts.append("\(rounds) rounds")
        }
        
        return parts.isEmpty ? nil : parts.joined(separator: " • ")
    }
    
    // MARK: - Helper Functions
    
    /// Format rest seconds into M:SS format
    private static func formatRest(_ restSeconds: Int?) -> String? {
        guard let rest = restSeconds, rest > 0 else { return nil }
        
        let minutes = rest / 60
        let seconds = rest % 60
        
        return String(format: "Rest: %d:%02d", minutes, seconds)
    }
    
    /// Format seconds into MM:SS or HH:MM:SS
    private static func formatSeconds(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    /// Combine exercise-level and set-level notes into bullet points
    private static func combineNotesIntoBullets(exerciseNotes: String?, setNotes: String?) -> [String] {
        var bullets: [String] = []
        
        // Add exercise-level notes first
        if let exerciseNotes = exerciseNotes, !exerciseNotes.isEmpty {
            bullets.append(contentsOf: parseNotesIntoBullets(exerciseNotes))
        }
        
        // Add set-level notes using the same parsing logic
        if let setNotes = setNotes, !setNotes.isEmpty {
            let setParsedNotes = parseNotesIntoBullets(setNotes)
            // Only add notes that aren't duplicates
            for note in setParsedNotes {
                if !bullets.contains(note) {
                    bullets.append(note)
                }
            }
        }
        
        return bullets
    }
    
    /// Parse notes into bullet points
    private static func parseNotesIntoBullets(_ notes: String?) -> [String] {
        guard let notes = notes, !notes.isEmpty else { return [] }
        
        // Split by common separators (newlines, commas, semicolons)
        let separators = CharacterSet(charactersIn: ",\n;")
        let components = notes.components(separatedBy: separators)
        
        var bullets: [String] = []
        
        for component in components {
            let trimmed = component.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty strings
            guard !trimmed.isEmpty else { continue }
            
            // Check if it looks like a circuit movement (e.g., "10 Burpees", "15 KB Swings")
            // Pattern: starts with a number or contains common exercise terms
            let looksLikeMovement = trimmed.range(of: "^\\d+", options: .regularExpression) != nil ||
                                   trimmed.lowercased().contains("burpee") ||
                                   trimmed.lowercased().contains("swing") ||
                                   trimmed.lowercased().contains("jump") ||
                                   trimmed.lowercased().contains("squat") ||
                                   trimmed.lowercased().contains("pull") ||
                                   trimmed.lowercased().contains("push") ||
                                   trimmed.lowercased().contains("row") ||
                                   trimmed.lowercased().contains("run") ||
                                   trimmed.lowercased().contains("cal")
            
            if looksLikeMovement {
                bullets.append(trimmed)
            } else {
                // If it doesn't look like a movement, still include it
                bullets.append(trimmed)
            }
        }
        
        return bullets
    }
}

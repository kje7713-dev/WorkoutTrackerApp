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
        
        // Note: Segments are rendered separately as collapsible cards in the whiteboard view,
        // so we don't format them here to avoid duplication.
        
        // Partition exercises
        let (strengthExercises, conditioningExercises) = partitionExercises(day.exercises)
        
        // Group exercises by setGroupId to keep supersets together
        let groupedStrength = groupExercisesBySetGroup(strengthExercises)
        
        // Further partition strength into main lifts vs accessories
        let (mainLifts, accessories) = partitionStrengthExercises(groupedStrength)
        
        // Build sections
        if !mainLifts.isEmpty {
            sections.append(WhiteboardSection(
                title: "Strength",
                items: formatStrengthExerciseGroups(mainLifts)
            ))
        }
        
        if !accessories.isEmpty {
            sections.append(WhiteboardSection(
                title: "Accessory",
                items: formatStrengthExerciseGroups(accessories)
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
    
    /// Group exercises that share a setGroupId together
    private static func groupExercisesBySetGroup(_ exercises: [UnifiedExercise]) -> [[UnifiedExercise]] {
        var groups: [[UnifiedExercise]] = []
        var currentGroup: [UnifiedExercise] = []
        var currentGroupId: String? = nil
        
        for exercise in exercises {
            if let groupId = exercise.setGroupId {
                if groupId == currentGroupId {
                    // Continue current group
                    currentGroup.append(exercise)
                } else {
                    // Start a new group
                    if !currentGroup.isEmpty {
                        groups.append(currentGroup)
                    }
                    currentGroup = [exercise]
                    currentGroupId = groupId
                }
            } else {
                // Non-grouped exercise
                if !currentGroup.isEmpty {
                    groups.append(currentGroup)
                    currentGroup = []
                    currentGroupId = nil
                }
                groups.append([exercise])
            }
        }
        
        // Add final group if any
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }
        
        return groups
    }
    
    /// Partition strength exercise groups into main lifts vs accessories
    private static func partitionStrengthExercises(_ exerciseGroups: [[UnifiedExercise]]) -> ([[UnifiedExercise]], [[UnifiedExercise]]) {
        var mainLifts: [[UnifiedExercise]] = []
        var accessories: [[UnifiedExercise]] = []
        
        for group in exerciseGroups {
            // Classify the group based on whether ANY exercise in the group is a main lift
            // This keeps superset groups together even if exercises have different classifications
            let hasMainLift = group.contains { isMainLift($0) }
            
            if hasMainLift {
                mainLifts.append(group)
            } else {
                accessories.append(group)
            }
        }
        
        return (mainLifts, accessories)
    }
    
    /// Heuristic to determine if an exercise is a main lift
    private static func isMainLift(_ exercise: UnifiedExercise) -> Bool {
        // Main lift categories (primary compound movements)
        let mainLiftCategories = ["squat", "hinge", "pressHorizontal", "pressVertical", "olympic"]
        
        if let category = exercise.category, mainLiftCategories.contains(category) {
            return true
        }
        
        // Check set count (5+ sets typically indicates main work)
        if exercise.strengthSets.count >= 5 {
            return true
        }
        
        return false
    }
    
    // MARK: - Strength Formatting
    
    /// Format strength exercise groups into whiteboard items
    private static func formatStrengthExerciseGroups(_ exerciseGroups: [[UnifiedExercise]]) -> [WhiteboardItem] {
        var items: [WhiteboardItem] = []
        var supersetGroupIndex = 0  // Track which superset group we're on (0=A, 1=B, 2=C, etc.)
        
        for group in exerciseGroups {
            if group.count > 1 {
                // This is a superset/circuit group - label them A1/A2, B1/B2, etc.
                // Get the letter for this superset group (A, B, C, D, ...)
                let groupLetter = Character(UnicodeScalar(65 + supersetGroupIndex)!)  // 65 is 'A' in ASCII
                
                for (index, exercise) in group.enumerated() {
                    let label = "\(groupLetter)\(index + 1)"  // A1, A2, A3... or B1, B2, B3...
                    items.append(formatStrengthExercise(exercise, label: label))
                }
                
                supersetGroupIndex += 1  // Move to next letter for next superset group
            } else if let exercise = group.first {
                // Single exercise
                items.append(formatStrengthExercise(exercise))
            }
        }
        
        return items
    }
    
    /// Format a strength exercise into a whiteboard item
    private static func formatStrengthExercise(_ exercise: UnifiedExercise, label: String? = nil) -> WhiteboardItem {
        var primary = exercise.name
        
        // Add label prefix for superset exercises (A1, A2, B1, B2, etc.)
        if let label = label {
            primary = "\(label)) \(primary)"
        }
        
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

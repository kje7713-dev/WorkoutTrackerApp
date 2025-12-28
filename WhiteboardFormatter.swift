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
    
    /// Format strength prescription (sets x reps @ intensity)
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
        
        // Add intensity cue from notes if present
        if let notes = exercise.notes, notes.contains("RPE") {
            return "\(prescription) \(notes)"
        }
        
        return prescription
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
            bullets = parseNotesIntoBullets(exercise.notes)
            
        case "emom":
            secondary = formatEMOM(firstSet)
            bullets = parseNotesIntoBullets(exercise.notes)
            
        case "intervals":
            secondary = formatIntervals(firstSet)
            bullets = formatIntervalBullets(firstSet)
            
        case "roundsfortime":
            secondary = formatRoundsForTime(firstSet)
            bullets = parseNotesIntoBullets(exercise.notes)
            
        case "fortime":
            secondary = formatForTime(firstSet)
            bullets = parseNotesIntoBullets(exercise.notes)
            
        case "fordistance":
            secondary = formatForDistance(firstSet)
            bullets = parseNotesIntoBullets(exercise.notes)
            
        case "forcalories":
            secondary = formatForCalories(firstSet)
            bullets = parseNotesIntoBullets(exercise.notes)
            
        default:
            secondary = formatGenericConditioning(firstSet)
            bullets = parseNotesIntoBullets(exercise.notes)
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
    
    /// Parse notes into bullet points
    private static func parseNotesIntoBullets(_ notes: String?) -> [String] {
        guard let notes = notes, !notes.isEmpty else { return [] }
        
        // Split by common separators
        let separators = [",", "\n", ";"]
        var bullets = [notes]
        
        for separator in separators {
            bullets = bullets.flatMap { $0.components(separatedBy: separator) }
        }
        
        return bullets
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

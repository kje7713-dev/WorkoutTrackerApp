//
//  ChatGPTBlockParser.swift
//  Savage By Design
//
//  Parser for converting ChatGPT responses into Block models
//

import Foundation

// MARK: - System Prompt Template

public struct ChatGPTPrompts {
    
    /// System message that defines the exact format for workout block generation
    public static let systemPrompt = """
You are an expert strength and conditioning coach. Generate workout training blocks in a structured, human-readable format.

Output Format:
================

BLOCK: [Block Name]
DESCRIPTION: [Optional description]
WEEKS: [Number]
GOAL: [strength|hypertrophy|power|conditioning|mixed|peaking|deload|rehab]

DAY 1: [Day Name]
SHORT: [D1]
GOAL: [Optional day-level goal]
---
Exercise: [Exercise Name]
Type: [strength|conditioning]
Category: [squat|hinge|pressHorizontal|pressVertical|pullHorizontal|pullVertical|carry|core|olympic|conditioning|mobility|mixed|other]
Sets: [Number] x Reps: [Number]
Weight: [Number] OR %Max: [Number]
RPE: [1-10] OR RIR: [0-5]
Tempo: [e.g., 3010]
Rest: [seconds]
Progression: +[weight per week] OR +[sets per week]
Notes: [Optional notes]
---
Exercise: [Next Exercise]
[... repeat for all exercises ...]

DAY 2: [Day Name]
[... repeat for all days ...]

For conditioning exercises:
Type: conditioning
ConditioningType: [monostructural|mixedModal|emom|amrap|intervals|forTime|forDistance|forCalories|roundsForTime|other]
Duration: [minutes]
Distance: [meters]
Calories: [number]
Rounds: [number]
Pace: [e.g., 2:00/500m]
Effort: [easy|moderate|hard]
Rest: [seconds]
Notes: [EMOM/AMRAP/pacing details]

Rules:
1. Always include BLOCK, WEEKS, and at least one DAY
2. Each exercise must have a name and type
3. For strength: include Sets, Reps; optional: Weight/%Max, RPE/RIR, Tempo, Rest
4. For conditioning: include relevant fields (Duration/Distance/Calories/Rounds)
5. Use "---" to separate exercises
6. Use clear headers for BLOCK and DAY sections
7. Progression should specify either weight or volume increase per week
"""
    
    /// Helper to create a user prompt for block generation
    public static func userPrompt(for request: String) -> String {
        return request
    }
}

// MARK: - Block Parser

public class ChatGPTBlockParser {
    
    public init() {}
    
    // MARK: - Parse Block
    
    /// Parse ChatGPT response text into a Block model
    /// - Parameter text: The response text from ChatGPT
    /// - Returns: A parsed Block model
    /// - Throws: ChatGPTError if parsing fails
    public func parseBlock(from text: String) throws -> Block {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        var blockName: String?
        var blockDescription: String?
        var numberOfWeeks: Int = 4 // default
        var blockGoal: TrainingGoal?
        var days: [DayTemplate] = []
        
        var currentDay: ParsedDay?
        var currentExercise: ParsedExercise?
        
        var i = 0
        while i < lines.count {
            let line = lines[i]
            
            // Skip empty lines
            if line.isEmpty {
                i += 1
                continue
            }
            
            // Parse block metadata
            if line.hasPrefix("BLOCK:") {
                blockName = line.replacingOccurrences(of: "BLOCK:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("DESCRIPTION:") {
                blockDescription = line.replacingOccurrences(of: "DESCRIPTION:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("WEEKS:") {
                let weeksStr = line.replacingOccurrences(of: "WEEKS:", with: "").trimmingCharacters(in: .whitespaces)
                numberOfWeeks = Int(weeksStr) ?? 4
            } else if line.hasPrefix("GOAL:") {
                let goalStr = line.replacingOccurrences(of: "GOAL:", with: "").trimmingCharacters(in: .whitespaces).lowercased()
                blockGoal = TrainingGoal(rawValue: goalStr)
            }
            
            // Parse day header
            else if line.hasPrefix("DAY") && line.contains(":") {
                // Save previous day if exists
                if let day = currentDay {
                    if let exercise = currentExercise {
                        day.exercises.append(exercise)
                        currentExercise = nil
                    }
                    days.append(day.toDayTemplate())
                }
                
                let parts = line.components(separatedBy: ":")
                let dayName = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) : "Day \(days.count + 1)"
                currentDay = ParsedDay(name: dayName)
                currentExercise = nil
            }
            
            // Parse day metadata
            else if line.hasPrefix("SHORT:") {
                currentDay?.shortCode = line.replacingOccurrences(of: "SHORT:", with: "").trimmingCharacters(in: .whitespaces)
            }
            
            // Exercise separator
            else if line == "---" {
                // Save previous exercise if exists
                if let exercise = currentExercise {
                    currentDay?.exercises.append(exercise)
                }
                currentExercise = ParsedExercise()
            }
            
            // Parse exercise fields
            else if line.hasPrefix("Exercise:") {
                // Save previous exercise if starting a new one without ---
                if let exercise = currentExercise {
                    currentDay?.exercises.append(exercise)
                }
                currentExercise = ParsedExercise()
                currentExercise?.name = line.replacingOccurrences(of: "Exercise:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("Type:") {
                let typeStr = line.replacingOccurrences(of: "Type:", with: "").trimmingCharacters(in: .whitespaces).lowercased()
                currentExercise?.type = ExerciseType(rawValue: typeStr) ?? .strength
            } else if line.hasPrefix("Category:") {
                let catStr = line.replacingOccurrences(of: "Category:", with: "").trimmingCharacters(in: .whitespaces)
                currentExercise?.category = ExerciseCategory(rawValue: catStr)
            } else if line.hasPrefix("ConditioningType:") {
                let condTypeStr = line.replacingOccurrences(of: "ConditioningType:", with: "").trimmingCharacters(in: .whitespaces)
                currentExercise?.conditioningType = ConditioningType(rawValue: condTypeStr)
            } else if line.contains("Sets:") && line.contains("Reps:") {
                // Parse "Sets: X x Reps: Y" or "Sets: X Reps: Y"
                // Extract just the numbers after Sets: and Reps:
                if let setsRange = line.range(of: "Sets:") {
                    let afterSets = String(line[setsRange.upperBound...])
                    let setsNumber = afterSets.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    if let sets = Int(setsNumber), sets > 0 {
                        currentExercise?.sets = sets
                    }
                }
                if let repsRange = line.range(of: "Reps:") {
                    let afterReps = String(line[repsRange.upperBound...])
                    let repsNumber = afterReps.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    if let reps = Int(repsNumber), reps > 0 {
                        currentExercise?.reps = reps
                    }
                }
            } else if line.hasPrefix("Weight:") {
                let weightStr = line.replacingOccurrences(of: "Weight:", with: "").trimmingCharacters(in: .whitespaces)
                currentExercise?.weight = Double(weightStr)
            } else if line.hasPrefix("%Max:") {
                let pctStr = line.replacingOccurrences(of: "%Max:", with: "").trimmingCharacters(in: .whitespaces)
                currentExercise?.percentageOfMax = Double(pctStr)
            } else if line.hasPrefix("RPE:") {
                let rpeStr = line.replacingOccurrences(of: "RPE:", with: "").trimmingCharacters(in: .whitespaces)
                currentExercise?.rpe = Double(rpeStr)
            } else if line.hasPrefix("RIR:") {
                let rirStr = line.replacingOccurrences(of: "RIR:", with: "").trimmingCharacters(in: .whitespaces)
                currentExercise?.rir = Double(rirStr)
            } else if line.hasPrefix("Tempo:") {
                currentExercise?.tempo = line.replacingOccurrences(of: "Tempo:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("Rest:") {
                let restStr = line.replacingOccurrences(of: "Rest:", with: "").trimmingCharacters(in: .whitespaces)
                currentExercise?.restSeconds = Int(restStr)
            } else if line.hasPrefix("Duration:") {
                let durationStr = line.replacingOccurrences(of: "Duration:", with: "").trimmingCharacters(in: .whitespaces)
                // Parse minutes to seconds
                if let minutes = Int(durationStr) {
                    currentExercise?.durationSeconds = minutes * 60
                }
            } else if line.hasPrefix("Distance:") {
                let distStr = line.replacingOccurrences(of: "Distance:", with: "").trimmingCharacters(in: .whitespaces)
                currentExercise?.distanceMeters = Double(distStr)
            } else if line.hasPrefix("Calories:") {
                let calStr = line.replacingOccurrences(of: "Calories:", with: "").trimmingCharacters(in: .whitespaces)
                currentExercise?.calories = Double(calStr)
            } else if line.hasPrefix("Rounds:") {
                let roundsStr = line.replacingOccurrences(of: "Rounds:", with: "").trimmingCharacters(in: .whitespaces)
                currentExercise?.rounds = Int(roundsStr)
            } else if line.hasPrefix("Pace:") {
                currentExercise?.pace = line.replacingOccurrences(of: "Pace:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("Effort:") {
                currentExercise?.effort = line.replacingOccurrences(of: "Effort:", with: "").trimmingCharacters(in: .whitespaces)
            } else if line.hasPrefix("Progression:") {
                let progStr = line.replacingOccurrences(of: "Progression:", with: "").trimmingCharacters(in: .whitespaces)
                currentExercise?.progression = progStr
            } else if line.hasPrefix("Notes:") {
                currentExercise?.notes = line.replacingOccurrences(of: "Notes:", with: "").trimmingCharacters(in: .whitespaces)
            }
            
            i += 1
        }
        
        // Save last exercise and day
        if let exercise = currentExercise {
            currentDay?.exercises.append(exercise)
        }
        if let day = currentDay {
            days.append(day.toDayTemplate())
        }
        
        // Validate we have minimum required data
        guard let name = blockName, !name.isEmpty else {
            throw ChatGPTError.parsingError("Block name not found in response")
        }
        
        guard !days.isEmpty else {
            throw ChatGPTError.parsingError("No days found in response")
        }
        
        return Block(
            name: name,
            description: blockDescription,
            numberOfWeeks: numberOfWeeks,
            goal: blockGoal,
            days: days,
            source: .ai,
            aiMetadata: nil
        )
    }
}

// MARK: - Internal Parsing Helpers

private class ParsedDay {
    var name: String
    var shortCode: String?
    var goal: TrainingGoal?
    var exercises: [ParsedExercise] = []
    
    init(name: String) {
        self.name = name
    }
    
    func toDayTemplate() -> DayTemplate {
        let exerciseTemplates = exercises.map { $0.toExerciseTemplate() }
        return DayTemplate(
            name: name,
            shortCode: shortCode,
            goal: goal,
            notes: nil,
            exercises: exerciseTemplates
        )
    }
}

private class ParsedExercise {
    var name: String = ""
    var type: ExerciseType = .strength
    var category: ExerciseCategory?
    var conditioningType: ConditioningType?
    
    // Strength fields
    var sets: Int?
    var reps: Int?
    var weight: Double?
    var percentageOfMax: Double?
    var rpe: Double?
    var rir: Double?
    var tempo: String?
    var restSeconds: Int?
    
    // Conditioning fields
    var durationSeconds: Int?
    var distanceMeters: Double?
    var calories: Double?
    var rounds: Int?
    var pace: String?
    var effort: String?
    
    // Common fields
    var progression: String?
    var notes: String?
    
    func toExerciseTemplate() -> ExerciseTemplate {
        // Parse progression
        let progressionRule = parseProgressionRule()
        
        // Build sets based on type
        var strengthSets: [StrengthSetTemplate]?
        var conditioningSets: [ConditioningSetTemplate]?
        
        if type == .strength {
            let setCount = sets ?? 3
            let baseSet = StrengthSetTemplate(
                index: 0,
                reps: reps,
                weight: weight,
                percentageOfMax: percentageOfMax.map { $0 / 100.0 }, // Convert to 0-1 range
                rpe: rpe,
                rir: rir,
                tempo: tempo,
                restSeconds: restSeconds,
                notes: notes
            )
            strengthSets = (0..<setCount).map { idx in
                var copy = baseSet
                copy.index = idx
                return copy
            }
        } else if type == .conditioning {
            let baseSet = ConditioningSetTemplate(
                index: 0,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
                calories: calories,
                rounds: rounds,
                targetPace: pace,
                effortDescriptor: effort,
                restSeconds: restSeconds,
                notes: notes
            )
            conditioningSets = [baseSet]
        }
        
        return ExerciseTemplate(
            exerciseDefinitionId: nil,
            customName: name.isEmpty ? "Unnamed Exercise" : name,
            type: type,
            category: category,
            conditioningType: conditioningType,
            notes: notes,
            setGroupId: nil,
            strengthSets: strengthSets,
            conditioningSets: conditioningSets,
            genericSets: nil,
            progressionRule: progressionRule
        )
    }
    
    private func parseProgressionRule() -> ProgressionRule {
        guard let prog = progression, !prog.isEmpty else {
            return ProgressionRule(type: .weight, deltaWeight: nil, deltaSets: nil)
        }
        
        // Extract numeric value first (handles +5, 5, +2.5, etc.)
        let allowedChars = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
        let numericString = prog.components(separatedBy: allowedChars.inverted)
            .filter { !$0.isEmpty }
            .joined()
        
        // Parse "+1 set" or "+2 sets" for volume
        if prog.lowercased().contains("set") {
            if let delta = Int(numericString) {
                return ProgressionRule(type: .volume, deltaWeight: nil, deltaSets: delta)
            }
        }
        
        // Parse "+5 lbs" or "+2.5" for weight
        if let delta = Double(numericString), delta > 0 {
            return ProgressionRule(type: .weight, deltaWeight: delta, deltaSets: nil)
        }
        
        return ProgressionRule(type: .custom, deltaWeight: nil, deltaSets: nil)
    }
}

//
//  BlockGenerator.swift
//  Savage By Design – AI Block Parser and Mapper
//
//  Two-stage parser: Primary JSON parser with fallback to HumanReadable section.
//  Maps ImportedBlock DTO to app's Block model.
//

import Foundation

// MARK: - Imported Block DTOs

/// DTO matching the JSON schema from ChatGPT
public struct ImportedBlock: Codable {
    public var Title: String
    public var Goal: String
    public var TargetAthlete: String
    public var DurationMinutes: Int
    public var Difficulty: Int
    public var Equipment: String
    public var WarmUp: String
    public var Exercises: [ImportedExercise]
    public var Finisher: String
    public var Notes: String
    public var EstimatedTotalTimeMinutes: Int
    public var Progression: String
    
    public init(
        Title: String,
        Goal: String,
        TargetAthlete: String,
        DurationMinutes: Int,
        Difficulty: Int,
        Equipment: String,
        WarmUp: String,
        Exercises: [ImportedExercise],
        Finisher: String,
        Notes: String,
        EstimatedTotalTimeMinutes: Int,
        Progression: String
    ) {
        self.Title = Title
        self.Goal = Goal
        self.TargetAthlete = TargetAthlete
        self.DurationMinutes = DurationMinutes
        self.Difficulty = Difficulty
        self.Equipment = Equipment
        self.WarmUp = WarmUp
        self.Exercises = Exercises
        self.Finisher = Finisher
        self.Notes = Notes
        self.EstimatedTotalTimeMinutes = EstimatedTotalTimeMinutes
        self.Progression = Progression
    }
}

public struct ImportedExercise: Codable {
    public var name: String
    public var setsReps: String
    public var restSeconds: Int
    public var intensityCue: String
    
    public init(
        name: String,
        setsReps: String,
        restSeconds: Int,
        intensityCue: String
    ) {
        self.name = name
        self.setsReps = setsReps
        self.restSeconds = restSeconds
        self.intensityCue = intensityCue
    }
}

// MARK: - Block Generator Errors

public enum BlockGeneratorError: Error, LocalizedError {
    case noJSONSection
    case jsonDecodeFailed(Error)
    case humanReadableParseFailedPartial(String)
    case humanReadableParseFailed
    case invalidFormat(String)
    
    public var errorDescription: String? {
        switch self {
        case .noJSONSection:
            return "No JSON section found (missing 'JSON:' marker)"
        case .jsonDecodeFailed(let error):
            return "JSON decode failed: \(error.localizedDescription)"
        case .humanReadableParseFailedPartial(let details):
            return "Human-readable parsing failed: \(details)"
        case .humanReadableParseFailed:
            return "Human-readable parsing failed: could not extract required fields"
        case .invalidFormat(let details):
            return "Invalid format: \(details)"
        }
    }
}

// MARK: - Block Generator

public struct BlockGenerator {
    
    // MARK: - Main Decode Method
    
    /// Decode a block from ChatGPT response text
    /// Primary: Try JSON section parsing
    /// Secondary: Fall back to HumanReadable section parsing
    public static func decodeBlock(from text: String) -> Result<ImportedBlock, BlockGeneratorError> {
        // Primary: Try JSON section
        if let jsonResult = tryParseJSONSection(from: text) {
            return jsonResult
        }
        
        // Secondary: Fall back to HumanReadable section
        return parseHumanReadableSection(from: text)
    }
    
    // MARK: - Primary Parser: JSON Section
    
    /// Try to find and parse the JSON section
    /// Looks for a line beginning with "JSON:" (case-sensitive)
    /// Then finds the first '{' after that marker and attempts to decode
    private static func tryParseJSONSection(from text: String) -> Result<ImportedBlock, BlockGeneratorError>? {
        let lines = text.components(separatedBy: .newlines)
        
        // Find the line with "JSON:" marker
        var jsonStartIndex: Int?
        for (index, line) in lines.enumerated() {
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("JSON:") {
                jsonStartIndex = index
                break
            }
        }
        
        guard let startIndex = jsonStartIndex else {
            return nil // No JSON section found
        }
        
        // Collect lines after "JSON:" marker
        let remainingLines = lines[startIndex...].joined(separator: "\n")
        
        // Find the first '{' character
        guard let braceIndex = remainingLines.firstIndex(of: "{") else {
            return .failure(.noJSONSection)
        }
        
        // Extract JSON string from first brace to end
        let jsonString = String(remainingLines[braceIndex...])
        
        // Try to find matching closing brace
        let jsonData: Data
        if let jsonSubstring = extractValidJSON(from: jsonString) {
            guard let data = jsonSubstring.data(using: .utf8) else {
                return .failure(.invalidFormat("Could not convert JSON string to data"))
            }
            jsonData = data
        } else {
            // Fall back to using entire string
            guard let data = jsonString.data(using: .utf8) else {
                return .failure(.invalidFormat("Could not convert JSON string to data"))
            }
            jsonData = data
        }
        
        // Decode JSON
        do {
            let decoder = JSONDecoder()
            let imported = try decoder.decode(ImportedBlock.self, from: jsonData)
            return .success(imported)
        } catch {
            return .failure(.jsonDecodeFailed(error))
        }
    }
    
    /// Extract valid JSON by finding matching braces
    private static func extractValidJSON(from text: String) -> String? {
        var depth = 0
        var startIndex: String.Index?
        var endIndex: String.Index?
        
        for index in text.indices {
            let char = text[index]
            if char == "{" {
                if startIndex == nil {
                    startIndex = index
                }
                depth += 1
            } else if char == "}" {
                depth -= 1
                if depth == 0 && startIndex != nil {
                    endIndex = index
                    break
                }
            }
        }
        
        if let start = startIndex, let end = endIndex {
            return String(text[start...end])
        }
        return nil
    }
    
    // MARK: - Secondary Parser: HumanReadable Section
    
    /// Parse the HumanReadable section using exact header order
    /// Headers: Title, Goal, Target Athlete, Duration, Difficulty, Equipment, Warm-Up, Exercises, Finisher, Notes, Estimated Total Time, Progression
    private static func parseHumanReadableSection(from text: String) -> Result<ImportedBlock, BlockGeneratorError> {
        let lines = text.components(separatedBy: .newlines)
        
        var title = ""
        var goal = ""
        var targetAthlete = ""
        var durationMinutes = 0
        var difficulty = 3
        var equipment = ""
        var warmUp = ""
        var exercises: [ImportedExercise] = []
        var finisher = ""
        var notes = ""
        var estimatedTotalTimeMinutes = 0
        var progression = ""
        
        var inExercises = false
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.isEmpty { continue }
            
            // Check for headers
            if trimmed.hasPrefix("Title:") {
                title = extractValue(from: trimmed, after: "Title:")
                inExercises = false
            } else if trimmed.hasPrefix("Goal:") {
                goal = extractValue(from: trimmed, after: "Goal:")
                inExercises = false
            } else if trimmed.hasPrefix("Target Athlete:") {
                targetAthlete = extractValue(from: trimmed, after: "Target Athlete:")
                inExercises = false
            } else if trimmed.hasPrefix("Duration (minutes):") || trimmed.hasPrefix("Duration:") {
                let valueStr = trimmed.hasPrefix("Duration (minutes):") 
                    ? extractValue(from: trimmed, after: "Duration (minutes):")
                    : extractValue(from: trimmed, after: "Duration:")
                // Extract first number only to avoid concatenating multiple numbers
                durationMinutes = extractFirstNumber(from: valueStr)
                inExercises = false
            } else if trimmed.hasPrefix("Difficulty (1-5):") || trimmed.hasPrefix("Difficulty:") {
                let valueStr = trimmed.hasPrefix("Difficulty (1-5):")
                    ? extractValue(from: trimmed, after: "Difficulty (1-5):")
                    : extractValue(from: trimmed, after: "Difficulty:")
                // Extract first number only
                difficulty = extractFirstNumber(from: valueStr)
                if difficulty < 1 { difficulty = 1 }
                if difficulty > 5 { difficulty = 5 }
                inExercises = false
            } else if trimmed.hasPrefix("Equipment:") {
                equipment = extractValue(from: trimmed, after: "Equipment:")
                inExercises = false
            } else if trimmed.hasPrefix("Warm-Up:") {
                warmUp = extractValue(from: trimmed, after: "Warm-Up:")
                inExercises = false
            } else if trimmed.hasPrefix("Exercises:") {
                inExercises = true
            } else if trimmed.hasPrefix("Finisher:") {
                finisher = extractValue(from: trimmed, after: "Finisher:")
                inExercises = false
            } else if trimmed.hasPrefix("Notes:") {
                notes = extractValue(from: trimmed, after: "Notes:")
                inExercises = false
            } else if trimmed.hasPrefix("Estimated Total Time (minutes):") || trimmed.hasPrefix("Estimated Total Time:") {
                let valueStr = trimmed.hasPrefix("Estimated Total Time (minutes):")
                    ? extractValue(from: trimmed, after: "Estimated Total Time (minutes):")
                    : extractValue(from: trimmed, after: "Estimated Total Time:")
                // Extract first number only
                estimatedTotalTimeMinutes = extractFirstNumber(from: valueStr)
                inExercises = false
            } else if trimmed.hasPrefix("Progression:") {
                progression = extractValue(from: trimmed, after: "Progression:")
                inExercises = false
            } else if inExercises && !trimmed.hasPrefix("-") && trimmed.contains("|") {
                // Parse exercise line: ExerciseName | SetsxReps | Rest(sec) | IntensityCue
                let parts = trimmed.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                if parts.count >= 3 {
                    let name = parts[0]
                    let setsReps = parts[1]
                    // Extract first number only for rest seconds
                    let rest = extractFirstNumber(from: parts[2])
                    let intensityCue = parts.count >= 4 ? parts[3] : ""
                    
                    exercises.append(ImportedExercise(
                        name: name,
                        setsReps: setsReps,
                        restSeconds: rest,
                        intensityCue: intensityCue
                    ))
                }
            }
        }
        
        // Validate required fields
        guard !title.isEmpty else {
            return .failure(.humanReadableParseFailedPartial("Title is missing"))
        }
        
        let imported = ImportedBlock(
            Title: title,
            Goal: goal,
            TargetAthlete: targetAthlete,
            DurationMinutes: durationMinutes,
            Difficulty: difficulty,
            Equipment: equipment,
            WarmUp: warmUp,
            Exercises: exercises,
            Finisher: finisher,
            Notes: notes,
            EstimatedTotalTimeMinutes: estimatedTotalTimeMinutes,
            Progression: progression
        )
        
        return .success(imported)
    }
    
    /// Extract value after a header
    private static func extractValue(from line: String, after header: String) -> String {
        guard let range = line.range(of: header) else { return "" }
        let value = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
        return value
    }
    
    /// Extract the first number from a string (avoids concatenating multiple numbers)
    private static func extractFirstNumber(from text: String) -> Int {
        // Use regex to find the first number in the string
        let pattern = "\\d+"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range, in: text) {
            return Int(text[range]) ?? 0
        }
        return 0
    }
    
    // MARK: - Converter: ImportedBlock -> Block
    
    /// Convert ImportedBlock DTO to app's Block model
    public static func convertToBlock(_ imported: ImportedBlock, numberOfWeeks: Int = 1) -> Block {
        // Create a single day template from the imported block
        let exercises = imported.Exercises.map { importedEx -> ExerciseTemplate in
            // Parse sets/reps string (e.g., "3x8", "4x10", "3X8")
            // Handle both lowercase 'x' and uppercase 'X'
            let normalizedSetsReps = importedEx.setsReps.lowercased()
            let components = normalizedSetsReps.split(separator: "x")
            let setsCount = components.first.flatMap { Int($0) } ?? 3
            let reps = components.count > 1 ? Int(components[1]) : nil
            
            // Create strength sets
            let strengthSets = (0..<setsCount).map { index in
                StrengthSetTemplate(
                    index: index,
                    reps: reps,
                    restSeconds: importedEx.restSeconds,
                    notes: importedEx.intensityCue
                )
            }
            
            // Create exercise template
            return ExerciseTemplate(
                customName: importedEx.name,
                type: .strength,
                notes: importedEx.intensityCue,
                strengthSets: strengthSets,
                progressionRule: ProgressionRule(
                    type: .weight,
                    deltaWeight: 5.0
                )
            )
        }
        
        // Build notes section
        var blockNotes = ""
        if !imported.WarmUp.isEmpty {
            blockNotes += "Warm-Up: \(imported.WarmUp)\n\n"
        }
        if !imported.Finisher.isEmpty {
            blockNotes += "Finisher: \(imported.Finisher)\n\n"
        }
        if !imported.Notes.isEmpty {
            blockNotes += "Notes: \(imported.Notes)\n\n"
        }
        if !imported.Progression.isEmpty {
            blockNotes += "Progression: \(imported.Progression)"
        }
        
        // Create day template
        let dayTemplate = DayTemplate(
            name: "Day 1",
            shortCode: "D1",
            notes: blockNotes.trimmingCharacters(in: .whitespacesAndNewlines),
            exercises: exercises
        )
        
        // Parse goal
        let goal = parseGoal(from: imported.Goal)
        
        // Create block
        let block = Block(
            name: imported.Title,
            description: "Target: \(imported.TargetAthlete)\nDuration: \(imported.DurationMinutes) min\nDifficulty: \(imported.Difficulty)/5\nEquipment: \(imported.Equipment)",
            numberOfWeeks: numberOfWeeks,
            goal: goal,
            days: [dayTemplate],
            source: .ai,
            aiMetadata: AIMetadata(
                prompt: "Generated block",
                createdAt: Date()
            )
        )
        
        return block
    }
    
    /// Parse training goal from string
    private static func parseGoal(from goalString: String) -> TrainingGoal? {
        let lower = goalString.lowercased()
        if lower.contains("strength") {
            return .strength
        } else if lower.contains("hypertrophy") || lower.contains("muscle") {
            return .hypertrophy
        } else if lower.contains("power") {
            return .power
        } else if lower.contains("conditioning") || lower.contains("cardio") {
            return .conditioning
        } else if lower.contains("mixed") {
            return .mixed
        }
        return nil
    }
}

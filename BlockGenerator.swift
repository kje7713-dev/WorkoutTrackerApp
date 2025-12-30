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
    public var Exercises: [ImportedExercise]?  // For single-day (legacy)
    public var Days: [ImportedDay]?            // For multi-day blocks (same days all weeks)
    public var Weeks: [[ImportedDay]]?         // For week-specific variations (NEW)
    public var Finisher: String
    public var Notes: String
    public var EstimatedTotalTimeMinutes: Int
    public var Progression: String
    public var NumberOfWeeks: Int?             // Optional: defaults to 1
    
    public init(
        Title: String,
        Goal: String,
        TargetAthlete: String,
        DurationMinutes: Int,
        Difficulty: Int,
        Equipment: String,
        WarmUp: String,
        Exercises: [ImportedExercise]? = nil,
        Days: [ImportedDay]? = nil,
        Weeks: [[ImportedDay]]? = nil,
        Finisher: String,
        Notes: String,
        EstimatedTotalTimeMinutes: Int,
        Progression: String,
        NumberOfWeeks: Int? = nil
    ) {
        self.Title = Title
        self.Goal = Goal
        self.TargetAthlete = TargetAthlete
        self.DurationMinutes = DurationMinutes
        self.Difficulty = Difficulty
        self.Equipment = Equipment
        self.WarmUp = WarmUp
        self.Exercises = Exercises
        self.Days = Days
        self.Weeks = Weeks
        self.Finisher = Finisher
        self.Notes = Notes
        self.EstimatedTotalTimeMinutes = EstimatedTotalTimeMinutes
        self.Progression = Progression
        self.NumberOfWeeks = NumberOfWeeks
    }
}

/// Imported Day structure for multi-day blocks
/// Supports both exercises and segments for comprehensive block import
public struct ImportedDay: Codable {
    public var name: String
    public var shortCode: String?
    public var goal: String?
    public var notes: String?
    public var exercises: [ImportedExercise]?  // Optional for segment-only days
    public var segments: [ImportedSegment]?    // For non-traditional sessions (BJJ, yoga, etc.)
    
    public init(
        name: String,
        shortCode: String? = nil,
        goal: String? = nil,
        notes: String? = nil,
        exercises: [ImportedExercise]? = nil,
        segments: [ImportedSegment]? = nil
    ) {
        self.name = name
        self.shortCode = shortCode
        self.goal = goal
        self.notes = notes
        self.exercises = exercises
        self.segments = segments
    }
}

// MARK: - Imported Segment Structures

/// Imported Segment for non-traditional sessions (BJJ, yoga, etc.)
public struct ImportedSegment: Codable {
    public var name: String
    public var segmentType: String
    public var domain: String?
    public var durationMinutes: Int?
    public var objective: String?
    public var constraints: [String]?
    public var coachingCues: [String]?
    public var positions: [String]?
    public var techniques: [ImportedTechnique]?
    public var drillPlan: ImportedDrillPlan?
    public var partnerPlan: ImportedPartnerPlan?
    public var roundPlan: ImportedRoundPlan?
    public var roles: ImportedRoles?
    public var resistance: Int?
    public var qualityTargets: ImportedQualityTargets?
    public var scoring: ImportedScoring?
    public var startPosition: String?
    public var endCondition: String?
    public var startingState: ImportedStartingState?
    public var holdSeconds: Int?
    public var breathCount: Int?
    public var flowSequence: [ImportedFlowStep]?
    public var intensityScale: String?
    public var props: [String]?
    public var breathwork: ImportedBreathwork?
    public var media: ImportedMedia?
    public var safety: ImportedSafety?
    public var notes: String?
}

public struct ImportedTechnique: Codable {
    public var name: String
    public var variant: String?
    public var keyDetails: [String]?
    public var commonErrors: [String]?
    public var counters: [String]?
    public var followUps: [String]?
}

public struct ImportedDrillPlan: Codable {
    public var items: [ImportedDrillItem]?
}

public struct ImportedDrillItem: Codable {
    public var name: String
    public var workSeconds: Int
    public var restSeconds: Int
    public var notes: String?
}

public struct ImportedPartnerPlan: Codable {
    public var rounds: Int?
    public var roundDurationSeconds: Int?
    public var restSeconds: Int?
    public var roles: ImportedRoles?
    public var resistance: Int?
    public var switchEverySeconds: Int?
    public var qualityTargets: ImportedQualityTargets?
}

public struct ImportedRoundPlan: Codable {
    public var rounds: Int?
    public var roundDurationSeconds: Int?
    public var restSeconds: Int?
    public var intensityCue: String?
    public var resetRule: String?
    public var startingState: ImportedStartingState?
    public var winConditions: [String]?
}

public struct ImportedRoles: Codable {
    public var attackerGoal: String?
    public var defenderGoal: String?
    public var switchEveryReps: Int?
}

public struct ImportedQualityTargets: Codable {
    public var successRateTarget: Double?
    public var cleanRepsTarget: Int?
    public var decisionSpeedSeconds: Double?
    public var controlTimeSeconds: Int?
    public var breathControl: String?
}

public struct ImportedScoring: Codable {
    public var attackerScoresIf: [String]?
    public var defenderScoresIf: [String]?
}

public struct ImportedStartingState: Codable {
    public var grips: [String]?
    public var roles: [String]?
}

public struct ImportedFlowStep: Codable {
    public var poseName: String
    public var holdSeconds: Int
    public var transitionCue: String?
}

public struct ImportedBreathwork: Codable {
    public var style: String?
    public var pattern: String?
    public var durationSeconds: Int?
}

public struct ImportedMedia: Codable {
    public var videoUrl: String?
    public var imageUrl: String?
    public var diagramAssetId: String?
    public var coachNotesMarkdown: String?
    public var commonFaults: [String]?
    public var keyCues: [String]?
    public var checkpoints: [String]?
}

public struct ImportedSafety: Codable {
    public var contraindications: [String]?
    public var stopIf: [String]?
    public var intensityCeiling: String?
}

// MARK: - Imported Exercise Structures

/// Imported Exercise with full field support
public struct ImportedExercise: Codable {
    public var name: String
    public var type: String?                   // "strength", "conditioning", "mixed"
    public var category: String?               // "squat", "hinge", "pressHorizontal", etc.
    
    // Simple format (legacy)
    public var setsReps: String?               // "3x8" format
    public var restSeconds: Int?
    public var intensityCue: String?
    
    // Advanced strength sets (array of sets with individual parameters)
    public var sets: [ImportedSet]?
    
    // Conditioning parameters
    public var conditioningType: String?       // "monostructural", "amrap", "emom", etc.
    public var conditioningSets: [ImportedConditioningSet]?
    
    // Exercise-level notes
    public var notes: String?
    
    // Superset/circuit grouping
    public var setGroupId: String?             // UUID string for grouping
    public var setGroupKind: String?           // "superset", "circuit", "giantSet"
    
    // Progression
    public var progressionType: String?        // "weight", "volume", "custom"
    public var progressionDeltaWeight: Double? // e.g., 5.0 for +5 lbs per week
    public var progressionDeltaSets: Int?      // e.g., +1 set per week
    
    public init(
        name: String,
        type: String? = nil,
        category: String? = nil,
        setsReps: String? = nil,
        restSeconds: Int? = nil,
        intensityCue: String? = nil,
        sets: [ImportedSet]? = nil,
        conditioningType: String? = nil,
        conditioningSets: [ImportedConditioningSet]? = nil,
        notes: String? = nil,
        setGroupId: String? = nil,
        setGroupKind: String? = nil,
        progressionType: String? = nil,
        progressionDeltaWeight: Double? = nil,
        progressionDeltaSets: Int? = nil
    ) {
        self.name = name
        self.type = type
        self.category = category
        self.setsReps = setsReps
        self.restSeconds = restSeconds
        self.intensityCue = intensityCue
        self.sets = sets
        self.conditioningType = conditioningType
        self.conditioningSets = conditioningSets
        self.notes = notes
        self.setGroupId = setGroupId
        self.setGroupKind = setGroupKind
        self.progressionType = progressionType
        self.progressionDeltaWeight = progressionDeltaWeight
        self.progressionDeltaSets = progressionDeltaSets
    }
}

/// Individual set with full parameters
public struct ImportedSet: Codable {
    public var reps: Int?
    public var weight: Double?
    public var percentageOfMax: Double?        // 0.0-1.0 (e.g., 0.75 = 75%)
    public var rpe: Double?                    // 1.0-10.0
    public var rir: Double?                    // 0.0-5.0+
    public var tempo: String?                  // e.g., "3-0-1-0"
    public var restSeconds: Int?
    public var notes: String?
    
    public init(
        reps: Int? = nil,
        weight: Double? = nil,
        percentageOfMax: Double? = nil,
        rpe: Double? = nil,
        rir: Double? = nil,
        tempo: String? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil
    ) {
        self.reps = reps
        self.weight = weight
        self.percentageOfMax = percentageOfMax
        self.rpe = rpe
        self.rir = rir
        self.tempo = tempo
        self.restSeconds = restSeconds
        self.notes = notes
    }
}

/// Conditioning set parameters
public struct ImportedConditioningSet: Codable {
    public var durationSeconds: Int?
    public var distanceMeters: Double?
    public var calories: Double?
    public var rounds: Int?
    public var targetPace: String?             // e.g., "2:00/500m" or "easy"
    public var effortDescriptor: String?       // e.g., "moderate", "hard"
    public var restSeconds: Int?
    public var notes: String?
    
    public init(
        durationSeconds: Int? = nil,
        distanceMeters: Double? = nil,
        calories: Double? = nil,
        rounds: Int? = nil,
        targetPace: String? = nil,
        effortDescriptor: String? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil
    ) {
        self.durationSeconds = durationSeconds
        self.distanceMeters = distanceMeters
        self.calories = calories
        self.rounds = rounds
        self.targetPace = targetPace
        self.effortDescriptor = effortDescriptor
        self.restSeconds = restSeconds
        self.notes = notes
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
        let weeksCount = imported.NumberOfWeeks ?? numberOfWeeks
        
        // Determine which format is being used: week-specific, multi-day, or single-day
        var dayTemplates: [DayTemplate]
        var weekTemplates: [[DayTemplate]]?
        
        // Priority: Weeks > Days > Exercises
        if let weeks = imported.Weeks, !weeks.isEmpty {
            // Week-specific block format (NEW)
            AppLogger.info("📅 Parsing week-specific block: \(weeks.count) weeks detected", subsystem: .general, category: "BlockGenerator")
            
            weekTemplates = weeks.map { weekDays in
                weekDays.map { convertDay($0, blockWarmUp: imported.WarmUp, blockFinisher: imported.Finisher) }
            }
            
            // Log day count per week for verification
            for (weekIndex, weekDays) in weekTemplates!.enumerated() {
                AppLogger.debug("  Week \(weekIndex + 1): \(weekDays.count) days", subsystem: .general, category: "BlockGenerator")
            }
            
            // Use first week as default days for backward compatibility
            // If first week is empty, fall back to creating an empty placeholder
            if let firstWeek = weekTemplates?.first, !firstWeek.isEmpty {
                dayTemplates = firstWeek
            } else {
                // Safeguard: Create a placeholder day if week templates are malformed
                AppLogger.warning("⚠️ Week-specific templates provided but first week is empty", subsystem: .general, category: "BlockGenerator")
                dayTemplates = [DayTemplate(
                    name: "Day 1",
                    notes: "Week-specific templates provided but first week is empty. Check JSON format.",
                    exercises: []
                )]
            }
        } else if let days = imported.Days, !days.isEmpty {
            // Multi-day block (same days all weeks)
            AppLogger.info("📅 Parsing multi-day block (same days all weeks): \(days.count) days", subsystem: .general, category: "BlockGenerator")
            dayTemplates = days.map { convertDay($0, blockWarmUp: imported.WarmUp, blockFinisher: imported.Finisher) }
            weekTemplates = nil
        } else if let exercises = imported.Exercises, !exercises.isEmpty {
            // Single-day block (legacy format)
            AppLogger.info("📅 Parsing single-day block (legacy format): \(exercises.count) exercises", subsystem: .general, category: "BlockGenerator")
            let convertedExercises = exercises.map { convertExercise($0) }
            
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
            
            let dayTemplate = DayTemplate(
                name: "Day 1",
                shortCode: "D1",
                notes: blockNotes.trimmingCharacters(in: .whitespacesAndNewlines),
                exercises: convertedExercises
            )
            dayTemplates = [dayTemplate]
            weekTemplates = nil
        } else {
            // Neither provided - create empty day with note
            let dayTemplate = DayTemplate(
                name: "Empty Block",
                shortCode: "E1",
                notes: "No exercises provided. Please add exercises to this block.",
                exercises: []
            )
            dayTemplates = [dayTemplate]
            weekTemplates = nil
        }
        
        // Parse goal
        let goal = parseGoal(from: imported.Goal)
        
        // Create block
        let block = Block(
            name: imported.Title,
            description: "Target: \(imported.TargetAthlete)\nDuration: \(imported.DurationMinutes) min\nDifficulty: \(imported.Difficulty)/5\nEquipment: \(imported.Equipment)",
            numberOfWeeks: weeksCount,
            goal: goal,
            days: dayTemplates,
            weekTemplates: weekTemplates,
            source: .ai,
            aiMetadata: AIMetadata(
                prompt: "Generated block",
                createdAt: Date()
            )
        )
        
        return block
    }
    
    /// Convert an ImportedDay to a DayTemplate
    private static func convertDay(_ imported: ImportedDay, blockWarmUp: String, blockFinisher: String) -> DayTemplate {
        let exercises = imported.exercises?.map { convertExercise($0) } ?? []
        let segments = imported.segments?.map { convertSegment($0) } ?? []
        
        // Build day notes
        var dayNotes = ""
        if let notes = imported.notes, !notes.isEmpty {
            dayNotes = notes
        }
        
        return DayTemplate(
            name: imported.name,
            shortCode: imported.shortCode,
            goal: parseGoal(from: imported.goal ?? ""),
            notes: dayNotes,
            exercises: exercises,
            segments: segments.isEmpty ? nil : segments
        )
    }
    
    /// Convert an ImportedExercise to an ExerciseTemplate with full field support
    private static func convertExercise(_ imported: ImportedExercise) -> ExerciseTemplate {
        // Determine exercise type
        let exerciseType = parseExerciseType(from: imported.type)
        let exerciseCategory = parseExerciseCategory(from: imported.category)
        
        // Parse set group ID if provided
        let setGroupId: SetGroupID? = imported.setGroupId.flatMap { UUID(uuidString: $0) }
        
        // Create strength sets
        var strengthSets: [StrengthSetTemplate]?
        if exerciseType == .strength || exerciseType == .mixed {
            if let importedSets = imported.sets, !importedSets.isEmpty {
                // Use advanced set format
                strengthSets = importedSets.enumerated().map { index, set in
                    StrengthSetTemplate(
                        index: index,
                        reps: set.reps,
                        weight: set.weight,
                        percentageOfMax: set.percentageOfMax,
                        rpe: set.rpe,
                        rir: set.rir,
                        tempo: set.tempo,
                        restSeconds: set.restSeconds,
                        notes: set.notes
                    )
                }
            } else if let setsReps = imported.setsReps {
                // Use simple format (legacy)
                let normalizedSetsReps = setsReps.lowercased()
                let components = normalizedSetsReps.split(separator: "x")
                let setsCount = components.first.flatMap { Int($0) } ?? 3
                let reps = components.count > 1 ? Int(components[1]) : nil
                
                strengthSets = (0..<setsCount).map { index in
                    StrengthSetTemplate(
                        index: index,
                        reps: reps,
                        restSeconds: imported.restSeconds,
                        notes: imported.intensityCue
                    )
                }
            }
        }
        
        // Create conditioning sets
        var conditioningSets: [ConditioningSetTemplate]?
        if exerciseType == .conditioning || exerciseType == .mixed {
            if let importedCondSets = imported.conditioningSets, !importedCondSets.isEmpty {
                conditioningSets = importedCondSets.enumerated().map { index, set in
                    ConditioningSetTemplate(
                        index: index,
                        durationSeconds: set.durationSeconds,
                        distanceMeters: set.distanceMeters,
                        calories: set.calories,
                        rounds: set.rounds,
                        targetPace: set.targetPace,
                        effortDescriptor: set.effortDescriptor,
                        restSeconds: set.restSeconds,
                        notes: set.notes
                    )
                }
            }
        }
        
        // Parse conditioning type
        let conditioningType = parseConditioningType(from: imported.conditioningType)
        
        // Create progression rule
        let progressionType = parseProgressionType(from: imported.progressionType)
        let progressionRule = ProgressionRule(
            type: progressionType,
            deltaWeight: imported.progressionDeltaWeight ?? (progressionType == .weight ? 5.0 : nil),
            deltaSets: imported.progressionDeltaSets
        )
        
        // Create exercise template
        return ExerciseTemplate(
            customName: imported.name,
            type: exerciseType,
            category: exerciseCategory,
            conditioningType: conditioningType,
            notes: imported.notes ?? imported.intensityCue,
            setGroupId: setGroupId,
            strengthSets: strengthSets,
            conditioningSets: conditioningSets,
            progressionRule: progressionRule
        )
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
        } else if lower.contains("peaking") {
            return .peaking
        } else if lower.contains("deload") {
            return .deload
        } else if lower.contains("rehab") {
            return .rehab
        }
        return nil
    }
    
    /// Parse exercise type from string
    private static func parseExerciseType(from typeString: String?) -> ExerciseType {
        guard let type = typeString?.lowercased() else { return .strength }
        
        switch type {
        case "strength": return .strength
        case "conditioning": return .conditioning
        case "mixed": return .mixed
        case "other": return .other
        default: return .strength
        }
    }
    
    /// Parse exercise category from string
    private static func parseExerciseCategory(from categoryString: String?) -> ExerciseCategory? {
        guard let category = categoryString?.lowercased() else { return nil }
        
        switch category {
        case "squat": return .squat
        case "hinge": return .hinge
        case "presshorizontal", "press_horizontal": return .pressHorizontal
        case "pressvertical", "press_vertical": return .pressVertical
        case "pullhorizontal", "pull_horizontal": return .pullHorizontal
        case "pullvertical", "pull_vertical": return .pullVertical
        case "carry": return .carry
        case "core": return .core
        case "olympic": return .olympic
        case "conditioning": return .conditioning
        case "mobility": return .mobility
        case "mixed": return .mixed
        case "other": return .other
        default: return nil
        }
    }
    
    /// Parse conditioning type from string
    private static func parseConditioningType(from typeString: String?) -> ConditioningType? {
        guard let type = typeString?.lowercased() else { return nil }
        
        switch type {
        case "monostructural": return .monostructural
        case "mixedmodal", "mixed_modal": return .mixedModal
        case "emom": return .emom
        case "amrap": return .amrap
        case "intervals": return .intervals
        case "fortime", "for_time": return .forTime
        case "fordistance", "for_distance": return .forDistance
        case "forcalories", "for_calories": return .forCalories
        case "roundsfortime", "rounds_for_time": return .roundsForTime
        case "other": return .other
        default: return nil
        }
    }
    
    /// Parse progression type from string
    private static func parseProgressionType(from typeString: String?) -> ProgressionType {
        guard let type = typeString?.lowercased() else { return .weight }
        
        switch type {
        case "weight": return .weight
        case "volume": return .volume
        case "custom": return .custom
        default: return .weight
        }
    }
    
    // MARK: - Segment Conversion
    
    /// Convert an ImportedSegment to a Segment
    private static func convertSegment(_ imported: ImportedSegment) -> Segment {
        // Parse segment type
        let segmentType = parseSegmentType(from: imported.segmentType)
        
        // Parse domain
        let domain = parseDomain(from: imported.domain)
        
        // Parse intensity scale
        let intensityScale = parseIntensityScale(from: imported.intensityScale)
        
        // Convert techniques
        let techniques = imported.techniques?.map { tech in
            Technique(
                name: tech.name,
                variant: tech.variant,
                keyDetails: tech.keyDetails ?? [],
                commonErrors: tech.commonErrors ?? [],
                counters: tech.counters ?? [],
                followUps: tech.followUps ?? []
            )
        } ?? []
        
        // Convert drill plan
        var drillPlan: DrillPlan?
        if let importedDrillPlan = imported.drillPlan, let items = importedDrillPlan.items {
            let drillItems = items.map { item in
                DrillItem(
                    name: item.name,
                    workSeconds: item.workSeconds,
                    restSeconds: item.restSeconds,
                    notes: item.notes
                )
            }
            drillPlan = DrillPlan(items: drillItems)
        }
        
        // Convert partner plan
        var partnerPlan: PartnerPlan?
        if let importedPartnerPlan = imported.partnerPlan {
            let roles = importedPartnerPlan.roles.map { r in
                Roles(
                    attackerGoal: r.attackerGoal,
                    defenderGoal: r.defenderGoal,
                    switchEveryReps: r.switchEveryReps
                )
            }
            
            let qualityTargets = importedPartnerPlan.qualityTargets.map { q in
                QualityTargets(
                    successRateTarget: q.successRateTarget,
                    cleanRepsTarget: q.cleanRepsTarget,
                    decisionSpeedSeconds: q.decisionSpeedSeconds,
                    controlTimeSeconds: q.controlTimeSeconds,
                    breathControl: q.breathControl
                )
            }
            
            partnerPlan = PartnerPlan(
                rounds: importedPartnerPlan.rounds ?? 1,
                roundDurationSeconds: importedPartnerPlan.roundDurationSeconds ?? 60,
                restSeconds: importedPartnerPlan.restSeconds ?? 0,
                roles: roles,
                resistance: importedPartnerPlan.resistance ?? 0,
                switchEverySeconds: importedPartnerPlan.switchEverySeconds,
                qualityTargets: qualityTargets
            )
        }
        
        // Convert round plan
        var roundPlan: RoundPlan?
        if let importedRoundPlan = imported.roundPlan {
            let startingState = importedRoundPlan.startingState.map { s in
                StartingState(
                    grips: s.grips ?? [],
                    roles: s.roles ?? []
                )
            }
            
            roundPlan = RoundPlan(
                rounds: importedRoundPlan.rounds ?? 1,
                roundDurationSeconds: importedRoundPlan.roundDurationSeconds ?? 60,
                restSeconds: importedRoundPlan.restSeconds ?? 0,
                intensityCue: importedRoundPlan.intensityCue,
                resetRule: importedRoundPlan.resetRule,
                startingState: startingState,
                winConditions: importedRoundPlan.winConditions ?? []
            )
        }
        
        // Convert roles
        var roles: Roles?
        if let importedRoles = imported.roles {
            roles = Roles(
                attackerGoal: importedRoles.attackerGoal,
                defenderGoal: importedRoles.defenderGoal,
                switchEveryReps: importedRoles.switchEveryReps
            )
        }
        
        // Convert quality targets
        var qualityTargets: QualityTargets?
        if let importedQualityTargets = imported.qualityTargets {
            qualityTargets = QualityTargets(
                successRateTarget: importedQualityTargets.successRateTarget,
                cleanRepsTarget: importedQualityTargets.cleanRepsTarget,
                decisionSpeedSeconds: importedQualityTargets.decisionSpeedSeconds,
                controlTimeSeconds: importedQualityTargets.controlTimeSeconds,
                breathControl: importedQualityTargets.breathControl
            )
        }
        
        // Convert scoring
        var scoring: Scoring?
        if let importedScoring = imported.scoring {
            scoring = Scoring(
                attackerScoresIf: importedScoring.attackerScoresIf ?? [],
                defenderScoresIf: importedScoring.defenderScoresIf ?? []
            )
        }
        
        // Convert starting state
        var startingState: StartingState?
        if let importedStartingState = imported.startingState {
            startingState = StartingState(
                grips: importedStartingState.grips ?? [],
                roles: importedStartingState.roles ?? []
            )
        }
        
        // Convert flow sequence
        let flowSequence = imported.flowSequence?.map { step in
            FlowStep(
                poseName: step.poseName,
                holdSeconds: step.holdSeconds,
                transitionCue: step.transitionCue
            )
        } ?? []
        
        // Convert breathwork
        var breathwork: BreathworkPlan?
        if let importedBreathwork = imported.breathwork,
           let style = importedBreathwork.style,
           let pattern = importedBreathwork.pattern,
           let durationSeconds = importedBreathwork.durationSeconds {
            breathwork = BreathworkPlan(
                style: style,
                pattern: pattern,
                durationSeconds: durationSeconds
            )
        }
        
        // Convert media
        var media: Media?
        if let importedMedia = imported.media {
            media = Media(
                videoUrl: importedMedia.videoUrl,
                imageUrl: importedMedia.imageUrl,
                diagramAssetId: importedMedia.diagramAssetId,
                coachNotesMarkdown: importedMedia.coachNotesMarkdown,
                commonFaults: importedMedia.commonFaults ?? [],
                keyCues: importedMedia.keyCues ?? [],
                checkpoints: importedMedia.checkpoints ?? []
            )
        }
        
        // Convert safety
        var safety: Safety?
        if let importedSafety = imported.safety {
            safety = Safety(
                contraindications: importedSafety.contraindications ?? [],
                stopIf: importedSafety.stopIf ?? [],
                intensityCeiling: importedSafety.intensityCeiling
            )
        }
        
        return Segment(
            name: imported.name,
            segmentType: segmentType,
            domain: domain,
            durationMinutes: imported.durationMinutes,
            objective: imported.objective,
            constraints: imported.constraints ?? [],
            coachingCues: imported.coachingCues ?? [],
            positions: imported.positions ?? [],
            techniques: techniques,
            roundPlan: roundPlan,
            drillPlan: drillPlan,
            partnerPlan: partnerPlan,
            roles: roles,
            resistance: imported.resistance,
            qualityTargets: qualityTargets,
            scoring: scoring,
            startPosition: imported.startPosition,
            endCondition: imported.endCondition,
            startingState: startingState,
            holdSeconds: imported.holdSeconds,
            breathCount: imported.breathCount,
            flowSequence: flowSequence,
            intensityScale: intensityScale,
            props: imported.props ?? [],
            breathwork: breathwork,
            media: media,
            safety: safety,
            notes: imported.notes
        )
    }
    
    /// Parse segment type from string
    private static func parseSegmentType(from typeString: String) -> SegmentType {
        let lower = typeString.lowercased()
        
        switch lower {
        case "warmup", "warm-up", "warm_up": return .warmup
        case "mobility": return .mobility
        case "technique": return .technique
        case "drill": return .drill
        case "positionalspar", "positional_spar", "positional-spar": return .positionalSpar
        case "rolling": return .rolling
        case "cooldown", "cool-down", "cool_down": return .cooldown
        case "lecture": return .lecture
        case "breathwork": return .breathwork
        case "flow": return .other  // Flow can be mapped to 'other' or you could add a new type
        default: return .other
        }
    }
    
    /// Parse domain from string
    private static func parseDomain(from domainString: String?) -> Domain? {
        guard let domain = domainString?.lowercased() else { return nil }
        
        switch domain {
        case "grappling": return .grappling
        case "yoga": return .yoga
        case "strength": return .strength
        case "conditioning": return .conditioning
        case "mobility": return .mobility
        case "other": return .other
        default: return nil
        }
    }
    
    /// Parse intensity scale from string
    private static func parseIntensityScale(from scaleString: String?) -> IntensityScale? {
        guard let scale = scaleString?.lowercased() else { return nil }
        
        switch scale {
        case "restorative": return .restorative
        case "easy": return .easy
        case "moderate": return .moderate
        case "strong": return .strong
        case "peak": return .peak
        default: return nil
        }
    }
}

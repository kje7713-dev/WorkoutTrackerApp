//
//  PromptTemplates.swift
//  Savage By Design – AI Block Generation Prompts
//
//  Contains the approved system message and user prompt template for ChatGPT block generation.
//

import Foundation

// MARK: - Chat Message DTO

/// Simple message structure for ChatGPT API
public struct ChatMessage: Codable {
    public var role: String
    public var content: String
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

// MARK: - Prompt Templates

public struct PromptTemplates {
    
    // MARK: - System Message
    
    /// The exact 3-part system message: HumanReadable + Confirmation + JSON
    public static let systemMessageExact = """
You are a professional strength & conditioning coach. You will generate a single training block (1 week) for an athlete based on their inputs. You must return TWO sections in your response:

1) **HUMAN-READABLE SUMMARY** (with these exact headers in order):
   - Title:
   - Goal:
   - Target Athlete:
   - Duration (minutes):
   - Difficulty (1-5):
   - Equipment:
   - Warm-Up:
   - Exercises:
     (List each exercise on a new line, formatted as: ExerciseName | SetsxReps | Rest(sec) | IntensityCue)
   - Finisher:
   - Notes:
   - Estimated Total Time (minutes):
   - Progression:

2) **JSON:** (begin this section with exactly "JSON:" on its own line)
   Return a valid JSON object matching this schema:
   {
     "Title": "string",
     "Goal": "string",
     "TargetAthlete": "string",
     "DurationMinutes": int,
     "Difficulty": int (1-5),
     "Equipment": "string",
     "WarmUp": "string",
     "Exercises": [
       {
         "name": "string",
         "setsReps": "string (e.g., '3x8', '4x10')",
         "restSeconds": int,
         "intensityCue": "string"
       }
     ],
     "Finisher": "string",
     "Notes": "string",
     "EstimatedTotalTimeMinutes": int,
     "Progression": "string"
   }

CRITICAL RULES:
- The HUMAN-READABLE section must use the exact headers listed above, in that order.
- The JSON section must begin with "JSON:" on its own line.
- The JSON must be valid and parseable.
- If user constraints are impossible, explain briefly in Notes and adjust intelligently.
"""
    
    // MARK: - User Prompt Template
    
    /// Prompt input structure
    public struct PromptInputs {
        public var availableTimeMinutes: Int
        public var athleteLevel: String
        public var focus: String
        public var allowedEquipment: String
        public var excludeExercises: String
        public var primaryConstraints: String
        public var goalNotes: String
        
        public init(
            availableTimeMinutes: Int = 45,
            athleteLevel: String = "Intermediate",
            focus: String = "Full Body Strength",
            allowedEquipment: String = "Barbell, Dumbbells, Rack",
            excludeExercises: String = "None",
            primaryConstraints: String = "None",
            goalNotes: String = "Build strength and muscle"
        ) {
            self.availableTimeMinutes = availableTimeMinutes
            self.athleteLevel = athleteLevel
            self.focus = focus
            self.allowedEquipment = allowedEquipment
            self.excludeExercises = excludeExercises
            self.primaryConstraints = primaryConstraints
            self.goalNotes = goalNotes
        }
    }
    
    /// Generate user message from inputs
    public static func defaultUserTemplate(promptInputs: PromptInputs) -> String {
        return """
Generate a single-week training block with the following parameters:

Available Time: \(promptInputs.availableTimeMinutes) minutes
Athlete Level: \(promptInputs.athleteLevel)
Focus: \(promptInputs.focus)
Allowed Equipment: \(promptInputs.allowedEquipment)
Exclude Exercises: \(promptInputs.excludeExercises)
Primary Constraints: \(promptInputs.primaryConstraints)
Goal Notes: \(promptInputs.goalNotes)

Please provide both the human-readable summary and the JSON output as specified in your instructions.
"""
    }
    
    // MARK: - Message Builder
    
    /// Build messages array for ChatGPT API
    public static func buildMessages(system: String, user: String) -> [ChatMessage] {
        return [
            ChatMessage(role: "system", content: system),
            ChatMessage(role: "user", content: user)
        ]
    }
}

//
//  WhiteboardModels.swift
//  Savage By Design
//
//  Unified models for whiteboard view rendering
//

import Foundation

// MARK: - Unified Models (Normalization Layer)

/// Unified block structure that normalizes both authoring JSON and export schemas
public struct UnifiedBlock: Codable, Equatable {
    public var title: String
    public var numberOfWeeks: Int
    public var weeks: [[UnifiedDay]]  // Always normalized to week-indexed days
    
    public init(
        title: String,
        numberOfWeeks: Int,
        weeks: [[UnifiedDay]]
    ) {
        self.title = title
        self.numberOfWeeks = numberOfWeeks
        self.weeks = weeks
    }
}

/// Unified day template
public struct UnifiedDay: Codable, Equatable {
    public var name: String
    public var goal: String?
    public var exercises: [UnifiedExercise]
    
    public init(
        name: String,
        goal: String? = nil,
        exercises: [UnifiedExercise]
    ) {
        self.name = name
        self.goal = goal
        self.exercises = exercises
    }
}

/// Unified exercise representation
public struct UnifiedExercise: Codable, Equatable {
    public var name: String
    public var type: String  // strength|conditioning|mixed|other
    public var category: String?
    public var notes: String?
    public var strengthSets: [UnifiedStrengthSet]
    public var conditioningType: String?
    public var conditioningSets: [UnifiedConditioningSet]
    public var setGroupId: String?
    public var setGroupKind: String?
    public var progressionType: String?
    public var progressionDeltaWeight: Double?
    public var progressionDeltaSets: Int?
    
    public init(
        name: String,
        type: String,
        category: String? = nil,
        notes: String? = nil,
        strengthSets: [UnifiedStrengthSet] = [],
        conditioningType: String? = nil,
        conditioningSets: [UnifiedConditioningSet] = [],
        setGroupId: String? = nil,
        setGroupKind: String? = nil,
        progressionType: String? = nil,
        progressionDeltaWeight: Double? = nil,
        progressionDeltaSets: Int? = nil
    ) {
        self.name = name
        self.type = type
        self.category = category
        self.notes = notes
        self.strengthSets = strengthSets
        self.conditioningType = conditioningType
        self.conditioningSets = conditioningSets
        self.setGroupId = setGroupId
        self.setGroupKind = setGroupKind
        self.progressionType = progressionType
        self.progressionDeltaWeight = progressionDeltaWeight
        self.progressionDeltaSets = progressionDeltaSets
    }
}

/// Unified strength set
public struct UnifiedStrengthSet: Codable, Equatable {
    public var reps: Int?
    public var restSeconds: Int?
    public var rpe: Double?
    public var notes: String?
    
    public init(
        reps: Int? = nil,
        restSeconds: Int? = nil,
        rpe: Double? = nil,
        notes: String? = nil
    ) {
        self.reps = reps
        self.restSeconds = restSeconds
        self.rpe = rpe
        self.notes = notes
    }
}

/// Unified conditioning set
public struct UnifiedConditioningSet: Codable, Equatable {
    public var durationSeconds: Int?
    public var distanceMeters: Double?
    public var calories: Double?
    public var rounds: Int?
    public var effortDescriptor: String?
    public var restSeconds: Int?
    public var notes: String?
    
    public init(
        durationSeconds: Int? = nil,
        distanceMeters: Double? = nil,
        calories: Double? = nil,
        rounds: Int? = nil,
        effortDescriptor: String? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil
    ) {
        self.durationSeconds = durationSeconds
        self.distanceMeters = distanceMeters
        self.calories = calories
        self.rounds = rounds
        self.effortDescriptor = effortDescriptor
        self.restSeconds = restSeconds
        self.notes = notes
    }
}

// MARK: - Whiteboard View Models

/// Section in the whiteboard (Strength, Accessory, Conditioning)
public struct WhiteboardSection: Identifiable, Equatable {
    public let id = UUID()
    public var title: String
    public var items: [WhiteboardItem]
    
    public init(title: String, items: [WhiteboardItem]) {
        self.title = title
        self.items = items
    }
}

/// Individual item in a whiteboard section
public struct WhiteboardItem: Identifiable, Equatable {
    public let id = UUID()
    public var primary: String
    public var secondary: String?
    public var tertiary: String?
    public var bullets: [String]
    
    public init(
        primary: String,
        secondary: String? = nil,
        tertiary: String? = nil,
        bullets: [String] = []
    ) {
        self.primary = primary
        self.secondary = secondary
        self.tertiary = tertiary
        self.bullets = bullets
    }
}

// MARK: - Authoring JSON Schema Models

/// Authoring schema exercise (from AI/manual block creation)
public struct AuthoringExercise: Codable {
    public var name: String
    public var type: String
    public var category: String?
    public var setsReps: String?
    public var intensityCue: String?
    public var notes: String?
    public var conditioningType: String?
    public var rounds: Int?
    public var durationSeconds: Int?
    public var distanceMeters: Double?
    public var effortDescriptor: String?
    public var restSeconds: Int?
}

/// Authoring schema day
public struct AuthoringDay: Codable {
    public var name: String
    public var shortCode: String?
    public var goal: String?
    public var exercises: [AuthoringExercise]
}

/// Authoring schema block (top-level JSON)
public struct AuthoringBlock: Codable {
    public var Title: String?
    public var Goal: String?
    public var TargetAthlete: String?
    public var NumberOfWeeks: Int?
    public var DurationMinutes: Int?
    public var Difficulty: Int?
    public var Equipment: String?
    public var WarmUp: String?
    public var Finisher: String?
    public var Notes: String?
    public var EstimatedTotalTimeMinutes: Int?
    public var Progression: String?
    
    // Content is exactly ONE of:
    public var Exercises: [AuthoringExercise]?      // Single-day block
    public var Days: [AuthoringDay]?                 // Multi-day repeated
    public var Weeks: [[AuthoringDay]]?              // Week-specific
}

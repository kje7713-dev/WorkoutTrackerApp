//
//  CoreModels.swift
//  Savage By Design – Domain Models
//
//  Phase 1: Pure data structures (no UI, no persistence)
//

import Foundation

// MARK: - Common ID Typealiases

public typealias BlockID = UUID
public typealias DayTemplateID = UUID
public typealias ExerciseTemplateID = UUID
public typealias ExerciseDefinitionID = UUID
public typealias WorkoutSessionID = UUID

// MARK: - Enums

public enum ExerciseType: String, Codable {
    case strength
    case conditioning
    case other
}

public enum BlockSource: String, Codable {
    case user
    case ai
}

public enum SessionStatus: String, Codable {
    case notStarted
    case inProgress
    case completed
}

public enum ProgressionType: String, Codable {
    case weight
    case volume
    case custom
}

// MARK: - ExerciseDefinition (Global Library Entry)

public struct ExerciseDefinition: Identifiable, Codable, Equatable {
    public var id: ExerciseDefinitionID
    public var name: String
    public var type: ExerciseType
    public var tags: [String]

    public init(
        id: ExerciseDefinitionID = ExerciseDefinitionID(),
        name: String,
        type: ExerciseType,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.tags = tags
    }
}

// MARK: - Block

public struct Block: Identifiable, Codable, Equatable {
    public var id: BlockID
    public var name: String
    public var description: String?
    public var numberOfWeeks: Int
    public var days: [DayTemplate]
    public var source: BlockSource
    public var aiMetadata: AIMetadata?

    public init(
        id: BlockID = BlockID(),
        name: String,
        description: String? = nil,
        numberOfWeeks: Int,
        days: [DayTemplate],
        source: BlockSource = .user,
        aiMetadata: AIMetadata? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.numberOfWeeks = numberOfWeeks
        self.days = days
        self.source = source
        self.aiMetadata = aiMetadata
    }
}

// MARK: - DayTemplate

public struct DayTemplate: Identifiable, Codable, Equatable {
    public var id: DayTemplateID
    public var name: String
    public var shortCode: String?
    public var exercises: [ExerciseTemplate]

    public init(
        id: DayTemplateID = DayTemplateID(),
        name: String,
        shortCode: String? = nil,
        exercises: [ExerciseTemplate] = []
    ) {
        self.id = id
        self.name = name
        self.shortCode = shortCode
        self.exercises = exercises
    }
}

// MARK: - ExerciseTemplate

public struct ExerciseTemplate: Identifiable, Codable, Equatable {
    public var id: ExerciseTemplateID
    public var exerciseDefinitionId: ExerciseDefinitionID?
    public var customName: String?
    public var type: ExerciseType
    public var notes: String?
    public var setTemplates: [SetTemplate]
    public var progressionRule: ProgressionRule

    public init(
        id: ExerciseTemplateID = ExerciseTemplateID(),
        exerciseDefinitionId: ExerciseDefinitionID? = nil,
        customName: String? = nil,
        type: ExerciseType,
        notes: String? = nil,
        setTemplates: [SetTemplate],
        progressionRule: ProgressionRule
    ) {
        self.id = id
        self.exerciseDefinitionId = exerciseDefinitionId
        self.customName = customName
        self.type = type
        self.notes = notes
        self.setTemplates = setTemplates
        self.progressionRule = progressionRule
    }
}

// MARK: - SetTemplate

public struct SetTemplate: Identifiable, Codable, Equatable {
    public var id: UUID
    public var index: Int

    public var plannedReps: Int?
    public var plannedWeight: Double?
    public var plannedTime: Double?        // seconds
    public var plannedDistance: Double?    // meters
    public var plannedCalories: Double?
    public var plannedRounds: Int?

    public init(
        id: UUID = UUID(),
        index: Int,
        plannedReps: Int? = nil,
        plannedWeight: Double? = nil,
        plannedTime: Double? = nil,
        plannedDistance: Double? = nil,
        plannedCalories: Double? = nil,
        plannedRounds: Int? = nil
    ) {
        self.id = id
        self.index = index
        self.plannedReps = plannedReps
        self.plannedWeight = plannedWeight
        self.plannedTime = plannedTime
        self.plannedDistance = plannedDistance
        self.plannedCalories = plannedCalories
        self.plannedRounds = plannedRounds
    }
}

// MARK: - ProgressionRule

public struct ProgressionRule: Codable, Equatable {
    public var type: ProgressionType

    // simple params for weight / volume
    public var deltaWeight: Double?
    public var deltaSets: Int?

    // flexible key-value for complex AI patterns
    public var customParams: [String: String]?

    public init(
        type: ProgressionType,
        deltaWeight: Double? = nil,
        deltaSets: Int? = nil,
        customParams: [String: String]? = nil
    ) {
        self.type = type
        self.deltaWeight = deltaWeight
        self.deltaSets = deltaSets
        self.customParams = customParams
    }
}

// MARK: - WorkoutSession

public struct WorkoutSession: Identifiable, Codable, Equatable {
    public var id: WorkoutSessionID
    public var blockId: BlockID
    public var weekIndex: Int
    public var dayTemplateId: DayTemplateID
    public var date: Date?
    public var status: SessionStatus
    public var exercises: [SessionExercise]

    public init(
        id: WorkoutSessionID = WorkoutSessionID(),
        blockId: BlockID,
        weekIndex: Int,
        dayTemplateId: DayTemplateID,
        date: Date? = nil,
        status: SessionStatus = .notStarted,
        exercises: [SessionExercise]
    ) {
        self.id = id
        self.blockId = blockId
        self.weekIndex = weekIndex
        self.dayTemplateId = dayTemplateId
        self.date = date
        self.status = status
        self.exercises = exercises
    }
}

// MARK: - SessionExercise

public struct SessionExercise: Identifiable, Codable, Equatable {
    public var id: UUID

    public var exerciseTemplateId: ExerciseTemplateID?
    public var exerciseDefinitionId: ExerciseDefinitionID?
    public var customName: String?

    public var expectedSets: [SessionSet]
    public var loggedSets: [SessionSet]

    public init(
        id: UUID = UUID(),
        exerciseTemplateId: ExerciseTemplateID? = nil,
        exerciseDefinitionId: ExerciseDefinitionID? = nil,
        customName: String? = nil,
        expectedSets: [SessionSet],
        loggedSets: [SessionSet]
    ) {
        self.id = id
        self.exerciseTemplateId = exerciseTemplateId
        self.exerciseDefinitionId = exerciseDefinitionId
        self.customName = customName
        self.expectedSets = expectedSets
        self.loggedSets = loggedSets
    }
}

// MARK: - SessionSet

public struct SessionSet: Identifiable, Codable, Equatable {
    public var id: UUID
    public var index: Int

    // expected values
    public var expectedReps: Int?
    public var expectedWeight: Double?
    public var expectedTime: Double?
    public var expectedDistance: Double?
    public var expectedCalories: Double?

    // logged values
    public var loggedReps: Int?
    public var loggedWeight: Double?
    public var loggedTime: Double?
    public var loggedDistance: Double?
    public var loggedCalories: Double?

    public var isCompleted: Bool
    public var notes: String?

    public init(
        id: UUID = UUID(),
        index: Int,
        expectedReps: Int? = nil,
        expectedWeight: Double? = nil,
        expectedTime: Double? = nil,
        expectedDistance: Double? = nil,
        expectedCalories: Double? = nil,
        loggedReps: Int? = nil,
        loggedWeight: Double? = nil,
        loggedTime: Double? = nil,
        loggedDistance: Double? = nil,
        loggedCalories: Double? = nil,
        isCompleted: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.index = index
        self.expectedReps = expectedReps
        self.expectedWeight = expectedWeight
        self.expectedTime = expectedTime
        self.expectedDistance = expectedDistance
        self.expectedCalories = expectedCalories
        self.loggedReps = loggedReps
        self.loggedWeight = loggedWeight
        self.loggedTime = loggedTime
        self.loggedDistance = loggedDistance
        self.loggedCalories = loggedCalories
        self.isCompleted = isCompleted
        self.notes = notes
    }
}

// MARK: - AIMetadata

public struct AIMetadata: Codable, Equatable {
    public var prompt: String
    public var createdAt: Date

    public init(
        prompt: String,
        createdAt: Date = Date()
    ) {
        self.prompt = prompt
        self.createdAt = createdAt
    }
}

// MARK: - AI BlockDraft (for AI integration pipeline)

public struct BlockDraft: Codable, Equatable {
    public struct DraftDay: Codable, Equatable {
        public var name: String
        public var shortCode: String?
        public var exercises: [DraftExercise]

        public init(
            name: String,
            shortCode: String? = nil,
            exercises: [DraftExercise]
        ) {
            self.name = name
            self.shortCode = shortCode
            self.exercises = exercises
        }
    }

    public struct DraftExercise: Codable, Equatable {
        public struct DraftSet: Codable, Equatable {
            public var reps: Int?
            public var weight: Double?

            public init(reps: Int? = nil, weight: Double? = nil) {
                self.reps = reps
                self.weight = weight
            }
        }

        public struct DraftProgression: Codable, Equatable {
            public var type: ProgressionType
            public var deltaWeight: Double?
            public var deltaSets: Int?

            public init(
                type: ProgressionType,
                deltaWeight: Double? = nil,
                deltaSets: Int? = nil
            ) {
                self.type = type
                self.deltaWeight = deltaWeight
                self.deltaSets = deltaSets
            }
        }

        public var name: String
        public var type: ExerciseType
        public var notes: String?
        public var sets: [DraftSet]
        public var progression: DraftProgression?

        public init(
            name: String,
            type: ExerciseType,
            notes: String? = nil,
            sets: [DraftSet],
            progression: DraftProgression? = nil
        ) {
            self.name = name
            self.type = type
            self.notes = notes
            self.sets = sets
            self.progression = progression
        }
    }

    public var name: String
    public var description: String?
    public var numberOfWeeks: Int
    public var days: [DraftDay]

    public init(
        name: String,
        description: String? = nil,
        numberOfWeeks: Int,
        days: [DraftDay]
    ) {
        self.name = name
        self.description = description
        self.numberOfWeeks = numberOfWeeks
        self.days = days
    }
}

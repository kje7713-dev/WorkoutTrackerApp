//
//  Models.swift
//  Savage By Design – Domain Models (v1)
//
import Foundation

// MARK: - ID Typealiases

public typealias BlockID = UUID
public typealias DayTemplateID = UUID
public typealias ExerciseTemplateID = UUID
public typealias ExerciseDefinitionID = UUID
public typealias WorkoutSessionID = UUID
public typealias SetGroupID = UUID

// MARK: - Core Enums

public enum ExerciseType: String, Codable {
    case strength
    case conditioning
    case mixed
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

// MARK: - Training Metadata Enums

/// High-level intent for a block or day (for AI + filtering).
public enum TrainingGoal: String, Codable {
    case strength
    case hypertrophy
    case power
    case conditioning
    case mixed
    case peaking
    case deload
    case rehab
}

/// Category for grouping movements.
public enum ExerciseCategory: String, Codable {
    case squat
    case hinge
    case pressHorizontal
    case pressVertical
    case pullHorizontal
    case pullVertical
    case carry
    case core
    case olympic
    case conditioning
    case mobility
    case mixed
    case other
}

/// How effort is described.
public enum EffortType: String, Codable {
    case none
    case rpe          // rating of perceived exertion
    case rir          // reps in reserve
    case percentOfMax // % of 1RM or training max
    case heartRateZone
}

/// Conditioning style.
public enum ConditioningType: String, Codable {
    case monostructural
    case mixedModal
    case emom
    case amrap
    case intervals
    case forTime
    case forDistance
    case forCalories
    case roundsForTime
    case other
}

/// Grouping style for supersets / circuits.
public enum SetGroupKind: String, Codable {
    case superset
    case giantSet
    case circuit
    case emom
    case amrap
}

// MARK: - Exercise Definition (Global Library)

public struct ExerciseDefinition: Identifiable, Codable, Equatable {
    public var id: ExerciseDefinitionID
    public var name: String
    public var type: ExerciseType
    public var category: ExerciseCategory?
    public var defaultConditioningType: ConditioningType?
    public var tags: [String]

    public init(
        id: ExerciseDefinitionID = ExerciseDefinitionID(),
        name: String,
        type: ExerciseType,
        category: ExerciseCategory? = nil,
        defaultConditioningType: ConditioningType? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.category = category
        self.defaultConditioningType = defaultConditioningType
        self.tags = tags
    }
}

// MARK: - Block Template

public struct Block: Identifiable, Codable, Equatable {
    public var id: BlockID
    public var name: String
    public var description: String?
    public var numberOfWeeks: Int
    public var goal: TrainingGoal?
    public var days: [DayTemplate]
    
    /// Optional week-specific day templates for blocks with exercise variations across weeks.
    /// If provided, this is an array where each element represents a week's day templates.
    /// weekTemplates[0] = Week 1 days, weekTemplates[1] = Week 2 days, etc.
    /// When nil or empty, falls back to replicating `days` for all weeks.
    public var weekTemplates: [[DayTemplate]]?
    
    public var source: BlockSource
    public var aiMetadata: AIMetadata?
    public var isArchived: Bool

    public init(
        id: BlockID = BlockID(),
        name: String,
        description: String? = nil,
        numberOfWeeks: Int,
        goal: TrainingGoal? = nil,
        days: [DayTemplate],
        weekTemplates: [[DayTemplate]]? = nil,
        source: BlockSource = .user,
        aiMetadata: AIMetadata? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.numberOfWeeks = numberOfWeeks
        self.goal = goal
        self.days = days
        self.weekTemplates = weekTemplates
        self.source = source
        self.aiMetadata = aiMetadata
        self.isArchived = isArchived
    }
}

// MARK: - Day Template

public struct DayTemplate: Identifiable, Codable, Equatable {
    public var id: DayTemplateID
    public var name: String
    public var shortCode: String?
    public var goal: TrainingGoal?
    public var notes: String?
    public var exercises: [ExerciseTemplate]

    public init(
        id: DayTemplateID = DayTemplateID(),
        name: String,
        shortCode: String? = nil,
        goal: TrainingGoal? = nil,
        notes: String? = nil,
        exercises: [ExerciseTemplate] = []
    ) {
        self.id = id
        self.name = name
        self.shortCode = shortCode
        self.goal = goal
        self.notes = notes
        self.exercises = exercises
    }
}

// MARK: - Superset / Circuit Group Template

public struct SetGroupTemplate: Identifiable, Codable, Equatable {
    public var id: SetGroupID
    public var name: String?
    public var kind: SetGroupKind
    public var roundCount: Int?        // e.g., 3 rounds for a circuit
    public var restBetweenRounds: Int? // seconds between rounds

    public init(
        id: SetGroupID = SetGroupID(),
        name: String? = nil,
        kind: SetGroupKind,
        roundCount: Int? = nil,
        restBetweenRounds: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.roundCount = roundCount
        self.restBetweenRounds = restBetweenRounds
    }
}

// MARK: - Exercise Template

public struct ExerciseTemplate: Identifiable, Codable, Equatable {
    public var id: ExerciseTemplateID

    public var exerciseDefinitionId: ExerciseDefinitionID?
    public var customName: String?
    public var type: ExerciseType
    public var category: ExerciseCategory?

    public var conditioningType: ConditioningType?
    public var notes: String?

    /// Optional group membership for supersets/circuits/etc.
    public var setGroupId: SetGroupID?

    /// Strength-style sets (reps/weight).
    public var strengthSets: [StrengthSetTemplate]?

    /// Conditioning-style sets (time, distance, calories, rounds).
    public var conditioningSets: [ConditioningSetTemplate]?

    /// Generic catch-all sets, primarily for older data or very custom use.
    public var genericSets: [SetTemplate]?

    /// Progression rule applied across weeks.
    public var progressionRule: ProgressionRule

    public init(
        id: ExerciseTemplateID = ExerciseTemplateID(),
        exerciseDefinitionId: ExerciseDefinitionID? = nil,
        customName: String? = nil,
        type: ExerciseType,
        category: ExerciseCategory? = nil,
        conditioningType: ConditioningType? = nil,
        notes: String? = nil,
        setGroupId: SetGroupID? = nil,
        strengthSets: [StrengthSetTemplate]? = nil,
        conditioningSets: [ConditioningSetTemplate]? = nil,
        genericSets: [SetTemplate]? = nil,
        progressionRule: ProgressionRule
    ) {
        self.id = id
        self.exerciseDefinitionId = exerciseDefinitionId
        self.customName = customName
        self.type = type
        self.category = category
        self.conditioningType = conditioningType
        self.notes = notes
        self.setGroupId = setGroupId
        self.strengthSets = strengthSets
        self.conditioningSets = conditioningSets
        self.genericSets = genericSets
        self.progressionRule = progressionRule
    }
}

// MARK: - Strength Set Template (separate model)

public struct StrengthSetTemplate: Identifiable, Codable, Equatable {
    public var id: UUID
    public var index: Int

    public var reps: Int?
    public var weight: Double?
    public var percentageOfMax: Double? // 0–1 (e.g., 0.75 for 75%)
    public var rpe: Double?
    public var rir: Double?
    public var tempo: String?
    public var restSeconds: Int?
    public var notes: String?

    public init(
        id: UUID = UUID(),
        index: Int,
        reps: Int? = nil,
        weight: Double? = nil,
        percentageOfMax: Double? = nil,
        rpe: Double? = nil,
        rir: Double? = nil,
        tempo: String? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.index = index
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

// MARK: - Conditioning Set Template (separate model)

public struct ConditioningSetTemplate: Identifiable, Codable, Equatable {
    public var id: UUID
    public var index: Int

    public var durationSeconds: Int?   // work interval
    public var distanceMeters: Double?
    public var calories: Double?
    public var rounds: Int?
    public var targetPace: String?     // e.g. "2:00/500m" or "easy/moderate/hard"
    public var effortDescriptor: String?
    public var restSeconds: Int?
    public var notes: String?

    public init(
        id: UUID = UUID(),
        index: Int,
        durationSeconds: Int? = nil,
        distanceMeters: Double? = nil,
        calories: Double? = nil,
        rounds: Int? = nil,
        targetPace: String? = nil,
        effortDescriptor: String? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.index = index
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

// MARK: - Generic Set Template (backwards-compatible / catch-all)

public struct SetTemplate: Identifiable, Codable, Equatable {
    public var id: UUID
    public var index: Int

    public var plannedReps: Int?
    public var plannedWeight: Double?
    public var plannedTime: Double?
    public var plannedDistance: Double?
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

// MARK: - Progression Rule

public struct ProgressionRule: Codable, Equatable {
    public var type: ProgressionType

    public var deltaWeight: Double?
    public var deltaSets: Int?
    public var deloadWeekIndexes: [Int]? // e.g. [4] for week 4 deload
    public var customParams: [String: String]?

    public init(
        type: ProgressionType,
        deltaWeight: Double? = nil,
        deltaSets: Int? = nil,
        deloadWeekIndexes: [Int]? = nil,
        customParams: [String: String]? = nil
    ) {
        self.type = type
        self.deltaWeight = deltaWeight
        self.deltaSets = deltaSets
        self.deloadWeekIndexes = deloadWeekIndexes
        self.customParams = customParams
    }
}

// MARK: - Live Workout Session Models

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

// In Models.swift (Around line 390)

public struct SessionSet: Identifiable, Codable, Equatable {
    public var id: UUID
    public var index: Int

    // expected
    public var expectedReps: Int?
    public var expectedWeight: Double?
    public var expectedTime: Double?
    public var expectedDistance: Double?
    public var expectedCalories: Double?
    public var expectedRounds: Int? // 🚨 ADDED

    // In Models.swift (Inside SessionSet struct definition, around line 407)

    // logged
    public var loggedReps: Int?
    public var loggedWeight: Double?
    public var loggedTime: Double?
    public var loggedDistance: Double?
    public var loggedCalories: Double?
    public var loggedRounds: Int? // This was added in the previous fix

    // optional effort / metadata (Phase-4 choice 4B) 🚨 ADD THESE PROPERTIES
    public var rpe: Double?         // 🚨 ADDED
    public var rir: Double?         // 🚨 ADDED
    public var tempo: String?       // 🚨 ADDED
    public var restSeconds: Int?    // 🚨 ADDED
    public var notes: String?       // 🚨 ADDED

    public var isCompleted: Bool
    public var completedAt: Date?
    
    // ... rest of the struct and initializer are now correct after the previous fix.


    // 🚨 UPDATE THE INITIALIZER (Around line 420)
    public init(
        id: UUID = UUID(),
        index: Int,
        expectedReps: Int? = nil,
        expectedWeight: Double? = nil,
        expectedTime: Double? = nil,
        expectedDistance: Double? = nil,
        expectedCalories: Double? = nil,
        expectedRounds: Int? = nil, // 🚨 ADDED
        loggedReps: Int? = nil,
        loggedWeight: Double? = nil,
        loggedTime: Double? = nil,
        loggedDistance: Double? = nil,
        loggedCalories: Double? = nil,
        loggedRounds: Int? = nil, // 🚨 ADDED
        rpe: Double? = nil,
        rir: Double? = nil,
        tempo: String? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.index = index
        self.expectedReps = expectedReps
        self.expectedWeight = expectedWeight
        self.expectedTime = expectedTime
        self.expectedDistance = expectedDistance
        self.expectedCalories = expectedCalories
        self.expectedRounds = expectedRounds // 🚨 ASSIGNMENT
        self.loggedReps = loggedReps
        self.loggedWeight = loggedWeight
        self.loggedTime = loggedTime
        self.loggedDistance = loggedDistance
        self.loggedCalories = loggedCalories
        self.loggedRounds = loggedRounds // 🚨 ASSIGNMENT
        self.rpe = rpe
        self.rir = rir
        self.tempo = tempo
        self.restSeconds = restSeconds
        self.notes = notes
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}


// MARK: - AI Metadata + Draft Models

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

/// Structure the AI will return before we map into real Block / Day / Exercise models.
public struct BlockDraft: Codable, Equatable {
    public struct DraftDay: Codable, Equatable {
        public var name: String
        public var shortCode: String?
        public var goal: TrainingGoal?
        public var exercises: [DraftExercise]

        public init(
            name: String,
            shortCode: String? = nil,
            goal: TrainingGoal? = nil,
            exercises: [DraftExercise]
        ) {
            self.name = name
            self.shortCode = shortCode
            self.goal = goal
            self.exercises = exercises
        }
    }

    public struct DraftExercise: Codable, Equatable {
        public struct DraftStrengthSet: Codable, Equatable {
            public var reps: Int?
            public var weight: Double?
            public var percentageOfMax: Double?

            public init(
                reps: Int? = nil,
                weight: Double? = nil,
                percentageOfMax: Double? = nil
            ) {
                self.reps = reps
                self.weight = weight
                self.percentageOfMax = percentageOfMax
            }
        }

        public struct DraftConditioningSet: Codable, Equatable {
            public var durationSeconds: Int?
            public var distanceMeters: Double?
            public var calories: Double?
            public var rounds: Int?

            public init(
                durationSeconds: Int? = nil,
                distanceMeters: Double? = nil,
                calories: Double? = nil,
                rounds: Int? = nil
            ) {
                self.durationSeconds = durationSeconds
                self.distanceMeters = distanceMeters
                self.calories = calories
                self.rounds = rounds
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
        public var category: ExerciseCategory?
        public var conditioningType: ConditioningType?

        public var notes: String?
        public var strengthSets: [DraftStrengthSet]?
        public var conditioningSets: [DraftConditioningSet]?
        public var progression: DraftProgression?

        public init(
            name: String,
            type: ExerciseType,
            category: ExerciseCategory? = nil,
            conditioningType: ConditioningType? = nil,
            notes: String? = nil,
            strengthSets: [DraftStrengthSet]? = nil,
            conditioningSets: [DraftConditioningSet]? = nil,
            progression: DraftProgression? = nil
        ) {
            self.name = name
            self.type = type
            self.category = category
            self.conditioningType = conditioningType
            self.notes = notes
            self.strengthSets = strengthSets
            self.conditioningSets = conditioningSets
            self.progression = progression
        }
    }

    public var name: String
    public var description: String?
    public var numberOfWeeks: Int
    public var goal: TrainingGoal?
    public var days: [DraftDay]

    public init(
        name: String,
        description: String? = nil,
        numberOfWeeks: Int,
        goal: TrainingGoal? = nil,
        days: [DraftDay]
    ) {
        self.name = name
        self.description = description
        self.numberOfWeeks = numberOfWeeks
        self.goal = goal
        self.days = days
    }
}

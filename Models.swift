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
    case skill  // For quality-based progression
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

// MARK: - Non-Traditional Session Enums

/// Type of class segment for structured sessions (BJJ, yoga, sports practice, business training, etc.)
public enum SegmentType: String, Codable {
    case warmup
    case mobility
    case technique
    case drill
    case positionalSpar
    case rolling
    case cooldown
    case lecture
    case breathwork
    case practice         // General sport practice or skill work
    case presentation     // Educational presentations or demos
    case review           // Reviewing/analyzing work or performance
    case demonstration    // Demonstrating skills or techniques
    case discussion       // Collaborative discussion or brainstorming
    case assessment       // Testing, evaluation, or quiz
    case other
}

/// Training domain classification
public enum Domain: String, Codable {
    case grappling
    case yoga
    case strength
    case conditioning
    case mobility
    case sports          // General sports (soccer, basketball, etc.)
    case business        // Business/professional training
    case education       // Educational content and learning
    case analytics       // Data analysis and business intelligence
    case other
}

/// Specific discipline tags
public enum Discipline: String, Codable {
    case bjj
    case nogi
    case wrestling
    case judo
    case yoga
    case mobility
    case breathwork
    case mma
}

/// Resistance level for partner drills
public enum ResistanceLevel: String, Codable {
    case compliant = "0"
    case light = "25"
    case moderate = "50"
    case hard = "75"
    case live = "100"
}

/// Intensity scale for yoga and mobility
public enum IntensityScale: String, Codable {
    case restorative
    case easy
    case moderate
    case strong
    case peak
}

/// Competition ruleset
public enum Ruleset: String, Codable {
    case ibjjf = "IBJJF"
    case adcc = "ADCC"
    case uww = "UWW"
    case custom
}

/// Training attire
public enum Attire: String, Codable {
    case gi
    case nogi
    case either
}

/// Class type classification
public enum ClassType: String, Codable {
    case fundamentals
    case advanced
    case competition
    case openMat
    case seminar
}

// MARK: - Non-Traditional Session Support Structures

/// Technique details for grappling/martial arts
public struct Technique: Codable, Equatable {
    public var name: String
    public var variant: String?
    public var keyDetails: [String]
    public var commonErrors: [String]
    public var counters: [String]
    public var followUps: [String]
    public var videoUrls: [String]?
    
    public init(
        name: String,
        variant: String? = nil,
        keyDetails: [String] = [],
        commonErrors: [String] = [],
        counters: [String] = [],
        followUps: [String] = [],
        videoUrls: [String]? = nil
    ) {
        self.name = name
        self.variant = variant
        self.keyDetails = keyDetails
        self.commonErrors = commonErrors
        self.counters = counters
        self.followUps = followUps
        self.videoUrls = videoUrls
    }
}

/// Round structure for sparring/drills
public struct RoundPlan: Codable, Equatable {
    public var rounds: Int
    public var roundDurationSeconds: Int
    public var restSeconds: Int
    public var intensityCue: String?
    public var resetRule: String?
    public var startingState: StartingState?
    public var winConditions: [String]
    
    public init(
        rounds: Int,
        roundDurationSeconds: Int,
        restSeconds: Int,
        intensityCue: String? = nil,
        resetRule: String? = nil,
        startingState: StartingState? = nil,
        winConditions: [String] = []
    ) {
        self.rounds = rounds
        self.roundDurationSeconds = roundDurationSeconds
        self.restSeconds = restSeconds
        self.intensityCue = intensityCue
        self.resetRule = resetRule
        self.startingState = startingState
        self.winConditions = winConditions
    }
}

/// Starting state for positional work
public struct StartingState: Codable, Equatable {
    public var grips: [String]
    public var roles: [String]
    
    public init(grips: [String] = [], roles: [String] = []) {
        self.grips = grips
        self.roles = roles
    }
}

/// Roles for partner drills
public struct Roles: Codable, Equatable {
    public var attackerGoal: String?
    public var defenderGoal: String?
    public var switchEveryReps: Int?
    
    public init(
        attackerGoal: String? = nil,
        defenderGoal: String? = nil,
        switchEveryReps: Int? = nil
    ) {
        self.attackerGoal = attackerGoal
        self.defenderGoal = defenderGoal
        self.switchEveryReps = switchEveryReps
    }
}

/// Quality metrics for skill-based training
public struct QualityTargets: Codable, Equatable {
    public var successRateTarget: Double?
    public var cleanRepsTarget: Int?
    public var decisionSpeedSeconds: Double?
    public var controlTimeSeconds: Int?
    public var breathControl: String?
    
    public init(
        successRateTarget: Double? = nil,
        cleanRepsTarget: Int? = nil,
        decisionSpeedSeconds: Double? = nil,
        controlTimeSeconds: Int? = nil,
        breathControl: String? = nil
    ) {
        self.successRateTarget = successRateTarget
        self.cleanRepsTarget = cleanRepsTarget
        self.decisionSpeedSeconds = decisionSpeedSeconds
        self.controlTimeSeconds = controlTimeSeconds
        self.breathControl = breathControl
    }
}

/// Safety information and contraindications
public struct Safety: Codable, Equatable {
    public var contraindications: [String]
    public var stopIf: [String]
    public var intensityCeiling: String?
    
    public init(
        contraindications: [String] = [],
        stopIf: [String] = [],
        intensityCeiling: String? = nil
    ) {
        self.contraindications = contraindications
        self.stopIf = stopIf
        self.intensityCeiling = intensityCeiling
    }
}

/// Breathwork pattern
public struct BreathworkPlan: Codable, Equatable {
    public var style: String
    public var pattern: String
    public var durationSeconds: Int
    
    public init(style: String, pattern: String, durationSeconds: Int) {
        self.style = style
        self.pattern = pattern
        self.durationSeconds = durationSeconds
    }
}

/// Media and coaching support
public struct Media: Codable, Equatable {
    public var videoUrl: String?
    public var imageUrl: String?
    public var diagramAssetId: String?
    public var coachNotesMarkdown: String?
    public var commonFaults: [String]
    public var keyCues: [String]
    public var checkpoints: [String]
    
    public init(
        videoUrl: String? = nil,
        imageUrl: String? = nil,
        diagramAssetId: String? = nil,
        coachNotesMarkdown: String? = nil,
        commonFaults: [String] = [],
        keyCues: [String] = [],
        checkpoints: [String] = []
    ) {
        self.videoUrl = videoUrl
        self.imageUrl = imageUrl
        self.diagramAssetId = diagramAssetId
        self.coachNotesMarkdown = coachNotesMarkdown
        self.commonFaults = commonFaults
        self.keyCues = keyCues
        self.checkpoints = checkpoints
    }
}

/// Drill item for warmup sequences
public struct DrillItem: Codable, Equatable {
    public var name: String
    public var workSeconds: Int
    public var restSeconds: Int
    public var notes: String?
    
    public init(name: String, workSeconds: Int, restSeconds: Int, notes: String? = nil) {
        self.name = name
        self.workSeconds = workSeconds
        self.restSeconds = restSeconds
        self.notes = notes
    }
}

/// Drill plan container
public struct DrillPlan: Codable, Equatable {
    public var items: [DrillItem]
    
    public init(items: [DrillItem] = []) {
        self.items = items
    }
}

/// Partner drill plan
public struct PartnerPlan: Codable, Equatable {
    public var rounds: Int
    public var roundDurationSeconds: Int
    public var restSeconds: Int
    public var roles: Roles?
    public var resistance: Int  // 0-100
    public var switchEverySeconds: Int?
    public var qualityTargets: QualityTargets?
    
    public init(
        rounds: Int,
        roundDurationSeconds: Int,
        restSeconds: Int,
        roles: Roles? = nil,
        resistance: Int = 0,
        switchEverySeconds: Int? = nil,
        qualityTargets: QualityTargets? = nil
    ) {
        self.rounds = rounds
        self.roundDurationSeconds = roundDurationSeconds
        self.restSeconds = restSeconds
        self.roles = roles
        self.resistance = resistance
        self.switchEverySeconds = switchEverySeconds
        self.qualityTargets = qualityTargets
    }
}

/// Scoring conditions for positional sparring
public struct Scoring: Codable, Equatable {
    public var attackerScoresIf: [String]
    public var defenderScoresIf: [String]
    
    public init(attackerScoresIf: [String] = [], defenderScoresIf: [String] = []) {
        self.attackerScoresIf = attackerScoresIf
        self.defenderScoresIf = defenderScoresIf
    }
}

/// Flow sequence step for yoga
public struct FlowStep: Codable, Equatable {
    public var poseName: String
    public var holdSeconds: Int
    public var transitionCue: String?
    
    public init(poseName: String, holdSeconds: Int, transitionCue: String? = nil) {
        self.poseName = poseName
        self.holdSeconds = holdSeconds
        self.transitionCue = transitionCue
    }
}

// MARK: - Exercise Definition (Global Library)

public struct ExerciseDefinition: Identifiable, Codable, Equatable {
    public var id: ExerciseDefinitionID
    public var name: String
    public var type: ExerciseType
    public var category: ExerciseCategory?
    public var defaultConditioningType: ConditioningType?
    public var tags: [String]
    public var videoUrls: [String]?

    public init(
        id: ExerciseDefinitionID = ExerciseDefinitionID(),
        name: String,
        type: ExerciseType,
        category: ExerciseCategory? = nil,
        defaultConditioningType: ConditioningType? = nil,
        tags: [String] = [],
        videoUrls: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.category = category
        self.defaultConditioningType = defaultConditioningType
        self.tags = tags
        self.videoUrls = videoUrls
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
    public var isActive: Bool
    
    // Non-traditional session metadata
    public var tags: [String]?
    public var disciplines: [Discipline]?
    public var ruleset: Ruleset?
    public var attire: Attire?
    public var classType: ClassType?

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
        isArchived: Bool = false,
        isActive: Bool = false,
        tags: [String]? = nil,
        disciplines: [Discipline]? = nil,
        ruleset: Ruleset? = nil,
        attire: Attire? = nil,
        classType: ClassType? = nil
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
        self.isActive = isActive
        self.tags = tags
        self.disciplines = disciplines
        self.ruleset = ruleset
        self.attire = attire
        self.classType = classType
    }
}

// MARK: - Segment (Non-Traditional Session Unit)

public typealias SegmentID = UUID

public struct Segment: Identifiable, Codable, Equatable {
    public var id: SegmentID
    public var name: String
    public var segmentType: SegmentType
    public var domain: Domain?
    public var durationMinutes: Int?
    public var objective: String?
    public var constraints: [String]
    public var coachingCues: [String]
    
    // Position and technique taxonomy
    public var positions: [String]
    public var techniques: [Technique]
    
    // Round structures
    public var roundPlan: RoundPlan?
    public var drillPlan: DrillPlan?
    public var partnerPlan: PartnerPlan?
    
    // Roles and resistance
    public var roles: Roles?
    public var resistance: Int?  // 0-100
    
    // Quality metrics
    public var qualityTargets: QualityTargets?
    
    // Scoring (for positional sparring)
    public var scoring: Scoring?
    public var startPosition: String?
    public var endCondition: String?
    public var startingState: StartingState?
    
    // Yoga/Mobility specific
    public var holdSeconds: Int?
    public var breathCount: Int?
    public var flowSequence: [FlowStep]
    public var intensityScale: IntensityScale?
    public var props: [String]
    
    // Breathwork
    public var breathwork: BreathworkPlan?
    
    // Media and safety
    public var media: Media?
    public var safety: Safety?
    
    public var notes: String?
    
    public init(
        id: SegmentID = SegmentID(),
        name: String,
        segmentType: SegmentType,
        domain: Domain? = nil,
        durationMinutes: Int? = nil,
        objective: String? = nil,
        constraints: [String] = [],
        coachingCues: [String] = [],
        positions: [String] = [],
        techniques: [Technique] = [],
        roundPlan: RoundPlan? = nil,
        drillPlan: DrillPlan? = nil,
        partnerPlan: PartnerPlan? = nil,
        roles: Roles? = nil,
        resistance: Int? = nil,
        qualityTargets: QualityTargets? = nil,
        scoring: Scoring? = nil,
        startPosition: String? = nil,
        endCondition: String? = nil,
        startingState: StartingState? = nil,
        holdSeconds: Int? = nil,
        breathCount: Int? = nil,
        flowSequence: [FlowStep] = [],
        intensityScale: IntensityScale? = nil,
        props: [String] = [],
        breathwork: BreathworkPlan? = nil,
        media: Media? = nil,
        safety: Safety? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.segmentType = segmentType
        self.domain = domain
        self.durationMinutes = durationMinutes
        self.objective = objective
        self.constraints = constraints
        self.coachingCues = coachingCues
        self.positions = positions
        self.techniques = techniques
        self.roundPlan = roundPlan
        self.drillPlan = drillPlan
        self.partnerPlan = partnerPlan
        self.roles = roles
        self.resistance = resistance
        self.qualityTargets = qualityTargets
        self.scoring = scoring
        self.startPosition = startPosition
        self.endCondition = endCondition
        self.startingState = startingState
        self.holdSeconds = holdSeconds
        self.breathCount = breathCount
        self.flowSequence = flowSequence
        self.intensityScale = intensityScale
        self.props = props
        self.breathwork = breathwork
        self.media = media
        self.safety = safety
        self.notes = notes
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
    
    /// Optional segments for non-traditional sessions (BJJ, yoga, etc.)
    /// When segments are present, they represent the primary structure of the day
    /// Can coexist with exercises for hybrid sessions
    public var segments: [Segment]?

    public init(
        id: DayTemplateID = DayTemplateID(),
        name: String,
        shortCode: String? = nil,
        goal: TrainingGoal? = nil,
        notes: String? = nil,
        exercises: [ExerciseTemplate] = [],
        segments: [Segment]? = nil
    ) {
        self.id = id
        self.name = name
        self.shortCode = shortCode
        self.goal = goal
        self.notes = notes
        self.exercises = exercises
        self.segments = segments
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
    
    /// Video URLs for technique demonstrations
    public var videoUrls: [String]?

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
        progressionRule: ProgressionRule,
        videoUrls: [String]? = nil
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
        self.videoUrls = videoUrls
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
    
    // Skill-based progression parameters
    public var deltaResistance: Int?  // Change in resistance level (0-100)
    public var deltaRounds: Int?      // Change in number of rounds
    public var deltaConstraints: [String]?  // Progressive constraint tightening

    public init(
        type: ProgressionType,
        deltaWeight: Double? = nil,
        deltaSets: Int? = nil,
        deloadWeekIndexes: [Int]? = nil,
        customParams: [String: String]? = nil,
        deltaResistance: Int? = nil,
        deltaRounds: Int? = nil,
        deltaConstraints: [String]? = nil
    ) {
        self.type = type
        self.deltaWeight = deltaWeight
        self.deltaSets = deltaSets
        self.deloadWeekIndexes = deloadWeekIndexes
        self.customParams = customParams
        self.deltaResistance = deltaResistance
        self.deltaRounds = deltaRounds
        self.deltaConstraints = deltaConstraints
    }
}

// MARK: - Live Workout Session Models

/// Session segment for live tracking of non-traditional session units
public struct SessionSegment: Identifiable, Codable, Equatable {
    public var id: UUID
    public var segmentId: SegmentID?
    public var name: String
    public var segmentType: SegmentType
    
    // Logged data
    public var startTime: Date?
    public var endTime: Date?
    public var isCompleted: Bool
    public var actualDurationMinutes: Int?
    
    // Quality metrics logged
    public var successRate: Double?
    public var cleanReps: Int?
    public var decisionSpeed: Double?
    public var controlTime: Int?
    
    // Round/drill tracking
    public var roundsCompleted: Int?
    public var drillItemsCompleted: Int?
    
    // Notes and feedback
    public var notes: String?
    public var coachFeedback: String?
    
    public init(
        id: UUID = UUID(),
        segmentId: SegmentID? = nil,
        name: String,
        segmentType: SegmentType,
        startTime: Date? = nil,
        endTime: Date? = nil,
        isCompleted: Bool = false,
        actualDurationMinutes: Int? = nil,
        successRate: Double? = nil,
        cleanReps: Int? = nil,
        decisionSpeed: Double? = nil,
        controlTime: Int? = nil,
        roundsCompleted: Int? = nil,
        drillItemsCompleted: Int? = nil,
        notes: String? = nil,
        coachFeedback: String? = nil
    ) {
        self.id = id
        self.segmentId = segmentId
        self.name = name
        self.segmentType = segmentType
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
        self.actualDurationMinutes = actualDurationMinutes
        self.successRate = successRate
        self.cleanReps = cleanReps
        self.decisionSpeed = decisionSpeed
        self.controlTime = controlTime
        self.roundsCompleted = roundsCompleted
        self.drillItemsCompleted = drillItemsCompleted
        self.notes = notes
        self.coachFeedback = coachFeedback
    }
}

public struct WorkoutSession: Identifiable, Codable, Equatable {
    public var id: WorkoutSessionID
    public var blockId: BlockID
    public var weekIndex: Int
    public var dayTemplateId: DayTemplateID
    public var date: Date?
    public var status: SessionStatus
    public var exercises: [SessionExercise]
    
    /// Optional segments for non-traditional sessions
    /// When present, represents the segment-based structure of the session
    public var segments: [SessionSegment]?

    public init(
        id: WorkoutSessionID = WorkoutSessionID(),
        blockId: BlockID,
        weekIndex: Int,
        dayTemplateId: DayTemplateID,
        date: Date? = nil,
        status: SessionStatus = .notStarted,
        exercises: [SessionExercise],
        segments: [SessionSegment]? = nil
    ) {
        self.id = id
        self.blockId = blockId
        self.weekIndex = weekIndex
        self.dayTemplateId = dayTemplateId
        self.date = date
        self.status = status
        self.exercises = exercises
        self.segments = segments
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

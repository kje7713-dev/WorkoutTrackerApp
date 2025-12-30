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
    public var segments: [UnifiedSegment]  // Added for non-traditional sessions
    
    public init(
        name: String,
        goal: String? = nil,
        exercises: [UnifiedExercise] = [],
        segments: [UnifiedSegment] = []
    ) {
        self.name = name
        self.goal = goal
        self.exercises = exercises
        self.segments = segments
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
    public var weight: Double?
    public var restSeconds: Int?
    public var rpe: Double?
    public var notes: String?
    
    public init(
        reps: Int? = nil,
        weight: Double? = nil,
        restSeconds: Int? = nil,
        rpe: Double? = nil,
        notes: String? = nil
    ) {
        self.reps = reps
        self.weight = weight
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

/// Unified segment for non-traditional sessions
public struct UnifiedSegment: Codable, Equatable {
    public var name: String
    public var segmentType: String  // warmup|technique|drill|positionalSpar|rolling|cooldown|lecture|breathwork|other
    public var domain: String?  // grappling|yoga|strength|conditioning|mobility|other
    public var durationMinutes: Int?
    public var objective: String?
    public var constraints: [String]
    public var coachingCues: [String]
    public var positions: [String]
    public var techniques: [UnifiedTechnique]
    public var rounds: Int?
    public var roundDurationSeconds: Int?
    public var restSeconds: Int?
    public var workSeconds: Int?
    public var resistance: Int?  // 0-100
    public var attackerGoal: String?
    public var defenderGoal: String?
    public var successRateTarget: Double?
    public var cleanRepsTarget: Int?
    public var startPosition: String?
    public var scoring: [String]  // Simplified scoring description
    public var breathworkStyle: String?
    public var breathworkPattern: String?
    public var holdSeconds: Int?
    public var intensityScale: String?
    public var props: [String]
    public var notes: String?
    public var contraindications: [String]
    public var drillItems: [UnifiedDrillItem]
    
    public init(
        name: String,
        segmentType: String,
        domain: String? = nil,
        durationMinutes: Int? = nil,
        objective: String? = nil,
        constraints: [String] = [],
        coachingCues: [String] = [],
        positions: [String] = [],
        techniques: [UnifiedTechnique] = [],
        rounds: Int? = nil,
        roundDurationSeconds: Int? = nil,
        restSeconds: Int? = nil,
        workSeconds: Int? = nil,
        resistance: Int? = nil,
        attackerGoal: String? = nil,
        defenderGoal: String? = nil,
        successRateTarget: Double? = nil,
        cleanRepsTarget: Int? = nil,
        startPosition: String? = nil,
        scoring: [String] = [],
        breathworkStyle: String? = nil,
        breathworkPattern: String? = nil,
        holdSeconds: Int? = nil,
        intensityScale: String? = nil,
        props: [String] = [],
        notes: String? = nil,
        contraindications: [String] = [],
        drillItems: [UnifiedDrillItem] = []
    ) {
        self.name = name
        self.segmentType = segmentType
        self.domain = domain
        self.durationMinutes = durationMinutes
        self.objective = objective
        self.constraints = constraints
        self.coachingCues = coachingCues
        self.positions = positions
        self.techniques = techniques
        self.rounds = rounds
        self.roundDurationSeconds = roundDurationSeconds
        self.restSeconds = restSeconds
        self.workSeconds = workSeconds
        self.resistance = resistance
        self.attackerGoal = attackerGoal
        self.defenderGoal = defenderGoal
        self.successRateTarget = successRateTarget
        self.cleanRepsTarget = cleanRepsTarget
        self.startPosition = startPosition
        self.scoring = scoring
        self.breathworkStyle = breathworkStyle
        self.breathworkPattern = breathworkPattern
        self.holdSeconds = holdSeconds
        self.intensityScale = intensityScale
        self.props = props
        self.notes = notes
        self.contraindications = contraindications
        self.drillItems = drillItems
    }
}

/// Unified technique representation
public struct UnifiedTechnique: Codable, Equatable {
    public var name: String
    public var variant: String?
    public var keyDetails: [String]
    public var commonErrors: [String]
    
    public init(
        name: String,
        variant: String? = nil,
        keyDetails: [String] = [],
        commonErrors: [String] = []
    ) {
        self.name = name
        self.variant = variant
        self.keyDetails = keyDetails
        self.commonErrors = commonErrors
    }
}

/// Unified drill item for warmup sequences
public struct UnifiedDrillItem: Codable, Equatable {
    public var name: String
    public var workSeconds: Int
    public var restSeconds: Int
    public var notes: String?
    
    public init(
        name: String,
        workSeconds: Int,
        restSeconds: Int,
        notes: String? = nil
    ) {
        self.name = name
        self.workSeconds = workSeconds
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
    public var segments: [AuthoringSegment]?  // Added for non-traditional sessions
}

/// Authoring schema segment
public struct AuthoringSegment: Codable {
    public var name: String
    public var segmentType: String
    public var domain: String?
    public var durationMinutes: Int?
    public var objective: String?
    public var constraints: [String]?
    public var coachingCues: [String]?
    public var positions: [String]?
    public var techniques: [AuthoringTechnique]?
    public var drillPlan: AuthoringDrillPlan?
    public var partnerPlan: AuthoringPartnerPlan?
    public var roundPlan: AuthoringRoundPlan?
    public var roles: AuthoringRoles?
    public var resistance: Int?
    public var qualityTargets: AuthoringQualityTargets?
    public var scoring: AuthoringScoring?
    public var startPosition: String?
    public var endCondition: String?
    public var startingState: AuthoringStartingState?
    public var holdSeconds: Int?
    public var breathCount: Int?
    public var flowSequence: [AuthoringFlowStep]?
    public var intensityScale: String?
    public var props: [String]?
    public var breathwork: AuthoringBreathwork?
    public var media: AuthoringMedia?
    public var safety: AuthoringSafety?
    public var notes: String?
}

public struct AuthoringTechnique: Codable {
    public var name: String
    public var variant: String?
    public var keyDetails: [String]?
    public var commonErrors: [String]?
    public var counters: [String]?
    public var followUps: [String]?
}

public struct AuthoringDrillPlan: Codable {
    public var items: [AuthoringDrillItem]
}

public struct AuthoringDrillItem: Codable {
    public var name: String
    public var workSeconds: Int
    public var restSeconds: Int
    public var notes: String?
}

public struct AuthoringPartnerPlan: Codable {
    public var rounds: Int
    public var roundDurationSeconds: Int
    public var restSeconds: Int
    public var roles: AuthoringRoles?
    public var resistance: Int?
    public var switchEverySeconds: Int?
    public var qualityTargets: AuthoringQualityTargets?
}

public struct AuthoringRoundPlan: Codable {
    public var rounds: Int
    public var roundDurationSeconds: Int
    public var restSeconds: Int
    public var intensityCue: String?
    public var resetRule: String?
    public var startingState: AuthoringStartingState?
    public var winConditions: [String]?
}

public struct AuthoringRoles: Codable {
    public var attackerGoal: String?
    public var defenderGoal: String?
    public var switchEveryReps: Int?
}

public struct AuthoringQualityTargets: Codable {
    public var successRateTarget: Double?
    public var cleanRepsTarget: Int?
    public var decisionSpeedSeconds: Double?
    public var controlTimeSeconds: Int?
    public var breathControl: String?
}

public struct AuthoringScoring: Codable {
    public var attackerScoresIf: [String]?
    public var defenderScoresIf: [String]?
}

public struct AuthoringStartingState: Codable {
    public var grips: [String]?
    public var roles: [String]?
}

public struct AuthoringFlowStep: Codable {
    public var poseName: String
    public var holdSeconds: Int
    public var transitionCue: String?
}

public struct AuthoringBreathwork: Codable {
    public var style: String
    public var pattern: String
    public var durationSeconds: Int
}

public struct AuthoringMedia: Codable {
    public var videoUrl: String?
    public var imageUrl: String?
    public var diagramAssetId: String?
    public var coachNotesMarkdown: String?
    public var commonFaults: [String]?
    public var keyCues: [String]?
    public var checkpoints: [String]?
}

public struct AuthoringSafety: Codable {
    public var contraindications: [String]?
    public var stopIf: [String]?
    public var intensityCeiling: String?
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

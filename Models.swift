import Foundation
import SwiftData

// MARK: - Exercise Library

@Model
class ExerciseTemplate {
    @Attribute(.unique) var id: UUID
    var name: String             // "Back Squat"
    var category: String?        // "Squat", "Press", "Pull" etc.
    var defaultReps: Int?        // optional default prescription
    var defaultSets: Int?
    var defaultRPE: Double?      // e.g. 8.0
    var defaultTempo: String?    // e.g. "3-1-1"
    var notes: String?           // cues like "drive knees out"

    init(
        id: UUID = UUID(),
        name: String,
        category: String? = nil,
        defaultReps: Int? = nil,
        defaultSets: Int? = nil,
        defaultRPE: Double? = nil,
        defaultTempo: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.defaultReps = defaultReps
        self.defaultSets = defaultSets
        self.defaultRPE = defaultRPE
        self.defaultTempo = defaultTempo
        self.notes = notes
    }
}

// MARK: - Plan / Templates

@Model
class BlockTemplate {
    @Attribute(.unique) var id: UUID
    var name: String                     // "SBD Block 1 – 4 Week Strength"
    var weeksCount: Int                  // 4
    var createdAt: Date
    var createdByUser: Bool              // true = user-made, false = built-in
    var notes: String?
    
    // To-many relationship to day templates
    @Relationship(deleteRule: .cascade) var days: [DayTemplate]

    init(
        id: UUID = UUID(),
        name: String,
        weeksCount: Int,
        createdAt: Date = .now,
        createdByUser: Bool = true,
        notes: String? = nil,
        days: [DayTemplate] = []
    ) {
        self.id = id
        self.name = name
        self.weeksCount = weeksCount
        self.createdAt = createdAt
        self.createdByUser = createdByUser
        self.notes = notes
        self.days = days
    }
}

@Model
class DayTemplate {
    @Attribute(.unique) var id: UUID
    var weekIndex: Int       // 1..N
    var dayIndex: Int        // 1..7
    var title: String        // "Heavy Lower"
    var dayDescription: String
    var orderIndex: Int      // so you can reorder days inside a week
    
    @Relationship(inverse: \BlockTemplate.days) var block: BlockTemplate?
    @Relationship(deleteRule: .cascade) var exercises: [PlannedExercise]

    init(
        id: UUID = UUID(),
        weekIndex: Int,
        dayIndex: Int,
        title: String,
        dayDescription: String,
        orderIndex: Int = 0,
        block: BlockTemplate? = nil,
        exercises: [PlannedExercise] = []
    ) {
        self.id = id
        self.weekIndex = weekIndex
        self.dayIndex = dayIndex
        self.title = title
        self.dayDescription = dayDescription
        self.orderIndex = orderIndex
        self.block = block
        self.exercises = exercises
    }
}

@Model
class PlannedExercise {
    @Attribute(.unique) var id: UUID
    var orderIndex: Int                 // reorderable
    var notes: String?                  // special instructions for this day
    
    @Relationship var exerciseTemplate: ExerciseTemplate?
    @Relationship(inverse: \DayTemplate.exercises) var day: DayTemplate?
    @Relationship(deleteRule: .cascade) var prescribedSets: [PrescribedSet]

    init(
        id: UUID = UUID(),
        orderIndex: Int,
        exerciseTemplate: ExerciseTemplate?,
        day: DayTemplate? = nil,
        notes: String? = nil,
        prescribedSets: [PrescribedSet] = []
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.exerciseTemplate = exerciseTemplate
        self.day = day
        self.notes = notes
        self.prescribedSets = prescribedSets
    }
}

@Model
class PrescribedSet {
    @Attribute(.unique) var id: UUID
    var setIndex: Int               // 1..N
    var targetReps: Int
    var targetWeight: Double        // in lb or kg depending on app setting
    var targetRPE: Double?          // 8.0 etc
    var tempo: String?              // "3-1-1" etc
    var notes: String?
    
    @Relationship(inverse: \PlannedExercise.prescribedSets) var plannedExercise: PlannedExercise?

    init(
        id: UUID = UUID(),
        setIndex: Int,
        targetReps: Int,
        targetWeight: Double,
        targetRPE: Double? = nil,
        tempo: String? = nil,
        notes: String? = nil,
        plannedExercise: PlannedExercise? = nil
    ) {
        self.id = id
        self.setIndex = setIndex
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.targetRPE = targetRPE
        self.tempo = tempo
        self.notes = notes
        self.plannedExercise = plannedExercise
    }
}

// MARK: - Log / History

@Model
class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var date: Date
    var weekIndex: Int
    var dayIndex: Int
    var isCompleted: Bool
    var notes: String?
    
    // Link back to plan (optional, but super useful for metrics)
    @Relationship var blockTemplate: BlockTemplate?
    @Relationship var dayTemplate: DayTemplate?
    
    // To-many exercises actually performed
    @Relationship(deleteRule: .cascade) var exercises: [SessionExercise]

    init(
        id: UUID = UUID(),
        date: Date = .now,
        weekIndex: Int,
        dayIndex: Int,
        isCompleted: Bool = false,
        notes: String? = nil,
        blockTemplate: BlockTemplate? = nil,
        dayTemplate: DayTemplate? = nil,
        exercises: [SessionExercise] = []
    ) {
        self.id = id
        self.date = date
        self.weekIndex = weekIndex
        self.dayIndex = dayIndex
        self.isCompleted = isCompleted
        self.notes = notes
        self.blockTemplate = blockTemplate
        self.dayTemplate = dayTemplate
        self.exercises = exercises
    }
}

@Model
class SessionExercise {
    @Attribute(.unique) var id: UUID
    var orderIndex: Int
    var nameOverride: String?         // if user changes name for this session
    var notes: String?
    
    @Relationship(inverse: \WorkoutSession.exercises) var session: WorkoutSession?
    @Relationship var exerciseTemplate: ExerciseTemplate?   // original template (optional)
    @Relationship(deleteRule: .cascade) var sets: [SessionSet]

    init(
        id: UUID = UUID(),
        orderIndex: Int,
        session: WorkoutSession? = nil,
        exerciseTemplate: ExerciseTemplate? = nil,
        nameOverride: String? = nil,
        notes: String? = nil,
        sets: [SessionSet] = []
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.session = session
        self.exerciseTemplate = exerciseTemplate
        self.nameOverride = nameOverride
        self.notes = notes
        self.sets = sets
    }
}

@Model
class SessionSet {
    @Attribute(.unique) var id: UUID
    var setIndex: Int
    
    // Copy of plan values at time of training (so you can see what was expected)
    var targetReps: Int
    var targetWeight: Double
    var targetRPE: Double?
    
    // Actual performance
    var actualReps: Int
    var actualWeight: Double
    var actualRPE: Double?
    var completed: Bool
    var timestamp: Date?
    var notes: String?

    @Relationship(inverse: \SessionExercise.sets) var sessionExercise: SessionExercise?

    init(
        id: UUID = UUID(),
        setIndex: Int,
        targetReps: Int,
        targetWeight: Double,
        targetRPE: Double? = nil,
        actualReps: Int = 0,
        actualWeight: Double = 0,
        actualRPE: Double? = nil,
        completed: Bool = false,
        timestamp: Date? = nil,
        notes: String? = nil,
        sessionExercise: SessionExercise? = nil
    ) {
        self.id = id
        self.setIndex = setIndex
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.targetRPE = targetRPE
        self.actualReps = actualReps
        self.actualWeight = actualWeight
        self.actualRPE = actualRPE
        self.completed = completed
        self.timestamp = timestamp
        self.notes = notes
        self.sessionExercise = sessionExercise
    }
}
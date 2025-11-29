import Foundation
import SwiftData

// MARK: - Block / Plan Models

@Model
final class BlockTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    var weeksCount: Int
    var createdAt: Date
    var createdByUser: Bool
    var notes: String?

    // One block has many day templates
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
final class DayTemplate {
    @Attribute(.unique) var id: UUID
    var weekIndex: Int
    var dayIndex: Int
    var title: String
    var dayDescription: String
    var orderIndex: Int

    // Back-reference to parent block
    @Relationship var block: BlockTemplate

    // Planned exercises for this day
    @Relationship(deleteRule: .cascade) var exercises: [PlannedExercise]

    init(
        id: UUID = UUID(),
        weekIndex: Int,
        dayIndex: Int,
        title: String,
        dayDescription: String,
        orderIndex: Int,
        block: BlockTemplate,
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
final class ExerciseTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: String?
    var defaultReps: Int?
    var defaultSets: Int?
    var defaultRPE: Double?
    var defaultTempo: String?
    var notes: String?

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

@Model
final class PlannedExercise {
    @Attribute(.unique) var id: UUID
    var orderIndex: Int
    var notes: String?

    // Link to exercise catalog + parent day
    @Relationship var exerciseTemplate: ExerciseTemplate?
    @Relationship var day: DayTemplate

    // Prescribed sets for this planned exercise
    @Relationship(deleteRule: .cascade) var prescribedSets: [PrescribedSet]

    init(
        id: UUID = UUID(),
        orderIndex: Int,
        exerciseTemplate: ExerciseTemplate?,
        day: DayTemplate,
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
final class PrescribedSet {
    @Attribute(.unique) var id: UUID
    var setIndex: Int
    var targetReps: Int
    var targetWeight: Double
    var targetRPE: Double?
    var tempo: String?
    var notes: String?

    @Relationship var plannedExercise: PlannedExercise

    init(
        id: UUID = UUID(),
        setIndex: Int,
        targetReps: Int,
        targetWeight: Double,
        targetRPE: Double? = nil,
        tempo: String? = nil,
        notes: String? = nil,
        plannedExercise: PlannedExercise
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

// MARK: - Workout / Logging Models

@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var date: Date
    var weekIndex: Int
    var dayIndex: Int
    var isCompleted: Bool
    var notes: String?

    // Optional links back to the plan
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
final class SessionExercise {
    @Attribute(.unique) var id: UUID
    var orderIndex: Int
    var nameOverride: String?

    @Relationship var session: WorkoutSession
    @Relationship var exerciseTemplate: ExerciseTemplate?

    @Relationship(deleteRule: .cascade) var sets: [SessionSet]

    init(
        id: UUID = UUID(),
        orderIndex: Int,
        session: WorkoutSession,
        exerciseTemplate: ExerciseTemplate?,
        nameOverride: String? = nil,
        sets: [SessionSet] = []
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.session = session
        self.exerciseTemplate = exerciseTemplate
        self.nameOverride = nameOverride
        self.sets = sets
    }
}

@Model
final class SessionSet {
    @Attribute(.unique) var id: UUID
    var setIndex: Int
    var targetReps: Int
    var targetWeight: Double
    var targetRPE: Double?

    var actualReps: Int
    var actualWeight: Double
    var actualRPE: Double?

    var completed: Bool
    var timestamp: Date?
    var notes: String?

    @Relationship var sessionExercise: SessionExercise

    init(
        id: UUID = UUID(),
        setIndex: Int,
        targetReps: Int,
        targetWeight: Double,
        targetRPE: Double? = nil,
        actualReps: Int,
        actualWeight: Double,
        actualRPE: Double? = nil,
        completed: Bool = false,
        timestamp: Date? = nil,
        notes: String? = nil,
        sessionExercise: SessionExercise
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
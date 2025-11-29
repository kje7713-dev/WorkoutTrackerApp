import SwiftData
import Foundation

// MARK: - BlockTemplate & DayTemplate assumed already @Model elsewhere

@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var date: Date
    var weekIndex: Int
    var dayIndex: Int
    var isCompleted: Bool
    var notes: String?
    
    // Link back to plan
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
        exerciseTemplate: ExerciseTemplate? = nil,
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
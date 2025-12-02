
import Foundation

// MARK: - Core Models

enum ProgressionType: String, CaseIterable, Identifiable, Codable {
    case weight = "Weight"
    case volume = "Volume"

    var id: String { rawValue }
}

struct WorkoutSetTemplate: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var setIndex: Int
    var reps: Int?
    var weight: Double?
    var timeSeconds: Int?
}

struct ExerciseTemplate: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String
    var isConditioning: Bool
    var notes: String
    var sets: [WorkoutSetTemplate]
}

struct DayTemplate: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String
    var exercises: [ExerciseTemplate]
}

struct BlockTemplate: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String
    var weeks: Int
    var progression: ProgressionType
    var days: [DayTemplate]
}

import Foundation

// MARK: - Core Models

struct Exercise: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var reps: Int
    var weight: Double?
    var isCompleted: Bool = false
}

struct WorkoutSession: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var dayTitle: String           // "Day 1 – Bench Focus"
    var description: String        // subtitle text
    var exercises: [Exercise]
}

// MARK: - Exercise Library (master list)

struct ExerciseLibrary {
    /// Master list of exercise names for the dropdown
    static let masterNames: [String] = [
        "Back Squat",
        "Front Squat",
        "Bench Press",
        "Incline Bench Press",
        "Overhead Press",
        "Deadlift",
        "Sumo Deadlift",
        "Romanian Deadlift",
        "Pull-Up",
        "Chin-Up",
        "Barbell Row",
        "Dumbbell Row",
        "Lat Pulldown",
        "Cable Row",
        "Hip Thrust",
        "Leg Press",
        "Lunge",
        "Split Squat",
        "Push-Up",
        "Dip",
        "Biceps Curl",
        "Triceps Extension",
        "Face Pull",
        "Lateral Raise",
        "Hamstring Curl",
        "Calf Raise",
        "Farmer Carry",
        "Plank",
        "Hanging Leg Raise"
    ]
}
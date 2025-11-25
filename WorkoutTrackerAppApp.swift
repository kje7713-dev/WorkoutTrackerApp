import SwiftUI
import SwiftData

@main
struct WorkoutTrackerAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            ExerciseTemplate.self,
            BlockTemplate.self,
            DayTemplate.self,
            PlannedExercise.self,
            PrescribedSet.self,
            WorkoutSession.self,
            SessionExercise.self,
            SessionSet.self
        ])
    }
}
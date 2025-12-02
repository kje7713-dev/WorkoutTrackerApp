import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            WorkoutSessionView(session: sampleSession)
        }
    }
}

// Demo data so the UI isn’t empty
private let sampleSession = WorkoutSession(
    title: "Workout Session",
    dayTitle: "Day 1 – Bench Focus",
    description: "Primary bench variation heavy for low reps plus upper-body accessories.",
    exercises: [
        Exercise(name: "Bench Press", reps: 3, weight: 245, isCompleted: true),
        Exercise(name: "Bench Press", reps: 3, weight: 245, isCompleted: true),
        Exercise(name: "Bench Press", reps: 3, weight: 245, isCompleted: false),
        Exercise(name: "Lat Pulldown", reps: 10, weight: 140, isCompleted: false)
    ]
)
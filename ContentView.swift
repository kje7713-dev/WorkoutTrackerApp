import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        BlockListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            BlockTemplate.self,
            DayTemplate.self,
            WorkoutSession.self,
            SessionExercise.self,
            SessionSet.self,
            ExerciseTemplate.self
        ])
}
import SwiftUI

struct SessionRunView: View {
    let session: WorkoutSession

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(session.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.customName ?? "Exercise")
                            .font(.headline)
                            .bold()
                        
                        ForEach(exercise.expectedSets) { set in
                            HStack {
                                Text("Set \(set.index + 1)")
                                Spacer()
                                if let reps = set.expectedReps {
                                    Text("\(reps) reps")
                                }
                                if let weight = set.expectedWeight {
                                    Text("@ \(String(format: "%.1f", weight)) lbs")
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Workout Session")
        .navigationBarTitleDisplayMode(.inline)
    }
}
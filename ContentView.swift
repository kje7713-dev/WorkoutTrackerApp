import SwiftUI
import Charts   // iOS 16+ (you’re targeting iOS 17, so this is fine)

struct DashboardView: View {
    @State private var block = WorkoutBlock.sampleBlock
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Block + Day header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(block.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(block.currentDayName)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    // Exercise completion chart
                    MetricCard(
                        title: "% Exercises Completed in Block",
                        subtitle: "Expected vs Actual",
                        points: block.exerciseCompletionPoints
                    )
                    
                    // Volume completion chart
                    MetricCard(
                        title: "% Volume Completed in Block",
                        subtitle: "Expected vs Actual",
                        points: block.volumeCompletionPoints
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            // ✨ NEW TITLE + CENTERING
            .navigationTitle("We are what we repeatedly do")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
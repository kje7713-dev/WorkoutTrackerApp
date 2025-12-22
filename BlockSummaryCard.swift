//
//  BlockSummaryCard.swift
//  Savage By Design
//
//  Summary metrics card for training blocks
//

import SwiftUI

struct BlockSummaryCard: View {
    let metrics: BlockMetrics
    @Environment(\.sbdTheme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Progress indicator
            HStack(spacing: 8) {
                Text("PROGRESS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(metrics.completionPercentage * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(progressColor)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // Filled portion
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * metrics.completionPercentage, height: 8)
                }
            }
            .frame(height: 8)
            
            // Metrics grid
            HStack(spacing: 12) {
                // Sets completed
                MetricItem(
                    title: "Sets",
                    value: "\(metrics.completedSets)/\(metrics.plannedSets)",
                    icon: "checkmark.circle.fill"
                )
                
                Divider()
                    .frame(height: 30)
                
                // Workouts completed
                MetricItem(
                    title: "Workouts",
                    value: "\(metrics.completedWorkouts)/\(metrics.totalWorkouts)",
                    icon: "calendar.circle.fill"
                )
                
                Divider()
                    .frame(height: 30)
                
                // Volume (if available)
                if metrics.plannedVolume > 0 {
                    MetricItem(
                        title: "Volume",
                        value: formatVolume(metrics.completedVolume),
                        icon: "chart.bar.fill"
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .tertiarySystemBackground))
        )
    }
    
    private var progressColor: Color {
        let percentage = metrics.completionPercentage
        if percentage >= 0.75 {
            return .green
        } else if percentage >= 0.5 {
            return .orange
        } else if percentage > 0 {
            return .yellow
        } else {
            return .gray
        }
    }
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        } else {
            return String(format: "%.0f", volume)
        }
    }
}

struct MetricItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    BlockSummaryCard(
        metrics: BlockMetrics(
            plannedSets: 100,
            completedSets: 75,
            plannedVolume: 15000,
            completedVolume: 12000,
            totalWorkouts: 12,
            completedWorkouts: 9
        )
    )
    .padding()
}

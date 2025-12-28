//
//  WhiteboardViews.swift
//  Savage By Design
//
//  SwiftUI views for whiteboard display
//

import SwiftUI

// MARK: - Whiteboard Week View

struct WhiteboardWeekView: View {
    let unifiedBlock: UnifiedBlock
    @State private var selectedWeekIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with block name
            VStack(alignment: .leading, spacing: 8) {
                Text(unifiedBlock.title)
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .textCase(.uppercase)
                    .kerning(1.2)
                
                if unifiedBlock.numberOfWeeks > 1 {
                    // Week selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<unifiedBlock.numberOfWeeks, id: \.self) { weekIndex in
                                WeekSelectorButton(
                                    weekNumber: weekIndex + 1,
                                    isSelected: weekIndex == selectedWeekIndex,
                                    action: { selectedWeekIndex = weekIndex }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
            
            // Day cards
            if selectedWeekIndex < unifiedBlock.weeks.count {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(unifiedBlock.weeks[selectedWeekIndex].enumerated()), id: \.offset) { dayIndex, day in
                            WhiteboardDayCardView(
                                day: day,
                                dayNumber: dayIndex + 1
                            )
                        }
                    }
                    .padding()
                }
            } else {
                Text("No data for this week")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

// MARK: - Week Selector Button

struct WeekSelectorButton: View {
    let weekNumber: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Week \(weekNumber)")
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.black : Color.clear
                )
                .foregroundColor(isSelected ? Color.white : Color.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: isSelected ? 0 : 1)
                )
                .cornerRadius(16)
        }
    }
}

// MARK: - Whiteboard Day Card

struct WhiteboardDayCardView: View {
    let day: UnifiedDay
    let dayNumber: Int
    
    private var sections: [WhiteboardSection] {
        WhiteboardFormatter.formatDay(day)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Day title
            HStack {
                Text(day.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Day \(dayNumber)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                    )
            }
            
            if let goal = day.goal {
                Text("Goal: \(goal)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Sections
            ForEach(sections) { section in
                WhiteboardSectionView(section: section)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Whiteboard Section

struct WhiteboardSectionView: View {
    let section: WhiteboardSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header
            Text(section.title.uppercased())
                .font(.system(.headline, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Items
            ForEach(section.items) { item in
                WhiteboardItemView(item: item)
            }
        }
    }
}

// MARK: - Whiteboard Item

struct WhiteboardItemView: View {
    let item: WhiteboardItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Primary line (exercise name)
            Text(item.primary)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
            
            // Secondary line (prescription)
            if let secondary = item.secondary {
                Text(secondary)
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            // Tertiary line (rest)
            if let tertiary = item.tertiary {
                Text(tertiary)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            // Bullets
            if !item.bullets.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(item.bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 4) {
                            Text("•")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                            Text(bullet)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.leading, 8)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#if DEBUG
struct WhiteboardViews_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample unified block
        let sampleBlock = UnifiedBlock(
            title: "Powerlifting DUP 4W 4D",
            numberOfWeeks: 2,
            weeks: [
                [
                    UnifiedDay(
                        name: "Heavy Squat",
                        goal: "strength",
                        exercises: [
                            UnifiedExercise(
                                name: "Back Squat",
                                type: "strength",
                                category: "squat",
                                notes: "@ RPE 8",
                                strengthSets: [
                                    UnifiedStrengthSet(reps: 5, restSeconds: 180),
                                    UnifiedStrengthSet(reps: 5, restSeconds: 180),
                                    UnifiedStrengthSet(reps: 5, restSeconds: 180),
                                    UnifiedStrengthSet(reps: 5, restSeconds: 180),
                                    UnifiedStrengthSet(reps: 5, restSeconds: 180)
                                ]
                            ),
                            UnifiedExercise(
                                name: "Romanian Deadlift",
                                type: "strength",
                                category: "hinge",
                                strengthSets: [
                                    UnifiedStrengthSet(reps: 8, restSeconds: 90),
                                    UnifiedStrengthSet(reps: 8, restSeconds: 90),
                                    UnifiedStrengthSet(reps: 8, restSeconds: 90)
                                ]
                            )
                        ]
                    ),
                    UnifiedDay(
                        name: "Conditioning",
                        goal: "conditioning",
                        exercises: [
                            UnifiedExercise(
                                name: "Metcon",
                                type: "conditioning",
                                notes: "10 Burpees, 15 KB Swings, 20 Box Jumps",
                                conditioningType: "amrap",
                                conditioningSets: [
                                    UnifiedConditioningSet(
                                        durationSeconds: 1200,
                                        rounds: nil
                                    )
                                ]
                            )
                        ]
                    )
                ],
                [
                    UnifiedDay(
                        name: "Volume Squat",
                        goal: "hypertrophy",
                        exercises: [
                            UnifiedExercise(
                                name: "Front Squat",
                                type: "strength",
                                category: "squat",
                                strengthSets: [
                                    UnifiedStrengthSet(reps: 8, restSeconds: 120),
                                    UnifiedStrengthSet(reps: 8, restSeconds: 120),
                                    UnifiedStrengthSet(reps: 8, restSeconds: 120),
                                    UnifiedStrengthSet(reps: 8, restSeconds: 120)
                                ]
                            )
                        ]
                    )
                ]
            ]
        )
        
        WhiteboardWeekView(unifiedBlock: sampleBlock)
            .previewDisplayName("Whiteboard Week View")
    }
}
#endif

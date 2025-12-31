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

// MARK: - Full-Screen Whiteboard Day View

struct WhiteboardFullScreenDayView: View {
    let unifiedBlock: UnifiedBlock
    let weekIndex: Int
    let dayIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    private var day: UnifiedDay? {
        guard weekIndex < unifiedBlock.weeks.count,
              dayIndex < unifiedBlock.weeks[weekIndex].count else {
            return nil
        }
        return unifiedBlock.weeks[weekIndex][dayIndex]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if let day = day {
                    ScrollView {
                        VStack(spacing: 16) {
                            WhiteboardDayCardView(
                                day: day,
                                dayNumber: dayIndex + 1
                            )
                        }
                        .padding()
                    }
                } else {
                    Text("No data for this day")
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(unifiedBlock.title)
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Week \(weekIndex + 1) • Day \(dayIndex + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    .accessibilityLabel("Close whiteboard")
                }
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
            // Section header with visual emphasis
            HStack {
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 4, height: 20)
                
                Text(section.title.uppercased())
                    .font(.system(.headline, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.bottom, 4)
            
            // Items with dividers
            ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                VStack(alignment: .leading, spacing: 0) {
                    WhiteboardItemView(item: item)
                    
                    // Add divider between items (but not after the last one)
                    if index < section.items.count - 1 {
                        Divider()
                            .padding(.leading, 16)
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(.bottom, 12)
    }
}

// MARK: - Whiteboard Item

struct WhiteboardItemView: View {
    let item: WhiteboardItem
    @State private var isExpanded: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Primary line (exercise/segment name)
            HStack {
                Text(item.primary)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                
                // Add expand/collapse for segments with lots of details
                if !item.bullets.isEmpty && item.bullets.count > 5 {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
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
            
            // Bullets with improved formatting
            if !item.bullets.isEmpty && isExpanded {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(item.bullets, id: \.self) { bullet in
                        BulletItemView(text: bullet)
                    }
                }
                .padding(.leading, 4)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Bullet Item with Smart Formatting

struct BulletItemView: View {
    let text: String
    
    // Determine the indentation level and styling based on content
    private var bulletStyle: BulletStyle {
        if text.hasPrefix("    ") {
            return .subSubItem
        } else if text.hasPrefix("  ") {
            return .subItem
        } else if text.contains(":") && !text.hasPrefix("  ") {
            // Section headers (e.g., "Quality Targets:", "Safety:")
            return .sectionHeader
        } else {
            return .item
        }
    }
    
    private var displayText: String {
        return text.trimmingCharacters(in: .whitespaces)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            // Spacing for indentation
            if bulletStyle == .subItem {
                Spacer().frame(width: 12)
            } else if bulletStyle == .subSubItem {
                Spacer().frame(width: 24)
            }
            
            // Bullet or indicator
            if bulletStyle != .sectionHeader {
                Text(bulletStyle.bullet)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(bulletStyle.color)
            }
            
            // Text content
            Text(displayText)
                .font(bulletStyle.font)
                .foregroundColor(bulletStyle.color)
                .fontWeight(bulletStyle == .sectionHeader ? .semibold : .regular)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

// MARK: - Bullet Style

enum BulletStyle {
    case sectionHeader
    case item
    case subItem
    case subSubItem
    
    var bullet: String {
        switch self {
        case .sectionHeader:
            return ""
        case .item:
            return "•"
        case .subItem:
            return "◦"
        case .subSubItem:
            return "▪︎"
        }
    }
    
    var font: Font {
        switch self {
        case .sectionHeader:
            return .system(.caption, design: .monospaced)
        case .item:
            return .system(.caption, design: .monospaced)
        case .subItem, .subSubItem:
            return .system(.caption2, design: .monospaced)
        }
    }
    
    var color: Color {
        switch self {
        case .sectionHeader:
            return .primary
        case .item:
            return .secondary
        case .subItem, .subSubItem:
            return Color.secondary.opacity(0.8)
        }
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

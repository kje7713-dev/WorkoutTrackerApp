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

// MARK: - Full-Screen Whiteboard Day View (Mobile-First)

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
                    MobileWhiteboardDayView(
                        day: day,
                        dayNumber: dayIndex + 1,
                        blockTitle: unifiedBlock.title,
                        weekNumber: weekIndex + 1
                    )
                } else {
                    Text("No data for this day")
                        .foregroundColor(.secondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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

// MARK: - Mobile Whiteboard Day View

struct MobileWhiteboardDayView: View {
    let day: UnifiedDay
    let dayNumber: Int
    let blockTitle: String
    let weekNumber: Int
    
    @State private var expandedSegmentId: UUID? = nil
    @State private var selectedSegmentId: UUID? = nil
    @Namespace private var animation
    
    // Cache formatted sections for exercises
    private var formattedSections: [WhiteboardSection] {
        WhiteboardFormatter.formatDay(day)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1) STICKY HEADER
            stickyHeader
                .background(Color(.systemBackground))
            
            Divider()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // 2) CLASS FLOW STRIP
                        if !day.segments.isEmpty {
                            classFlowStrip
                                .padding(.vertical, 12)
                                .background(Color(.systemBackground))
                        }
                        
                        // 3) SEGMENT CARD STACK (for segment-based days)
                        if !day.segments.isEmpty {
                            segmentCardStack
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                        }
                        
                        // 4) EXERCISE SECTIONS (for traditional exercise-based days)
                        if !day.exercises.isEmpty {
                            exerciseSections
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                        }
                    }
                }
                .onChange(of: selectedSegmentId) { _, newId in
                    if let newId = newId {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(newId, anchor: .top)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 1) Sticky Header
    
    private var stickyHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Line 1: Day Name (bold)
            Text(day.name)
                .font(.title2)
                .fontWeight(.bold)
            
            // Line 2: Chips [Goal] [Duration] [Difficulty]
            // Only show chips for non-segment days (exercise-based days)
            if day.segments.isEmpty {
                HStack(spacing: 8) {
                    if let goal = day.goal {
                        ChipView(text: goal.uppercased(), color: .blue)
                    }
                    
                    // Difficulty could be derived from segment types or added to model
                    // For now, we'll skip it if not available
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - 2) Class Flow Strip
    
    private var classFlowStrip: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(day.segments.enumerated()), id: \.element.id) { index, segment in
                        SegmentPillCard(
                            segment: segment,
                            index: index + 1,
                            isSelected: selectedSegmentId == segment.id
                        )
                        .onTapGesture {
                            selectedSegmentId = segment.id
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Progress indicator
            if !day.segments.isEmpty {
                Text("\(selectedSegmentIndex + 1) / \(day.segments.count) segments")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var selectedSegmentIndex: Int {
        if let id = selectedSegmentId,
           let index = day.segments.firstIndex(where: { $0.id == id }) {
            return index
        }
        return 0
    }
    
    // MARK: - 3) Segment Card Stack
    
    private var segmentCardStack: some View {
        LazyVStack(spacing: 12) {
            ForEach(day.segments) { segment in
                SegmentCard(
                    segment: segment,
                    isExpanded: expandedSegmentId == segment.id,
                    onToggle: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if expandedSegmentId == segment.id {
                                expandedSegmentId = nil
                            } else {
                                expandedSegmentId = segment.id
                            }
                        }
                    }
                )
                .id(segment.id)
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - 4) Exercise Sections
    
    private var exerciseSections: some View {
        LazyVStack(spacing: 20) {
            ForEach(formattedSections) { section in
                VStack(alignment: .leading, spacing: 12) {
                    // Section header
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
                    
                    // Section items
                    ForEach(section.items) { item in
                        VStack(alignment: .leading, spacing: 6) {
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
                            
                            // Bullets with improved formatting
                            if !item.bullets.isEmpty {
                                VStack(alignment: .leading, spacing: 3) {
                                    ForEach(item.bullets, id: \.self) { bullet in
                                        BulletItemView(text: bullet)
                                    }
                                }
                                .padding(.leading, 4)
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                }
            }
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Chip View

struct ChipView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            )
    }
}

// MARK: - Tag Chip View

struct TagChipView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Segment Pill Card

struct SegmentPillCard: View {
    let segment: UnifiedSegment
    let index: Int
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                // Icon
                Text(segmentTypeIcon)
                    .font(.body)
                
                // Short name
                Text(segment.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            
            // Duration badge
            if let duration = segment.durationMinutes {
                Text("\(duration)m")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(segmentTypeColor)
                .shadow(color: isSelected ? segmentTypeColor.opacity(0.4) : .clear, radius: 8, x: 0, y: 2)
        )
        .foregroundColor(.white)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var segmentTypeIcon: String {
        switch segment.segmentType.lowercased() {
        case "warmup": return "🔄"
        case "mobility": return "🧘"
        case "technique": return "🧠"
        case "drill": return "🔁"
        case "positionalspar": return "⚔️"
        case "rolling": return "🥋"
        case "cooldown": return "🌬️"
        case "lecture": return "🎓"
        case "breathwork": return "🌬️"
        case "flow": return "🧘"
        default: return "📌"
        }
    }
    
    private var segmentTypeColor: Color {
        switch segment.segmentType.lowercased() {
        case "warmup", "mobility": return Color.orange
        case "technique": return Color.blue
        case "drill", "practice": return Color.purple
        case "positionalspar", "rolling": return Color.red
        case "cooldown", "breathwork", "flow": return Color.green
        case "lecture", "presentation": return Color.gray
        case "review", "assessment": return Color.cyan
        case "demonstration": return Color.indigo
        case "discussion": return Color.teal
        default: return Color.secondary
        }
    }
}

// MARK: - Segment Card

struct SegmentCard: View {
    let segment: UnifiedSegment
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header (always visible) - now a button
            Button(action: onToggle) {
                cardHeader
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if isExpanded {
                Divider()
                    .padding(.vertical, 8)
                
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Card Header (Collapsed View)
    
    private var cardHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left: icon + color stripe
            VStack(spacing: 4) {
                Text(segmentTypeIcon)
                    .font(.title2)
                
                Rectangle()
                    .fill(segmentTypeColor)
                    .frame(width: 4, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(segment.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                // Subtitle: type + duration
                HStack(spacing: 8) {
                    Text(segment.segmentType.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(segmentTypeColor)
                    
                    if let duration = segment.durationMinutes {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("\(duration) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Expand indicator
            Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                .font(.title3)
                .foregroundColor(.accentColor)
        }
    }
    
    // MARK: - Expanded Content
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // A) Objective (full)
            if let objective = segment.objective {
                SectionView(title: "Objective") {
                    Text(objective)
                        .font(.subheadline)
                }
            }
            
            // B) Start / Positions
            if !segment.positions.isEmpty {
                SectionView(title: "Positions") {
                    FlowLayout(items: segment.positions) { position in
                        TagChipView(text: position)
                    }
                }
            }
            
            // C) Techniques
            if !segment.techniques.isEmpty {
                SectionView(title: "Techniques") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(segment.techniques, id: \.name) { technique in
                            TechniqueRow(technique: technique)
                        }
                    }
                }
            }
            
            // D) Drill Plan
            if !segment.drillItems.isEmpty {
                SectionView(title: "Drill Plan") {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(segment.drillItems, id: \.name) { item in
                            HStack {
                                Text(item.name)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(item.workSeconds)s work / \(item.restSeconds)s rest")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            
            // E) Partner Plan
            if let rounds = segment.rounds,
               let roundDuration = segment.roundDurationSeconds,
               (segment.attackerGoal != nil || segment.defenderGoal != nil) {
                SectionView(title: "Partner Plan") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(rounds) × \(formatTime(roundDuration)) rounds")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if let rest = segment.restSeconds {
                            Text("Rest: \(formatTime(rest))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let attackerGoal = segment.attackerGoal {
                            BulletPoint(text: "Attacker: \(attackerGoal)")
                        }
                        
                        if let defenderGoal = segment.defenderGoal {
                            BulletPoint(text: "Defender: \(defenderGoal)")
                        }
                        
                        if let resistance = segment.resistance {
                            HStack {
                                Text("Resistance:")
                                    .font(.caption)
                                ProgressView(value: Double(resistance), total: 100)
                                    .tint(resistanceColor(resistance))
                                Text("\(resistance)%")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    )
                }
            }
            
            // F) Round Plan (Live Rounds)
            if let rounds = segment.rounds,
               let roundDuration = segment.roundDurationSeconds,
               segment.attackerGoal == nil && segment.defenderGoal == nil {
                SectionView(title: "Live Rounds") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(rounds) × \(formatTime(roundDuration))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if let rest = segment.restSeconds {
                            Text("Rest: \(formatTime(rest))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let intensity = segment.intensityCue {
                            BulletPoint(text: "Intensity: \(intensity)")
                        }
                        
                        if let resetRule = segment.resetRule {
                            BulletPoint(text: "Reset: \(resetRule)")
                        }
                        
                        if !segment.winConditions.isEmpty {
                            Text("Win Conditions:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            ForEach(segment.winConditions, id: \.self) { condition in
                                BulletPoint(text: condition, indent: true)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red.opacity(0.3), lineWidth: 2)
                    )
                }
            }
            
            // G) Constraints
            if !segment.constraints.isEmpty {
                SectionView(title: "Constraints") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(segment.constraints, id: \.self) { constraint in
                            HStack(alignment: .top, spacing: 6) {
                                Text("⚠️")
                                    .font(.caption)
                                Text(constraint)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
            }
            
            // H) Scoring
            if !segment.scoring.isEmpty {
                SectionView(title: "Scoring") {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(segment.scoring.prefix(segment.scoring.count / 2 + segment.scoring.count % 2), id: \.self) { score in
                                BulletPoint(text: score)
                            }
                        }
                        
                        if segment.scoring.count > 1 {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(segment.scoring.dropFirst((segment.scoring.count / 2 + segment.scoring.count % 2)), id: \.self) { score in
                                    BulletPoint(text: score)
                                }
                            }
                        }
                    }
                }
            }
            
            // I) Flow / Mobility
            if !segment.flowSequence.isEmpty {
                SectionView(title: "Flow Sequence") {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(segment.flowSequence, id: \.poseName) { step in
                            HStack {
                                Text(step.poseName)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(step.holdSeconds)s")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                            
                            if let transition = step.transitionCue {
                                Text("→ \(transition)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .italic()
                                    .padding(.leading, 12)
                            }
                        }
                    }
                }
            }
            
            // J) Breathwork
            if let style = segment.breathworkStyle {
                SectionView(title: "Breathwork") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(style)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if let pattern = segment.breathworkPattern {
                            Text(pattern)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let duration = segment.breathworkDurationSeconds {
                            Text("\(formatTime(duration))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                    )
                }
            }
            
            // K) Coaching Cues
            if !segment.coachingCues.isEmpty {
                SectionView(title: "Coaching Cues") {
                    FlowLayout(items: segment.coachingCues) { cue in
                        Text(cue)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                }
            }
            
            // L) Safety
            if !segment.contraindications.isEmpty || !segment.stopIf.isEmpty {
                SectionView(title: "Safety") {
                    VStack(alignment: .leading, spacing: 6) {
                        if !segment.contraindications.isEmpty {
                            Text("Contraindications:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            ForEach(segment.contraindications, id: \.self) { item in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("⛔")
                                        .font(.caption)
                                    Text(item)
                                        .font(.caption)
                                }
                            }
                        }
                        
                        if !segment.stopIf.isEmpty {
                            Text("Stop if:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            ForEach(segment.stopIf, id: \.self) { item in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("🛑")
                                        .font(.caption)
                                    Text(item)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                    )
                }
            }
            
            // M) Notes (last)
            if let notes = segment.notes, !notes.isEmpty {
                SectionView(title: "Notes") {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var segmentTypeIcon: String {
        switch segment.segmentType.lowercased() {
        case "warmup": return "🔄"
        case "mobility": return "🧘"
        case "technique": return "🧠"
        case "drill": return "🔁"
        case "positionalspar": return "⚔️"
        case "rolling": return "🥋"
        case "cooldown": return "🌬️"
        case "lecture": return "🎓"
        case "breathwork": return "🌬️"
        case "flow": return "🧘"
        default: return "📌"
        }
    }
    
    private var segmentTypeColor: Color {
        switch segment.segmentType.lowercased() {
        case "warmup", "mobility": return Color.orange
        case "technique": return Color.blue
        case "drill", "practice": return Color.purple
        case "positionalspar", "rolling": return Color.red
        case "cooldown", "breathwork", "flow": return Color.green
        case "lecture", "presentation": return Color.gray
        case "review", "assessment": return Color.cyan
        case "demonstration": return Color.indigo
        case "discussion": return Color.teal
        default: return Color.secondary
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, secs)
        } else {
            return "\(secs)s"
        }
    }
    
    private func resistanceColor(_ resistance: Int) -> Color {
        switch resistance {
        case 0...25: return .green
        case 26...50: return .yellow
        case 51...75: return .orange
        default: return .red
        }
    }
}

// MARK: - Supporting Views

struct MicroBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 10))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(0.1))
        )
        .foregroundColor(.primary)
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .textCase(.uppercase)
                .foregroundColor(.primary)
            
            content
        }
    }
}

struct BulletPoint: View {
    let text: String
    var indent: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            if indent {
                Spacer().frame(width: 12)
            }
            Text("•")
                .font(.caption)
            Text(text)
                .font(.caption)
        }
    }
}

struct TechniqueRow: View {
    let technique: UnifiedTechnique
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(technique.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if let variant = technique.variant {
                            Text(variant)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    if !technique.keyDetails.isEmpty {
                        Text("Key Details:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        ForEach(technique.keyDetails, id: \.self) { detail in
                            BulletPoint(text: detail, indent: true)
                        }
                    }
                    
                    if !technique.commonErrors.isEmpty {
                        Text("Common Errors:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        ForEach(technique.commonErrors, id: \.self) { error in
                            BulletPoint(text: error, indent: true)
                        }
                    }
                    
                    if !technique.followUps.isEmpty {
                        Text("Follow-ups:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        ForEach(technique.followUps, id: \.self) { followUp in
                            BulletPoint(text: followUp, indent: true)
                        }
                    }
                    
                    if !technique.counters.isEmpty {
                        Text("Counters:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        ForEach(technique.counters, id: \.self) { counter in
                            BulletPoint(text: counter, indent: true)
                        }
                    }
                    
                    if let videoUrls = technique.videoUrls, !videoUrls.isEmpty {
                        Text("Videos")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(videoUrls, id: \.self) { urlString in
                                if let url = URL(string: urlString) {
                                    Link(destination: url) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "play.rectangle.fill")
                                                .foregroundColor(.red)
                                                .font(.caption)
                                            Text("Technique demo")
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                            Image(systemName: "arrow.up.forward.square")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(.systemBackground).opacity(0.5))
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 12)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

struct FlowLayout<Item: Hashable, ItemView: View>: View {
    let items: [Item]
    let itemView: (Item) -> ItemView
    
    @State private var totalHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                itemView(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == items.last {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if item == items.last {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
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

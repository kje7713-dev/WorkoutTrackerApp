# Mobile-First Whiteboard Implementation Guide

## Overview

This document describes the new mobile-first whiteboard view implementation that addresses the requirement for a clean, progressive disclosure UI for segment-based workouts.

## Design Principles

1. **Show the whole class at a glance first, then details** - Flow strip provides overview
2. **Progressive disclosure** - Cards collapsed by default, expand on tap
3. **Consistent visual language** - Color + icon by segmentType
4. **Thumb-friendly** - Big tap targets (44pt+), minimal scrolling friction

## Architecture

### View Hierarchy

```
WhiteboardFullScreenDayView (entry point)
└── MobileWhiteboardDayView
    ├── Sticky Header
    │   ├── Day Name
    │   ├── Chips (Goal, Duration, Difficulty)
    │   └── Tags (Positions)
    ├── Class Flow Strip
    │   ├── Segment Pills (horizontal scroll)
    │   └── Progress Indicator
    └── Segment Card Stack
        └── SegmentCard (collapsible)
            ├── Card Header (always visible)
            └── Expanded Content (sections)
```

### Key Components

#### 1. Sticky Header
```swift
VStack(alignment: .leading, spacing: 8) {
    // Line 1: Day Name (bold)
    Text(day.name)
        .font(.title2)
        .fontWeight(.bold)
    
    // Line 2: Chips [Goal] [Duration] [Positions]
    // NOTE: Chips are only shown for exercise-based days (when segments are empty)
    // For segment-based days, this information is shown in the segment cards
    if day.segments.isEmpty {
        HStack(spacing: 8) {
            if let goal = day.goal {
                ChipView(text: goal.uppercased(), color: .blue)
            }
        }
    }
}
```

**Rationale:** Chips are hidden for segment-based days to avoid redundancy. Duration is already shown in segment pill cards, and positions are displayed in expanded segment details.

#### 2. Class Flow Strip
A horizontally scrollable timeline showing all segments at a glance.

**Features:**
- Each segment rendered as a "pill card"
- Icon + short name + duration badge
- Color-coded by segment type
- Tap to jump to segment details
- Visual indicator for selected segment
- Progress counter (e.g., "3/6 segments")

**Segment Type Colors:**
- 🟠 Warmup/Mobility → Orange
- 🔵 Technique → Blue
- 🟣 Drill → Purple
- 🔴 Positional Spar/Rolling → Red
- 🟢 Cooldown/Breathwork/Flow → Green
- ⚫ Lecture → Gray
- ⚪ Other → Secondary

**Segment Type Icons:**
- 🔄 warmup
- 🧘 mobility
- 🧠 technique
- 🔁 drill
- ⚔️ positionalSpar
- 🥋 rolling
- 🌬️ cooldown
- 🎓 lecture
- 🌬️ breathwork
- 🧘 flow
- 📌 other

#### 3. Segment Card

**Collapsed State (Default):**
```
┌──────────────────────────────────────┐
│ 🧠 │ Single Leg Entry Technique      │
│ ║  │ TECHNIQUE • 15 min              │
└──────────────────────────────────────┘
```
- Shows only: icon, title, type label, and duration
- Tap to expand for full details

**Expanded State:**
Shows detailed sections in this order (only if data exists):

A. **Objective** - Full learning objective text
B. **Positions** - Chips for start positions
C. **Techniques** - Accordion list with expandable details
   - Technique name + variant
   - Key details, common errors, follow-ups, counters
D. **Drill Plan** - Work/rest list
   - Each row: name | work seconds | rest seconds
E. **Partner Plan** - Boxed "Round Recipe"
   - Rounds × duration, rest
   - Attacker/defender goals
   - Resistance progress bar (0-100%)
   - Switch timing
   - Quality targets
F. **Round Plan** - Boxed "Live Rounds"
   - Rounds × duration, rest
   - Intensity cue
   - Reset rule
   - Win conditions
G. **Constraints** - Highlighted callout with ⚠️
H. **Scoring** - Two-column board
   - Attacker scores if...
   - Defender scores if...
I. **Flow/Mobility** - Pose list
   - Pose name + hold seconds
   - Transition cues
J. **Breathwork** - Small box
   - Style, pattern, duration
K. **Coaching Cues** - Chips
L. **Safety** - Warning list
   - ⛔ Contraindications
   - 🛑 Stop if...
M. **Notes** - Last section

## Usage

### From BlockRunMode

The whiteboard view is accessed via the "Whiteboard" button in the toolbar:

```swift
.fullScreenCover(isPresented: $showWhiteboard) {
    WhiteboardFullScreenDayView(
        unifiedBlock: BlockNormalizer.normalize(block: block),
        weekIndex: currentWeekIndex,
        dayIndex: currentDayIndex
    )
}
```

### Data Requirements

The view expects a `UnifiedBlock` with `UnifiedDay` containing `UnifiedSegment` items:

```swift
let unifiedBlock = UnifiedBlock(
    title: "BJJ Fundamentals Week 1",
    numberOfWeeks: 4,
    weeks: [
        [
            UnifiedDay(
                name: "Technique Day",
                goal: "technical",
                exercises: [],
                segments: [
                    UnifiedSegment(
                        id: UUID(),
                        name: "Single Leg Takedown",
                        segmentType: "technique",
                        durationMinutes: 15,
                        objective: "Build clean single-leg entry...",
                        techniques: [...],
                        rounds: 6,
                        roundDurationSeconds: 150,
                        ...
                    )
                ]
            )
        ]
    ]
)
```

## Interaction Model

### Tap Behaviors

1. **Tap Segment Pill** → Smooth scroll to that segment's detail card
2. **Tap Card Header** → Toggle expand/collapse with animation
3. **Tap Technique Row** → Expand to show details (key points, errors, counters)

### Animations

- Card expand/collapse: `.easeInOut(duration: 0.3)`
- Pill selection scale: `.easeInOut(duration: 0.2)`
- Scroll to segment: `.easeInOut(duration: 0.3)`
- Technique accordion: `.easeInOut(duration: 0.2)`

### State Management

```swift
@State private var expandedSegmentId: UUID? = nil
@State private var selectedSegmentId: UUID? = nil
```

- Only one segment card expanded at a time
- Selected pill highlights and scales up
- Scroll position tracks selected segment

## Visual Design

### Typography Hierarchy

1. **Day Name** - `.title2` + `.bold`
2. **Section Headers** - `.subheadline` + `.bold` + `.uppercase`
3. **Body Text** - `.subheadline`
4. **Meta/Caption** - `.caption` / `.caption2`

### Spacing

- Card padding: 16pt
- Section spacing: 16pt
- Horizontal margins: 16pt
- Flow strip vertical padding: 12pt
- Pill spacing: 12pt

### Touch Targets

- Minimum: 44pt × 44pt
- Segment pills: Auto-sized with adequate padding
- Card headers: Full width, minimum 60pt height
- Chevron buttons: 44pt × 44pt

## Supporting Views

### ChipView
Colored rounded rectangle for metadata (goal, duration)

### TagChipView
Outlined chip for tags (positions, constraints)

### MicroBadge
Small icon + text badge for payload indicators

### SectionView
Consistent section header + content container

### BulletPoint
Bullet list item with optional indent

### TechniqueRow
Expandable technique with accordion behavior

### FlowLayout
Auto-wrapping layout for chips/tags

## Testing Checklist

- [ ] Segments display in correct order
- [ ] Colors match segment types
- [ ] Icons display correctly
- [ ] Tap on pill scrolls to card
- [ ] Tap on card toggles expand/collapse
- [ ] Only one card expanded at a time
- [ ] Technique accordions work
- [ ] Empty sections are hidden
- [ ] All field types render correctly
- [ ] Animations are smooth
- [ ] Works on various screen sizes
- [ ] Scroll performance is good with many segments
- [ ] Tags wrap properly in header
- [ ] Safety warnings display correctly

## Future Enhancements

### Possible Additions

1. **Quick Nav Menu**
   - "Jump to..." dropdown
   - "Collapse all" button
   - "Expand current only" toggle

2. **Long-Press Preview**
   - Show objective + rounds in popover
   - Quick peek without full navigation

3. **Swipe Gestures**
   - Swipe card left/right to navigate
   - Swipe to mark complete

4. **Persistence**
   - Remember expanded state
   - Last viewed segment

5. **Search/Filter**
   - Filter by segment type
   - Search within segments

## Notes

- The implementation preserves backward compatibility
- Old `WhiteboardDayCardView` is kept but not used in new flow
- `UnifiedSegment` required addition of `id: UUID` field
- All data comes from existing `Segment` model via `BlockNormalizer`
- No changes to persistence layer needed
- Works with existing subscription/paywall integration

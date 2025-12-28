# Whiteboard Full-Screen Feature - Visual Guide

## Feature Overview

This document provides a visual description of the new full-screen whiteboard feature, including before/after comparisons and UI layout specifications.

## Before This PR

### Previous Behavior (Inline Toggle)
```
┌─────────────────────────────────────────────┐
│ [Close Session]        BLOCK NAME [Whiteboard] │
├─────────────────────────────────────────────┤
│                                             │
│  IF showWhiteboard == false:                │
│    ┌─────────────────────────────────────┐ │
│    │  Week Tabs                          │ │
│    │  ─────────────────────────────────  │ │
│    │  Day Tabs                           │ │
│    │  ─────────────────────────────────  │ │
│    │  Exercise Cards (detailed tracking) │ │
│    │  • Set controls                     │ │
│    │  • Complete buttons                 │ │
│    │  • Progress indicators              │ │
│    └─────────────────────────────────────┘ │
│                                             │
│  IF showWhiteboard == true:                 │
│    ┌─────────────────────────────────────┐ │
│    │  BLOCK NAME                         │ │
│    │  Week Selector (horizontal scroll)  │ │
│    │  ─────────────────────────────────  │ │
│    │  Day 1 Card                         │ │
│    │  Day 2 Card                         │ │
│    │  Day 3 Card                         │ │
│    │  (All days in selected week shown)  │ │
│    └─────────────────────────────────────┘ │
│                                             │
└─────────────────────────────────────────────┘
```

**Issues with Previous Approach**:
- User had to mentally filter which day they're on
- All days shown, creating visual clutter
- Toggle button changed state, less intuitive
- No clear "close" action, just toggle back

## After This PR

### New Behavior (Full-Screen Modal)

#### Step 1: Tracking View
```
┌─────────────────────────────────────────────┐
│ [Close Session]        BLOCK NAME [Whiteboard] │
├─────────────────────────────────────────────┤
│                                             │
│  Week Tabs  [Week 1] [Week 2]               │
│  ─────────────────────────────────────      │
│  Day Tabs   [Day1] [Day2] [Day3]            │  ← User on Day 2
│  ─────────────────────────────────────      │
│                                             │
│  Exercise Cards (Day 2 exercises)           │
│  ┌─────────────────────────────────────┐   │
│  │ Back Squat                     ✓    │   │
│  │ Set 1: 5 reps @ 225 lbs        ✓    │   │
│  │ Set 2: 5 reps @ 225 lbs        ✓    │   │
│  └─────────────────────────────────────┘   │
│                                             │
│                User taps [Whiteboard] ───────→
│                                             │
└─────────────────────────────────────────────┘
```

#### Step 2: Full-Screen Whiteboard (Day 2 Only)
```
╔═══════════════════════════════════════════════╗
║                   BLOCK NAME                  ║ ← Navigation Bar
║               Week 1 • Day 2            [X]   ║ ← X to dismiss
╠═══════════════════════════════════════════════╣
║                                               ║
║  ┌─────────────────────────────────────────┐ ║
║  │  Back Squat Day             Day 2       │ ║
║  │  Goal: Strength                         │ ║
║  │  ─────────────────────────────────────  │ ║
║  │                                         │ ║
║  │  STRENGTH                               │ ║
║  │  Back Squat                             │ ║
║  │  5 × 5 @ RPE 8                          │ ║
║  │  Rest: 3:00                             │ ║
║  │                                         │ ║
║  │  ACCESSORY                              │ ║
║  │  Romanian Deadlift                      │ ║
║  │  3 × 8                                  │ ║
║  │  Rest: 1:30                             │ ║
║  │                                         │ ║
║  └─────────────────────────────────────────┘ ║
║                                               ║
║                User taps [X] ─────────────────→
║                                               ║
╚═══════════════════════════════════════════════╝
```

#### Step 3: Return to Tracking View
```
┌─────────────────────────────────────────────┐
│ [Close Session]        BLOCK NAME [Whiteboard] │
├─────────────────────────────────────────────┤
│                                             │
│  Week Tabs  [Week 1] [Week 2]               │
│  ─────────────────────────────────────────  │
│  Day Tabs   [Day1] [Day2] [Day3]            │  ← Still on Day 2
│  ─────────────────────────────────────────  │
│                                             │
│  Exercise Cards (Day 2 exercises)           │
│  ┌─────────────────────────────────────┐   │
│  │ Back Squat                     ✓    │   │
│  │ Set 1: 5 reps @ 225 lbs        ✓    │   │
│  │ Set 2: 5 reps @ 225 lbs        ✓    │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  (All progress preserved)                   │
│                                             │
└─────────────────────────────────────────────┘
```

**Benefits of New Approach**:
✅ Shows only current day - less cognitive load
✅ Full-screen focus on workout details
✅ Clear X button to close - more intuitive
✅ Modal presentation - standard iOS pattern
✅ No state loss on dismiss

## AMRAP Notes Parsing Example

### Input (Exercise Notes)
```swift
ExerciseTemplate(
    customName: "21-15-9 Metcon",
    type: .conditioning,
    conditioningType: .amrap,
    notes: "10 Burpees, 15 KB Swings (53/35), 20 Box Jumps (24/20)",
    conditioningSets: [
        ConditioningSetTemplate(
            durationSeconds: 1200  // 20 minutes
        )
    ]
)
```

### Output (Whiteboard Display)
```
CONDITIONING

21-15-9 Metcon
20 min AMRAP
• 10 Burpees
• 15 KB Swings (53/35)
• 20 Box Jumps (24/20)
```

### Parsing Logic
The enhanced `parseNotesIntoBullets()` function:
1. Splits notes by comma, newline, or semicolon
2. Trims whitespace from each component
3. Checks if component looks like a movement:
   - Starts with a number (regex: `^\d+`)
   - Contains exercise keywords (burpee, swing, jump, squat, etc.)
4. Adds each movement as a bullet point

## UI Component Hierarchy

```
WhiteboardFullScreenDayView
├── NavigationView
│   ├── ZStack
│   │   ├── Color(.systemBackground)
│   │   └── ScrollView
│   │       └── VStack
│   │           └── WhiteboardDayCardView
│   │               ├── Day Title + Number
│   │               ├── Goal (optional)
│   │               └── ForEach(sections)
│   │                   └── WhiteboardSectionView
│   │                       ├── Section Title
│   │                       └── ForEach(items)
│   │                           └── WhiteboardItemView
│   │                               ├── Primary (exercise name)
│   │                               ├── Secondary (prescription)
│   │                               ├── Tertiary (rest time)
│   │                               └── Bullets (notes)
│   └── .toolbar
│       ├── .principal
│       │   └── VStack
│       │       ├── Block Name
│       │       └── "Week X • Day Y"
│       └── .navigationBarTrailing
│           └── X Button (dismiss)
└── @Environment(\.dismiss)
```

## Typography & Styling

### Font Choices
- **Block Title**: `.headline` + `.bold`
- **Week/Day Info**: `.caption` + `.secondary`
- **Exercise Names**: `.body` + `.monospaced` + `.semibold`
- **Prescriptions**: `.subheadline` + `.monospaced` + `.secondary`
- **Rest Times**: `.caption` + `.monospaced` + `.secondary`
- **Bullets**: `.caption` + `.monospaced` + `.secondary`

### Color Scheme
- **Background**: `.systemBackground`
- **Primary Text**: `.primary`
- **Secondary Text**: `.secondary`
- **Section Headers**: `.primary` (uppercase, bold)

### Spacing
- Section Spacing: 16pt
- Item Spacing: 8pt
- Line Spacing: 4pt
- Card Padding: 12pt

## Layout Specifications

### Navigation Bar
```
┌─────────────────────────────────────────────┐
│ ┌─────────────────────────────────────────┐ │
│ │         POWERLIFTING DUP BLOCK          │ │ ← .headline, bold
│ │            Week 1 • Day 1              [X]│ │ ← .caption, secondary
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
     ↑                                    ↑
   .principal                 .navigationBarTrailing
```

### Day Card Layout
```
┌───────────────────────────────────────────┐
│  Heavy Squat Day                 Day 1    │ ← Day title + number
│  Goal: strength                           │ ← Goal (optional)
│  ─────────────────────────────────────────│
│                                           │
│  STRENGTH                                 │ ← Section header
│  Back Squat                               │ ← Primary
│  5 × 5 @ RPE 8                            │ ← Secondary
│  Rest: 3:00                               │ ← Tertiary
│                                           │
│  ACCESSORY                                │
│  Romanian Deadlift                        │
│  3 × 8                                    │
│  Rest: 1:30                               │
│                                           │
│  CONDITIONING                             │
│  Metcon                                   │
│  20 min AMRAP                             │
│  • 10 Burpees                             │ ← Bullets
│  • 15 KB Swings                           │
│  • 20 Box Jumps                           │
│                                           │
└───────────────────────────────────────────┘
```

## Interaction Flow

```
┌──────────────┐
│ User opens   │
│ workout      │
│ session      │
└──────┬───────┘
       │
       ▼
┌──────────────┐       ┌─────────────────┐
│ BlockRunMode │       │ User navigates  │
│ Tracking     │◄──────│ between days    │
│ View         │       │ and weeks       │
└──────┬───────┘       └─────────────────┘
       │
       │ Tap "Whiteboard"
       ▼
┌──────────────────┐
│ Full-Screen      │
│ Whiteboard       │
│ (Current Day)    │
└──────┬───────────┘
       │
       │ Tap X
       ▼
┌──────────────┐
│ Return to    │
│ Tracking     │
│ View         │
└──────────────┘
```

## State Management

### BlockRunModeView State
```swift
@State private var showWhiteboard: Bool = false
@State private var currentWeekIndex: Int = 0
@State private var currentDayIndex: Int = 0
```

### Data Flow
```
Block
  ↓ normalize
UnifiedBlock
  ↓ [weekIndex, dayIndex]
UnifiedDay
  ↓ format
[WhiteboardSection]
  ↓ render
UI Components
```

### No State Persistence
- Whiteboard is **display-only**
- No data mutations occur
- Dismissing preserves tracking view state
- Opening/closing has no side effects

## Accessibility

### VoiceOver Labels
- Whiteboard button: "View Whiteboard"
- X button: "Close whiteboard"
- Navigation bar title: Reads block name and week/day

### Dynamic Type Support
- All text uses system fonts
- Scales with user's preferred text size
- Maintains readability at all sizes

### Color Contrast
- Primary/secondary colors meet WCAG standards
- Monospace font ensures alignment
- Sufficient spacing for touch targets

## Dark Mode Support

All colors use semantic system colors:
- `.systemBackground` → black in dark mode
- `.primary` → white in dark mode
- `.secondary` → gray in dark mode

No hardcoded colors, so dark mode works automatically.

## Animation Details

### Modal Presentation
- Type: `.fullScreenCover`
- Animation: Default iOS slide-up
- Duration: ~0.3 seconds
- Easing: System default

### Modal Dismissal
- Triggered by: X button tap
- Uses: `@Environment(\.dismiss)`
- Animation: Slide-down
- Duration: ~0.3 seconds

## Performance Considerations

### Lazy Loading
- WhiteboardDayCardView only renders current day
- ForEach loops are efficient (< 20 items typically)
- No unnecessary re-renders

### Memory Usage
- UnifiedBlock normalized once on modal open
- Formatting happens on-demand per section
- No caching needed (view dismissed completely)

### Scroll Performance
- ScrollView with VStack is lightweight
- Monospace font has consistent metrics
- No complex layouts or animations during scroll

## Summary

This feature provides a focused, distraction-free view of the current workout day in a standard iOS full-screen modal pattern. The implementation is minimal, performant, and follows iOS design guidelines.

**Key Advantages**:
1. Single-day focus reduces cognitive load
2. Full-screen maximizes content visibility
3. Modal pattern is familiar to iOS users
4. Enhanced notes parsing shows circuit details clearly
5. No state changes or side effects
6. Works seamlessly with existing tracking view

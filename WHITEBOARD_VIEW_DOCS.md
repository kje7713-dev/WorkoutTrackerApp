# Whiteboard View Implementation

## Overview

The Whiteboard View is a clean, CrossFit-style workout display that renders training blocks in a skimmable format. It supports both the Savage By Design authoring JSON schema and the app's export schema.

## Features

- **Full-Screen Display**: Pop out to full-screen whiteboard view for current day
- **Single Day Focus**: Shows only the day you're currently working on in BlockRunMode
- **Close Button**: X button to dismiss and return to tracking view
- **Week Navigation**: Browse through different weeks of a training block (in WhiteboardWeekView)
- **Section Organization**: Exercises are organized into Strength, Accessory, and Conditioning sections
- **Compact Display**: Monospace font with minimal lines for easy reading
- **Enhanced Notes Parsing**: AMRAP circuits with movements in notes display as bullets
- **Multiple Input Formats**: Supports authoring JSON and export JSON schemas

## Architecture

### Models (WhiteboardModels.swift)

#### Unified Models
- `UnifiedBlock`: Normalized block structure with weeks array
- `UnifiedDay`: Day with name, goal, and exercises
- `UnifiedExercise`: Exercise with strength/conditioning sets
- `UnifiedStrengthSet`: Reps, rest, RPE, notes
- `UnifiedConditioningSet`: Duration, distance, calories, rounds, effort

#### View Models
- `WhiteboardSection`: Section with title and items
- `WhiteboardItem`: Primary/secondary/tertiary text + bullets

#### Authoring JSON Models
- `AuthoringBlock`: Top-level JSON with Title, Exercises/Days/Weeks
- `AuthoringDay`: Day with name and exercises
- `AuthoringExercise`: Exercise with setsReps, intensityCue, etc.

### Normalization (BlockNormalizer.swift)

The `BlockNormalizer` service converts various input schemas into `UnifiedBlock`:

#### Supported Inputs

1. **Block Model** (App's native model)
   - Uses `weekTemplates` if available
   - Falls back to repeating `days` for all weeks

2. **Authoring JSON** (AI/manual block creation)
   - `Weeks`: Array of week-specific days
   - `Days`: Multi-day repeated across weeks
   - `Exercises`: Single day repeated across weeks

3. **Export JSON** (App export)
   - Prefers `weekTemplates` over `days`
   - Supports multiple blocks (select by index)

#### Normalization Rules

- If `Weeks` exists: `numberOfWeeks = Weeks.count`, use each week's days
- If `Days` exists: repeat Days for `numberOfWeeks`
- If `Exercises` exists: create "Day 1" with exercises, repeat for `numberOfWeeks`

### Formatting (WhiteboardFormatter.swift)

The `WhiteboardFormatter` service converts `UnifiedDay` into `WhiteboardSection` array:

#### Exercise Partitioning

1. **Strength vs Conditioning**: Based on `type` and presence of `conditioningSets`
2. **Main Lifts vs Accessories**: Based on category, set count, and grouping

#### Main Lift Heuristic
- Category in: squat, hinge, pressHorizontal, pressVertical, olympic
- OR strength sets count >= 5
- NOT part of a set group (superset/circuit)

#### Strength Formatting

**Primary**: Exercise name

**Secondary**: Prescription
- All reps same: "5 × 5"
- Varying reps: "3 sets: 5/3/1"
- No reps: "3 sets"
- Append intensity cue from notes (e.g., "@ RPE 8")

**Tertiary**: Rest time
- Format: "Rest: M:SS"
- Example: "Rest: 3:00" for 180 seconds

#### Conditioning Formatting

Formats vary by `conditioningType`:

1. **AMRAP**
   - Secondary: "{minutes} min AMRAP"
   - Bullets: Parsed from notes (comma/newline separated)

2. **EMOM**
   - Secondary: "EMOM {minutes} min"
   - Bullets: Parsed from notes

3. **Intervals**
   - Secondary: "{rounds} rounds"
   - Bullets: ":MM:SS effort", ":MM:SS rest"

4. **Rounds For Time**
   - Secondary: "{rounds} Rounds For Time"
   - Bullets: Parsed from notes

5. **For Time**
   - Secondary: "For Time — {distance}m" or "For Time — {duration}"
   - Bullets: Parsed from notes

6. **For Distance/Calories**
   - Secondary: "For Distance — {meters}m" or "For Calories — {cal} cal"
   - Bullets: Parsed from notes

### UI Components (WhiteboardViews.swift)

#### WhiteboardWeekView
- Header with block name
- Week selector (if multiple weeks)
- Scrollable list of day cards

#### WhiteboardFullScreenDayView (New)
- Full-screen modal presentation
- Shows single day from current week
- Navigation bar with block title and week/day info
- X button in top-right to dismiss
- Scrollable whiteboard display for current day only

#### WhiteboardDayCardView
- Day title and number
- Goal (if present)
- Sections (Strength, Accessory, Conditioning)

#### WhiteboardSectionView
- Bold section header (uppercase, monospaced)
- List of items

#### WhiteboardItemView
- Primary: Exercise name (bold, monospaced)
- Secondary: Prescription (monospaced, secondary color)
- Tertiary: Rest (caption, monospaced, secondary color)
- Bullets: Details with bullet points (caption, monospaced)

## Usage

### In BlockRunMode

1. Open a workout session (BlockRunModeView)
2. Tap "Whiteboard" button in toolbar
3. Full-screen whiteboard view opens showing the current day
4. Tap X button to dismiss and return to tracking view

### Programmatic Usage

```swift
// Normalize a Block
let unifiedBlock = BlockNormalizer.normalize(block: myBlock)

// Normalize authoring JSON
let authoringBlock = try JSONDecoder().decode(AuthoringBlock.self, from: jsonData)
let unifiedBlock = BlockNormalizer.normalize(authoringBlock: authoringBlock)

// Format a day
let sections = WhiteboardFormatter.formatDay(unifiedDay)

// Display full-screen for specific day
WhiteboardFullScreenDayView(
    unifiedBlock: unifiedBlock,
    weekIndex: 0,
    dayIndex: 0
)

// Display multi-week view
WhiteboardWeekView(unifiedBlock: unifiedBlock)
```

## Testing

Run tests with:
```bash
xcodebuild test -scheme WorkoutTrackerApp
```

Test coverage includes:
- Normalization for all input formats
- Strength prescription formatting
- Conditioning formatting (all types)
- Rest time formatting
- Exercise partitioning

## Examples

### Input: Authoring JSON with Weeks

```json
{
  "Title": "Powerlifting Block",
  "NumberOfWeeks": 2,
  "Weeks": [
    [
      {
        "name": "Heavy Squat",
        "exercises": [
          {
            "name": "Back Squat",
            "type": "strength",
            "category": "squat",
            "setsReps": "5x5",
            "intensityCue": "@ RPE 8"
          }
        ]
      }
    ]
  ]
}
```

### Output: Whiteboard Display

```
POWERLIFTING BLOCK
Week 1 • Day 1

Heavy Squat

STRENGTH
Back Squat
5 × 5 @ RPE 8
Rest: 3:00
```

## Notes

- Full-screen modal presentation focuses user on workout details
- Shows only the current day being worked on in BlockRunMode
- Monospace font ensures consistent alignment
- Compact spacing reduces visual clutter
- Section headers are bold and uppercase
- Rest times are optional (only shown if present)
- Bullets are used for conditioning details and parsed from notes
- Enhanced notes parsing detects common exercise patterns (burpees, swings, etc.)
- Modal dismisses cleanly with X button, returning to tracking view
- No data loss when switching between views

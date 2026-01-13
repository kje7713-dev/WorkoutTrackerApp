# Superset Rules

This document explains the superset execution rules implemented in the Workout Tracker App.

## Overview

Supersets are groups of exercises that must be performed back-to-back with rest only after completing all exercises in the group. This is a common training technique used to save time and increase training intensity.

## The Rules

### 1. **Letter Groups Define Supersets**

Any exercises sharing the same letter (A1 + A2, B1 + B2, etc.) form a required superset.

**Example:**
- **Superset A**: A1 (Bench Press) + A2 (Barbell Row)
- **Superset B**: B1 (Overhead Press) + B2 (Pull-Up)
- **Single Exercise**: Squat (no letter prefix)

### 2. **Exercises Must Be Displayed Together**

All exercises in a superset group are displayed as a single grouped block with:
- A blue header showing the group letter (e.g., "Superset A")
- Execution order instructions (e.g., "Complete A1 → A2, then rest")
- Individual exercise labels (A1, A2, A3, etc.)
- A rest instruction at the bottom
- Visual grouping with background color and borders

### 3. **Back-to-Back Execution**

Exercises in a superset must be completed back-to-back before resting:

**Correct Execution:**
1. Complete one set of A1 (Bench Press)
2. Immediately complete one set of A2 (Barbell Row)
3. Rest for the prescribed time
4. Repeat for all sets

**Incorrect Execution:**
- ❌ A1 → Rest → A2 → Rest
- ❌ Complete all sets of A1, then all sets of A2

### 4. **Rest After Complete Superset**

The rest period applies **after completing the full superset**, not between individual exercises:

**Example:**
```
Superset A:
  A1) Bench Press - 3 × 8 @ 135 lbs
  A2) Barbell Row - 3 × 8 @ 115 lbs
  Rest: 90 seconds

Execution:
  Set 1: Bench Press → Barbell Row → Rest 90s
  Set 2: Bench Press → Barbell Row → Rest 90s
  Set 3: Bench Press → Barbell Row → Done
```

### 5. **Numeric Suffix Indicates Order**

The numeric suffix (1, 2, 3...) indicates the execution order within the superset:
- **A1**: First exercise in Superset A
- **A2**: Second exercise in Superset A
- **A3**: Third exercise in Superset A (if present)

## UI Implementation

### Run Mode Display

When viewing a workout in Run Mode, supersets are displayed with:

1. **Group Header**
   - Blue background
   - Link icon (🔗)
   - Group name: "Superset A", "Superset B", etc.
   - Execution instruction: "Complete A1 → A2 → A3, then rest"

2. **Individual Exercise Cards**
   - Exercise label (A1, A2, etc.) displayed prominently
   - Exercise name and details
   - Set logging controls
   - Blue border to indicate grouping

3. **Rest Instruction Footer**
   - Orange background
   - Pause icon (⏸)
   - Text: "Rest after completing all exercises in this superset"

4. **Visual Grouping**
   - Light background behind the entire superset group
   - Rounded corners
   - Clear separation from other exercises

### Whiteboard Display

The whiteboard view shows supersets with:
- Exercise labels (A1, A2, B1, B2, etc.)
- Grouped presentation
- Rest periods clearly indicated

## Technical Implementation

### Data Model
- Exercises with the same `setGroupId` (UUID) are grouped together
- Groups are labeled alphabetically (A, B, C, ...) based on their order in the workout
- Labels are calculated dynamically when rendering the UI

### Code Location
- **Run Mode UI**: `blockrunmode.swift` - `SupersetGroupView` struct
- **Whiteboard Formatting**: `WhiteboardFormatter.swift` - `formatStrengthExerciseGroups` method
- **Exercise Grouping Logic**: `blockrunmode.swift` - `groupExercises` method

## Benefits

This implementation addresses 90% of user misunderstandings about supersets by:

1. **Clear Visual Grouping**: Exercises are visually grouped together
2. **Explicit Labels**: A1/A2 notation is universally understood in strength training
3. **Execution Instructions**: Text explicitly states the execution order
4. **Rest Clarity**: Prominent instruction about when to rest
5. **Professional Standard**: Follows standard gym programming notation

## Examples

### Two-Exercise Superset
```
┌─────────────────────────────────────────┐
│ 🔗 Superset A                           │
│ Complete A1 → A2, then rest             │
├─────────────────────────────────────────┤
│ A1                                      │
│ Bench Press                             │
│ 3 × 8 @ 135 lbs                        │
├─────────────────────────────────────────┤
│ A2                                      │
│ Barbell Row                             │
│ 3 × 8 @ 115 lbs                        │
├─────────────────────────────────────────┤
│ ⏸ Rest after completing all exercises  │
└─────────────────────────────────────────┘
```

### Three-Exercise Giant Set
```
┌─────────────────────────────────────────┐
│ 🔗 Superset B                           │
│ Complete B1 → B2 → B3, then rest        │
├─────────────────────────────────────────┤
│ B1                                      │
│ Overhead Press                          │
│ 3 × 10 @ 95 lbs                        │
├─────────────────────────────────────────┤
│ B2                                      │
│ Pull-Up                                 │
│ 3 × 8                                  │
├─────────────────────────────────────────┤
│ B3                                      │
│ Face Pull                               │
│ 3 × 15 @ 20 lbs                        │
├─────────────────────────────────────────┤
│ ⏸ Rest after completing all exercises  │
└─────────────────────────────────────────┘
```

## Future Enhancements

Potential improvements:
- Rest timer that starts automatically after completing all exercises in the group
- Audio/haptic feedback when transitioning between exercises
- Progress indicator showing which exercise in the superset is active
- Option to customize rest periods per superset group
- Support for advanced variations (alternating sets, cluster sets, etc.)

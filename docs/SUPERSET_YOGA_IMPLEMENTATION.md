# Superset and Yoga Movement Support Implementation

## Overview

This implementation addresses two key issues:
1. **Superset Organization**: Exercises with the same `setGroupId` are now visually grouped and clearly labeled
2. **Yoga/Mobility Exercises**: Added 20+ yoga and mobility exercises to the exercise library

## Changes Made

### 1. Exercise Library Enhancement (Repositories.swift)

Added 20 yoga and mobility exercises to the seed data:

**Yoga Poses**:
- Downward Dog
- Child's Pose
- Cat-Cow Stretch
- Pigeon Pose
- Cobra Pose
- Warrior I & II
- Triangle Pose
- Bridge Pose
- Seated Forward Fold

**Mobility & Stretching**:
- Hip Flexor Stretch
- Thoracic Spine Rotation
- Shoulder Dislocates
- World's Greatest Stretch
- 90/90 Hip Stretch
- Couch Stretch
- Frog Stretch
- Scorpion Stretch
- Band Pull-Apart
- Foam Rolling

All mobility exercises are tagged with:
- `type: .other` (since they're not strength or conditioning)
- `category: .mobility`
- Relevant tags like "yoga", "warm-up", "recovery", "hip mobility", etc.

### 2. Superset Visual Grouping (blockrunmode.swift)

#### RunExerciseState Enhancement
Added `setGroupId` field to track which exercises belong to the same superset:

```swift
struct RunExerciseState: Identifiable, Codable {
    var id = UUID()
    var name: String
    var type: ExerciseType
    var notes: String
    var sets: [RunSetState]
    var setGroupId: SetGroupID?  // NEW: For superset/circuit grouping
}
```

#### Exercise Grouping Logic
Added `groupExercises()` helper function that:
- Groups consecutive exercises with the same `setGroupId`
- Returns individual exercises that aren't in a group
- Maintains exercise order from the template

#### SupersetGroupView Component
New UI component that displays grouped exercises with:
- **Header**: Blue banner with "Superset Group" label and link icon
- **Alternate Icon**: Indicates exercises should be performed alternating
- **Group Container**: Light background with rounded corners
- **Exercise Borders**: Blue outline around each exercise in the group
- **Visual Hierarchy**: Clear separation from non-grouped exercises

#### DayRunView Updates
Modified to:
- Use the `groupExercises()` helper to organize exercises
- Render `SupersetGroupView` for grouped exercises
- Render individual `ExerciseRunCard` for standalone exercises
- Maintain existing functionality for adding exercises

### 3. State Management (RunStateMapper.swift)

Updated `createRunExerciseState()` to:
- Extract `setGroupId` from the exercise template
- Pass it through to the RunExerciseState
- Preserve superset grouping when converting between WorkoutSession and UI state

### 4. Testing (Tests/SupersetAndYogaTests.swift)

Created comprehensive test suite:
- `testYogaExercisesSeeded`: Verifies yoga exercises are in the library
- `testMobilityExercisesHaveCorrectCategory`: Checks category assignment
- `testSupersetGrouping`: Validates grouping logic with templates
- `testSupersetGroupingInSessions`: Ensures sessions preserve structure

### 5. Demo Data (Tests/superset_yoga_demo_block.json)

Created sample block demonstrating:
- Two superset pairs (bench/row, OHP/pull-up)
- Complete yoga & mobility day
- Proper use of setGroupId for grouping

## Usage Guide

### Creating Supersets in Block Builder

When using the JSON block generator:

```json
{
  "exercises": [
    {
      "name": "Bench Press",
      "setGroupId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "setGroupKind": "superset",
      "strengthSets": [...]
    },
    {
      "name": "Barbell Row",
      "setGroupId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "setGroupKind": "superset",
      "strengthSets": [...]
    }
  ]
}
```

**Key Points**:
- Use the **same UUID** for `setGroupId` to group exercises
- Place grouped exercises **consecutively** in the exercises array
- The UI will automatically detect and group them

### Adding Yoga/Mobility Exercises

Users can now:
1. Search for yoga/mobility exercises in the exercise library
2. Find pre-populated options like "Downward Dog", "Hip Flexor Stretch"
3. Filter by `.mobility` category
4. All mobility exercises use `type: .other` (not strength/conditioning)

### Visual Indicators

When viewing a workout with supersets:
- **Blue banner** at top of group says "Superset Group"
- **Link icon** (🔗) indicates exercises are connected
- **Alternate icon** (↕️) shows exercises should be alternated
- **Blue borders** around each exercise in the group
- **Light background** behind the entire group

## Architecture Notes

### Data Flow

```
ExerciseTemplate (with setGroupId)
    ↓
WorkoutSession → SessionExercise (references template)
    ↓
RunStateMapper (extracts setGroupId from template)
    ↓
RunExerciseState (includes setGroupId)
    ↓
DayRunView (groups by setGroupId)
    ↓
SupersetGroupView (visual grouping)
```

### Key Design Decisions

1. **No Changes to Core Models**: `SessionExercise` doesn't have `setGroupId` - it's extracted from the template via `exerciseTemplateId` reference

2. **Consecutive Grouping**: Only consecutive exercises with the same `setGroupId` are grouped (prevents scattered exercises from being grouped)

3. **Visual Only**: Grouping is a UI concern - doesn't affect data storage or progression logic

4. **Exercise Type for Mobility**: Used `.other` type rather than creating a new type, with `.mobility` category for filtering

## Testing

Run the test suite:
```swift
SupersetAndYogaTests.runAllTests()
```

Or import the demo block:
```
Tests/superset_yoga_demo_block.json
```

## Future Enhancements

Potential improvements:
- Display `SetGroupKind` (superset vs circuit vs giant set)
- Show round count for circuits
- Rest timer between group rounds
- Reorder exercises within groups
- Create groups in the UI (not just via JSON)
- Add more yoga/mobility exercises based on user feedback

## Compatibility

- **iOS**: 17.0+
- **Models**: Backward compatible (setGroupId is optional)
- **Existing Blocks**: Continue to work (no grouping shown if setGroupId is nil)
- **Storage**: No migration needed (existing data works as-is)

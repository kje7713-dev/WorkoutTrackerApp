# Superset Whiteboard Rendering Fix

## Problem

Superset exercises were not rendering correctly in the whiteboard view. The issue was that exercises with a `setGroupId` were being automatically classified as accessories, even when they were primary lifts like Bench Press and Barbell Row.

### Root Cause

In `WhiteboardFormatter.swift`, the `isMainLift()` function had a blanket exclusion at lines 100-103:

```swift
// Check if grouped exercises (supersets/circuits are usually accessories)
if exercise.setGroupId != nil {
    return false  // Forces ALL superset exercises to accessories
}
```

This meant that a superset of two main lifts (e.g., Bench Press + Barbell Row) would be incorrectly placed under the "Accessory" header instead of "Strength".

## Solution

### Changes Made

1. **Removed blanket exclusion**: Deleted the code that forced all superset exercises into accessories

2. **Group-based classification**: Modified the logic to group exercises by `setGroupId` BEFORE classifying them as main lifts or accessories

3. **First-exercise classification**: Superset groups are now classified based on the first exercise in the group

4. **Added superset labeling**: Exercises in a superset are labeled as a1, a2, a3, etc. for clarity

### Implementation Details

#### New Function: `groupExercisesBySetGroup()`

Groups consecutive exercises that share the same `setGroupId`:

```swift
private static func groupExercisesBySetGroup(_ exercises: [UnifiedExercise]) -> [[UnifiedExercise]] {
    var groups: [[UnifiedExercise]] = []
    var currentGroup: [UnifiedExercise] = []
    var currentGroupId: String? = nil
    
    for exercise in exercises {
        if let groupId = exercise.setGroupId {
            if groupId == currentGroupId {
                currentGroup.append(exercise)
            } else {
                // Start new group
                if !currentGroup.isEmpty {
                    groups.append(currentGroup)
                }
                currentGroup = [exercise]
                currentGroupId = groupId
            }
        } else {
            // Non-grouped exercise
            if !currentGroup.isEmpty {
                groups.append(currentGroup)
                currentGroup = []
                currentGroupId = nil
            }
            groups.append([exercise])
        }
    }
    
    if !currentGroup.isEmpty {
        groups.append(currentGroup)
    }
    
    return groups
}
```

#### Modified: `partitionStrengthExercises()`

Now operates on groups instead of individual exercises:

```swift
private static func partitionStrengthExercises(_ exerciseGroups: [[UnifiedExercise]]) 
    -> ([[UnifiedExercise]], [[UnifiedExercise]]) {
    var mainLifts: [[UnifiedExercise]] = []
    var accessories: [[UnifiedExercise]] = []
    
    for group in exerciseGroups {
        // Classify based on first exercise in group
        if let firstExercise = group.first, isMainLift(firstExercise) {
            mainLifts.append(group)
        } else {
            accessories.append(group)
        }
    }
    
    return (mainLifts, accessories)
}
```

#### Updated: `isMainLift()`

Removed the blanket exclusion of superset exercises:

```swift
private static func isMainLift(_ exercise: UnifiedExercise) -> Bool {
    let mainLiftCategories = ["squat", "hinge", "pressHorizontal", "pressVertical", "olympic"]
    
    if let category = exercise.category, mainLiftCategories.contains(category) {
        return true
    }
    
    if exercise.strengthSets.count >= 5 {
        return true
    }
    
    return false
    // REMOVED: if exercise.setGroupId != nil { return false }
}
```

#### New Function: `formatStrengthExerciseGroups()`

Formats groups and adds superset labels:

```swift
private static func formatStrengthExerciseGroups(_ exerciseGroups: [[UnifiedExercise]]) -> [WhiteboardItem] {
    var items: [WhiteboardItem] = []
    
    for group in exerciseGroups {
        if group.count > 1 {
            // Superset group - label them a1, a2, etc.
            for (index, exercise) in group.enumerated() {
                let label = "a\(index + 1)"
                items.append(formatStrengthExercise(exercise, label: label))
            }
        } else if let exercise = group.first {
            // Single exercise
            items.append(formatStrengthExercise(exercise))
        }
    }
    
    return items
}
```

## Before vs After

### Before (Incorrect)

```
STRENGTH
  Deadlift
  5 × 5 @ 315 lbs
  Rest: 3:00

ACCESSORY
  Bench Press          ← WRONG! This is a primary lift
  3 × 8 @ 135 lbs
  Rest: 1:00
  
  Barbell Row          ← WRONG! Separated from its superset partner
  3 × 8 @ 115 lbs
  Rest: 1:00
```

### After (Correct)

```
STRENGTH
  a1) Bench Press      ← CORRECT! Labeled as part of superset
  3 × 8 @ 135 lbs
  Rest: 1:00
  ────────────────
  a2) Barbell Row      ← CORRECT! Grouped with superset partner
  3 × 8 @ 115 lbs
  Rest: 1:00
```

## Test Coverage

Added 5 comprehensive tests in `WhiteboardTests.swift`:

1. **testSupersetRenderingUnderStrengthSection**: Verifies supersets of primary lifts stay in Strength section
2. **testMultipleSupersetGroupsUnderStrengthSection**: Tests multiple superset groups in one day
3. **testSupersetWithAccessoryExerciseStaysUnderStrength**: Tests mixed superset (main lift + accessory)
4. **testMixedSupersetAndNonSupersetExercises**: Tests combination of superset and non-superset exercises
5. All tests verify proper a1/a2 labeling

## Edge Cases Handled

1. **Multiple superset groups**: Each group gets its own a1/a2 labeling
2. **Mixed supersets**: If the first exercise is a main lift, the entire group stays in Strength
3. **Standalone exercises**: Non-superset exercises display without labels
4. **Superset + standalone**: Can have both in the same section

## Benefits

✅ **Correct classification**: Supersets are classified based on their content, not just their grouping
✅ **Visual clarity**: a1/a2 labels make superset relationships obvious
✅ **Grouped display**: Superset exercises stay together in the same section
✅ **Flexible**: Works with any number of exercises in a superset (a1, a2, a3, etc.)
✅ **Backward compatible**: Non-superset exercises work exactly as before

## Files Modified

- `WhiteboardFormatter.swift` - Core formatting logic
- `Tests/WhiteboardTests.swift` - Test coverage

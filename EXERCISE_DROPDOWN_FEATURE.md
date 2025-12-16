# Exercise Dropdown Feature

## Overview

This feature adds a dropdown selector for exercises in the Block Builder view while maintaining the ability to enter custom exercise names via free-form text entry.

## User Experience

### Exercise Selection Flow

When adding or editing an exercise in the Block Builder:

1. **Default Mode - Dropdown Selection**
   - User sees a dropdown button showing either "Select exercise" or the currently selected exercise name
   - Tapping the dropdown reveals a menu of standard exercises filtered by type (Strength or Conditioning)
   - User can select any exercise from the list
   - At the bottom of the menu, a "Custom Exercise" option is available

2. **Custom Entry Mode**
   - User can tap the pencil icon button to switch to free-form text entry
   - A standard text field appears where any exercise name can be typed
   - User can tap the list icon button to switch back to dropdown mode

3. **Type Changes**
   - When switching between Strength and Conditioning types, the dropdown automatically updates to show exercises matching the selected type
   - The picker resets to ensure the correct exercise list is displayed

### Toggle Button

- **List icon** (☰): Appears when in custom text entry mode - switches back to dropdown
- **Pencil icon** (✏️): Appears when in dropdown mode - switches to custom text entry

## Technical Implementation

### Components

#### ExerciseNamePicker
A new SwiftUI component that manages the exercise selection experience:

```swift
struct ExerciseNamePicker: View {
    @Binding var exerciseName: String
    let exerciseType: ExerciseType
    @EnvironmentObject private var exerciseLibrary: ExerciseLibraryRepository
    // ...
}
```

**Key Features:**
- Filters exercises by type (strength/conditioning)
- Maintains state for custom entry mode
- Automatically refreshes when exercise type changes
- Uses SwiftUI Menu for native iOS dropdown experience

#### Integration
The picker is integrated into `ExerciseEditorRow` in `BlockBuilderView.swift`:

```swift
ExerciseNamePicker(exerciseName: $exercise.name, exerciseType: exercise.type)
    .id(exercise.type) // Force refresh when type changes
```

### Exercise Library

The `ExerciseLibraryRepository` is seeded with a comprehensive list of common exercises:

#### Strength Exercises (40+ exercises)
- **Squat variations**: Back Squat, Front Squat, Goblet Squat, Bulgarian Split Squat, etc.
- **Hinge variations**: Deadlift, Romanian Deadlift, Sumo Deadlift, etc.
- **Horizontal Press**: Bench Press, Incline Bench Press, Dumbbell Bench Press, Push-Up, etc.
- **Vertical Press**: Overhead Press, Push Press, Handstand Push-Up, etc.
- **Horizontal Pull**: Barbell Row, Dumbbell Row, Cable Row, etc.
- **Vertical Pull**: Pull-Up, Chin-Up, Lat Pulldown, Ring Muscle-Up, etc.
- **Olympic lifts**: Clean, Snatch, Clean & Jerk, Power Clean, etc.
- **Core**: Plank, Sit-Up, Hanging Knee Raise, Toes to Bar, etc.

#### Conditioning Exercises (12+ exercises)
- **Monostructural**: Assault Bike, Row Erg, Ski Erg, BikeErg, Run, Swimming
- **Mixed Modal**: Burpee, Box Jump, Double-Under, Wall Ball, Thruster, Kettlebell Swing

### Data Flow

1. **App Launch**: `SavageByDesignApp` calls `exerciseLibraryRepository.loadDefaultSeedIfEmpty()` in `onAppear`
2. **Exercise Selection**: User interactions update the `exerciseName` binding
3. **Type Filtering**: The picker filters `exerciseLibrary.all()` by the current `exerciseType`
4. **Save**: Exercise name is saved as part of the `EditableExercise` and persisted when the block is saved

## Backwards Compatibility

- Existing blocks with custom exercise names continue to work unchanged
- Free-form text entry is always available as a fallback
- If the exercise library is empty, the picker automatically falls back to text entry mode

## Benefits

1. **Consistency**: Users can select from standardized exercise names
2. **Speed**: Faster than typing, especially for common exercises
3. **Discoverability**: Users can browse available exercises
4. **Flexibility**: Custom exercises can still be entered when needed
5. **Type Safety**: Dropdown automatically filters to relevant exercise types

## Future Enhancements

Potential improvements for future versions:
- Persist custom exercises to the library
- Add search/filter within the dropdown
- Add exercise descriptions and form cues
- Allow users to manage and customize the exercise library
- Add exercise images or videos
- Support for exercise variations and progressions

# Superset Visual Grouping - UI Examples

## Before (Without Grouping)
```
┌─────────────────────────────────┐
│ Bench Press                     │
│ 3 sets × 8 reps @ 135 lbs      │
│ [Set controls]                  │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Barbell Row                     │
│ 3 sets × 8 reps @ 115 lbs      │
│ [Set controls]                  │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Squat                           │
│ 3 sets × 5 reps @ 225 lbs      │
│ [Set controls]                  │
└─────────────────────────────────┘
```

**Problem**: No indication that Bench Press and Barbell Row should be performed together as a superset.

## After (With Grouping)
```
╔═════════════════════════════════╗
║ 🔗 Superset Group      ↕️ Alternate ║
╠═════════════════════════════════╣
║ ┌───────────────────────────┐ ║
║ │ Bench Press               │ ║
║ │ 3 sets × 8 reps @ 135 lbs│ ║
║ │ [Set controls]            │ ║
║ └───────────────────────────┘ ║
║                                 ║
║ ┌───────────────────────────┐ ║
║ │ Barbell Row               │ ║
║ │ 3 sets × 8 reps @ 115 lbs│ ║
║ │ [Set controls]            │ ║
║ └───────────────────────────┘ ║
╚═════════════════════════════════╝

┌─────────────────────────────────┐
│ Squat                           │
│ 3 sets × 5 reps @ 225 lbs      │
│ [Set controls]                  │
└─────────────────────────────────┘
```

**Solution**: 
- Clear visual grouping with blue border
- Header indicates this is a superset
- Alternate icon shows exercises should be performed alternating
- Standalone exercises remain as separate cards

## Color Scheme

- **Group Border**: Blue (`Color.blue.opacity(0.3)`)
- **Group Header**: Blue background (`Color.blue.opacity(0.1)`)
- **Group Label**: Blue text with link icon (🔗)
- **Exercise Cards**: White/system background with blue outline
- **Container**: Light gray background (`.systemGray6`)

## User Experience

### During Workout:
1. User sees "Superset Group" banner
2. Recognizes exercises should be performed together
3. Completes one set of Bench Press
4. Immediately performs one set of Barbell Row
5. Rests after completing both
6. Repeats for remaining sets

### Visual Cues:
- **Link Icon**: Exercises are connected
- **Alternate Icon**: Perform exercises in alternating fashion
- **Blue Border**: Group boundary is clear
- **Spacing**: Groups have more spacing between them than individual exercises

## Multiple Superset Groups

```
╔═════════════════════════════════╗
║ 🔗 Superset Group      ↕️ Alternate ║
╠═════════════════════════════════╣
║ ┌───────────────────────────┐ ║
║ │ Bench Press               │ ║
║ └───────────────────────────┘ ║
║ ┌───────────────────────────┐ ║
║ │ Barbell Row               │ ║
║ └───────────────────────────┘ ║
╚═════════════════════════════════╝

╔═════════════════════════════════╗
║ 🔗 Superset Group      ↕️ Alternate ║
╠═════════════════════════════════╣
║ ┌───────────────────────────┐ ║
║ │ Overhead Press            │ ║
║ └───────────────────────────┘ ║
║ ┌───────────────────────────┐ ║
║ │ Pull-Up                   │ ║
║ └───────────────────────────┘ ║
╚═════════════════════════════════╝

┌─────────────────────────────────┐
│ Core Work                       │
└─────────────────────────────────┘
```

**Each superset group is visually distinct and separated.**

## Yoga/Mobility Exercises

```
┌─────────────────────────────────┐
│ Downward Dog                    │
│ Type: Mobility                  │
│ 1 set (hold 30-60s)            │
│ [Complete button]               │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Pigeon Pose                     │
│ Type: Mobility                  │
│ 2 sets (each side)             │
│ [Complete button]               │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Hip Flexor Stretch              │
│ Type: Mobility                  │
│ 2 sets (each side)             │
│ [Complete button]               │
└─────────────────────────────────┘
```

**Yoga exercises appear as regular exercises but can be found by filtering for `.mobility` category.**

## Implementation Notes

### SwiftUI Structure:
```swift
SupersetGroupView {
    VStack {
        // Header with icon and label
        HStack {
            Image(systemName: "link.circle.fill")
            Text("Superset Group")
            Spacer()
            Image(systemName: "arrow.up.arrow.down.circle")
            Text("Alternate")
        }
        
        // Exercises with blue borders
        ForEach(exercises) { exercise in
            ExerciseRunCard(exercise)
                .overlay(blueStroke)
        }
    }
    .background(grayBackground)
}
```

### Data Model:
```swift
struct RunExerciseState {
    var setGroupId: UUID?  // Same UUID = grouped together
    // ... other fields
}
```

### Grouping Logic:
```swift
func groupExercises() -> [ExerciseGroup] {
    // Consecutive exercises with same setGroupId → grouped
    // Exercises with nil setGroupId → individual
    // Maintains order from template
}
```

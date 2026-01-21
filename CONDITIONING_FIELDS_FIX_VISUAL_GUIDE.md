# Conditioning Fields Fix - Visual Guide

## Overview

This document demonstrates the fix for missing conditioning fields (`distanceMeters` and `calories`) in the Whiteboard view across all conditioning exercise types.

## Problem

Previously, only certain conditioning types would display `distanceMeters` and `calories` fields:
- ✅ **forTime**: Displayed distance and duration
- ✅ **forDistance**: Displayed distance
- ✅ **forCalories**: Displayed calories
- ✅ **Generic**: Displayed all fields
- ❌ **AMRAP**: Did NOT display distance or calories
- ❌ **EMOM**: Did NOT display distance or calories
- ❌ **Intervals**: Did NOT display distance or calories (only in bullets)
- ❌ **Rounds For Time**: Did NOT display distance or calories

## Solution

Updated all conditioning type formatters to display `distanceMeters` and `calories` when present.

## Before & After Comparison

### AMRAP

**Before:**
```
Metcon
20 min AMRAP
• 10 Burpees
• 15 KB Swings
```

**After (with distance):**
```
Metcon
20 min AMRAP — 5000m
• 10 Burpees
• 15 KB Swings
```

**After (with calories):**
```
Bike AMRAP
10 min AMRAP — 150 cal
```

**After (with both):**
```
Mixed AMRAP
20 min AMRAP — 5000m — 200 cal
```

---

### EMOM

**Before:**
```
Row EMOM
EMOM 10 min
• 100m every minute
```

**After (with distance):**
```
Row EMOM
EMOM 10 min — 100m
• 100m every minute
```

**After (with calories):**
```
Bike EMOM
EMOM 15 min — 15 cal
```

---

### Intervals

**Before:**
```
Running Intervals
8 rounds
• :2:00 hard
• :1:00 rest
```

**After (with distance):**
```
Running Intervals
8 rounds — 400m
• :2:00 hard
• :1:00 rest
```

**After (with calories):**
```
Bike Intervals
10 rounds — 20 cal
• :1:30 hard
• :0:30 rest
```

---

### Rounds For Time

**Before:**
```
Hero WOD
5 Rounds For Time
• 400m run
• 50 squats
```

**After (with distance):**
```
Hero WOD
5 Rounds For Time — 800m
• 400m run
• 50 squats
```

**After (with calories):**
```
Bike WOD
3 Rounds For Time — 50 cal
```

---

### For Calories

**Before:**
```
Row
For Calories — 100 cal
```

**After (with distance):**
```
Row
For Calories — 100 cal • 2000m
```

## Technical Details

### Changes to WhiteboardFormatter.swift

Each conditioning type formatter was updated to:
1. Build an array of parts to display
2. Start with the base format (e.g., "20 min AMRAP")
3. Append `distanceMeters` if present (formatted as integer + "m")
4. Append `calories` if present (formatted as integer + " cal")
5. Join parts with " — " separator (or " • " for forCalories)

### Format Pattern

```swift
private static func formatXXX(_ set: UnifiedConditioningSet) -> String {
    var parts: [String] = []
    
    // Add base format
    parts.append("Base Format")
    
    // Add distance if present
    if let distance = set.distanceMeters {
        parts.append("\(Int(distance))m")
    }
    
    // Add calories if present
    if let calories = set.calories {
        parts.append("\(Int(calories)) cal")
    }
    
    return parts.joined(separator: " — ")
}
```

### Test Coverage

Added 11 comprehensive test cases in `WhiteboardTests.swift`:

1. `testAMRAPWithDistanceMetersDisplayed()` - Verifies AMRAP displays distance
2. `testAMRAPWithCaloriesDisplayed()` - Verifies AMRAP displays calories
3. `testEMOMWithDistanceMetersDisplayed()` - Verifies EMOM displays distance
4. `testEMOMWithCaloriesDisplayed()` - Verifies EMOM displays calories
5. `testIntervalsWithDistanceMetersDisplayed()` - Verifies Intervals displays distance
6. `testIntervalsWithCaloriesDisplayed()` - Verifies Intervals displays calories
7. `testRoundsForTimeWithDistanceMetersDisplayed()` - Verifies Rounds For Time displays distance
8. `testRoundsForTimeWithCaloriesDisplayed()` - Verifies Rounds For Time displays calories
9. `testForCaloriesWithDistanceMetersDisplayed()` - Verifies For Calories displays distance
10. `testAMRAPWithBothDistanceAndCalories()` - Verifies multiple fields display correctly

Each test:
- Creates a `UnifiedDay` with a conditioning exercise
- Includes the specific field being tested (`distanceMeters` or `calories`)
- Formats the day using `WhiteboardFormatter.formatDay()`
- Asserts the field appears in the `secondary` line of the formatted item

## Impact

This fix ensures that ALL conditioning fields are visible in the Whiteboard view, regardless of the conditioning type. This provides:

1. **Complete Information**: Users can see distance and calorie targets at a glance
2. **Consistency**: All conditioning types now display fields in a uniform manner
3. **Better Planning**: Athletes can understand the full scope of their conditioning work
4. **Data Integrity**: No information is lost when viewing workouts in the Whiteboard

## Data Model

The `UnifiedConditioningSet` model supports these fields:
```swift
public struct UnifiedConditioningSet: Codable, Equatable {
    public var durationSeconds: Int?
    public var distanceMeters: Double?
    public var calories: Double?
    public var rounds: Int?
    public var effortDescriptor: String?
    public var restSeconds: Int?
    public var notes: String?
}
```

All fields are optional, and the formatter gracefully handles missing fields by only displaying what's present.

## Example Use Cases

### Rowing AMRAP
- Duration: 20 minutes
- Distance target: 5000m
- Display: `20 min AMRAP — 5000m`

### Bike Intervals
- Rounds: 8
- Calories per round: 20
- Work: 90 seconds
- Rest: 30 seconds
- Display: `8 rounds — 20 cal`
- Bullets: `:1:30 hard`, `:0:30 rest`

### Running Intervals
- Rounds: 6
- Distance per round: 400m
- Work: 2 minutes
- Rest: 1 minute
- Display: `6 rounds — 400m`
- Bullets: `:2:00 hard`, `:1:00 rest`

### Hero WOD (Rounds For Time)
- Rounds: 5
- Total distance: 2000m (across all rounds)
- Display: `5 Rounds For Time — 2000m`
- Bullets: Parsed from notes with specific movements

## Notes

- Distance is always formatted as an integer with "m" suffix (e.g., `5000m`)
- Calories are always formatted as an integer with " cal" suffix (e.g., `150 cal`)
- Multiple fields are separated by " — " for most types
- For `forCalories`, distance is separated with " • " to maintain the "For Calories —" prefix
- Fields only appear if they have a non-nil value in the data
- The order is always: base format → distance → calories

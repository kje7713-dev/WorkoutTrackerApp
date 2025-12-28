# Time-Based Workout Requirements Implementation

## Overview

This document describes the implementation of HH:MM:SS time format support for conditioning workouts in the WorkoutTrackerApp.

## Problem Statement

Previously, the app only supported time input in whole minutes for conditioning workouts. This limitation made it impossible to specify:
- Precise workout durations like 1 hour, 30 minutes, and 15 seconds (1:30:15)
- Short interval work periods like 20 seconds (00:00:20)
- Short rest periods like 10 seconds (00:00:10)
- Tabata-style intervals (e.g., 00:00:20 work, 00:00:10 rest)

## Solution

The solution introduces HH:MM:SS time format support throughout the conditioning workout creation and tracking workflow.

### Key Components

#### 1. TimeFormatter Utility (`SetControls.swift`)

A new utility struct that handles conversion between total seconds and HH:MM:SS format:

```swift
public struct TimeFormatter {
    /// Converts total seconds to (hours, minutes, seconds)
    static func secondsToComponents(_ totalSeconds: Int) -> (hours: Int, minutes: Int, seconds: Int)
    
    /// Converts (hours, minutes, seconds) to total seconds
    static func componentsToSeconds(hours: Int, minutes: Int, seconds: Int) -> Int
    
    /// Formats total seconds as "HH:MM:SS" or "H:MM:SS" string
    static func formatTime(_ totalSeconds: Int) -> String
    
    /// Parses time string to total seconds (supports "HH:MM:SS", "MM:SS", or "SS" formats)
    static func parseTime(_ timeString: String) -> Int?
}
```

**Examples:**
- `formatTime(5415)` → `"1:30:15"` (1 hour, 30 minutes, 15 seconds)
- `formatTime(20)` → `"00:00:20"` (20 seconds)
- `formatTime(90)` → `"00:01:30"` (1 minute, 30 seconds)

#### 2. Time Picker Controls (`SetControls.swift`)

Two new SwiftUI controls for hour:minute:second input:

**TimePickerControl** - For `Int?` values (used in block/template creation):
```swift
TimePickerControl(
    label: "DURATION (HH:MM:SS)",
    totalSeconds: $conditioningDurationSeconds
)
```

**TimePickerControlDouble** - For `Double?` values (used in session logging):
```swift
TimePickerControlDouble(
    label: "TIME (HH:MM:SS)",
    totalSeconds: $actualTimeSeconds
)
```

Both controls provide:
- Separate +/- buttons for hours, minutes, and seconds
- Each component displayed as 2-digit format (e.g., "01", "00", "15")
- Automatic conversion to/from total seconds
- Validation (max 23 hours, max 59 minutes, max 59 seconds)

#### 3. Block Builder Updates (`BlockBuilderView.swift`)

The conditioning editor now uses the time picker instead of simple minute input:

**Before:**
```swift
TextField("Duration (minutes, optional)", text: durationMinutesBinding)
```

**After:**
```swift
TimePickerControl(
    label: "DURATION (HH:MM:SS)",
    totalSeconds: $exercise.conditioningDurationSeconds
)

// Also updated rest input:
TimePickerControl(
    label: "REST (HH:MM:SS)",
    totalSeconds: $exercise.conditioningRestSeconds
)
```

#### 4. Session Run View Updates (`blockrunmode.swift`)

The live workout tracking interface now displays and logs time in HH:MM:SS format:

**Before:**
```swift
// Displayed only minutes
Text("\(timeMinutesValue) min")
```

**After:**
```swift
TimePickerControlDouble(
    label: "TIME (HH:MM:SS)",
    totalSeconds: $runSet.actualTimeSeconds
)
```

The "Planned" display text also now shows HH:MM:SS format:
```swift
// Old: "10 min" or "90 sec"
// New: "00:10:00" or "00:01:30"
parts.append(TimeFormatter.formatTime(dur))
```

## Data Model

**No changes** to the data model were required. The app continues to store time as:
- `durationSeconds: Int?` in `ConditioningSetTemplate`
- `actualTimeSeconds: Double?` and `expectedTime: Double?` in session data

This ensures **full backwards compatibility** with existing workout data.

## Use Cases

### Example 1: Long Run with Time Cap
Create a 1-hour, 30-minute, 15-second run:
1. Add conditioning exercise
2. Set duration using time picker:
   - Hours: 01
   - Minutes: 30
   - Seconds: 15
3. Result: Stored as 5415 seconds, displayed as "1:30:15"

### Example 2: Tabata Row Intervals
Create 20 seconds work, 10 seconds rest:

**Work Interval:**
- Hours: 00, Minutes: 00, Seconds: 20
- Displayed as "00:00:20"

**Rest Period:**
- Hours: 00, Minutes: 00, Seconds: 10
- Displayed as "00:00:10"

### Example 3: EMOM (Every Minute on the Minute)
Create 12-minute EMOM:
- Hours: 00, Minutes: 12, Seconds: 00
- Displayed as "00:12:00"

## Testing

A comprehensive test suite (`TimeFormatterTests.swift`) validates:
- ✅ Conversion from seconds to components (hours, minutes, seconds)
- ✅ Conversion from components back to total seconds
- ✅ Formatting as HH:MM:SS strings
- ✅ Parsing various time formats (HH:MM:SS, MM:SS, SS)
- ✅ Round-trip conversions (format → parse → original value)

Example test cases:
- 1:30:15 (5415 seconds)
- 00:00:20 (20 seconds)
- 00:00:10 (10 seconds)
- 1:00:00 (3600 seconds)
- 00:01:30 (90 seconds)

## UI/UX Improvements

### Before
- **Input:** Single text field asking for minutes
- **Display:** "10 min" or "90 sec"
- **Limitation:** Could not specify seconds or hours precisely

### After
- **Input:** Three separate controls (hours, minutes, seconds) with +/- buttons
- **Display:** "1:30:15", "00:00:20", "00:12:00" - always in HH:MM:SS
- **Benefit:** Precise control over workout timing

## Backwards Compatibility

✅ **Fully backwards compatible**
- Existing workouts continue to work
- Old data (stored in seconds) displays correctly in new format
- No migration required

Example:
- Old workout with 600 seconds now displays as "00:10:00"
- Old workout with 90 seconds now displays as "00:01:30"

## Future Enhancements

Potential improvements for future versions:
1. **Quick presets:** "20s", "30s", "1min", "5min" buttons for common intervals
2. **Direct text input:** Allow typing "1:30:15" directly in addition to steppers
3. **Time calculator:** Helper to convert paces (e.g., "8:00/mile" for 5K)
4. **Timer integration:** Live countdown timer during workout execution

## Files Modified

1. **SetControls.swift** (+234 lines)
   - Added `TimeFormatter` utility struct
   - Added `TimePickerControl` for Int? values
   - Added `TimePickerControlDouble` for Double? values
   - Added Int? binding extension for minutes conversion

2. **BlockBuilderView.swift** (-21 lines)
   - Replaced minute-only input with HH:MM:SS time picker
   - Removed `durationMinutesBinding` computed property
   - Updated rest seconds input to use time picker

3. **blockrunmode.swift** (-27 lines)
   - Replaced minute-only display with HH:MM:SS time picker
   - Updated display text generation to use `TimeFormatter.formatTime()`
   - Removed `timeMinutesValue` computed property
   - Updated `buildConditioningDisplayText()` function

4. **Tests/TimeFormatterTests.swift** (+157 lines, new file)
   - Comprehensive test coverage for time formatting utilities

## Summary

This implementation successfully adds HH:MM:SS time format support to conditioning workouts, enabling precise time-based programming for athletes and coaches. The solution maintains backwards compatibility while providing a significantly improved user experience for time-based workout programming.

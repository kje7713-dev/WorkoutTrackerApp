# Weeks Schema Implementation Guide

## Overview

The Savage By Design workout tracker app now fully supports **week-specific exercise variations** through the `Weeks` schema in JSON blocks. This allows for true Daily Undulating Periodization (DUP) programming, deload weeks, peaking cycles, and any week-specific periodization strategy.

## JSON Schema

### Basic Structure

```json
{
  "Title": "Block Name",
  "NumberOfWeeks": 4,
  "Weeks": [
    [/* Week 1 days */],
    [/* Week 2 days */],
    [/* Week 3 days */],
    [/* Week 4 days */]
  ]
}
```

### Complete Example

```json
{
  "Title": "Powerlifting DUP 4-Week Block",
  "Goal": "strength",
  "TargetAthlete": "Intermediate",
  "NumberOfWeeks": 4,
  "DurationMinutes": 90,
  "Difficulty": 4,
  "Equipment": "Barbell, Rack",
  "WarmUp": "5 min dynamic",
  "Weeks": [
    [
      {
        "name": "Week 1 - Heavy Day",
        "exercises": [
          {
            "name": "Back Squat",
            "setsReps": "5x5",
            "intensityCue": "85% 1RM"
          }
        ]
      }
    ],
    [
      {
        "name": "Week 2 - Volume Day",
        "exercises": [
          {
            "name": "Front Squat",
            "setsReps": "4x8",
            "intensityCue": "70% 1RM"
          }
        ]
      }
    ],
    [
      {
        "name": "Week 3 - Power Day",
        "exercises": [
          {
            "name": "Box Squat",
            "setsReps": "6x3",
            "intensityCue": "75% 1RM"
          }
        ]
      }
    ],
    [
      {
        "name": "Week 4 - Deload",
        "exercises": [
          {
            "name": "Back Squat",
            "setsReps": "3x5",
            "intensityCue": "60% 1RM"
          }
        ]
      }
    ]
  ],
  "Finisher": "Core work",
  "Notes": "DUP programming",
  "EstimatedTotalTimeMinutes": 90,
  "Progression": "Week-specific"
}
```

## Implementation Details

### Parsing Priority

The BlockGenerator follows this priority order when parsing JSON:

1. **Weeks** - Week-specific variations (NEW)
2. **Days** - Multi-day blocks with same days all weeks
3. **Exercises** - Single-day blocks (legacy)

### Data Model

#### ImportedBlock (DTO)
```swift
public struct ImportedBlock: Codable {
    public var Title: String
    public var NumberOfWeeks: Int?
    public var Weeks: [[ImportedDay]]?  // Week-specific variations
    public var Days: [ImportedDay]?     // Multi-day (same all weeks)
    public var Exercises: [ImportedExercise]? // Single-day (legacy)
    // ... other fields
}
```

#### Block (Domain Model)
```swift
public struct Block: Identifiable, Codable, Equatable {
    public var id: BlockID
    public var name: String
    public var numberOfWeeks: Int
    public var days: [DayTemplate]           // Default/fallback days
    public var weekTemplates: [[DayTemplate]]? // Week-specific templates
    // ... other fields
}
```

### Conversion Logic

**BlockGenerator.convertToBlock()** handles the conversion:

```swift
// Priority: Weeks > Days > Exercises
if let weeks = imported.Weeks, !weeks.isEmpty {
    // Week-specific mode
    weekTemplates = weeks.map { weekDays in
        weekDays.map { convertDay($0, ...) }
    }
    dayTemplates = weekTemplates?.first ?? [placeholder]
} else if let days = imported.Days, !days.isEmpty {
    // Multi-day mode (same days all weeks)
    dayTemplates = days.map { convertDay($0, ...) }
    weekTemplates = nil
} else if let exercises = imported.Exercises, !exercises.isEmpty {
    // Single-day mode (legacy)
    dayTemplates = [DayTemplate(...)]
    weekTemplates = nil
}
```

### Session Generation

**SessionFactory.makeSessions()** creates workout sessions:

```swift
for weekIndex in 1...block.numberOfWeeks {
    let dayTemplates: [DayTemplate]
    
    if let weekTemplates = block.weekTemplates, !weekTemplates.isEmpty {
        // Use week-specific templates
        let weekArrayIndex = weekIndex - 1
        if weekArrayIndex < weekTemplates.count {
            dayTemplates = weekTemplates[weekArrayIndex]
        } else {
            // Repeat last week if numberOfWeeks > weekTemplates.count
            dayTemplates = weekTemplates.last ?? block.days
        }
    } else {
        // Replicate block.days for all weeks
        dayTemplates = block.days
    }
    
    // Generate sessions from dayTemplates...
}
```

## Logging

The implementation includes comprehensive logging to confirm parsing:

### BlockGenerator Logging

- **Week-specific blocks**: Logs week count and days per week
- **Multi-day blocks**: Logs total days
- **Single-day blocks**: Logs exercise count

Example output:
```
📅 Parsing week-specific block: 4 weeks detected
  Week 1: 2 days
  Week 2: 2 days
  Week 3: 2 days
  Week 4: 2 days
```

### SessionFactory Logging

- Logs which mode is being used (week-specific vs. standard)
- Logs session generation for each week
- Logs total session count

Example output:
```
🏋️ Generating sessions in week-specific mode: 4 week templates for 4 weeks
  Week 1: using week-specific templates (2 days)
  Week 2: using week-specific templates (2 days)
  Week 3: using week-specific templates (2 days)
  Week 4: using week-specific templates (2 days)
✅ Generated 8 total sessions for block 'Powerlifting DUP 4-Week Block'
```

## Backward Compatibility

The implementation maintains full backward compatibility:

1. **Existing blocks without weekTemplates** continue to work normally
2. **Days-based blocks** replicate days across all weeks as before
3. **Exercise-based blocks** (legacy) work unchanged
4. **weekTemplates is optional** - defaults to `nil` if not provided

## Testing

### Automated Tests

See `Tests/WeekSpecificBlockTests.swift` for comprehensive test coverage:

- `testBlockWeekTemplatesStorage()` - Verifies Block model stores weekTemplates
- `testSessionFactoryWeekSpecific()` - Validates session generation with weekTemplates
- `testSessionFactoryFallback()` - Confirms fallback to standard mode
- `testJSONWeekSpecificParsing()` - Tests JSON parsing of Weeks array
- `testBackwardCompatibility()` - Ensures legacy blocks still work

### Manual Testing

Use `Tests/ManualWeeksTest.swift` with the test JSON file:

```swift
ManualWeeksTest.runAll()
```

This will:
1. Load `Tests/test_weeks_block.json`
2. Parse the JSON with BlockGenerator
3. Convert to Block model
4. Generate sessions with SessionFactory
5. Verify week distribution
6. Log all steps with detailed output

## Use Cases

### Daily Undulating Periodization (DUP)
Different exercises or intensities each week while maintaining the same movement patterns.

### Deload Weeks
Week 4 uses reduced volume/intensity while weeks 1-3 are higher stress.

### Peaking Cycles
Progressively reduce volume and increase specificity in final weeks.

### Block Periodization
Different training phases within a single block (accumulation → intensification → realization).

### Progressive Overload
Week-by-week changes in sets, reps, or load.

## Migration Guide

### From Days-based to Weeks-based

**Before (Days):**
```json
{
  "Days": [
    {"name": "Day 1", "exercises": [...]},
    {"name": "Day 2", "exercises": [...]}
  ]
}
```

**After (Weeks):**
```json
{
  "Weeks": [
    [
      {"name": "Week 1 Day 1", "exercises": [...]},
      {"name": "Week 1 Day 2", "exercises": [...]}
    ],
    [
      {"name": "Week 2 Day 1", "exercises": [...]},
      {"name": "Week 2 Day 2", "exercises": [...]}
    ]
  ]
}
```

## Troubleshooting

### Issue: Weeks not parsing

**Check:**
1. Ensure `Weeks` field is at the root level of JSON
2. Verify `Weeks` is an array of arrays: `[[ImportedDay]]`
3. Check logs for parsing errors
4. Ensure JSON is valid (use a JSON validator)

### Issue: Only first week appears

**Check:**
1. Verify `numberOfWeeks` matches or exceeds `Weeks.length`
2. Check that all weeks have at least one day
3. Review logs to confirm all weeks were parsed

### Issue: Sessions not generated correctly

**Check:**
1. Confirm Block has non-nil `weekTemplates`
2. Verify SessionFactory logs show "week-specific mode"
3. Ensure each week's dayTemplates have exercises

## Performance Considerations

- **Memory**: Week-specific blocks store more data (N weeks × M days)
- **Parsing**: Minimal overhead - same O(n) complexity
- **Session Generation**: No significant performance impact
- **Storage**: JSON size increases with week-specific data

## Future Enhancements

Potential improvements:
1. UI indicators for week-specific blocks
2. Week comparison views in the app
3. Export/import of week-specific blocks
4. Template library for common DUP schemes
5. Week-by-week progression tracking

## Related Files

- `Models.swift` - Block and DayTemplate definitions
- `BlockGenerator.swift` - JSON parsing and conversion
- `SessionFactory.swift` - Session generation logic
- `Repositories.swift` - Persistence layer
- `Tests/WeekSpecificBlockTests.swift` - Automated tests
- `Tests/ManualWeeksTest.swift` - Manual testing suite
- `Tests/test_weeks_block.json` - Sample week-specific JSON

## Support

For issues or questions about the Weeks schema implementation:
1. Check logs for parsing/generation details
2. Review test files for working examples
3. Consult this documentation
4. Check test_weeks_block.json for JSON schema reference

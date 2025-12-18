# Week-Specific Exercise Variations Guide

## Overview

This guide explains the new week-specific exercise variation feature that allows you to create training blocks with different exercises across weeks. This is essential for proper periodization, deload weeks, exercise rotations, and progressive programming.

## Problem Solved

**Before**: Training blocks could only repeat the same exercises for all weeks. If you had a 12-week block, Week 1 Day 1 would have the exact same exercises as Week 12 Day 1.

**After**: You can now specify different exercises for each week, enabling:
- Exercise variations (Back Squat → Front Squat → Pause Squat)
- Deload weeks with different movements
- Progressive complexity (Simple → Advanced variations)
- Periodization models with exercise rotations
- Different training phases within a single block

## Architecture

### Data Model Changes

#### Block Model (Models.swift)
```swift
public struct Block {
    public var days: [DayTemplate]              // Default days (backward compatible)
    public var weekTemplates: [[DayTemplate]]?  // NEW: Week-specific templates
    // ... other fields
}
```

**How it works**:
- `days`: Used when all weeks have the same exercises (standard mode)
- `weekTemplates`: Optional array where `weekTemplates[0]` = Week 1 days, `weekTemplates[1]` = Week 2 days, etc.
- When `weekTemplates` is present, it takes priority over `days`

#### SessionFactory Logic
```swift
// Determines which templates to use for each week:
if let weekTemplates = block.weekTemplates {
    // Use week-specific templates
    dayTemplates = weekTemplates[weekIndex - 1]
} else {
    // Fall back to standard replication
    dayTemplates = block.days
}
```

## JSON Schema

### Standard Format (Same Exercises All Weeks)

Use the `Days` field for blocks where exercises don't change:

```json
{
  "Title": "Upper/Lower Split",
  "NumberOfWeeks": 4,
  "Days": [
    {
      "name": "Day 1: Upper",
      "exercises": [
        {"name": "Bench Press", "setsReps": "4x8"},
        {"name": "Barbell Row", "setsReps": "4x8"}
      ]
    },
    {
      "name": "Day 2: Lower",
      "exercises": [
        {"name": "Back Squat", "setsReps": "4x8"},
        {"name": "Romanian Deadlift", "setsReps": "3x10"}
      ]
    }
  ]
}
```

Result: Same 2 days repeated for all 4 weeks.

### Week-Specific Format (Different Exercises Per Week)

Use the `Weeks` field for blocks with exercise variations:

```json
{
  "Title": "Squat Variation Block",
  "NumberOfWeeks": 3,
  "Weeks": [
    [
      {
        "name": "Day 1: Heavy Squat",
        "exercises": [
          {"name": "Back Squat", "setsReps": "5x5", "intensityCue": "RPE 8"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Volume Squat",
        "exercises": [
          {"name": "Front Squat", "setsReps": "4x8", "intensityCue": "RPE 7"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Technique Squat",
        "exercises": [
          {"name": "Pause Squat", "setsReps": "3x6", "intensityCue": "RPE 6"}
        ]
      }
    ]
  ]
}
```

Result:
- Week 1: Back Squat 5x5
- Week 2: Front Squat 4x8
- Week 3: Pause Squat 3x6

## Real-World Examples

### Example 1: Periodization Block with Exercise Rotations

A 12-week block rotating between three squat variations:

```json
{
  "Title": "12-Week Squat Periodization",
  "Goal": "strength",
  "TargetAthlete": "Advanced",
  "NumberOfWeeks": 12,
  "DurationMinutes": 90,
  "Difficulty": 5,
  "Equipment": "Full gym access",
  "WarmUp": "10 min movement prep",
  "Weeks": [
    [
      {
        "name": "Day 1: Heavy Back Squat",
        "exercises": [
          {"name": "Back Squat", "setsReps": "5x3", "intensityCue": "RPE 9"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Heavy Back Squat",
        "exercises": [
          {"name": "Back Squat", "setsReps": "5x2", "intensityCue": "RPE 9"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Heavy Back Squat",
        "exercises": [
          {"name": "Back Squat", "setsReps": "5x1", "intensityCue": "RPE 9.5"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Deload - Pause Squat",
        "exercises": [
          {"name": "Pause Squat", "setsReps": "3x5", "intensityCue": "RPE 6"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Front Squat Build",
        "exercises": [
          {"name": "Front Squat", "setsReps": "4x6", "intensityCue": "RPE 8"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Front Squat Build",
        "exercises": [
          {"name": "Front Squat", "setsReps": "4x5", "intensityCue": "RPE 8"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Front Squat Build",
        "exercises": [
          {"name": "Front Squat", "setsReps": "4x4", "intensityCue": "RPE 8.5"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Deload - Goblet Squat",
        "exercises": [
          {"name": "Goblet Squat", "setsReps": "3x8", "intensityCue": "RPE 5"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Competition Squat Peak",
        "exercises": [
          {"name": "Back Squat", "setsReps": "3x3", "intensityCue": "RPE 9"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Competition Squat Peak",
        "exercises": [
          {"name": "Back Squat", "setsReps": "3x2", "intensityCue": "RPE 9.5"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Competition Squat Peak",
        "exercises": [
          {"name": "Back Squat", "setsReps": "3x1", "intensityCue": "RPE 10"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Recovery Week",
        "exercises": [
          {"name": "Box Squat", "setsReps": "3x5", "intensityCue": "RPE 5"}
        ]
      }
    ]
  ],
  "Finisher": "Mobility and recovery work",
  "Notes": "Progressive periodization with deloads every 4 weeks",
  "EstimatedTotalTimeMinutes": 90,
  "Progression": "Wave loading with exercise variations"
}
```

### Example 2: Conjugate Method Block

```json
{
  "Title": "8-Week Conjugate Method",
  "Goal": "strength",
  "TargetAthlete": "Advanced",
  "NumberOfWeeks": 8,
  "DurationMinutes": 75,
  "Difficulty": 5,
  "Equipment": "Full powerlifting gym",
  "WarmUp": "Dynamic warm-up",
  "Weeks": [
    [
      {
        "name": "Max Effort Lower",
        "exercises": [
          {"name": "Box Squat", "setsReps": "Work up to 1RM"}
        ]
      },
      {
        "name": "Dynamic Effort Upper",
        "exercises": [
          {"name": "Speed Bench", "setsReps": "8x3", "intensityCue": "60% 1RM"}
        ]
      }
    ],
    [
      {
        "name": "Max Effort Lower",
        "exercises": [
          {"name": "Deadlift Against Bands", "setsReps": "Work up to 1RM"}
        ]
      },
      {
        "name": "Dynamic Effort Upper",
        "exercises": [
          {"name": "Speed Bench", "setsReps": "8x3", "intensityCue": "60% 1RM"}
        ]
      }
    ],
    [
      {
        "name": "Max Effort Lower",
        "exercises": [
          {"name": "Safety Squat Bar Squat", "setsReps": "Work up to 3RM"}
        ]
      },
      {
        "name": "Dynamic Effort Upper",
        "exercises": [
          {"name": "Speed Bench with Chains", "setsReps": "8x3"}
        ]
      }
    ]
  ],
  "Finisher": "Accessory work based on weaknesses",
  "Notes": "Rotate max effort exercises weekly",
  "EstimatedTotalTimeMinutes": 75,
  "Progression": "Westside Barbell conjugate method"
}
```

### Example 3: Hypertrophy Block with Progressive Complexity

```json
{
  "Title": "6-Week Hypertrophy Progression",
  "Goal": "hypertrophy",
  "TargetAthlete": "Intermediate",
  "NumberOfWeeks": 6,
  "DurationMinutes": 60,
  "Difficulty": 4,
  "Equipment": "Dumbbells, cables, machines",
  "WarmUp": "5 min cardio + activation",
  "Weeks": [
    [
      {
        "name": "Day 1: Chest",
        "exercises": [
          {"name": "Machine Chest Press", "setsReps": "4x12", "intensityCue": "RPE 7"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Chest",
        "exercises": [
          {"name": "Machine Chest Press", "setsReps": "4x10", "intensityCue": "RPE 8"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Chest",
        "exercises": [
          {"name": "Dumbbell Bench Press", "setsReps": "4x10", "intensityCue": "RPE 8"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Chest",
        "exercises": [
          {"name": "Dumbbell Bench Press", "setsReps": "4x8", "intensityCue": "RPE 8.5"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Chest",
        "exercises": [
          {"name": "Barbell Bench Press", "setsReps": "4x8", "intensityCue": "RPE 8.5"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: Chest",
        "exercises": [
          {"name": "Barbell Bench Press", "setsReps": "4x6", "intensityCue": "RPE 9"}
        ]
      }
    ]
  ],
  "Finisher": "Stretching and recovery",
  "Notes": "Progress from machines to free weights with increasing intensity",
  "EstimatedTotalTimeMinutes": 60,
  "Progression": "Exercise complexity and load increase"
}
```

## AI Prompt Template Usage

When requesting AI to generate blocks with week variations, use this format:

```
I need a [X]-week block with different exercises each week.

Requirements:
- Week 1-3: Back Squat focus (strength)
- Week 4: Deload with lighter squat variation
- Week 5-7: Front Squat focus (volume)
- Week 8: Peak with competition squat

Use the "Weeks" format in JSON to specify different exercises for each week.
```

The AI will generate proper JSON with week-specific templates.

## Migration from Old Format

### Old Format (Limited)
```json
{
  "Days": [{"name": "Day 1", "exercises": [...]}],
  "NumberOfWeeks": 8
}
```
Result: Same exercises for all 8 weeks

### New Format (Flexible)
```json
{
  "Weeks": [
    [{"name": "Day 1", "exercises": [...]}],  // Week 1
    [{"name": "Day 1", "exercises": [...]}],  // Week 2
    // ... etc
  ]
}
```
Result: Different exercises each week

## Backward Compatibility

All existing blocks continue to work:
- Blocks without `weekTemplates` field work unchanged
- JSON without `Weeks` field processes normally
- SessionFactory automatically detects and uses correct mode
- No migration needed for existing data

## Technical Implementation

### SessionFactory.makeSessions(for:) Logic
```swift
for weekIndex in 1...block.numberOfWeeks {
    let dayTemplates: [DayTemplate]
    
    if let weekTemplates = block.weekTemplates, !weekTemplates.isEmpty {
        // Week-specific mode
        let weekArrayIndex = weekIndex - 1
        if weekArrayIndex < weekTemplates.count {
            dayTemplates = weekTemplates[weekArrayIndex]
        } else {
            // Fallback to last week if index exceeds
            dayTemplates = weekTemplates.last ?? block.days
        }
    } else {
        // Standard replication mode
        dayTemplates = block.days
    }
    
    // Generate sessions from dayTemplates...
}
```

### BlockGenerator.convertToBlock Priority
```swift
// Priority order:
if let weeks = imported.Weeks {
    // Use week-specific format (NEW)
    weekTemplates = convert(weeks)
} else if let days = imported.Days {
    // Use multi-day format
    dayTemplates = convert(days)
} else if let exercises = imported.Exercises {
    // Use single-day format (legacy)
    dayTemplates = [convert(exercises)]
}
```

## Best Practices

### 1. When to Use Week-Specific Format
✅ Use when:
- Exercise selection changes across weeks
- Implementing periodization models
- Planning deload weeks with different movements
- Rotating exercise variations
- Progressive complexity training

❌ Don't use when:
- Same exercises for all weeks (use standard `Days` format)
- Only changing weights/reps (use progression rules instead)
- Simple linear progression programs

### 2. JSON Structure Tips
- Keep week arrays consistent in structure
- Maintain same day names across weeks for clarity
- Use descriptive exercise names
- Include intensity cues for each variation
- Document progression strategy in `Progression` field

### 3. Programming Considerations
- Plan deload weeks as different exercises, not just reduced volume
- Rotate variations to prevent adaptation
- Progress from simpler to more complex variations
- Consider technical mastery before advancing variations
- Balance variety with practice (don't change too frequently)

## Troubleshooting

### Issue: Weeks not different in app
**Solution**: Verify JSON uses `Weeks` array, not `Days` field

### Issue: Missing weeks in generated sessions
**Solution**: Ensure `Weeks` array length matches `NumberOfWeeks`

### Issue: Unexpected exercises in certain weeks
**Solution**: Check week array indexing (0-based in array, 1-based in week numbers)

### Issue: Backward compatibility broken
**Solution**: Ensure old blocks have `weekTemplates: nil`, not empty array

## Testing

Run the test suite to validate week-specific functionality:
```swift
WeekSpecificBlockTests.runAll()
```

Tests validate:
- ✅ Block model stores week templates correctly
- ✅ SessionFactory generates week-specific sessions
- ✅ SessionFactory falls back to standard mode
- ✅ JSON import parses week-specific format
- ✅ Backward compatibility with existing blocks

## Summary

The week-specific exercise variation feature enables:
- **True periodization**: Change exercises across training phases
- **Better programming**: Implement deload weeks properly
- **Exercise mastery**: Progress through variation complexity
- **Flexibility**: Mix and match exercises week-to-week
- **Compatibility**: Works alongside existing block formats

This solves the original limitation where blocks could only repeat the same exercises for all weeks, enabling proper periodization and programming flexibility.

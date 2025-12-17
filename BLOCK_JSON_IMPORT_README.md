# Block JSON Import - Complete Guide

## Overview

This feature allows you to import custom training blocks from JSON files into the Savage By Design app. Generate blocks using any AI assistant (ChatGPT, Claude, Gemini, etc.) and import them directly into your training library.

**Key Capabilities:**
- ✅ Strength training exercises (sets, reps, weight, RPE, RIR, tempo)
- ✅ Conditioning exercises (time, distance, calories, rounds)
- ✅ Multi-week progression programs
- ✅ Exercise categorization and organization
- ✅ Custom warm-ups, finishers, and notes
- ✅ Automatic session generation for all weeks

## Quick Start

### Importing a Block

1. Open the app and navigate to **Blocks**
2. Tap **IMPORT FROM JSON** (blue button)
3. Tap **Choose JSON File**
4. Select a JSON file from your device (must have `.json` extension)
5. Review the block preview
6. Tap **Save Block to Library**

The block will be added to your library with automatically generated workout sessions for all weeks.

## JSON File Format

### File Naming Convention

Save your JSON files with descriptive names using this pattern:
- `[BlockName]_[Weeks]W_[Days]D.json` - Example: `UpperLower_4W_4D.json`
- `[Goal]_[Level].json` - Example: `Strength_Intermediate.json`
- Keep filenames under 50 characters, use underscores instead of spaces

### Simple Example (Strength Focus)

This is the simplest format for a single-day strength training block:

```json
{
  "Title": "Full Body Strength",
  "Goal": "Build foundational strength",
  "TargetAthlete": "Intermediate",
  "DurationMinutes": 45,
  "Difficulty": 3,
  "Equipment": "Barbell, Dumbbells, Rack",
  "WarmUp": "5 min dynamic stretching, mobility work",
  "Exercises": [
    {
      "name": "Back Squat",
      "setsReps": "3x8",
      "restSeconds": 180,
      "intensityCue": "RPE 7"
    },
    {
      "name": "Bench Press",
      "setsReps": "3x8",
      "restSeconds": 120,
      "intensityCue": "RPE 7"
    },
    {
      "name": "Barbell Row",
      "setsReps": "3x8",
      "restSeconds": 120,
      "intensityCue": "RPE 7"
    }
  ],
  "Finisher": "10 min cooldown stretch",
  "Notes": "Focus on form over weight. Increase load gradually.",
  "EstimatedTotalTimeMinutes": 45,
  "Progression": "Add 5 lbs per week"
}
```

## Complete Field Reference

### Block-Level Fields

| Field | Type | Required? | Description | Example |
|-------|------|-----------|-------------|---------|
| `Title` | string | ✅ Required | Block name (keep under 50 chars) | "Upper/Lower Split" |
| `Goal` | string | ✅ Required | Training objective | "strength", "hypertrophy", "power", "conditioning", "mixed", "peaking", "deload", "rehab" |
| `TargetAthlete` | string | ✅ Required | Experience level | "Beginner", "Intermediate", "Advanced" |
| `NumberOfWeeks` | integer | ⚪ Optional | Total weeks in block (defaults to 1) | `4`, `8`, `12` |
| `DurationMinutes` | integer | ✅ Required | Estimated workout duration per session | `45`, `60`, `30` |
| `Difficulty` | integer | ✅ Required | Difficulty rating (1-5 scale) | `3` (1=easiest, 5=hardest) |
| `Equipment` | string | ✅ Required | Required equipment list | "Barbell, Dumbbells, Rack, Bench" |
| `WarmUp` | string | ✅ Required | Warm-up instructions | "5 min bike, dynamic stretching" |
| `Exercises` | array | ⚪ Optional* | Single-day format: list of exercises | `[{...}, {...}]` |
| `Days` | array | ⚪ Optional* | Multi-day format: array of day objects | `[{day1}, {day2}]` |
| `Finisher` | string | ✅ Required | Finisher/cooldown instructions | "10 min cooldown, foam rolling" |
| `Notes` | string | ✅ Required | Additional context and instructions | "Focus on form, progressive overload" |
| `EstimatedTotalTimeMinutes` | integer | ✅ Required | Total session time including warm-up/finisher | `60` |
| `Progression` | string | ✅ Required | Week-to-week progression strategy | "Add 5 lbs per week, deload week 4" |

**\*Note:** Use either `Exercises` (for single-day blocks) OR `Days` (for multi-day blocks), not both.

### Day-Level Fields (for Multi-Day Blocks)

When using the `Days` array, each day object has these fields:

| Field | Type | Required? | Description | Example |
|-------|------|-----------|-------------|---------|
| `name` | string | ✅ Required | Day name | "Day 1: Upper Body", "Lower Power" |
| `shortCode` | string | ⚪ Optional | Short identifier for day | "U1", "L1", "F1" |
| `goal` | string | ⚪ Optional | Training goal for this day | "strength", "hypertrophy", "conditioning" |
| `notes` | string | ⚪ Optional | Day-specific notes | "Focus on compound movements" |
| `exercises` | array | ✅ Required | Array of exercise objects | `[{...}, {...}]` |

### Exercise Fields - Simple Format (Legacy/Quick Blocks)

For simple blocks, each exercise in the `Exercises` array needs these fields:

| Field | Type | Required? | Description | Example |
|-------|------|-----------|-------------|---------|
| `name` | string | ✅ Required | Exercise name (will be added to library) | "Back Squat", "Bench Press" |
| `setsReps` | string | ⚪ Optional* | Sets × Reps format (supports 'x' or 'X') | "3x8", "4X10", "5x5" |
| `restSeconds` | integer | ⚪ Optional | Rest period between sets | `180` (3 min), `120` (2 min), `60` (1 min) |
| `intensityCue` | string | ⚪ Optional | Intensity guidance (free text) | "RPE 7", "RIR 3", "75% 1RM", "Tempo 3-0-1-0" |

**\*Note:** Use `setsReps` for simple format OR `sets` array for advanced format (see below).

### Exercise Fields - Advanced Format (Detailed Programming)

For advanced blocks with detailed set-by-set programming:

| Field | Type | Required? | Description | Example |
|-------|------|-----------|-------------|---------|
| `name` | string | ✅ Required | Exercise name | "Barbell Back Squat" |
| `type` | string | ⚪ Optional | Exercise type (defaults to "strength") | "strength", "conditioning", "mixed", "other" |
| `category` | string | ⚪ Optional | Movement category | "squat", "hinge", "pressHorizontal", "pressVertical", "pullHorizontal", "pullVertical", "carry", "core", "olympic", "conditioning", "mobility", "mixed", "other" |
| `setsReps` | string | ⚪ Optional* | Simple format (if not using `sets`) | "3x8" |
| `sets` | array | ⚪ Optional* | Advanced format (replaces `setsReps`) | See "Set Object" below |
| `conditioningType` | string | ⚪ Optional | Type of conditioning work | "monostructural", "mixedModal", "emom", "amrap", "intervals", "forTime", "forDistance", "forCalories", "roundsForTime", "other" |
| `conditioningSets` | array | ⚪ Optional | Conditioning-specific sets | See "Conditioning Set Object" below |
| `notes` | string | ⚪ Optional | Exercise-specific notes | "Focus on depth and control" |
| `setGroupId` | string | ⚪ Optional | UUID for grouping (supersets/circuits) | "550e8400-e29b-41d4-a716-446655440000" |
| `setGroupKind` | string | ⚪ Optional | Type of set grouping | "superset", "circuit", "giantSet", "emom", "amrap" |
| `progressionType` | string | ⚪ Optional | How to progress (defaults to "weight") | "weight", "volume", "custom" |
| `progressionDeltaWeight` | number | ⚪ Optional | Weight to add per week (lbs/kg) | `5.0`, `2.5`, `10.0` |
| `progressionDeltaSets` | integer | ⚪ Optional | Sets to add per week | `1` |

**\*Note:** Use either `setsReps` (simple) OR `sets` array (advanced).

### Set Object (for Advanced Format)

When using the `sets` array, each set object can have:

| Field | Type | Required? | Description | Example |
|-------|------|-----------|-------------|---------|
| `reps` | integer | ⚪ Optional | Target reps for this set | `8`, `10`, `5` |
| `weight` | number | ⚪ Optional | Weight in pounds or kg | `135.0`, `185.5`, `225.0` |
| `percentageOfMax` | number | ⚪ Optional | Percentage of 1RM (0.0-1.0) | `0.75` (75%), `0.80` (80%) |
| `rpe` | number | ⚪ Optional | Rate of Perceived Exertion (1.0-10.0) | `7.0`, `8.5`, `9.0` |
| `rir` | number | ⚪ Optional | Reps In Reserve (0.0-5.0+) | `2.0`, `3.0`, `1.5` |
| `tempo` | string | ⚪ Optional | Tempo prescription (eccentric-pause-concentric-pause) | "3-0-1-0", "2-1-X-1" |
| `restSeconds` | integer | ⚪ Optional | Rest after this set | `180`, `120`, `90` |
| `notes` | string | ⚪ Optional | Set-specific notes | "Focus on explosive concentric" |

### Conditioning Set Object

When using `conditioningSets` array for conditioning exercises:

| Field | Type | Required? | Description | Example |
|-------|------|-----------|-------------|---------|
| `durationSeconds` | integer | ⚪ Optional | Duration of work interval | `300` (5 min), `120` (2 min) |
| `distanceMeters` | number | ⚪ Optional | Target distance in meters | `1000.0`, `500.0`, `5000.0` |
| `calories` | number | ⚪ Optional | Target calories | `20.0`, `15.0`, `50.0` |
| `rounds` | integer | ⚪ Optional | Number of rounds | `5`, `3`, `10` |
| `targetPace` | string | ⚪ Optional | Target pace | "2:00/500m", "easy", "moderate" |
| `effortDescriptor` | string | ⚪ Optional | Effort level | "easy", "moderate", "hard", "all-out" |
| `restSeconds` | integer | ⚪ Optional | Rest after this interval | `60`, `120`, `90` |
| `notes` | string | ⚪ Optional | Set-specific notes | "Maintain steady pace" |

### Sets/Reps Format Examples

The `setsReps` field accepts various formats:
- Standard: `"3x8"` = 3 sets of 8 reps
- Alternative: `"4X10"` = 4 sets of 10 reps (uppercase X also works)
- High volume: `"5x12"` = 5 sets of 12 reps
- Low reps: `"5x3"` = 5 sets of 3 reps (strength focus)
- Single set: `"1x20"` = 1 set of 20 reps

### Intensity Cue Examples

The `intensityCue` field is flexible and supports various coaching methodologies:

**RPE (Rate of Perceived Exertion):**
- `"RPE 7"` = Leave 3 reps in reserve
- `"RPE 8.5"` = Leave 1-2 reps in reserve
- `"RPE 9"` = 1 rep in reserve

**RIR (Reps in Reserve):**
- `"RIR 2"` = Stop 2 reps before failure
- `"RIR 3"` = Stop 3 reps before failure

**Percentage-Based:**
- `"75% 1RM"` = 75% of one-rep max
- `"80% Training Max"` = 80% of training max
- `"85%"` = 85% of max

**Tempo:**
- `"Tempo 3-0-1-0"` = 3 sec eccentric, 0 pause, 1 sec concentric, 0 pause
- `"Tempo 2-1-X-1"` = 2 sec down, 1 sec pause, explosive up, 1 sec pause

**Descriptive:**
- `"Moderate weight, focus on form"`
- `"Heavy, leave 1-2 reps"`
- `"Light, explosive"`
- `"To failure"`

**Combined:**
- `"RPE 8, Tempo 3-0-1-0"`
- `"75% 1RM, RIR 2"`

## Advanced Examples

### Example 1: Multi-Week Block with Advanced Sets

This example shows how to specify exact weights, RPE, and tempo for each set:

```json
{
  "Title": "Strength Progression 8-Week",
  "Goal": "strength",
  "TargetAthlete": "Intermediate",
  "NumberOfWeeks": 8,
  "DurationMinutes": 60,
  "Difficulty": 4,
  "Equipment": "Barbell, Squat Rack, Bench, Plates",
  "WarmUp": "10 min dynamic warm-up, movement prep",
  "Exercises": [
    {
      "name": "Barbell Back Squat",
      "type": "strength",
      "category": "squat",
      "sets": [
        {
          "reps": 5,
          "weight": 185.0,
          "percentageOfMax": 0.75,
          "rpe": 7.5,
          "tempo": "3-0-1-0",
          "restSeconds": 240,
          "notes": "Focus on depth"
        },
        {
          "reps": 5,
          "weight": 205.0,
          "percentageOfMax": 0.80,
          "rpe": 8.0,
          "tempo": "3-0-1-0",
          "restSeconds": 240
        },
        {
          "reps": 5,
          "weight": 225.0,
          "percentageOfMax": 0.85,
          "rpe": 8.5,
          "tempo": "3-0-1-0",
          "restSeconds": 300,
          "notes": "Max effort"
        }
      ],
      "progressionType": "weight",
      "progressionDeltaWeight": 5.0,
      "notes": "Increase weight 5 lbs per week on top set"
    }
  ],
  "Finisher": "10 min stretching and mobility",
  "Notes": "Deload on week 4 and week 8",
  "EstimatedTotalTimeMinutes": 60,
  "Progression": "Linear progression: +5 lbs per week on main lifts"
}
```

### Example 2: Multi-Day Block (Upper/Lower Split)

This example demonstrates how to create a 4-day training split across multiple weeks:

```json
{
  "Title": "Upper/Lower Strength Split",
  "Goal": "strength",
  "TargetAthlete": "Advanced",
  "NumberOfWeeks": 12,
  "DurationMinutes": 75,
  "Difficulty": 5,
  "Equipment": "Full commercial gym",
  "WarmUp": "10 min cardio + dynamic stretching",
  "Days": [
    {
      "name": "Day 1: Upper Power",
      "shortCode": "U1",
      "goal": "power",
      "notes": "Focus on explosive movement",
      "exercises": [
        {
          "name": "Barbell Bench Press",
          "type": "strength",
          "category": "pressHorizontal",
          "sets": [
            {"reps": 5, "weight": 185, "rpe": 7.5, "restSeconds": 240},
            {"reps": 5, "weight": 205, "rpe": 8.0, "restSeconds": 240},
            {"reps": 5, "weight": 225, "rpe": 8.5, "restSeconds": 300}
          ],
          "progressionDeltaWeight": 5.0
        },
        {
          "name": "Barbell Row",
          "type": "strength",
          "category": "pullHorizontal",
          "setsReps": "4x6",
          "restSeconds": 180,
          "intensityCue": "RPE 8",
          "progressionDeltaWeight": 5.0
        }
      ]
    },
    {
      "name": "Day 2: Lower Power",
      "shortCode": "L1",
      "goal": "power",
      "exercises": [
        {
          "name": "Barbell Back Squat",
          "type": "strength",
          "category": "squat",
          "sets": [
            {"reps": 3, "weight": 275, "percentageOfMax": 0.80, "rpe": 8, "restSeconds": 300},
            {"reps": 3, "weight": 295, "percentageOfMax": 0.85, "rpe": 8.5, "restSeconds": 300}
          ],
          "progressionDeltaWeight": 10.0
        }
      ]
    },
    {
      "name": "Day 3: Upper Hypertrophy",
      "shortCode": "U2",
      "goal": "hypertrophy",
      "exercises": [
        {
          "name": "Dumbbell Incline Press",
          "type": "strength",
          "category": "pressHorizontal",
          "setsReps": "4x10",
          "restSeconds": 90,
          "intensityCue": "RPE 7.5",
          "progressionDeltaWeight": 2.5
        }
      ]
    },
    {
      "name": "Day 4: Lower Hypertrophy",
      "shortCode": "L2",
      "goal": "hypertrophy",
      "exercises": [
        {
          "name": "Romanian Deadlift",
          "type": "strength",
          "category": "hinge",
          "setsReps": "4x8",
          "restSeconds": 120,
          "intensityCue": "RPE 8",
          "progressionDeltaWeight": 5.0
        }
      ]
    }
  ],
  "Finisher": "Mobility work and foam rolling",
  "Notes": "Deload every 4th week. Track all lifts for progression.",
  "EstimatedTotalTimeMinutes": 75,
  "Progression": "Linear progression on compounds, wave loading on accessories"
}
```

### Example 3: Conditioning Block with Multiple Modalities

```json
{
  "Title": "Conditioning and Work Capacity",
  "Goal": "conditioning",
  "TargetAthlete": "Intermediate",
  "NumberOfWeeks": 6,
  "DurationMinutes": 45,
  "Difficulty": 4,
  "Equipment": "Rowing machine, Assault Bike, Jump Rope",
  "WarmUp": "5 min easy cardio + dynamic mobility",
  "Exercises": [
    {
      "name": "Rowing Machine Intervals",
      "type": "conditioning",
      "conditioningType": "intervals",
      "conditioningSets": [
        {
          "durationSeconds": 120,
          "distanceMeters": 500,
          "targetPace": "1:50/500m",
          "effortDescriptor": "hard",
          "restSeconds": 60,
          "notes": "Maintain consistent pace"
        },
        {
          "durationSeconds": 120,
          "distanceMeters": 500,
          "targetPace": "1:50/500m",
          "effortDescriptor": "hard",
          "restSeconds": 60
        },
        {
          "durationSeconds": 120,
          "distanceMeters": 500,
          "targetPace": "1:50/500m",
          "effortDescriptor": "hard",
          "restSeconds": 120
        }
      ]
    },
    {
      "name": "Assault Bike EMOM",
      "type": "conditioning",
      "conditioningType": "emom",
      "conditioningSets": [
        {
          "durationSeconds": 60,
          "calories": 15.0,
          "effortDescriptor": "moderate",
          "rounds": 10,
          "notes": "15 cal every minute on the minute for 10 min"
        }
      ]
    },
    {
      "name": "Jump Rope",
      "type": "conditioning",
      "conditioningType": "forTime",
      "conditioningSets": [
        {
          "durationSeconds": 180,
          "effortDescriptor": "easy",
          "notes": "Active recovery - easy pace"
        }
      ]
    }
  ],
  "Finisher": "5 min cooldown walk and stretching",
  "Notes": "Focus on pacing. Build work capacity over 6 weeks.",
  "EstimatedTotalTimeMinutes": 45,
  "Progression": "Increase calories by 1-2 per week, decrease rest by 10 sec"
}
```

### Example 4: Superset/Circuit Block

This example shows how to group exercises into supersets using `setGroupId`:

```json
{
  "Title": "Upper Body Superset Block",
  "Goal": "hypertrophy",
  "TargetAthlete": "Intermediate",
  "NumberOfWeeks": 4,
  "DurationMinutes": 50,
  "Difficulty": 3,
  "Equipment": "Dumbbells, Cables, Bench",
  "WarmUp": "5 min cardio + shoulder mobility",
  "Exercises": [
    {
      "name": "Dumbbell Bench Press",
      "type": "strength",
      "category": "pressHorizontal",
      "setGroupId": "550e8400-e29b-41d4-a716-446655440001",
      "setGroupKind": "superset",
      "setsReps": "4x10",
      "restSeconds": 0,
      "intensityCue": "RPE 8"
    },
    {
      "name": "Dumbbell Row",
      "type": "strength",
      "category": "pullHorizontal",
      "setGroupId": "550e8400-e29b-41d4-a716-446655440001",
      "setGroupKind": "superset",
      "setsReps": "4x10",
      "restSeconds": 120,
      "intensityCue": "RPE 8",
      "notes": "120 sec rest after completing the superset"
    },
    {
      "name": "Cable Lateral Raise",
      "type": "strength",
      "category": "pressVertical",
      "setGroupId": "550e8400-e29b-41d4-a716-446655440002",
      "setGroupKind": "superset",
      "setsReps": "3x15",
      "restSeconds": 0,
      "intensityCue": "RPE 7.5"
    },
    {
      "name": "Cable Face Pull",
      "type": "strength",
      "category": "pullHorizontal",
      "setGroupId": "550e8400-e29b-41d4-a716-446655440002",
      "setGroupKind": "superset",
      "setsReps": "3x15",
      "restSeconds": 90,
      "intensityCue": "RPE 7.5"
    }
  ],
  "Finisher": "Arm pump: 3 sets bicep curls + tricep extensions",
  "Notes": "Pair antagonist muscle groups for efficiency",
  "EstimatedTotalTimeMinutes": 50,
  "Progression": "Add 1-2 reps per week, increase weight when hitting 12+ reps"
}
```

### Example 5: Powerlifting Block with RPE Progression

```json
{
  "Title": "Powerlifting Strength Block",
  "Goal": "Increase 1RM on squat, bench, deadlift",
  "TargetAthlete": "Advanced",
  "DurationMinutes": 75,
  "Difficulty": 5,
  "Equipment": "Barbell, Plates, Squat Rack, Bench, Deadlift Platform",
  "WarmUp": "10 min: light cardio, dynamic stretching, empty bar movement prep",
  "Exercises": [
    {
      "name": "Competition Squat",
      "setsReps": "5x3",
      "restSeconds": 300,
      "intensityCue": "RPE 8.5"
    },
    {
      "name": "Paused Bench Press",
      "setsReps": "4x5",
      "restSeconds": 240,
      "intensityCue": "RPE 8, 2 sec pause"
    },
    {
      "name": "Romanian Deadlift",
      "setsReps": "3x8",
      "restSeconds": 180,
      "intensityCue": "RPE 7, controlled eccentric"
    },
    {
      "name": "Barbell Row",
      "setsReps": "4x8",
      "restSeconds": 120,
      "intensityCue": "RPE 7.5"
    },
    {
      "name": "Core: Plank Hold",
      "setsReps": "3x1",
      "restSeconds": 90,
      "intensityCue": "60 seconds max effort"
    }
  ],
  "Finisher": "Mobility: hip flexors, thoracic spine, shoulders (10 min)",
  "Notes": "Week 1-3: Build to RPE 8.5. Week 4: Deload at RPE 6-7. Track all lifts for progression.",
  "EstimatedTotalTimeMinutes": 75,
  "Progression": "Weeks 1-3: Increase weight 5-10 lbs when RPE feels manageable. Week 4: Reduce weight 20% for deload."
}
```

### Example 2: Bodybuilding Hypertrophy Block

```json
{
  "Title": "Upper Body Hypertrophy - Push Focus",
  "Goal": "Maximize chest, shoulders, and triceps hypertrophy",
  "TargetAthlete": "Intermediate",
  "DurationMinutes": 60,
  "Difficulty": 4,
  "Equipment": "Dumbbells, Barbell, Cable Station, Bench",
  "WarmUp": "5 min cardio, rotator cuff warm-up, band pull-aparts 2x20",
  "Exercises": [
    {
      "name": "Barbell Bench Press",
      "setsReps": "4x8",
      "restSeconds": 150,
      "intensityCue": "RPE 8, Tempo 3-0-1-0"
    },
    {
      "name": "Incline Dumbbell Press",
      "setsReps": "4x10",
      "restSeconds": 120,
      "intensityCue": "RPE 8, full ROM"
    },
    {
      "name": "Dumbbell Shoulder Press",
      "setsReps": "3x12",
      "restSeconds": 90,
      "intensityCue": "RPE 7.5"
    },
    {
      "name": "Cable Lateral Raise",
      "setsReps": "3x15",
      "restSeconds": 60,
      "intensityCue": "RPE 8, constant tension"
    },
    {
      "name": "Tricep Rope Pushdown",
      "setsReps": "3x15",
      "restSeconds": 60,
      "intensityCue": "RPE 8"
    },
    {
      "name": "Cable Chest Fly",
      "setsReps": "3x12",
      "restSeconds": 60,
      "intensityCue": "RPE 7, squeeze at contraction"
    }
  ],
  "Finisher": "Burnout set: push-ups to failure, then 5 min stretch",
  "Notes": "Focus on mind-muscle connection. Control the eccentric. Progressive overload by adding 2.5-5 lbs or 1-2 reps per week.",
  "EstimatedTotalTimeMinutes": 60,
  "Progression": "Week 1: Baseline. Week 2-4: Add reps (up to 12/14/17). Week 5+: Add weight, reset reps."
}
```

### Example 3: Functional Fitness / CrossFit Style

```json
{
  "Title": "Mixed Modal Conditioning",
  "Goal": "Improve work capacity and conditioning across multiple time domains",
  "TargetAthlete": "Intermediate",
  "DurationMinutes": 40,
  "Difficulty": 4,
  "Equipment": "Barbell, Dumbbells, Jump Rope, Pull-up Bar, Assault Bike",
  "WarmUp": "3 rounds: 10 air squats, 5 push-ups, 5 ring rows, 30 sec jump rope",
  "Exercises": [
    {
      "name": "Thruster",
      "setsReps": "5x5",
      "restSeconds": 120,
      "intensityCue": "Moderate weight, fast and explosive"
    },
    {
      "name": "Pull-ups",
      "setsReps": "5x8",
      "restSeconds": 90,
      "intensityCue": "Strict or banded, full range"
    },
    {
      "name": "AMRAP 8 min: 10 Dumbbell Snatches, 10 Box Jumps, 10 Burpees",
      "setsReps": "1x1",
      "restSeconds": 0,
      "intensityCue": "As many rounds as possible, moderate pace"
    }
  ],
  "Finisher": "4 min EMOM: 15/12 cal Assault Bike",
  "Notes": "Scale movements as needed. Focus on consistent pacing. Track rounds completed in AMRAP for future sessions.",
  "EstimatedTotalTimeMinutes": 40,
  "Progression": "Increase thruster weight by 5-10 lbs per week. Add 1-2 reps to pull-ups. Aim for +1 round in AMRAP."
}
```

### Example 4: Minimalist Home Workout

```json
{
  "Title": "Home Strength & Conditioning",
  "Goal": "Maintain strength and fitness with minimal equipment",
  "TargetAthlete": "Beginner to Intermediate",
  "DurationMinutes": 35,
  "Difficulty": 2,
  "Equipment": "Single pair of dumbbells (20-35 lbs), resistance band",
  "WarmUp": "5 min: jumping jacks, arm circles, bodyweight squats, world's greatest stretch x 5",
  "Exercises": [
    {
      "name": "Goblet Squat",
      "setsReps": "4x12",
      "restSeconds": 90,
      "intensityCue": "RPE 7, pause at bottom"
    },
    {
      "name": "Push-up",
      "setsReps": "4x15",
      "restSeconds": 60,
      "intensityCue": "Modify on knees if needed, RPE 7"
    },
    {
      "name": "Dumbbell Row",
      "setsReps": "4x10",
      "restSeconds": 60,
      "intensityCue": "Each arm, RPE 7"
    },
    {
      "name": "Dumbbell Overhead Press",
      "setsReps": "3x12",
      "restSeconds": 75,
      "intensityCue": "RPE 7, strict form"
    },
    {
      "name": "Band Pull-apart",
      "setsReps": "3x20",
      "restSeconds": 45,
      "intensityCue": "Controlled tempo, squeeze shoulder blades"
    },
    {
      "name": "Plank Hold",
      "setsReps": "3x1",
      "restSeconds": 60,
      "intensityCue": "45-60 seconds, maintain neutral spine"
    }
  ],
  "Finisher": "5 min cooldown: stretching major muscle groups, focus on hips and shoulders",
  "Notes": "Excellent for travel or home training. Can be done 3-4x per week. Adjust dumbbell weight as needed.",
  "EstimatedTotalTimeMinutes": 35,
  "Progression": "Add 1-2 reps per week. When you can do all sets at top of range, increase dumbbell weight by 5 lbs."
}
```

## Generating JSON with AI

### Quick Copy Template

Copy and paste this complete template into your AI assistant (ChatGPT, Claude, etc.), then add your specific requirements:

```
I need you to generate a workout block in JSON format for the Savage By Design workout tracker app.

IMPORTANT - JSON Format Specification:
- The file MUST be valid JSON with proper syntax (commas, quotes, brackets)
- Most fields are REQUIRED unless marked as [OPTIONAL]
- Save as a .json file: [BlockName]_[Weeks]W_[Days]D.json
- Example: UpperLower_4W_4D.json or Strength_8W_3D.json

COMPLETE JSON Structure (ALL AVAILABLE FIELDS):

For SIMPLE single-day blocks, use this format:
{
  "Title": "Block name (under 50 characters)",
  "Goal": "strength|hypertrophy|power|conditioning|mixed|peaking|deload|rehab",
  "TargetAthlete": "Beginner|Intermediate|Advanced",
  "NumberOfWeeks": <number> [OPTIONAL, defaults to 1],
  "DurationMinutes": <number: workout duration>,
  "Difficulty": <number: 1-5>,
  "Equipment": "Comma-separated list",
  "WarmUp": "Warm-up instructions",
  "Exercises": [
    {
      "name": "Exercise name",
      "setsReps": "3x8",
      "restSeconds": 120,
      "intensityCue": "RPE 7"
    }
  ],
  "Finisher": "Cooldown instructions",
  "Notes": "Important context",
  "EstimatedTotalTimeMinutes": <number>,
  "Progression": "Week-to-week strategy"
}

For ADVANCED blocks with detailed programming:
{
  "Title": "Block name",
  "Goal": "strength",
  "TargetAthlete": "Advanced",
  "NumberOfWeeks": 8,
  "DurationMinutes": 60,
  "Difficulty": 4,
  "Equipment": "Full gym",
  "WarmUp": "10 min prep",
  "Exercises": [
    {
      "name": "Barbell Back Squat",
      "type": "strength" [OPTIONAL],
      "category": "squat" [OPTIONAL],
      "sets": [
        {
          "reps": 5,
          "weight": 225.0 [OPTIONAL - specify weights when known],
          "percentageOfMax": 0.80 [OPTIONAL - 0.0 to 1.0],
          "rpe": 8.0 [OPTIONAL],
          "rir": 2.0 [OPTIONAL],
          "tempo": "3-0-1-0" [OPTIONAL],
          "restSeconds": 240,
          "notes": "Focus on depth" [OPTIONAL]
        }
      ],
      "progressionType": "weight" [OPTIONAL],
      "progressionDeltaWeight": 5.0 [OPTIONAL],
      "notes": "Exercise notes" [OPTIONAL]
    }
  ],
  "Finisher": "Cooldown",
  "Notes": "Block notes",
  "EstimatedTotalTimeMinutes": 60,
  "Progression": "Linear progression"
}

For MULTI-DAY blocks (e.g., Upper/Lower splits):
{
  "Title": "Upper/Lower Split",
  "Goal": "strength",
  "TargetAthlete": "Intermediate",
  "NumberOfWeeks": 12,
  "DurationMinutes": 60,
  "Difficulty": 4,
  "Equipment": "Full gym",
  "WarmUp": "10 min warm-up",
  "Days": [
    {
      "name": "Day 1: Upper Body",
      "shortCode": "U1" [OPTIONAL],
      "goal": "strength" [OPTIONAL],
      "notes": "Focus on compounds" [OPTIONAL],
      "exercises": [
        {
          "name": "Bench Press",
          "setsReps": "5x5",
          "restSeconds": 240,
          "intensityCue": "RPE 8",
          "progressionDeltaWeight": 5.0
        }
      ]
    },
    {
      "name": "Day 2: Lower Body",
      "shortCode": "L1",
      "exercises": [
        {
          "name": "Back Squat",
          "setsReps": "5x5",
          "restSeconds": 300,
          "intensityCue": "RPE 8"
        }
      ]
    }
  ],
  "Finisher": "Mobility",
  "Notes": "Progressive overload",
  "EstimatedTotalTimeMinutes": 60,
  "Progression": "Add 5-10 lbs weekly"
}

For CONDITIONING exercises:
{
  "Title": "Conditioning Block",
  "Goal": "conditioning",
  "TargetAthlete": "Intermediate",
  "NumberOfWeeks": 6,
  "DurationMinutes": 40,
  "Difficulty": 3,
  "Equipment": "Rowing machine, Assault Bike",
  "WarmUp": "5 min easy cardio",
  "Exercises": [
    {
      "name": "Rowing Intervals",
      "type": "conditioning",
      "conditioningType": "intervals",
      "conditioningSets": [
        {
          "durationSeconds": 120,
          "distanceMeters": 500,
          "targetPace": "1:50/500m",
          "effortDescriptor": "hard",
          "restSeconds": 60
        }
      ]
    }
  ],
  "Finisher": "Cooldown walk",
  "Notes": "Build work capacity",
  "EstimatedTotalTimeMinutes": 40,
  "Progression": "Decrease rest, increase pace"
}

For SUPERSETS (group exercises with same setGroupId):
{
  ...
  "Exercises": [
    {
      "name": "Bench Press",
      "setGroupId": "550e8400-e29b-41d4-a716-446655440001",
      "setGroupKind": "superset",
      "setsReps": "4x8",
      "restSeconds": 0
    },
    {
      "name": "Barbell Row",
      "setGroupId": "550e8400-e29b-41d4-a716-446655440001",
      "setGroupKind": "superset",
      "setsReps": "4x8",
      "restSeconds": 120
    }
  ]
  ...
}

USAGE GUIDELINES:
1. For SIMPLE blocks: Use "Exercises" with "setsReps"
2. For ADVANCED blocks: Use "sets" array with detailed parameters
3. For MULTI-WEEK: Set "NumberOfWeeks" (e.g., 4, 8, 12)
4. For MULTI-DAY: Use "Days" array instead of "Exercises"
5. For CONDITIONING: Set type="conditioning" and use "conditioningSets"
6. For SUPERSETS: Give exercises same "setGroupId" UUID
7. SPECIFY WEIGHTS when known - helps with progression tracking

See complete field reference in app documentation for all available options.

MY REQUIREMENTS:
[Describe your training goals, experience level, available equipment, time constraints, weeks, days, and specific exercises you want]
```

### Example AI Prompts

**For Multi-Week, Multi-Day Strength Block:**
```
I need you to generate a workout block in JSON format for the Savage By Design workout tracker app.

[paste the template above]

MY REQUIREMENTS:
Create an 8-week upper/lower split for an intermediate lifter.
- NumberOfWeeks: 8
- 4 days per week (2 upper, 2 lower) - use "Days" array
- Goal: Build overall strength
- 75 minutes per session
- Equipment: Full commercial gym (barbells, dumbbells, machines, cables)
- Include main compound lifts with specific weights, RPE, and tempo
- Specify weight for each set (start at 70-85% range)
- Use "sets" array format with detailed parameters
- Progression: Add 5-10 lbs per week on main lifts, deload week 4 and 8
- Include progressionDeltaWeight for each exercise

Generate all 4 days with complete exercise details.
```

**For Advanced Powerlifting Block with Percentage-Based Loading:**
```
I need you to generate a workout block in JSON format for the Savage By Design workout tracker app.

[paste the template above]

MY REQUIREMENTS:
Create a 12-week powerlifting peaking block for an advanced lifter.
- NumberOfWeeks: 12
- Single-day format focused on squat, bench, deadlift
- Goal: peaking
- 90 minutes per session
- Equipment: Power rack, barbell, bench, platform
- Use "sets" array with percentageOfMax, weight, rpe, and tempo
- Week 1-4: Volume phase (70-80% intensity)
- Week 5-8: Intensity phase (80-90% intensity)
- Week 9-11: Peaking phase (90-95% intensity)
- Week 12: Deload
- Include specific weights based on 1RM: Squat 405, Bench 315, Dead 500
```

**For Conditioning Block with Multiple Modalities:**
```
I need you to generate a workout block in JSON format for the Savage By Design workout tracker app.

[paste the template above]

MY REQUIREMENTS:
Create a 6-week conditioning block for CrossFit-style training.
- NumberOfWeeks: 6
- Goal: conditioning
- 45 minutes per session
- Equipment: Rowing machine, Assault Bike, Jump Rope, Dumbbells
- Use type="conditioning" for exercises
- Include "conditioningSets" with durationSeconds, distanceMeters, calories
- Mix of: rowing intervals, bike EMOM, AMRAP circuits
- Specify targetPace and effortDescriptor for each interval
- Progression: Increase work, decrease rest weekly
```

**For Superset/Circuit Block:**
```
I need you to generate a workout block in JSON format for the Savage By Design workout tracker app.

[paste the template above]

MY REQUIREMENTS:
Create a 4-week upper body hypertrophy block using supersets.
- NumberOfWeeks: 4
- Goal: hypertrophy
- 50 minutes per session
- Equipment: Dumbbells, cables, machines
- Pair antagonist muscle groups (push/pull) in supersets
- Use setGroupId to group exercises (same UUID for paired exercises)
- Use setGroupKind: "superset"
- 4 supersets total (8 exercises)
- First exercise in pair: restSeconds: 0
- Second exercise in pair: restSeconds: 90-120
- Include progressionDeltaWeight: 2.5 for dumbbells

Generate complete superset pairs with matching setGroupId values.
```

### Tips for Best AI Results

1. **Be Specific About Structure**: 
   - Specify number of weeks: "NumberOfWeeks: 8"
   - For multi-day: "Use Days array with 4 days"
   - For single-day: "Use Exercises array"
   - Mention if you want detailed set-by-set programming

2. **Request Detailed Fields When Needed**:
   - "Include specific weights for each set"
   - "Use sets array with weight, rpe, and tempo for each set"
   - "Specify percentageOfMax based on these 1RMs: Squat 315, Bench 225"
   - "Include progressionDeltaWeight for each exercise"

3. **For Multi-Week Blocks**:
   - Clearly state: "NumberOfWeeks: 12"
   - Describe progression: "Linear progression weeks 1-8, deload weeks 4 and 8, peak weeks 9-12"
   - AI will generate the template; app auto-generates sessions for all weeks

4. **For Conditioning Work**:
   - Specify: "type: conditioning"
   - Request: "Use conditioningSets with durationSeconds and distanceMeters"
   - Include: "targetPace and effortDescriptor for each interval"

5. **For Supersets/Circuits**:
   - Request: "Group exercises using setGroupId"
   - Specify: "Create 4 superset pairs with matching UUIDs"
   - Note: "First exercise restSeconds: 0, second exercise restSeconds: 120"

6. **Be Specific About Experience & Equipment**:
   - State your experience level clearly
   - List exact equipment available
   - Specify rep ranges you prefer
   - Mention any limitations (injuries, time, etc.)

7. **Request Iterations**: If the first output isn't perfect:
   ```
   This is good, but please:
   - Reduce rest times to 60-90 seconds
   - Add more accessory work for shoulders
   - Include tempo prescriptions for all exercises
   ```

3. **Validate Before Import**: 
   - Check JSON syntax at [jsonlint.com](https://jsonlint.com)
   - Verify all required fields are present
   - Ensure numbers are not in quotes
   - Confirm exercise names are specific and clear

4. **Multi-Day Blocks**: For programs with multiple days:
   ```
   Generate 3 separate JSON files:
   - Day 1: Upper Body Push
   - Day 2: Lower Body Squat Focus  
   - Day 3: Upper Body Pull
   
   I'll import each as a separate block.
   ```

5. **Save and Organize**: 
   - Name files descriptively: `Bench_Specialization_4W.json`
   - Keep a folder of your generated programs
   - Document which AI and prompt you used (for future reference)

## Troubleshooting Guide

### Common Errors and Solutions

#### "Invalid JSON format"
**Problem:** The JSON file has syntax errors

**Solutions:**
- Validate syntax at [jsonlint.com](https://jsonlint.com) - paste your JSON and click "Validate"
- Check for missing commas between fields
- Verify all strings are in double quotes (not single quotes)
- Ensure all brackets/braces are properly closed: `[]` for arrays, `{}` for objects
- Remove trailing commas (e.g., `"field": "value",}` should be `"field": "value"}`)

**Example of common errors:**
```json
{
  "Title": "My Block"    // ❌ Missing comma
  "Goal": "Strength",    // ✅ This line is correct
  "Exercises": [
    {
      "name": "Squat",   // ✅ Correct
    }                    // ❌ Trailing comma before closing bracket
  ]
}
```

#### "Missing required field: [field name]"
**Problem:** One or more required fields are not in your JSON

**Solutions:**
- Cross-reference your JSON with the complete field list above
- All 12 block-level fields must be present
- All 4 exercise fields must be present for each exercise
- Field names are case-sensitive: `"Title"` ✅ vs `"title"` ❌

**Quick checklist:**
```
Block fields:
☐ Title
☐ Goal
☐ TargetAthlete
☐ DurationMinutes
☐ Difficulty
☐ Equipment
☐ WarmUp
☐ Exercises
☐ Finisher
☐ Notes
☐ EstimatedTotalTimeMinutes
☐ Progression

Exercise fields (for each exercise):
☐ name
☐ setsReps
☐ restSeconds
☐ intensityCue
```

#### "Type mismatch" or "Expected number, got string"
**Problem:** Wrong data type for a field

**Solutions:**
- Numbers should NOT be in quotes: `"DurationMinutes": 45` ✅ vs `"DurationMinutes": "45"` ❌
- Strings MUST be in quotes: `"Title": "My Block"` ✅ vs `"Title": My Block` ❌
- Difficulty must be 1-5 (integer)
- All time values are integers (no decimals)

**Correct types:**
```json
{
  "Title": "String value",              // ✅ String
  "DurationMinutes": 45,                // ✅ Number (no quotes)
  "Difficulty": 3,                      // ✅ Number 1-5
  "Exercises": [...]                    // ✅ Array
}
```

#### "Invalid sets/reps format"
**Problem:** The `setsReps` field doesn't match expected pattern

**Solutions:**
- Use format: `"3x8"` or `"4X10"` (both 'x' and 'X' work)
- Must be: `[number]x[number]`
- Examples: `"3x8"` ✅, `"5x5"` ✅, `"4X12"` ✅
- Invalid: `"3 x 8"` ❌, `"3*8"` ❌, `"three x 8"` ❌

#### File Won't Import
**Problem:** File picker doesn't show the file or import fails

**Solutions:**
- File MUST have `.json` extension (not `.txt`, `.doc`, etc.)
- Rename file if needed: `myworkout.txt` → `myworkout.json`
- Re-save with UTF-8 encoding (most text editors do this by default)
- Try moving file to a different location (Downloads, iCloud Drive, etc.)
- File size should be reasonable (< 1 MB for workout data)

#### App Crashes or Freezes
**Problem:** App becomes unresponsive during import

**Solutions:**
- Check JSON file size (should be small, typically < 100 KB)
- Ensure you don't have thousands of exercises in one file
- Restart the app and try again
- Simplify the JSON (reduce number of exercises) to test

### Still Having Issues?

If you continue to have problems:

1. **Start with a minimal example** - Use the "Simple Example" from above and verify it imports successfully
2. **Add complexity gradually** - Once basic import works, add your custom exercises one at a time
3. **Use JSON validation tools** - Always validate at [jsonlint.com](https://jsonlint.com) before importing
4. **Check AI output** - Sometimes AI assistants generate invalid JSON; always review and validate

## What Gets Created When You Import

When you import a JSON file, the app automatically creates:

1. **Block Template** - The master training block with metadata
2. **Day Template** - A single day structure with all exercises
3. **Exercise Templates** - Individual exercises with set/rep schemes
4. **Workout Sessions** - Actual workout instances you'll log during training
5. **Progression Rules** - Automatic weekly progression based on your JSON specs

All imported blocks are tagged with `source: .ai` so you can track AI-generated vs manually created blocks.

## Features

✅ **Universal AI Support** - Works with ChatGPT, Claude, Gemini, Perplexity, and any AI assistant  
✅ **Flexible Intensity Methods** - RPE, RIR, percentage-based, tempo, and custom cues  
✅ **Automatic Progression** - Generates all weeks with progression built in  
✅ **Exercise Library Integration** - Adds custom exercises to your library automatically  
✅ **Preview Before Save** - Review all details before committing  
✅ **Detailed Error Messages** - Clear feedback if something goes wrong  
✅ **Dark/Light Mode** - Seamless UI across system themes  
✅ **Session Generation** - Creates workout logs ready to track  

## Best Practices

### DO's ✅

- ✅ **Validate JSON syntax** at [jsonlint.com](https://jsonlint.com) before importing
- ✅ **Use descriptive file names** with block name and duration
- ✅ **Save your JSON files** in a dedicated folder for future reference
- ✅ **Start simple** - Test with 2-3 exercises before creating complex blocks
- ✅ **Include specific exercise names** - "Barbell Back Squat" not just "Squat"
- ✅ **Specify equipment clearly** - Helps with future workout planning
- ✅ **Add progression details** - Clear week-to-week strategy in Notes
- ✅ **Use consistent intensity methods** - Pick RPE or RIR and stick with it

### DON'Ts ❌

- ❌ **Don't use ambiguous exercise names** - "Press" could mean 10 different exercises
- ❌ **Don't mix up numbers and strings** - 45 vs "45" matters in JSON
- ❌ **Don't forget warm-up/cooldown** - These fields are required even if brief
- ❌ **Don't make duration unrealistic** - Be honest about actual workout time
- ❌ **Don't skip the Notes field** - Use it for important context and safety cues
- ❌ **Don't use special characters in Title** - Keep it alphanumeric + spaces

### File Organization Tips

Create a folder structure for your workout JSONs:
```
Workout_JSONs/
├── Strength/
│   ├── Powerlifting_4W.json
│   └── Upper_Lower_8W.json
├── Conditioning/
│   ├── HIIT_Cardio_6W.json
│   └── Mixed_Modal_4W.json
├── Hypertrophy/
│   ├── Push_Pull_Legs_8W.json
│   └── Bodybuilding_Split_12W.json
└── Sport_Specific/
    ├── MMA_Conditioning_6W.json
    └── Basketball_Strength_8W.json
```

## Use Cases & Applications

### Strength & Powerlifting
- Linear progression programs (5x5, 5/3/1 style)
- Powerlifting peaking blocks
- Olympic lifting programs
- Strength foundation building

### Hypertrophy & Bodybuilding
- Classic body part splits (chest/back/legs/shoulders/arms)
- Push/Pull/Legs routines
- Upper/Lower splits
- Volume accumulation blocks

### Athletic Performance
- Sport-specific strength programs
- Power development blocks
- Speed and agility work
- Functional fitness programming

### Conditioning & Metcons
- CrossFit-style WODs
- HIIT protocols
- Circuit training
- Cardiovascular endurance work

### Specialized Training
- Rehabilitation and return-to-training
- Pre-season strength building
- In-season maintenance programs
- Post-season recovery blocks
- Travel/hotel room workouts with minimal equipment

## Technical Implementation Details

**For Developers & Advanced Users:**

- **Parser**: Swift JSONDecoder with custom error handling
- **Set Format**: Regex pattern `\\d+[xX]\\d+` (flexible case)
- **Model Mapping**: ImportedBlock DTO → Block domain model
- **Session Factory**: Automatically generates WorkoutSession instances for each week
- **Progression**: Applied via ProgressionRule (currently weight-based, 5 lbs default)
- **Exercise Creation**: Custom exercises auto-added to ExerciseLibraryRepository
- **Type Safety**: All models conform to Codable, Equatable, Identifiable
- **Source Tracking**: Blocks marked with `.ai` source for filtering/analytics

**Current Limitations:**
- Single day per JSON (multi-day blocks require multiple imports)
- Strength exercises only (conditioning exercises parsed but not fully utilized)
- No superset/circuit grouping in JSON (exercises are sequential)
- Fixed progression rule (weight-based)

**Planned Enhancements:**
- Multi-day block support in single JSON
- Conditioning exercise set templates (time/distance/calories/rounds)
- Superset/circuit grouping with `setGroupId`
- Custom progression parameters per exercise
- Block sharing and template marketplace

## Version History

**Version 1.0** (December 2024)
- Initial release
- Basic JSON import for strength exercises
- Single-day block support
- Simple sets/reps parsing
- RPE intensity cues

**Version 1.1** (December 2024)
- Enhanced error messages
- JSON validation improvements
- UI/UX refinements
- Documentation expansion

---

**Last Updated:** December 17, 2024  
**App Version Compatibility:** iOS 17.0+  
**Documentation Version:** 1.1

# AI Prompt Examples for Week-Specific Blocks

## Introduction

This document provides copy-paste AI prompts for generating training blocks with week-specific exercise variations. Use these with ChatGPT, Claude, or any AI assistant to generate properly formatted JSON blocks.

**⚠️ Important Disclaimer**: AI-generated content should always be validated before use. AI assistants may not always follow the exact format requested, may generate invalid JSON syntax, or may produce training programs that are not appropriate for your fitness level or goals. Always review and test generated JSON before importing, and consult with a qualified fitness professional before starting any new training program.

## Basic Week-Specific Prompt Template

```
Generate a workout block in JSON format for Savage By Design app.

Block Requirements:
- Name: [Your block name]
- Weeks: [Number of weeks]
- Goal: [strength/hypertrophy/power/conditioning]
- Target: [Beginner/Intermediate/Advanced]

Week-by-Week Exercise Plan:
Week 1: [List exercises]
Week 2: [List exercises]
Week 3: [List exercises]
[etc...]

IMPORTANT: Use the "Weeks" field in JSON format to specify different exercises for each week.

JSON Format:
{
  "Title": "[Block name]",
  "Goal": "[goal]",
  "TargetAthlete": "[level]",
  "NumberOfWeeks": [X],
  "DurationMinutes": [X],
  "Difficulty": [1-5],
  "Equipment": "[equipment list]",
  "WarmUp": "[warm-up description]",
  "Weeks": [
    [
      {
        "name": "Day 1: [description]",
        "exercises": [
          {"name": "[exercise]", "setsReps": "[XxY]", "intensityCue": "[cue]"}
        ]
      }
    ],
    [
      {
        "name": "Day 1: [description]",
        "exercises": [
          {"name": "[different exercise]", "setsReps": "[XxY]", "intensityCue": "[cue]"}
        ]
      }
    ]
  ],
  "Finisher": "[finisher description]",
  "Notes": "[important notes]",
  "EstimatedTotalTimeMinutes": [X],
  "Progression": "[progression strategy]"
}

Generate the complete JSON following this structure with all weeks specified.
```

## Example Prompt 1: Squat Variation Block

```
Generate a 12-week squat periodization block in JSON format for Savage By Design app.

Block Requirements:
- Name: "12-Week Squat Cycle"
- Goal: strength
- Target: Advanced lifter
- Equipment: Full gym with barbell, squat rack, specialty bars

Week-by-Week Exercise Plan:
Weeks 1-3: Back Squat accumulation (5x5, 5x4, 5x3)
Week 4: Deload with Pause Squat (3x5)
Weeks 5-7: Front Squat volume phase (4x8, 4x6, 4x5)
Week 8: Deload with Goblet Squat (3x10)
Weeks 9-11: Back Squat peaking (3x3, 3x2, 3x1)
Week 12: Recovery with Box Squat (3x5)

IMPORTANT: Use the "Weeks" field in JSON to specify different exercises for each week.
Include RPE targets for each exercise.
Save as: SquatCycle_12W_1D.json
```

## Example Prompt 2: Upper/Lower with Deloads

```
Generate an 8-week upper/lower split with deload weeks in JSON format.

Block Requirements:
- Name: "8-Week Upper/Lower with Variations"
- Goal: hypertrophy
- Target: Intermediate
- Equipment: Full gym

Week-by-Week Exercise Plan:

Weeks 1-3 (Build Phase):
- Upper: Barbell Bench Press, Barbell Row, Overhead Press
- Lower: Back Squat, Romanian Deadlift, Leg Press

Week 4 (Deload):
- Upper: Dumbbell Bench Press (lighter), Cable Rows
- Lower: Goblet Squat, Single-leg RDL

Weeks 5-7 (Intensification):
- Upper: Incline Barbell Bench, Chest-Supported Row, Push Press
- Lower: Front Squat, Conventional Deadlift, Walking Lunges

Week 8 (Recovery):
- Upper: Machine Press, Lat Pulldown, Cable Raises
- Lower: Leg Press, Hamstring Curl, Calf Raises

Use the "Weeks" field to specify different exercises for each week.
Include sets, reps, and RPE for each exercise.
Save as: UpperLower_8W_2D.json
```

## Example Prompt 3: Conjugate Method Block

```
Generate a 4-week conjugate method block with rotating max effort exercises.

Block Requirements:
- Name: "Conjugate Method - 4 Week Wave"
- Goal: strength
- Target: Advanced powerlifter
- Equipment: Full powerlifting gym with specialty bars and bands

Week-by-Week Exercise Plan:

Week 1:
- Max Effort Lower: Box Squat (work up to 1RM)
- Max Effort Upper: Floor Press (work up to 3RM)
- Dynamic Effort Lower: Speed Deadlifts (8x1)
- Dynamic Effort Upper: Speed Bench (8x3)

Week 2:
- Max Effort Lower: Deadlift Against Bands (work up to 1RM)
- Max Effort Upper: 2-Board Press (work up to 1RM)
- Dynamic Effort Lower: Speed Squats (10x2)
- Dynamic Effort Upper: Speed Bench with Chains (8x3)

Week 3:
- Max Effort Lower: Safety Squat Bar Squat (work up to 3RM)
- Max Effort Upper: Close-Grip Bench (work up to 3RM)
- Dynamic Effort Lower: Box Squat (12x2)
- Dynamic Effort Upper: Speed Bench Cambered Bar (8x3)

Week 4:
- Max Effort Lower: Rack Pulls (work up to 1RM)
- Max Effort Upper: Incline Bench Press (work up to 3RM)
- Dynamic Effort Lower: Speed Deadlifts with Chains (8x1)
- Dynamic Effort Upper: Speed Bench (8x3)

Use "Weeks" field with 4 weeks of different exercises.
Each week should have 4 days.
Include intensity prescriptions (work up to XRM, % 1RM).
Save as: Conjugate_4W_4D.json
```

## Example Prompt 4: Beginner Progression Block

```
Generate a 6-week beginner progression block with exercise advancement.

Block Requirements:
- Name: "6-Week Beginner Progression"
- Goal: mixed (strength and technique)
- Target: Beginner
- Equipment: Basic gym with dumbbells, barbells, machines

Week-by-Week Exercise Plan:

Weeks 1-2 (Machine Focus):
- Machine Chest Press, Machine Row, Leg Press, Leg Curl

Weeks 3-4 (Dumbbell Introduction):
- Dumbbell Bench Press, Dumbbell Row, Goblet Squat, Dumbbell RDL

Weeks 5-6 (Barbell Introduction):
- Barbell Bench Press, Barbell Row, Back Squat, Romanian Deadlift

Progress from machines to free weights over 6 weeks.
Start with 3x10-12 reps, progress to 3x8-10 by week 6.
Use "Weeks" field to show exercise progression.
Include form cues and safety notes.
Save as: BeginnerProgression_6W_1D.json
```

## Example Prompt 5: Conditioning Block with Variations

```
Generate an 8-week conditioning block with different modalities each week.

Block Requirements:
- Name: "8-Week Conditioning Variations"
- Goal: conditioning
- Target: Intermediate
- Equipment: Rowing machine, assault bike, treadmill, jump rope

Week-by-Week Exercise Plan:

Week 1: Rowing Intervals (500m x 6, 2min rest)
Week 2: Assault Bike EMOM (15 cal per minute x 10)
Week 3: Treadmill Hill Sprints (30 sec sprint, 90 sec walk x 10)
Week 4: Jump Rope (3 min on, 1 min off x 5)
Week 5: Rowing + Bike Mix (250m row, 10 cal bike x 8)
Week 6: Treadmill HIIT (60 sec sprint, 60 sec walk x 12)
Week 7: Complex Circuit (row 200m, 20 air squats, 10 burpees x 5)
Week 8: Active Recovery (easy rowing 20 min)

Use "Weeks" field with conditioning-specific parameters.
Include duration, distance, calories, and rest periods.
Set type="conditioning" for exercises.
Save as: ConditioningVar_8W_1D.json
```

## Example Prompt 6: Deload Week Strategy

```
Generate a 4-week block showing proper deload implementation.

Block Requirements:
- Name: "4-Week Volume Block with Deload"
- Goal: hypertrophy
- Target: Intermediate
- Equipment: Full gym

Week-by-Week Exercise Plan:

Week 1 (Normal Volume):
- Bench Press 4x8
- Back Squat 4x8
- Deadlift 3x8

Week 2 (Increased Volume):
- Bench Press 5x8
- Back Squat 5x8
- Deadlift 4x8

Week 3 (Peak Volume):
- Bench Press 6x8
- Back Squat 6x8
- Deadlift 5x8

Week 4 (Deload - DIFFERENT EXERCISES):
- Dumbbell Press 3x10 (lighter)
- Goblet Squat 3x10 (lighter)
- Romanian Deadlift 3x10 (lighter)

Use "Weeks" field to show volume progression and deload.
Week 4 should use different, easier exercises.
Include RPE targets (7-8 for weeks 1-3, 5-6 for week 4).
Save as: VolumeBlock_4W_1D.json
```

## Tips for AI Prompt Writing

### Be Specific About Format
Always include:
- "Use the 'Weeks' field in JSON"
- "Different exercises for each week"
- Specific week-by-week breakdown

### Include Context
- Training goal and philosophy
- Equipment availability
- Experience level
- Time constraints

### Specify Progression
- How exercises change week-to-week
- Rep ranges and intensity progression
- Deload strategy

### Request Complete JSON
- "Generate the complete JSON"
- "Include all required fields"
- Specify filename format

## Common Patterns

### Pattern 1: Block Periodization
```
Weeks 1-4: Accumulation (high volume, moderate intensity)
Week 5: Deload
Weeks 6-9: Intensification (moderate volume, high intensity)
Week 10: Deload
Weeks 11-12: Peaking (low volume, very high intensity)
```

### Pattern 2: Exercise Rotation
```
Weeks 1-3: Main Variation (e.g., Back Squat)
Weeks 4-6: Secondary Variation (e.g., Front Squat)
Weeks 7-9: Tertiary Variation (e.g., Pause Squat)
```

### Pattern 3: Wave Loading
```
Week 1: 5x5
Week 2: 5x3
Week 3: 5x1
Week 4: Deload 3x5
[Repeat with heavier weights]
```

### Pattern 4: Progressive Complexity
```
Weeks 1-2: Machine exercises (stable)
Weeks 3-4: Dumbbell exercises (moderate stability)
Weeks 5-6: Barbell exercises (high skill demand)
```

## Validation Checklist

After AI generates JSON, verify:
- [ ] `Weeks` field is present (not `Days` for variations)
- [ ] Number of week arrays matches `NumberOfWeeks`
- [ ] Each week has consistent day structure
- [ ] Exercise names are descriptive
- [ ] Sets/reps are specified
- [ ] Intensity cues included (RPE, RIR, %)
- [ ] Valid JSON syntax (commas, brackets, quotes)

## Troubleshooting AI Responses

### AI Uses "Days" Instead of "Weeks"
**Fix**: Explicitly state in prompt:
"CRITICAL: Use the 'Weeks' field, not 'Days', to specify different exercises for each week."

### AI Generates Same Exercises All Weeks
**Fix**: Provide detailed week-by-week breakdown in prompt:
```
Week 1: Exercise A
Week 2: Exercise B (DIFFERENT from Week 1)
Week 3: Exercise C (DIFFERENT from Weeks 1-2)
```

### AI Omits Required Fields
**Fix**: Reference complete JSON template in prompt:
"Follow this exact structure: [paste template]"

### JSON Syntax Errors
**Fix**: Request validation:
"Ensure valid JSON syntax with proper commas and brackets. Validate before responding."

## Advanced Use Cases

### Multi-Phase Periodization
```
Phases within block:
Weeks 1-4: Anatomical Adaptation (machines, high reps)
Weeks 5-8: Hypertrophy (free weights, moderate reps)
Weeks 9-12: Strength (barbell compounds, low reps)
```

### Sport-Specific Preparation
```
Off-season (Weeks 1-4): General strength, varied exercises
Pre-season (Weeks 5-8): Sport-specific movements
In-season (Weeks 9-12): Maintenance, reduced volume
```

### Injury Recovery Progression
```
Week 1: Isometric exercises
Week 2: Eccentric exercises
Week 3: Concentric exercises (machines)
Week 4: Compound movements (dumbbells)
Weeks 5-6: Return to normal training (barbells)
```

## Summary

Key points for generating week-specific blocks with AI:
1. Always specify "Use the Weeks field"
2. Provide detailed week-by-week exercise breakdown
3. Request complete, valid JSON output
4. Include programming rationale (periodization model)
5. Specify intensity and volume progression
6. Validate generated JSON before importing

With these prompts and patterns, you can generate sophisticated training blocks with exercise variations, proper periodization, and effective programming principles.

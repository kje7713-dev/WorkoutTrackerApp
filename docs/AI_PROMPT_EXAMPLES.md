# AI Prompt Examples for Week-Specific Blocks

## Introduction

This document provides copy-paste AI prompts for generating training blocks with week-specific exercise variations. Use these with ChatGPT, Claude, or any AI assistant to generate properly formatted JSON blocks.

**⚠️ Important Disclaimer**: AI-generated content should always be validated before use. AI assistants may not always follow the exact format requested, may generate invalid JSON syntax, or may produce training programs that are not appropriate for your fitness level or goals. Always review and test generated JSON before importing, and consult with a qualified fitness professional before starting any new training program.

## Complete JSON Schema Reference

The Savage By Design app supports a comprehensive schema for training blocks, including:

### Block-Level Fields
- `Title`: Block name
- `Goal`: Training goal (strength/hypertrophy/power/conditioning/mixed/peaking/deload/rehab)
- `TargetAthlete`: Experience level or target audience
- `NumberOfWeeks`: Total weeks in the block
- `DurationMinutes`: Estimated session duration
- `Difficulty`: 1-5 scale
- `Equipment`: Required equipment list
- `WarmUp`: Warm-up description
- `Finisher`: Finisher/cooldown description
- `Notes`: Additional block notes
- `EstimatedTotalTimeMinutes`: Total time estimate
- `Progression`: Progression strategy description

### Block Structure Options
- `Exercises`: Single-day format (legacy) - array of exercises for one day
- `Days`: Multi-day format - array of day templates (same days all weeks)
- `Weeks`: Week-specific format - array of weeks, each containing array of day templates

### Exercise-Level Fields (Advanced)
Each exercise can include:
- `name`: Exercise name
- `type`: "strength", "conditioning", "mixed", "other"
- `category`: "squat", "hinge", "pressHorizontal", "pressVertical", "pullHorizontal", "pullVertical", "carry", "core", "olympic", "conditioning", "mobility", "mixed", "other"
- `setsReps`: Simple format like "3x8" (legacy)
- `sets`: Advanced array of individual sets with detailed parameters
- `conditioningType`: "monostructural", "mixedModal", "emom", "amrap", "intervals", "forTime", "forDistance", "forCalories", "roundsForTime", "other"
- `conditioningSets`: Array of conditioning sets with time/distance/calories
- `notes`: Exercise notes
- `restSeconds`: Rest between sets (simple format)
- `intensityCue`: Intensity guidance (simple format)
- `videoUrls`: Array of video URLs for technique demonstration
- **Superset/Circuit Grouping**:
  - `setGroupId`: UUID string for grouping exercises
  - `setGroupKind`: "superset", "circuit", "giantSet", "emom", "amrap"
- **Progression Parameters**:
  - `progressionType`: "weight", "volume", "custom", "skill"
  - `progressionDeltaWeight`: Weight increase per week (e.g., 5.0)
  - `progressionDeltaSets`: Set increase per week
  - `deloadWeekIndexes`: Array of week numbers for deload (e.g., [4, 8])
  - `deltaResistance`: Resistance level change for skill-based progression (0-100)
  - `deltaRounds`: Round count change for skill-based progression
  - `deltaConstraints`: Progressive constraint changes (array of strings)

### Individual Set Parameters (Advanced)
For `sets` array:
- `reps`: Target reps
- `weight`: Target weight
- `percentageOfMax`: Percentage of 1RM (0.0-1.0)
- `rpe`: Rating of Perceived Exertion (1.0-10.0)
- `rir`: Reps In Reserve (0.0-5.0+)
- `tempo`: Tempo prescription (e.g., "3-0-1-0")
- `restSeconds`: Rest after this set
- `notes`: Set-specific notes

For `conditioningSets` array:
- `durationSeconds`: Work duration
- `distanceMeters`: Target distance
- `calories`: Target calories
- `rounds`: Number of rounds
- `targetPace`: Pace target (e.g., "2:00/500m")
- `effortDescriptor`: Effort level (e.g., "moderate", "hard")
- `restSeconds`: Rest after this set
- `notes`: Set-specific notes

### Segment-Based Sessions (BJJ, Yoga, etc.)
For non-traditional training (grappling, yoga, business training, etc.), use `segments` instead of or alongside `exercises`:

**Segment Fields**:
- `name`: Segment name
- `segmentType`: "warmup", "mobility", "technique", "drill", "positionalSpar", "rolling", "cooldown", "lecture", "breathwork", "practice", "presentation", "review", "demonstration", "discussion", "assessment", "other"
- `domain`: "grappling", "yoga", "strength", "conditioning", "mobility", "sports", "business", "education", "analytics", "other"
- `durationMinutes`: Segment duration
- `objective`: Segment objective/goal
- `constraints`: Array of constraints
- `coachingCues`: Array of coaching cues
- `positions`: Array of positions (grappling)
- `techniques`: Array of technique objects with videoUrls support
- `roundPlan`: Round structure with timing and rules
- `drillPlan`: Drill plan with work/rest intervals
- `partnerPlan`: Partner drill structure
- `roles`: Attacker/defender roles
- `resistance`: Resistance level (0-100)
- `qualityTargets`: Success metrics
- `scoring`: Scoring conditions
- `flowSequence`: Yoga flow sequence
- `intensityScale`: "restorative", "easy", "moderate", "strong", "peak"
- `props`: Array of props/equipment
- `breathwork`: Breathwork pattern details
- `media`: Video URLs, images, diagrams
- `safety`: Contraindications and safety notes
- `notes`: Additional notes

**Technique Object** (within segments):
- `name`: Technique name
- `variant`: Technique variant
- `keyDetails`: Array of key details
- `commonErrors`: Array of common errors
- `counters`: Array of counters
- `followUps`: Array of follow-up options
- `videoUrls`: Array of video URLs for this technique

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

---

## Advanced Features Examples

### Example 7: Superset and Circuit Training

```
Generate a 4-week upper body superset block in JSON format for Savage By Design app.

Block Requirements:
- Name: "4-Week Upper Body Supersets"
- Goal: hypertrophy
- Target: Intermediate
- Equipment: Full gym

Use superset grouping with setGroupId and setGroupKind fields.

Week 1-4 Structure (same each week):
Day 1: Push Supersets
- Superset A (setGroupId: "A1", setGroupKind: "superset"):
  - Bench Press: 4x8-10
  - Dumbbell Pullover: 4x12
- Superset B (setGroupId: "B1", setGroupKind: "superset"):
  - Overhead Press: 3x8
  - Lateral Raise: 3x15
- Circuit C (setGroupId: "C1", setGroupKind: "circuit", 3 rounds):
  - Cable Flies: 15 reps
  - Tricep Pushdowns: 15 reps
  - Face Pulls: 20 reps

Day 2: Pull Supersets
- Superset A (setGroupId: "A2", setGroupKind: "superset"):
  - Barbell Row: 4x8-10
  - Pull-ups: 4x max
- Giant Set B (setGroupId: "B2", setGroupKind: "giantSet"):
  - Cable Row: 3x12
  - Lat Pulldown: 3x12
  - Barbell Curl: 3x10
  - Hammer Curl: 3x12

JSON Format Note:
{
  "Days": [
    {
      "name": "Day 1: Push Supersets",
      "exercises": [
        {
          "name": "Bench Press",
          "type": "strength",
          "setsReps": "4x8",
          "setGroupId": "A1",
          "setGroupKind": "superset",
          "videoUrls": ["https://youtube.com/bench-press-form"]
        },
        {
          "name": "Dumbbell Pullover",
          "type": "strength",
          "setsReps": "4x12",
          "setGroupId": "A1",
          "setGroupKind": "superset"
        }
      ]
    }
  ]
}

Include videoUrls for key exercises.
Save as: UpperBodySupersets_4W_2D.json
```

### Example 8: Advanced Progression with Deload Weeks

```
Generate a 6-week strength block with programmed deload weeks.

Block Requirements:
- Name: "6-Week Strength Block with Auto-Deload"
- Goal: strength
- Target: Advanced
- Equipment: Full powerlifting gym

Programming Details:
- Weeks 1-2: Accumulation phase
- Week 3: Deload (use deloadWeekIndexes field)
- Weeks 4-5: Intensification phase
- Week 6: Final deload (use deloadWeekIndexes field)

Each exercise should specify:
- progressionType: "weight"
- progressionDeltaWeight: 5.0 (for main lifts)
- deloadWeekIndexes: [3, 6]

Example exercise JSON:
{
  "name": "Back Squat",
  "type": "strength",
  "category": "squat",
  "sets": [
    {"reps": 5, "percentageOfMax": 0.75, "rpe": 7.5, "restSeconds": 180},
    {"reps": 5, "percentageOfMax": 0.80, "rpe": 8.0, "restSeconds": 180},
    {"reps": 5, "percentageOfMax": 0.85, "rpe": 8.5, "restSeconds": 240}
  ],
  "progressionType": "weight",
  "progressionDeltaWeight": 5.0,
  "deloadWeekIndexes": [3, 6],
  "notes": "Drop to 70% on deload weeks",
  "videoUrls": ["https://youtube.com/squat-technique"]
}

Generate complete block with 3 days per week:
- Day 1: Squat-focused
- Day 2: Bench-focused
- Day 3: Deadlift-focused

Use advanced sets format with reps, percentageOfMax, rpe, tempo, and restSeconds.
Save as: StrengthDeload_6W_3D.json
```

### Example 9: Skill-Based Progression (BJJ/Martial Arts)

```
Generate an 8-week BJJ progression block using segment-based format.

Block Requirements:
- Name: "8-Week BJJ Guard Development"
- Goal: mixed
- Target: Intermediate grapplers
- Equipment: Grappling mats, training partners, timer

Use segments instead of exercises for this block.

Week 1-4: Closed Guard Foundation
Week 5-8: Advanced Guard Variations

Include full segment details:
- segmentType: "technique", "drill", "positionalSpar", "rolling"
- domain: "grappling"
- positions array
- techniques array with videoUrls
- roundPlan with timing
- partnerPlan with resistance levels
- roles (attackerGoal, defenderGoal)
- qualityTargets

Progression Parameters:
- progressionType: "skill"
- deltaResistance: 10 (increase resistance 10% per week)
- deltaRounds: 1 (add 1 round every 2 weeks)
- deltaConstraints: Progressive constraint tightening

Example Segment:
{
  "name": "Closed Guard Sweep Drill",
  "segmentType": "drill",
  "domain": "grappling",
  "durationMinutes": 10,
  "objective": "Master hip bump sweep from closed guard",
  "positions": ["closed_guard", "mount"],
  "techniques": [
    {
      "name": "Hip Bump Sweep",
      "variant": "standard",
      "keyDetails": ["Break posture first", "Hip to side", "Swim arm deep"],
      "commonErrors": ["Sweeping without breaking posture", "Weak base"],
      "counters": ["Post on sweeping side"],
      "followUps": ["Mount", "Gift wrap"],
      "videoUrls": ["https://youtube.com/hip-bump-sweep"]
    }
  ],
  "partnerPlan": {
    "rounds": 5,
    "roundDurationSeconds": 120,
    "restSeconds": 30,
    "roles": {
      "attackerGoal": "Execute sweep from closed guard",
      "defenderGoal": "Maintain posture with light resistance"
    },
    "resistance": 25,
    "switchEverySeconds": 60,
    "qualityTargets": {
      "successRateTarget": 0.7,
      "cleanRepsTarget": 5
    }
  },
  "progressionType": "skill",
  "deltaResistance": 10,
  "notes": "Increase resistance each week"
}

Generate complete 8-week block with:
- 2 days per week
- 5-6 segments per day
- Warm-up, technique, drills, positional sparring, rolling, cooldown
- Progressive resistance and complexity

Save as: BJJGuardProgression_8W_2D.json
```

### Example 10: Comprehensive Exercise with All Fields

```
Generate a single-day demonstration block showing ALL possible exercise fields.

Block Requirements:
- Name: "Comprehensive Exercise Schema Demo"
- Goal: strength
- Target: Advanced
- Equipment: Full gym

This is a DEMO block to show all supported fields. Generate ONE day with 3 exercises:

Exercise 1 - Strength with Advanced Sets:
{
  "name": "Competition Bench Press",
  "type": "strength",
  "category": "pressHorizontal",
  "sets": [
    {
      "reps": 3,
      "weight": 225.0,
      "percentageOfMax": 0.85,
      "rpe": 8.5,
      "rir": 1.5,
      "tempo": "3-1-1-0",
      "restSeconds": 240,
      "notes": "Controlled eccentric, explosive concentric"
    },
    {
      "reps": 3,
      "weight": 235.0,
      "percentageOfMax": 0.88,
      "rpe": 9.0,
      "rir": 1.0,
      "tempo": "3-1-1-0",
      "restSeconds": 240,
      "notes": "Touch and go"
    }
  ],
  "notes": "Competition pause on chest",
  "progressionType": "weight",
  "progressionDeltaWeight": 5.0,
  "deloadWeekIndexes": [4, 8],
  "videoUrls": [
    "https://youtube.com/bench-press-setup",
    "https://youtube.com/bench-press-technique"
  ]
}

Exercise 2 - Conditioning with Advanced Parameters:
{
  "name": "Rowing Intervals",
  "type": "conditioning",
  "category": "conditioning",
  "conditioningType": "intervals",
  "conditioningSets": [
    {
      "durationSeconds": 120,
      "distanceMeters": 500.0,
      "calories": 25.0,
      "targetPace": "1:45/500m",
      "effortDescriptor": "hard",
      "restSeconds": 60,
      "notes": "Maintain stroke rate 24-26"
    },
    {
      "durationSeconds": 120,
      "distanceMeters": 500.0,
      "calories": 25.0,
      "targetPace": "1:45/500m",
      "effortDescriptor": "hard",
      "restSeconds": 60
    }
  ],
  "notes": "Focus on consistent pacing",
  "progressionType": "custom",
  "videoUrls": ["https://youtube.com/rowing-technique"]
}

Exercise 3 - Circuit with Grouping:
Create a 3-exercise circuit using setGroupId and setGroupKind: "circuit"

Include ALL fields where applicable.
Generate complete valid JSON.
Save as: ComprehensiveDemo_1D.json
```

### Example 11: Yoga/Mobility Session with Segments

```
Generate a 4-week yoga progression block using segment-based format.

Block Requirements:
- Name: "4-Week Vinyasa Flow Progression"
- Goal: mobility
- Target: All levels
- Equipment: Yoga mat, blocks, strap

Use segments for yoga structure:

Week 1-2: Foundation Flow (60 min sessions)
Week 3-4: Advanced Flow (75 min sessions)

Each session should have segments:
1. Breathwork (5-10 min)
2. Warm-up flow (10-15 min)
3. Peak pose sequence (20-30 min)
4. Cooldown flow (10-15 min)
5. Savasana (5-10 min)

Example Breathwork Segment:
{
  "name": "Pranayama - Ujjayi",
  "segmentType": "breathwork",
  "domain": "yoga",
  "durationMinutes": 5,
  "objective": "Establish breath awareness and rhythm",
  "breathwork": {
    "style": "Ujjayi",
    "pattern": "Ocean breath through nose",
    "durationSeconds": 300
  },
  "intensityScale": "easy",
  "props": ["block (optional for seated)"],
  "media": {
    "videoUrl": "https://youtube.com/ujjayi-pranayama",
    "coachNotesMarkdown": "Emphasize smooth, even breath"
  },
  "notes": "Find natural rhythm before starting flow"
}

Example Flow Segment:
{
  "name": "Sun Salutation A Variations",
  "segmentType": "warmup",
  "domain": "yoga",
  "durationMinutes": 10,
  "objective": "Warm body and link breath to movement",
  "flowSequence": [
    {"poseName": "Mountain", "holdSeconds": 15, "transitionCue": "Inhale arms up"},
    {"poseName": "Forward Fold", "holdSeconds": 20, "transitionCue": "Exhale fold"},
    {"poseName": "Halfway Lift", "holdSeconds": 10, "transitionCue": "Inhale lengthen"},
    {"poseName": "Plank", "holdSeconds": 15, "transitionCue": "Step or jump back"},
    {"poseName": "Chaturanga", "holdSeconds": 5, "transitionCue": "Lower with control"},
    {"poseName": "Upward Dog", "holdSeconds": 10, "transitionCue": "Inhale open chest"},
    {"poseName": "Downward Dog", "holdSeconds": 30, "transitionCue": "Exhale push back"}
  ],
  "intensityScale": "moderate",
  "coachingCues": ["Move with breath", "Modifications available", "Find your edge"],
  "props": ["blocks for tight hamstrings"],
  "media": {
    "videoUrl": "https://youtube.com/sun-salutation-a",
    "keyCues": ["Breath leads movement", "Steady gaze", "Core engaged"]
  },
  "safety": {
    "contraindications": ["Wrist injuries", "Shoulder impingement"],
    "stopIf": ["Sharp pain", "Dizziness"],
    "intensityCeiling": "moderate"
  },
  "notes": "Complete 3-5 rounds of sequence"
}

Generate complete 4-week progression with:
- 2 sessions per week
- 5-6 segments per session
- Progressive intensity (easy → moderate → strong)
- Video URLs for key poses
- Props and modifications listed

Save as: VinyasaProgression_4W_2D.json
```

## Validation Checklist

After AI generates JSON, verify:
- [ ] Valid JSON syntax (commas, brackets, quotes)
- [ ] All required top-level fields present (Title, Goal, etc.)
- [ ] `Weeks`, `Days`, or `Exercises` field chosen appropriately
- [ ] Exercise fields match type (strength vs conditioning)
- [ ] Progression fields are consistent with progressionType
- [ ] Video URLs are valid (if provided)
- [ ] Segment structure is complete (if used)
- [ ] SetGroupId is same UUID for grouped exercises
- [ ] DeloadWeekIndexes are within NumberOfWeeks range
- [ ] All nested objects have required fields

## Testing Your Generated JSON

1. Copy the generated JSON
2. Validate JSON syntax at jsonlint.com
3. Import into Savage By Design app
4. Verify all fields display correctly
5. Test progression calculations
6. Check video links work
7. Validate segment structure (if applicable)

With these comprehensive examples and the full schema reference, you can generate training blocks that utilize all available features in the Savage By Design app.

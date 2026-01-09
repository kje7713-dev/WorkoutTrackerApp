# AI Prompt Examples v3 - Coach-Grade Training Design

## Overview

This document provides example interactions with the new v3 coach-grade AI prompt. These examples demonstrate how the system analyzes training correctness before generating JSON.

## Example 1: LOW-ENTROPY Request (Simple Workout)

**User Input:**
```
Create a single upper body workout for intermediate lifters
```

**Expected AI Response:**

```
ENTROPY CLASSIFICATION: LOW
(Single workout, straightforward - no detailed analysis needed)

Using SMART DEFAULTS:
- Primary Stimulus: Strength (upper body)
- Units per Session: 2 (1 main push, 1 main pull)
- Duration: moderate (45-60 min)
- Detail: medium

JSON:
{
  "Title": "Upper Body Strength Session",
  "Goal": "strength",
  "TargetAthlete": "Intermediate",
  "NumberOfWeeks": 1,
  "DurationMinutes": 60,
  "Difficulty": 3,
  "Equipment": "Barbell, Dumbbells, Pull-up Bar",
  "WarmUp": "5 min dynamic stretching, arm circles, band work",
  "Exercises": [
    {
      "name": "Barbell Bench Press",
      "type": "strength",
      "category": "pressHorizontal",
      "setsReps": "4x6",
      "restSeconds": 180,
      "intensityCue": "RPE 8",
      "progressionDeltaWeight": 5.0
    },
    {
      "name": "Weighted Pull-ups",
      "type": "strength",
      "category": "pullVertical",
      "setsReps": "4x6",
      "restSeconds": 180,
      "intensityCue": "RPE 8",
      "progressionDeltaWeight": 2.5
    }
  ],
  "Finisher": "3x15 face pulls, 3x12 bicep curls",
  "Notes": "Focus on controlled tempo and full range of motion",
  "EstimatedTotalTimeMinutes": 60,
  "Progression": "Add 5 lbs to bench, 2.5 lbs to pull-ups weekly"
}
```

## Example 2: HIGH-ENTROPY with Proper Analysis

**User Input:**
```
Create a 4-week strength block with squats, bench press, and deadlifts
```

**Expected AI Response:**

```
ENTROPY CLASSIFICATION: HIGH
(Multi-week program requiring analysis)

SCOPE SUMMARY (INITIAL):
- contentType: workout
- primaryItem: exercise
- mediaImpact: low

GOAL STIMULUS:
- Primary Stimulus: Strength (maximal)
- Secondary Stimulus: None
- Tertiary Stimulus: None

PRE-SCOPE SUFFICIENCY ANALYSIS:
1) Minimum Effective Units (MEU): 3 (squat, bench, deadlift - the three requested compounds)
2) Maximum Recoverable Units (MRU): 4-5 (3 heavy compounds + 1-2 accessories per session)
3) Time Constraint Check: 3 compounds @ 45-60 min = realistic
4) Interference Check: All three lifts target strength, no interference

UNIT JUSTIFICATION:
- Primary Stimulus: Maximal strength
- MEU per Session: 3 (squat, bench, deadlift)
- MRU per Session: 4 (3 compounds + 1 accessory)
- Chosen Units per Session: 3-4 exercises
- Rejected Alternatives: Conditioning work (would interfere), isolation movements (not MEU)
- Final Justification: 3 compound lifts meet MEU while staying under MRU. Adding 1 complementary accessory per day optimizes without overreaching.

QUESTION GATE:
1) Session duration: short (20–30), moderate (45–60), long (90+)?
2) Unit density: few (2–3), moderate (4–5), many (6+)?
3) Detail depth: brief | moderate | detailed?
4) Structure: identical | progressive | rotational?

[If user doesn't answer, use SMART DEFAULTS]

SCOPE SUMMARY (FINAL):
- contentType: workout
- primaryItem: exercise  
- mediaImpact: low
- unitDuration: moderate
- unitsPerSession: 4
- detailDepth: medium
- structureConsistency: progressive

JSON:
{
  "Title": "4-Week Strength Block - Big 3",
  "Goal": "strength",
  "TargetAthlete": "Intermediate",
  "NumberOfWeeks": 4,
  "DurationMinutes": 60,
  "Difficulty": 4,
  "Equipment": "Barbell, Rack, Bench",
  "WarmUp": "10 min mobility and activation",
  "Days": [
    {
      "name": "Day 1: Squat Focus",
      "exercises": [
        {
          "name": "Back Squat",
          "type": "strength",
          "category": "squat",
          "setsReps": "5x5",
          "restSeconds": 240,
          "intensityCue": "RPE 8",
          "progressionDeltaWeight": 10.0,
          "deloadWeekIndexes": [4]
        },
        {
          "name": "Romanian Deadlift",
          "type": "strength",
          "category": "hinge",
          "setsReps": "3x8",
          "restSeconds": 120,
          "intensityCue": "RPE 7"
        }
      ]
    },
    {
      "name": "Day 2: Bench Focus",
      "exercises": [
        {
          "name": "Bench Press",
          "type": "strength",
          "category": "pressHorizontal",
          "setsReps": "5x5",
          "restSeconds": 240,
          "intensityCue": "RPE 8",
          "progressionDeltaWeight": 5.0,
          "deloadWeekIndexes": [4]
        },
        {
          "name": "Barbell Row",
          "type": "strength",
          "category": "pullHorizontal",
          "setsReps": "4x8",
          "restSeconds": 120,
          "intensityCue": "RPE 7"
        }
      ]
    },
    {
      "name": "Day 3: Deadlift Focus",
      "exercises": [
        {
          "name": "Deadlift",
          "type": "strength",
          "category": "hinge",
          "setsReps": "5x3",
          "restSeconds": 300,
          "intensityCue": "RPE 8",
          "progressionDeltaWeight": 10.0,
          "deloadWeekIndexes": [4]
        },
        {
          "name": "Front Squat",
          "type": "strength",
          "category": "squat",
          "setsReps": "3x6",
          "restSeconds": 180,
          "intensityCue": "RPE 7"
        }
      ]
    }
  ],
  "Finisher": "Core work: 3x20 ab rollouts",
  "Notes": "Week 4 is deload at 70% intensity. Focus on bar speed and technique.",
  "EstimatedTotalTimeMinutes": 60,
  "Progression": "Linear progression +5-10 lbs per week, deload week 4"
}
```

## Example 3: HARD FAILURE - MEU > MRU

**User Input:**
```
Create a 30-minute workout with squats, deadlifts, bench press, overhead press, rows, and pull-ups
```

**Expected AI Response:**

```
ENTROPY CLASSIFICATION: HIGH

GOAL STIMULUS:
- Primary Stimulus: Strength (full body)

PRE-SCOPE SUFFICIENCY ANALYSIS:
1) Minimum Effective Units (MEU): 6 (all exercises requested)
2) Maximum Recoverable Units (MRU): 3-4 (heavy compounds)
3) Time Constraint Check: 6 exercises @ 30 min = 5 min per exercise = IMPOSSIBLE
4) Interference Check: N/A (cannot proceed)

HARD FAILURE DETECTED:
- MEU (6) > MRU (4)
- Session duration (30 min) cannot support MEU (6 exercises)

I cannot generate this program as requested because:
1. You've requested 6 heavy compound exercises, but maximum recoverable is 3-4
2. 30 minutes cannot accommodate 6 compound lifts with adequate rest

Would you like me to:
A) Reduce to 3 key compound exercises (squat, bench, deadlift) in 30 minutes
B) Keep all 6 exercises but extend session to 60-75 minutes
C) Split into 2 separate sessions (upper/lower split)

Please clarify your preference.
```

## Example 4: HIGH-ENTROPY with Interference Check

**User Input:**
```
Create a 4-week program with heavy squats AND high-volume running
```

**Expected AI Response:**

```
ENTROPY CLASSIFICATION: HIGH

SCOPE SUMMARY (INITIAL):
- contentType: workout
- primaryItem: exercise
- mediaImpact: low

GOAL STIMULUS:
- Primary Stimulus: UNCLEAR (strength OR conditioning?)
- Secondary Stimulus: CONFLICT DETECTED

PRE-SCOPE SUFFICIENCY ANALYSIS:
1) Minimum Effective Units (MEU): Depends on primary goal
2) Maximum Recoverable Units (MRU): Depends on primary goal
3) Time Constraint Check: Can be managed
4) Interference Check: SEVERE INTERFERENCE DETECTED

INTERFERENCE ANALYSIS:
Heavy squats require:
- High CNS demand
- Long recovery (48-72 hours)
- Muscular fatigue in legs

High-volume running creates:
- Concurrent training effect (reduces strength gains)
- Leg fatigue (compromises squat performance)
- Extended recovery needs

These goals are contradictory at high volumes.

CLARIFICATION NEEDED:
Which is your PRIMARY goal?

Option A: Strength-focused
- Heavy squats 3x/week
- Light/moderate running 2x/week (recovery runs only)
- Running volume capped to preserve squat performance

Option B: Conditioning-focused
- High-volume running program
- Moderate squats 2x/week (strength maintenance)
- Squat intensity reduced to prevent overreaching

Option C: Hybrid (Advanced athletes only)
- Heavy squats 2x/week
- Moderate running 2-3x/week
- Requires excellent recovery capacity

Please specify your primary goal and training experience level.
```

## Example 5: Skill-Based (BJJ) with Media Impact

**User Input:**
```
Create an 8-week BJJ guard curriculum with video demonstrations
```

**Expected AI Response:**

```
ENTROPY CLASSIFICATION: HIGH
(Multi-week curriculum with skill progression)

SCOPE SUMMARY (INITIAL):
- contentType: curriculum
- primaryItem: technique
- mediaImpact: high (video demos requested)

GOAL STIMULUS:
- Primary Stimulus: Skill acquisition (guard techniques)
- Secondary Stimulus: Drilling proficiency
- Tertiary Stimulus: Live application

PRE-SCOPE SUFFICIENCY ANALYSIS:
1) Minimum Effective Units (MEU): 2-3 techniques per session (depth over breadth)
2) Maximum Recoverable Units (MRU): 4-5 techniques per session (cognitive load limit)
3) Time Constraint Check: 60-90 min sessions support MEU
4) Interference Check: No conflicts, all work toward guard mastery

UNIT JUSTIFICATION:
- Primary Stimulus: Guard technique mastery
- MEU per Session: 2 techniques (allows depth and drilling time)
- MRU per Session: 4 techniques (cognitive load limit for retention)
- Chosen Units per Session: 3 techniques (optimal for learning)
- Rejected Alternatives: 5+ techniques (too shallow, poor retention)
- Final Justification: 3 techniques per session allows proper depth, drilling, and live application while staying within cognitive load limits.

QUESTION GATE:
1) Session duration: short (20–30), moderate (45–60), long (90+)?
2) Unit density: few (2–3), moderate (4–5), many (6+)?
3) Detail depth: brief | moderate | detailed?
4) Structure: identical | progressive | rotational?
5) Video policy: none | 1 per session | 1 per technique | multiple per technique?

[Assuming user wants: moderate duration, few units, detailed depth, progressive structure, 1 video per technique]

SCOPE SUMMARY (FINAL):
- contentType: curriculum
- primaryItem: technique
- mediaImpact: high
- unitDuration: moderate (60 min)
- unitsPerSession: 3 techniques
- detailDepth: detailed
- structureConsistency: progressive
- mediaPolicy: 1 video per technique

JSON:
{
  "Title": "8-Week BJJ Guard Development Curriculum",
  "Goal": "mixed",
  "TargetAthlete": "Intermediate grapplers",
  "NumberOfWeeks": 8,
  "DurationMinutes": 60,
  "Difficulty": 4,
  "Equipment": "Grappling mats, training partners, timer",
  "WarmUp": "See segment structure",
  "Weeks": [
    [
      {
        "name": "Week 1, Day 1: Closed Guard Foundation",
        "segments": [
          {
            "name": "Warmup Drills",
            "segmentType": "warmup",
            "domain": "grappling",
            "durationMinutes": 10,
            "drillPlan": {
              "items": [
                {"name": "Hip escapes", "workSeconds": 60, "restSeconds": 15},
                {"name": "Technical standups", "workSeconds": 60, "restSeconds": 15}
              ]
            }
          },
          {
            "name": "Technique: Closed Guard Posture Control",
            "segmentType": "technique",
            "domain": "grappling",
            "durationMinutes": 15,
            "objective": "Establish and maintain closed guard control",
            "positions": ["closed_guard"],
            "techniques": [
              {
                "name": "Closed Guard Posture Break",
                "keyDetails": [
                  "Squeeze knees to control hips",
                  "Pull head down with overhook",
                  "Create angle for attacks"
                ],
                "commonErrors": [
                  "Breaking posture without angle",
                  "Releasing squeeze too early"
                ],
                "videoUrls": ["https://youtube.com/closed-guard-posture-break"]
              }
            ]
          },
          {
            "name": "Drilling: Posture Break Reps",
            "segmentType": "drill",
            "domain": "grappling",
            "durationMinutes": 15,
            "partnerPlan": {
              "rounds": 5,
              "roundDurationSeconds": 120,
              "restSeconds": 30,
              "roles": {
                "attackerGoal": "Break posture 10 times",
                "defenderGoal": "Light resistance (30%)"
              },
              "resistance": 30,
              "switchEverySeconds": 60,
              "qualityTargets": {
                "cleanRepsTarget": 8,
                "successRateTarget": 0.8
              }
            }
          },
          {
            "name": "Positional Sparring",
            "segmentType": "positionalSpar",
            "domain": "grappling",
            "durationMinutes": 15,
            "startPosition": "closed_guard",
            "roundPlan": {
              "rounds": 5,
              "roundDurationSeconds": 180,
              "restSeconds": 30,
              "intensityCue": "moderate"
            },
            "scoring": {
              "attackerScoresIf": ["Sweep", "Submit"],
              "defenderScoresIf": ["Pass guard", "Stand up"]
            }
          },
          {
            "name": "Cooldown",
            "segmentType": "cooldown",
            "domain": "mobility",
            "durationMinutes": 5,
            "breathwork": {
              "style": "Box breathing",
              "pattern": "4s in / 4s hold / 4s out / 4s hold",
              "durationSeconds": 300
            }
          }
        ]
      }
    ]
  ],
  "Finisher": "See cooldown segment",
  "Notes": "Progress resistance 10% per week. Add constraints in weeks 5-8.",
  "EstimatedTotalTimeMinutes": 60,
  "Progression": "Increase resistance and add positional constraints each week"
}
```

## Key Takeaways

1. **LOW-ENTROPY**: Simple, direct generation with sensible defaults
2. **HIGH-ENTROPY**: Detailed analysis before generation
3. **HARD FAILURES**: AI stops and asks for clarification rather than generating invalid programs
4. **INTERFERENCE**: AI identifies conflicts between goals and suggests solutions
5. **SKILL-BASED**: Different analysis for skill vs strength training
6. **SCHEMA COMPLIANCE**: Never violated, even when training concepts conflict

## Testing Your Own Prompts

To test the new v3 prompt:
1. Open BlockGeneratorView in the app
2. Enter your requirements
3. Copy the complete prompt
4. Paste into ChatGPT 4 or Claude
5. Verify you see the required sections (ENTROPY, GOAL STIMULUS, MEU/MRU, etc.)
6. Check that JSON conforms to schema
7. Import into app and verify parsing works

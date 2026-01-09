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

PRE-SCOPE SUFFICIENCY ANALYSIS — INTERNAL (not shown to user):
[Internal reasoning about volume and recovery - not exposed]

UNIT JUSTIFICATION:
- Primary Stimulus: Maximal strength
- Chosen Units per Session: 3-4 exercises (main lifts + 1 accessory)
- Rejected Alternatives: Excessive accessories would compromise recovery for main lifts
- Final Justification: Three main compound lifts with one complementary accessory per day provides sufficient stimulus while maintaining focus on the requested movements.

QUESTION GATE (optional - only if needed):
1) Session duration preference: short (20–30), moderate (45–60), long (90+)?
2) Detail depth: brief | moderate | detailed?
3) Structure preference: identical | progressive | rotational?

[Using sensible defaults based on stated goal and athlete level]

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

## Example 3: HARD FAILURE - Excessive Volume for Time

**User Input:**
```
Create a 30-minute workout with squats, deadlifts, bench press, overhead press, rows, and pull-ups
```

**Expected AI Response:**

```
ENTROPY CLASSIFICATION: HIGH

GOAL STIMULUS:
- Primary Stimulus: Strength (full body)

PRE-SCOPE SUFFICIENCY ANALYSIS — INTERNAL:
[Internal reasoning: 6 heavy compounds cannot be recovered from in single session, and 30 min is insufficient time]

HARD FAILURE DETECTED:

I cannot generate this program as requested because:
1. Six heavy compound exercises in a single session would compromise recovery and training quality
2. A 30-minute session cannot accommodate six compound lifts with adequate rest between sets

Would you like me to:
A) Reduce to 3 key compound exercises (squat, bench, deadlift) that fit within 30 minutes
B) Keep all 6 exercises but extend the session to 60-75 minutes
C) Split into 2 separate sessions (upper/lower or push/pull split)

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

PRE-SCOPE SUFFICIENCY ANALYSIS — INTERNAL:
[Internal reasoning detects severe interference between heavy squats and high-volume running]

INTERFERENCE ANALYSIS:

I've identified a significant conflict in your training goals:

Heavy squats and high-volume running create competing demands:
- Heavy squats require significant CNS resources and 48-72 hour recovery
- High-volume running increases leg fatigue and can reduce strength gains (concurrent training effect)
- Both together may compromise performance in your primary goal

CLARIFICATION NEEDED:
Which is your PRIMARY goal?

Option A: Strength-focused
- Heavy squats 3x/week as primary focus
- Light/moderate running 2x/week for conditioning (capped to preserve squat performance)
- Running programmed on non-squat days for recovery

Option B: Conditioning-focused
- High-volume running as primary program
- Moderate squats 2x/week for strength maintenance
- Squat intensity reduced to avoid overreaching

Option C: Hybrid approach (for advanced athletes)
- Heavy squats 2x/week
- Moderate running 2-3x/week
- Requires good recovery capacity and experience with concurrent training

Please specify your primary goal and training experience level so I can adjust the program appropriately.
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

PRE-SCOPE SUFFICIENCY ANALYSIS — INTERNAL:
[Internal reasoning about appropriate technique volume and cognitive load for skill retention]

UNIT JUSTIFICATION:
- Primary Stimulus: Guard technique mastery
- Chosen Units per Session: 3 techniques
- Rejected Alternatives: More than 4 techniques would reduce drilling depth and skill retention
- Final Justification: Three techniques per session allows proper depth, adequate drilling time, and live application while maintaining focus and retention.

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
2. **HIGH-ENTROPY**: Detailed analysis before generation (internal reasoning not exposed)
3. **HARD FAILURES**: AI stops and explains the conflict in training terms, suggests solutions
4. **INTERFERENCE**: AI identifies conflicts between goals and suggests solutions without exposing internal volume metrics
5. **SKILL-BASED**: Different analysis approach for skill vs strength training
6. **SCHEMA COMPLIANCE**: Never violated
7. **VOLUME OWNERSHIP**: AI owns volume/recovery decisions, adjusts automatically with brief justification

## Testing Your Own Prompts

To test the revised v3 prompt:
1. Open BlockGeneratorView in the app
2. Enter your requirements
3. Copy the complete prompt
4. Paste into ChatGPT 4 or Claude
5. Verify you see the required sections (ENTROPY, GOAL STIMULUS, UNIT JUSTIFICATION without MEU/MRU exposure)
6. Check that volume decisions are made automatically without asking user
7. Verify JSON conforms to schema
8. Import into app and verify parsing works

# Complete JSON Schema Reference for Savage By Design

This document provides a comprehensive reference for all JSON schema fields supported by the Savage By Design workout tracking app.

## Table of Contents
1. [Block-Level Schema](#block-level-schema)
2. [Day Template Schema](#day-template-schema)
3. [Exercise Schema](#exercise-schema)
4. [Segment Schema](#segment-schema)
5. [Complete Examples](#complete-examples)

---

## Block-Level Schema

The top-level Block object represents a complete training program.

### Required Fields
| Field | Type | Description |
|-------|------|-------------|
| `Title` | String | Block name |
| `Goal` | String | Training goal: "strength", "hypertrophy", "power", "conditioning", "mixed", "peaking", "deload", "rehab" |
| `TargetAthlete` | String | Target audience or experience level |
| `NumberOfWeeks` | Integer | Total weeks in the block (can be overridden by Weeks array length) |
| `DurationMinutes` | Integer | Estimated session duration |
| `Difficulty` | Integer | 1-5 scale |
| `Equipment` | String | Required equipment list |
| `WarmUp` | String | Warm-up description |
| `Finisher` | String | Finisher/cooldown description |
| `Notes` | String | Additional block notes |
| `EstimatedTotalTimeMinutes` | Integer | Total time estimate |
| `Progression` | String | Progression strategy description |

### Block Structure Options (Choose One)
| Field | Type | Description |
|-------|------|-------------|
| `Exercises` | Array | Single-day format (legacy) - array of exercises for one day |
| `Days` | Array | Multi-day format - array of day templates (same days all weeks) |
| `Weeks` | Array of Arrays | Week-specific format - array of weeks, each containing array of day templates |

**Priority**: `Weeks` > `Days` > `Exercises`

---

## Day Template Schema

Each day within a block can contain exercises, segments, or both.

### Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | String | Yes | Day name |
| `shortCode` | String | No | Short code (e.g., "D1", "UL1") |
| `goal` | String | No | Day-specific goal |
| `notes` | String | No | Day notes |
| `exercises` | Array | No | Array of exercises (traditional strength/conditioning) |
| `segments` | Array | No | Array of segments (for BJJ, yoga, etc.) |

**Note**: A day can have both `exercises` and `segments` for hybrid training.

---

## Exercise Schema

Exercises represent traditional strength training or conditioning work.

### Basic Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | String | Yes | Exercise name |
| `type` | String | No | "strength", "conditioning", "mixed", "other" |
| `category` | String | No | See [Exercise Categories](#exercise-categories) |
| `notes` | String | No | Exercise notes |
| `videoUrls` | Array of Strings | No | Video URLs for technique reference |

### Simple Format (Legacy)
| Field | Type | Description |
|-------|------|-------------|
| `setsReps` | String | Simple format like "3x8", "5x5" |
| `restSeconds` | Integer | Rest between sets |
| `intensityCue` | String | Intensity guidance (e.g., "RPE 7-8") |

### Advanced Strength Sets
| Field | Type | Description |
|-------|------|-------------|
| `sets` | Array | Array of [Strength Set Objects](#strength-set-object) with detailed parameters |

### Conditioning Parameters
| Field | Type | Description |
|-------|------|-------------|
| `conditioningType` | String | See [Conditioning Types](#conditioning-types) |
| `conditioningSets` | Array | Array of [Conditioning Set Objects](#conditioning-set-object) |

### Superset/Circuit Grouping
| Field | Type | Description |
|-------|------|-------------|
| `setGroupId` | String | UUID string - same ID groups exercises together |
| `setGroupKind` | String | "superset", "circuit", "giantSet", "emom", "amrap" |

### Progression Parameters
| Field | Type | Description |
|-------|------|-------------|
| `progressionType` | String | "weight", "volume", "custom", "skill" |
| `progressionDeltaWeight` | Number | Weight increase per week (e.g., 5.0 for +5 lbs) |
| `progressionDeltaSets` | Integer | Set increase per week |
| `deloadWeekIndexes` | Array of Integers | Week numbers for deload (e.g., [4, 8]) |
| `deltaResistance` | Integer | Resistance level change for skill progression (0-100) |
| `deltaRounds` | Integer | Round count change for skill progression |
| `deltaConstraints` | Array of Strings | Progressive constraint changes |

### Exercise Categories
- `squat` - Squat variations
- `hinge` - Hip hinge movements (deadlifts, RDLs)
- `pressHorizontal` - Horizontal pressing (bench press, push-ups)
- `pressVertical` - Vertical pressing (overhead press)
- `pullHorizontal` - Horizontal pulling (rows)
- `pullVertical` - Vertical pulling (pull-ups, lat pulldowns)
- `carry` - Loaded carries
- `core` - Core work
- `olympic` - Olympic lifts
- `conditioning` - Conditioning work
- `mobility` - Mobility work
- `mixed` - Mixed/hybrid
- `other` - Other

### Conditioning Types
- `monostructural` - Single modality (rowing, running, etc.)
- `mixedModal` - Multiple modalities
- `emom` - Every Minute on the Minute
- `amrap` - As Many Rounds/Reps As Possible
- `intervals` - Interval training
- `forTime` - For time completion
- `forDistance` - For distance
- `forCalories` - For calorie burn
- `roundsForTime` - Multiple rounds for time
- `other` - Other formats

---

## Strength Set Object

Individual set within the `sets` array.

| Field | Type | Description |
|-------|------|-------------|
| `reps` | Integer | Target reps |
| `weight` | Number | Target weight |
| `percentageOfMax` | Number | Percentage of 1RM (0.0-1.0, e.g., 0.75 = 75%) |
| `rpe` | Number | Rating of Perceived Exertion (1.0-10.0) |
| `rir` | Number | Reps In Reserve (0.0-5.0+) |
| `tempo` | String | Tempo prescription (e.g., "3-0-1-0" = 3s eccentric, 0s pause, 1s concentric, 0s rest) |
| `restSeconds` | Integer | Rest after this set |
| `notes` | String | Set-specific notes |

---

## Conditioning Set Object

Individual conditioning set within the `conditioningSets` array.

| Field | Type | Description |
|-------|------|-------------|
| `durationSeconds` | Integer | Work duration |
| `distanceMeters` | Number | Target distance |
| `calories` | Number | Target calories |
| `rounds` | Integer | Number of rounds |
| `targetPace` | String | Pace target (e.g., "2:00/500m" or "easy") |
| `effortDescriptor` | String | Effort level (e.g., "moderate", "hard") |
| `restSeconds` | Integer | Rest after this set |
| `notes` | String | Set-specific notes |

---

## Segment Schema

Segments represent non-traditional training sessions (BJJ, yoga, business training, etc.).

### Core Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | String | Yes | Segment name |
| `segmentType` | String | Yes | See [Segment Types](#segment-types) |
| `domain` | String | No | See [Domains](#domains) |
| `durationMinutes` | Integer | No | Segment duration |
| `objective` | String | No | Segment objective/goal |
| `notes` | String | No | Additional notes |

### Structure Arrays
| Field | Type | Description |
|-------|------|-------------|
| `constraints` | Array of Strings | Training constraints |
| `coachingCues` | Array of Strings | Coaching cues |
| `positions` | Array of Strings | Positions (for grappling) |
| `props` | Array of Strings | Props/equipment needed |

### Technique Details
| Field | Type | Description |
|-------|------|-------------|
| `techniques` | Array | Array of [Technique Objects](#technique-object) |

### Round Structures
| Field | Type | Description |
|-------|------|-------------|
| `roundPlan` | Object | [Round Plan Object](#round-plan-object) - structured rounds |
| `drillPlan` | Object | [Drill Plan Object](#drill-plan-object) - drill sequences |
| `partnerPlan` | Object | [Partner Plan Object](#partner-plan-object) - partner work |

### Quality & Scoring
| Field | Type | Description |
|-------|------|-------------|
| `roles` | Object | [Roles Object](#roles-object) - attacker/defender roles |
| `resistance` | Integer | Resistance level (0-100) |
| `qualityTargets` | Object | [Quality Targets Object](#quality-targets-object) |
| `scoring` | Object | [Scoring Object](#scoring-object) |
| `startPosition` | String | Starting position |
| `endCondition` | String | Ending condition |
| `startingState` | Object | [Starting State Object](#starting-state-object) |

### Yoga/Mobility Specific
| Field | Type | Description |
|-------|------|-------------|
| `holdSeconds` | Integer | Hold duration for poses |
| `breathCount` | Integer | Number of breaths |
| `flowSequence` | Array | Array of [Flow Step Objects](#flow-step-object) |
| `intensityScale` | String | "restorative", "easy", "moderate", "strong", "peak" |
| `breathwork` | Object | [Breathwork Object](#breathwork-object) |

### Media & Safety
| Field | Type | Description |
|-------|------|-------------|
| `media` | Object | [Media Object](#media-object) - videos, images, diagrams |
| `safety` | Object | [Safety Object](#safety-object) - contraindications, warnings |

### Segment Types
- `warmup` - Warm-up activities
- `mobility` - Mobility work
- `technique` - Technique instruction
- `drill` - Drilling/skill work
- `positionalSpar` - Positional sparring
- `rolling` - Live rolling/sparring
- `cooldown` - Cooldown activities
- `lecture` - Instructional lecture
- `breathwork` - Breathwork practice
- `practice` - General practice
- `presentation` - Presentation/demo
- `review` - Review session
- `demonstration` - Demonstration
- `discussion` - Discussion/brainstorming
- `assessment` - Testing/evaluation
- `other` - Other

### Domains
- `grappling` - Grappling arts (BJJ, wrestling, judo)
- `yoga` - Yoga
- `strength` - Strength training
- `conditioning` - Conditioning
- `mobility` - Mobility work
- `sports` - General sports
- `business` - Business/professional training
- `education` - Educational content
- `analytics` - Data analysis
- `other` - Other

---

## Nested Objects Reference

### Technique Object
| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Technique name |
| `variant` | String | Technique variant |
| `keyDetails` | Array of Strings | Key technical details |
| `commonErrors` | Array of Strings | Common errors |
| `counters` | Array of Strings | Counters to this technique |
| `followUps` | Array of Strings | Follow-up options |
| `videoUrls` | Array of Strings | Video URLs for this technique |

### Round Plan Object
| Field | Type | Description |
|-------|------|-------------|
| `rounds` | Integer | Number of rounds |
| `roundDurationSeconds` | Integer | Duration of each round |
| `restSeconds` | Integer | Rest between rounds |
| `intensityCue` | String | Intensity guidance |
| `resetRule` | String | When to reset |
| `startingState` | Object | Starting State Object |
| `winConditions` | Array of Strings | Conditions for "winning" |

### Drill Plan Object
| Field | Type | Description |
|-------|------|-------------|
| `items` | Array | Array of [Drill Item Objects](#drill-item-object) |

### Drill Item Object
| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Drill name |
| `workSeconds` | Integer | Work duration |
| `restSeconds` | Integer | Rest duration |
| `notes` | String | Item notes |

### Partner Plan Object
| Field | Type | Description |
|-------|------|-------------|
| `rounds` | Integer | Number of rounds |
| `roundDurationSeconds` | Integer | Round duration |
| `restSeconds` | Integer | Rest between rounds |
| `roles` | Object | Roles Object |
| `resistance` | Integer | Resistance level (0-100) |
| `switchEverySeconds` | Integer | Switch roles every X seconds |
| `qualityTargets` | Object | Quality Targets Object |

### Roles Object
| Field | Type | Description |
|-------|------|-------------|
| `attackerGoal` | String | Attacker's goal |
| `defenderGoal` | String | Defender's goal |
| `switchEveryReps` | Integer | Switch after X reps |

### Quality Targets Object
| Field | Type | Description |
|-------|------|-------------|
| `successRateTarget` | Number | Target success rate (0.0-1.0) |
| `cleanRepsTarget` | Integer | Target clean reps |
| `decisionSpeedSeconds` | Number | Target decision speed |
| `controlTimeSeconds` | Integer | Target control time |
| `breathControl` | String | Breath control guidance |

### Scoring Object
| Field | Type | Description |
|-------|------|-------------|
| `attackerScoresIf` | Array of Strings | Scoring conditions for attacker |
| `defenderScoresIf` | Array of Strings | Scoring conditions for defender |

### Starting State Object
| Field | Type | Description |
|-------|------|-------------|
| `grips` | Array of Strings | Starting grips |
| `roles` | Array of Strings | Starting roles |

### Flow Step Object
| Field | Type | Description |
|-------|------|-------------|
| `poseName` | String | Pose/position name |
| `holdSeconds` | Integer | Hold duration |
| `transitionCue` | String | Transition cue |

### Breathwork Object
| Field | Type | Description |
|-------|------|-------------|
| `style` | String | Breathwork style |
| `pattern` | String | Breathing pattern |
| `durationSeconds` | Integer | Duration |

### Media Object
| Field | Type | Description |
|-------|------|-------------|
| `videoUrl` | String | Video URL |
| `imageUrl` | String | Image URL |
| `diagramAssetId` | String | Diagram asset ID |
| `coachNotesMarkdown` | String | Coaching notes in Markdown |
| `commonFaults` | Array of Strings | Common faults |
| `keyCues` | Array of Strings | Key cues |
| `checkpoints` | Array of Strings | Checkpoints |

### Safety Object
| Field | Type | Description |
|-------|------|-------------|
| `contraindications` | Array of Strings | Contraindications |
| `stopIf` | Array of Strings | Stop conditions |
| `intensityCeiling` | String | Maximum intensity |

---

## Complete Examples

### Example 1: Strength Training with Video URLs

```json
{
  "Title": "Strength Block with Videos",
  "Goal": "strength",
  "TargetAthlete": "Intermediate",
  "NumberOfWeeks": 4,
  "DurationMinutes": 60,
  "Difficulty": 3,
  "Equipment": "Barbell, rack",
  "WarmUp": "Dynamic stretching",
  "Days": [
    {
      "name": "Day 1: Lower",
      "exercises": [
        {
          "name": "Back Squat",
          "type": "strength",
          "category": "squat",
          "sets": [
            {
              "reps": 5,
              "percentageOfMax": 0.80,
              "rpe": 8.0,
              "tempo": "3-0-1-0",
              "restSeconds": 180
            }
          ],
          "progressionType": "weight",
          "progressionDeltaWeight": 5.0,
          "deloadWeekIndexes": [4],
          "videoUrls": [
            "https://youtube.com/squat-setup",
            "https://youtube.com/squat-depth"
          ]
        }
      ]
    }
  ],
  "Finisher": "Core work",
  "Notes": "Progressive overload",
  "EstimatedTotalTimeMinutes": 60,
  "Progression": "Add 5 lbs per week, deload week 4"
}
```

### Example 2: BJJ Segment with Techniques

```json
{
  "Title": "BJJ Guard Development",
  "Goal": "mixed",
  "TargetAthlete": "Intermediate grapplers",
  "NumberOfWeeks": 4,
  "DurationMinutes": 90,
  "Difficulty": 4,
  "Equipment": "Mats, gi",
  "WarmUp": "Movement prep",
  "Days": [
    {
      "name": "Day 1: Closed Guard",
      "segments": [
        {
          "name": "Armbar Technique",
          "segmentType": "technique",
          "domain": "grappling",
          "durationMinutes": 15,
          "objective": "Master armbar mechanics",
          "positions": ["closed_guard"],
          "techniques": [
            {
              "name": "Armbar from Guard",
              "keyDetails": ["Break posture", "Control head", "Hip angle"],
              "videoUrls": [
                "https://youtube.com/armbar-basic",
                "https://youtube.com/armbar-details"
              ]
            }
          ],
          "partnerPlan": {
            "rounds": 5,
            "roundDurationSeconds": 180,
            "restSeconds": 60,
            "resistance": 25,
            "qualityTargets": {
              "successRateTarget": 0.7,
              "cleanRepsTarget": 5
            }
          }
        }
      ]
    }
  ],
  "Finisher": "Rolling",
  "Notes": "Progressive resistance",
  "EstimatedTotalTimeMinutes": 90,
  "Progression": "Increase resistance by 10% per week"
}
```

### Example 3: Superset with Deload Weeks

```json
{
  "Title": "Upper Body Supersets",
  "Goal": "hypertrophy",
  "TargetAthlete": "Advanced",
  "NumberOfWeeks": 8,
  "DurationMinutes": 75,
  "Difficulty": 4,
  "Equipment": "Full gym",
  "WarmUp": "Band work",
  "Days": [
    {
      "name": "Day 1: Push",
      "exercises": [
        {
          "name": "Bench Press",
          "type": "strength",
          "category": "pressHorizontal",
          "setsReps": "4x8",
          "restSeconds": 90,
          "setGroupId": "A1",
          "setGroupKind": "superset",
          "progressionType": "weight",
          "progressionDeltaWeight": 5.0,
          "deloadWeekIndexes": [4, 8],
          "videoUrls": ["https://youtube.com/bench"]
        },
        {
          "name": "Dumbbell Row",
          "type": "strength",
          "category": "pullHorizontal",
          "setsReps": "4x8",
          "restSeconds": 90,
          "setGroupId": "A1",
          "setGroupKind": "superset",
          "progressionType": "weight",
          "progressionDeltaWeight": 2.5
        }
      ]
    }
  ],
  "Finisher": "Arm work",
  "Notes": "Superset format throughout",
  "EstimatedTotalTimeMinutes": 75,
  "Progression": "Linear with planned deloads"
}
```

---

## Validation Tips

1. **Use JSON Validator**: Always validate JSON syntax at jsonlint.com or similar
2. **Check Required Fields**: Ensure all required fields are present
3. **Field Types**: Verify numbers are not strings (use `5` not `"5"`)
4. **Array vs String**: Don't confuse arrays with strings
5. **UUID Format**: UUIDs should be valid UUID strings (for setGroupId)
6. **Video URLs**: Ensure URLs are properly formatted strings
7. **Progression Consistency**: Ensure progression fields match progressionType
8. **Week Numbers**: deloadWeekIndexes should be within NumberOfWeeks range

---

## Additional Resources

- [AI Prompt Examples](AI_PROMPT_EXAMPLES.md) - Copy-paste prompts for generating blocks
- [Segment Schema Documentation](SEGMENT_SCHEMA_DOCS.md) - Detailed segment field guide
- [Week-Specific Blocks Guide](WEEK_SPECIFIC_BLOCKS_GUIDE.md) - Week variation examples

---

*Last Updated: 2026-01-04*
*Schema Version: 1.0*

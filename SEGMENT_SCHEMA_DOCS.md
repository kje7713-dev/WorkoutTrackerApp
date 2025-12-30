# Non-Traditional Session Schema Documentation

## Overview

This document describes the schema extensions added to support non-traditional training sessions such as BJJ (Brazilian Jiu-Jitsu), yoga, breathwork, and other skill-based activities. These extensions are fully backwards compatible with existing exercise-based workout blocks.

## Key Concepts

### Segments vs. Exercises

The schema now supports two ways to structure a training day:

1. **Exercise-based** (traditional): Days contain `exercises[]` with sets, reps, and weights
2. **Segment-based** (new): Days contain `segments[]` representing class sections or training modules
3. **Hybrid**: Days can contain both `exercises[]` and `segments[]` for mixed sessions

## New Enums

### SegmentType
Defines the type of class segment:
- `warmup` - General warm-up and movement preparation
- `mobility` - Mobility and flexibility work
- `technique` - Technical instruction and practice
- `drill` - Specific drilling with constraints
- `positionalSpar` - Positional sparring from specific positions
- `rolling` - Free rolling/sparring
- `cooldown` - Cool-down and recovery
- `lecture` - Instructional lecture or video review
- `breathwork` - Breathing exercises
- `other` - Other segment types

### Domain
Training domain classification:
- `grappling` - Grappling sports (BJJ, wrestling, judo)
- `yoga` - Yoga practice
- `strength` - Strength training
- `conditioning` - Conditioning work
- `mobility` - Mobility work
- `other` - Other domains

### Discipline
Specific discipline tags for filtering and organization:
- `bjj` - Brazilian Jiu-Jitsu
- `nogi` - No-Gi grappling
- `wrestling` - Wrestling
- `judo` - Judo
- `yoga` - Yoga
- `mobility` - Mobility
- `breathwork` - Breathwork
- `mma` - Mixed Martial Arts

### IntensityScale
For yoga and mobility work:
- `restorative` - Very light, recovery-focused
- `easy` - Light intensity
- `moderate` - Moderate intensity
- `strong` - Strong intensity
- `peak` - Peak intensity

### Ruleset
Competition ruleset for grappling:
- `ibjjf` - IBJJF rules
- `adcc` - ADCC rules
- `uww` - United World Wrestling rules
- `custom` - Custom ruleset

### Attire
Training attire specification:
- `gi` - With gi
- `nogi` - Without gi
- `either` - Both allowed

### ClassType
Classification of class type:
- `fundamentals` - Fundamentals class
- `advanced` - Advanced class
- `competition` - Competition training
- `openMat` - Open mat session
- `seminar` - Seminar or workshop

## Core Structures

### Segment

The primary unit for non-traditional sessions. Represents a distinct section of a training session.

**Properties:**
- `id` (UUID) - Unique identifier
- `name` (String) - Segment name (e.g., "General Warm-up", "Technique Progression 1")
- `segmentType` (SegmentType) - Type of segment
- `domain` (Domain?) - Training domain
- `durationMinutes` (Int?) - Planned duration
- `objective` (String?) - Learning objective or goal
- `constraints` ([String]) - Rules or constraints (e.g., "Must start from inside tie")
- `coachingCues` ([String]) - Coaching points

**Position & Technique Taxonomy:**
- `positions` ([String]) - Starting positions (e.g., ["standing", "inside_tie", "single_leg"])
- `techniques` ([Technique]) - Techniques covered in this segment

**Round Structures:**
- `roundPlan` (RoundPlan?) - Round-based structure for sparring
- `drillPlan` (DrillPlan?) - Drill sequence for warmup
- `partnerPlan` (PartnerPlan?) - Partner drill structure

**Roles & Resistance:**
- `roles` (Roles?) - Attacker/defender roles
- `resistance` (Int?) - Resistance level (0-100)

**Quality Metrics:**
- `qualityTargets` (QualityTargets?) - Target quality metrics

**Scoring (for positional sparring):**
- `scoring` (Scoring?) - Win conditions
- `startPosition` (String?) - Starting position
- `endCondition` (String?) - End condition
- `startingState` (StartingState?) - Initial grips and positions

**Yoga/Mobility:**
- `holdSeconds` (Int?) - Hold duration for poses
- `breathCount` (Int?) - Number of breaths
- `flowSequence` ([FlowStep]) - Yoga flow sequence
- `intensityScale` (IntensityScale?) - Intensity level
- `props` ([String]) - Props needed (block, strap, bolster, etc.)

**Breathwork:**
- `breathwork` (BreathworkPlan?) - Breathwork pattern

**Media & Safety:**
- `media` (Media?) - Instructional media and coaching notes
- `safety` (Safety?) - Safety information
- `notes` (String?) - Additional notes

### Supporting Structures

#### Technique
Represents a specific technique or skill.

**Properties:**
- `name` (String) - Technique name
- `variant` (String?) - Variant or style
- `keyDetails` ([String]) - Key technical points
- `commonErrors` ([String]) - Common mistakes
- `counters` ([String]) - Counter techniques
- `followUps` ([String]) - Follow-up options

#### RoundPlan
Structure for timed rounds (sparring, drills).

**Properties:**
- `rounds` (Int) - Number of rounds
- `roundDurationSeconds` (Int) - Duration per round
- `restSeconds` (Int) - Rest between rounds
- `intensityCue` (String?) - Intensity description
- `resetRule` (String?) - When to reset (e.g., "Reset on takedown")
- `startingState` (StartingState?) - Initial position
- `winConditions` ([String]) - Scoring conditions

#### DrillPlan
Container for drill sequences.

**Properties:**
- `items` ([DrillItem]) - Drill items

#### DrillItem
Individual drill in a sequence.

**Properties:**
- `name` (String) - Drill name
- `workSeconds` (Int) - Work duration
- `restSeconds` (Int) - Rest duration
- `notes` (String?) - Notes

#### PartnerPlan
Structure for partner drills with roles and resistance.

**Properties:**
- `rounds` (Int) - Number of rounds
- `roundDurationSeconds` (Int) - Round duration
- `restSeconds` (Int) - Rest between rounds
- `roles` (Roles?) - Role definitions
- `resistance` (Int) - Resistance level (0-100)
- `switchEverySeconds` (Int?) - Role switching timing
- `qualityTargets` (QualityTargets?) - Target metrics

#### Roles
Role definitions for partner work.

**Properties:**
- `attackerGoal` (String?) - Attacker objective
- `defenderGoal` (String?) - Defender objective
- `resistance` (Int) - Resistance level (0-100)
- `switchEverySeconds` (Int?) - Switch timing
- `switchEveryReps` (Int?) - Switch after reps

#### QualityTargets
Target quality metrics for skill development.

**Properties:**
- `successRateTarget` (Double?) - Target success rate (0-1)
- `cleanRepsTarget` (Int?) - Target clean repetitions
- `decisionSpeedSeconds` (Double?) - Target decision speed
- `controlTimeSeconds` (Int?) - Target control time
- `breathControl` (String?) - Breath control goal

#### Scoring
Scoring conditions for positional work.

**Properties:**
- `attackerScoresIf` ([String]) - Attacker scoring conditions
- `defenderScoresIf` ([String]) - Defender scoring conditions

#### Safety
Safety information and contraindications.

**Properties:**
- `contraindications` ([String]) - Things to avoid
- `stopIf` ([String]) - Reasons to stop
- `intensityCeiling` (String?) - Max intensity level

#### Media
Instructional media and coaching support.

**Properties:**
- `videoUrl` (String?) - Video URL
- `imageUrl` (String?) - Image URL
- `diagramAssetId` (String?) - Diagram asset
- `coachNotesMarkdown` (String?) - Markdown notes
- `commonFaults` ([String]) - Common faults
- `keyCues` ([String]) - Key coaching cues
- `checkpoints` ([String]) - Quality checkpoints

#### BreathworkPlan
Breathwork pattern specification.

**Properties:**
- `style` (String) - Breathing style
- `pattern` (String) - Breathing pattern (e.g., "4s inhale / 6s exhale")
- `durationSeconds` (Int) - Duration

#### FlowStep
Step in a yoga flow sequence.

**Properties:**
- `poseName` (String) - Pose name
- `holdSeconds` (Int) - Hold duration
- `transitionCue` (String?) - Transition cue

## Block-Level Extensions

### Block Metadata

Blocks can now include additional metadata:

**Properties:**
- `tags` ([String]?) - Freeform tags
- `disciplines` ([Discipline]?) - Specific disciplines
- `ruleset` (Ruleset?) - Competition ruleset
- `attire` (Attire?) - Required attire
- `classType` (ClassType?) - Class type

### DayTemplate Extensions

DayTemplates now support segments:

**Properties:**
- `exercises` ([ExerciseTemplate]) - Traditional exercises (unchanged)
- `segments` ([Segment]?) - Segment-based structure (new)

A day can have:
- Only exercises (traditional)
- Only segments (new)
- Both exercises and segments (hybrid)

## Session Tracking

### SessionSegment

For live tracking of segment execution.

**Properties:**
- `id` (UUID) - Unique identifier
- `segmentId` (SegmentID?) - Link to template
- `name` (String) - Segment name
- `segmentType` (SegmentType) - Type

**Logged Data:**
- `startTime` (Date?) - When started
- `endTime` (Date?) - When ended
- `isCompleted` (Bool) - Completion status
- `actualDurationMinutes` (Int?) - Actual duration

**Quality Metrics:**
- `successRate` (Double?) - Measured success rate
- `cleanReps` (Int?) - Clean repetitions completed
- `decisionSpeed` (Double?) - Average decision speed
- `controlTime` (Int?) - Control time achieved

**Round/Drill Tracking:**
- `roundsCompleted` (Int?) - Rounds completed
- `drillItemsCompleted` (Int?) - Drill items completed

**Notes:**
- `notes` (String?) - Session notes
- `coachFeedback` (String?) - Coach feedback

### WorkoutSession Extensions

WorkoutSession now supports segments:

**Properties:**
- `exercises` ([SessionExercise]) - Exercise tracking (unchanged)
- `segments` ([SessionSegment]?) - Segment tracking (new)

## Progression

### Skill-Based Progression

ProgressionRule extended with:

**Properties:**
- `deltaResistance` (Int?) - Change in resistance level per week
- `deltaRounds` (Int?) - Change in round count per week
- `deltaConstraints` ([String]?) - Progressive constraint tightening

**New ProgressionType:**
- `skill` - For quality-based progression

## JSON Schema

### Authoring Schema

See `bjj_class_segments_example.json` for a complete example.

**Basic Structure:**
```json
{
  "Title": "Block Name",
  "NumberOfWeeks": 4,
  "Days": [
    {
      "name": "Day Name",
      "segments": [
        {
          "name": "Segment Name",
          "segmentType": "technique",
          "domain": "grappling",
          "durationMinutes": 15,
          "objective": "Learn X technique",
          "techniques": [...],
          "partnerPlan": {...}
        }
      ]
    }
  ]
}
```

## UI Integration

### BlockRunMode

Segments display in BlockRunMode with:
- Completion checkbox
- Segment type badge (color-coded)
- Duration display
- Round tracking with +/- controls
- Quality metrics logging (clean reps, success rate)
- Drill item checklist
- Notes display

### Whiteboard View

Segments display in whiteboard with:
- Grouped by segment type (Warm-Up, Technique, Drilling, Live Training, Cool Down)
- Formatted with objectives, constraints, coaching cues
- Techniques with key details and common errors
- Round plans and quality targets

## Examples

### BJJ Class Example

See `Tests/bjj_class_segments_example.json` for a complete 7-segment BJJ class including:
1. General warm-up with drilling
2. Technique progression 1 (inside tie to single entry)
3. Technique progression 2 (single finishes)
4. Constraint drilling
5. Situational sparring
6. BJJ integration (finish to pass)
7. Cooldown with breathwork

### Yoga Session (Conceptual)

```json
{
  "name": "Restorative Yoga",
  "segments": [
    {
      "name": "Opening Breathwork",
      "segmentType": "breathwork",
      "durationMinutes": 5,
      "breathwork": {
        "style": "diaphragmatic breathing",
        "pattern": "4s inhale / 6s exhale",
        "durationSeconds": 300
      }
    },
    {
      "name": "Gentle Flow",
      "segmentType": "mobility",
      "durationMinutes": 30,
      "intensityScale": "easy",
      "flowSequence": [
        {
          "poseName": "Child's Pose",
          "holdSeconds": 60,
          "transitionCue": "Slowly shift to downward dog"
        },
        {
          "poseName": "Downward Dog",
          "holdSeconds": 60
        }
      ]
    }
  ]
}
```

## Migration Guide

### For Existing Blocks

No changes needed! Existing exercise-based blocks continue to work exactly as before.

### Adding Segments to Existing Block

Simply add a `segments` array to a DayTemplate:

```json
{
  "name": "Hybrid Day",
  "exercises": [...],  // Your existing exercises
  "segments": [...]     // New segment-based work
}
```

## Best Practices

1. **Use segments for non-traditional sessions** where the structure is more about phases/modules than sets/reps
2. **Use exercises for traditional gym work** with sets, reps, and weight
3. **Use hybrid days** when appropriate (e.g., strength work + BJJ conditioning)
4. **Be descriptive with objectives** to guide athletes through the session
5. **Include safety notes** for high-risk activities
6. **Track quality over quantity** for skill-based work using quality targets
7. **Use constraints** to create progressive difficulty
8. **Document techniques thoroughly** with key details and common errors

## Future Enhancements

Potential areas for enhancement:
- Video integration for technique review
- Live timers for round-based work
- Partner rotation tracking
- Advanced breathwork patterns with visual guidance
- Integration with wearables for heart rate tracking
- Competition simulation mode with scoring

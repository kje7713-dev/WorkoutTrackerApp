# AI Prompt Structural Constraints - Visual Guide

## Before vs After Enhancement

### ❌ BEFORE: Ambiguous Guidance

The old prompt didn't explicitly prevent these issues:

```json
{
  "Days": [
    {
      "name": "Day 1",
      "exercises": [...],
      "exercises": [...]  // ❌ DUPLICATE KEY - parsing error!
    }
  ]
}
```

Or this confusion:

```json
{
  "Days": [
    {
      "name": "Powerlifting Day",
      "exercises": [...],
      "segments": [...]  // ⚠️ Why segments in pure powerlifting?
    }
  ]
}
```

### ✅ AFTER: Clear Structural Constraints

The enhanced prompt now enforces:

```json
{
  "Title": "3-Week Powerlifting Block",
  "NumberOfWeeks": 3,
  "Days": [
    {
      "name": "Day 1: Squat Focus",
      "exercises": [
        // ✅ ONE exercises array
        // ✅ ALL exercises for this day
        // ✅ No segments array (pure strength)
      ]
    },
    {
      "name": "Day 2: Bench Focus",
      "exercises": [...]  // ✅ ONE exercises array
    },
    {
      "name": "Day 3: Deadlift Focus",
      "exercises": [...]  // ✅ ONE exercises array
    }
  ]
}
```

## Visual Prompt Structure

```
┌─────────────────────────────────────────────────────────────┐
│ USER REQUIREMENTS:                                          │
│ "I want a 3-week program, 3 days per week,                 │
│  powerlifting focused."                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ ENTROPY DETECTION AND SCOPE CONTRACT                       │
│ • Classify as LOW or HIGH entropy                          │
│ • For HIGH entropy: analyze MEU/MRU                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ ⚠️  CRITICAL STRUCTURAL CONSTRAINTS (NEW!)                 │
│                                                             │
│ JSON STRUCTURE RULES (NON-NEGOTIABLE):                     │
│ 1. Use exactly ONE "segments" array per Day (if needed)    │
│ 2. Use exactly ONE "exercises" array per Day (if needed)   │
│ 3. NEVER duplicate JSON keys                               │
│ 4. Arrays must be properly formatted with []               │
│ 5. Comma-separated items, no trailing comma               │
│                                                             │
│ POWERLIFTING/STRENGTH PROGRAMS:                            │
│ • Use ONLY "exercises" array                               │
│ • Do NOT add "segments" unless mixing with skill work      │
│ • Each Day has ONE "exercises" array with all lifts        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ COMPLETE JSON STRUCTURE SPECIFICATION                       │
│ • All field definitions                                     │
│ • Exercise parameters                                       │
│ • Segment parameters                                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ USAGE GUIDELINES (ENHANCED!)                                │
│                                                             │
│ FOR GYM WORKOUTS - POWERLIFTING, BODYBUILDING:            │
│ 6. CRITICAL: Each Day has exactly ONE "exercises" array    │
│ 7. NEVER create multiple "exercises" keys                  │
│                                                             │
│ FOR SKILL SESSIONS - BJJ, YOGA:                            │
│ 7. CRITICAL: Each Day has exactly ONE "segments" array     │
│ 8. NEVER create multiple "segments" keys                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ EXAMPLE 1: 3-Week Powerlifting Program (NEW!)              │
│ • Demonstrates 3 weeks, 3 days per week                    │
│ • Shows proper ONE "exercises" array per Day               │
│ • No "segments" array                                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
                    AI GENERATES
                          ↓
              ✅ Valid JSON Structure
```

## Decision Tree for Program Structure

```
START: What type of program?
│
├─ Pure Strength/Powerlifting?
│  └─ YES → Use ONLY "exercises" array
│     ├─ ONE "exercises" array per Day
│     └─ NO "segments" array
│
├─ Pure Skill/Technique (BJJ, Yoga)?
│  └─ YES → Use ONLY "segments" array
│     ├─ ONE "segments" array per Day
│     └─ NO "exercises" array
│
└─ Hybrid (Strength + Skill)?
   └─ YES → Use BOTH arrays
      ├─ ONE "exercises" array per Day
      ├─ ONE "segments" array per Day
      └─ NEVER duplicate keys
```

## Example Request → Response Flow

### User Input:
```
"I want a 3-week program, 3 days per week, powerlifting focused."
```

### AI Analysis (Internal):
```
ENTROPY: HIGH (multi-week program)
SCOPE SUMMARY: 
  - contentType: workout
  - primaryItem: exercise
  - mediaImpact: low

GOAL STIMULUS:
  - Primary: Strength (powerlifting)
  - Secondary: None

MEU/MRU ANALYSIS:
  - MEU: 1 main compound lift per day
  - MRU: 3-4 exercises per day
  - Chosen: 3 exercises per day (1 main + 2 accessories)

STRUCTURAL CONSTRAINTS CHECK:
  ✅ Pure powerlifting → use ONLY "exercises" array
  ✅ 3 weeks → NumberOfWeeks: 3
  ✅ 3 days per week → Days array with 3 elements
  ✅ Each Day gets ONE "exercises" array
  ✅ NO "segments" arrays needed
```

### AI Output:
```json
{
  "Title": "3-Week Powerlifting Block",
  "NumberOfWeeks": 3,
  "Days": [
    {
      "name": "Day 1: Squat Focus",
      "exercises": [
        {"name": "Barbell Back Squat", "setsReps": "5x5"},
        {"name": "Romanian Deadlift", "setsReps": "3x8"},
        {"name": "Leg Press", "setsReps": "3x10"}
      ]
    },
    {
      "name": "Day 2: Bench Press Focus",
      "exercises": [
        {"name": "Barbell Bench Press", "setsReps": "5x5"},
        {"name": "Barbell Row", "setsReps": "4x8"},
        {"name": "Overhead Press", "setsReps": "3x8"}
      ]
    },
    {
      "name": "Day 3: Deadlift Focus",
      "exercises": [
        {"name": "Barbell Deadlift", "setsReps": "5x3"},
        {"name": "Front Squat", "setsReps": "3x6"},
        {"name": "Pull-ups", "setsReps": "3xAMRAP"}
      ]
    }
  ]
}
```

### Result:
```
✅ JSON valid
✅ No duplicate keys
✅ Proper structure
✅ Parses successfully in app
✅ User can start training immediately
```

## Common Pitfalls - Now Prevented

### ❌ Pitfall 1: Duplicate Keys
**Before:** AI might accidentally do this:
```json
{
  "name": "Day 1",
  "exercises": [{"name": "Squat", ...}],
  "exercises": [{"name": "Bench", ...}]
}
```
**After:** Prompt explicitly states "NEVER duplicate JSON keys"

### ❌ Pitfall 2: Mixed Signals
**Before:** Unclear when to use segments vs exercises
```json
{
  "name": "Powerlifting Day",
  "exercises": [...],
  "segments": [...]  // Why both?
}
```
**After:** "For pure strength/powerlifting programs, use ONLY 'exercises' array"

### ❌ Pitfall 3: Unclear Array Cardinality
**Before:** No guidance on how many arrays
```json
{
  "name": "Day 1",
  "exercises": [...],  // First array
  // More content
  "exercises": [...]   // Oops, second array?
}
```
**After:** "Each Day has exactly ONE 'exercises' array containing ALL exercises"

## Quick Reference Card

```
╔═══════════════════════════════════════════════════════════╗
║           AI PROMPT STRUCTURAL CONSTRAINTS                ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  RULE 1: ONE "exercises" array per Day (if using)       ║
║  RULE 2: ONE "segments" array per Day (if using)        ║
║  RULE 3: NEVER duplicate any JSON key                    ║
║  RULE 4: Arrays use square brackets []                   ║
║  RULE 5: Comma-separated, no trailing comma             ║
║                                                           ║
║  POWERLIFTING → exercises ONLY                           ║
║  BJJ/YOGA     → segments ONLY                            ║
║  HYBRID       → BOTH (one of each)                       ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

## Testing Your AI-Generated JSON

After getting JSON from AI, validate it:

1. **Check for duplicate keys:**
   ```bash
   python3 -c "import json; json.load(open('program.json'))"
   ```

2. **Verify structure:**
   - ✅ One "exercises" or "segments" array per Day
   - ✅ No duplicate keys
   - ✅ Proper array formatting

3. **Import into app:**
   - Open BlockGeneratorView
   - Paste JSON
   - Click "Parse JSON"
   - Should succeed without errors

## Summary

The enhanced AI prompt ensures:
- ✅ No duplicate JSON keys
- ✅ Clear structural rules
- ✅ Appropriate array usage for program type
- ✅ Better AI-generated output quality
- ✅ Fewer parsing errors
- ✅ Better user experience

**Result:** Users can generate powerlifting programs with confidence that the JSON will parse correctly in the app!

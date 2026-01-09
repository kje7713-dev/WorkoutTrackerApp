# AI Prompt Structural Constraints Enhancement

## Overview

This document describes the structural constraints added to the AI prompt template to prevent JSON parsing errors caused by duplicate keys and improper array usage.

## Problem Statement

Previously, the AI prompt did not explicitly emphasize structural constraints, which could lead to:
- Duplicate JSON keys (e.g., multiple "exercises" or "segments" arrays in the same Day)
- Ambiguous guidance on when to use exercises vs segments
- Parsing failures due to malformed JSON structure

## Solution

Added explicit structural constraints to the AI prompt template in `BlockGeneratorView.swift`:

### 1. Critical Structural Constraints Section

Added a new section emphasizing:
- Use exactly ONE "segments" array per Day (if needed)
- Use exactly ONE "exercises" array per Day (if needed)  
- NEVER duplicate JSON keys - each key appears once per object
- Proper array formatting with square brackets []
- Comma separation without trailing commas

### 2. Program-Specific Guidance

**For Powerlifting/Strength Programs:**
- Use ONLY "exercises" array
- Do NOT add "segments" array unless explicitly mixing strength with skill work
- Each Day has ONE "exercises" array containing all lifts

**For Skill/Technique Programs:**
- Use ONLY "segments" array
- Do NOT add "exercises" array unless explicitly mixing with strength work

**For Hybrid Programs:**
- Use ONE "exercises" array for all strength exercises
- Use ONE "segments" array for all skill/technique work
- Never duplicate these keys

### 3. Enhanced Usage Guidelines

Updated the USAGE GUIDELINES section with:
- Critical warnings about array duplication
- Explicit statements: "Each Day has exactly ONE 'exercises' array containing ALL exercises"
- Clear separation between program types (powerlifting, BJJ, hybrid)

### 4. Powerlifting Example

Added a complete 3-week powerlifting program example (Example 1) showing:
- 3 weeks, 3 days per week structure
- Proper Day structure with ONE "exercises" array per day
- No "segments" arrays (pure strength focus)
- Realistic exercise selection (Squat, Bench, Deadlift focus days)
- Proper progression parameters

## Validation

Created test JSON file demonstrating the proper structure:
- ✅ No duplicate JSON keys
- ✅ Structure follows all constraints
- ✅ NumberOfWeeks = 3
- ✅ Exactly 3 days per week
- ✅ Each day has exercises-only (no segments)

## Example Structure

```json
{
  "Title": "3-Week Powerlifting Block",
  "NumberOfWeeks": 3,
  "Days": [
    {
      "name": "Day 1: Squat Focus",
      "exercises": [
        // All exercises for this day in ONE array
      ]
    },
    {
      "name": "Day 2: Bench Focus",
      "exercises": [
        // All exercises for this day in ONE array
      ]
    },
    {
      "name": "Day 3: Deadlift Focus",
      "exercises": [
        // All exercises for this day in ONE array
      ]
    }
  ]
}
```

## Benefits

1. **Eliminates Parsing Errors:** No more duplicate key issues
2. **Clear Guidance:** Explicit rules for different program types
3. **Better Examples:** Real-world powerlifting program structure
4. **Prevents Confusion:** Clear when to use exercises vs segments vs both
5. **Improved AI Output:** AI assistants will generate properly structured JSON

## Usage

When using the AI prompt:
1. Open BlockGeneratorView in the app
2. Enter requirements (e.g., "3-week powerlifting program, 3 days per week")
3. Copy the complete prompt
4. Paste into ChatGPT, Claude, or other AI assistant
5. The AI will now follow strict structural constraints
6. Generated JSON will parse correctly in the app

## Testing

To test the constraints:
1. Generate a powerlifting program using the prompt
2. Verify JSON has no duplicate keys
3. Verify each Day has exactly ONE "exercises" array
4. Verify no "segments" array for pure strength programs
5. Import JSON into the app and verify successful parsing

## Files Modified

- `BlockGeneratorView.swift`: Enhanced AI prompt template with structural constraints
- Created test file: `/tmp/test_powerlifting_3week.json` (validation passed)

## Related Documents

- `AI_PROMPT_EXAMPLES_V3.md`: Contains example AI interactions
- `AI_PROMPT_SCOPE_CONTRACT.md`: Describes the v3 coach-grade prompt system
- `BlockGenerator.swift`: JSON parsing logic that expects this structure

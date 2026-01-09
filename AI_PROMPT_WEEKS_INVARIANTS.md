# AI Prompt Enhancement: WEEKS INVARIANTS

## Overview

This document describes the addition of explicit WEEKS INVARIANTS to the AI prompt template in `BlockGeneratorView.swift` to ensure proper JSON structure when using the week-specific `Weeks` array format.

## Problem Statement

The AI prompt needed explicit validation rules to prevent common errors when generating week-specific training blocks. Without clear invariants, AI assistants might generate JSON with:
- Mismatched `NumberOfWeeks` and `Weeks.length`
- Non-Day objects in Weeks arrays (e.g., narrative text, progression rules)
- Days without exercises or segments
- Placeholder days instead of actual training content

## Solution

Added a comprehensive **WEEKS INVARIANTS (NON-NEGOTIABLE)** section to the AI prompt template with five critical rules:

### 1. NumberOfWeeks Must Equal Weeks.length

**Rule:** If you have 4 weeks of data, `"NumberOfWeeks": 4` and `"Weeks"` must contain exactly 4 arrays.

**Example:**
```json
{
  "NumberOfWeeks": 4,
  "Weeks": [
    [/* Week 1 days */],
    [/* Week 2 days */],
    [/* Week 3 days */],
    [/* Week 4 days */]
  ]
}
```

### 2. Each Weeks[i] Must Be an Array of Day Objects

**Rule:** Every week must be an array containing Day objects, no exceptions.

**Correct:**
```json
"Weeks": [
  [
    {"name": "Day 1", "exercises": [...]},
    {"name": "Day 2", "exercises": [...]}
  ]
]
```

**Wrong:**
```json
"Weeks": [
  [{"name": "Day 1", "exercises": [...]}],
  ["Week 2: Same as Week 1 with 5lbs added"]  // Not a Day object!
]
```

### 3. Each Day Must Contain Exactly ONE "exercises" or "segments" Array

**Rule:** Every Day object must have exactly one `"exercises"` array OR exactly one `"segments"` array (or one of each for hybrid training).

**Correct:**
```json
{"name": "Day 1", "exercises": [...]}
{"name": "Day 2", "segments": [...]}
{"name": "Day 3", "exercises": [...], "segments": [...]}
```

**Wrong:**
```json
{"name": "Day 1"}  // Missing exercises/segments!
```

### 4. NO Placeholder Days, NO "Progression Rule" Objects, NO Narrative Items

**Rule:** Every Day object must be a real, actionable training day. No placeholder text, progression rules, or narrative descriptions where Day objects should be.

**Wrong Examples:**
- `"Week 2: Similar to Week 1 but..."`
- `{"progressionRule": "Add 5lbs each week"}`
- `"Continue with 2 days from Week 1"`

### 5. Weeks with Fewer Days Must Be Explicit and Intentional

**Rule:** If a week has fewer training days than others, provide exactly those Day objects explicitly.

**Example:** Week 4 deload with 2 days while other weeks have 4 days:

```json
{
  "NumberOfWeeks": 4,
  "Weeks": [
    [
      {"name": "Week 1 Day 1", "exercises": [...]},
      {"name": "Week 1 Day 2", "exercises": [...]},
      {"name": "Week 1 Day 3", "exercises": [...]},
      {"name": "Week 1 Day 4", "exercises": [...]}
    ],
    // ... Week 2 and 3 similar ...
    [
      {"name": "Week 4 Day 1", "exercises": [...]},
      {"name": "Week 4 Day 2", "exercises": [...]}
    ]
  ]
}
```

## Validation Examples Included

The prompt includes comprehensive validation examples showing:

### ✅ CORRECT Examples
- Proper week structure with matching NumberOfWeeks
- Day objects with exercises arrays
- Explicit deload weeks with fewer days

### ❌ WRONG Examples
- NumberOfWeeks doesn't match Weeks.length
- Weeks containing non-Day objects
- Days missing exercises/segments
- Placeholder text instead of Day objects

## Implementation Details

### Location
`BlockGeneratorView.swift` - Function `aiPromptTemplate(withRequirements:)`

### Position in Prompt
Placed immediately after the "OPTION C: Week-Specific Block" section and before the "USAGE GUIDELINES" section, ensuring visibility when AI assistants process the prompt.

### Visual Formatting
Uses clear visual separators and markdown-style formatting:
```
═══════════════════════════════════════════════════════════════
WEEKS INVARIANTS (NON-NEGOTIABLE):
═══════════════════════════════════════════════════════════════
```

## Benefits

1. **Prevents Parsing Errors:** Ensures JSON structure matches what BlockGenerator expects
2. **Eliminates Ambiguity:** Clear rules reduce AI assistant confusion
3. **Enforces Consistency:** NumberOfWeeks always matches actual week count
4. **Validates Structure:** Guarantees each Day has actionable content
5. **Improves Quality:** No placeholder or narrative content in structured data
6. **Clear Failure Modes:** Explicit guidance on when to use alternative formats

## Testing

The existing test suite validates these invariants:

### Sample JSON File
`Tests/sample_weeks_block.json` demonstrates correct structure:
- ✅ NumberOfWeeks: 4, Weeks.length: 4
- ✅ Each week is an array of Day objects
- ✅ Each Day has exactly one "exercises" array
- ✅ No placeholders or narrative items

### Test Files
- `Tests/WeekSpecificBlockTests.swift` - Automated tests
- `Tests/ManualWeeksTest.swift` - Manual validation
- `Tests/BlockGeneratorTests.swift` - Parser tests

## Usage

When generating blocks with AI assistants:

1. **Copy the complete prompt** from BlockGeneratorView in the app
2. **Provide your requirements** in the input field
3. **Paste into ChatGPT, Claude, or other AI assistant**
4. **AI will follow WEEKS INVARIANTS** when generating week-specific blocks
5. **JSON will parse correctly** in the app

## Alternative Formats

The invariants include guidance on when to use alternative formats:

- **Use "Days" format** if all weeks are identical (simpler structure)
- **Use "Exercises" format** for single-day blocks
- **Ask user for clarification** if Weeks format cannot satisfy invariants
- **Stop and explain** why Weeks format cannot be used if appropriate

## Related Documentation

- `WEEKS_SCHEMA_IMPLEMENTATION.md` - Technical implementation details
- `AI_PROMPT_STRUCTURAL_CONSTRAINTS.md` - General structural constraints
- `AI_PROMPT_SCOPE_CONTRACT.md` - AI prompt design philosophy
- `AI_PROMPT_EXAMPLES_V3.md` - Example AI interactions

## Future Enhancements

Potential improvements:
- Server-side validation of WEEKS INVARIANTS before import
- UI warning indicators for imported blocks violating invariants
- Automatic correction suggestions for common violations
- Import-time validation with detailed error messages

## Summary

The WEEKS INVARIANTS section ensures AI assistants generate properly structured week-specific training blocks that the app can parse and use correctly. These rules are non-negotiable and marked as such in the prompt to ensure compliance.

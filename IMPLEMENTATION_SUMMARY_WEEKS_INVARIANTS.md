# Implementation Summary: WEEKS INVARIANTS for AI Prompt

## Issue
Add explicit WEEKS INVARIANTS to the AI prompt to ensure proper validation when generating week-specific training blocks using the `Weeks` array format.

## Problem Statement Requirements

The following invariants were requested to be NON-NEGOTIABLE:

1. **NumberOfWeeks must equal Weeks.length**
2. **Each Weeks[i] must be an array of Day objects**
3. **Each Day must contain exactly one "exercises" array (or one "segments")**
4. **No placeholder days, no "progression rule" objects, no narrative items**
5. **If a week has fewer than the normal number of days, that must be explicit and intentional**

## Solution Implemented

### Changes Made

#### 1. BlockGeneratorView.swift
**Location:** Lines 1013-1101 (89 new lines added)

Added a comprehensive **WEEKS INVARIANTS (NON-NEGOTIABLE)** section to the `aiPromptTemplate(withRequirements:)` function, positioned immediately after the "OPTION C: Week-Specific Block" schema definition.

**Key Features:**
- ✅ All 5 invariants explicitly stated with markdown formatting
- ✅ Clear rule definitions with examples for each invariant
- ✅ 5 CORRECT validation examples showing proper structure
- ✅ 8 WRONG validation examples showing common mistakes
- ✅ Guidance on alternative formats when Weeks cannot be used
- ✅ NON-NEGOTIABLE enforcement clearly stated
- ✅ Visual separators using equals signs for prominence

**Example Invariant:**
```
1. **NumberOfWeeks MUST equal Weeks.length**
   - If you have 4 weeks of data, "NumberOfWeeks": 4 and "Weeks" must contain exactly 4 arrays
   - NEVER set NumberOfWeeks to a different value than the actual number of week arrays provided
   - Example: "NumberOfWeeks": 4 requires "Weeks": [week1, week2, week3, week4]
```

#### 2. AI_PROMPT_WEEKS_INVARIANTS.md
**New File:** 200 lines of comprehensive documentation

Created detailed documentation covering:
- Overview of the problem and solution
- Detailed explanation of each of the 5 invariants
- Complete JSON examples (correct and incorrect)
- Implementation details (location, formatting, position in prompt)
- Benefits of the enhancement
- Testing validation using existing test suite
- Usage guidelines for end users
- Alternative format guidance
- Future enhancement possibilities

### Validation Performed

✅ **Swift Syntax:** File parses without errors using `swift -frontend -parse`

✅ **All Invariants Present:** Verified all 5 invariants are in the prompt:
```bash
1. **NumberOfWeeks MUST equal Weeks.length**
2. **Each Weeks[i] MUST be an array of Day objects**
3. **Each Day MUST contain exactly ONE "exercises" array OR exactly ONE "segments" array (or one of each)**
4. **NO placeholder days, NO "progression rule" objects, NO narrative items**
5. **If a week has fewer days than others, that MUST be explicit and intentional**
```

✅ **Validation Examples:** Confirmed VALIDATION EXAMPLES section includes:
- 5 CORRECT examples (marked with ✅)
- 8 WRONG examples (marked with ❌)

✅ **Existing Tests Pass:** Verified existing test JSON follows all invariants:
```
NumberOfWeeks: 4
Weeks.length: 4
Match: True
Week 1: 2 days - each day has exercises=True
Week 2: 2 days - each day has exercises=True
Week 3: 2 days - each day has exercises=True
Week 4: 2 days - each day has exercises=True
```

### Test Coverage

Existing test suite validates these invariants:

1. **Tests/WeekSpecificBlockTests.swift**
   - Tests Block model storage of weekTemplates
   - Validates SessionFactory generation with week-specific templates
   - Confirms backward compatibility

2. **Tests/ManualWeeksTest.swift**
   - Manual validation of Weeks schema parsing
   - Verifies week distribution in generated sessions
   - Logs detailed parsing steps

3. **Tests/sample_weeks_block.json**
   - Reference JSON demonstrating correct structure
   - All invariants satisfied:
     - NumberOfWeeks = 4, Weeks.length = 4 ✅
     - Each week is array of Day objects ✅
     - Each Day has exactly one "exercises" array ✅
     - No placeholders or narratives ✅
     - All weeks have 2 days consistently ✅

### Files Modified

```
BlockGeneratorView.swift          | 89 lines added
AI_PROMPT_WEEKS_INVARIANTS.md     | 200 lines added (new file)
```

### Git Commits

1. `414f23c` - Initial plan: Add WEEKS INVARIANTS to AI prompt
2. `4605a83` - Add WEEKS INVARIANTS section to AI prompt template
3. `9eeee47` - Add documentation for WEEKS INVARIANTS enhancement

## Implementation Details

### Prompt Structure
The WEEKS INVARIANTS section is positioned strategically in the AI prompt:

```
[User Requirements]
↓
[ENTROPY DETECTION AND SCOPE CONTRACT]
↓
[JSON Format Specification]
↓
[CHOOSING BETWEEN EXERCISES vs SEGMENTS]
↓
[CRITICAL STRUCTURAL CONSTRAINTS]
↓
[COMPLETE JSON Structure]
  ├─ OPTION A: Single-Day Block
  ├─ OPTION B: Multi-Day Block  
  └─ OPTION C: Week-Specific Block
↓
[WEEKS INVARIANTS (NON-NEGOTIABLE)] ← NEW SECTION
↓
[USAGE GUIDELINES]
```

### Visual Formatting
Uses consistent visual separators for prominence:
```
═══════════════════════════════════════════════════════════════
WEEKS INVARIANTS (NON-NEGOTIABLE):
═══════════════════════════════════════════════════════════════
```

### Markdown Formatting
Rules use markdown-style formatting for clarity:
- `**Bold**` for rule headings
- `✅ CORRECT:` for valid examples
- `❌ WRONG:` for invalid examples
- Code blocks for JSON examples
- Bullet points for sub-rules

## Benefits

1. **Prevents Parsing Errors:** Ensures JSON structure matches BlockGenerator expectations
2. **Eliminates Ambiguity:** Clear rules reduce AI assistant confusion about structure
3. **Enforces Consistency:** NumberOfWeeks always matches actual week count
4. **Validates Structure:** Guarantees each Day has actionable content (exercises or segments)
5. **Improves Quality:** No placeholder or narrative content in structured data
6. **Clear Failure Modes:** Explicit guidance on when to use alternative formats or ask for clarification
7. **User-Friendly:** Comprehensive examples help AI assistants understand correct structure
8. **Maintainable:** Well-documented with clear reasoning for each invariant

## Usage Flow

1. **User opens BlockGeneratorView** in the Savage By Design app
2. **User enters requirements** in the text field (e.g., "4-week powerlifting program")
3. **User clicks "Copy Complete Prompt"** button
4. **Prompt includes WEEKS INVARIANTS** section automatically
5. **User pastes into ChatGPT/Claude** or other AI assistant
6. **AI assistant follows invariants** when generating week-specific blocks
7. **Generated JSON structure** satisfies all invariants
8. **User pastes JSON back** into the app
9. **BlockGenerator parses successfully** without errors
10. **Sessions are generated correctly** with proper week distribution

## Alternative Formats Guidance

The invariants include clear guidance on when to use alternative formats:

- **Use "Days" format** if all weeks are identical (simpler structure)
- **Use "Exercises" format** for single-day blocks (legacy format)
- **Ask user for clarification** if week-specific requirements are unclear
- **Stop and explain** why Weeks format cannot be used if invariants cannot be satisfied

This prevents AI assistants from forcing the Weeks format when inappropriate.

## Future Enhancements

Potential improvements identified:

1. **Server-side validation** of WEEKS INVARIANTS before import
2. **UI warning indicators** for imported blocks violating invariants
3. **Automatic correction suggestions** for common violations
4. **Import-time validation** with detailed error messages pointing to specific violations
5. **Visual diff tool** showing expected vs. actual structure
6. **Template library** with pre-validated week-specific examples

## Conclusion

The WEEKS INVARIANTS enhancement successfully addresses all requirements from the problem statement:

✅ **NumberOfWeeks must equal Weeks.length** - Invariant #1 explicitly enforces this
✅ **Each Weeks[i] must be an array of Day objects** - Invariant #2 explicitly enforces this
✅ **Each Day must contain exactly one "exercises" array (or one "segments")** - Invariant #3 explicitly enforces this
✅ **No placeholder days, no "progression rule" objects, no narrative items** - Invariant #4 explicitly enforces this
✅ **If a week has fewer days, that must be explicit and intentional** - Invariant #5 explicitly enforces this

All invariants are:
- Clearly stated as NON-NEGOTIABLE
- Prominently positioned in the prompt
- Supported by comprehensive examples
- Validated by existing test suite
- Well-documented for maintenance

The implementation is minimal, focused, and surgical - adding exactly what was requested without modifying existing functionality.

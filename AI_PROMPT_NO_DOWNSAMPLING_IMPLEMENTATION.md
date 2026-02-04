# AI Prompt No-Downsampling Implementation

## Overview

This document describes the implementation of strict prohibitions against downsampling (reducing exercises, sets, or days to save space) in the AI prompt template in `BlockGeneratorView.swift`.

## Problem Statement

The AI prompt needed explicit clarification that it is **strictly forbidden** from reducing the number of exercises, sets, or days to save space, reduce token usage, or manage output length constraints.

Previously, the prompt had a general "Do Not Down-Scope" guideline, but it was not forceful or explicit enough about the specific prohibition against reducing programming content for convenience or output management reasons.

## Solution: Three-Layer Prohibition System

### Layer 1: Segmented Phase Delivery Rules Enhancement

**Location:** Lines 488-489 in `BlockGeneratorView.swift`

**Added two explicit prohibition statements:**

```
• STRICTLY FORBIDDEN: You are NEVER permitted to reduce the number of exercises, 
  sets, or days to save space, reduce token usage, or manage output length.

• NO DOWNSAMPLING: Do NOT reduce, abbreviate, or omit exercises, sets, days, 
  or weeks regardless of JSON size or token constraints.
```

**Purpose:** Immediately after the "Do Not Down-Scope" rule, these statements provide clear, absolute prohibition using emphatic language (STRICTLY FORBIDDEN, NEVER, DO NOT).

### Layer 2: Dedicated NO DOWN-SAMPLING RULE Section

**Location:** Lines 511-536 in `BlockGeneratorView.swift`

**New section marked as "ABSOLUTE - NON-NEGOTIABLE":**

```
3. NO DOWN-SAMPLING RULE (ABSOLUTE - NON-NEGOTIABLE):

You are STRICTLY FORBIDDEN from reducing the number of exercises, sets, or days to save space.

NEVER reduce content because of:
- JSON file size or length
- Token limits or output constraints  
- Perceived complexity or verbosity
- Desire to simplify or abbreviate
- Transmission or parsing concerns

If the full program cannot fit in a single response:
- Use Segmented Phase Delivery (divide into phases)
- Maintain ALL exercises, sets, and days across all segments
- NEVER omit or reduce programming content

This rule applies to:
- Number of exercises per session
- Number of sets per exercise
- Number of days per week
- Number of weeks in the program
- Exercise details, notes, and progression parameters
- Segment details, techniques, and drilling instructions

"Saving space" or "reducing output length" are NEVER valid reasons to modify programming content.
```

**Purpose:** 
- Provides comprehensive coverage of what is forbidden
- Lists specific invalid reasons that might tempt an AI to reduce content
- Offers the correct alternative solution (Segmented Phase Delivery)
- Specifies exactly what content types are protected
- Uses emphatic, unambiguous language throughout

### Layer 3: ANTI-LAZINESS Section Extension

**Location:** Lines 631-639 in `BlockGeneratorView.swift`

**Extended the existing ANTI-LAZINESS section:**

```
EXTENDED TO ALL CONTENT:
You MAY NOT reduce exercises, sets, days, or weeks to:
- shorten JSON or reduce output length
- manage token limits or output constraints
- simplify the programming structure
- make artifact generation easier
- reduce perceived complexity

"Output length", "token limits", or "JSON size" are NEVER valid reasons to reduce programming content.
```

**Purpose:** The ANTI-LAZINESS section already prohibited omitting videos for convenience. This extension applies the same principle to all programming content (exercises, sets, days, weeks), creating consistency across the prompt.

## Benefits

### 1. Absolute Clarity
The prohibition is stated in three different sections using multiple phrasings, ensuring AI assistants understand the requirement regardless of how they parse or prioritize the prompt.

### 2. Comprehensive Coverage
The rules explicitly cover:
- Exercises
- Sets
- Days
- Weeks
- Exercise details and notes
- Progression parameters
- Segments and techniques

### 3. Invalid Reasons Enumerated
By listing specific reasons that are NOT valid (JSON size, token limits, complexity, etc.), the prompt preemptively counters the most likely rationalizations an AI might use to justify downsampling.

### 4. Alternative Solution Provided
The rules don't just say what NOT to do; they also specify what TO do instead (use Segmented Phase Delivery), making it clear that large programs are still achievable.

### 5. Reinforcement Through Repetition
The prohibition appears in three distinct sections:
1. Segmented Phase Delivery Rules (lines 488-489)
2. NO DOWN-SAMPLING RULE (lines 511-536)
3. ANTI-LAZINESS extension (lines 631-639)

This repetition ensures the rule is encountered multiple times during prompt processing.

## Validation

Automated validation confirms:

- ✅ Contains "STRICTLY FORBIDDEN" (3 instances)
- ✅ Contains "NO DOWNSAMPLING"
- ✅ Explicit prohibition: "reduce the number of exercises, sets, or days"
- ✅ Prohibits reducing to "save space"
- ✅ Addresses "token limits" as invalid reason
- ✅ Dedicated "NO DOWN-SAMPLING RULE" section exists
- ✅ "EXTENDED TO ALL CONTENT" section exists
- ✅ Contains "NEVER reduce" language
- ✅ Contains "NEVER omit" language
- ✅ All content types covered: exercises, sets, days, weeks, segments

## Impact on AI Behavior

### Before This Change
An AI assistant might have:
- Reduced the number of exercises to fit output limits
- Abbreviated sets or simplified progression to "save space"
- Omitted days or weeks to avoid large JSON files
- Justified these reductions as "making the output more manageable"

### After This Change
An AI assistant will:
- Maintain ALL requested exercises, sets, days, and weeks
- Use Segmented Phase Delivery to handle large programs
- Never reduce content for token/space/complexity reasons
- Preserve full detail in exercise descriptions and progression parameters

## Implementation Location

All changes are in `BlockGeneratorView.swift` in the `aiPromptTemplate(withRequirements:)` function.

The prompt structure now includes these prohibition layers:
1. Line 487: "Do Not Down-Scope" (existing)
2. Lines 488-489: STRICTLY FORBIDDEN + NO DOWNSAMPLING (new)
3. Lines 511-536: NO DOWN-SAMPLING RULE section (new)
4. Lines 631-639: ANTI-LAZINESS extension (new)

## Usage

When users generate training programs using the AI prompt:

1. Open BlockGeneratorView in the app
2. Enter requirements (e.g., "6-week strength program, 4 days per week")
3. Copy the complete prompt
4. Paste into ChatGPT, Claude, or other AI assistant
5. The AI will now strictly adhere to no-downsampling rules
6. If the program is large, the AI will use Segmented Phase Delivery
7. Users receive complete programs with all requested content

## Testing Recommendations

### Test Case 1: Large Multi-Week Program
**Input:** "Create a 12-week powerlifting program, 4 days per week, 5 exercises per day"
**Expected Behavior:**
- AI should NOT reduce to 3 weeks or 3 days or 3 exercises
- AI should use Segmented Phase Delivery if needed (e.g., two 6-week phases)
- Each phase maintains full detail with all exercises and sets

### Test Case 2: Complex Hybrid Program
**Input:** "8-week program with strength training AND BJJ technique, 5 days per week"
**Expected Behavior:**
- AI should NOT omit BJJ segments to simplify
- AI should NOT reduce strength exercises to "make room" for BJJ
- Full content for both training modalities

### Test Case 3: High-Volume Request
**Input:** "4-week bodybuilding program, 6 days per week, 8-10 exercises per session"
**Expected Behavior:**
- AI should NOT reduce to 5 exercises per session
- AI should NOT reduce to 4 days per week
- Full volume maintained, using Segmented Phase Delivery if needed

## Future Enhancements

Potential improvements:
1. Add specific examples of acceptable Segmented Phase Delivery usage
2. Include automated checks in the app to warn if imported JSON seems "too small" for the request
3. Add user documentation explaining why full programs are better than abbreviated ones
4. Track historical AI outputs to identify if downsampling is still occurring despite prohibitions

## Conclusion

The AI prompt now contains **strict, unambiguous, and comprehensive prohibitions** against downsampling programming content. The three-layer approach (Segmented Phase Rules + Dedicated Section + ANTI-LAZINESS Extension) ensures AI assistants understand that reducing exercises, sets, or days to save space or manage output is absolutely forbidden.

**Core Principle:** "Maintain full program complexity. Use Segmented Phase Delivery for large programs. Never reduce content for convenience."

## Files Modified

- `BlockGeneratorView.swift` (+38 lines)
  - Lines 488-489: Added prohibitions to Segmented Phase Delivery Rules
  - Lines 511-536: Added NO DOWN-SAMPLING RULE section
  - Lines 631-639: Extended ANTI-LAZINESS section to all content

## Related Documents

- `AI_PROMPT_CLARIFICATION_IMPLEMENTATION.md`: SAVAGE BY DESIGN philosophy
- `AI_PROMPT_SCOPE_CONTRACT.md`: Coach-grade training program design system
- `AI_PROMPT_STRUCTURAL_CONSTRAINTS.md`: JSON structure rules
- `CAPACITY_AWARE_PROTOCOL_IMPLEMENTATION.md`: Segmented Phase Delivery details

# Pull Request Summary: AI Prompt Refinement - SAVAGE BY DESIGN Philosophy

## Overview

This PR implements the **SAVAGE BY DESIGN — CLARIFICATION OVER ASSUMPTION** philosophy into the AI prompt template, ensuring the AI assistant never defaults to conservative or minimal programming when generating training blocks.

## Problem Statement

The original AI prompt from the problem statement highlighted several issues:

> "Do NOT default to conservative or minimal programming.
> If a request is HIGH entropy and any critical input is missing
> (e.g. training frequency, session duration, competitive intent, structure),
> you MUST ask clarifying questions before generating the program.
>
> Competition or meet prep IMPLIES a dedicated athlete.
> Conservative defaults are DISABLED in competitive contexts.
>
> When information is missing:
> - ASK, do not assume down.
> - Optimize for performance, not convenience.
> - Use recovery management to support higher output, not to justify reduced exposure.
>
> Silence from the user is NOT permission to be conservative."

## Solution Implemented

Added explicit philosophical guidance throughout the AI prompt template in `BlockGeneratorView.swift` to ensure the AI assistant:

1. ✅ **Never defaults to conservative or minimal programming**
2. ✅ **Asks clarifying questions when critical information is missing**
3. ✅ **Treats competitive contexts as dedicated athlete programming**
4. ✅ **Optimizes for performance, not convenience**
5. ✅ **Uses recovery management to support higher output**
6. ✅ **Treats silence as a signal to ASK, not assume conservative**

## Changes Made

### 1. New Section: "SAVAGE BY DESIGN — CLARIFICATION OVER ASSUMPTION"

Added a dedicated 44-line section (lines 538-581) establishing the core philosophy with:
- **CORE PHILOSOPHY**: Explicit prohibition on conservative defaults
- **COMPETITIVE CONTEXT RULES**: Meet prep = dedicated athlete
- **DEFAULT BIAS**: Bias toward performance optimization
- **REQUIRED QUESTIONS**: Mandatory questions for HIGH-ENTROPY requests
- **WHEN INFORMATION IS MISSING**: ASK, do not assume down

### 2. Updated "VOLUME & RECOVERY OWNERSHIP" (19 lines added)

Enhanced to include:
- Competitive intent as a decision factor
- Explicit prohibition on conservative defaults when ambiguous
- FIRST ask questions, THEN adjust programming
- Bias toward performance optimization
- Silence is NOT permission to program conservatively

### 3. Modified "QUESTION GATE" (26 lines changed)

Changed from **OPTIONAL** to **REQUIRED** when critical info missing:
- Must ask about: frequency, duration, competitive intent, experience
- Explicit: "DO NOT proceed with conservative assumptions"
- Added competitive context signals (advanced athlete, higher capacity)

### 4. Enhanced "SMART DEFAULTS" (23 lines changed)

Updated to:
- Only apply when ALL critical information provided
- Bias toward performance in all defaults
- Do not assume beginner without evidence
- Do not automatically reduce strength volume

### 5. Updated "HARD FAILURE CONDITIONS" (11 lines added)

Enhanced to include:
- Missing critical inputs as a failure condition
- Explicit guidance against conservative defaults
- Operating principle: "bias toward performance optimization and ASK"

## Files Changed

### Modified
1. **BlockGeneratorView.swift** (104 additions, 21 deletions)
   - AI prompt template function `aiPromptTemplate(withRequirements:)`
   - Lines 496-1041 (the complete prompt template)

### Added
2. **AI_PROMPT_CLARIFICATION_IMPLEMENTATION.md** (10,925 characters)
   - Complete implementation guide
   - Problem statement and solution details
   - Section-by-section breakdown
   - Example scenarios and test cases
   - Validation checklist

3. **AI_PROMPT_BEFORE_AFTER_COMPARISON.md** (17,779 characters)
   - Side-by-side comparison of all changes
   - Before/after for each modified section
   - Use case examples with behavioral changes
   - Philosophy shift explanation
   - Testing scenarios

## Verification

All key philosophy statements verified in the implementation:

✅ **Core philosophy statement**: "Do NOT default to conservative or minimal programming"
✅ **Competitive context rules**: "Competition or meet prep IMPLIES a dedicated athlete"
✅ **ASK principle**: "ASK, do not assume down"
✅ **Silence rule**: "Silence from the user is NOT permission to be conservative"
✅ **REQUIRED question gate**: Changed from OPTIONAL to REQUIRED
✅ **Performance bias**: Throughout all decision-making sections

## Impact

### Before This PR
- AI could default to conservative volume when uncertain
- Competitive contexts treated like any other request
- Questions were optional
- Silence could imply "use safe defaults"
- Recovery could justify reduced volume

### After This PR
- AI must ask questions when critical info missing
- Competitive contexts trigger advanced athlete programming
- Questions are REQUIRED for HIGH-ENTROPY requests with missing info
- Silence triggers clarifying questions
- Recovery supports higher output, not reduced volume

## Example Use Cases

### Use Case 1: Meet Prep Request
**Input:** "Create a 12-week powerlifting meet prep program"

**Before:** Might default to 3 days/week, moderate volume
**After:** Recognizes competitive context, MUST ask frequency/duration/experience, programs for dedicated athlete

### Use Case 2: Vague Request
**Input:** "Help me get stronger"

**Before:** Might assume beginner programming
**After:** Asks experience, frequency, duration, competitive intent before proceeding

### Use Case 3: High Volume Context
**Input:** "6 days/week strength training"

**Before:** Might reduce volume per session (conservative approach)
**After:** Recognizes informed decision, uses recovery to support frequency, does not preemptively reduce

## Testing Recommendations

1. **Competition Context Test**: Request meet prep program, verify AI asks clarifying questions and programs aggressively
2. **Missing Info Test**: Request vague "training block", verify AI stops and asks REQUIRED questions
3. **High Volume Test**: Request 5-6 day/week program, verify AI supports high frequency appropriately
4. **Ambiguous Goal Test**: Request "get stronger", verify AI asks rather than assumes beginner

## Documentation

Comprehensive documentation provided in two new markdown files:

1. **AI_PROMPT_CLARIFICATION_IMPLEMENTATION.md**
   - Implementation details and rationale
   - Test cases and validation checklist
   - Key quotes and principles

2. **AI_PROMPT_BEFORE_AFTER_COMPARISON.md**
   - Visual before/after comparison
   - Section-by-section changes
   - Use case examples
   - Philosophy shift summary

## Breaking Changes

None. This is a pure enhancement to the AI prompt template. The prompt generation function signature and all existing functionality remain unchanged.

## Code Quality

- ✅ No syntax errors
- ✅ String interpolation verified
- ✅ Multi-line string properly closed
- ✅ All key sections verified in implementation
- ✅ Git history clean with descriptive commits
- ✅ Comprehensive documentation provided

## Next Steps

1. Test prompt generation in the app UI
2. Copy generated prompt and test with ChatGPT/Claude
3. Verify AI assistant follows new guidelines with sample competitive context requests
4. Collect user feedback on AI-generated programs
5. Iterate based on real-world usage

## Conclusion

This PR successfully implements the SAVAGE BY DESIGN philosophy into the AI prompt template, ensuring that competitive athletes and serious trainees receive appropriately aggressive programming rather than being under-served by conservative defaults. The AI assistant will now ask clarifying questions when information is missing and bias toward performance optimization when making programming decisions.

**Core Principle:** "When in doubt, ASK. When competitive, OPTIMIZE. When ambiguous, BIAS TOWARD PERFORMANCE."

---

## Commits in This PR

1. **Initial plan**: Set up PR description and checklist
2. **Add SAVAGE BY DESIGN clarification philosophy to AI prompt**: Core implementation (104 additions, 21 deletions)
3. **Add comprehensive documentation for AI prompt refinement**: Documentation files (688 additions, 2 files created)

## Files Changed Summary

```
BlockGeneratorView.swift                        | 125 ++++++---
AI_PROMPT_CLARIFICATION_IMPLEMENTATION.md       | New file (10,925 chars)
AI_PROMPT_BEFORE_AFTER_COMPARISON.md           | New file (17,779 chars)
```

**Total:** 104 additions, 21 deletions in code; 28,704 characters of documentation

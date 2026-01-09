# AI Prompt Refinement: SAVAGE BY DESIGN — CLARIFICATION OVER ASSUMPTION

## Overview

This document describes the implementation of the "SAVAGE BY DESIGN — CLARIFICATION OVER ASSUMPTION" philosophy into the AI prompt template in `BlockGeneratorView.swift`.

## Problem Statement

The original AI prompt did not explicitly prevent conservative or minimal programming defaults when information was ambiguous. This could lead to:
- Under-programming for competitive athletes
- Conservative volume assumptions when user intent was performance-focused
- Failure to ask clarifying questions when critical information was missing
- Treating silence as permission to program conservatively

## Solution: SAVAGE BY DESIGN Philosophy

Added explicit philosophical guidance to ensure the AI assistant:
1. **Never defaults to conservative or minimal programming**
2. **Asks clarifying questions when critical information is missing**
3. **Treats competitive contexts as dedicated athlete programming**
4. **Optimizes for performance, not convenience**
5. **Uses recovery management to support higher output, not justify reduced exposure**
6. **Treats silence as a signal to ASK, not to assume down**

## Changes Made

### 1. New Section: "SAVAGE BY DESIGN — CLARIFICATION OVER ASSUMPTION"

Added a dedicated section (lines 538-581) that establishes core philosophy:

```
CORE PHILOSOPHY:
Do NOT default to conservative or minimal programming.

If a request is HIGH entropy and any critical input is missing
(e.g. training frequency, session duration, competitive intent, structure),
you MUST ask clarifying questions before generating the program.

Competition or meet prep IMPLIES a dedicated athlete.
Conservative defaults are DISABLED in competitive contexts.
```

**Key Principles:**
- **WHEN INFORMATION IS MISSING**: ASK, do not assume down
- **COMPETITIVE CONTEXT RULES**: Meet prep = advanced programming with appropriate volume
- **DEFAULT BIAS**: When ambiguous, bias toward performance optimization
- **REQUIRED QUESTIONS**: Must ask about frequency, duration, competitive intent, experience, and volume baseline for HIGH-ENTROPY requests

### 2. Updated "VOLUME & RECOVERY OWNERSHIP" Section

Enhanced the section (lines 511-533) to emphasize:
- **DO NOT default to conservative or minimal programming when information is ambiguous**
- **FIRST, ask clarifying questions if critical information is missing**
- **Bias toward performance optimization, not conservative safety margins**
- **Use competitive context as a signal for advanced programming**
- **Silence is NOT permission to program conservatively**

### 3. Modified "QUESTION GATE" Section

Changed from "OPTIONAL" to "REQUIRED FOR HIGH ENTROPY WHEN CRITICAL INFO MISSING" (lines 620-646):

**Critical information includes:**
1. Training frequency (days per week)
2. Session duration available
3. Competitive intent (recreational, serious, meet prep)
4. Experience level with the specific goal

**Added rule**: "You MUST ask clarifying questions. DO NOT proceed with conservative assumptions."

**Added competitive context signals:**
- Advanced/dedicated athlete
- Higher training capacity
- Performance optimization priority
- DO NOT apply conservative defaults

### 4. Enhanced "SMART DEFAULTS" Section

Updated smart defaults (lines 648-671) to:
- Only apply when **ALL CRITICAL INFORMATION PROVIDED**
- **Bias toward performance** when context suggests dedicated training
- **Ask rather than assume** when experience unclear but goal is advanced
- **Do not automatically reduce strength volume** when adding conditioning

**Default bias principles:**
- When context suggests dedicated training: program accordingly (not conservatively)
- When competitive intent stated: assume advanced capacity unless contradicted
- When experience unclear but goal is advanced: ask rather than assume beginner programming

### 5. Updated "HARD FAILURE CONDITIONS" Section

Enhanced failure conditions (lines 694-713) to:
- Include "CRITICAL INPUTS are missing for HIGH-ENTROPY requests" as a failure condition
- Add explicit guidance: "DO NOT default to conservative/minimal programming"
- Add guidance: "ASK clarifying questions to understand the user's actual context"
- Updated operating principle: "When ambiguous, bias toward performance optimization and ASK rather than assume conservative"

## Benefits

### 1. Performance-First Programming
The AI will now prioritize performance optimization over conservative safety margins, appropriate for serious athletes.

### 2. Competitive Context Recognition
Competition prep and meet prep are now explicitly recognized as signals for advanced programming with appropriate volume.

### 3. Mandatory Clarification
HIGH-ENTROPY requests with missing critical information will trigger mandatory clarification questions rather than conservative assumptions.

### 4. No Silent Defaults
The AI will not interpret user silence as permission to program conservatively. It will ask questions instead.

### 5. Recovery as Performance Tool
Recovery management is positioned as a tool to support higher training output, not as a justification for reduced exposure.

### 6. Context-Appropriate Defaults
When defaults must be applied, they bias toward performance optimization and match the stated training context.

## Example Scenarios

### Scenario 1: Competition Prep Request (Before)
**User:** "Create a 12-week meet prep program"
**AI (Before):** Might default to conservative volume, 3x/week frequency
**AI (After):** Asks: "What's your training frequency? What's your experience level with meet prep? What's your available session duration?"

### Scenario 2: High-Volume Request (Before)
**User:** "4-week strength block"
**AI (Before):** Might default to 2-3 exercises per session (conservative)
**AI (After):** Asks: "What's your training frequency? Competitive intent? Experience level?" Then programs appropriately based on answers.

### Scenario 3: Ambiguous Goal (Before)
**User:** "Help me get stronger"
**AI (Before):** Might assume beginner programming
**AI (After):** Asks: "What's your experience level? Are you training for competition? How many days per week can you train?"

### Scenario 4: Competitive Context (Before)
**User:** "Powerlifting meet prep, 8 weeks out"
**AI (Before):** Might still ask for volume preferences or default conservatively
**AI (After):** Recognizes competitive context → assumes advanced athlete → asks specific questions about frequency and structure, then programs accordingly with appropriate volume

## Testing Recommendations

### Test Case 1: HIGH-ENTROPY with Competition Context
**Input:** "Create a 12-week powerlifting meet prep program"
**Expected Behavior:**
1. Recognize HIGH entropy
2. Recognize competitive context (meet prep)
3. Ask REQUIRED questions: frequency, duration, experience
4. DO NOT default to conservative volume
5. Program for dedicated athlete with appropriate volume

### Test Case 2: HIGH-ENTROPY without Critical Info
**Input:** "Create a strength program"
**Expected Behavior:**
1. Recognize HIGH entropy
2. Identify missing critical info: weeks, frequency, duration, intent
3. Ask clarifying questions before proceeding
4. DO NOT assume conservative defaults

### Test Case 3: LOW-ENTROPY Request
**Input:** "Create a single upper body workout for intermediate lifter"
**Expected Behavior:**
1. Recognize LOW entropy
2. May proceed with smart defaults
3. Bias toward performance optimization within constraints

### Test Case 4: Competitive + Missing Info
**Input:** "Help me prep for nationals"
**Expected Behavior:**
1. Recognize competitive context → dedicated athlete
2. Ask: sport, weeks available, current training status, frequency
3. DO NOT reduce volume preemptively
4. Program for competitive performance

## Implementation Location

All changes are in `BlockGeneratorView.swift` in the `aiPromptTemplate(withRequirements:)` function (lines 496-1041).

The prompt structure now follows this order:
1. Schema correctness (non-negotiable)
2. **VOLUME & RECOVERY OWNERSHIP** (updated with no-conservative-default rules)
3. User requirements
4. **SAVAGE BY DESIGN — CLARIFICATION OVER ASSUMPTION** (NEW)
5. ENTROPY DETECTION AND SCOPE CONTRACT
6. Goal stimulus identification
7. Pre-scope sufficiency analysis (internal)
8. Unit justification
9. **QUESTION GATE** (now REQUIRED when critical info missing)
10. **SMART DEFAULTS** (now biased toward performance)
11. Scope summary (final)
12. Schema priority rules
13. **HARD FAILURE CONDITIONS** (updated with no-conservative-default rules)
14. JSON format specification
15. Usage guidelines and examples

## Key Quotes from Changes

> "Do NOT default to conservative or minimal programming."

> "Competition or meet prep IMPLIES a dedicated athlete. Conservative defaults are DISABLED in competitive contexts."

> "Silence from the user is NOT permission to be conservative."

> "When ambiguous: bias toward performance optimization"

> "ASK, do not assume down."

> "Use recovery management to support higher output, not to justify reduced exposure."

> "When ambiguous, bias toward performance optimization and ASK rather than assume conservative. Adjust programming based on actual user context, not worst-case assumptions."

## Validation Checklist

- [x] Core philosophy section added
- [x] VOLUME & RECOVERY OWNERSHIP updated
- [x] QUESTION GATE changed to REQUIRED for missing critical info
- [x] SMART DEFAULTS biased toward performance
- [x] HARD FAILURE CONDITIONS include missing critical info
- [x] Competitive context rules established
- [x] Default bias principles documented
- [x] "ASK rather than assume down" principle emphasized throughout
- [x] Recovery positioned as performance tool, not volume reducer
- [x] Silence explicitly NOT permission to be conservative

## Future Enhancements

Potential future improvements:
1. Add competitive context presets (powerlifting, Olympic lifting, CrossFit)
2. Include volume benchmarks for different competitive levels
3. Add recovery capacity estimation based on training history
4. Implement performance-first template library
5. Add auto-detection of competitive keywords (nationals, meet, competition)
6. Include progressive volume guidance for competitive periodization

## Conclusion

The AI prompt now embodies the SAVAGE BY DESIGN philosophy: **CLARIFICATION OVER ASSUMPTION**. The AI assistant will no longer default to conservative programming when information is ambiguous. Instead, it will ask clarifying questions and optimize for performance based on the user's actual context and goals.

This ensures that serious athletes, competitive lifters, and dedicated trainees receive appropriate programming that matches their capacity and intent, rather than being under-programmed due to conservative assumptions.

**Operating Principle:** "When in doubt, ASK. When competitive, OPTIMIZE. When ambiguous, BIAS TOWARD PERFORMANCE."

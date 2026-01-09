# AI Prompt Generation Scope Contract (Revised v3 - Coach-Grade)

## Overview

This document describes the coach-grade training program design system implemented in the AI prompt template in BlockGeneratorView.swift. The system prioritizes schema correctness as non-negotiable while ensuring training program quality through structured analysis and decision-making.

**Latest Update (v3):** Complete redesign focused on coach-grade program design with:
- Entropy detection (LOW/HIGH)
- Goal stimulus identification
- Pre-scope sufficiency analysis (MEU/MRU)
- Unit justification requirements
- Hard failure conditions for invalid programming
- Schema compliance as mandatory, training decisions as flexible

## Problem Statement

Previous versions of the AI prompt:
- Exposed internal coaching concepts (MEU/MRU) to users
- Asked users to define volume parameters they shouldn't need to understand
- Made the AI assistant seem less autonomous and knowledgeable

## Solution: Coach-Grade Training Program Design System with Agent-Owned Volume

A structured design process has been implemented that:
1. **Classifies entropy** to identify complexity level
2. **Identifies goal stimulus** to ensure training clarity
3. **Analyzes sufficiency internally** to prevent overreaching (without exposing metrics)
4. **Justifies decisions briefly** in user-friendly terms
5. **Enforces schema compliance** as mandatory
6. **Provides failure conditions** to catch invalid programs
7. **Owns volume and recovery decisions** as the expert coach

### Core Principle

**"The AI assistant owns volume, intensity, and recovery decisions. MEU/MRU are internal reasoning tools, not exposed to users unless explaining a safety or recovery concern. Schema correctness remains non-negotiable."**

## Contract Components

### 1. ENTROPY DETECTION

The AI must classify each request as:
- **LOW entropy**: Single workout, straightforward requirements
- **HIGH entropy**: Multi-day, multi-week, curriculum, protocol, or hybrid (strength + skill + conditioning)

If HIGH entropy, all subsequent steps are **mandatory**.

### 2. SCOPE SUMMARY (INITIAL)

For HIGH-ENTROPY requests, the AI must classify:

```
contentType: workout | seminar | course | curriculum | protocol | other
primaryItem: exercise | technique | drill | concept | task | skill
mediaImpact: low | medium | high
```

This classification guides subsequent decisions about scope and media handling.

### 3. GOAL STIMULUS

The AI must identify and document:

```
Primary Stimulus: [e.g., strength, hypertrophy, conditioning, skill acquisition]
Secondary Stimulus: [e.g., conditioning, mobility]
Tertiary Stimulus (optional): [additional training goals]
```

**Critical Rule**: If goal stimulus is unclear or contradictory, the AI must **STOP** and ask for clarification rather than proceeding.

### 4. PRE-SCOPE SUFFICIENCY ANALYSIS (INTERNAL - NOT EXPOSED)

The AI must internally analyze:

1. **Minimum effective volume**: What is the minimum volume needed to address the primary stimulus?
2. **Maximum recoverable volume**: What is the maximum volume the athlete can recover from given their level, frequency, and block length?
3. **Time constraints**: Does the session duration support the proposed work?
4. **Interference**: Do secondary/tertiary stimuli interfere with the primary stimulus?

**Critical Rule**: This analysis is INTERNAL reasoning only. DO NOT:
- Ask the user to define MEU or MRU
- Expose these terms in output unless explaining a safety/recovery issue
- Request volume parameters from the user

The AI owns these decisions and adjusts programming automatically based on:
- Stated goal
- Athlete experience level
- Training frequency
- Block length
- Available session time

This prevents:
- Insufficient volume
- Overreaching
- Time constraint violations
- Training interference

### 5. UNIT JUSTIFICATION

Before generating JSON, the AI must output (in user-friendly terms):

```
Primary Stimulus: [identified stimulus]
Chosen Units per Session: [number with brief rationale]
Rejected Alternatives (if significant): [what was considered but not included, and why]
Final Justification (brief): [why this approach serves the primary stimulus]
```

This ensures transparency without exposing internal metrics like MEU/MRU.
Focus on training outcomes rather than volume formulas.

### 6. QUESTION GATE (OPTIONAL)

For HIGH-ENTROPY requests (unless user says "use defaults"):

The AI MAY ask clarifying questions if genuinely needed:
1. **Session duration**: short (20–30), moderate (45–60), long (90+)
2. **Detail depth**: brief | moderate | detailed
3. **Structure**: identical | progressive | rotational
4. **Video policy** (ONLY if mediaImpact = high): Ask video policy

**DO NOT ask about**:
- Volume parameters (unit counts, exercise density)
- Recovery capacity
- Intensity levels (unless truly ambiguous)

The AI owns volume and recovery decisions based on stated goal, athlete level, frequency, and block length.

### 7. SMART DEFAULTS

**ONLY IF QUESTIONS SKIPPED**

The AI determines appropriate volume based on:
- **Goal**: Strength goals typically need 2-4 main exercises
- **Athlete level**: Beginners need less volume than advanced
- **Session duration**: Available time constrains volume
- **Recovery capacity**: Adjust based on frequency and intensity

If conditioning or skill is appended to strength:
- Adjust total volume to preserve training quality and recovery
- Place conditioning after strength to prioritize main stimulus

General defaults:
- UnitDuration = moderate
- DetailDepth = medium
- StructureConsistency = identical unless progression is implied
- MediaPolicy = none if mediaImpact = low

### 8. SCOPE SUMMARY (FINAL)

After analysis and questions (or defaults), the AI must output:

```
contentType: [value]
primaryItem: [value]
mediaImpact: [value]
unitDuration: [value]
unitsPerSession: [value]
detailDepth: [value]
structureConsistency: [value]
```

**After FINAL SCOPE LOCK:**
- No scope changes allowed
- No unit additions allowed
- No schema reshaping allowed

### 9. SCHEMA PRIORITY RULES

These rules are **absolute**:
- Never alter schema shape, field names, required fields, or types
- Never add filler units to appear complete
- Reduce scope or ask questions instead
- Schema compliance is mandatory

### 10. HARD FAILURE CONDITIONS

The AI must **STOP AND ASK** if:
- The requested volume cannot be recovered from given athlete level, frequency, and intensity
- Session duration is insufficient for the requested work
- Secondary work would significantly undermine the primary stimulus
- The program structure would compromise training quality or safety
- Schema compliance cannot be maintained

**When explaining failures**:
- Focus on training outcomes (e.g., "This volume may compromise recovery")
- Avoid internal metrics terminology
- Suggest practical alternatives
- Ask for user preference

**Operating Principle**: "You own volume and recovery decisions. Prioritize training quality and long-term progress. Adjust programming automatically when needed, with brief justification."

## Benefits

1. **Agent Autonomy**: AI owns volume/recovery decisions like a real coach
2. **User Experience**: Users don't need to understand MEU/MRU concepts
3. **Schema Compliance**: Non-negotiable schema enforcement prevents parsing errors
4. **Transparency**: Brief justifications explain decisions in user-friendly terms
5. **Failure Prevention**: Hard failure conditions catch issues and suggest alternatives
6. **Training Quality**: Automatic adjustments prioritize long-term progress
7. **Recovery Optimization**: Internal analysis prevents overreaching without exposing formulas
8. **Time Management**: Duration checks ensure programs fit available time

## Implementation Location

The contract is in `BlockGeneratorView.swift` in the `aiPromptTemplate(withRequirements:)` function, positioned at the start of the prompt after user requirements.

```swift
private func aiPromptTemplate(withRequirements requirements: String?) -> String {
    // ...
    return """
    You are a coach-grade training program designer...
    
    MY REQUIREMENTS:
    \(requirementsText)
    
    ═══════════════════════════════════════════════════════════════
    ENTROPY DETECTION AND SCOPE CONTRACT (REQUIRED)
    ═══════════════════════════════════════════════════════════════
    
    [Contract content with all sections]
    
    ═══════════════════════════════════════════════════════════════
    
    IMPORTANT - JSON Format Specification:
    [Rest of prompt...]
    """
}
```

## Usage

Users will interact with the system by:
1. Providing requirements in the BlockGeneratorView input field
2. Copying the complete prompt using "Copy Complete Prompt"
3. Pasting into ChatGPT, Claude, or other AI assistant
4. Responding to questions if HIGH-ENTROPY is detected
5. Receiving structured output with SCOPE SUMMARY and UNIT JUSTIFICATION
6. Getting valid JSON that conforms to the schema

## Testing

To verify the contract is working:

### Test Case 1: LOW-ENTROPY Request
- **Input**: "Create a single upper body workout"
- **Expected**: AI skips questions, uses smart defaults, generates JSON directly

### Test Case 2: HIGH-ENTROPY with Strength Focus
- **Input**: "Create a 4-week strength block"
- **Expected**:
  1. Entropy: HIGH
  2. SCOPE SUMMARY (INITIAL) with contentType: workout, primaryItem: exercise, mediaImpact: low
  3. GOAL STIMULUS: Primary = strength
  4. PRE-SCOPE SUFFICIENCY: Internal analysis (not shown)
  5. May ask clarifying questions OR use smart defaults
  6. UNIT JUSTIFICATION with brief reasoning (no MEU/MRU exposure)
  7. SCOPE SUMMARY (FINAL)
  8. Valid JSON with appropriate exercise count (2-4 per session based on internal analysis)

### Test Case 3: HIGH-ENTROPY with Interference
- **Input**: "4-week block with heavy squats, deadlifts, AND high-volume conditioning"
- **Expected**:
  1. Entropy: HIGH
  2. GOAL STIMULUS: Primary = strength, Secondary = conditioning
  3. INTERFERENCE CHECK: Flags that high-volume conditioning may interfere with strength
  4. Either: Asks clarification OR automatically reduces conditioning volume
  5. UNIT JUSTIFICATION explains adjustment without exposing MEU/MRU

### Test Case 4: Hard Failure - Excessive Volume
- **Input**: "30-minute session with 8 heavy compound lifts"
- **Expected**:
  1. PRE-SCOPE SUFFICIENCY: Internal analysis identifies issue
  2. HARD FAILURE: Excessive volume for time and recovery
  3. AI stops and explains: "This volume cannot be recovered from and 30 min is insufficient"
  4. Suggests alternatives without using MEU/MRU terminology

### Test Case 5: BJJ Curriculum (Segments)
- **Input**: "8-week BJJ guard curriculum"
- **Expected**:
  1. Entropy: HIGH
  2. SCOPE SUMMARY: contentType = curriculum, primaryItem = technique, mediaImpact = medium/high
  3. GOAL STIMULUS: Primary = skill (guard techniques)
  4. Asks about video policy if mediaImpact = high
  5. Uses segment-based format instead of exercises
  6. Valid JSON with technique segments

### Validation Checklist
- [ ] Entropy correctly classified (LOW/HIGH)
- [ ] SCOPE SUMMARY (INITIAL) provided for HIGH entropy
- [ ] GOAL STIMULUS identified
- [ ] PRE-SCOPE SUFFICIENCY analysis performed internally (not exposed)
- [ ] UNIT JUSTIFICATION provided before JSON (brief, user-friendly)
- [ ] No MEU/MRU terminology exposed to user
- [ ] Volume decisions made automatically by AI
- [ ] SCOPE SUMMARY (FINAL) shown
- [ ] Hard failures explain issues in training terms, not internal metrics
- [ ] Schema compliance maintained
- [ ] JSON parses successfully in the app

## Future Enhancements

Potential improvements:
- Auto-detect MEU/MRU based on goal and experience level
- Provide built-in interference matrices for common goal combinations
- Track historical unit counts to refine MEU/MRU recommendations
- Add validation warnings if generated output violates sufficiency analysis
- Implement server-side MEU/MRU calculation
- Add preset stimulus profiles (e.g., "powerlifting", "CrossFit", "bodybuilding")
- Include recovery capacity estimation based on training age

## Key Differences from Previous Version

### What Changed:
1. **Volume Ownership**: AI now owns volume/recovery decisions (not user-defined)
2. **MEU/MRU Internal**: These concepts are now internal reasoning tools, not exposed
3. **Question Gate Simplified**: Removed volume/density questions
4. **Unit Justification Simplified**: No longer exposes MEU/MRU values
5. **Hard Failures User-Friendly**: Explain issues in training terms, not formulas
6. **Agent Autonomy**: AI acts more like an expert coach, less like a question-asking assistant
7. **Focus**: "Determine appropriate volume based on context" vs "Ask user for volume parameters"

### What Stayed:
- Entropy detection (LOW/HIGH)
- SCOPE SUMMARY (INITIAL and FINAL)
- Media impact classification
- JSON schema (unchanged)
- Segment vs Exercise structure support
- Schema compliance as non-negotiable

### Philosophy Change:
- **Old**: "Ask questions including volume parameters, expose MEU/MRU analysis"
- **New**: "Own volume/recovery decisions as the expert, use MEU/MRU internally only, adjust automatically with brief justification"

This shift makes the AI assistant feel more like an experienced strength coach who understands programming principles and makes informed decisions, rather than a passive tool that needs user input for everything.


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

Previous versions of the AI prompt allowed:
- Overly complex or inconsistent segment structures
- Unclear training stimulus priorities
- Unit counts that exceeded recoverable capacity
- Conflicts between training goals and program structure
- Schema violations when attempting to express training concepts

## Solution: Coach-Grade Training Program Design System

A structured design process has been implemented that:
1. **Classifies entropy** to identify complexity level
2. **Identifies goal stimulus** to ensure training clarity
3. **Analyzes sufficiency** to prevent overreaching
4. **Justifies unit selection** before generation
5. **Enforces schema compliance** as mandatory
6. **Provides failure conditions** to catch invalid programs

### Core Principle

**"Schema correctness is NON-NEGOTIABLE. Training correctness determines unit selection and content. If there is conflict, reduce scope (fewer units) or ask clarifying questions. Never break the schema."**

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

### 4. PRE-SCOPE SUFFICIENCY ANALYSIS

Before generating content, the AI must analyze:

1. **Minimum Effective Units (MEU)**: What is the minimum number of exercises/techniques needed to address the primary stimulus?
2. **Maximum Recoverable Units (MRU)**: What is the maximum number of exercises/techniques the athlete can recover from?
3. **Time Constraint Check**: Does the session duration support the proposed work?
4. **Interference Check**: Do secondary/tertiary stimuli interfere with the primary stimulus?

This analysis prevents:
- Insufficient volume (below MEU)
- Overreaching (above MRU)
- Time constraint violations
- Training interference

### 5. UNIT JUSTIFICATION

Before generating JSON, the AI must output:

```
Primary Stimulus: [identified stimulus]
MEU per Session: [number]
MRU per Session: [number]
Chosen Units per Session: [number with rationale]
Rejected Alternatives: [what was considered but not included, and why]
Final Justification: [why this unit count serves the primary stimulus]
```

This ensures transparency and forces the AI to think through programming decisions.

### 6. QUESTION GATE

For HIGH-ENTROPY requests (unless user says "use defaults"):

1. **Session duration**: short (20–30), moderate (45–60), long (90+)
2. **Unit density**: few (2–3), moderate (4–5), many (6+)
3. **Detail depth**: brief | moderate | detailed
4. **Structure**: identical | progressive | rotational
5. **Video policy** (ONLY if mediaImpact = high): Ask video policy

### 7. SMART DEFAULTS

**ONLY IF QUESTIONS SKIPPED**

If Primary Stimulus = strength:
- MEU = 1 main lift + 1 secondary lift
- MRU = 3 heavy lifts
- Default units per session = 2

If conditioning or skill is appended:
- Cap total units to preserve output quality
- Place conditioning after strength

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
- MEU > MRU (impossible to satisfy minimum while respecting maximum)
- Session duration cannot support MEU (time constraint violation)
- Primary stimulus is undermined by secondary work (training interference)
- Unit count cannot be justified (arbitrary selection)
- Schema compliance cannot be maintained (format violation)

**Operating Principle**: "The number of units is a training decision, schema compliance is mandatory."

## Benefits

1. **Training Correctness**: MEU/MRU analysis prevents under- and over-programming
2. **Schema Compliance**: Non-negotiable schema enforcement prevents parsing errors
3. **Transparency**: Unit justification makes programming decisions explicit
4. **Failure Prevention**: Hard failure conditions catch invalid programs before generation
5. **Flexibility**: Training decisions remain flexible while schema remains fixed
6. **Clarity**: Goal stimulus identification ensures programs address actual needs
7. **Recovery Optimization**: MRU checks prevent overreaching
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
  4. PRE-SCOPE SUFFICIENCY: MEU = 2 (main + secondary), MRU = 3
  5. Asks 5 questions (or uses smart defaults if "skip questions")
  6. UNIT JUSTIFICATION with reasoning
  7. SCOPE SUMMARY (FINAL)
  8. Valid JSON with 2-3 exercises per session

### Test Case 3: HIGH-ENTROPY with Interference
- **Input**: "4-week block with heavy squats, deadlifts, AND high-volume conditioning"
- **Expected**:
  1. Entropy: HIGH
  2. GOAL STIMULUS: Primary = strength, Secondary = conditioning
  3. INTERFERENCE CHECK: Flags that high-volume conditioning may interfere with strength
  4. Either: Asks clarification OR reduces conditioning volume
  5. UNIT JUSTIFICATION explains interference mitigation

### Test Case 4: Hard Failure - MEU > MRU
- **Input**: "30-minute session with 8 heavy compound lifts"
- **Expected**:
  1. PRE-SCOPE SUFFICIENCY: Identifies MEU = 8, MRU = 3, Duration = 30 min
  2. HARD FAILURE: MEU > MRU
  3. AI stops and asks: "This request cannot be satisfied. Would you like to reduce exercise count or increase session duration?"

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
- [ ] PRE-SCOPE SUFFICIENCY analysis shown
- [ ] UNIT JUSTIFICATION provided before JSON
- [ ] SCOPE SUMMARY (FINAL) shown
- [ ] Hard failures trigger questions instead of invalid output
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
1. **Focus shift**: From "asking questions" to "training correctness analysis"
2. **New requirement**: MEU/MRU analysis before generation
3. **New requirement**: UNIT JUSTIFICATION output
4. **New requirement**: HARD FAILURE conditions
5. **New rule**: Schema compliance is non-negotiable (previously could be bent)
6. **Simplified**: Removed verbose question policy, replaced with streamlined QUESTION GATE
7. **Enhanced**: SMART DEFAULTS now include training-specific logic (strength vs skill)

### What Stayed:
- Entropy detection (LOW/HIGH)
- SCOPE SUMMARY (INITIAL and FINAL)
- Media impact classification
- JSON schema (unchanged)
- Segment vs Exercise structure support

### Philosophy Change:
- **Old**: "Ask lots of questions to get user input"
- **New**: "Analyze training correctness first, reduce scope if needed, schema is mandatory"

This shift reflects a more coach-like approach where the AI acts as a knowledgeable program designer rather than just a JSON generator.


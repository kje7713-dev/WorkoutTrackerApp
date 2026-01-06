# AI Prompt Generation Scope Contract (Revised)

## Overview

This document describes the revised Generation Scope Contract added to the AI prompt template in BlockGeneratorView.swift to address issues with ChatGPT generating overly complex or inconsistent segment structures.

## Problem Statement

ChatGPT was finding the segment structure too flexible, resulting in:
- Inconsistent schema shapes across generated units
- Overly verbose descriptions that could overwhelm the parser
- Performance issues with extremely large or complex outputs
- Unpredictable use of optional fields across different days/weeks
- Unclear handling of media content (videos, images, etc.)

## Solution: Revised Generation Scope Contract

A structured contract has been added to the AI prompt that establishes clear constraints before generation begins. The revised version includes enhanced scope validation and media handling.

### Contract Components

#### 1. HIGH-ENTROPY Detection
The AI must first identify if the user's request is "HIGH-ENTROPY", which includes:
- Multi-day programs
- Curriculum or course structures
- Long-term training programs
- Series of related sessions

#### 2. SCOPE VALIDATION (Mandatory for High-Entropy)
Before generating JSON, the AI must:

**A) Classify contentType:**
- workout | seminar | course | curriculum | protocol | other

**B) Classify mediaImpact:**
- low | medium | high
- Guidance: mediaImpact is at least "medium" for seminar/course/curriculum/protocol
- Usually "low" for simple strength blocks unless videos were requested

**C) Identify the "Primary Item":**
- The main repeatable unit inside a session
- Examples: technique, exercise, concept, drill, task, skill

**D) Print a SCOPE SUMMARY:**
A 3-5 line summary using chosen defaults/policy:
- contentType: <value>
- primaryItem: <value>
- mediaImpact: <value>
- mediaPolicy: <value>
- unitDuration: <value>
- itemsPerUnit: <value>
- detailDepth: <value>
- structureConsistency: <value>

Users can correct any line in the SCOPE SUMMARY before JSON generation.

#### 3. Defaults
If the user doesn't answer scoping questions, these defaults apply:
- **UnitDuration**: moderate
- **ItemsPerUnit**: low (2 primary items)
- **DetailDepth**: medium
- **StructureConsistency**: identical structure across units

#### 4. Media Defaults (Conditional)
Media handling varies based on mediaImpact classification:

**If mediaImpact == low:**
- Media: none

**If mediaImpact == medium:**
- Media: limited (1 video per Primary Item)

**If mediaImpact == high:**
- AI asks exactly 1 question: "Video policy: none | 1 per session | 1 per primary item | per primary item (multiple)?"
- If unanswered: default to "1 per primary item"

#### 5. Questions Policy
- Ask at most 5 questions total
- Ask questions ONLY if they materially affect output size or structure
- Do NOT ask questions for minor preferences; use sensible defaults
- If SCOPE SUMMARY looks correct and mediaImpact != high, proceed directly to JSON

#### 6. Rules
Strict rules to ensure consistency:
- **No optional fields** unless used consistently across ALL units
- **120 character limit** per descriptive text field
- **Units differ by content**, not schema shape
- **Cached file rendering** for performance-intensive outputs
- **Ambiguous requests**: prefer defaults + brief SCOPE SUMMARY over extra questions

## Benefits

1. **Consistency**: All generated units follow the same schema structure
2. **Performance**: Limits output size to manageable levels
3. **Predictability**: Clear defaults ensure the AI knows what to generate when details are unclear
4. **Quality**: Forces the AI to be concise and focused
5. **Media Management**: Conditional media policies prevent over-generation of video links while supporting rich content when needed
6. **Scope Transparency**: SCOPE SUMMARY provides users visibility into the AI's classification and defaults before generation
7. **Reduced Back-and-Forth**: Clear questions policy minimizes unnecessary clarification rounds

## Implementation Location

The contract is inserted in `BlockGeneratorView.swift` in the `aiPromptTemplate(withRequirements:)` function, positioned immediately after the user requirements and before the JSON format specification.

```swift
private func aiPromptTemplate(withRequirements requirements: String?) -> String {
    // ...
    return """
    I need you to generate a workout block in JSON format...
    
    MY REQUIREMENTS:
    \(requirementsText)
    
    ═══════════════════════════════════════════════════════════════
    GENERATION SCOPE CONTRACT (REQUIRED) — REVISED
    ═══════════════════════════════════════════════════════════════
    
    [Contract content with SCOPE VALIDATION, DEFAULTS, MEDIA DEFAULTS, 
     QUESTIONS POLICY, and RULES sections]
    
    ═══════════════════════════════════════════════════════════════
    
    IMPORTANT - JSON Format Specification:
    [Rest of prompt...]
    """
}
```

## Usage

Users will see the contract when they:
1. Expand the "Preview Full Prompt" disclosure group in the BlockGeneratorView
2. Copy the complete prompt using the "Copy Complete Prompt" button
3. Use the prompt with ChatGPT, Claude, or other AI assistants

The AI assistant will read the contract and apply its constraints during generation, resulting in more consistent and manageable workout block structures.

## Testing

To verify the contract is working:
1. Generate a multi-week, multi-day program using the AI prompt
2. Verify the AI provides a SCOPE SUMMARY before generating JSON
3. Check that all days have consistent field usage
4. Verify descriptive text is concise (≤120 chars per field)
5. Confirm optional fields appear consistently or not at all
6. Validate media content adheres to the declared mediaPolicy
7. Ensure contentType and primaryItem classifications are appropriate
8. Validate the JSON parses successfully in the app

## Future Enhancements

Potential improvements:
- Add user-configurable defaults in app settings
- Provide preset scoping profiles (e.g., "minimal", "standard", "detailed")
- Track which scoping defaults were applied for user feedback
- Add validation warnings if generated output violates contract rules
- Allow users to save custom SCOPE SUMMARY templates
- Implement server-side validation of media policies

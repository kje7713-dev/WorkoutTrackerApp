# AI Prompt Generation Scope Contract (Revised v2)

## Overview

This document describes the revised Generation Scope Contract added to the AI prompt template in BlockGeneratorView.swift to address issues with ChatGPT generating overly complex or inconsistent segment structures.

**Latest Update:** The contract now requires the AI to **always ask 5 scoping questions** for HIGH-ENTROPY requests, and only use defaults if the user fails to answer the questions. This ensures better user control and more appropriate outputs.

## Problem Statement

ChatGPT was finding the segment structure too flexible, resulting in:
- Inconsistent schema shapes across generated units
- Overly verbose descriptions that could overwhelm the parser
- Performance issues with extremely large or complex outputs
- Unpredictable use of optional fields across different days/weeks
- Unclear handling of media content (videos, images, etc.)
- AI jumping to defaults without user input for complex requests

## Solution: Revised Generation Scope Contract

A structured contract has been added to the AI prompt that establishes clear constraints before generation begins. The revised version includes enhanced scope validation, mandatory questioning for high-entropy requests, and media handling.

### Contract Components

#### 1. HIGH-ENTROPY Detection
The AI must first identify if the user's request is "HIGH-ENTROPY", which includes:
- Multi-day programs
- Curriculum or course structures
- Long-term training programs
- Series of related sessions

#### 2. SCOPE VALIDATION (Mandatory for High-Entropy)
For HIGH-ENTROPY requests, the AI must:

**A) Classify contentType:**
- workout | seminar | course | curriculum | protocol | other

**B) Classify mediaImpact:**
- low | medium | high
- Guidance: mediaImpact is at least "medium" for seminar/course/curriculum/protocol
- Usually "low" for simple strength blocks unless videos were requested

**C) Identify the "Primary Item":**
- The main repeatable unit inside a session
- Examples: technique, exercise, concept, drill, task, skill

**D) Print an INITIAL SCOPE SUMMARY:**
Shows the classification before asking questions:
- contentType: <value>
- primaryItem: <value>
- mediaImpact: <value>

**E) Ask the 5 REQUIRED QUESTIONS** (see Questions Policy below)

**F) Print a FINAL SCOPE SUMMARY:**
Shows all parameters after receiving user answers (or applying defaults if no answer):
- contentType: <value>
- primaryItem: <value>
- mediaImpact: <value>
- mediaPolicy: <value>
- unitDuration: <value>
- itemsPerUnit: <value>
- detailDepth: <value>
- structureConsistency: <value>

**G) Generate the JSON** based on the final scope.

#### 3. Defaults (Applied Only When User Doesn't Answer)
These defaults are used **ONLY** when the user fails to answer the 5 required questions:
- **UnitDuration**: moderate
- **ItemsPerUnit**: low (2 primary items)
- **DetailDepth**: medium
- **StructureConsistency**: identical structure across units

**Important:** For HIGH-ENTROPY requests, the AI must first ask the questions and wait for user input before applying defaults.

#### 4. Media Defaults (Conditional)
Media handling varies based on mediaImpact classification:

**If mediaImpact == low:**
- Media: none

**If mediaImpact == medium:**
- Media: limited (1 video per Primary Item)

**If mediaImpact == high:**
- AI asks exactly 1 question: "Video policy: none | 1 per session | 1 per primary item | per primary item (multiple)?"
- If unanswered: default to "1 per primary item"

#### 5. Questions Policy (Mandatory for High-Entropy)
For **HIGH-ENTROPY** requests, the AI **MUST** ask these questions before generating JSON:

**Question 1:** "Unit Duration - How long should each session/unit be? (short/moderate/long)"

**Question 2:** "Items Per Unit - How many primary items per session? (low: 2-3 | medium: 4-5 | high: 6+)"

**Question 3:** "Detail Depth - How detailed should the descriptions be? (brief/medium/detailed)"

**Question 4:** "Structure Consistency - Should all units follow identical structure? (yes/no, if no: describe variation)"

**Question 5 (conditional):** Only asked if mediaImpact is 'high': "Video policy: none | 1 per session | 1 per primary item | per primary item (multiple)?"

**Important Rules:**
- For HIGH-ENTROPY requests, these questions are **REQUIRED** before generating JSON
- The AI should wait for user responses to these questions
- If the user explicitly says "use defaults" or "skip questions", then apply the DEFAULTS
- If the user provides partial answers, ask only the unanswered questions again
- For LOW-ENTROPY requests (single workout), skip questions and use defaults directly

**Media-specific behavior:**
- If mediaImpact == low: Skip Question 5, use "Media: none"
- If mediaImpact == medium: Skip Question 5, use "Media: limited (1 video per Primary Item)"
- If mediaImpact == high: Ask Question 5

#### 6. Rules
Strict rules to ensure consistency:
- **No optional fields** unless used consistently across ALL units
- **120 character limit** per descriptive text field
- **Units differ by content**, not schema shape
- **Cached file rendering** for performance-intensive outputs
- **For HIGH-ENTROPY requests**: Asking the 5 questions is MANDATORY before generating JSON
- **Only use defaults** if the user explicitly chooses defaults or fails to respond to questions

## Benefits

1. **User Control**: Users are always asked for their preferences on HIGH-ENTROPY requests, ensuring outputs match their needs
2. **Consistency**: All generated units follow the same schema structure
3. **Performance**: Limits output size to manageable levels through scoping questions
4. **Predictability**: Clear defaults ensure the AI knows what to generate when users don't answer
5. **Quality**: Forces the AI to be concise and focused
6. **Media Management**: Conditional media policies prevent over-generation of video links while supporting rich content when needed
7. **Scope Transparency**: Initial and Final SCOPE SUMMARY provide users visibility into the AI's classification and chosen parameters
8. **Better Engagement**: AI actively seeks user input for complex requests rather than making assumptions

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
2. Verify the AI provides an **INITIAL SCOPE SUMMARY** showing classification
3. Verify the AI **asks the 5 required questions** (or 4 if mediaImpact is not 'high')
4. Verify the AI **waits for user answers** before proceeding
5. Verify the AI provides a **FINAL SCOPE SUMMARY** with all parameters
6. Check that all days have consistent field usage
7. Verify descriptive text is concise (≤120 chars per field)
8. Confirm optional fields appear consistently or not at all
9. Validate media content adheres to the declared mediaPolicy
10. Ensure contentType and primaryItem classifications are appropriate
11. Validate the JSON parses successfully in the app

**Test Case 1: HIGH-ENTROPY with user answers**
- Input: "Create a 4-week BJJ curriculum"
- Expected: AI shows INITIAL SCOPE SUMMARY, asks questions, waits for answers, shows FINAL SCOPE SUMMARY, generates JSON

**Test Case 2: HIGH-ENTROPY with defaults**
- Input: "Create a 4-week BJJ curriculum" followed by "use defaults"
- Expected: AI shows INITIAL SCOPE SUMMARY, asks questions, user says "use defaults", AI shows FINAL SCOPE SUMMARY with default values, generates JSON

**Test Case 3: LOW-ENTROPY**
- Input: "Create a single upper body workout"
- Expected: AI skips questions, uses defaults, generates JSON directly

## Future Enhancements

Potential improvements:
- Add user-configurable defaults in app settings
- Provide preset scoping profiles (e.g., "minimal", "standard", "detailed")
- Track which scoping defaults were applied for user feedback
- Add validation warnings if generated output violates contract rules
- Allow users to save custom SCOPE SUMMARY templates
- Implement server-side validation of media policies

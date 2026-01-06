# AI Prompt Generation Scope Contract

## Overview

This document describes the Generation Scope Contract added to the AI prompt template in BlockGeneratorView.swift to address issues with ChatGPT generating overly complex or inconsistent segment structures.

## Problem Statement

ChatGPT was finding the segment structure too flexible, resulting in:
- Inconsistent schema shapes across generated units
- Overly verbose descriptions that could overwhelm the parser
- Performance issues with extremely large or complex outputs
- Unpredictable use of optional fields across different days/weeks

## Solution: Generation Scope Contract

A structured contract has been added to the AI prompt that establishes clear constraints before generation begins.

### Contract Components

#### 1. HIGH-ENTROPY Detection
The AI must first identify if the user's request is "HIGH-ENTROPY", which includes:
- Multi-day programs
- Curriculum or course structures
- Long-term training programs
- Series of related sessions

#### 2. Scoping Questions
For HIGH-ENTROPY requests, the AI should ask up to 5 scoping questions that materially affect:
- Output size
- Structure complexity
- Content depth

Examples:
- "How many days per week?"
- "What level of detail for technique descriptions?"
- "Should each week have identical structure or progressive variation?"

#### 3. Defaults
If the user doesn't answer scoping questions, these defaults apply:
- **UnitDuration**: moderate
- **ItemsPerUnit**: low (2 primary items)
- **DetailDepth**: medium
- **Media**: none
- **StructureConsistency**: identical structure across units

#### 4. Rules
Strict rules to ensure consistency:
- **No optional fields** unless used consistently across ALL units
- **120 character limit** per descriptive text field
- **Units differ by content**, not schema shape
- **Cached file rendering** for performance-intensive outputs

## Benefits

1. **Consistency**: All generated units follow the same schema structure
2. **Performance**: Limits output size to manageable levels
3. **Predictability**: Clear defaults ensure the AI knows what to generate when details are unclear
4. **Quality**: Forces the AI to be concise and focused

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
    GENERATION SCOPE CONTRACT (REQUIRED)
    ═══════════════════════════════════════════════════════════════
    
    [Contract content here]
    
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
2. Check that all days have consistent field usage
3. Verify descriptive text is concise (≤120 chars per field)
4. Confirm optional fields appear consistently or not at all
5. Validate the JSON parses successfully in the app

## Future Enhancements

Potential improvements:
- Add user-configurable defaults in app settings
- Provide preset scoping profiles (e.g., "minimal", "standard", "detailed")
- Track which scoping defaults were applied for user feedback
- Add validation warnings if generated output violates contract rules

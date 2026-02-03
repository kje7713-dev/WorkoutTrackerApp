# Video Policy Enforcement Rules - Implementation Summary

## Overview
Implemented comprehensive VIDEO POLICY enforcement rules in the AI prompt template to ensure proper video inclusion in workout programs when needed.

## Changes Made

### 1. Added VIDEO POLICY Section to AI Prompt
**Location**: `BlockGeneratorView.swift` - `aiPromptTemplate()` function

Added a new major section titled "VIDEO POLICY — ENFORCEMENT RULES (NON-NEGOTIABLE)" that defines:

#### A) REQUIRED OUTPUT (BEFORE JSON)
- AI must output a VIDEO_DECISION header before generating JSON
- Header format:
  ```
  VIDEO_DECISION:
  included: YES|NO
  mediaImpact: low|medium|high
  requiredSkills: <comma-separated list or NONE>
  rationale: <1–2 sentences>
  ```

#### B) VIDEO REQUIRED CONDITIONS (NO DISCRETION)
Three specific conditions that automatically trigger video inclusion:
1. True beginner learning skill for the first time
2. Foundational motor pattern where early errors compound
3. Timing-dependent phases difficult to convey via text alone

**Critical**: If ANY condition is true and AI sets included = NO → INVALID RESPONSE

#### C) MINIMUM VIDEO REQUIREMENT
- When VIDEO_DECISION.included = YES:
  - Must embed at least 1 video for EACH item in requiredSkills
  - Use existing schema fields only:
    - For segments: `techniques[].videoUrls[]` OR `media.videoUrl`
    - For exercises: `videoUrls[]`
  - No new schema fields allowed

**Validation**: If included=YES and requiredSkills != NONE but any skill has 0 videos → INVALID RESPONSE

#### D) MINIMALISM (ANTI-BLOAT)
- Use 1 canonical video per required skill (max 2 if breakdown needed)
- Total videos SHOULD be <= 6 unless explicitly requested
- No decorative videos unrelated to requiredSkills

#### E) ANTI-LAZINESS / NO JSON-SIMPLIFICATION EXCUSE
AI may NOT omit required videos or downgrade mediaImpact to:
- Shorten JSON
- Reduce schema complexity
- Avoid using media/video fields
- Make artifact generation easier

"JSON convenience" is never a valid reason to exclude videos.

#### F) OMISSION PATH
- Only valid when none of the Video Required Conditions are true
- Must explain in VIDEO_DECISION.rationale why video is not necessary

### 2. Updated Question Gate Section
**Line ~716**: Updated clarifying questions list
- Removed: "Video policy (ONLY if mediaImpact = high): Ask video policy preference"
- Added note: "Video inclusion is now enforced by VIDEO POLICY rules"
- AI should NOT ask about video preferences - follow VIDEO REQUIRED CONDITIONS automatically

### 3. Updated Smart Defaults Section
**Line ~757**: Removed MediaPolicy default setting
- Old: `MediaPolicy = none if mediaImpact = low`
- New: Note that MediaPolicy is enforced by VIDEO POLICY rules, not a default setting

## Schema Integration

The video policy uses existing schema fields:

### For Exercises (Strength/Conditioning):
```swift
public struct ImportedExercise: Codable {
    ...
    public var videoUrls: [String]?  // Line 257 in BlockGenerator.swift
}
```

### For Segments (Skill-based training):
```swift
public struct ImportedTechnique: Codable {
    ...
    public var videoUrls: [String]?  // Line 134 in BlockGenerator.swift
}

public struct ImportedMedia: Codable {
    public var videoUrl: String?  // Line 205 in BlockGenerator.swift
}
```

## Validation Points

The VIDEO POLICY creates three validation checkpoints:

1. **Header Presence**: AI response without VIDEO_DECISION header = INVALID
2. **Condition Enforcement**: If any condition true but included=NO = INVALID
3. **Video Presence**: If included=YES and requiredSkills specified but videos missing = INVALID

## Examples of Video Required Conditions

### Condition 1 - True Beginner
- "Create a surfing program for someone who has never stood up on a board"
- Must include videos for pop-up technique

### Condition 2 - Foundational Motor Pattern
- "Teach deadlift to new lifters"
- Must include videos for hip hinge pattern

### Condition 3 - Timing-Dependent
- "Teach Olympic lifts (snatch, clean & jerk)"
- Complex timing phases require video demonstration

## Testing Recommendations

To validate the implementation:

1. **Test with beginner programs**: Verify VIDEO_DECISION header appears and videos are included
2. **Test with high-frequency programs**: Verify 4+ days/week triggers video inclusion
3. **Test with standard programs**: Verify videos can be omitted when conditions not met
4. **Test video count**: Verify minimalism (1-2 videos per skill, total <= 6)
5. **Verify schema compliance**: Ensure videos use only existing schema fields

## Impact on User Experience

### For Users Creating Prompts:
- More consistent video inclusion in appropriate programs
- Better support for beginner-friendly content
- Clearer expectations about when videos will be included

### For AI Assistants:
- Clear, non-negotiable rules about video inclusion
- Structured output format with VIDEO_DECISION header
- Explicit validation checkpoints to prevent lazy omissions

## Files Modified

1. `BlockGeneratorView.swift` (lines 565-621, 713-720, 754-759)
   - Added VIDEO POLICY section
   - Updated question gate section
   - Updated smart defaults section

## Backward Compatibility

This change is backward compatible because:
- No changes to data models or schema
- No changes to parsing logic
- Only affects the prompt template text
- Uses existing `videoUrls` and `media.videoUrl` fields that were already in the schema

## Future Considerations

- Consider adding automated validation in the parser to check for VIDEO_DECISION header
- Could add metrics tracking to see how often video conditions are triggered
- May want to add examples of good VIDEO_DECISION headers to the prompt

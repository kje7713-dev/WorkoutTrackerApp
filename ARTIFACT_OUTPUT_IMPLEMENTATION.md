# Capacity-Aware Transmission Protocol Implementation Summary

## Overview
This implementation adds a comprehensive capacity-aware transmission protocol to the AI prompt template for handling large JSON outputs when generating workout blocks through the BlockGeneratorView. The protocol intelligently detects the AI environment and chooses the appropriate delivery method, with fallback to segmented phase delivery when needed.

## Problem Statement
When users request complex training programs (many weeks, many days, or long JSON), the output can be unwieldy to manage in different AI environments. The AI assistant needed clear guidance on:
1. Detecting whether it can create downloadable files or is in a text-only environment
2. Handling cases where JSON exceeds token limits
3. Maintaining full program complexity without down-scoping when output must be segmented
4. Avoiding hallucinated download links in text-only environments

## Solution
Added a "III. CAPACITY-AWARE TRANSMISSION PROTOCOL (AI-AGNOSTIC)" section to the AI prompt template in `BlockGeneratorView.swift`. This protocol is AI-agnostic, meaning it works with any AI model regardless of its capabilities.

## Implementation Details

### File Modified
- `BlockGeneratorView.swift` - Updated the `aiPromptTemplate(withRequirements:)` function

### Changes Made
Added a new prominent section at the beginning of the AI prompt template (right after schema requirements) with the following protocol:

**1. Environmental Assessment:**
The AI assistant must first determine its environment:
- **Code Execution Environment**: Can create files and provide downloads (e.g., Python sandbox, Code Interpreter)
  - Action: Generate full multi-week JSON as a single .json or .zip file
- **Text-Only Environment** OR **Token Limit Exceeded** (approx. 5,000 characters):
  - Action: Transition to Segmented Phase Delivery

**2. Segmented Phase Delivery Rules:**
When segmentation is required:
- **Do Not Down-Scope**: Maintain the full complexity of the requested program (e.g., if 6 weeks are requested, design all 6 weeks)
- **Logical Partitioning**: Divide the program into the largest possible "Phases" that fit within a single message (e.g., two 3-week phases or three 2-week phases)
- **Completeness**: Each segment MUST be a valid, standalone JSON object conforming to the schema
- **Sequence**: Provide Phase 1 immediately. At the end of the response, provide a brief summary of what Phase 2 entails and ask the user for permission to output the next segment
- **Anti-Hallucination**: If file generation is not supported, do not provide a "download link." Instead, state: "This environment is text-optimized; providing Phase 1 of [X] in raw JSON below."

**File Naming Convention** (when file generation is supported):
- Format: `[BlockName]_[Weeks]W_[Days]D.json`

**Examples Provided:**
- `UpperLower_4W_4D.json` - 4-week upper/lower split with 4 days per week
- `Powerlifting_6W_3D.json` - 6-week powerlifting program with 3 days per week
- `BJJ_Fundamentals_8W_2D.json` - 8-week BJJ program with 2 days per week

**Multi-File and ZIP Rules:**
- Only create multiple JSON files if the program is intentionally modular (e.g., separate phases, blocks, or reusable libraries)
- DO NOT split a single block across multiple JSON files unless explicitly requested
- Create a .zip ONLY when there are 2 or more output JSON files
- If there is only one JSON file, provide only the .json (no zip)

## Benefits

### For Users:
- Programs of any complexity can be generated without down-scoping
- Works across different AI environments (file generation or text-only)
- Large programs are intelligently segmented into digestible phases when needed
- Each phase is a complete, valid JSON that can be imported independently
- No confusion from fake download links in text-only environments
- Clear file naming makes it easy to identify programs
- Multiple modular programs can be bundled into a .zip for easy organization

### For AI Assistants:
- AI-agnostic protocol works with any model
- Clear decision tree: assess environment → choose delivery method
- Explicit instructions to maintain full complexity (never down-scope)
- Structured approach to segmentation with logical partitioning
- Anti-hallucination protection prevents generating fake download links
- Clear guidance on file naming conventions and multi-file handling

## Testing
Manual testing is recommended to validate that AI assistants correctly:
1. Detect their environment (file generation vs text-only)
2. Generate full JSON files when environment supports it
3. Transition to segmented delivery when needed (text-only or token limits)
4. Maintain full program complexity without down-scoping during segmentation
5. Partition programs logically into phases that fit in single messages
6. Generate valid, standalone JSON for each phase
7. Provide Phase 1 immediately and ask permission before Phase 2
8. State "text-optimized" message instead of fake download links
9. Use proper file naming convention when applicable
10. Only create multiple files when intentionally modular
11. Only bundle into .zip when 2+ files exist

## Technical Notes
- This is a prompt-level change only - no changes to Swift code logic
- Protocol is AI-agnostic and works with any AI model
- Replaces previous "ARTIFACT OUTPUT" section with more comprehensive protocol
- Environmental assessment allows AI to adapt to its capabilities
- Segmented delivery prevents down-scoping while respecting token limits
- Anti-hallucination rule prevents fake download links in text-only environments
- Section is prominently placed for visibility (after non-negotiable schema requirements)

## Future Enhancements
Potential improvements for future consideration:
- Add client-side validation to suggest appropriate delivery method
- Implement automatic segmentation in the app for very large blocks
- Add UI indicators when imported JSON is part of a multi-phase program
- Support direct import of segmented JSON phases
- Add phase merging functionality for multi-phase imports

## Validation
- ✅ Code review completed with no issues
- ✅ Security scan completed (no applicable changes)
- ✅ Syntax validation passed (balanced quotes, proper formatting)
- ✅ All required protocol elements present and verified
- ✅ Git commit successful
- ⏳ Manual testing with AI assistant recommended

## Related Files
- `BlockGeneratorView.swift` - Contains the AI prompt template
- `BlockGenerator.swift` - Parses JSON into Block models (unchanged)
- AI_PROMPT_*.md files - Related documentation on prompt design

## Commit History
- 84403cd - "Add ARTIFACT OUTPUT section to AI prompt template" (original implementation)
- [previous] - "Enhance AI prompt with simplified, intent-aware artifact output guidelines"
- [current] - "Add capacity-aware transmission protocol to AI prompt" (this implementation)

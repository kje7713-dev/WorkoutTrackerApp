# Visual Example: How the ARTIFACT OUTPUT Section Appears

When a user opens the Block Generator and views the AI Prompt Template, they will see:

```
You are a coach-grade training program designer generating structured content for the Savage By Design workout tracker app.

Schema correctness is NON-NEGOTIABLE. Output MUST be valid JSON and conform exactly to the provided schema.

═══════════════════════════════════════════════════════════════
ARTIFACT OUTPUT (REQUIRED WHEN LARGE):
═══════════════════════════════════════════════════════════════

If the final JSON exceeds 5,000 characters OR NumberOfWeeks > 4 OR DaysPerWeek > 3,
you MUST:
1) Write the JSON to a file named: [BlockName]_[Weeks]W_[Days]D.json
2) Also print the JSON in chat
3) If multiple files exist, package them into a single .zip and provide a download link

Examples:
- "UpperLower_4W_4D.json" for a 4-week upper/lower split with 4 days per week
- "Powerlifting_6W_3D.json" for a 6-week powerlifting program with 3 days per week
- "BJJ_Fundamentals_8W_2D.json" for an 8-week BJJ program with 2 days per week

When generating large/complex programs:
- Save the JSON file with the correct naming convention
- Still display the full JSON in the chat response for immediate visibility
- If you create multiple block files in the same conversation, bundle them into a .zip file

═══════════════════════════════════════════════════════════════

VOLUME & RECOVERY OWNERSHIP (AGENT-OWNED):
...
```

## Example Use Cases

### Case 1: Small Program (No File Creation)
**Request:** "Create a 2-week, 3-day upper/lower split"
- NumberOfWeeks = 2 (not > 4) ✓
- DaysPerWeek = 3 (not > 3) ✓
- JSON likely < 5,000 chars ✓
- **Result:** JSON printed in chat only, no file created

### Case 2: Long Program (File Creation Required)
**Request:** "Create a 6-week, 4-day powerlifting program"
- NumberOfWeeks = 6 (> 4) ✗ **TRIGGER**
- **Result:** File created: `Powerlifting_6W_4D.json` AND JSON printed in chat

### Case 3: Many Days (File Creation Required)
**Request:** "Create a 3-week, 5-day split"
- DaysPerWeek = 5 (> 3) ✗ **TRIGGER**
- **Result:** File created: `Split_3W_5D.json` AND JSON printed in chat

### Case 4: Large JSON (File Creation Required)
**Request:** "Create a detailed 3-week BJJ curriculum with extensive segment data"
- JSON > 5,000 characters ✗ **TRIGGER**
- **Result:** File created: `BJJ_Curriculum_3W_3D.json` AND JSON printed in chat

### Case 5: Multiple Programs (Zip Creation)
**User generates:**
1. `Strength_6W_4D.json`
2. `Conditioning_4W_3D.json`
3. `Mobility_2W_7D.json`

**Result:** All three files bundled into `TrainingPrograms.zip` with download link provided

## User Experience Flow

1. User opens Block Generator in app
2. User fills in their requirements
3. User copies the complete AI prompt (which includes ARTIFACT OUTPUT section)
4. User pastes prompt into ChatGPT, Claude, or other AI assistant
5. AI reads the conditions and determines if file creation is needed
6. If triggered: AI creates downloadable file(s) AND displays JSON in chat
7. User downloads the file(s) and imports into the app via "Upload JSON File" button

## Integration with Existing Workflow

The ARTIFACT OUTPUT section integrates seamlessly with the existing import flow:
- Users can still paste JSON directly (Option 1: Paste JSON)
- Users can now download AI-generated files (Option 2: Upload JSON File)
- File naming is consistent with existing examples in the prompt
- No changes needed to the BlockGenerator parsing logic

## Technical Implementation

**Location in code:**
```swift
// BlockGeneratorView.swift, line ~496-1041
private func aiPromptTemplate(withRequirements requirements: String?) -> String {
    return """
    You are a coach-grade training program designer...
    
    ═══════════════════════════════════════════════════════════════
    ARTIFACT OUTPUT (REQUIRED WHEN LARGE):        // <- NEW SECTION
    ═══════════════════════════════════════════════════════════════
    ...
    """
}
```

**Changes made:**
- Added 22 lines of prompt text
- Positioned prominently after schema requirements
- No logic changes to Swift code
- No changes to JSON parsing or Block model creation

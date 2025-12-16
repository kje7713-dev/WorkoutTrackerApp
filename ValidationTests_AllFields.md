# Validation Tests for All Fields in BlockRunMode

## Objective
Verify that all fields from `SessionSet` are properly bound and persisted in `BlockRunMode` (RunSetState).

## New Fields Under Test
1. `rpe: Double?` - Rating of Perceived Exertion (1-10 scale)
2. `rir: Double?` - Reps In Reserve (0-5+ scale)
3. `tempo: String?` - Tempo notation (e.g., "3-0-1-0")
4. `restSeconds: Int?` - Rest period between sets
5. `notes: String?` - Set-specific notes

## Manual Testing Checklist

### Test 1: Field UI Visibility
**Steps:**
1. Launch app and enter run mode for any block
2. Expand a set card
3. Tap "Additional Details" to expand the metadata section

**Expected:**
- Metadata section toggle button appears
- When expanded, all 5 new fields are visible:
  - RPE input field (1-10)
  - RIR input field (0-5+)
  - Tempo input field (text)
  - Rest input field (seconds)
  - Notes input field (multi-line text)

### Test 2: Field Data Entry and Save
**Steps:**
1. In run mode, expand a set's metadata section
2. Enter values for each field:
   - RPE: 7.5
   - RIR: 2.0
   - Tempo: "3-0-1-0"
   - Rest: 90
   - Notes: "Form felt good, depth was perfect"
3. Navigate to a different day or week
4. Return to the same set

**Expected:**
- All entered values persist within the session
- Auto-save triggers after each field change
- Values remain visible and editable

### Test 3: Session Close and Reload
**Steps:**
1. Enter metadata values for several sets
2. Tap "Close Session" and confirm
3. Reopen run mode for the same block
4. Navigate to the sets where metadata was entered

**Expected:**
- All metadata values persist after session close/reload
- SessionsRepository correctly saves and loads metadata fields
- Values match what was entered before closing

### Test 4: Mapping Verification (SessionSet → RunSetState)
**Steps:**
1. Create a test with pre-populated session data containing metadata
2. Open run mode
3. Verify metadata appears correctly in UI

**Expected:**
- RunStateMapper correctly converts SessionSet fields to RunSetState
- All 5 metadata fields map correctly:
  - sessionSet.rpe → runSetState.rpe
  - sessionSet.rir → runSetState.rir
  - sessionSet.tempo → runSetState.tempo
  - sessionSet.restSeconds → runSetState.restSeconds
  - sessionSet.notes → runSetState.notes

### Test 5: Reverse Mapping (RunSetState → SessionSet)
**Steps:**
1. Enter metadata in run mode UI
2. Close session
3. Inspect sessions.json file in Documents directory
4. Verify metadata fields are present in saved data

**Expected:**
- RunStateMapper correctly converts RunSetState back to SessionSet
- All logged metadata values appear in sessions.json
- Fields maintain correct data types (Double, Int, String)

### Test 6: Empty/Nil Values
**Steps:**
1. Create sets without entering any metadata
2. Enter metadata, then delete all values
3. Save and reload

**Expected:**
- Empty/nil values are handled correctly
- No crashes or errors when fields are empty
- Optional fields correctly serialize as nil or absent in JSON

### Test 7: Multiple Sets with Mixed Data
**Steps:**
1. Create an exercise with 4 sets
2. Enter different metadata for each set:
   - Set 1: Full metadata
   - Set 2: Only RPE and RIR
   - Set 3: Only notes
   - Set 4: No metadata
3. Save, close, and reload

**Expected:**
- Each set retains its own metadata independently
- No data leakage between sets
- All variations of filled/empty fields work correctly

### Test 8: Both Strength and Conditioning Exercises
**Steps:**
1. Create a workout with both strength and conditioning exercises
2. Add metadata to sets in both exercise types
3. Verify save and reload

**Expected:**
- Metadata works for both exercise types
- No conflicts or issues between strength and conditioning sets
- All fields persist correctly regardless of exercise type

### Test 9: Integration with Existing Fields
**Steps:**
1. Complete a set with both traditional fields (reps, weight) and new metadata
2. Mark set as completed
3. Save and reload

**Expected:**
- New metadata fields coexist with existing fields
- No interference between old and new fields
- isCompleted flag works correctly with metadata
- All onChange handlers trigger appropriately

### Test 10: UI/UX Flow
**Steps:**
1. Navigate through metadata entry during a workout
2. Test keyboard types for different fields
3. Test multi-line notes expansion

**Expected:**
- Decimal keyboard for RPE and RIR
- Number keyboard for rest seconds
- Standard keyboard for tempo and notes
- Notes field expands appropriately for multi-line input
- Collapsible section maintains state within session

## Validation Script (Pseudo-code)

```swift
func validateAllFieldsPersistence() {
    // 1. Create test data with all metadata fields
    let testSet = SessionSet(
        index: 0,
        expectedReps: 10,
        expectedWeight: 135,
        loggedReps: 10,
        loggedWeight: 135,
        rpe: 8.0,
        rir: 2.0,
        tempo: "3-0-1-0",
        restSeconds: 90,
        notes: "Test notes",
        isCompleted: true
    )
    
    let testExercise = SessionExercise(
        customName: "Squat",
        expectedSets: [testSet],
        loggedSets: [testSet]
    )
    
    let testSession = WorkoutSession(
        blockId: testBlockId,
        weekIndex: 1,
        dayTemplateId: testDayId,
        exercises: [testExercise]
    )
    
    // 2. Convert to RunState
    let runWeeks = RunStateMapper.sessionsToRunWeeks([testSession], block: testBlock)
    
    // 3. Verify conversion preserved all fields
    let runSet = runWeeks[0].days[0].exercises[0].sets[0]
    assert(runSet.rpe == 8.0, "RPE should be preserved")
    assert(runSet.rir == 2.0, "RIR should be preserved")
    assert(runSet.tempo == "3-0-1-0", "Tempo should be preserved")
    assert(runSet.restSeconds == 90, "Rest seconds should be preserved")
    assert(runSet.notes == "Test notes", "Notes should be preserved")
    
    // 4. Modify values in run state
    var modifiedRunSet = runSet
    modifiedRunSet.rpe = 9.0
    modifiedRunSet.rir = 1.0
    modifiedRunSet.tempo = "2-0-1-0"
    modifiedRunSet.restSeconds = 120
    modifiedRunSet.notes = "Modified notes"
    
    // 5. Convert back to SessionSet
    var modifiedWeeks = runWeeks
    modifiedWeeks[0].days[0].exercises[0].sets[0] = modifiedRunSet
    
    let updatedSessions = RunStateMapper.runWeeksToSessions(
        modifiedWeeks,
        originalSessions: [testSession],
        block: testBlock
    )
    
    // 6. Verify reverse conversion preserved modified values
    let updatedSet = updatedSessions[0].exercises[0].loggedSets[0]
    assert(updatedSet.rpe == 9.0, "Modified RPE should be preserved")
    assert(updatedSet.rir == 1.0, "Modified RIR should be preserved")
    assert(updatedSet.tempo == "2-0-1-0", "Modified tempo should be preserved")
    assert(updatedSet.restSeconds == 120, "Modified rest should be preserved")
    assert(updatedSet.notes == "Modified notes", "Modified notes should be preserved")
    
    print("✅ All fields validation passed!")
}
```

## Success Criteria

All tests should pass with:
- ✅ All 5 new fields appear in UI
- ✅ All fields accept and display data correctly
- ✅ All fields persist through session close/reload
- ✅ Mapping works in both directions (SessionSet ↔ RunSetState)
- ✅ No data loss or corruption
- ✅ Works with both strength and conditioning exercises
- ✅ No conflicts with existing fields
- ✅ Proper handling of empty/nil values
- ✅ onChange handlers trigger saves for all new fields

## Notes

- The new fields are displayed in a collapsible "Additional Details" section to avoid cluttering the main UI
- All fields are optional (nullable) matching the data model design
- The UI uses appropriate keyboard types for each field type
- Auto-save triggers on any field change via onChange handlers

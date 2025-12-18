# Validation Tests for Run Mode Persistence Unification

## Manual Testing Checklist

### Test 1: New Block Session Generation
**Steps:**
1. Launch app
2. Create a new block with at least 2 weeks and 2 days
3. Add exercises to each day (mix of strength and conditioning)
4. Save the block
5. Tap "RUN" on the block
6. Verify: Run mode opens with correct weeks/days/exercises

**Expected:**
- Sessions are generated automatically via SessionFactory
- Sessions are saved to SessionsRepository (sessions.json)
- No runstate-*.json files are created
- All weeks and days appear correctly in run mode

### Test 2: Set Logging and Auto-Save
**Steps:**
1. In run mode, complete a few sets (mark them completed)
2. Change logged reps/weight values
3. Navigate between different days
4. Close the app completely
5. Reopen the app and go back to run mode for the same block

**Expected:**
- All completed sets remain marked as completed
- All logged values (reps, weight, etc.) are preserved
- Changes are saved to sessions.json via SessionsRepository
- No runstate-*.json files are created

### Test 3: Close and Reopen Session
**Steps:**
1. In run mode, complete some sets
2. Tap "Close Session"
3. Confirm in the close dialog
4. Verify: Returns to blocks list
5. Tap "RUN" again on the same block

**Expected:**
- Save verification succeeds
- All progress is preserved when reopening
- SessionsRepository is the source for reloaded data
- sessions.json contains the updated logged values

### Test 4: Edit Block with Existing Sessions (Warning)
**Steps:**
1. Create and run a block with logged progress
2. Return to blocks list
3. Tap "EDIT" on the block
4. Make changes to the block structure
5. Tap "Save"

**Expected:**
- Confirmation dialog appears: "Overwrite Existing Sessions?"
- Dialog warns about losing logged progress
- If user cancels, changes are not saved
- If user confirms, sessions are regenerated and old progress is lost

### Test 5: Edit Block without Logged Progress (No Warning)
**Steps:**
1. Create a new block but don't run it (or run without completing any sets)
2. Tap "EDIT" on the block
3. Make changes
4. Tap "Save"

**Expected:**
- No confirmation dialog appears
- Sessions are regenerated without warning
- Save completes immediately

### Test 6: Multiple Weeks Progress
**Steps:**
1. Create a block with 4 weeks
2. Complete all sets in Week 1
3. Complete some sets in Week 2
4. Close and reopen the session

**Expected:**
- Week 1 shows all sets completed
- Week 2 shows partial completion
- Week 3 and 4 show no completion
- All data persists through close/reopen

### Test 7: Data Integrity Check
**Steps:**
1. After completing some sets, close the app
2. Check filesystem for sessions.json
3. Open sessions.json and verify structure

**Expected:**
- sessions.json exists in Documents directory
- File contains WorkoutSession array with correct blockId
- loggedSets contain isCompleted, loggedReps, loggedWeight, etc.
- No runstate-*.json files exist (or if they do, they're not being used)

## Validation Script Output

Run these checks programmatically if possible:

```swift
// Pseudo-code for validation
func validateRunModeUnification() {
    // 1. Check SessionsRepository is being used
    let sessions = sessionsRepository.sessions(forBlockId: testBlockId)
    assert(!sessions.isEmpty, "Sessions should exist after generation")
    
    // 2. Check sessions.json exists and is valid
    let sessionsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("sessions.json")
    assert(FileManager.default.fileExists(atPath: sessionsURL.path), 
           "sessions.json should exist")
    
    // 3. Check no runstate files are created
    let runstateURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("runstate-\(testBlockId.uuidString).json")
    assert(!FileManager.default.fileExists(atPath: runstateURL.path), 
           "runstate-*.json should not exist")
    
    // 4. Check RunStateMapper conversion is symmetric
    let runWeeks = RunStateMapper.sessionsToRunWeeks(sessions, block: testBlock)
    let convertedSessions = RunStateMapper.runWeeksToSessions(
        runWeeks, 
        originalSessions: sessions, 
        block: testBlock
    )
    assert(convertedSessions.count == sessions.count, 
           "Session count should be preserved")
    
    // 5. Check logged values are preserved
    for (original, converted) in zip(sessions, convertedSessions) {
        for (origEx, convEx) in zip(original.exercises, converted.exercises) {
            for (origSet, convSet) in zip(origEx.loggedSets, convEx.loggedSets) {
                assert(origSet.isCompleted == convSet.isCompleted, 
                       "isCompleted should be preserved")
                assert(origSet.loggedReps == convSet.loggedReps, 
                       "loggedReps should be preserved")
                assert(origSet.loggedWeight == convSet.loggedWeight, 
                       "loggedWeight should be preserved")
            }
        }
    }
    
    print("✅ All validation checks passed!")
}
```

## Success Criteria

All tests should pass with:
- ✅ SessionsRepository is the single source of truth
- ✅ No runstate-*.json files are created or used
- ✅ All logged progress persists through app restarts
- ✅ Save verification succeeds with correct data counts
- ✅ Warning dialog appears when editing blocks with logged data
- ✅ sessions.json contains all workout session data

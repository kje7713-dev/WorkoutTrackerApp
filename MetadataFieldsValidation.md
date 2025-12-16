# Metadata Fields Validation Tests (Issue #51)

## Overview
This document validates that all SessionSet metadata fields (rpe, rir, tempo, restSeconds, notes) are properly displayed, editable, and persisted in BlockRunMode.

## Test 1: Field Persistence - Strength Exercise

### Setup
1. Create a new block with 1 week, 1 day
2. Add a strength exercise (e.g., "Back Squat") with 3 sets
3. Set template values for the first set:
   - Reps: 5
   - Weight: 135
   - RPE: 8.0
   - RIR: 2.0
   - Tempo: "3-1-1-0"
   - Rest: 180 seconds
   - Notes: "Focus on depth"

### Test Steps
1. Save the block and enter Run Mode
2. Navigate to the exercise
3. Verify all metadata fields are visible in the UI:
   - [ ] RPE field displays "8.0"
   - [ ] RIR field displays "2.0"
   - [ ] Tempo field displays "3-1-1-0"
   - [ ] Rest field displays "180"
   - [ ] Notes field displays "Focus on depth"
4. Modify the values:
   - Change RPE to 9.5
   - Change RIR to 1.0
   - Change Tempo to "2-0-2-0"
   - Change Rest to 120
   - Change Notes to "Hit depth perfectly"
5. Complete the set
6. Close the session (tap "Close Session")
7. Reopen Run Mode for the same block
8. Navigate back to the same exercise and set

### Expected Results
All modified values should persist:
- [ ] RPE shows "9.5"
- [ ] RIR shows "1.0"
- [ ] Tempo shows "2-0-2-0"
- [ ] Rest shows "120"
- [ ] Notes shows "Hit depth perfectly"
- [ ] Set remains marked as completed

## Test 2: Field Persistence - Conditioning Exercise

### Setup
1. Create a new block with 1 week, 1 day
2. Add a conditioning exercise (e.g., "Row") with 2 sets
3. Set template values:
   - Duration: 600 seconds (10 min)
   - Calories: 100
   - Rest: 120 seconds
   - Notes: "Steady state pace"

### Test Steps
1. Save the block and enter Run Mode
2. Navigate to the conditioning exercise
3. Verify metadata fields for conditioning:
   - [ ] RPE field is NOT visible (strength only)
   - [ ] RIR field is NOT visible (strength only)
   - [ ] Tempo field is NOT visible (strength only)
   - [ ] Rest field IS visible and displays "120"
   - [ ] Notes field IS visible and displays "Steady state pace"
4. Modify the values:
   - Change Rest to 90
   - Change Notes to "Increased pace slightly"
5. Complete the set
6. Close and reopen the session

### Expected Results
Modified values should persist:
- [ ] Rest shows "90"
- [ ] Notes shows "Increased pace slightly"
- [ ] Set remains marked as completed

## Test 3: Auto-Save Trigger Validation

### Setup
Use the block from Test 1

### Test Steps
1. Enter Run Mode
2. For each metadata field, make a change and immediately navigate away:
   - Change RPE → navigate to different day
   - Navigate back → verify RPE change persisted
   - Change RIR → navigate to different day
   - Navigate back → verify RIR change persisted
   - Change Tempo → navigate to different day
   - Navigate back → verify Tempo change persisted
   - Change Rest → navigate to different day
   - Navigate back → verify Rest change persisted
   - Change Notes → navigate to different day
   - Navigate back → verify Notes change persisted

### Expected Results
- [ ] All changes trigger auto-save
- [ ] All changes persist when navigating away and back
- [ ] No data loss occurs

## Test 4: Multiple Sets with Different Metadata

### Setup
1. Create a block with 1 week, 1 day
2. Add a strength exercise with 5 sets, each with different template metadata:
   - Set 1: RPE 6, RIR 4, Tempo "4-0-4-0", Rest 120, Notes "Warm-up"
   - Set 2: RPE 7, RIR 3, Tempo "3-1-1-0", Rest 150, Notes "Build up"
   - Set 3: RPE 8, RIR 2, Tempo "3-0-1-0", Rest 180, Notes "Working set"
   - Set 4: RPE 9, RIR 1, Tempo "2-0-1-0", Rest 180, Notes "Top set"
   - Set 5: RPE 7, RIR 3, Tempo "3-1-1-0", Rest 120, Notes "Back-off"

### Test Steps
1. Enter Run Mode
2. For each set, verify the metadata displays correctly
3. Complete all sets without modifying values
4. Close and reopen the session
5. Verify all metadata for all sets

### Expected Results
- [ ] Each set displays its unique metadata values
- [ ] All sets persist their metadata after close/reopen
- [ ] No cross-contamination between sets

## Test 5: SessionFactory Integration

### Validation Code
```swift
// This validates that SessionFactory properly maps metadata from templates to sessions

func testSessionFactoryMetadataMapping() {
    // Create a block with metadata in templates
    let strengthSet = StrengthSetTemplate(
        index: 0,
        reps: 5,
        weight: 225,
        rpe: 8.5,
        rir: 1.5,
        tempo: "3-1-1-0",
        restSeconds: 180,
        notes: "Focus on form"
    )
    
    let exercise = ExerciseTemplate(
        type: .strength,
        strengthSets: [strengthSet],
        progressionRule: ProgressionRule(type: .weight)
    )
    
    let day = DayTemplate(name: "Day 1", exercises: [exercise])
    let block = Block(name: "Test Block", numberOfWeeks: 1, days: [day])
    
    // Generate sessions
    let factory = SessionFactory()
    let sessions = factory.makeSessions(for: block)
    
    // Validate metadata is mapped
    let firstSet = sessions[0].exercises[0].loggedSets[0]
    assert(firstSet.rpe == 8.5, "RPE should be 8.5")
    assert(firstSet.rir == 1.5, "RIR should be 1.5")
    assert(firstSet.tempo == "3-1-1-0", "Tempo should be 3-1-1-0")
    assert(firstSet.restSeconds == 180, "Rest should be 180")
    assert(firstSet.notes == "Focus on form", "Notes should match")
    
    print("✅ SessionFactory metadata mapping validated")
}
```

### Expected Results
- [ ] All metadata fields map from template to session
- [ ] Both expectedSets and loggedSets contain metadata
- [ ] No fields are lost in the mapping

## Test 6: RunStateMapper Bidirectional Mapping

### Validation Code
```swift
// This validates that RunStateMapper properly converts metadata both directions

func testRunStateMapperMetadataBidirectional() {
    // Create a session with metadata
    let sessionSet = SessionSet(
        index: 0,
        expectedReps: 5,
        expectedWeight: 225,
        loggedReps: 5,
        loggedWeight: 225,
        rpe: 9.0,
        rir: 0.5,
        tempo: "2-0-1-0",
        restSeconds: 240,
        notes: "Max effort",
        isCompleted: true
    )
    
    let sessionExercise = SessionExercise(
        customName: "Deadlift",
        expectedSets: [sessionSet],
        loggedSets: [sessionSet]
    )
    
    let session = WorkoutSession(
        blockId: UUID(),
        weekIndex: 1,
        dayTemplateId: UUID(),
        exercises: [sessionExercise]
    )
    
    let day = DayTemplate(name: "Day 1", exercises: [])
    let block = Block(name: "Test", numberOfWeeks: 1, days: [day])
    
    // Convert to RunState
    let runWeeks = RunStateMapper.sessionsToRunWeeks([session], block: block)
    let runSet = runWeeks[0].days[0].exercises[0].sets[0]
    
    // Validate forward mapping
    assert(runSet.rpe == 9.0, "RPE should be 9.0")
    assert(runSet.rir == 0.5, "RIR should be 0.5")
    assert(runSet.tempo == "2-0-1-0", "Tempo should be 2-0-1-0")
    assert(runSet.restSeconds == 240, "Rest should be 240")
    assert(runSet.notes == "Max effort", "Notes should match")
    
    // Modify values
    var modifiedRunSet = runSet
    modifiedRunSet.rpe = 8.0
    modifiedRunSet.rir = 2.0
    modifiedRunSet.tempo = "3-1-1-0"
    modifiedRunSet.restSeconds = 180
    modifiedRunSet.notes = "Adjusted load"
    
    // Create modified run weeks
    var modifiedExercise = runWeeks[0].days[0].exercises[0]
    modifiedExercise.sets = [modifiedRunSet]
    var modifiedDay = runWeeks[0].days[0]
    modifiedDay.exercises = [modifiedExercise]
    var modifiedWeek = runWeeks[0]
    modifiedWeek.days = [modifiedDay]
    
    // Convert back to sessions
    let updatedSessions = RunStateMapper.runWeeksToSessions(
        [modifiedWeek],
        originalSessions: [session],
        block: block
    )
    
    let updatedSet = updatedSessions[0].exercises[0].loggedSets[0]
    
    // Validate reverse mapping
    assert(updatedSet.rpe == 8.0, "RPE should be 8.0")
    assert(updatedSet.rir == 2.0, "RIR should be 2.0")
    assert(updatedSet.tempo == "3-1-1-0", "Tempo should be 3-1-1-0")
    assert(updatedSet.restSeconds == 180, "Rest should be 180")
    assert(updatedSet.notes == "Adjusted load", "Notes should match")
    
    print("✅ RunStateMapper bidirectional metadata mapping validated")
}
```

### Expected Results
- [ ] Forward mapping (Session → RunState) preserves all metadata
- [ ] Reverse mapping (RunState → Session) preserves all metadata
- [ ] Modified values in RunState propagate back to Session correctly

## Test 7: Empty/Nil Metadata Handling

### Test Steps
1. Create a block with an exercise that has NO metadata values set
2. Enter Run Mode
3. Verify all metadata fields are empty/blank
4. Add values to each field:
   - RPE: 7.5
   - RIR: 2.5
   - Tempo: "3-0-1-0"
   - Rest: 90
   - Notes: "First attempt"
5. Complete the set
6. Close and reopen
7. Verify values persist

### Expected Results
- [ ] Empty fields display as empty/placeholder text
- [ ] User can add values to previously empty fields
- [ ] Added values persist correctly
- [ ] No crashes or data corruption with nil → value transitions

## Test 8: Data File Inspection

### Test Steps
1. Complete Test 1 (add metadata and save)
2. Locate sessions.json file in app's Documents directory
3. Open and inspect the JSON structure

### Expected Structure
```json
{
  "sessions": [
    {
      "id": "...",
      "blockId": "...",
      "weekIndex": 1,
      "exercises": [
        {
          "loggedSets": [
            {
              "loggedReps": 5,
              "loggedWeight": 135,
              "rpe": 9.5,
              "rir": 1.0,
              "tempo": "2-0-2-0",
              "restSeconds": 120,
              "notes": "Hit depth perfectly",
              "isCompleted": true
            }
          ]
        }
      ]
    }
  ]
}
```

### Expected Results
- [ ] sessions.json contains all 5 metadata fields
- [ ] Values match what was entered in the UI
- [ ] Fields are at the SessionSet level, not Exercise level
- [ ] File structure is valid JSON

## Success Criteria

All tests must pass:
- ✅ All 5 metadata fields display in UI
- ✅ Strength-specific fields (RPE, RIR, Tempo) show only for strength exercises
- ✅ Common fields (Rest, Notes) show for all exercise types
- ✅ All fields trigger auto-save on change
- ✅ All fields persist through close/reopen
- ✅ SessionFactory maps metadata from templates
- ✅ RunStateMapper maps metadata bidirectionally
- ✅ Multiple sets can have different metadata values
- ✅ Nil/empty values are handled gracefully
- ✅ sessions.json contains all metadata fields

## Regression Checks

Ensure existing functionality still works:
- [ ] Existing fields (reps, weight, time, etc.) still work
- [ ] Set completion still works
- [ ] Navigation between weeks/days still works
- [ ] Close session with save verification still works
- [ ] Multiple blocks don't interfere with each other

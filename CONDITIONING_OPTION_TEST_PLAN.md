# Test Plan: Conditioning Option in BlockRunMode

## Issue #46: Add conditioning as an exercise type option in BlockRunMode

### Overview
This test plan validates that users can now add conditioning exercises in BlockRunMode, and that these exercises are properly persisted through the data layer.

---

## Test Cases

### Test 1: Add New Conditioning Exercise via Dialog
**Objective:** Verify that the exercise type selection dialog appears and allows creating a conditioning exercise.

**Steps:**
1. Launch the app
2. Create a new training block or open an existing one
3. Tap "RUN" to enter BlockRunMode
4. Navigate to any day
5. Tap the "Add Exercise" button

**Expected Results:**
- ✅ A confirmation dialog appears with title "Select Exercise Type"
- ✅ Dialog shows three options: "Strength", "Conditioning", and "Cancel"
- ✅ When "Conditioning" is selected, a new exercise is added with conditioning type
- ✅ The new exercise displays conditioning controls (Time, Calories, Rounds) instead of strength controls (Reps, Weight)

**Test Data:**
- Exercise Name: "Row 500m"
- Type: Conditioning
- Initial Set: 1 set with default values

---

### Test 2: Add New Strength Exercise (Regression Test)
**Objective:** Ensure strength exercises still work correctly after changes.

**Steps:**
1. In BlockRunMode, tap "Add Exercise"
2. Select "Strength" from the dialog

**Expected Results:**
- ✅ A new exercise is created with strength type
- ✅ The exercise displays strength controls (Reps, Weight)
- ✅ Sets can be completed and logged normally

---

### Test 3: Change Exercise Type Using Picker
**Objective:** Verify that the type picker allows changing between strength and conditioning.

**Steps:**
1. Add a new exercise (any type)
2. Locate the segmented control picker below the exercise name
3. Tap the opposite type (if Strength, tap Conditioning; if Conditioning, tap Strength)

**Expected Results:**
- ✅ Segmented picker shows "Strength" and "Conditioning" options
- ✅ When type is changed, all sets are regenerated with the new type
- ✅ Changing to Conditioning shows conditioning controls
- ✅ Changing to Strength shows strength controls
- ✅ Set count is preserved when changing type

---

### Test 4: Persistence of Conditioning Exercise
**Objective:** Verify conditioning exercises persist through save/reload cycles.

**Steps:**
1. Add a conditioning exercise
2. Add multiple sets (e.g., 3 sets)
3. Log values for each set:
   - Set 1: 20 min, 200 cal, 1 round
   - Set 2: 15 min, 150 cal, 1 round
   - Set 3: 10 min, 100 cal, 1 round
4. Mark all sets as completed
5. Tap "Close Session" and confirm
6. Reopen the same block in RUN mode

**Expected Results:**
- ✅ All three conditioning sets are still present
- ✅ All logged values (time, calories, rounds) are preserved
- ✅ Completion status is maintained for all sets
- ✅ Exercise type remains "Conditioning"

---

### Test 5: Add Multiple Exercise Types in Same Day
**Objective:** Verify that mixing strength and conditioning exercises works correctly.

**Steps:**
1. In BlockRunMode, add a strength exercise (e.g., "Back Squat")
2. Add 2-3 sets and log strength values
3. Add a conditioning exercise (e.g., "Assault Bike")
4. Add 2-3 sets and log conditioning values
5. Add another strength exercise
6. Complete some sets from each exercise
7. Close and reopen the session

**Expected Results:**
- ✅ All exercises maintain their correct type
- ✅ Each exercise displays appropriate controls
- ✅ All logged values persist correctly
- ✅ Completion status is maintained for each set

---

### Test 6: Modify Existing Exercise Type
**Objective:** Verify that changing exercise type mid-workout doesn't break functionality.

**Steps:**
1. Add a strength exercise with 3 sets
2. Log reps and weight for first set
3. Mark first set as completed
4. Change exercise type to Conditioning using the picker
5. Observe the sets regenerate
6. Log conditioning values for the sets
7. Close and reopen session

**Expected Results:**
- ✅ Sets are regenerated when type changes
- ✅ Previously completed status is lost (expected behavior - sets are recreated)
- ✅ New conditioning sets can be logged properly
- ✅ Changes persist through save/reload

---

### Test 7: Edge Case - Cancel Dialog
**Objective:** Verify canceling the exercise type dialog works correctly.

**Steps:**
1. Tap "Add Exercise"
2. Tap "Cancel" on the dialog

**Expected Results:**
- ✅ Dialog dismisses without adding an exercise
- ✅ Day remains unchanged
- ✅ Can tap "Add Exercise" again and dialog reappears

---

### Test 8: Conditioning Set Controls Validation
**Objective:** Verify all conditioning controls work correctly.

**Steps:**
1. Add a conditioning exercise
2. Test Time control:
   - Increment/decrement using +/- buttons
   - Verify display shows minutes
3. Test Calories control:
   - Increment/decrement in steps of 5
   - Verify minimum is 0
4. Test Rounds control:
   - Increment/decrement in steps of 1
   - Verify minimum is 0

**Expected Results:**
- ✅ Time control increments in 1-minute steps
- ✅ Calories control increments in 5-calorie steps
- ✅ Rounds control increments in 1-round steps
- ✅ All controls respect minimum value of 0
- ✅ Values are properly formatted and displayed

---

### Test 9: Add/Remove Sets for Conditioning Exercise
**Objective:** Verify set management works for conditioning exercises.

**Steps:**
1. Add a conditioning exercise
2. Tap "Add Set" button multiple times to add 3-4 sets
3. Tap "Remove Set" button to remove a set
4. Log values for remaining sets
5. Close and reopen session

**Expected Results:**
- ✅ Can add multiple conditioning sets
- ✅ Can remove conditioning sets (when count > 1)
- ✅ Each set is independently configurable
- ✅ Set indices remain consistent after add/remove
- ✅ All sets persist through save/reload

---

### Test 10: RunStateMapper Validation
**Objective:** Verify the data layer correctly handles new exercises and sets.

**Steps:**
1. Create a block with 1 week, 1 day, 1 exercise
2. Enter RUN mode (session generated via SessionFactory)
3. Add 2 new exercises (1 strength, 1 conditioning)
4. Add extra sets to all exercises
5. Log values and mark some sets complete
6. Close session with "Save & Close"
7. Check sessions.json in app documents directory
8. Reopen session

**Expected Results:**
- ✅ sessions.json contains all 3 exercises (1 original + 2 new)
- ✅ All sets for all exercises are present in JSON
- ✅ Conditioning exercise has correct logged values (time, calories, rounds)
- ✅ Reloading session shows all exercises and sets
- ✅ No data loss occurs

---

## Success Criteria

All test cases must pass with the following outcomes:
- ✅ Conditioning is available as an exercise type option in BlockRunMode
- ✅ Users can select exercise type when adding new exercises
- ✅ Users can change exercise type after creation
- ✅ Conditioning exercises display appropriate controls (time, calories, rounds)
- ✅ All exercise types persist correctly through save/reload cycles
- ✅ New exercises added during workout are saved to sessions.json
- ✅ No regression in existing strength exercise functionality

---

## Known Limitations

1. **Type Change Resets Sets:** When changing exercise type via picker, all sets are regenerated with default values. This is expected behavior to ensure sets have the correct structure for the new type.

2. **Set Completion Lost on Type Change:** If sets are marked complete before changing type, the completion status is lost when sets regenerate. This is acceptable as the sets are fundamentally different.

---

## Validation Notes

This test plan should be executed on:
- iOS 17.0+ (minimum deployment target)
- iPhone simulator (recommended)
- Physical iPhone device (optional but recommended)

Test both portrait and landscape orientations where applicable.

---

## Issue Resolution Checklist

- [x] Added confirmation dialog for exercise type selection
- [x] Added type picker (segmented control) in ExerciseRunCard
- [x] Made RunExerciseState.type mutable
- [x] Fixed RunStateMapper to persist new exercises
- [x] Fixed RunStateMapper to persist new sets
- [x] Ensured conditioning controls display correctly
- [x] Validated data persistence through the repository layer
- [ ] Manual testing completed
- [ ] Screenshots captured
- [ ] PR review requested from @kje7713-dev

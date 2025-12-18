# Exercise Persistence Test Plan

## Feature: Add Exercise to Future Weeks

### Overview
When adding an exercise during a workout session (in blockrunmode), users now have the option to add that exercise to the same day in all future weeks of the block.

### Changes Made

#### 1. Modified `DayRunView` (blockrunmode.swift)
- Added `block`, `weekIndex`, and `dayIndex` parameters
- Added `@EnvironmentObject` for `blocksRepository` and `sessionsRepository`
- Added `persistToFutureWeeks` state variable
- Replaced `confirmationDialog` with custom `AddExerciseSheet`
- Enhanced `addExercise()` to support persistence logic
- Added `addExerciseToBlockTemplate()` to update the block template
- Added `regenerateSessionsForFutureWeeks()` to update future sessions

#### 2. Created `AddExerciseSheet` (blockrunmode.swift)
- New SwiftUI sheet view for selecting exercise type
- Includes toggle for "Add to this day in all future weeks"
- Toggle only appears when there are future weeks available
- Presented as a medium-sized sheet with clear action buttons

#### 3. Modified `WeekRunView` (blockrunmode.swift)
- Added `block` parameter
- Passes required parameters to `DayRunView`

#### 4. Modified `BlockRunModeView` (blockrunmode.swift)
- Passes `block` parameter to `WeekRunView`

#### 5. Modified `BlocksListView`
- Added `blocksRepository` as environment object when navigating to `BlockRunModeView`

#### 6. Modified `SessionFactory`
- Made `makeSessionSetsFromTemplate()` public for use when adding exercises during workout

### Test Scenarios

#### Scenario 1: Add Exercise Without Persistence (Default Behavior)
**Setup:**
1. Create a block with 4 weeks
2. Add at least 2 days to the block
3. Start a workout session (RUN) in Week 1, Day 1

**Steps:**
1. Tap "Add Exercise" button
2. Verify the sheet appears with "Strength" and "Conditioning" buttons
3. Verify the toggle "Add to this day in all future weeks" is visible and OFF by default
4. Tap "Strength" (without enabling the toggle)
5. Verify the exercise is added to the current day

**Expected Results:**
- Exercise appears in Week 1, Day 1
- Navigate to Week 2, Day 1 → Exercise should NOT appear
- Navigate to Week 3, Day 1 → Exercise should NOT appear
- Navigate to Week 4, Day 1 → Exercise should NOT appear

#### Scenario 2: Add Exercise With Persistence
**Setup:**
1. Create a block with 4 weeks
2. Add at least 2 days to the block
3. Start a workout session (RUN) in Week 1, Day 1

**Steps:**
1. Tap "Add Exercise" button
2. Enable the toggle "Add to this day in all future weeks"
3. Tap "Conditioning"
4. Verify the exercise is added to the current day

**Expected Results:**
- Exercise appears in Week 1, Day 1
- Navigate to Week 2, Day 1 → Exercise SHOULD appear (with 0 sets completed)
- Navigate to Week 3, Day 1 → Exercise SHOULD appear (with 0 sets completed)
- Navigate to Week 4, Day 1 → Exercise SHOULD appear (with 0 sets completed)
- The exercise should have the same name in all weeks
- The exercise should have the same type in all weeks
- Each week should have independent set completion tracking

#### Scenario 3: Add Exercise in Last Week
**Setup:**
1. Create a block with 4 weeks
2. Add at least 1 day to the block
3. Start a workout session (RUN) in Week 4, Day 1

**Steps:**
1. Tap "Add Exercise" button
2. Verify the toggle "Add to this day in all future weeks" is NOT visible (no future weeks)
3. Tap "Strength"

**Expected Results:**
- Exercise is added only to Week 4, Day 1
- Toggle is hidden because there are no future weeks

#### Scenario 4: Add Exercise in Middle Week With Persistence
**Setup:**
1. Create a block with 6 weeks
2. Add at least 1 day to the block
3. Start a workout session (RUN) in Week 3, Day 1

**Steps:**
1. Tap "Add Exercise" button
2. Enable the toggle "Add to this day in all future weeks"
3. Tap "Conditioning"

**Expected Results:**
- Exercise appears in Week 3, Day 1
- Navigate to Week 4, Day 1 → Exercise SHOULD appear
- Navigate to Week 5, Day 1 → Exercise SHOULD appear
- Navigate to Week 6, Day 1 → Exercise SHOULD appear
- Navigate to Week 2, Day 1 → Exercise SHOULD NOT appear (past week)
- Navigate to Week 1, Day 1 → Exercise SHOULD NOT appear (past week)

#### Scenario 5: Persistence Across Different Days
**Setup:**
1. Create a block with 4 weeks
2. Add at least 3 days to the block (e.g., "Push", "Pull", "Legs")
3. Start a workout session (RUN) in Week 1

**Steps:**
1. On Day 1 (Push), add an exercise with persistence enabled
2. On Day 2 (Pull), add a different exercise with persistence enabled
3. Navigate to Week 2

**Expected Results:**
- Week 2, Day 1 should have the exercise added from Week 1, Day 1
- Week 2, Day 2 should have the exercise added from Week 1, Day 2
- Week 2, Day 3 should NOT have any of these exercises (nothing was added there)

#### Scenario 6: Block Template Update
**Setup:**
1. Create a block with 3 weeks
2. Start workout in Week 1, Day 1
3. Add exercise with persistence

**Steps:**
1. Close the workout session (Save & Close)
2. Navigate back to Blocks List
3. Tap "EDIT" on the same block
4. Navigate to the day template where the exercise was added

**Expected Results:**
- The block template should show the newly added exercise
- The exercise should appear in the day's exercise list
- The exercise can be edited like any other template exercise

### Edge Cases

#### Edge Case 1: Toggle State Reset
**Test:** Add exercise with toggle ON, then add another exercise
**Expected:** Toggle should be OFF for the second exercise (reset after each add)

#### Edge Case 2: Cancel Action
**Test:** Open add exercise sheet, enable toggle, then cancel
**Expected:** No exercise added, toggle state doesn't affect anything

#### Edge Case 3: Multiple Adds in Same Session
**Test:** Add 3 exercises in Week 1, Day 1 with persistence enabled
**Expected:** All 3 exercises should appear in future weeks

### Data Integrity Checks

1. **Sessions Repository Consistency**
   - Verify sessions.json is updated correctly
   - Confirm all future week sessions have the new exercise

2. **Blocks Repository Consistency**
   - Verify blocks.json is updated with the new exercise template
   - Confirm the exercise has proper type and progression rule

3. **State Persistence**
   - Close and reopen the app
   - Start workout in a future week
   - Verify the added exercise still appears

### Performance Considerations

- Adding exercise with persistence may take slightly longer (updating multiple sessions)
- No noticeable lag expected for blocks with reasonable number of weeks (<20)
- Sheet presentation should be smooth

### Regression Testing

Run the following to ensure no regressions:

1. **Existing Add Exercise Functionality**
   - Without enabling toggle, exercises should add to current day only (original behavior)

2. **Exercise Type Selection**
   - Both Strength and Conditioning types should work correctly

3. **Set Completion Tracking**
   - Completing sets should still work normally
   - Week completion modal should still trigger correctly

4. **Save Functionality**
   - Auto-save should still work
   - Manual save & close should work
   - Data verification should pass

### Known Limitations

1. Exercise persistence only applies to future weeks, not past weeks
2. Once an exercise is added with persistence, removing it requires editing the block template or removing from each week individually
3. The feature works at the day level (not week level)

### Success Criteria

✅ Toggle appears and functions correctly
✅ Exercises persist to future weeks when enabled
✅ Toggle is hidden in last week
✅ Block template is updated correctly
✅ Sessions repository is updated correctly
✅ No regressions in existing functionality
✅ UI is clear and intuitive
✅ Data persists across app restarts

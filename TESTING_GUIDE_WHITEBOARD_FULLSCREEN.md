# Whiteboard Full-Screen Feature - Testing Guide

## Overview
This guide provides step-by-step instructions for manually testing the new full-screen whiteboard feature.

## Prerequisites
- iOS device or simulator running iOS 17.0+
- App built from the `copilot/pop-out-whiteboard-fullscreen` branch
- A training block with multiple days and exercises
- At least one conditioning exercise (AMRAP) with notes containing circuit movements

## Test Cases

### Test Case 1: Full-Screen Modal Presentation
**Objective**: Verify whiteboard opens in full screen with proper UI elements

**Steps**:
1. Open the app and navigate to a training block
2. Tap "Start Session" or similar to enter BlockRunMode
3. Tap the "Whiteboard" button in the top-right toolbar
4. Observe the full-screen modal presentation

**Expected Results**:
- ✅ Modal covers entire screen
- ✅ Navigation bar visible at top
- ✅ Block title displayed in navigation bar center
- ✅ Week and day info shown below title (e.g., "Week 1 • Day 1")
- ✅ X button (circular, filled) visible in top-right corner
- ✅ Whiteboard content displays below navigation bar
- ✅ Content is scrollable if longer than screen

**Screenshot Location**: Please capture and save to `docs/screenshots/whiteboard-fullscreen-open.png`

---

### Test Case 2: X Button Dismissal
**Objective**: Verify X button properly closes the whiteboard

**Steps**:
1. From whiteboard full-screen view (see Test Case 1)
2. Tap the X button in top-right corner
3. Observe the dismissal animation

**Expected Results**:
- ✅ Modal dismisses with smooth animation
- ✅ Returns to BlockRunMode tracking view
- ✅ User remains on same week and day
- ✅ No loss of workout data or progress

---

### Test Case 3: Single Day Display
**Objective**: Verify only the current day is shown, not all days

**Steps**:
1. In BlockRunMode, ensure you're on Day 1
2. Open whiteboard (tap "Whiteboard" button)
3. Verify only Day 1 content is shown
4. Close whiteboard (tap X)
5. Switch to Day 2 in tracking view (use day tabs)
6. Open whiteboard again
7. Verify only Day 2 content is shown

**Expected Results**:
- ✅ On Day 1: whiteboard shows only Day 1 exercises
- ✅ On Day 2: whiteboard shows only Day 2 exercises
- ✅ No day navigation controls in whiteboard view
- ✅ Navigation bar correctly shows "Week X • Day Y"
- ✅ Content matches the day being tracked

**Screenshot Locations**:
- `docs/screenshots/whiteboard-day1.png`
- `docs/screenshots/whiteboard-day2.png`

---

### Test Case 4: AMRAP with Circuit Notes - Bullet Display
**Objective**: Verify notes with circuit movements display as bullets

**Setup**:
Create or find a conditioning exercise with:
- Type: Conditioning
- Conditioning Type: AMRAP
- Notes: "10 Burpees, 15 KB Swings (53/35), 20 Box Jumps (24/20)"

**Steps**:
1. Navigate to a day with the AMRAP exercise
2. Open whiteboard view
3. Scroll to the Conditioning section
4. Locate the AMRAP exercise

**Expected Results**:
- ✅ Exercise name displayed (e.g., "Metcon")
- ✅ AMRAP prescription shown (e.g., "20 min AMRAP")
- ✅ Three bullet points displayed:
  - "10 Burpees"
  - "15 KB Swings (53/35)"
  - "20 Box Jumps (24/20)"
- ✅ Bullets use • character
- ✅ Text is properly formatted (monospaced font)

**Screenshot Location**: `docs/screenshots/whiteboard-amrap-bullets.png`

---

### Test Case 5: Strength Exercise Display
**Objective**: Verify strength exercises format correctly

**Setup**:
Find or create a strength exercise with:
- Type: Strength
- Sets: 5 sets of 5 reps
- Rest: 180 seconds
- Notes: "@ RPE 8"

**Steps**:
1. Navigate to a day with strength exercises
2. Open whiteboard view
3. Locate the strength exercise in the Strength section

**Expected Results**:
- ✅ Exercise name displayed (e.g., "Back Squat")
- ✅ Prescription shows "5 × 5 @ RPE 8"
- ✅ Rest time shows "Rest: 3:00"
- ✅ Format is clean and readable
- ✅ Monospace font used throughout

**Screenshot Location**: `docs/screenshots/whiteboard-strength.png`

---

### Test Case 6: Mixed Day (Strength + Conditioning)
**Objective**: Verify sections are properly organized

**Setup**:
Use a day that has both strength and conditioning exercises

**Steps**:
1. Navigate to a mixed day (strength + conditioning)
2. Open whiteboard view
3. Scroll through entire whiteboard

**Expected Results**:
- ✅ "STRENGTH" section header appears (uppercase, bold)
- ✅ Main lift exercises under Strength section
- ✅ "ACCESSORY" section header (if accessory exercises exist)
- ✅ Accessory exercises under Accessory section
- ✅ "CONDITIONING" section header appears
- ✅ Conditioning exercises under Conditioning section
- ✅ Sections in correct order: Strength → Accessory → Conditioning
- ✅ Clean separation between sections

**Screenshot Location**: `docs/screenshots/whiteboard-mixed-day.png`

---

### Test Case 7: Multi-Week Block Navigation
**Objective**: Verify whiteboard follows week changes

**Setup**:
Use a block with 2+ weeks

**Steps**:
1. In BlockRunMode, navigate to Week 1, Day 1
2. Open whiteboard, verify shows "Week 1 • Day 1"
3. Close whiteboard
4. Swipe to Week 2 in tracking view
5. Open whiteboard, verify shows "Week 2 • Day 1"

**Expected Results**:
- ✅ Week number in navigation bar matches current week
- ✅ Day content matches week-specific templates (if applicable)
- ✅ No way to change weeks within whiteboard (by design)

---

### Test Case 8: Edge Cases

#### 8a: Empty Day
**Steps**: Navigate to a day with no exercises, open whiteboard

**Expected Results**:
- ✅ Whiteboard opens without crash
- ✅ Shows message like "No data for this day" or empty content
- ✅ Can dismiss normally with X button

#### 8b: Exercise with No Notes
**Steps**: View exercise with no notes in whiteboard

**Expected Results**:
- ✅ Exercise displays normally
- ✅ No bullets or extra spacing for missing notes
- ✅ Only prescription and rest (if present) shown

#### 8c: Very Long Notes
**Steps**: Create exercise with very long notes (100+ characters), view in whiteboard

**Expected Results**:
- ✅ Notes parse into bullets correctly
- ✅ Content is scrollable
- ✅ No UI overflow or clipping

---

## Regression Testing

### Verify No Breaking Changes

**Test**: Existing whiteboard functionality (WhiteboardWeekView)
1. Navigate to a block's details page (not in run mode)
2. If whiteboard preview exists there, verify it still works
3. Week selector should work
4. Day cards should display

**Test**: Tracking view functionality
1. Complete sets in tracking view
2. Open whiteboard
3. Close whiteboard
4. Verify set completion persists

**Test**: Data persistence
1. Make progress on workout
2. Open whiteboard multiple times
3. Close app
4. Reopen app
5. Verify progress saved correctly

---

## Performance Testing

**Test**: Modal animation performance
- Modal should open/close smoothly
- No lag or stuttering
- Animation should be ~0.3 seconds

**Test**: Scrolling performance
- Whiteboard content should scroll smoothly
- No jank with long exercise lists
- Proper scroll indicators

---

## Accessibility Testing

**Test**: VoiceOver support
1. Enable VoiceOver
2. Navigate to whiteboard button
3. Verify label reads "View Whiteboard"
4. Open whiteboard
5. Navigate to X button
6. Verify label reads "Close whiteboard"

---

## Checklist

Before approving this PR, verify:
- [ ] All 8 test cases pass
- [ ] Screenshots captured and saved
- [ ] No crashes or errors observed
- [ ] Regression tests pass
- [ ] Performance is acceptable
- [ ] Accessibility works with VoiceOver
- [ ] Code builds successfully in CI
- [ ] All automated tests pass

---

## Reporting Issues

If any test fails, please document:
1. Test case number and name
2. Steps to reproduce
3. Expected vs actual behavior
4. Device/simulator details (iOS version, device model)
5. Screenshots or screen recording if possible

Report issues in PR comments or create new GitHub issues with label `whiteboard-fullscreen`.

---

## Success Criteria

This feature is ready to merge when:
✅ All test cases pass
✅ No regressions in existing functionality
✅ Code review approved
✅ CI build succeeds
✅ Manual testing complete on at least one iOS device/simulator

---

## Notes for Testers

- The whiteboard view uses monospace font for alignment
- Circuit movements in notes should be comma or newline separated
- The view is read-only (no editing in whiteboard mode)
- Dismissing whiteboard returns to exact same state in tracking view
- This is a display-only feature, no data mutations occur

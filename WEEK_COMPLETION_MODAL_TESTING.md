# Week and Block Completion Modal Testing Guide

## Overview

This document describes how to manually test the week and block completion modals implemented for issue #49.

## Feature Description

The app now shows celebration modals when:
1. **Week Completion**: Any week transitions from incomplete to complete
2. **Block Completion**: The final week of a block is completed (all weeks done)

## Modal Specifications

### Week Completion Modal
- **Title**: "Week completed"
- **Message**: "Excellence is not an act but a habit."
- **Styling**: Dark blue gradient header, rounded card with shadow
- **Dismiss**: "OK" button

### Block Completion Modal
- **Title**: "Block completed"  
- **Message**: "Fuck yeah! Block built."
- **Styling**: Bright blue/purple gradient header (more vibrant than week modal)
- **Dismiss**: "OK" button
- **Priority**: Shows instead of week modal when completing the final week

## Manual Testing Steps

### Test 1: Week Completion (Mid-Block)
1. Open a block with at least 2 weeks
2. Complete all sets in Week 1
3. Verify: Week completion modal appears
4. Dismiss the modal
5. Complete all sets in Week 2
6. Verify: Week completion modal appears again

### Test 2: Block Completion (Final Week)
1. Open a block with 3+ weeks
2. Complete all sets in Weeks 1 and 2
3. Complete all sets in the final week (Week 3)
4. Verify: Block completion modal appears (NOT week modal)
5. Dismiss the modal
6. Verify: No modal appears on subsequent saves

### Test 3: Single Week Block
1. Create a block with only 1 week
2. Complete all sets in that week
3. Verify: Block completion modal appears (since completing the only week = block done)

### Test 4: Partial Week Completion
1. Open any block
2. Complete some but not all sets in a week
3. Verify: No modal appears (week not complete)
4. Complete the remaining sets
5. Verify: Week completion modal appears

### Test 5: Modal Dismissal
1. Trigger any completion modal
2. Tap "OK" button
3. Verify: Modal dismisses smoothly
4. Tap outside the modal area (backdrop)
5. Verify: Modal also dismisses

### Test 6: Already Completed Week
1. Complete a week (modal appears)
2. Dismiss modal
3. Change a completed set back to incomplete
4. Complete it again
5. Verify: Week completion modal appears again (transition detected)

## Expected Behavior

### Detection Logic
- Modals trigger on **transitions** from incomplete → complete
- Saves are triggered by:
  - Set completion toggle
  - onChange handlers for set values
  - Closing the session
  - View disappearing
- Modal check happens after save verification

### Priority Rules
1. If both week and block would be completed → show block modal only
2. Otherwise show week modal
3. Only show modal for first completed week in a save operation

## Visual Verification Checklist

- [ ] Week modal has darker gradient (dark blue/navy)
- [ ] Block modal has brighter gradient (bright blue/purple)
- [ ] Both modals have rounded corners (16pt)
- [ ] Both modals have shadow effect
- [ ] Title is uppercase, bold, white text
- [ ] Message is centered, regular weight
- [ ] OK button spans full width with accent color background
- [ ] Modal appears with smooth fade-in animation
- [ ] Modal dismisses with smooth fade-out animation
- [ ] Semi-transparent backdrop dims content behind modal

## Code References

- **Modal View**: `WeekCompletionModal.swift`
- **Detection Logic**: `blockrunmode.swift` - `checkForCompletionTransition()` method
- **Tests**: `Tests/BlockRunModeCompletionTests.swift`

## Notes

- Tests are passing for the completion detection logic (4/4 tests pass)
- UI testing requires running in iOS simulator or on device
- The modals use SwiftUI's `.overlay()` modifier for presentation
- Animations use `.easeInOut(duration: 0.3)` for smooth transitions

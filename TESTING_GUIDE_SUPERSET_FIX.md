# Manual Testing Guide for Superset Whiteboard Fix

## Overview
This guide provides instructions for manually testing the superset whiteboard rendering fix.

## Prerequisites
- Xcode installed
- Repository cloned
- Project generated with XcodeGen (`xcodegen generate`)

## Test Data
The repository includes a test block with supersets at:
```
Tests/superset_yoga_demo_block.json
```

This block contains:
- Day 1: "Push/Pull Supersets" with 2 superset groups
  - Superset 1: Bench Press + Barbell Row (both main lifts)
  - Superset 2: Overhead Press + Pull-Up (both main lifts)
- Day 2: "Yoga & Mobility" (non-superset exercises)

## Test Scenarios

### Scenario 1: Import Superset Demo Block

**Steps:**
1. Open the app in Xcode and run on simulator
2. Import the test block from `Tests/superset_yoga_demo_block.json`
3. Navigate to the whiteboard view for Week 1, Day 1 ("Push/Pull Supersets")

**Expected Results:**
- ✅ "STRENGTH" section header appears
- ✅ Four exercises are shown under STRENGTH (not split between STRENGTH and ACCESSORY)
- ✅ First superset pair is labeled:
  - `a1) Bench Press`
  - `a2) Barbell Row`
- ✅ Second superset pair is labeled (labels restart):
  - `a1) Overhead Press`
  - `a2) Pull-Up`
- ✅ Each exercise shows proper prescription (e.g., "3 × 8 @ 135 lbs")
- ✅ Each exercise shows rest time (e.g., "Rest: 1:00")

**Screenshots to Capture:**
- Full whiteboard view showing both superset groups under STRENGTH header

### Scenario 2: Verify Non-Superset Exercises Still Work

**Steps:**
1. Navigate to Week 1, Day 2 ("Yoga & Mobility")
2. View the whiteboard

**Expected Results:**
- ✅ Exercises appear without a1/a2 labels
- ✅ All exercises are standalone items
- ✅ No regression in display format

**Screenshots to Capture:**
- Whiteboard view of non-superset day

### Scenario 3: Create Custom Block with Supersets

**Steps:**
1. Create a new block with AI or manually in JSON with these exercises:
   ```json
   {
     "exercises": [
       {
         "name": "Squat",
         "category": "squat",
         "setGroupId": "group-1",
         "strengthSets": [{"reps": 5}]
       },
       {
         "name": "Leg Curls",
         "category": "other",
         "setGroupId": "group-1",
         "strengthSets": [{"reps": 12}]
       }
     ]
   }
   ```
2. View the whiteboard

**Expected Results:**
- ✅ Both exercises appear under STRENGTH (Squat is main lift, so group stays in STRENGTH)
- ✅ Exercises are labeled:
  - `a1) Squat`
  - `a2) Leg Curls`

**Screenshots to Capture:**
- Mixed superset (main lift + accessory) under STRENGTH section

### Scenario 4: Mixed Superset and Standalone Exercises

**Steps:**
1. Create a block with:
   - Standalone main lift (Deadlift)
   - Superset pair (Bench Press + Barbell Row)
   - Standalone accessory (Bicep Curls)
2. View the whiteboard

**Expected Results:**
- ✅ STRENGTH section contains:
  - Deadlift (no label)
  - a1) Bench Press
  - a2) Barbell Row
- ✅ ACCESSORY section contains:
  - Bicep Curls (no label)

**Screenshots to Capture:**
- Mixed workout with both sections visible

## Automated Tests

Run the test suite to verify the formatting logic:

```bash
# Using Xcode
Product > Test (⌘U)

# Or using command line
xcodebuild test -scheme WorkoutTrackerApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Expected Test Results:**
All tests in `WhiteboardTests.swift` should pass, including:
- `testSupersetRenderingUnderStrengthSection`
- `testMultipleSupersetGroupsUnderStrengthSection`
- `testSupersetWithAccessoryExerciseStaysUnderStrength`
- `testMixedSupersetAndNonSupersetExercises`

## Verification Checklist

- [ ] Test scenario 1: Superset demo block imported and displayed correctly
- [ ] Test scenario 2: Non-superset exercises work without regression
- [ ] Test scenario 3: Custom mixed superset classified correctly
- [ ] Test scenario 4: Mixed superset and standalone exercises displayed correctly
- [ ] All automated tests pass
- [ ] Screenshots captured for documentation
- [ ] No visual glitches or layout issues

## Common Issues to Check

1. **Label Format**: Ensure labels are "a1)" not "a1." or just "a1"
2. **Section Classification**: Verify supersets don't get split between STRENGTH and ACCESSORY
3. **Multiple Groups**: Each superset group should restart labels at a1
4. **Dividers**: Visual dividers should appear between exercises
5. **Prescriptions**: Exercise details should display correctly with labels

## Regression Testing

To ensure no existing functionality broke:

1. **Test non-superset blocks**: Import any existing blocks without supersets
2. **Test conditioning exercises**: Verify AMRAP, EMOM, etc. still format correctly
3. **Test segment-based days**: Yoga/mobility days should work as before
4. **Test multi-week blocks**: Week progression should work normally

## Success Criteria

The fix is successful if:
1. ✅ Superset exercises with main lift categories stay under STRENGTH
2. ✅ Superset exercises are labeled a1, a2, a3, etc.
3. ✅ Multiple superset groups are supported in one day
4. ✅ Mixed supersets classify based on first exercise
5. ✅ No regression in non-superset exercise display
6. ✅ All automated tests pass

## Notes

- The fix does NOT change the session run view (blockrunmode.swift) - only the whiteboard view
- The whiteboard view is read-only; no changes to workout execution
- The labeling (a1, a2) is purely visual and does not affect workout data

# Testing Checklist: Exercise Dropdown Feature

## Pre-Testing Setup
- [ ] Build the app successfully (run `xcodegen generate` first)
- [ ] Launch app in simulator or on device
- [ ] Navigate to Block Builder (HomeView → Add Block or Edit Block)
- [ ] Start adding or editing a day with exercises

## Core Functionality Tests

### 1. Dropdown Display - Strength Exercises
- [ ] Set exercise type to "Strength"
- [ ] Verify dropdown button shows "Select exercise" placeholder
- [ ] Tap dropdown button
- [ ] Verify strength exercises appear in menu (Back Squat, Bench Press, etc.)
- [ ] Verify no conditioning exercises appear
- [ ] Verify "Custom Exercise" option appears at bottom with divider
- [ ] Select an exercise from the list
- [ ] Verify exercise name appears in the dropdown button
- [ ] Verify exercise name is in primary text color (not gray)

### 2. Dropdown Display - Conditioning Exercises
- [ ] Set exercise type to "Conditioning"
- [ ] Tap dropdown button
- [ ] Verify conditioning exercises appear (Assault Bike, Row Erg, etc.)
- [ ] Verify no strength exercises appear
- [ ] Select a conditioning exercise
- [ ] Verify exercise name populates correctly

### 3. Toggle to Custom Entry Mode
- [ ] In dropdown mode, tap the pencil icon (✎) button
- [ ] Verify text field appears with rounded border
- [ ] Verify pencil icon changes to list icon (☰)
- [ ] Verify current exercise name is preserved in text field
- [ ] Type a custom exercise name
- [ ] Verify text updates as you type

### 4. Toggle Back to Dropdown Mode
- [ ] In custom entry mode, tap the list icon (☰) button
- [ ] Verify dropdown button reappears
- [ ] Verify custom exercise name is preserved
- [ ] Tap dropdown to verify standard exercises still available

### 5. "Custom Exercise" Menu Option
- [ ] In dropdown mode, tap dropdown button
- [ ] Scroll to bottom of menu
- [ ] Tap "Custom Exercise" option
- [ ] Verify switches to text entry mode
- [ ] Verify current exercise name is preserved (not cleared)

### 6. Exercise Type Changes
- [ ] Select a strength exercise (e.g., "Bench Press")
- [ ] Change exercise type to "Conditioning"
- [ ] Verify dropdown refreshes automatically
- [ ] Tap dropdown button
- [ ] Verify only conditioning exercises appear
- [ ] Verify "Bench Press" name is still shown (preserved)
- [ ] Change back to "Strength"
- [ ] Verify strength exercises appear again

### 7. Saving Exercise with Dropdown Selection
- [ ] Select exercise "Back Squat" from dropdown
- [ ] Fill in sets, reps, weight
- [ ] Save the day
- [ ] Edit the day again
- [ ] Verify "Back Squat" is still selected in dropdown

### 8. Saving Exercise with Custom Name
- [ ] Switch to custom entry mode
- [ ] Type "My Custom Exercise"
- [ ] Fill in other exercise details
- [ ] Save the day
- [ ] Edit the day again
- [ ] Verify "My Custom Exercise" appears in text field or dropdown

### 9. Multiple Exercises in Same Day
- [ ] Add first exercise using dropdown (e.g., "Deadlift")
- [ ] Add second exercise using custom entry (e.g., "Cable Flyes")
- [ ] Add third exercise using dropdown (e.g., "Row Erg" - conditioning)
- [ ] Verify each exercise maintains its selection
- [ ] Save and verify all three exercises preserved

## Edge Cases

### 10. Empty Exercise Name
- [ ] Leave exercise name blank
- [ ] Try to save the day
- [ ] Verify empty exercises are filtered out (as per existing logic)

### 11. Very Long Exercise Name
- [ ] Enter a very long custom exercise name (50+ characters)
- [ ] Verify text field handles long text
- [ ] Verify dropdown button truncates or wraps text appropriately
- [ ] Save and verify long name is preserved

### 12. Special Characters in Custom Name
- [ ] Enter exercise name with special characters: "Pull-Up (Wide Grip)"
- [ ] Verify characters are accepted
- [ ] Save and reload
- [ ] Verify special characters preserved

### 13. Rapid Type Switching
- [ ] Switch exercise type multiple times rapidly: Strength → Conditioning → Strength → Conditioning
- [ ] Verify picker updates correctly each time
- [ ] Verify no crashes or UI glitches

### 14. Rapid Mode Toggling
- [ ] Toggle between dropdown and custom mode multiple times rapidly
- [ ] Verify no crashes or state corruption
- [ ] Verify exercise name preserved throughout

## UI/UX Verification

### 15. Visual Appearance - Light Mode
- [ ] Test in light mode
- [ ] Verify dropdown button has proper border
- [ ] Verify chevron icon visible
- [ ] Verify toggle button background visible
- [ ] Verify text is readable

### 16. Visual Appearance - Dark Mode
- [ ] Switch to dark mode (Settings → Dark Appearance)
- [ ] Verify dropdown button adapts colors
- [ ] Verify text remains readable
- [ ] Verify borders and backgrounds adapt

### 17. Accessibility - VoiceOver
- [ ] Enable VoiceOver
- [ ] Navigate to exercise picker
- [ ] Verify dropdown button announces correctly
- [ ] Verify toggle button announces correctly
- [ ] Verify menu items announce correctly

### 18. Accessibility - Dynamic Type
- [ ] Enable larger text sizes (Settings → Display & Brightness → Text Size)
- [ ] Verify text in dropdown scales appropriately
- [ ] Verify picker remains usable with large text

## Integration Tests

### 19. Block Creation Flow
- [ ] Create new block with multiple days
- [ ] Use mix of dropdown and custom exercises
- [ ] Save block
- [ ] Navigate away and back
- [ ] Verify all exercises preserved

### 20. Block Editing Flow
- [ ] Edit existing block
- [ ] Change some exercises from custom to dropdown selections
- [ ] Change some from dropdown to custom
- [ ] Save changes
- [ ] Verify changes preserved

### 21. Session Generation
- [ ] Create block with exercises selected from dropdown
- [ ] Generate sessions (existing functionality)
- [ ] Start a workout session
- [ ] Verify exercise names appear correctly in session

### 22. Exercise Library Not Loaded (Edge Case)
- [ ] If possible, test with fresh install where library might not load immediately
- [ ] Verify text field appears as fallback
- [ ] Verify app doesn't crash

## Performance Tests

### 23. Dropdown Performance
- [ ] Open dropdown menu
- [ ] Scroll through all exercises
- [ ] Verify smooth scrolling
- [ ] Verify no lag when selecting exercises

### 24. Multiple Exercises Performance
- [ ] Create day with 10+ exercises
- [ ] Use dropdown for each one
- [ ] Verify no performance degradation
- [ ] Verify save operation is fast

## Regression Tests

### 25. Existing Blocks Compatibility
- [ ] Open existing block with custom exercise names
- [ ] Verify names still appear correctly
- [ ] Edit and save
- [ ] Verify no data loss

### 26. Exercise Notes Preserved
- [ ] Add exercise with notes field filled
- [ ] Change exercise name using dropdown
- [ ] Verify notes are preserved
- [ ] Save and reload
- [ ] Verify notes still present

### 27. Set Configuration Preserved
- [ ] Configure sets, reps, weight for exercise
- [ ] Change exercise name using dropdown
- [ ] Verify set configuration unchanged
- [ ] Save and reload
- [ ] Verify configuration preserved

## Final Verification

### 28. Complete Block Builder Flow
- [ ] Create complete training block
- [ ] Use mix of dropdown and custom exercises
- [ ] Include both strength and conditioning
- [ ] Save block
- [ ] Edit block
- [ ] Change some exercises
- [ ] Save again
- [ ] Generate and run a session
- [ ] Verify entire flow works end-to-end

### 29. User Experience Check
- [ ] Verify dropdown is faster than typing for standard exercises
- [ ] Verify custom entry is still easy to access
- [ ] Verify UI is intuitive and discoverable
- [ ] Verify no confusion between modes

### 30. Code Review Items Verified
- [ ] Verify exercise name preserved when toggling modes
- [ ] Verify no temporary repository issues in app init
- [ ] Verify type changes refresh picker correctly

## Sign-Off
- [ ] All core functionality tests passed
- [ ] All edge cases handled gracefully
- [ ] All UI/UX verification passed
- [ ] All integration tests passed
- [ ] All performance tests acceptable
- [ ] All regression tests passed
- [ ] No crashes or errors observed
- [ ] Feature ready for production

---

## Testing Notes
Use this section to record any issues found during testing:

**Issue:** [Description]
**Steps to Reproduce:** [Steps]
**Expected:** [Expected behavior]
**Actual:** [Actual behavior]
**Severity:** [Low/Medium/High]
**Status:** [Open/Fixed/Won't Fix]

---

## Test Environment
- **iOS Version:** _________
- **Device/Simulator:** _________
- **Build Date:** _________
- **Tester:** _________
- **Date Tested:** _________

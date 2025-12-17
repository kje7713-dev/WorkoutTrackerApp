# Block History Feature - UI/UX Guide

## Overview

This guide describes the user interface changes for the block history feature, including navigation flows, screen layouts, and user interactions.

## Navigation Structure

```
Home View
├── BLOCKS → BlocksListView (Active Blocks)
│   ├── RUN → BlockRunModeView
│   ├── EDIT → BlockBuilderView
│   ├── NEXT BLOCK → BlockBuilderView (clone mode)
│   ├── ARCHIVE (moves to history)
│   └── DELETE
│
└── BLOCK HISTORY → BlockHistoryListView (Archived Blocks)
    ├── REVIEW → BlockRunModeView
    ├── EDIT → BlockBuilderView
    ├── NEXT BLOCK → BlockBuilderView (clone mode)
    ├── UNARCHIVE (restores to active)
    └── DELETE
```

## Screen-by-Screen Breakdown

### 1. Home View (Updated)

**Changes:**
- Added "BLOCK HISTORY" button below "Today (Future)"
- Replaced placeholder "History (Future)" with functional navigation

**Button Appearance:**
- Text: "BLOCK HISTORY"
- Style: Full-width button with dark background (matches BLOCKS button)
- Font: System font, size 16, semibold, uppercase
- Height: 52 points
- Corner radius: 20

**User Action:**
- Tap "BLOCK HISTORY" → Navigate to BlockHistoryListView

---

### 2. BlocksListView (Updated)

**Changes:**
- Now shows only **active** (non-archived) blocks
- Added "ARCHIVE" button to each block card

**Block Card Layout:**
```
┌─────────────────────────────────────┐
│ Block Name (Headline, Bold)         │
│ Description (Subheadline, Secondary)│
│                                     │
│ ⏱ 4 weeks  🎯 Strength  ✨ AI      │
│                                     │
│ ┌─────┐ ┌──────┐ ┌────────────┐   │
│ │ RUN │ │ EDIT │ │ NEXT BLOCK │   │
│ └─────┘ └──────┘ └────────────┘   │
│                                     │
│ ARCHIVE (footnote size)             │
│ DELETE (footnote size, destructive) │
└─────────────────────────────────────┘
```

**Button Behaviors:**
- **RUN**: Navigate to BlockRunModeView (run the block)
- **EDIT**: Open BlockBuilderView in edit mode
- **NEXT BLOCK**: Open BlockBuilderView in clone mode
- **ARCHIVE**: Move block to history (immediate effect)
- **DELETE**: Permanently delete the block (destructive action)

**Empty State:**
When no active blocks exist:
```
No blocks yet

Create a block in the builder, then come back 
here to run it.
```

---

### 3. BlockHistoryListView (New)

**Header:**
- Title: "Block History" (Large title, bold)
- Subtitle: "Review your archived blocks." (Body, secondary color)

**Block Card Layout:**
```
┌─────────────────────────────────────┐
│ Block Name (Headline, Bold)         │
│ Description (Subheadline, Secondary)│
│                                     │
│ ⏱ 4 weeks  🎯 Strength  ✨ AI      │
│                                     │
│ ┌────────┐ ┌──────┐ ┌────────────┐│
│ │REVIEW │ │ EDIT │ │ NEXT BLOCK ││
│ └────────┘ └──────┘ └────────────┘│
│                                     │
│ UNARCHIVE (footnote size)           │
│ DELETE (footnote size, destructive) │
└─────────────────────────────────────┘
```

**Key Differences from BlocksListView:**
1. "REVIEW" button instead of "RUN" (same functionality)
2. "UNARCHIVE" button instead of "ARCHIVE"
3. Different header text

**Button Behaviors:**
- **REVIEW**: Navigate to BlockRunModeView (view completed sessions)
- **EDIT**: Open BlockBuilderView in edit mode
- **NEXT BLOCK**: Open BlockBuilderView in clone mode (create new block based on this)
- **UNARCHIVE**: Restore block to active list (immediate effect)
- **DELETE**: Permanently delete the block (destructive action)

**Empty State:**
When no archived blocks exist:
```
No archived blocks

Completed or NLA blocks you archive will 
appear here.
```

---

## User Workflows

### Workflow 1: Archive a Completed Block

1. User opens app → sees Home View
2. User taps "BLOCKS"
3. User scrolls to find completed block
4. User taps "ARCHIVE" on the block
5. Block immediately disappears from the list
6. User can now access it via "BLOCK HISTORY"

**Duration**: ~5 seconds

---

### Workflow 2: Review an Archived Block

1. User opens app → sees Home View
2. User taps "BLOCK HISTORY"
3. User sees list of archived blocks
4. User taps "REVIEW" on desired block
5. User navigates through block sessions (same as RUN mode)
6. User can view all historical data

**Duration**: Variable (depends on review needs)

---

### Workflow 3: Unarchive a Block

1. User opens app → sees Home View
2. User taps "BLOCK HISTORY"
3. User finds block to restore
4. User taps "UNARCHIVE"
5. Block immediately disappears from history list
6. Block reappears in "BLOCKS" view
7. User can now run it again

**Duration**: ~5 seconds

---

### Workflow 4: Create Next Block from History

1. User opens app → sees Home View
2. User taps "BLOCK HISTORY"
3. User finds previous block to use as template
4. User taps "NEXT BLOCK"
5. BlockBuilderView opens with cloned data
6. User modifies as needed
7. User saves new block
8. New block appears in "BLOCKS" (active list)

**Duration**: Variable (depends on modifications)

---

## Visual Design Consistency

### Colors & Styling

**Button Styles:**
- Primary Action (RUN/REVIEW): `.borderedProminent` (system blue)
- Secondary Actions (EDIT, NEXT BLOCK): `.bordered` (system default)
- Tertiary Actions (ARCHIVE, UNARCHIVE): Plain text, footnote size
- Destructive Actions (DELETE): Red text, footnote size

**Card Styling:**
- Background: `.secondarySystemBackground`
- Corner radius: 16 points
- Padding: Standard (matches existing cards)
- Spacing: 16 points between cards

**Typography:**
- Block Name: `.headline`, bold
- Description: `.subheadline`, secondary color
- Metadata: `.caption`, secondary color
- Button Text: `.subheadline`, bold for primary/secondary actions
- Action Links: `.footnote` for tertiary actions

### Icons

Used in metadata row:
- 📅 `calendar` - Number of weeks
- 🎯 `target` - Training goal
- ✨ `sparkles` - AI-generated indicator

---

## Accessibility Considerations

1. **VoiceOver Support:**
   - All buttons have clear, descriptive labels
   - "REVIEW" vs "RUN" provides context about archived state
   - Card structure maintains logical reading order

2. **Dynamic Type:**
   - All text scales with system font size settings
   - Button sizes accommodate larger text

3. **Color Independence:**
   - Destructive actions use both red color AND role indicator
   - Information conveyed through text, not just color

4. **Touch Targets:**
   - All buttons meet minimum 44x44 point touch target size
   - Adequate spacing between interactive elements

---

## Performance Characteristics

**List Rendering:**
- Efficient SwiftUI rendering with `ForEach` and `Identifiable`
- Filter operations are O(n) but acceptable for expected block counts
- Lazy loading handled by `ScrollView`

**State Management:**
- `@EnvironmentObject` for shared repositories
- Automatic view updates via `@Published` properties
- Immediate UI updates on archive/unarchive

**Persistence:**
- Archive state persists via JSON (existing mechanism)
- No additional storage overhead
- Backward compatible with existing data

---

## Edge Cases & Error Handling

### No Active Blocks
- Clear empty state message
- Directs user to create blocks

### No Archived Blocks
- Clear empty state message
- Explains where archived blocks come from

### Archive During Active Session
- Block remains accessible via back navigation
- Archive state persists after session ends

### Unarchive While In History View
- Block disappears from current list immediately
- Appears in Blocks view when user navigates there

---

## Testing Checklist

### Visual Testing
- [ ] Home view shows BLOCK HISTORY button
- [ ] Blocks view shows only active blocks
- [ ] History view shows only archived blocks
- [ ] Empty states display correctly
- [ ] Card layouts match between views
- [ ] Button styles are consistent

### Functional Testing
- [ ] Archive button moves block to history
- [ ] Unarchive button restores block to active
- [ ] REVIEW button navigates correctly
- [ ] Navigation flows work as expected
- [ ] State persists across app restarts

### Edge Case Testing
- [ ] Empty active blocks list
- [ ] Empty archived blocks list
- [ ] Archive while session is open
- [ ] Rapid archive/unarchive cycles
- [ ] Delete from history

---

## Screenshots

_Screenshots will be added once the app is built and running in the simulator or on a device._

### Key Screens to Capture:
1. Home View with BLOCK HISTORY button
2. Blocks View (with ARCHIVE button visible)
3. Block History View (empty state)
4. Block History View (with archived blocks)
5. Block card showing all buttons (ARCHIVE/UNARCHIVE)

---

## Future UI Enhancements

Potential improvements for future iterations:

1. **Visual Indicators:**
   - Subtle "Archived" badge on blocks in history
   - Completion percentage or date indicators

2. **Swipe Actions:**
   - Swipe to archive/unarchive
   - Swipe to delete

3. **Bulk Operations:**
   - Select multiple blocks to archive at once
   - Batch delete from history

4. **Search & Filter:**
   - Search bar in both views
   - Filter by goal, source, or date

5. **Statistics:**
   - Show total weeks trained in history
   - Display completion statistics

6. **Animations:**
   - Smooth transition when archiving/unarchiving
   - Fade in/out for card additions/removals

---

## Summary

The Block History UI provides a clean, consistent experience for managing completed blocks. The design:

✅ Maintains visual consistency with existing UI  
✅ Provides clear affordances for all actions  
✅ Follows iOS Human Interface Guidelines  
✅ Supports accessibility features  
✅ Handles edge cases gracefully  
✅ Performs efficiently with expected data volumes  

The feature integrates seamlessly into the existing app structure while providing valuable new functionality for users with multiple training blocks.

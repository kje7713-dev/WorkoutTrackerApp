# Week Completion Toggle - Quick Reference

## Problem Solved

✅ **Create a toggle on blockrunmode to complete a week**
- Added manual week completion toggle at top of each week view
- Users can mark/unmark weeks as complete independent of set completion

✅ **Open blockrunmode mode to greatest week where not completed**
- Already working via `findActiveWeekIndex()`
- Navigates to first incomplete week (whether manually or automatically incomplete)

## Changes at a Glance

| File | Change | Purpose |
|------|--------|---------|
| `Models.swift` | Added `weekCompletedAt: Date?` to `WorkoutSession` | Persist manual week completion |
| `blockrunmode.swift` | Added `weekCompletedAt: Date?` to `RunWeekState` | Track completion in UI state |
| `blockrunmode.swift` | Updated `RunWeekState.isCompleted` logic | Check manual completion first |
| `blockrunmode.swift` | Added week completion banner to `WeekRunView` | UI toggle button |
| `RunStateMapper.swift` | Updated `sessionsToRunWeeks()` | Extract weekCompletedAt from sessions |
| `RunStateMapper.swift` | Updated `runWeeksToSessions()` | Apply weekCompletedAt to all sessions in week |
| `Tests/BlockRunModeCompletionTests.swift` | Added `testManualWeekCompletion()` | Verify manual completion behavior |

## UI Component

```
┌─────────────────────────────────────────────────────────┐
│  Week 1               [✓] Week Complete                 │  ← Week Completion Banner
│  Background: Light green                                 │
├─────────────────────────────────────────────────────────┤
│  [ Mon ]  [ Tue ]  [ Wed ]  [ Thu ]  [ Fri ]           │  ← Day Tabs
└─────────────────────────────────────────────────────────┘
```

**States:**
- **Incomplete:** Gray circle icon, "Mark Week Complete", default background
- **Complete:** Green checkmark icon, "Week Complete", green background

**Interaction:**
- Tap to toggle between complete/incomplete
- Changes persist to sessions.json
- Triggers save and may show completion modal

## Key Code Locations

### Model Definition
```swift
// Models.swift (line ~1055)
public var weekCompletedAt: Date?
```

### UI Toggle
```swift
// blockrunmode.swift (line ~700)
private var weekCompletionBanner: some View {
    // Week completion toggle implementation
}
```

### Completion Logic
```swift
// blockrunmode.swift (line ~1827)
var isCompleted: Bool {
    if weekCompletedAt != nil {
        return true  // Manual completion
    }
    // ... check set completion ...
}
```

### Mapper
```swift
// RunStateMapper.swift (line ~44-50)
let weekCompletedAt = weekSessions.first?.weekCompletedAt
return RunWeekState(
    index: weekIndex - 1,
    days: dayStates,
    weekCompletedAt: weekCompletedAt
)

// RunStateMapper.swift (line ~299-300)
updatedSession.weekCompletedAt = week.weekCompletedAt
```

## Data Structure

```
WorkoutSession (Persistent Storage - sessions.json)
├─ id: UUID
├─ blockId: UUID
├─ weekIndex: Int (1-based)
├─ dayTemplateId: UUID
├─ weekCompletedAt: Date? ← NEW FIELD
└─ exercises: [SessionExercise]

RunWeekState (UI State)
├─ id: UUID
├─ index: Int (0-based)
├─ weekCompletedAt: Date? ← NEW FIELD
└─ days: [RunDayState]
    └─ exercises: [RunExerciseState]
        └─ sets: [RunSetState]
            └─ isCompleted: Bool
```

## Completion Determination

```swift
Week is Complete IF:
  weekCompletedAt != nil  // Manual completion
  OR
  allSetsComplete == true  // Automatic completion
```

## Navigation Logic

```swift
findActiveWeekIndex() returns:
  weeks.firstIndex(where: { !$0.isCompleted })  // First incomplete week
  OR
  weeks.count - 1  // Last week if all complete
```

## Testing

**Run Tests:**
```swift
BlockRunModeCompletionTests.runAllTests()
```

**Expected Output:**
```
🧪 Running Block Completion Modal Tests
============================================================

🧪 Testing: Week completion modal triggers on single week completion
  ✅ PASS: Week modal triggered correctly

🧪 Testing: Block completion modal triggers when final week completes
  ✅ PASS: Block modal triggered correctly (takes precedence)

🧪 Testing: No modal triggers when no week completes
  ✅ PASS: No modal triggered (correct)

🧪 Testing: Single-week block completion shows block modal
  ✅ PASS: Block modal triggered for single-week block

🧪 Testing: Manual week completion triggers modal
  ✅ PASS: Week modal triggered for manual completion

============================================================
📊 Test Results: 5 passed, 0 failed
============================================================
```

## Manual Testing Checklist

- [ ] Open block in run mode
- [ ] Verify banner shows "Week 1" and "Mark Week Complete"
- [ ] Tap "Mark Week Complete" button
- [ ] Verify background turns light green
- [ ] Verify button shows green checkmark and "Week Complete"
- [ ] Close and reopen app
- [ ] Verify week still shows as complete (persistence)
- [ ] Tap "Week Complete" button again
- [ ] Verify week unmarked (returns to default state)
- [ ] Complete all sets in a different week
- [ ] Verify automatic completion still works
- [ ] Navigate between weeks
- [ ] Verify opens to first incomplete week

## Common Use Cases

### 1. Skip Incomplete Week
```
Scenario: User wants to move on despite incomplete work
Action: Mark week as complete manually
Result: Week marked done, navigation skips to next week
```

### 2. Deload/Rest Week
```
Scenario: Week has no planned work or is rest week
Action: Mark week as complete without logging sets
Result: Week complete, can progress to next training week
```

### 3. Correction
```
Scenario: User marked week complete by mistake
Action: Tap button again to unmark
Result: Week returns to incomplete state
```

### 4. Return to Old Work
```
Scenario: User unmarked old week to complete missed work
Action: Unmark week from completed state
Result: Navigation opens to that week (now first incomplete)
```

## Backward Compatibility

✅ **Existing Data:**
- Old sessions without `weekCompletedAt` work fine (nil = not manually completed)
- No migration needed

✅ **Existing Behavior:**
- Automatic completion (all sets done) still works
- Week completion modals still trigger
- Navigation logic unchanged (just uses updated isCompleted)

✅ **Codable:**
- Optional field is Codable-compatible
- JSON encoding/decoding works with or without field

## Documentation Files

- `WEEK_COMPLETION_TOGGLE_IMPLEMENTATION.md` - Detailed technical documentation
- `WEEK_COMPLETION_TOGGLE_VISUAL_GUIDE.md` - UI/UX visual documentation
- `WEEK_COMPLETION_TOGGLE_QUICK_REFERENCE.md` - This file (quick reference)

## Git Commits

```bash
ad204bd - Initial plan
eeb3a99 - Add manual week completion toggle feature
d238585 - Add documentation for week completion toggle feature
```

## Summary

The week completion toggle feature allows users to manually mark weeks as complete independent of individual set completion. This is implemented through:

1. **Model Layer:** `weekCompletedAt: Date?` field added to `WorkoutSession` and `RunWeekState`
2. **UI Layer:** Toggle button in `WeekRunView` with clear visual states
3. **Mapping Layer:** `RunStateMapper` handles bidirectional conversion
4. **Persistence:** Saved to sessions.json via `SessionsRepository`
5. **Navigation:** Automatically opens to first incomplete week

The feature is backward compatible, well-tested, and documented. Manual completion works alongside automatic completion (all sets done), giving users flexibility in their training workflow.

# Week Completion Toggle Implementation Summary

## Overview
This implementation adds a manual toggle to mark weeks as complete in BlockRunMode, independent of individual set completion. This allows users to explicitly mark a week as finished even if they haven't completed every single set.

## Problem Statement
1. **Create a toggle on blockrunmode to complete a week** - Users can now manually mark a week as complete
2. **Open blockrunmode mode to greatest week where not completed** - Already working (findActiveWeekIndex navigates to first incomplete week)

## Changes Made

### 1. Model Changes

#### WorkoutSession (Models.swift)
```swift
public struct WorkoutSession: Identifiable, Codable, Equatable {
    // ... existing fields ...
    
    /// Timestamp when the week was manually marked as complete
    /// Used for manual week completion feature (one timestamp per week, duplicated across all sessions in that week)
    public var weekCompletedAt: Date?
    
    public init(
        // ... existing params ...
        weekCompletedAt: Date? = nil
    ) {
        // ... initialization ...
        self.weekCompletedAt = weekCompletedAt
    }
}
```

**Key Points:**
- Added optional `weekCompletedAt` field to track manual week completion
- Same value is duplicated across all WorkoutSessions in the same week
- Persisted to sessions.json via SessionsRepository

#### RunWeekState (blockrunmode.swift)
```swift
struct RunWeekState: Identifiable, Codable {
    var id = UUID()
    let index: Int
    var days: [RunDayState]
    
    /// Timestamp when the week was manually marked as complete
    var weekCompletedAt: Date?

    var isCompleted: Bool {
        // If manually marked complete, return true
        if weekCompletedAt != nil {
            return true
        }
        
        // Otherwise check if all sets and segments are completed
        // ... existing completion logic ...
    }
}
```

**Key Points:**
- Added `weekCompletedAt` field for UI state
- Updated `isCompleted` computed property to prioritize manual completion
- If `weekCompletedAt` is set, week is considered complete regardless of set completion status

### 2. Mapper Changes

#### RunStateMapper.sessionsToRunWeeks
```swift
// Extract weekCompletedAt from any session in this week (they should all have the same value)
let weekCompletedAt = weekSessions.first?.weekCompletedAt

return RunWeekState(
    index: weekIndex - 1,
    days: dayStates,
    weekCompletedAt: weekCompletedAt
)
```

**Key Points:**
- Extracts `weekCompletedAt` from any session in the week (all sessions share same value)
- Maps to RunWeekState for UI

#### RunStateMapper.runWeeksToSessions
```swift
// Update the session with logged values from run state
var updatedSession = updateSession(
    originalSession,
    with: runDay,
    dayTemplate: dayTemplate
)

// Apply weekCompletedAt to all sessions in this week
updatedSession.weekCompletedAt = week.weekCompletedAt

updatedSessions.append(updatedSession)
```

**Key Points:**
- Applies `weekCompletedAt` from RunWeekState to all WorkoutSessions in that week
- Ensures consistent state across all sessions

### 3. UI Changes

#### WeekRunView (blockrunmode.swift)
```swift
private var weekCompletionBanner: some View {
    HStack {
        Text("Week \(week.index + 1)")
            .font(.headline)
            .fontWeight(.bold)
        
        Spacer()
        
        Button(action: {
            if week.weekCompletedAt != nil {
                // Uncomplete the week
                week.weekCompletedAt = nil
            } else {
                // Complete the week
                week.weekCompletedAt = Date()
            }
            onSave()
        }) {
            HStack(spacing: 6) {
                Image(systemName: week.weekCompletedAt != nil ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(week.weekCompletedAt != nil ? .green : .gray)
                
                Text(week.weekCompletedAt != nil ? "Week Complete" : "Mark Week Complete")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .accessibilityLabel(week.weekCompletedAt != nil ? "Unmark week as complete" : "Mark week as complete")
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
        week.weekCompletedAt != nil
            ? Color.green.opacity(0.1)
            : Color(.systemBackground)
    )
}
```

**Visual Features:**
- Banner at top of week view showing "Week N"
- Toggle button with checkmark icon
- Green background when week is marked complete
- Clear labeling: "Week Complete" vs "Mark Week Complete"
- Accessible with proper labels

### 4. Test Updates

#### BlockRunModeCompletionTests.swift
Added new test case:
```swift
/// Test that manually completing a week triggers the completion modal
static func testManualWeekCompletion() -> Bool {
    // ... test implementation ...
}
```

**Test Coverage:**
- Verifies manual completion triggers week completion modal
- Tests that manually completed weeks are properly detected
- Added to test runner alongside existing tests

## Data Flow

### Marking Week Complete
1. User taps "Mark Week Complete" button in WeekRunView
2. `week.weekCompletedAt = Date()` sets completion timestamp
3. `onSave()` called, triggering `BlockRunModeView.saveWeeks()`
4. `RunStateMapper.runWeeksToSessions()` converts RunWeekState to WorkoutSessions
5. `weekCompletedAt` applied to all sessions in that week
6. `SessionsRepository.replaceSessions()` persists to sessions.json
7. Week completion modal may trigger based on transition logic

### Loading Existing Completion State
1. `BlockRunModeView.initializeWeeks()` loads sessions from SessionsRepository
2. `RunStateMapper.sessionsToRunWeeks()` converts to RunWeekState
3. `weekCompletedAt` extracted from first session in week
4. UI displays completion state in banner

### Navigation Behavior (Already Working)
- `findActiveWeekIndex()` finds first week where `!$0.isCompleted`
- `RunWeekState.isCompleted` returns true if `weekCompletedAt != nil`
- Therefore, manually completed weeks are skipped, opening first incomplete week

## Backward Compatibility

**New Fields:**
- `WorkoutSession.weekCompletedAt` is optional, defaults to nil
- Existing sessions without this field will have nil value (week not manually completed)
- Codable compatibility maintained

**Behavior:**
- Weeks with all sets complete: `isCompleted = true` (existing behavior)
- Weeks with manual completion: `isCompleted = true` (new behavior)
- Weeks with some sets incomplete and not manually complete: `isCompleted = false` (existing behavior)

## Edge Cases Handled

1. **Unmarking Completion:** User can tap button again to unmark week as complete
2. **Multiple Sessions per Week:** `weekCompletedAt` consistently applied to all sessions
3. **Persistence:** Completion state persists across app launches via sessions.json
4. **Completion Modals:** Manual completion triggers same modals as automatic completion
5. **Navigation:** Already navigates to first incomplete week (whether manually or automatically incomplete)

## Files Modified

1. **Models.swift** - Added `weekCompletedAt` to WorkoutSession
2. **RunStateMapper.swift** - Bidirectional mapping for weekCompletedAt
3. **blockrunmode.swift** - UI toggle and RunWeekState updates
4. **Tests/BlockRunModeCompletionTests.swift** - Added manual completion test

## Testing

### Manual Testing
1. Open block in run mode
2. Click "Mark Week Complete" button
3. Verify green background appears
4. Verify button text changes to "Week Complete"
5. Close and reopen - completion state should persist
6. Click button again to unmark
7. Navigate to next week - should skip completed weeks

### Automated Testing
- Run `BlockRunModeCompletionTests.runAllTests()`
- Verifies manual completion detection logic
- 5 tests total (4 existing + 1 new)

## Future Enhancements

Potential improvements:
1. Show completion date in UI (currently just stored)
2. Completion percentage indicator (X/Y sets complete)
3. Bulk operations (complete all remaining weeks)
4. Undo last completion with confirmation
5. Analytics on manual vs automatic completions

## Notes

- Manual completion does NOT mark individual sets as complete
- Sets remain in their original state
- Useful for scenarios where user wants to move on despite incomplete sets
- Week completion modal still triggers on manual completion transitions

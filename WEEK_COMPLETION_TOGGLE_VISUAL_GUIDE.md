# Week Completion Toggle - Visual Guide

## UI Location

The week completion toggle appears at the top of each week view, above the day tabs.

```
┌─────────────────────────────────────────────────────────┐
│  Week 1               [○] Mark Week Complete            │  ← Week Completion Banner (default)
├─────────────────────────────────────────────────────────┤
│  [ Mon ]  [ Tue ]  [ Wed ]  [ Thu ]  [ Fri ]           │  ← Day Tabs
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Exercise 1                                              │
│  Set 1: [Complete] ...                                  │
│  Set 2: [Complete] ...                                  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## States

### 1. Incomplete Week (Default)
```
┌─────────────────────────────────────────────────────────┐
│  Week 1               [○] Mark Week Complete            │
│  Background: Default (system background)                 │
│  Icon: Empty circle (gray)                              │
│  Text: "Mark Week Complete"                             │
└─────────────────────────────────────────────────────────┘
```

**Characteristics:**
- Light/white background
- Gray empty circle icon
- Button text: "Mark Week Complete"
- Shows when `weekCompletedAt == nil`

### 2. Completed Week (Manual)
```
┌─────────────────────────────────────────────────────────┐
│  Week 1               [✓] Week Complete                 │
│  Background: Light green (green opacity 0.1)            │
│  Icon: Filled checkmark circle (green)                  │
│  Text: "Week Complete"                                  │
└─────────────────────────────────────────────────────────┘
```

**Characteristics:**
- Light green background
- Green filled checkmark circle icon
- Button text: "Week Complete"
- Shows when `weekCompletedAt != nil`

## Interaction Flow

### Marking Complete
```
User Action:
  Tap "Mark Week Complete" button
    ↓
State Change:
  weekCompletedAt = Date() (current timestamp)
    ↓
Visual Update:
  - Background changes to light green
  - Icon changes to filled green checkmark
  - Text changes to "Week Complete"
    ↓
Save Triggered:
  onSave() persists to SessionsRepository
    ↓
Completion Modal:
  Week completion modal may appear
```

### Unmarking Complete
```
User Action:
  Tap "Week Complete" button again
    ↓
State Change:
  weekCompletedAt = nil
    ↓
Visual Update:
  - Background returns to default
  - Icon changes to empty gray circle
  - Text changes to "Mark Week Complete"
    ↓
Save Triggered:
  onSave() persists to SessionsRepository
```

## Layout Details

### Banner Components
```
┌─────────────────────────────────────────────────────────┐
│ [Week Label]                         [Completion Toggle] │
│                                                          │
│ "Week N"                    [Icon] "Status Text"        │
│ - font: headline                                        │
│ - weight: bold               - font: subheadline        │
│                             - weight: medium            │
│                             - icon: title3              │
└─────────────────────────────────────────────────────────┘
```

### Padding & Spacing
```
Vertical:   12pt top & bottom
Horizontal: 16pt left & right
Icon Gap:   6pt between icon and text
```

### Colors
```
Incomplete State:
  - Background: Color(.systemBackground)
  - Icon: .gray
  - Text: .primary (default)

Complete State:
  - Background: Color.green.opacity(0.1)
  - Icon: .green
  - Text: .primary (default)
```

## Accessibility

### Labels
- **Incomplete:** "Mark week as complete"
- **Complete:** "Unmark week as complete"

### Traits
- Button is accessible as a standard button element
- State changes are announced to screen readers
- Icon + text combination provides clear visual and semantic meaning

## Navigation Impact

### Opening BlockRunMode
```
Before (without manual completion):
  Opens to Week 1 if any sets incomplete in Week 1
  Opens to Week 2 if Week 1 all sets complete
  etc.

After (with manual completion):
  Opens to Week 1 if weekCompletedAt == nil
  Opens to Week 2 if Week 1 weekCompletedAt != nil
  etc.

Logic: findActiveWeekIndex() returns first week where !isCompleted
       isCompleted = weekCompletedAt != nil || allSetsComplete
```

### Week Navigation Indicator
```
Week 1 [✓] ← Currently viewing, marked complete
Week 2 [○] ← Incomplete, would be default on next open
Week 3 [○] ← Incomplete
Week 4 [○] ← Incomplete
```

## User Scenarios

### Scenario 1: Normal Progression
```
Week 1: Complete all sets → Auto-marked complete → [✓] Week Complete
Week 2: Complete all sets → Auto-marked complete → [✓] Week Complete
Week 3: Working on it... → Not complete → [○] Mark Week Complete
Week 4: Not started → Not complete → [○] Mark Week Complete

Opens to: Week 3 (first incomplete)
```

### Scenario 2: Skip Incomplete Week
```
Week 1: Complete 8/10 sets → Manually mark complete → [✓] Week Complete
Week 2: Not started → Not complete → [○] Mark Week Complete
Week 3: Not started → Not complete → [○] Mark Week Complete
Week 4: Not started → Not complete → [○] Mark Week Complete

Opens to: Week 2 (first incomplete)
Note: Week 1 still has 2 incomplete sets, but week is marked done
```

### Scenario 3: Return to Old Week
```
Week 1: [✓] Complete → User unmarks → [○] Mark Week Complete
Week 2: [○] Incomplete
Week 3: [○] Incomplete

Opens to: Week 1 (now first incomplete after unmarking)
```

## Code Snippet (for reference)

```swift
// WeekRunView - Week Completion Banner
private var weekCompletionBanner: some View {
    HStack {
        Text("Week \(week.index + 1)")
            .font(.headline)
            .fontWeight(.bold)
        
        Spacer()
        
        Button(action: {
            if week.weekCompletedAt != nil {
                week.weekCompletedAt = nil
            } else {
                week.weekCompletedAt = Date()
            }
            onSave()
        }) {
            HStack(spacing: 6) {
                Image(systemName: week.weekCompletedAt != nil 
                    ? "checkmark.circle.fill" 
                    : "circle")
                    .font(.title3)
                    .foregroundColor(week.weekCompletedAt != nil 
                        ? .green 
                        : .gray)
                
                Text(week.weekCompletedAt != nil 
                    ? "Week Complete" 
                    : "Mark Week Complete")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
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

## Design Rationale

### Why Banner at Top?
- Always visible when viewing week
- Clear separation from day-level content
- Doesn't interfere with exercise logging
- Easy to find and access

### Why Green Color?
- Universal color for completion/success
- Matches existing completion indicators (set checkmarks)
- Subtle opacity maintains clean aesthetic
- High contrast with incomplete state

### Why Toggle (not permanent)?
- Allows correction of mistakes
- User can return to incomplete week if needed
- Flexible workflow support
- Reversible action reduces anxiety

### Why Show Week Number?
- Clear context of which week user is viewing
- Helps with multi-week planning
- Matches mental model of "Week 1, Week 2, etc."
- Consistent with app's block periodization model

## Notes

- Manual completion does NOT complete individual sets
- Sets maintain their individual completion state
- Week can be marked complete even with 0 sets done
- Useful for skipping deload weeks, rest weeks, or moving on despite incomplete work
- Completion modals still trigger on week completion transitions

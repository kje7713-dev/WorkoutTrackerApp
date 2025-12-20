# Completion Timestamp UI Mockup

## Before Implementation

When a set is completed, only the "COMPLETED" ribbon and "Undo" button were shown:

```
┌─────────────────────────────────────────────┐
│ Set 1                                       │
│ Planned: Reps: 10 • Weight: 135            │
│                                             │
│ REPETITIONS                                 │
│ [-] 10 [+] reps                            │
│                                             │
│ WEIGHT                                      │
│ [-] 135 [+] lb                             │
│                                             │
│                                             │
│                              [Undo]         │
└─────────────────────────────────────────────┘
       ╲                           ╱
        ╲                         ╱
         ╲  COMPLETED RIBBON     ╱
          ╲                     ╱
           ┴───────────────────┴
```

## After Implementation

Now shows the completion date next to the "Undo" button:

```
┌─────────────────────────────────────────────┐
│ Set 1                                       │
│ Planned: Reps: 10 • Weight: 135            │
│                                             │
│ REPETITIONS                                 │
│ [-] 10 [+] reps                            │
│                                             │
│ WEIGHT                                      │
│ [-] 135 [+] lb                             │
│                                             │
│                                             │
│                     12/20/24  [Undo]        │
└─────────────────────────────────────────────┘
       ╲                           ╱
        ╲                         ╱
         ╲  COMPLETED RIBBON     ╱
          ╲                     ╱
           ┴───────────────────┴
```

## Code Location

The UI change is in `blockrunmode.swift`, `SetRunRow` struct, around line 1395-1428:

```swift
// Complete / Undo
HStack {
    Spacer()
    if runSet.isCompleted {
        // Show completion date if available
        if let completedDate = runSet.completedAt {
            Text(formatShortDate(completedDate))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        
        Button("Undo") {
            runSet.isCompleted = false
            runSet.completedAt = nil
            onSave()
        }
        .font(.caption)
    } else {
        Button("Complete") {
            runSet.isCompleted = true
            runSet.completedAt = Date()
            onSave()
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary, lineWidth: 1)
        )
    }
}
```

## Key UI Elements

1. **Completion Date** (`12/20/24`)
   - Font: `.caption2` (very small, secondary text)
   - Color: `.secondary` (gray/muted)
   - Position: Left of "Undo" button
   - Only visible when set is completed

2. **Undo Button**
   - Font: `.caption` (small)
   - Position: Right side of the HStack
   - Clears both `isCompleted` and `completedAt` when tapped

3. **Complete Button** (when not completed)
   - Font: `.subheadline`
   - Has rounded border stroke
   - Sets both `isCompleted = true` and `completedAt = Date()`

## Date Format Examples

The date format varies by device locale:

| Locale | Date Format | Example |
|--------|-------------|---------|
| US (en_US) | M/d/yy | 12/20/24 |
| UK (en_GB) | dd/MM/yyyy | 20/12/2024 |
| Canada (en_CA) | yyyy-MM-dd | 2024-12-20 |
| Japan (ja_JP) | yyyy/MM/dd | 2024/12/20 |

The formatter uses `DateFormatter` with `dateStyle: .short` which automatically adapts to the user's locale preferences.

## Visual Hierarchy

```
┌─ Set Container ────────────────────────────┐
│                                             │
│  Set Title                                  │
│  Planned Values                             │
│                                             │
│  [Controls for Reps/Weight]                │
│                                             │
│  [Notes field]                              │
│                                             │
│  ┌─ Completion Actions ─────────────────┐  │
│  │              date    [Undo] button   │  │
│  │  (subtle)    ^^^^    ^^^^^^          │  │
│  └──────────────────────────────────────┘  │
│                                             │
└─────────────────────────────────────────────┘
```

The completion date is styled to be subtle and informational, not drawing attention away from the primary "Undo" action.

## Responsive Behavior

- Date automatically hides when set is not completed
- Date appears immediately when "Complete" is tapped
- Date is cleared when "Undo" is tapped
- All changes persist to storage automatically via `onSave()` callback

# Auto-Save Implementation for Block Builder

## Overview

This document describes the auto-save functionality implemented for the BlockBuilderView to ensure workout block data is automatically persisted to disk as users edit fields.

## Problem Statement

Previously, workout block data was only saved when users explicitly tapped the "Save" button. If users tapped "Cancel" or dismissed the view, all changes were lost. This was problematic because:

1. Users could lose significant work if they accidentally dismissed the view
2. App crashes or force-quits would lose in-progress edits
3. The workflow didn't match user expectations for modern apps

## Solution

Implemented a comprehensive auto-save mechanism that persists changes automatically as users edit, while maintaining data integrity and performance.

## Key Features

### 1. Persistent Block ID Tracking
- Each editing session maintains a persistent `workingBlockId`
- New blocks: Generate a new UUID that persists across auto-saves
- Edit mode: Use the existing block's ID
- Clone mode: Generate a new UUID for the cloned block
- This ensures no duplicate blocks are created

### 2. Debounced Auto-Save
- Changes trigger auto-save after 1 second of inactivity
- Previous pending saves are cancelled when new changes occur
- Prevents excessive disk writes during rapid typing
- Balances responsiveness with performance

### 3. Smart Validation
- Manual save (via "Save" button): Requires non-empty block name
- Auto-save: Allows "Untitled Block" as default name
- Both validate that at least one day has exercises
- Empty exercises (blank names) are filtered out

### 4. Cleanup on Dismissal
- `.onDisappear` ensures pending saves complete before view closes
- Synchronous execution prevents data loss
- Works for both "Save" and "Cancel" buttons

### 5. Code Quality
- Extracted `buildBlockFromCurrentState()` helper method
- Eliminated ~240 lines of duplicated code
- Single source of truth for block creation logic
- Consistent validation across save paths

## Implementation Details

### State Variables

```swift
@State private var workingBlockId: BlockID          // Persistent block ID
@State private var autoSaveEnabled: Bool = false    // Controls when auto-save starts
@State private var autoSaveTimer: Timer?            // Debounce timer
```

### Auto-Save Flow

1. **User edits a field** → `.onChange` modifier fires
2. **`autoSave()` called** → Cancels previous timer, starts new 1-second timer
3. **Timer fires** → `performAutoSave()` executes
4. **`performAutoSave()`** → Calls `buildBlockFromCurrentState()`
5. **Block built** → Repository adds or updates block
6. **Sessions regenerated** → SessionFactory creates workout sessions

### Helper Method

```swift
private func buildBlockFromCurrentState(requireName: Bool = false) -> Block?
```

- `requireName: true` → Used by manual save, enforces name validation
- `requireName: false` → Used by auto-save, allows "Untitled Block"
- Returns `nil` if block doesn't meet minimum requirements
- Consolidates all block-building logic in one place

### Lifecycle Integration

```swift
.onAppear {
    // Enable auto-save after 0.5s to avoid saving empty initial state
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        autoSaveEnabled = true
    }
}

.onDisappear {
    // Complete any pending auto-save synchronously
    autoSaveTimer?.invalidate()
    if autoSaveEnabled {
        performAutoSave()
    }
}

.onChange(of: blockName) { _ in autoSave() }
.onChange(of: blockDescription) { _ in autoSave() }
// ... all editable fields
```

## Performance Considerations

### Debouncing
- 1-second delay prevents excessive saves during typing
- Timer cancellation prevents queued saves from piling up
- Users won't notice the 1-second delay in practice

### Thread Safety
- `Timer.scheduledTimer` already executes on main thread
- Repository updates modify `@Published` properties safely
- Disk writes are atomic with backup mechanism

### Memory
- Single timer instance (not one per field)
- Block built on-demand (not stored in additional state)
- Minimal memory overhead

## Testing Verification

### Manual Test Cases

1. **New Block Auto-Save**
   - Create new block → Enter name → Wait 1s → Force quit app → Relaunch
   - Expected: Block persists with entered name

2. **Edit Auto-Save**
   - Edit existing block → Change fields → Wait 1s → Tap Cancel
   - Expected: Changes persist (already auto-saved)

3. **Rapid Typing**
   - Type quickly in name field → Stop → Wait 1s
   - Expected: Only one save occurs after typing stops

4. **Empty Block Handling**
   - Open new block → Immediately force quit
   - Expected: No empty block saved

5. **Clone Auto-Save**
   - Clone block → Change name → Wait 1s → Force quit
   - Expected: New block saved with unique ID

### Debug Logging

```swift
#if DEBUG
print("🔄 Auto-saving block: \(blockName)")
print("✅ BlocksRepository: saved N blocks to [path]")
#endif
```

## Data Flow Diagram

```
User Edit → onChange → autoSave() → Timer (1s) → performAutoSave()
                                                        ↓
                                                buildBlockFromCurrentState()
                                                        ↓
                                                Repository.update/add()
                                                        ↓
                                                saveToDisk() → blocks.json
```

## Migration Notes

### Backward Compatibility
- Uses existing `BlocksRepository.saveToDisk()` mechanism
- No changes to data models or persistence format
- Existing blocks load and save as before

### Breaking Changes
- None - purely additive functionality

## Future Enhancements

### Potential Improvements
1. **Conflict Resolution**: Handle simultaneous edits from multiple devices
2. **Undo/Redo**: Track change history for reverting edits
3. **Visual Feedback**: Show "Saving..." indicator to user
4. **Offline Queue**: Queue saves when offline, sync when online
5. **Compression**: Compress blocks.json for faster saves

### Not Implemented (Intentionally)
- **Instant Save**: Would cause excessive disk I/O
- **Cloud Sync**: Out of scope for this feature
- **Draft/Publish**: Adds complexity without clear benefit

## Troubleshooting

### Issue: Changes Not Saving
**Symptoms**: User makes changes, but they don't persist
**Causes**:
1. Auto-save disabled (before 0.5s onAppear delay)
2. Block validation fails (no exercises with names)
3. Disk write permission issue

**Resolution**:
- Check debug logs for auto-save messages
- Verify exercises have non-empty names
- Check file permissions on documents directory

### Issue: Duplicate Blocks
**Symptoms**: Multiple blocks with same content but different IDs
**Causes**: Should not occur with current implementation

**Resolution**:
- `workingBlockId` ensures same ID used across saves
- Repository checks for existing block before adding

## References

- **BlockBuilderView.swift**: Main implementation
- **Repositories.swift**: Persistence layer
- **validate_autosave.md**: Manual testing procedures
- **SessionFactory.swift**: Session generation logic

## Conclusion

The auto-save implementation provides a robust, performant solution for automatically persisting workout block data. It maintains data integrity, prevents loss of user work, and improves the overall user experience without compromising app performance.

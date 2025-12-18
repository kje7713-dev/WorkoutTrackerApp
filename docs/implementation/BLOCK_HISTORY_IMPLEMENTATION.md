# Block History Feature Implementation

## Overview

This document describes the implementation of the block history feature, which allows users to archive completed or no-longer-active (NLA) blocks while maintaining their history for future review.

## Problem Statement

Users needed a way to move completed or NLA blocks out of the main blocks list without deleting their history. The active blocks list was getting cluttered with old blocks, making it harder to find current training programs.

## Solution

We implemented an archive/unarchive system that:
1. Allows users to archive blocks from the main blocks list
2. Provides a dedicated Block History view to review archived blocks
3. Maintains all block data and allows unarchiving if needed
4. Keeps the active blocks list focused on current/upcoming training

## Implementation Details

### 1. Model Changes (`Models.swift`)

Added `isArchived` boolean field to the `Block` struct:

```swift
public struct Block: Identifiable, Codable, Equatable {
    // ... existing fields
    public var isArchived: Bool
    
    public init(
        // ... existing parameters
        isArchived: Bool = false  // defaults to false for backward compatibility
    ) {
        // ... initialization
        self.isArchived = isArchived
    }
}
```

**Key Design Decisions:**
- Default value of `false` ensures backward compatibility with existing blocks
- Codable conformance ensures persistence works automatically
- Simple boolean flag is more maintainable than separate collections

### 2. Repository Changes (`Repositories.swift`)

Added archive management methods to `BlocksRepository`:

```swift
/// Archive a block
public func archive(_ block: Block) {
    guard let index = blocks.firstIndex(where: { $0.id == block.id }) else { return }
    var updatedBlock = blocks[index]
    updatedBlock.isArchived = true
    blocks[index] = updatedBlock
    saveToDisk()
}

/// Unarchive a block
public func unarchive(_ block: Block) {
    guard let index = blocks.firstIndex(where: { $0.id == block.id }) else { return }
    var updatedBlock = blocks[index]
    updatedBlock.isArchived = false
    blocks[index] = updatedBlock
    saveToDisk()
}

/// Get active (non-archived) blocks
public func activeBlocks() -> [Block] {
    blocks.filter { !$0.isArchived }
}

/// Get archived blocks
public func archivedBlocks() -> [Block] {
    blocks.filter { $0.isArchived }
}
```

**Key Design Decisions:**
- Archive/unarchive methods update the flag and persist immediately
- Filter methods provide convenient access to subsets
- All blocks remain in the same collection for simpler persistence

### 3. New View: BlockHistoryListView (`BlockHistoryListView.swift`)

Created a dedicated view for archived blocks, replicating the structure of `BlocksListView` with the following changes:

**Key Differences from BlocksListView:**
- Shows `archivedBlocks()` instead of `activeBlocks()`
- "RUN" button replaced with "REVIEW" button (same functionality)
- Has "UNARCHIVE" button to restore blocks to active list
- Header text updated to "Block History" / "Review your archived blocks"
- Empty state explains archived blocks

**Shared Behavior:**
- EDIT button to modify the block
- NEXT BLOCK button to clone and create a new block
- DELETE button for permanent removal
- Navigation to BlockRunModeView for reviewing sessions

### 4. Updated BlocksListView (`BlocksListView.swift`)

Modified to show only active blocks:

```swift
// Changed from:
if blocksRepository.blocks.isEmpty { ... }
ForEach(blocksRepository.blocks) { block in ... }

// To:
if blocksRepository.activeBlocks().isEmpty { ... }
ForEach(blocksRepository.activeBlocks()) { block in ... }
```

Added ARCHIVE button:
```swift
Button {
    blocksRepository.archive(block)
} label: {
    Text("ARCHIVE")
        .font(.footnote)
}
```

### 5. Updated HomeView (`HomeView.swift`)

Added navigation link to Block History:

```swift
// Block History -> BlockHistoryListView
NavigationLink {
    BlockHistoryListView()
} label: {
    Text("BLOCK HISTORY")
        .font(.system(size: 16, weight: .semibold))
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .foregroundColor(foregroundButtonColor)
        .background(backgroundButtonColor)
        .cornerRadius(20)
        .textCase(.uppercase)
}
.buttonStyle(PlainButtonStyle())
```

Replaced the placeholder "History (Future)" button with actual functionality.

## Testing

Created comprehensive unit tests in `Tests/BlockHistoryTests.swift`:

### Test Coverage:
1. **Archive Operations**
   - `testArchiveBlock()` - Verifies archiving sets isArchived flag
   - `testUnarchiveBlock()` - Verifies unarchiving clears isArchived flag

2. **Filter Operations**
   - `testActiveBlocksFilter()` - Verifies active blocks excludes archived
   - `testArchivedBlocksFilter()` - Verifies archived blocks filter works
   - `testEmptyActiveBlocks()` - Edge case with no active blocks
   - `testEmptyArchivedBlocks()` - Edge case with no archived blocks

3. **Integration Tests**
   - `testArchiveUnarchiveCycle()` - Full workflow test

All tests verify:
- Correct filtering behavior
- State transitions
- Count accuracy
- Data integrity

## User Flow

### Archiving a Block:
1. User navigates to "BLOCKS" from home screen
2. User finds a completed/NLA block
3. User taps "ARCHIVE" button
4. Block is immediately removed from the active list
5. Block appears in Block History

### Reviewing Archived Blocks:
1. User navigates to "BLOCK HISTORY" from home screen
2. User sees list of archived blocks
3. User can tap "REVIEW" to view sessions (same as RUN)
4. User can "EDIT", "NEXT BLOCK", or "DELETE" as needed

### Unarchiving a Block:
1. User navigates to "BLOCK HISTORY"
2. User finds the block to restore
3. User taps "UNARCHIVE" button
4. Block returns to the active blocks list

## Data Persistence

The archive state is automatically persisted because:
1. `Block.isArchived` is `Codable`
2. `BlocksRepository.archive()` and `unarchive()` call `saveToDisk()`
3. Existing JSON persistence handles the new field seamlessly

**Backward Compatibility:**
- Existing blocks without `isArchived` field will default to `false`
- No data migration required
- JSON decoder handles missing fields gracefully

## UI/UX Considerations

### Visual Consistency
- Block History view matches the style and layout of Blocks view
- Same card design, button styles, and spacing
- Consistent navigation patterns

### User Clarity
- "REVIEW" instead of "RUN" indicates read-only intent (though functionality is identical)
- Clear empty states explain where archived blocks come from
- "UNARCHIVE" button is obvious and accessible

### Performance
- Filtering is O(n) but acceptable for expected block counts (<100 typically)
- Could optimize with separate collections if needed in future
- Persistence is already optimized with backup mechanism

## Future Enhancements

Possible improvements for future iterations:

1. **Bulk Operations**
   - Archive multiple blocks at once
   - Bulk unarchive

2. **Archive Reasons**
   - Tag blocks with completion status (completed, abandoned, modified)
   - Add completion date metadata

3. **Search/Filter**
   - Search archived blocks by name
   - Filter by goal, source, or date

4. **Statistics**
   - Show completion statistics in Block History
   - Track total weeks trained, exercises performed, etc.

5. **Auto-Archive**
   - Optional auto-archive after X weeks of inactivity
   - Auto-archive when all sessions are completed

## Related Files

- `Models.swift` - Block model with isArchived field
- `Repositories.swift` - BlocksRepository with archive methods
- `BlockHistoryListView.swift` - New history view
- `BlocksListView.swift` - Updated to filter active blocks
- `HomeView.swift` - Added history navigation
- `Tests/BlockHistoryTests.swift` - Comprehensive test suite

## Summary

This implementation provides a clean, minimal solution to the problem of managing completed blocks. The archive system:
- ✅ Keeps active blocks list focused
- ✅ Preserves block history
- ✅ Allows easy restoration
- ✅ Integrates seamlessly with existing persistence
- ✅ Maintains consistent UI/UX
- ✅ Requires no data migration
- ✅ Is thoroughly tested

The feature is production-ready and can be extended with additional functionality as user needs evolve.

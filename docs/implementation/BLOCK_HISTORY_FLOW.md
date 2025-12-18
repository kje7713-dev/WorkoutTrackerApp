# Block History Feature - Visual Flow Diagram

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         Home View                            │
│  ┌────────────┐  ┌───────────────┐  ┌──────────────────┐  │
│  │   BLOCKS   │  │  TODAY (TBD)  │  │  BLOCK HISTORY   │  │
│  └────────────┘  └───────────────┘  └──────────────────┘  │
└──────┬──────────────────────────────────────┬──────────────┘
       │                                       │
       v                                       v
┌─────────────────────┐              ┌─────────────────────┐
│  BlocksListView     │              │ BlockHistoryListView │
│  (Active Blocks)    │              │  (Archived Blocks)  │
└─────────────────────┘              └─────────────────────┘
       │                                       │
       │     Archive →                ← Unarchive
       └───────────────────┬───────────────────┘
                          │
                          v
              ┌────────────────────┐
              │ BlocksRepository   │
              │   blocks: [Block]  │
              └────────────────────┘
                          │
                          v
              ┌────────────────────┐
              │  JSON Persistence  │
              │   blocks.json      │
              └────────────────────┘
```

## Data Flow

### Archive Operation
```
User Action: Tap "ARCHIVE" in BlocksListView
              │
              v
┌──────────────────────────────────────┐
│ BlocksRepository.archive(block)      │
│  1. Find block by ID                 │
│  2. Set isArchived = true            │
│  3. Save to disk                     │
└──────────────────────────────────────┘
              │
              v
┌──────────────────────────────────────┐
│ SwiftUI Reactive Update              │
│  @Published blocks changes           │
│  → View automatically refreshes      │
└──────────────────────────────────────┘
              │
              v
┌──────────────────────────────────────┐
│ BlocksListView re-renders            │
│  activeBlocks() excludes archived    │
│  Block disappears from list          │
└──────────────────────────────────────┘
```

### Unarchive Operation
```
User Action: Tap "UNARCHIVE" in BlockHistoryListView
              │
              v
┌──────────────────────────────────────┐
│ BlocksRepository.unarchive(block)    │
│  1. Find block by ID                 │
│  2. Set isArchived = false           │
│  3. Save to disk                     │
└──────────────────────────────────────┘
              │
              v
┌──────────────────────────────────────┐
│ SwiftUI Reactive Update              │
│  @Published blocks changes           │
│  → View automatically refreshes      │
└──────────────────────────────────────┘
              │
              v
┌──────────────────────────────────────┐
│ BlockHistoryListView re-renders      │
│  archivedBlocks() excludes unarchived│
│  Block disappears from history       │
└──────────────────────────────────────┘
```

## Filter Logic Flow

```
BlocksRepository.blocks (All blocks)
         │
         ├─────────────────┬─────────────────┐
         │                 │                 │
         v                 v                 v
   All blocks        Active blocks      Archived blocks
   (no filter)       (isArchived ==     (isArchived ==
                        false)               true)
         │                 │                 │
         │                 │                 │
         v                 v                 v
    Builder          BlocksListView    BlockHistoryListView
```

## User Journey Maps

### Journey 1: Completing a Training Block
```
Week 1-4: Training
    ↓
Week 4 Complete
    ↓
Open App → BLOCKS
    ↓
Find completed block
    ↓
Tap "ARCHIVE"
    ↓
Block moves to history
    ↓
Active list now shows only current training
    ↓
Continue with next block
```

### Journey 2: Creating Next Block from Previous
```
Open App → BLOCK HISTORY
    ↓
Find previous block
    ↓
Tap "NEXT BLOCK"
    ↓
BlockBuilderView opens (clone mode)
    ↓
Modify exercises/progression
    ↓
Save new block
    ↓
New block appears in BLOCKS (active)
    ↓
Original stays in history
```

### Journey 3: Reviewing Past Training
```
Open App → BLOCK HISTORY
    ↓
Browse archived blocks
    ↓
Tap "REVIEW" on block
    ↓
BlockRunModeView opens
    ↓
Navigate weeks/days/sessions
    ↓
View completed sets, weights, etc.
    ↓
Back to history
```

## State Diagram

```
┌─────────────┐
│   Created   │ (New block)
└──────┬──────┘
       │
       v
┌─────────────┐
│   Active    │ (isArchived = false)
│ (Training)  │
└──────┬──────┘
       │
       │ Archive
       v
┌─────────────┐
│  Archived   │ (isArchived = true)
│  (History)  │
└──────┬──────┘
       │
       │ Unarchive
       v
┌─────────────┐
│   Active    │ (isArchived = false)
│ (Training)  │
└──────┬──────┘
       │
       │ Delete
       v
┌─────────────┐
│   Deleted   │ (Permanent)
└─────────────┘
```

## Component Interaction Diagram

```
HomeView
  ├─> BlocksListView
  │     ├─> @EnvironmentObject BlocksRepository
  │     ├─> @EnvironmentObject SessionsRepository
  │     ├─> @EnvironmentObject ExerciseLibraryRepository
  │     │
  │     ├─> activeBlocks() → ForEach → Block Cards
  │     │                                   ├─> RUN → BlockRunModeView
  │     │                                   ├─> EDIT → BlockBuilderView
  │     │                                   ├─> NEXT BLOCK → BlockBuilderView
  │     │                                   ├─> ARCHIVE → archive(block)
  │     │                                   └─> DELETE → delete(block)
  │     │
  │     └─> NEW BLOCK → BlockBuilderView
  │
  └─> BlockHistoryListView
        ├─> @EnvironmentObject BlocksRepository
        ├─> @EnvironmentObject SessionsRepository
        ├─> @EnvironmentObject ExerciseLibraryRepository
        │
        └─> archivedBlocks() → ForEach → Block Cards
                                             ├─> REVIEW → BlockRunModeView
                                             ├─> EDIT → BlockBuilderView
                                             ├─> NEXT BLOCK → BlockBuilderView
                                             ├─> UNARCHIVE → unarchive(block)
                                             └─> DELETE → delete(block)
```

## Persistence Flow

```
┌─────────────────────────────────────────────────────────────┐
│  In-Memory State                                            │
│  BlocksRepository.blocks: [Block]                           │
│    ├─> Block 1 (isArchived: false)                         │
│    ├─> Block 2 (isArchived: true)                          │
│    └─> Block 3 (isArchived: false)                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ archive() / unarchive() / add() / etc.
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│  saveToDisk()                                               │
│    1. Create backup of existing file                        │
│    2. Encode blocks to JSON                                 │
│    3. Validate JSON can be decoded                          │
│    4. Write atomically to blocks.json                       │
│    5. Clean up backup on success                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│  Disk Storage                                               │
│  ~/Documents/blocks.json                                    │
│  [                                                          │
│    {                                                        │
│      "id": "...",                                           │
│      "name": "Block 1",                                     │
│      "isArchived": false,                                   │
│      ...                                                    │
│    },                                                       │
│    {                                                        │
│      "id": "...",                                           │
│      "name": "Block 2",                                     │
│      "isArchived": true,                                    │
│      ...                                                    │
│    }                                                        │
│  ]                                                          │
└─────────────────────────────────────────────────────────────┘
```

## Error Handling Flow

```
┌─────────────────────────────────────────────────────────────┐
│  User Action (Archive/Unarchive)                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     v
┌─────────────────────────────────────────────────────────────┐
│  Repository Method                                          │
│  guard let index = blocks.firstIndex(...)                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                ┌────┴────┐
                │         │
           Found│         │Not Found
                │         │
                v         v
        ┌────────────┐  ┌────────────┐
        │ Update     │  │ Early      │
        │ Block      │  │ Return     │
        └─────┬──────┘  └────────────┘
              │
              v
        ┌────────────┐
        │ saveToDisk │
        └─────┬──────┘
              │
         ┌────┴────┐
         │         │
    Success│       │Failure
         │         │
         v         v
   ┌─────────┐  ┌──────────┐
   │ Update  │  │ Restore  │
   │ Saved   │  │ Backup   │
   └─────────┘  └──────────┘
```

## Testing Flow

```
Test Setup
  ↓
Create test blocks
  ↓
Initialize repository
  ↓
Execute operation
  ↓
Verify state changes
  ↓
Verify filtering works
  ↓
Test complete

Test Cases:
├─> testArchiveBlock()
├─> testUnarchiveBlock()
├─> testActiveBlocksFilter()
├─> testArchivedBlocksFilter()
├─> testEmptyActiveBlocks()
├─> testEmptyArchivedBlocks()
└─> testArchiveUnarchiveCycle()
```

## Summary

This visual flow documentation illustrates:

1. **Architecture**: How components interact
2. **Data Flow**: How archive/unarchive operations work
3. **User Journeys**: Common usage patterns
4. **State Management**: Block lifecycle states
5. **Persistence**: How data is saved and loaded
6. **Error Handling**: Graceful failure handling
7. **Testing**: Coverage and validation

All flows demonstrate the minimal, efficient approach taken in this implementation.

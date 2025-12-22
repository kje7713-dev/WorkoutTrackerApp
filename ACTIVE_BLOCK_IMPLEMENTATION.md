# Active Block Selection & Summary Metrics Implementation

## Overview
This implementation adds the ability to mark a block as "active" and displays summary metrics showing planned vs completed volume for each block.

## Changes Made

### 1. Model Updates (Models.swift)
- Added `isActive: Bool` field to `Block` struct
- Updated Block initializer to include `isActive` parameter (default: false)
- Ensures only one block can be marked as active at a time

### 2. Repository Methods (Repositories.swift)
Added the following methods to `BlocksRepository`:
- `setActive(_ block: Block)` - Sets a block as active and deactivates all others
- `activeBlock() -> Block?` - Returns the currently active block
- `clearActiveBlock()` - Deactivates all blocks

### 3. Metrics Calculation (BlockMetrics.swift)
New file that provides:
- `BlockMetrics` struct with the following properties:
  - `plannedSets: Int` - Total number of sets planned
  - `completedSets: Int` - Total number of sets completed
  - `plannedVolume: Double` - Total weight × reps for strength exercises
  - `completedVolume: Double` - Actual weight × reps completed
  - `totalWorkouts: Int` - Total number of workout sessions
  - `completedWorkouts: Int` - Number of completed workout sessions
  - Computed properties for completion percentages

- `calculate(for:sessions:)` method that:
  - Takes a block and its sessions
  - Calculates all metrics
  - Returns a BlockMetrics struct

### 4. Summary Card UI (BlockSummaryCard.swift)
New SwiftUI component that displays:
- Progress bar showing overall completion percentage
- Color-coded progress indicator (gray/yellow/orange/green based on completion)
- Three metric items:
  - Sets completed vs planned
  - Workouts completed vs planned
  - Volume completed (formatted for readability)

### 5. Updated Blocks List (BlocksListView.swift)
Enhanced the block cards to show:
- Active block indicator (yellow star badge with "ACTIVE BLOCK" text)
- Star button to toggle active status
- Yellow border around active blocks
- Summary metrics card for each block
- All existing functionality preserved

### 6. Tests (Tests/ActiveBlockTests.swift)
Added comprehensive tests:
- Test setting a block as active
- Test that only one block can be active at a time
- Test clearing the active block
- Test metrics calculation with various scenarios

## Usage

### Setting a Block as Active
Users can tap the star icon on any block card to mark it as active. Only one block can be active at a time. Tapping the star on an already-active block will deactivate it.

### Viewing Summary Metrics
Each block card now displays a summary showing:
- Overall progress percentage and color-coded progress bar
- Sets completed out of total sets planned
- Workouts completed out of total workouts
- Volume completed (for strength training)

### Visual Indicators
- Active blocks have a yellow star badge and yellow border
- Progress bars are color-coded:
  - Gray: 0% completion
  - Yellow: 1-49% completion
  - Orange: 50-74% completion
  - Green: 75%+ completion

## Technical Notes

### Data Persistence
- The `isActive` field is automatically persisted with the Block model
- BlocksRepository handles ensuring only one block is active
- No migration needed - new field defaults to false for existing blocks

### Performance
- Metrics calculation is performed on-demand in the view
- For typical usage (<100 blocks), performance impact is negligible
- Consider caching metrics if performance becomes an issue with large datasets

### Backwards Compatibility
- Existing blocks will have `isActive = false` by default
- No breaking changes to existing APIs
- All existing functionality is preserved

## Future Enhancements
Potential improvements that could be added:
- Cache computed metrics to avoid recalculation
- Add trends and charts for volume over time
- Show active block prominently on home screen
- Add filtering by active block in workout history
- Notifications based on active block progress

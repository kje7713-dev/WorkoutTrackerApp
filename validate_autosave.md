# Auto-Save Validation Test Plan

## Manual Testing Steps

### Test 1: New Block Auto-Save
1. Launch the app
2. Tap "BLOCKS" button on home screen
3. Tap "NEW BLOCK" button
4. Enter a block name (e.g., "Test Block")
5. Wait 1 second (auto-save should trigger)
6. Force quit the app (swipe up from app switcher)
7. Relaunch the app
8. Tap "BLOCKS" button
9. **Expected**: "Test Block" should appear in the blocks list

### Test 2: Field Change Auto-Save
1. Launch the app and navigate to Blocks
2. Tap "EDIT" on an existing block
3. Change the block name
4. Change the number of weeks
5. Add a new exercise
6. Wait 1 second after each change
7. Tap "Cancel" (do NOT tap Save)
8. **Expected**: The changes should still be visible when you edit the block again

### Test 3: Edit Existing Block
1. Launch the app and navigate to Blocks
2. Tap "EDIT" on an existing block
3. Modify the description field
4. Add a new day
5. Wait 1 second
6. Force quit the app
7. Relaunch and navigate to Blocks
8. **Expected**: All changes should be persisted

### Test 4: Clone Block Auto-Save
1. Launch the app and navigate to Blocks
2. Tap "NEXT BLOCK" on an existing block
3. Change the block name to something unique
4. Wait 1 second
5. Force quit the app
6. Relaunch and navigate to Blocks
7. **Expected**: The new cloned block with the unique name should exist

## Implementation Details

### Auto-Save Mechanism
- **Trigger**: Any change to blockName, blockDescription, numberOfWeeks, progressionType, deltaWeightText, deltaSetsText, or days
- **Delay**: 0.5 seconds after view appears (to avoid saving empty initial state)
- **Persistence**: Blocks saved to `blocks.json` in Documents directory
- **Block ID**: Persistent across saves (uses `workingBlockId`)

### Key Changes
1. Added `workingBlockId` state variable to track the block being edited
2. Implemented `autoSave()` method that builds and saves block
3. Added `.onChange()` modifiers for all editable fields
4. Updated `saveBlock()` to avoid creating duplicate blocks
5. Added `autoSaveEnabled` flag with 0.5s delay

### Debug Logging
Look for these log messages in Xcode console:
- `🔄 Auto-saving block: [blockName]` - Auto-save triggered
- `✅ BlocksRepository: saved N blocks to [path]` - Successful save to disk
- `🔵 Save button persisted block id: [id] with N sessions` - Final save completed

# Data Management Feature Documentation

## Overview

This document describes the data management features implemented to address issue #90, including data export/import capabilities and automatic data retention policies.

## Features

### 1. Data Export

The app provides multiple export formats to back up and analyze your workout data:

#### JSON Export (Complete Backup)
- **What it includes:** All blocks, workout sessions, and exercise definitions
- **Use case:** Complete backup for transferring to another device or archiving
- **Format:** Structured JSON with ISO8601 dates
- **Access:** Data Management → Export as JSON

#### CSV Export: Workout History
- **What it includes:** Date, block name, week, day, exercise name, sets completed, total reps, total weight
- **Use case:** Analysis in spreadsheet applications (Excel, Google Sheets)
- **Format:** Standard CSV with headers
- **Access:** Data Management → Export Workout History (CSV)

#### CSV Export: Blocks Summary
- **What it includes:** Block name, weeks, days, exercise count, goal, source, archived status
- **Use case:** Quick overview of all training blocks
- **Format:** Standard CSV with headers
- **Access:** Data Management → Export Blocks Summary (CSV)

### 2. Data Import

Restore data from previous exports or transfer from another device:

#### Import Strategies

**Merge Mode (Recommended)**
- Adds imported data to existing data
- Skips items with duplicate IDs (preserves your current data)
- Safe for combining data from multiple sources
- **Use when:** Adding workouts from another device while keeping current data

**Replace Mode (Caution)**
- Removes all existing data
- Replaces with imported data only
- Cannot be undone
- **Use when:** Starting fresh with a complete backup

#### Supported Format
- JSON exports created by this app
- Must include version information and proper structure

### 3. Data Retention & Cleanup

Automatic background cleanup runs weekly to maintain app performance:

#### Default Retention Policy
- **Sessions:** Keep sessions from the last 365 days
- **Completed sessions:** Older completed sessions are removed
- **In-progress sessions:** Always kept regardless of age
- **Archived blocks:** Maximum of 50 archived blocks
- **Block cleanup:** Oldest archived blocks are removed first
- **Associated data:** When a block is deleted, its sessions are also removed

#### Manual Cleanup
You can manually trigger cleanup with custom policies:
1. Navigate to Data Management
2. Adjust retention settings:
   - Session retention: 90 days, 180 days, 1 year, or 2 years
   - Max archived blocks: 20, 50, 100, or unlimited
3. Tap "Clean Up Old Data"
4. Confirm the action

**Warning:** Manual cleanup cannot be undone. Export your data first if unsure.

### 4. Storage Statistics

View your app's data usage in real-time:

- **Active Blocks:** Count of non-archived training blocks
- **Archived Blocks:** Count of archived blocks
- **Total Sessions:** All workout sessions (completed, in-progress, not started)
- **Completed Sessions:** Successfully completed workouts
- **Exercises in Library:** Custom and default exercises
- **Estimated Size:** Approximate storage used by your data (in MB)

## Technical Details

### Data Structure

#### JSON Export Format
```json
{
  "version": "1.0",
  "exportDate": "2025-12-19T18:30:00Z",
  "blocks": [...],
  "sessions": [...],
  "exercises": [...]
}
```

#### CSV Export Formats

**Workout History:**
```
Date,Block,Week,Day,Exercise,Sets Completed,Total Reps,Total Weight
2025-12-19T10:00:00Z,Strength Block,1,Day 1,Squat,5,25,500
```

**Blocks Summary:**
```
Block Name,Weeks,Days,Total Exercises,Goal,Source,Archived
"Strength Block",4,3,12,strength,user,No
```

### Background Processing

- Cleanup runs on app launch
- Checks if 7 days have passed since last cleanup
- Runs asynchronously on background thread
- Does not block app startup
- Uses UserDefaults to track last cleanup date

### Data Persistence

All data is stored as JSON in the app's Documents directory:
- `blocks.json` - Training blocks
- `sessions.json` - Workout sessions
- `blocks.backup.json` - Automatic backup before save
- `sessions.backup.json` - Automatic backup before save

### Error Handling

- Failed saves attempt to restore from backup
- Import validates JSON structure before applying
- Export errors are reported to user with details
- All operations are logged for debugging

## Performance Considerations

### Pagination
- Block History view loads 20 items initially
- "Load More" button loads additional pages
- Reduces memory usage with large datasets
- Smooth scrolling performance maintained

### Retention Benefits
- Smaller data files load faster
- Less memory consumption
- Improved JSON encoding/decoding performance
- Faster backup/restore operations

## Privacy & Security

- All data stays on device by default
- Exports are shared via iOS system share sheet
- User controls where exported files are saved
- No data sent to external servers
- No analytics or tracking of workout data

## Best Practices

### Regular Backups
- Export JSON backup monthly
- Store backups in cloud storage (iCloud, Dropbox, etc.)
- Test restores periodically

### Data Hygiene
- Review archived blocks quarterly
- Delete blocks you no longer need
- Let automatic cleanup maintain session history

### Storage Management
- Monitor statistics if app feels slow
- Reduce retention period if storage is limited
- Clean up old data before iOS device backup

### Import/Export Tips
- Always use "Merge" mode unless intentionally replacing all data
- Export before making bulk changes
- Test imports on a secondary device first if possible

## Troubleshooting

### Export Issues
**Problem:** Export fails with error
- **Solution:** Check available storage space
- **Solution:** Try exporting smaller dataset (archive old blocks first)

**Problem:** Exported file not appearing
- **Solution:** Check share sheet - file may be saved to unexpected location
- **Solution:** Try different export format (JSON vs CSV)

### Import Issues
**Problem:** Import fails with "Invalid data" error
- **Solution:** Verify file is a valid JSON export from this app
- **Solution:** Check file wasn't corrupted during transfer

**Problem:** Duplicate data after import
- **Solution:** Use "Replace" mode to start fresh
- **Solution:** Manually delete unwanted duplicates

### Performance Issues
**Problem:** App feels slow with lots of data
- **Solution:** Run manual cleanup with aggressive retention policy
- **Solution:** Archive completed blocks
- **Solution:** Export and start fresh with current block only

### Missing Data
**Problem:** Sessions or blocks disappeared
- **Solution:** Check if automatic cleanup removed old data
- **Solution:** Restore from most recent backup
- **Solution:** Adjust retention policy to keep data longer

## Future Enhancements

Potential improvements for future versions:
- Automatic cloud backup integration
- Selective export/import (specific blocks or date ranges)
- More granular retention policies per block
- Incremental backups (only changes since last export)
- Export to additional formats (PDF reports, charts)
- Import from other workout tracking apps

## Related Files

- `DataManagementService.swift` - Core export/import/retention logic
- `DataManagementView.swift` - User interface for data management
- `BlockHistoryListView.swift` - Paginated view of archived blocks
- `SavageByDesignApp.swift` - Background cleanup initialization
- `Tests/DataManagementTests.swift` - Unit tests

## Version History

**v1.0** (2025-12-19)
- Initial implementation
- JSON and CSV export
- Import with merge/replace strategies
- Automatic retention policies
- Pagination support
- Comprehensive unit tests

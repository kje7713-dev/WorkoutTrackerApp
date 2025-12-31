# Segment Summary Detail Implementation

## Overview

This document describes the implementation of summary-level details in `SegmentRunCard` within `BlockRunModeView`. The enhancement addresses the issue that segments previously lacked sufficient detail for effective training tracking.

## Problem Statement

Previously, `SegmentRunCard` in `BlockRunModeView` displayed only minimal information:
- Segment name and type
- Duration
- Objective (if present)
- Basic round tracking
- Quality tracking counters
- Drill item checklist
- Notes

This lacked the contextual information athletes need during training sessions to properly execute techniques and understand training goals.

## Solution

### 1. Extended RunSegmentState Model

Added the following fields to `RunSegmentState` (all with default empty/nil values for backward compatibility):

```swift
// Summary details for tracking
let techniqueNames: [String]      // Names of techniques covered
let coachingCues: [String]        // Key coaching cues
let constraints: [String]         // Training constraints
let attackerGoal: String?         // Partner drill attacker goal
let defenderGoal: String?         // Partner drill defender goal
let resistance: Int?              // Resistance level (0-100)
let targetSuccessRate: Double?    // Target success rate (0-1)
let targetCleanReps: Int?         // Target clean reps
let safetyNotes: [String]         // Safety contraindications
```

### 2. Updated Mapping Logic

Modified two locations where `Segment` → `RunSegmentState` mapping occurs:

#### blockrunmode.swift (Line 591-606)
During initial session creation from block templates:
- Extracts technique names from `segment.techniques`
- Pulls safety contraindications from `segment.safety`
- Retrieves partner roles from `segment.partnerPlan?.roles` or `segment.roles`
- Copies resistance levels
- Extracts quality targets from nested structures
- Preserves coaching cues and constraints

#### RunStateMapper.swift (Line 92-109)
During session reload from repository:
- Similar extraction logic as above
- Ensures data consistency when sessions are reloaded
- Maintains reference to original segment template for full detail access

### 3. Enhanced SegmentRunCard UI

Added new visual sections to `SegmentRunCard`:

#### Techniques Section
```swift
if !segment.techniqueNames.isEmpty {
    // Displays technique names with target icon
    // Clean, scannable list for quick reference
}
```

#### Coaching Cues Section
```swift
if !segment.coachingCues.isEmpty {
    // Bullet list of key coaching points
    // Helps athletes maintain form and technique
}
```

#### Partner Roles Section
```swift
if segment.attackerGoal != nil || segment.defenderGoal != nil {
    // Shows attacker (⚔️) and defender (🛡️) goals
    // Includes visual resistance level indicator (5-bar)
    // Highlighted in light blue background
}
```

#### Constraints Section
```swift
if !segment.constraints.isEmpty {
    // Warning icon (⚠️) with constraint text
    // Ensures athletes follow training rules
}
```

#### Quality Targets Section
```swift
if segment.targetSuccessRate != nil || segment.targetCleanReps != nil {
    // Shows target success rate percentage
    // Shows target clean reps count
    // Green icons indicate quality goals
}
```

#### Safety Notes Section
```swift
if !segment.safetyNotes.isEmpty {
    // Alert icon (🚨) with safety information
    // Red text and light red background for visibility
    // Emphasizes contraindications and safety rules
}
```

#### Whiteboard Hint
```swift
// Bottom of card shows:
// "Tap 'Whiteboard' for full details"
// Directs users to comprehensive view when needed
```

## Design Decisions

### Summary-Level vs. Full Detail

The implementation follows a "summary for tracking, whiteboard for learning" philosophy:

**Summary in BlockRunMode:**
- Technique *names* only (not key details, common errors, counters)
- Partner *goals* only (not full starting state, win conditions)
- Safety *contraindications* only (not full safety structure)
- Coaching *cues* only (not media, diagrams, checkpoints)

**Full Detail in Whiteboard:**
- Complete technique breakdowns with variants and follow-ups
- Detailed round plans with intensity cues and reset rules
- Full media references (videos, diagrams)
- Starting states with grips and roles
- Comprehensive constraints and scoring systems

### Visual Design

1. **Color Coding:**
   - Blue for partner roles (cooperation)
   - Orange for resistance levels (challenge)
   - Red for safety (critical attention)
   - Green for quality targets (goals)

2. **Icons:**
   - Consistent icon usage for quick visual scanning
   - Emoji for personality (⚔️, 🛡️, ⚠️, 🚨)
   - SF Symbols for system consistency

3. **Layout:**
   - Maintains vertical scrollable layout
   - Grouped related information in visual boxes
   - Appropriate padding and spacing for mobile touch targets
   - Sections only appear when data is present (progressive disclosure)

### Backward Compatibility

All new fields in `RunSegmentState`:
- Have default values (empty arrays, nil optionals)
- Are populated during mapping only if source data exists
- Don't break existing code that creates `RunSegmentState` instances
- Don't affect serialization (Codable protocol handles new fields automatically)

## Data Flow

```
Block Template (Segment)
    ↓
SessionFactory creates WorkoutSession (SessionSegment)
    ↓
Stored in SessionsRepository
    ↓
Loaded by BlockRunModeView
    ↓
Mapped to RunSegmentState (via buildWeeks or RunStateMapper)
    ↓
Displayed in SegmentRunCard
```

## Testing Recommendations

### Manual Testing Checklist

1. **Load BJJ Class Example**
   - [ ] Open block with segments (Tests/bjj_class_segments_example.json)
   - [ ] Verify all new sections appear with correct data
   - [ ] Check visual appearance on iPhone-sized screens
   - [ ] Test scrolling through long segment cards

2. **Partner Roles Display**
   - [ ] Verify attacker goal shows with ⚔️ icon
   - [ ] Verify defender goal shows with 🛡️ icon
   - [ ] Check resistance bar displays correct level (0-100 scale)
   - [ ] Confirm light blue background appears

3. **Safety Notes**
   - [ ] Verify safety notes show with 🚨 icon
   - [ ] Confirm red text and light red background
   - [ ] Check that section only appears when safety notes exist

4. **Quality Targets**
   - [ ] Verify target success rate displays as percentage
   - [ ] Verify target clean reps displays as integer
   - [ ] Check green icons appear

5. **Whiteboard Integration**
   - [ ] Tap "Whiteboard" button from BlockRunMode
   - [ ] Verify full segment details appear in whiteboard view
   - [ ] Confirm hint at bottom of card is visible

6. **Empty Fields Handling**
   - [ ] Create segment with minimal fields
   - [ ] Verify only populated sections appear
   - [ ] Confirm no layout issues with missing sections

### Automated Testing

Existing tests should continue to pass:
- `SegmentTests.swift` - Tests segment model structures
- `SegmentFieldCoverageTests.swift` - Tests field coverage in segments
- `SegmentEndToEndTests.swift` - Tests JSON → UnifiedBlock → Whiteboard flow

No test updates needed because:
- Tests don't directly instantiate `RunSegmentState`
- Mapping logic preserves existing behavior
- New fields are optional with defaults

## Benefits

1. **Better Training Experience**
   - Athletes see key information during active training
   - No need to constantly switch to whiteboard for basic info
   - Quick reference for techniques, cues, and safety

2. **Maintains Simplicity**
   - Summary-level detail doesn't overwhelm the UI
   - Progressive disclosure (only show what's present)
   - Clear visual hierarchy

3. **Encourages Whiteboard Use**
   - Hint at bottom directs to full details
   - Summary whets appetite for deeper learning
   - Maintains separation between tracking and education

4. **Backward Compatible**
   - Existing blocks without segments continue to work
   - Segments without new fields display gracefully
   - No breaking changes to data structures

## Future Enhancements

Potential improvements for future iterations:

1. **Expandable Sections**
   - Allow collapse/expand of technique details
   - Show/hide individual sections based on preference

2. **Quick Actions**
   - Tap technique name to see full detail in modal
   - Quick access to safety notes without leaving run mode

3. **Visual Indicators**
   - Progress bars for quality tracking vs. targets
   - Check marks when targets are met
   - Visual feedback on constraint compliance

4. **Smart Summaries**
   - Auto-summarize long coaching cues
   - Highlight most critical information
   - Context-aware display based on segment type

5. **Integration with Wearables**
   - Display resistance level from heart rate
   - Track actual vs. target metrics in real-time
   - Haptic feedback for round transitions

## Conclusion

This implementation successfully adds summary-level detail to `SegmentRunCard` while maintaining:
- Clean, scrollable UI
- Clear visual hierarchy
- Backward compatibility
- Performance (no extra network/disk access)
- Separation of concerns (summary vs. full detail)

The enhancement makes BlockRunMode a more effective training tool while still encouraging users to reference the Whiteboard for comprehensive technique instruction and planning.

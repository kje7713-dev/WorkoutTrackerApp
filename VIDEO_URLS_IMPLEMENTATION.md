# Video URLs UI Implementation

## Overview
This document describes the UI implementation for rendering technique video URLs in the expanded segment detail view.

## Location
**Screen:** Expanded Segment Detail view (TechniqueRow in WhiteboardViews.swift)

## Implementation Details

### Data Model Changes
1. Added `videoUrls: [String]?` to `Technique` struct (Models.swift)
2. Added `videoUrls: [String]?` to `UnifiedTechnique` struct (WhiteboardModels.swift)
3. Updated `BlockNormalizer.swift` to map videoUrls between models

### UI Design

#### Rendering Logic
- **If videoUrls is nil or empty:** Nothing is rendered
- **If videoUrls exists and has items:** Render the "Videos" section

#### Visual Structure
```
┌─────────────────────────────────────────────┐
│ Technique Name                           ▼  │  ← Collapsible header
├─────────────────────────────────────────────┤
│                                             │
│ Key Details:                                │
│   • Detail 1                                │
│   • Detail 2                                │
│                                             │
│ Common Errors:                              │
│   • Error 1                                 │
│                                             │
│ Videos                                      │  ← NEW: Videos section
│   ┌───────────────────────────────────┐    │
│   │ ▶ Technique demo          ↗      │    │  ← Video link
│   └───────────────────────────────────┘    │
│   ┌───────────────────────────────────┐    │
│   │ ▶ Technique demo          ↗      │    │  ← Additional videos
│   └───────────────────────────────────┘    │
│                                             │
└─────────────────────────────────────────────┘
```

#### Component Breakdown

**"Videos" Section Header:**
- Font: `.caption`
- Font Weight: `.semibold`
- Matches style of other section headers (Key Details, Common Errors, etc.)

**Video Link Items:**
Each video URL renders as a `Link` with:

**Left Icon:**
- System icon: `play.rectangle.fill` (YouTube-style play button)
- Color: Red (`.red`)
- Font: `.caption`

**Label:**
- Text: "Technique demo"
- Font: `.caption`
- Color: `.primary`

**Right Icon:**
- System icon: `arrow.up.forward.square` (external link indicator)
- Font: `.caption2`
- Color: `.secondary`

**Container:**
- Padding: 8pt
- Full width alignment (`.leading`)
- Background: `Color(.systemBackground).opacity(0.5)` (lighter than main card)
- Corner radius: 6pt
- Spacing between items: 4pt

### Behavior
- **Click action:** Opens URL in Safari (default browser)
- **No autoplay:** Links are passive until tapped
- **No embedded player:** External browser navigation only
- **No thumbnails:** Simple link representation

### Multiple Videos
- Each URL renders as a separate clickable link in a vertical list
- Spacing maintained between items (4pt)
- Consistent styling for all items

### Single Video
- Still renders "Videos" header for consistency
- Single clickable link below header

### Example JSON
```json
{
  "techniques": [
    {
      "name": "Single Leg Takedown",
      "variant": "High crotch finish",
      "keyDetails": ["Level change", "Penetration step"],
      "videoUrls": [
        "https://www.youtube.com/watch?v=example1"
      ]
    },
    {
      "name": "Double Leg Takedown",
      "videoUrls": [
        "https://www.youtube.com/watch?v=example2",
        "https://www.youtube.com/watch?v=example3"
      ]
    }
  ]
}
```

## Backward Compatibility
- `videoUrls` is an optional field
- Existing JSON without videoUrls continues to work
- Existing Technique initializations use default `nil` value
- No breaking changes to existing code

## Files Modified
1. `Models.swift` - Added videoUrls to Technique
2. `WhiteboardModels.swift` - Added videoUrls to UnifiedTechnique
3. `BlockNormalizer.swift` - Map videoUrls in both normalization paths
4. `WhiteboardViews.swift` - Render Videos section in TechniqueRow
5. `SEGMENT_SCHEMA_DOCS.md` - Updated documentation
6. `SEGMENT_FIELD_COVERAGE_GUIDE.md` - Added videoUrls to checklist

## Test Data
Created `Tests/technique_video_urls_test.json` with examples of:
- Technique with single videoUrl
- Technique with multiple videoUrls
- Technique without videoUrls (existing behavior)

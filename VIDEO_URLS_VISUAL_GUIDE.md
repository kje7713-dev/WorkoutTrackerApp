# Video URLs UI Visual Guide

## Before & After Comparison

### BEFORE (without videoUrls)
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  Single Leg Takedown                    ▼  ┃  ← Technique card (collapsed)
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  Single Leg Takedown                    ▲  ┃  ← Expanded
┃─────────────────────────────────────────────┃
┃                                             ┃
┃  Key Details:                               ┃
┃    • Level change                           ┃
┃    • Penetration step                       ┃
┃    • Head position                          ┃
┃                                             ┃
┃  Common Errors:                             ┃
┃    • Reaching without level change          ┃
┃                                             ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### AFTER (with videoUrls - Single Video)
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  Single Leg Takedown                    ▲  ┃  ← Expanded
┃─────────────────────────────────────────────┃
┃                                             ┃
┃  Key Details:                               ┃
┃    • Level change                           ┃
┃    • Penetration step                       ┃
┃    • Head position                          ┃
┃                                             ┃
┃  Common Errors:                             ┃
┃    • Reaching without level change          ┃
┃                                             ┃
┃  Videos                              ← NEW  ┃
┃  ╔═══════════════════════════════════════╗ ┃
┃  ║ ▶️ Technique demo              ↗    ║ ┃  ← Clickable link
┃  ╚═══════════════════════════════════════╝ ┃
┃                                             ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### AFTER (with videoUrls - Multiple Videos)
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  Double Leg Takedown                    ▲  ┃  ← Expanded
┃─────────────────────────────────────────────┃
┃                                             ┃
┃  Key Details:                               ┃
┃    • Drive through                          ┃
┃    • Keep head up                           ┃
┃                                             ┃
┃  Videos                              ← NEW  ┃
┃  ╔═══════════════════════════════════════╗ ┃
┃  ║ ▶️ Technique demo              ↗    ║ ┃  ← Video 1
┃  ╚═══════════════════════════════════════╝ ┃
┃  ╔═══════════════════════════════════════╗ ┃
┃  ║ ▶️ Technique demo              ↗    ║ ┃  ← Video 2
┃  ╚═══════════════════════════════════════╝ ┃
┃                                             ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

## UI Component Details

### Video Link Component Breakdown
```
╔═══════════════════════════════════════════════╗
║  [▶️]  [Technique demo]  [↗]                 ║
║   ↑           ↑            ↑                  ║
║   │           │            └─ External link   ║
║   │           │                indicator      ║
║   │           │                (caption2,     ║
║   │           │                 secondary)    ║
║   │           │                               ║
║   │           └─ Label text                   ║
║   │              (caption, primary)           ║
║   │                                           ║
║   └─ YouTube-style play icon                 ║
║      (play.rectangle.fill, red, caption)     ║
╚═══════════════════════════════════════════════╝
      ↑
      └─ Background: systemBackground @ 50% opacity
         Padding: 8pt all sides
         Corner radius: 6pt
         Full width, left-aligned
```

### Color & Typography Specs

**"Videos" Header:**
- Font: `.caption` (system caption)
- Weight: `.semibold`
- Color: Primary text color

**Play Icon:**
- Symbol: `play.rectangle.fill` (SF Symbol)
- Color: `.red` (YouTube brand association)
- Size: `.caption`

**Label:**
- Text: "Technique demo"
- Font: `.caption`
- Color: `.primary`

**External Link Icon:**
- Symbol: `arrow.up.forward.square` (SF Symbol)
- Color: `.secondary`
- Size: `.caption2` (smaller than caption)

**Container:**
- Background: `Color(.systemBackground)` with 50% opacity
- Corner radius: 6pt
- Padding: 8pt
- Spacing between items: 4pt vertical

### Parent Card Styling
- Background: `Color(.tertiarySystemBackground)` (darker)
- Padding: 10pt
- Corner radius: 8pt

### Visual Hierarchy
```
Technique Card (tertiarySystemBackground - darkest)
└── Content Area
    ├── Key Details section
    ├── Common Errors section
    ├── Follow-ups section
    ├── Counters section
    └── Videos section
        └── Video Links (systemBackground @ 50% - lightest)
```

## Interaction Flow

### User Journey
1. User views segment in whiteboard
2. User taps technique name to expand
3. Technique details appear with animation
4. If videoUrls present, "Videos" section appears below other details
5. User taps any video link
6. iOS opens URL in Safari/default browser
7. User watches technique demonstration
8. User returns to app to continue workout planning

### States
- **No videos:** Videos section not rendered at all
- **Has videos:** Videos section rendered with all URLs
- **Tap video:** Link opens in external browser (Safari)
- **No autoplay:** Passive until user interaction

## Accessibility

### VoiceOver Support
- Link elements are accessible via SwiftUI's Link component
- Each link announces: "Technique demo, link" 
- External link indicator is semantic via SF Symbol

### Dynamic Type Support
- All text uses system fonts (`.caption`, `.caption2`)
- Automatically scales with user's text size preferences

## Example Use Cases

### 1. BJJ Technique with Tutorial
```json
{
  "name": "Single Leg Takedown",
  "videoUrls": ["https://youtube.com/watch?v=abc123"]
}
```
**Result:** One clickable video link in expanded view

### 2. Multiple Angle Demonstrations
```json
{
  "name": "Arm Bar from Guard",
  "videoUrls": [
    "https://youtube.com/watch?v=basic-armbar",
    "https://youtube.com/watch?v=armbar-counters",
    "https://youtube.com/watch?v=armbar-advanced"
  ]
}
```
**Result:** Three stacked video links, each clickable

### 3. Legacy Technique (no videos)
```json
{
  "name": "Basic Stance",
  "keyDetails": ["Feet shoulder width", "Knees bent"]
}
```
**Result:** No Videos section rendered (backward compatible)

## Technical Implementation Notes

### SwiftUI Code Structure
```swift
if let videoUrls = technique.videoUrls, !videoUrls.isEmpty {
    Text("Videos")
        .font(.caption)
        .fontWeight(.semibold)
    
    VStack(alignment: .leading, spacing: 4) {
        ForEach(videoUrls, id: \.self) { urlString in
            if let url = URL(string: urlString) {
                Link(destination: url) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.rectangle.fill")
                            .foregroundColor(.red)
                        Text("Technique demo")
                        Image(systemName: "arrow.up.forward.square")
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(...)
                }
            }
        }
    }
}
```

### Key Design Decisions

1. **Optional Field:** Maintains backward compatibility
2. **Simple Link:** No complex video player, just external navigation
3. **Consistent Label:** All videos labeled "Technique demo" for simplicity
4. **YouTube Icon:** Red play button provides visual association
5. **External Indicator:** Arrow icon shows link opens externally
6. **Secondary Background:** Lighter than card, provides visual separation
7. **Vertical Stack:** Natural flow for multiple videos

### Layout Integration
The Videos section integrates seamlessly with existing technique detail sections:
- Appears last in the expanded view
- Same indentation as other sections (12pt left padding)
- Consistent header styling
- Natural flow with existing content

## Test Coverage
See `Tests/technique_video_urls_test.json` for comprehensive examples testing:
- Single video URL
- Multiple video URLs
- Technique without videos (existing behavior)
- All in context of a full segment structure

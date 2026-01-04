# Exercise Video URLs - Visual Guide

## Before & After Comparison

### BEFORE (without videoUrls)
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  🔽 Bench Press                              ┃  ← Exercise card (expanded)
┃─────────────────────────────────────────────┃
┃  Type: [Strength | Conditioning]           ┃
┃                                             ┃
┃  Add notes (RPE, cues, etc.)                ┃
┃  [editable text field]                      ┃
┃                                             ┃
┃  Sets:                                      ┃
┃  ┌─────────────────────────────────────┐   ┃
┃  │ Set 1: 5 reps @ 135 lbs       ☐    │   ┃
┃  └─────────────────────────────────────┘   ┃
┃  ┌─────────────────────────────────────┐   ┃
┃  │ Set 2: 5 reps @ 135 lbs       ☐    │   ┃
┃  └─────────────────────────────────────┘   ┃
┃  ┌─────────────────────────────────────┐   ┃
┃  │ Set 3: 5 reps @ 135 lbs       ☐    │   ┃
┃  └─────────────────────────────────────┘   ┃
┃                                             ┃
┃  [+ Add Set]                  [- Remove]    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### AFTER (with videoUrls - Single Video)
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  🔽 Bench Press                              ┃  ← Exercise card (expanded)
┃─────────────────────────────────────────────┃
┃  Type: [Strength | Conditioning]           ┃
┃                                             ┃
┃  Add notes (RPE, cues, etc.)                ┃
┃  [editable text field]                      ┃
┃                                             ┃
┃  Videos                              ← NEW  ┃
┃  ╔═══════════════════════════════════════╗ ┃
┃  ║ ▶️ Technique demo              ↗    ║ ┃  ← Clickable video link
┃  ╚═══════════════════════════════════════╝ ┃
┃                                             ┃
┃  Sets:                                      ┃
┃  ┌─────────────────────────────────────┐   ┃
┃  │ Set 1: 5 reps @ 135 lbs       ☐    │   ┃
┃  └─────────────────────────────────────┘   ┃
┃  ┌─────────────────────────────────────┐   ┃
┃  │ Set 2: 5 reps @ 135 lbs       ☐    │   ┃
┃  └─────────────────────────────────────┘   ┃
┃  ┌─────────────────────────────────────┐   ┃
┃  │ Set 3: 5 reps @ 135 lbs       ☐    │   ┃
┃  └─────────────────────────────────────┘   ┃
┃                                             ┃
┃  [+ Add Set]                  [- Remove]    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### AFTER (with videoUrls - Multiple Videos)
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  🔽 Olympic Clean                            ┃  ← Exercise card (expanded)
┃─────────────────────────────────────────────┃
┃  Type: [Strength | Conditioning]           ┃
┃                                             ┃
┃  Add notes (RPE, cues, etc.)                ┃
┃  [editable text field]                      ┃
┃                                             ┃
┃  Videos                              ← NEW  ┃
┃  ╔═══════════════════════════════════════╗ ┃
┃  ║ ▶️ Technique demo              ↗    ║ ┃  ← Video 1: Setup
┃  ╚═══════════════════════════════════════╝ ┃
┃  ╔═══════════════════════════════════════╗ ┃
┃  ║ ▶️ Technique demo              ↗    ║ ┃  ← Video 2: Pull
┃  ╚═══════════════════════════════════════╝ ┃
┃  ╔═══════════════════════════════════════╗ ┃
┃  ║ ▶️ Technique demo              ↗    ║ ┃  ← Video 3: Catch
┃  ╚═══════════════════════════════════════╝ ┃
┃                                             ┃
┃  Sets:                                      ┃
┃  ┌─────────────────────────────────────┐   ┃
┃  │ Set 1: 3 reps @ 185 lbs       ☐    │   ┃
┃  └─────────────────────────────────────┘   ┃
┃                                             ┃
┃  [+ Add Set]                  [- Remove]    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

## UI Component Breakdown

### Video Link Component
```
╔═══════════════════════════════════════════════╗
║  [▶️]  [Technique demo]  [    ]  [↗]         ║
║   ↑           ↑            ↑      ↑           ║
║   │           │            │      └─ External ║
║   │           │            │         link     ║
║   │           │            │         icon     ║
║   │           │            └─ Spacer pushes  ║
║   │           │               icon to right   ║
║   │           └─ Label text                  ║
║   │              (caption, primary)          ║
║   └─ YouTube-style play icon                ║
║      (play.rectangle.fill, red, caption)    ║
╚═══════════════════════════════════════════════╝
       ↑
       └─ Background: systemBackground @ 50% opacity
          Padding: 8pt all sides
          Corner radius: 6pt
          Full width, left-aligned
```

## Color & Typography Specs

### "Videos" Section Header
- **Font:** `.caption` (system caption)
- **Weight:** `.semibold`
- **Top Padding:** 4pt
- **Color:** Primary text color

### Play Icon
- **Symbol:** `play.rectangle.fill` (SF Symbol)
- **Color:** `.red` (YouTube brand association)
- **Size:** `.caption`

### Label Text
- **Text:** "Technique demo"
- **Font:** `.caption`
- **Color:** `.primary`

### External Link Icon
- **Symbol:** `arrow.up.forward.square` (SF Symbol)
- **Color:** `.secondary`
- **Size:** `.caption2` (smaller than caption)

### Video Link Container
- **Background:** `Color(.systemBackground)` with 50% opacity
- **Corner Radius:** 6pt
- **Padding:** 8pt
- **Spacing:** 4pt vertical between multiple videos

## User Interaction Flow

### During Workout Session
```
1. User opens workout session
   ↓
2. User expands exercise card
   ↓
3. If exercise has videoUrls:
   - "Videos" section appears below notes
   - Video links are displayed
   ↓
4. User taps video link
   ↓
5. iOS opens URL in Safari/default browser
   ↓
6. User watches demonstration
   ↓
7. User returns to app
   ↓
8. User completes sets with proper technique
```

## Context: Where Exercise Cards Appear

### Workout Session View (BlockRunModeView)
```
┌─────────────────────────────────────────┐
│  [Close Session]     Block Name  [🔍]  │  ← Top bar
├─────────────────────────────────────────┤
│                                         │
│  Week 1 of 4     •••     Day 1 of 3    │  ← Week/Day indicator
│                                         │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  │
│  ┃ 🔽 Bench Press                  ┃  │  ← Exercise 1
│  ┃   Videos                        ┃  │
│  ┃   [▶️ Technique demo]  ↗       ┃  │  ← NEW
│  ┃   Sets: [...]                   ┃  │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  │
│                                         │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  │
│  ┃ 🔽 Overhead Press               ┃  │  ← Exercise 2
│  ┃   Videos                        ┃  │
│  ┃   [▶️ Technique demo]  ↗       ┃  │  ← NEW
│  ┃   [▶️ Technique demo]  ↗       ┃  │  ← NEW
│  ┃   Sets: [...]                   ┃  │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  │
│                                         │
│  [+ Add Exercise]                       │  ← Add more
│                                         │
└─────────────────────────────────────────┘
```

## Comparison with Technique Videos

Both Exercise and Technique video URLs use the same UI pattern:

| Feature | Technique (Whiteboard) | Exercise (Session) |
|---------|------------------------|---------------------|
| Location | Expanded TechniqueRow | Expanded ExerciseRunCard |
| Header | "Videos" | "Videos" |
| Icon | ▶️ (red) | ▶️ (red) |
| Label | "Technique demo" | "Technique demo" |
| Link Icon | ↗ | ↗ |
| Background | systemBackground @ 50% | systemBackground @ 50% |
| Action | Opens in Safari | Opens in Safari |

## Example Use Cases

### 1. Powerlifting Exercise
**Bench Press with form check video**
- User opens workout
- Sees Bench Press exercise
- Taps video link to review proper form
- Watches technique video
- Returns to app and completes sets with correct form

### 2. Complex Olympic Lift
**Clean & Jerk with multiple instructional videos**
- Exercise has 3 videos: Setup, Pull, Catch
- User can review each phase separately
- All videos available before starting the lift
- User can reference during rest periods

### 3. Conditioning Exercise
**Rowing with technique tutorial**
- Cardio exercise with proper stroke form video
- User checks form before starting intervals
- Reference available throughout the workout

### 4. Legacy Exercise
**Air Bike without videos**
- Exercise renders normally without Videos section
- No visual changes to existing cards
- Full backward compatibility

## Technical Notes

### SwiftUI Implementation
```swift
// Video URLs section (if present)
if let videoUrls = exercise.videoUrls, !videoUrls.isEmpty {
    Text("Videos")
        .font(.caption)
        .fontWeight(.semibold)
        .padding(.top, 4)
    
    VStack(alignment: .leading, spacing: 4) {
        ForEach(videoUrls, id: \.self) { urlString in
            if let url = URL(string: urlString) {
                Link(destination: url) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.rectangle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("Technique demo")
                            .font(.caption)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.forward.square")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemBackground).opacity(0.5))
                    )
                }
            }
        }
    }
}
```

### Key Design Decisions

1. **Consistent Styling:** Uses exact same visual style as Technique videos
2. **Placement:** Videos appear between notes and sets for natural flow
3. **Optional Rendering:** Only shows when videos exist, maintaining clean UI
4. **Simple Labels:** All videos use "Technique demo" for consistency
5. **External Links:** Opens in Safari rather than embedded player
6. **Backward Compatible:** Existing exercises without videos unchanged

## Accessibility

### VoiceOver Support
- Link elements are accessible via SwiftUI's Link component
- Each link announces: "Technique demo, link"
- External link indicator is semantic via SF Symbol

### Dynamic Type Support
- All text uses system fonts (`.caption`, `.caption2`)
- Automatically scales with user's text size preferences
- Icons scale proportionally with text

### Color Contrast
- Red play icon stands out against backgrounds
- Secondary color for external link maintains hierarchy
- Light background provides separation from card

## Future Enhancement Ideas (Out of Scope)

These features could be added later but are not part of this implementation:
- Custom video labels instead of generic "Technique demo"
- Video thumbnails from URL preview
- Embedded video player (YouTube/Vimeo)
- Autoplay or preview functionality
- Platform-specific icons (YouTube vs Vimeo logos)
- Video duration display
- Watch history or progress tracking
- Offline video caching
- UI to add/edit videos in BlockBuilderView

---

**Visual Design Status:** ✅ COMPLETE  
**Matches Technique Pattern:** ✅ YES  
**Accessibility:** ✅ SUPPORTED  
**Backward Compatibility:** ✅ VERIFIED

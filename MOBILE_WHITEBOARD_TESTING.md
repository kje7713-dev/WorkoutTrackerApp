# Mobile Whiteboard Testing Quick Start

## Prerequisites

- Xcode 16.0+
- iOS 17.0+ simulator or device
- Valid subscription (or dev unlock for testing)

## Build Instructions

### 1. Generate Xcode Project

```bash
cd /path/to/WorkoutTrackerApp
xcodegen generate
```

This creates `WorkoutTrackerApp.xcodeproj` from `project.yml`.

### 2. Open in Xcode

```bash
open WorkoutTrackerApp.xcodeproj
```

### 3. Select Scheme and Device

- Scheme: `WorkoutTrackerApp`
- Device: iPhone 15 (or any iOS 17+ device)

### 4. Build and Run

- Press `Cmd+R` or click the Run button
- Wait for build to complete
- App launches on simulator/device

## Accessing the Whiteboard

### From BlockRunMode

1. **Launch app** → Home screen
2. **Tap a block** → Opens BlocksListView
3. **Tap "Start Training"** → Opens BlockRunModeView
4. **Tap "Whiteboard" button** (top-right toolbar)
5. **Whiteboard opens** → Mobile-first view appears

**Note:** Whiteboard is a Pro feature. If not subscribed:
- Paywall sheet appears
- Subscribe or use dev unlock
- Then access whiteboard

### Dev Unlock (for testing)

If subscription check is blocking access:

1. Look for dev unlock mechanism (check `DEV_UNLOCK.md`)
2. Or temporarily modify `blockrunmode.swift` line 135:
   ```swift
   if subscriptionManager.isSubscribed || true {  // ← Force true for testing
       showWhiteboard = true
   }
   ```

## Testing Checklist

### Visual Tests

**Sticky Header:**
- [ ] Day name displays in bold title font
- [ ] Goal chip appears (blue, uppercase)
- [ ] Duration chip appears (orange, "X min")
- [ ] Position tags appear in scrollable row
- [ ] Tags are outlined (not filled)

**Flow Strip:**
- [ ] All segments appear as pills
- [ ] Icons match segment types (🔄 🧠 🔁 etc.)
- [ ] Colors match types (orange, blue, purple, red, green)
- [ ] Duration badges show (e.g., "15m")
- [ ] Progress indicator shows "X / Y segments"
- [ ] Pills scroll horizontally

**Segment Cards:**
- [ ] Cards stack vertically
- [ ] Collapsed state shows: icon, stripe, title, type, duration
- [ ] Objective preview shows (1 line)
- [ ] Micro-badges appear if data present
- [ ] Chevron icon points down (collapsed) or up (expanded)

### Interaction Tests

**Flow Strip Navigation:**
- [ ] Tap pill → scrolls to corresponding card
- [ ] Selected pill scales up (1.05x)
- [ ] Selected pill has shadow
- [ ] Scroll is smooth, no lag

**Card Expand/Collapse:**
- [ ] Tap card header → expands card
- [ ] Tap again → collapses card
- [ ] Only one card expanded at a time
- [ ] Expansion is smooth (0.3s animation)
- [ ] Chevron animates with card

**Technique Accordion:**
- [ ] Tap technique row → expands details
- [ ] Shows: key details, errors, follow-ups, counters
- [ ] Tap again → collapses
- [ ] Multiple techniques can be expanded
- [ ] Smooth animation

**Scrolling:**
- [ ] Vertical scroll through cards is smooth
- [ ] Horizontal scroll in flow strip is smooth
- [ ] No stuttering or lag
- [ ] Scroll position maintained when expanding

### Content Tests

**Test with Various Segment Types:**

Create or find a day with these segment types:
- [ ] Warmup (🔄 orange)
- [ ] Mobility (🧘 orange)
- [ ] Technique (🧠 blue)
- [ ] Drill (🔁 purple)
- [ ] Positional Spar (⚔️ red)
- [ ] Rolling (🥋 red)
- [ ] Cooldown (🌬️ green)
- [ ] Lecture (🎓 gray)
- [ ] Breathwork (🌬️ green)

**Test Section Rendering:**

Expand a card with full data:
- [ ] Objective section appears
- [ ] Positions chips appear
- [ ] Techniques accordion appears
- [ ] Drill plan list appears
- [ ] Partner plan box appears (blue border)
- [ ] Round plan box appears (red border)
- [ ] Constraints appear (orange bg, ⚠️ icons)
- [ ] Scoring appears (two columns if multiple)
- [ ] Flow sequence appears (with → transitions)
- [ ] Breathwork box appears (green bg)
- [ ] Coaching cues chips appear (blue bg)
- [ ] Safety warnings appear (red bg, ⛔ 🛑)
- [ ] Notes appear last

**Test Empty Sections:**

Expand a card with minimal data:
- [ ] Empty sections do not appear
- [ ] No empty boxes or headers
- [ ] Card height adjusts to content
- [ ] No layout breaks

### Device Tests

Test on different screen sizes:

**iPhone SE (small):**
- [ ] Layout is readable
- [ ] Touch targets are 44pt+
- [ ] No horizontal overflow
- [ ] Chips wrap appropriately
- [ ] Text is not truncated

**iPhone 15 (standard):**
- [ ] Layout looks balanced
- [ ] Generous whitespace
- [ ] Typography hierarchy clear
- [ ] All content visible

**iPhone 15 Pro Max (large):**
- [ ] Layout doesn't look sparse
- [ ] Content scales appropriately
- [ ] No excessive whitespace
- [ ] Typography readable

**iPad (if supported):**
- [ ] Layout adapts to larger screen
- [ ] Content is centered or appropriately sized
- [ ] Touch targets remain accessible

### Performance Tests

**With Few Segments (1-3):**
- [ ] Renders instantly
- [ ] Animations are 60fps
- [ ] No lag or stuttering

**With Many Segments (10+):**
- [ ] Initial render is fast
- [ ] Scroll is smooth
- [ ] Expand/collapse is fast
- [ ] Memory usage reasonable

**Rapid Interactions:**
- [ ] Rapid pill tapping → smooth scrolls
- [ ] Rapid card tapping → smooth animations
- [ ] No crashes or freezes

### Accessibility Tests

**Touch Targets:**
- [ ] All tap areas are at least 44pt
- [ ] Card headers are easy to tap
- [ ] Pills are easy to tap
- [ ] Chevrons are easy to tap

**Visual:**
- [ ] Text is readable (not too small)
- [ ] Contrast is sufficient
- [ ] Color is not sole indicator (icons + text)
- [ ] Dynamic Type works (if supported)

**VoiceOver (if time permits):**
- [ ] Elements are labeled
- [ ] Navigation is logical
- [ ] Actions are clear

## Known Issues to Ignore

- Exercise-based days (non-segment) may not show whiteboard
- Empty days may show "No data for this day"
- Segments without id field will not work (already fixed in code)

## Screenshot Capture

Take screenshots of:

1. **Full view** - Showing header + flow strip + cards
2. **Flow strip** - Close-up of pills with colors
3. **Collapsed card** - Showing icon, stripe, badges
4. **Expanded card** - Showing all sections (A-M)
5. **Technique accordion** - Expanded with details
6. **Partner plan** - Showing resistance bar
7. **Safety warnings** - Showing emoji indicators
8. **Different segment types** - Each color

Save screenshots to: `/docs/screenshots/mobile-whiteboard/`

## Reporting Issues

If you find bugs, note:
1. Device and iOS version
2. Steps to reproduce
3. Expected vs actual behavior
4. Screenshot if visual issue
5. Console logs if crash/error

## Test Data Creation

To test all features, create a day with:

- Multiple segment types (warmup, technique, drill, spar)
- Techniques with all detail fields
- Partner plan with resistance and quality targets
- Constraints (3-5 items)
- Safety warnings (contraindications + stop conditions)
- Coaching cues (5-7 items)
- Flow sequence (if mobility segment)
- Breathwork (if breathwork segment)

Example JSON structures are in:
- `SEGMENT_SCHEMA_DOCS.md`
- `RECOMMENDED_PARTNERPLAN_STRUCTURE.json`

## Success Criteria

Whiteboard is considered working if:

✅ All 11 segment types display correctly
✅ Colors and icons match design spec
✅ Flow strip navigation works
✅ Cards expand/collapse smoothly
✅ All 13 section types render when data present
✅ Empty sections are hidden
✅ Layout works on iPhone SE, 15, 15 Pro Max
✅ Animations are smooth (60fps)
✅ No crashes or freezes
✅ Touch targets are accessible (44pt+)

## Next Steps After Testing

1. **Document findings** in test results file
2. **Take screenshots** for documentation
3. **Fix any bugs** found during testing
4. **Update documentation** with actual screenshots
5. **Mark as production-ready** if all tests pass

## Quick Fixes

If something doesn't work:

**Whiteboard button doesn't appear:**
- Check subscription status
- Check `showWhiteboard` state binding
- Check toolbar placement

**Segments don't appear:**
- Check `day.segments` array has items
- Check `UnifiedSegment` has id field
- Check BlockNormalizer conversion

**Colors are wrong:**
- Check `segmentType` string values
- Check `.lowercased()` comparison
- Check Color constants

**Layout is broken:**
- Check SwiftUI view hierarchy
- Check padding/spacing values
- Check device screen size

**Animations are janky:**
- Check device performance
- Check LazyVStack usage
- Check animation durations

## Contact

For questions or issues:
- Check implementation docs first
- Review visual guide for expected behavior
- Check GitHub issues for known problems
- Submit PR with fixes if confident

---

**Testing Time Estimate:** 30-45 minutes for comprehensive testing
**Priority:** High (validates all requirements)
**Blocker:** Requires iOS device or simulator

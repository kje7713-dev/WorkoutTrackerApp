# Pro Home Screen Visual Layout

```
┌─────────────────────────────────────────────────┐
│ ⬤ Savage by Design                         ⚙️  │ ← Top App Bar
├─────────────────────────────────────────────────┤   (H: auto, Pad: 16/12)
│                                                 │
│ ┌───────────────────────────────────────────┐ │
│ │  SAVAGE BY DESIGN — PRO     [PRO ACTIVE] │ │ ← Hero Card
│ │                                           │ │   (Dark #0F0F10)
│ │  Train with intent.                      │ │   (Corner: 16)
│ │  Programs, progression, and curriculum   │ │   (Shadow: heavy)
│ │  in one place.                            │ │
│ │                                           │ │
│ │  [📦 Blocks] [📊 Progress] [✨ Builder] │ │ ← Mini Metrics
│ └───────────────────────────────────────────┘ │
│                                                 │
│ ┌───────────────────────────────────────────┐ │
│ │ 🔲  Training Blocks                    ›  │ │ ← Feature Row 1
│ │     Browse 4–12 week programs...          │ │   (White card)
│ └───────────────────────────────────────────┘ │   (Corner: 14)
│                                                 │
│ ┌───────────────────────────────────────────┐ │
│ │ 📊  Progress History                   ›  │ │ ← Feature Row 2
│ │     See volume, sessions, and streak      │ │   (Gap: 12)
│ └───────────────────────────────────────────┘ │
│                                                 │
│ ┌───────────────────────────────────────────┐ │
│ │ ✨  Curriculum Builder                 ›  │ │ ← Feature Row 3
│ │     Design strength or hybrid curricula   │ │
│ └───────────────────────────────────────────┘ │
│                                                 │
│ ┌──────────────────────┐ ┌──────────────────┐ │
│ │ Manage Subscription  │ │ Restore Purchase │ │ ← Secondary Actions
│ │    (Black BG)        │ │  (White BG)      │ │   (H: 52, Gap: 12)
│ └──────────────────────┘ └──────────────────┘ │
│                                                 │
│           Questions? Contact support            │ ← Footer
│               [copilot/branch-name]             │
└─────────────────────────────────────────────────┘
```

## Spacing Diagram (Vertical)

```
┌─ Safe Area Top ─────────────────────────────────┐
│                                                  │
├─ Top App Bar (12pt vertical padding) ───────────┤
│                                                  │
├─ 16pt spacing ──────────────────────────────────┤
│                                                  │
├─ Hero Card (content-driven height ~140-170) ────┤
│                                                  │
├─ 16pt spacing ──────────────────────────────────┤
│                                                  │
├─ Feature Row 1 (height: auto) ──────────────────┤
│                                                  │
├─ 12pt spacing ──────────────────────────────────┤
│                                                  │
├─ Feature Row 2 ─────────────────────────────────┤
│                                                  │
├─ 12pt spacing ──────────────────────────────────┤
│                                                  │
├─ Feature Row 3 ─────────────────────────────────┤
│                                                  │
├─ 20pt spacing ──────────────────────────────────┤
│                                                  │
├─ Button Row (H: 52) ────────────────────────────┤
│                                                  │
├─ 8pt spacing ───────────────────────────────────┤
│                                                  │
├─ Footer ────────────────────────────────────────┤
│                                                  │
└─ 24pt bottom padding ───────────────────────────┘
```

## Color Palette

### Light Mode (Primary)

```
Background:      #F7F7F7  ░░░░░░  (Page background)
Surface:         #FFFFFF  ▓▓▓▓▓▓  (Cards, buttons)
Text Primary:    #0B0B0B  ██████  (Headings, body)
Text Secondary:  #5A5A5A  ▒▒▒▒▒▒  (Subtitles, captions)
Divider:         #000000 @ 8%     (Borders, strokes)
Brand Black:     #0F0F10  ██████  (Hero card, primary CTA)
Brand Green:     #22C55E  ██████  (Success, pro status)
Accent Gold:     #D4AF37  ██████  (Premium accents - sparingly)
```

## Component Breakdown

### Hero Card Internal Layout

```
┌─────────────────────────────────────────────────┐
│ SAVAGE BY DESIGN — PRO        [● PRO ACTIVE]   │ ← Row 1
│                                                 │    (Badge + Status)
│ Train with intent.                             │ ← Row 2 (Title)
│ Programs, progression, and curriculum          │    (Subtitle)
│ in one place.                                   │
│                                                 │
│ [📦 Blocks] [📊 Progress] [✨ Builder]        │ ← Row 3 (Metrics)
└─────────────────────────────────────────────────┘

Padding: 16pt all around
Spacing: 12pt between rows
Background: #0F0F10 (Brand Black)
Corner: 16pt
Shadow: 0 10 30 @ 12% black
```

### Status Pill Detail

```
┌──────────────────┐
│ ● PRO ACTIVE    │  Height: 26pt
└──────────────────┘  Padding: 10h / 6v
                      Corner: 999 (pill)
                      BG: Green @ 18%
                      Text: Green, 12pt semibold
                      Dot: 6×6 circle
```

### Metric Chip Detail

```
┌───────────────┐
│ 📦 Blocks    │  Height: 28pt
└───────────────┘  Padding: 10h / 6v
                   Corner: 999 (pill)
                   BG: White @ 10%
                   Text: White @ 85%, 12pt
                   Icon: 14×14
```

### Feature Row Detail

```
┌─────────────────────────────────────────────────┐
│  ⭕  Training Blocks                          › │
│      Browse 4–12 week programs and build       │
│      sessions fast                              │
└─────────────────────────────────────────────────┘

Icon Container: 36×36 circle, BG @ 6%
Icon: 18pt SF Symbol
Title: 16pt semibold
Subtitle: 13pt regular, secondary color
Chevron: @ 35% opacity
Internal Padding: 14pt
Border: 1px @ 8% opacity
Corner: 14pt
Shadow: 0 3 10 @ 6%
```

## Typography Hierarchy

```
H1 (Title)        28pt  Semibold  "Train with intent."
H2 (Section)      18pt  Semibold  "Savage by Design"
Body              15pt  Regular   "Programs, progression..."
Subtext           13pt  Regular   "Browse 4–12 week programs..."
Button            16pt  Semibold  "Manage Subscription"
Badge/Chip        12pt  Semibold  "PRO ACTIVE" "Blocks"
```

## Icon Mapping

```
Logo              : Custom "SBDPrimaryLogo" asset (32×32 in 36×36 circle)
Settings          : gearshape
Training Blocks   : square.stack.3d.up.fill
Progress          : chart.bar.fill
Curriculum Builder: wand.and.stars
Chevron           : chevron.right
```

## Responsive Behavior

- **ScrollView**: All content scrollable for smaller devices
- **Safe Area**: Respects top/bottom safe area insets
- **Dynamic Type**: Supports iOS accessibility text sizing
- **Device Sizes**: Optimized for iPhone SE to iPhone Pro Max
- **Landscape**: Horizontal scroll, maintains layout structure

## Dark Mode Considerations (Future)

While the current implementation focuses on light mode, dark mode support can be added:

```
Background:      #000000 or #0A0A0A
Surface:         #1C1C1E
Text Primary:    #FFFFFF
Text Secondary:  #999999
Hero Card:       Keep #0F0F10 or slightly lighter
Feature Rows:    #1C1C1E surface
```

## Accessibility

- **VoiceOver**: All buttons have semantic labels
- **Contrast**: WCAG AA compliant text contrast ratios
- **Touch Targets**: Minimum 44pt touch targets
- **Dynamic Type**: Text scales with system preferences
- **Reduce Motion**: Respects system animation preferences

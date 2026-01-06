# Pro Home Design Implementation Guide

## Overview

This document describes the implementation of the "Savage by Design — Pro Home" screen redesign following the detailed design specifications.

## Design System Implementation

### Design Tokens (DesignTokens struct)

**Spacing (8pt grid)**
- `spacing4` = 4
- `spacing8` = 8
- `spacing12` = 12
- `spacing14` = 14
- `spacing16` = 16
- `spacing20` = 20
- `spacing24` = 24
- `spacing32` = 32

**Corner Radius**
- `cornerCard` = 16 (for hero card and main cards)
- `cornerRow` = 14 (for feature rows and buttons)
- `cornerPill` = 999 (for badges and status pills)

**Stroke**
- `strokeHairline` = 1 (for borders at 8-10% opacity)

### Color Palette

**Light Mode Colors (via Color extension)**
- `proBackground` = #F7F7F7 (page background)
- `proSurface` = #FFFFFF (cards and surfaces)
- `proTextPrimary` = #0B0B0B (primary text)
- `proTextSecondary` = #5A5A5A (secondary text)
- `proDivider` = #000000 @ 8% (borders and dividers)
- `proBrandBlack` = #0F0F10 (hero card and primary buttons)
- `proBrandGreen` = #22C55E (success, pro status)
- `proAccentGold` = #D4AF37 (premium accents, use sparingly)

### Typography

**Font Styles Used**
- **H1 / Title**: 28pt, Semibold (hero card title)
- **H2 / Section**: 18pt, Semibold (top nav title)
- **Body**: 15pt, Regular (hero card subtitle)
- **Subtext**: 13pt, Regular (feature row subtitles)
- **Button**: 16pt, Semibold (all buttons)
- **Badge**: 12pt, Semibold (status pill, metric chips)

## Layout Structure (Top to Bottom)

### A) Top App Bar

**Elements:**
- Left: SBD logo (32×32) inside circular container (36×36)
- Center: "Savage by Design" text (H2)
- Right: Settings icon (gearshape)

**Spacing:**
- Horizontal padding: 16pt
- Vertical padding: 12pt

**Implementation:**
```swift
HStack(alignment: .center, spacing: DesignTokens.spacing12) {
    // Logo in circle
    // Title text
    // Settings button
}
.padding(.horizontal, DesignTokens.spacing16)
.padding(.vertical, DesignTokens.spacing12)
```

### B) Hero Card

**Component:** `HeroCard` with black background (#0F0F10)

**Shadow:** 0 10 30 @ 12% black opacity

**Internal Layout:**
1. **Top Row**: Brand badge + Status pill
   - Badge: "SAVAGE BY DESIGN — PRO" (white @ 85%)
   - Status: Shows "PRO ACTIVE" (green) or "FREE" (gray)

2. **Main Message:**
   - Title: "Train with intent." (28pt semibold, white)
   - Subtitle: "Programs, progression, and curriculum in one place." (15pt, white @ 75%)

3. **Mini Metrics Strip:**
   Three `MetricChip` components showing:
   - Blocks (square.stack.3d.up.fill icon)
   - Progress (chart.bar.fill icon)
   - Builder (wand.and.stars icon)

**Implementation:**
```swift
HeroCard {
    VStack(spacing: DesignTokens.spacing12) {
        // Top row
        HStack {
            Text("SAVAGE BY DESIGN — PRO")
            Spacer()
            StatusPill(...)
        }
        
        // Main message
        VStack(alignment: .leading, spacing: 8) {
            Text("Train with intent.")
            Text("Programs, progression...")
        }
        
        // Metrics
        HStack(spacing: DesignTokens.spacing8) {
            MetricChip(icon: "...", label: "Blocks")
            MetricChip(icon: "...", label: "Progress")
            MetricChip(icon: "...", label: "Builder")
        }
    }
}
```

### C) Feature Action List (3 Primary Rows)

**Component:** `FeatureRow` (tappable card-style navigation)

**Card Styling:**
- Fill: Surface (#FFFFFF)
- Corner: 14pt
- Border: 1px Divider (8%)
- Shadow: 0 3 10 @ 6%
- Padding: 14pt internal
- Spacing between rows: 12pt

**Row Layout:**
- **Left:** Icon (18pt) in circular container (36×36) with BrandBlack @ 6% fill
- **Center:** Title (16pt semibold) + Subtitle (13pt regular, secondary color)
- **Right:** Chevron (chevron.right) @ 35% opacity

**Three Rows:**
1. **Training Blocks**
   - Icon: `square.stack.3d.up.fill`
   - Subtitle: "Browse 4–12 week programs and build sessions fast"
   - Destination: `BlocksListView()`

2. **Progress History**
   - Icon: `chart.bar.fill`
   - Subtitle: "See volume, sessions, and your training streak"
   - Destination: `BlockHistoryListView()`

3. **Curriculum Builder**
   - Icon: `wand.and.stars`
   - Subtitle: "Design strength, grappling, or hybrid curricula"
   - Destination: `DataManagementView()`

### D) Secondary Actions (Two Buttons)

**Layout:**
- Two equal-width buttons side by side
- Gap: 12pt
- Height: 52pt
- Corner: 14pt

**Button 1: "Manage Subscription"**
- Fill: BrandBlack (#0F0F10)
- Text: White, 16pt semibold

**Button 2: "Restore Purchases"**
- Fill: White
- Border: Divider @ 10%
- Text: BrandBlack, 16pt semibold

**Implementation:**
```swift
HStack(spacing: DesignTokens.spacing12) {
    Button { /* Manage */ } label: {
        Text("Manage Subscription")
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity, height: 52)
            .foregroundColor(.white)
            .background(Color.proBrandBlack)
            .cornerRadius(DesignTokens.cornerRow)
    }
    
    Button { /* Restore */ } label: {
        Text("Restore Purchases")
            // Secondary style with border
    }
}
```

### E) Support Footer

**Elements:**
- "Questions? Contact support" (13pt, secondary color, underlined)
- Build branch label (12pt, in rounded container)

**Spacing:**
- Top padding: 8pt additional
- Bottom padding: 24pt

## Screen Spacing Summary

**Vertical Spacing:**
- Nav → Hero: 16pt
- Hero → Feature list: 16pt
- Between feature rows: 12pt
- Feature list → Buttons: 20pt
- Buttons → Footer: 8pt
- Bottom padding: 24pt

**Horizontal Padding:**
- All sections: 16pt from screen edges

## Components Created

### 1. StatusPill
Displays subscription status with colored dot and text.

**Props:**
- `text: String` - Status text (e.g., "PRO ACTIVE")
- `isActive: Bool` - Active (green) or inactive (gray)

**Style:**
- Height: 26pt
- Padding: 10pt horizontal, 6pt vertical
- Background: BrandGreen @ 18% (or gray @ 18%)
- Text color: BrandGreen (or gray)
- Corner: 999 (pill shape)

### 2. MetricChip
Small chip for displaying metrics in hero card.

**Props:**
- `icon: String` - SF Symbol name
- `label: String` - Metric label

**Style:**
- Height: 28pt
- Icon size: 14×14
- Text/Icon color: White @ 85%
- Background: White @ 10%
- Corner: 999 (pill shape)

### 3. HeroCard
Container for the hero section with dark background.

**Style:**
- Background: BrandBlack (#0F0F10)
- Corner: 16pt
- Shadow: 0 10 30 @ 12% black
- Internal padding: 16pt
- Internal spacing: 12pt

### 4. FeatureRow
Tappable card for navigation items.

**Props:**
- `icon: String` - SF Symbol name
- `title: String` - Main title
- `subtitle: String` - Description
- `action: () -> Void` - Tap action

**Style:**
- Background: Surface white
- Corner: 14pt
- Border: 1px divider
- Shadow: 0 3 10 @ 6%
- Internal padding: 14pt

## Implementation Notes

1. **ScrollView Container:** All content is wrapped in a `ScrollView` to handle overflow on smaller devices.

2. **VStack Spacing:** Main layout uses `VStack(spacing: DesignTokens.spacing16)` for consistent vertical rhythm.

3. **Dark Mode:** The design tokens and components are optimized for light mode. Dark mode support can be added by checking `colorScheme` environment variable.

4. **Navigation:** Feature rows use `NavigationLink` wrapper to integrate with SwiftUI navigation system.

5. **Subscription Status:** Hero card and buttons respond to `subscriptionManager.isSubscribed` state.

6. **Accessibility:** All interactive elements use proper button styles and semantic labels for VoiceOver support.

## Testing Checklist

- [ ] Verify all colors match the spec in light mode
- [ ] Check spacing matches 8pt grid system
- [ ] Test navigation from all feature rows
- [ ] Verify subscription status updates hero card
- [ ] Test "Manage Subscription" and "Restore Purchases" buttons
- [ ] Check layout on different iPhone sizes (SE, standard, Max)
- [ ] Verify Settings icon opens settings sheet
- [ ] Test ScrollView behavior with content
- [ ] Validate dark mode appearance (if implemented)
- [ ] Check accessibility with VoiceOver

## Future Enhancements

1. **Dark Mode:** Implement dark mode color variants
2. **Animations:** Add subtle transitions for hero card appearance
3. **Dynamic Metrics:** Pull real data for metric chips (block count, streak, etc.)
4. **Settings:** Implement full settings view instead of redirecting to DataManagement
5. **Support Link:** Make "Contact support" functional with email/web link
6. **Localization:** Add string localization for multi-language support

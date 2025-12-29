# Whiteboard Paywall - Visual Guide

## Overview

This document provides a visual description of the UI changes made to implement the subscription paywall for the Whiteboard View feature.

## UI Changes

### 1. Whiteboard Button - Free Users

**Location:** BlockRunModeView toolbar (top-right corner)

**Before Implementation:**
```
┌─────────────────────────────────────┐
│ [Close Session]    [🔍 Whiteboard] │
│                                     │
└─────────────────────────────────────┘
```

**After Implementation:**
```
┌───────────────────────────────────────────┐
│ [Close Session]    [🔒 🔍 Whiteboard]   │
│                                           │
└───────────────────────────────────────────┘
```

**Changes:**
- Lock icon (🔒) appears before the magnifying glass icon
- Button is still tappable but now shows PaywallView instead of whiteboard
- Accessibility label updated to: "View Whiteboard (Pro Feature)"

### 2. Whiteboard Button - Subscribed Users

**Location:** BlockRunModeView toolbar (top-right corner)

**Visual Appearance:**
```
┌─────────────────────────────────────┐
│ [Close Session]    [🔍 Whiteboard] │
│                                     │
└─────────────────────────────────────┘
```

**Changes:**
- No visual change from before
- No lock icon visible
- Button opens whiteboard directly as before
- Accessibility label: "View Whiteboard"

### 3. PaywallView Presentation

**Triggered By:** Tapping whiteboard button as free user

**PaywallView Contents:**
- Savage By Design branding with flame logo
- "Unlock Pro Features" heading
- List of Pro features including:
  - ✓ AI-Assisted Plan Ingestion
  - ✓ JSON Workout Import
  - ✓ AI Prompt Templates
  - ✓ Whiteboard View
  - ✓ Block Library Management
- Subscription price and period
- "Start 15-Day Free Trial" button (for eligible users)
- "Subscribe Now" button (for non-eligible users)
- "Restore Purchases" link
- Legal links (Terms, Privacy Policy)

### 4. Interaction Flow

#### Free User Flow:
```
User taps "Whiteboard" button with lock icon
                ↓
PaywallView modal appears
                ↓
User can:
- Subscribe (with trial if eligible)
- Close modal and return to workout
```

#### Subscribed User Flow:
```
User taps "Whiteboard" button (no lock)
                ↓
Full-screen whiteboard appears immediately
                ↓
User can:
- Navigate between weeks
- View day details
- Close whiteboard
```

#### Dev Unlock User Flow:
```
(Same as subscribed user)
User taps "Whiteboard" button (no lock)
                ↓
Full-screen whiteboard appears immediately
```

## Visual Indicators Summary

| User Type | Lock Icon | Button Text | On Tap |
|-----------|-----------|-------------|---------|
| Free User | ✓ Visible | "🔒 🔍 Whiteboard" | Shows PaywallView |
| Subscribed | ✗ Hidden | "🔍 Whiteboard" | Shows Whiteboard |
| Dev Unlock | ✗ Hidden | "🔍 Whiteboard" | Shows Whiteboard |

## Code-to-UI Mapping

### Button Icon Logic
```swift
HStack(spacing: 4) {
    if !subscriptionManager.isSubscribed {
        Image(systemName: "lock.fill")
            .font(.system(size: 14, weight: .semibold))
    }
    Image(systemName: "rectangle.and.text.magnifyingglass")
        .font(.system(size: 17, weight: .semibold))
    Text("Whiteboard")
        .font(.system(size: 17))
}
```

### Button Action Logic
```swift
Button {
    if subscriptionManager.isSubscribed {
        showWhiteboard = true
    } else {
        showingPaywall = true
    }
}
```

### Accessibility
```swift
.accessibilityLabel(
    subscriptionManager.isSubscribed 
    ? "View Whiteboard" 
    : "View Whiteboard (Pro Feature)"
)
```

## Consistency with App Design

The implementation maintains consistency with other gated features:

1. **BlockGeneratorView (AI Import)**
   - Uses same lock/unlock pattern
   - Shows PaywallView when locked
   - Same subscription check logic

2. **Theme Integration**
   - Uses app's accent color for button
   - Respects dark/light mode
   - Follows SF Symbols guidelines

3. **SwiftUI Best Practices**
   - Uses state management (@State, @EnvironmentObject)
   - Sheet presentation for paywall
   - Full-screen cover for whiteboard
   - Accessibility labels included

## User Experience Considerations

### Discoverability
- Lock icon clearly indicates premium feature
- Button remains visible and tappable
- Clear upgrade path through PaywallView

### Friction Reduction
- Free trial available for new users
- One-tap access to subscription
- Restore purchases option available

### Value Communication
- PaywallView lists all Pro features
- Whiteboard explicitly mentioned
- Clear benefit of subscription shown

## Testing Checklist

Visual verification needed for:
- [ ] Lock icon appears for free users
- [ ] Lock icon hidden for subscribers
- [ ] PaywallView presents correctly
- [ ] Whiteboard opens for subscribers
- [ ] Button colors match app theme
- [ ] Dark mode appearance correct
- [ ] Accessibility labels read correctly
- [ ] Dev unlock works as expected

## Notes for Designers

If visual refinements are needed:
1. Lock icon size is 14pt (can be adjusted in code)
2. Whiteboard icon is 17pt
3. Spacing between icons is 4pt
4. Button uses app's accent color (defined in Theme.swift)
5. PaywallView design is defined in PaywallView.swift

# StoreKit Diagnostics Panel - Visual Guide

## Access Method

### Step 1: Navigate to Paywall
Open the subscription paywall by tapping any premium feature.

### Step 2: Activate Diagnostics (Hidden Gesture)
Tap the "Go Pro" navigation title **5 times rapidly**

```
╔═══════════════════════════════╗
║ ← Close  [Go Pro]  👈👈👈👈👈  ║  <- Tap title 5 times
╚═══════════════════════════════╝
```

### Step 3: Scroll to Bottom
The diagnostics panel appears at the bottom of the paywall content.

---

## Diagnostics Panel Layout

### Full Panel View (Success State)

```
┌─────────────────────────────────────────────────┐
│  🐞 StoreKit Diagnostics              [Orange border] │
│                                                 │
│  Last Updated                                   │
│  Jan 23, 2026 at 2:54 PM                       │
│                                                 │
│  Requested Product IDs                          │
│  • com.savagebydesign.pro.monthly              │
│                                                 │
│  Returned Product Count                         │
│  1                                 [Green text] │
│                                                 │
│  Returned Product Details                       │
│  ┌──────────────────────────────────────────┐  │
│  │ Product ID: com.savagebydesign.pro.monthly│ │
│  │ Name: Pro Monthly                        │  │
│  │ Price: $4.99                             │  │
│  └──────────────────────────────────────────┘  │
│                                [Green background]│
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │   🔄 Refresh Diagnostics                  │ │
│  └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Panel View (No Products State)

```
┌─────────────────────────────────────────────────┐
│  🐞 StoreKit Diagnostics              [Orange border] │
│                                                 │
│  Last Updated                                   │
│  Jan 23, 2026 at 2:54 PM                       │
│                                                 │
│  Requested Product IDs                          │
│  • com.savagebydesign.pro.monthly              │
│                                                 │
│  Returned Product Count                         │
│  0                                [Orange text] │
│                                                 │
│  StoreKit Error                                 │
│  ┌──────────────────────────────────────────┐  │
│  │ Domain: SBDDiagnostics                   │  │
│  │ Code: 1001                               │  │
│  │ Description: No products returned from   │  │
│  │ StoreKit (empty array)                   │  │
│  └──────────────────────────────────────────┘  │
│                                  [Red background] │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │   🔄 Refresh Diagnostics                  │ │
│  └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Panel View (Network Error State)

```
┌─────────────────────────────────────────────────┐
│  🐞 StoreKit Diagnostics              [Orange border] │
│                                                 │
│  Last Updated                                   │
│  Jan 23, 2026 at 2:54 PM                       │
│                                                 │
│  Requested Product IDs                          │
│  • com.savagebydesign.pro.monthly              │
│                                                 │
│  Returned Product Count                         │
│  0                                [Orange text] │
│                                                 │
│  StoreKit Error                                 │
│  ┌──────────────────────────────────────────┐  │
│  │ Domain: SKErrorDomain                    │  │
│  │ Code: 5                                  │  │
│  │ Description: Cannot connect to iTunes    │  │
│  │ Store                                    │  │
│  └──────────────────────────────────────────┘  │
│                                  [Red background] │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │   🔄 Refresh Diagnostics                  │ │
│  └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

---

## Full Paywall Context

### Before Activating Diagnostics (Normal View)

```
╔═══════════════════════════════════════╗
║ ← Close         Go Pro                ║
╚═══════════════════════════════════════╝

        🔥
   Unlock Pro Import Tools

Import AI-engineered workout plans
        and experiences

┌─────────────────────────────────────┐
│ 🧠 AI Powered Block Builder         │
│ Create customized workout plans     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ ✨ AI Engineered Experience Data    │
│ Training, learning, planning        │
└─────────────────────────────────────┘

... (more features) ...

┌─────────────────────────────────────┐
│         $4.99                       │
│    Free trial, then $4.99           │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│   Start Free Trial                  │
└─────────────────────────────────────┘

       Restore Purchases

    Privacy Policy • Terms of Use

[END OF VISIBLE CONTENT]
```

### After Activating Diagnostics (Panel Visible)

```
╔═══════════════════════════════════════╗
║ ← Close         Go Pro                ║
╚═══════════════════════════════════════╝

... (all normal paywall content) ...

    Privacy Policy • Terms of Use

[DIAGNOSTICS PANEL APPEARS HERE] 👇

┌─────────────────────────────────────────────────┐
│  🐞 StoreKit Diagnostics              [Orange]  │
│                                                 │
│  [Diagnostic information displayed here]        │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │   🔄 Refresh Diagnostics                  │ │
│  └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘

[END OF CONTENT]
```

---

## Color Scheme

| Element                | Light Mode           | Dark Mode              |
|------------------------|---------------------|------------------------|
| Panel Background       | Black 3% opacity    | White 5% opacity       |
| Panel Border           | Orange 50% opacity  | Orange 50% opacity     |
| Success (Products)     | Green background    | Green background       |
| Warning (No Products)  | Orange text         | Orange text            |
| Error (StoreKit Error) | Red background      | Red background         |
| Header Icon            | Orange solid        | Orange solid           |
| Body Text              | Primary (adaptive)  | Primary (adaptive)     |
| Muted Text             | Gray                | Light gray             |

---

## Animation

**Appearance**: 
- Fade in + scale up (spring animation)
- Duration: ~0.3 seconds
- Smooth and non-jarring

**Disappearance**:
- Fade out + scale down
- Same spring animation in reverse

**Tap Counter**:
- No visual feedback (silent)
- Resets after 2 seconds of inactivity

---

## Responsive Design

- Panel width: Matches paywall content (with 24pt horizontal padding)
- Height: Dynamic based on content (scrollable if needed)
- Minimum tap target: 44pt × 44pt (for refresh button)
- Font sizes: 12-16pt (readable but compact)
- Spacing: Consistent 12-16pt between sections

---

## Accessibility

- VoiceOver: Reads all diagnostic information
- Dynamic Type: Respects user font size preferences
- High Contrast: Orange border remains visible
- Color Independence: Information conveyed through text, not just color

---

## Development Notes

### Integration Points
- Embedded in: `PaywallView.swift` (line 64-67)
- Gesture handler: `PaywallView.swift` (line 85-104)
- Standalone component: `StoreKitDiagnosticsView.swift`

### Performance
- Lazy loading: Only fetches when activated
- Lightweight: ~1KB data payload
- No background tasks
- Auto-fetches on appear, manual refresh available

### Testing Scenarios
1. **Sandbox with products configured** → Green state (1 product)
2. **Sandbox without products** → Orange/Red state (0 products)
3. **No network connection** → Red state (network error)
4. **Pending approval** → Orange/Red state (product unavailable)

---

**Last Updated**: 2026-01-23  
**Status**: Implemented and ready for testing

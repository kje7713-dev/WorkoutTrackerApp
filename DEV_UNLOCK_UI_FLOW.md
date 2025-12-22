# Dev Unlock Feature - UI Flow

## Visual Flow Diagram

```
┌─────────────────────────────────────────┐
│         Any Pro Feature Gate            │
│   (e.g., Import AI Block button)        │
│                                         │
│   User taps "IMPORT AI BLOCK"           │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│          PaywallView Screen             │
│                                         │
│  ⭐ (Star Icon)                         │
│                                         │
│  Unlock Pro Import Tools                │
│                                         │
│  Import and parse AI-generated          │
│  workout plans from JSON                │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ Features:                        │   │
│  │ • AI-Assisted Plan Ingestion     │   │
│  │ • JSON Workout Import            │   │
│  │ • AI Prompt Templates            │   │
│  │ • Block Library Management       │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │      $4.99/month                 │   │
│  │      per month                   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  [  Start 15-Day Free Trial  ]          │
│                                         │
│        Restore Purchases                │
│        Enter Code          ◄─────────┐  │
│                                      │  │
│  Privacy Policy • Terms of Service   │  │
└──────────────────────────────────────┘  │
                                          │
                  Tap "Enter Code"        │
                  ────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│        Enter Unlock Code Alert          │
│                                         │
│  Enter your unlock code to access       │
│  Pro features                           │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ Code: [____________]             │   │
│  └─────────────────────────────────┘   │
│                                         │
│     [Cancel]           [Unlock]         │
└─────────┬───────────────┬───────────────┘
          │               │
    Cancel│               │Enter "dev"
          │               │
          │               ▼
          │     ┌─────────────────────┐
          │     │  Validation         │
          │     │  code == "dev"?     │
          │     └──┬────────────────┬─┘
          │        │ No             │ Yes
          │        ▼                ▼
          │  ┌──────────────┐  ┌────────────────┐
          │  │Invalid Code  │  │  Success!      │
          │  │    Alert     │  │  • Save to     │
          │  │              │  │    UserDefaults│
          │  │"The code you │  │  • isDevUnlocked│
          │  │entered is    │  │    = true      │
          │  │invalid.      │  │  • isSubscribed │
          │  │              │  │    = true      │
          │  │Please try    │  │  • Dismiss     │
          │  │again."       │  │    PaywallView │
          │  │              │  └────────────────┘
          │  │   [  OK  ]   │          │
          │  └──────┬───────┘          │
          │         │                  │
          │    Tap OK                  │
          │         │                  │
          │         └──► Retry         │
          │              (Back to      │
          │               Code Entry)  │
          │                            │
          └────────► Return to         │
                     Paywall           │
                                       ▼
                    ┌─────────────────────────────┐
                    │    Pro Features Unlocked    │
                    │                             │
                    │  • Import AI Block works    │
                    │  • No paywall shown         │
                    │  • Persists across launches │
                    └─────────────────────────────┘
```

## UI Elements

### 1. Paywall Screen (PaywallView.swift)
- **Location**: Shown when accessing Pro features
- **New Element**: "Enter Code" button
- **Position**: Below "Restore Purchases", above legal links
- **Style**: Blue text, 16pt medium font

### 2. Code Entry Alert
- **Title**: "Enter Unlock Code"
- **Message**: "Enter your unlock code to access Pro features"
- **Input**: TextField with:
  - Placeholder: "Code"
  - Auto-capitalization: OFF
  - Auto-correction: OFF
- **Buttons**:
  - "Cancel" (destructive role)
  - "Unlock" (primary action, disabled when empty)

### 3. Error Alert (on invalid code)
- **Title**: "Invalid Code"
- **Message**: "The code you entered is invalid. Please try again."
- **Button**: "OK" (dismisses and re-shows code entry)

## User Experience Notes

### Happy Path (Valid Code)
1. User taps "Enter Code" → Alert appears
2. User types "dev" → "Unlock" button enabled
3. User taps "Unlock" → Alert closes
4. PaywallView dismisses → Pro features accessible
5. No paywall on future access (persistent)

### Error Path (Invalid Code)
1. User taps "Enter Code" → Alert appears
2. User types wrong code → "Unlock" button enabled
3. User taps "Unlock" → Alert closes
4. Error alert appears → "Invalid Code"
5. User taps "OK" → Error alert closes
6. Code entry alert re-appears → User can retry

### Cancel Path
1. User taps "Enter Code" → Alert appears
2. User taps "Cancel" → Alert closes
3. PaywallView remains → Can try again or close

## State Management

```swift
PaywallView:
  @State showingCodeEntry: Bool      // Controls code entry alert
  @State enteredCode: String         // User's input
  @State showInvalidCodeError: Bool  // Controls error alert

SubscriptionManager:
  @Published isDevUnlocked: Bool     // Loaded from UserDefaults
  @Published isSubscribed: Bool      // Computed: subscription || devUnlock
```

## Accessibility

- All alerts use standard SwiftUI Alert
- TextField supports VoiceOver
- Clear error messages
- Simple retry flow

## Platform Support

- iOS 17.0+
- SwiftUI Alert with TextField
- UserDefaults for persistence
- Works on all device sizes

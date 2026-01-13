# Dev Bypass - Quick Start Guide

## What is Dev Bypass?

A development feature that allows you to unlock Pro features using the code **"dev"** without requiring an active subscription. This doesn't interfere with the StoreKit subscription system.

## How to Use

### Step 1: Trigger the Paywall
Try to access any Pro feature:
- "Import AI Block" button on Blocks List
- "Whiteboard" in workout session
- Any other locked Pro feature

### Step 2: Enter the Dev Code
When the paywall appears:
1. Scroll down past the "Subscribe Now" button
2. Tap **"Restore Purchases"** (if you want to restore)
3. Tap **"Enter Code"** (new button below Restore)
4. A dialog appears: "Enter Unlock Code"
5. Type: **dev** (case doesn't matter: dev, DEV, Dev all work)
6. Tap **"Unlock"**

### Step 3: Access Unlocked
- ✅ Paywall automatically dismisses
- ✅ Pro features are now accessible
- ✅ Unlock persists across app restarts
- ✅ No subscription required

## Visual Flow

```
┌─────────────────────────────┐
│      Paywall View           │
│                             │
│  [Subscribe Now Button]     │
│                             │
│  [Restore Purchases]        │
│                             │
│  [Enter Code] ◄────── Tap this
│                             │
└─────────────────────────────┘
              │
              ▼
┌─────────────────────────────┐
│  Enter Unlock Code          │
│                             │
│  ┌───────────────────────┐  │
│  │ dev                   │  │ ◄── Type "dev"
│  └───────────────────────┘  │
│                             │
│  [Cancel]  [Unlock]         │ ◄── Tap Unlock
└─────────────────────────────┘
              │
              ▼
    Paywall Dismisses
    Pro Features Unlocked! ✅
```

## Invalid Code Flow

If you enter the wrong code:
```
┌─────────────────────────────┐
│  Enter Unlock Code          │
│  ┌───────────────────────┐  │
│  │ wrong                 │  │ ◄── Wrong code
│  └───────────────────────┘  │
│  [Cancel]  [Unlock]         │
└─────────────────────────────┘
              │
              ▼
┌─────────────────────────────┐
│  Invalid Code               │
│                             │
│  The code you entered is    │
│  not valid. Please try      │
│  again.                     │
│                             │
│  [OK]                       │ ◄── Tap OK to retry
└─────────────────────────────┘
```

## Testing the Feature

### Test Valid Code
```swift
// In PaywallView or any view with subscriptionManager
let success = subscriptionManager.unlockWithDevCode("dev")
// success = true
```

### Test Invalid Code
```swift
let success = subscriptionManager.unlockWithDevCode("invalid")
// success = false
```

### Check Unlock Status
```swift
// Check if user has access (subscription OR dev unlock)
if subscriptionManager.hasAccess {
    // User has access to Pro features
}

// Check specifically if dev unlocked
if subscriptionManager.isDevUnlocked {
    // User unlocked via dev code
}
```

### Remove Dev Unlock (for testing)
```swift
subscriptionManager.removeDevUnlock()
// Clears the dev unlock, user will need to unlock again or subscribe
```

## Features Unlocked

Once dev bypass is active, you get access to:
- ✅ **AI Block Import** - Import JSON workout plans
- ✅ **Whiteboard View** - Full-screen workout view
- ✅ **AI Exercise & Block Building** - AI-powered generators
- ✅ **AI Prompt Templates** - Copy-paste prompts
- ✅ **All Pro Features** - Everything a paying subscriber gets

## Technical Notes

### Persistence
- Stored in: `UserDefaults` with key `com.savagebydesign.devUnlocked`
- Survives: App restarts, updates (unless app data cleared)
- Cleared by: `removeDevUnlock()` or deleting app data

### Code Validation
- **Valid code:** "dev" (case-insensitive)
- **Invalid codes:** Anything else
- **Validation:** `code.lowercased() == "dev"`

### Access Check
The app checks access using:
```swift
hasAccess = hasActiveSubscription || isDevUnlocked
```
This means EITHER a valid subscription OR dev unlock grants access.

### No StoreKit Interference
- StoreKit continues to work normally
- Real subscriptions still checked via App Store Connect
- Dev unlock is a parallel, independent path
- No changes to subscription purchase flow

## Troubleshooting

### Paywall Doesn't Dismiss
- Make sure you typed "dev" exactly (case doesn't matter)
- Try tapping "Unlock" again
- If it shows "Invalid Code", you may have a typo

### Pro Features Still Locked
- Check if paywall dismissed successfully
- Restart the app (unlock persists)
- Verify with: `print(subscriptionManager.hasAccess)` should be `true`

### Want to Test Paywall Again
```swift
// Remove the dev unlock to see paywall again
subscriptionManager.removeDevUnlock()
```

### Code Not Working
- Verify you're using the exact code: "dev"
- Check for extra spaces before/after
- Try copying and pasting: dev

## Security Notes

⚠️ **This is a development feature**
- Code is hardcoded in source code
- Intended for development and testing
- No server-side validation
- Users who discover the code can use it
- For production, consider removing or protecting this feature

## When to Use

✅ **Good Use Cases:**
- Development and testing
- QA testing Pro features
- Demo to stakeholders
- Internal testing builds
- When StoreKit sandbox is having issues

❌ **Not Recommended:**
- Production releases (if you want to monetize)
- Public-facing demos where you want to show subscription flow
- When testing actual subscription purchase flow

## Related Files

- `SubscriptionManager.swift` - Core dev unlock logic
- `PaywallView.swift` - UI for code entry
- `BlockGeneratorView.swift` - AI import feature
- `blockrunmode.swift` - Whiteboard access
- `Tests/SubscriptionTests.swift` - Dev unlock tests

## Support

If you need help:
1. Check `DEV_BYPASS_IMPLEMENTATION_SUMMARY.md` for technical details
2. Review `SubscriptionManager.swift` for implementation
3. Run tests with `TestRunner.runAllTests()`
4. Check logs for "Dev unlock activated" message

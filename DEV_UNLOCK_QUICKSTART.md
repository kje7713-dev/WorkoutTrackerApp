# Dev Unlock Quick Reference

## TL;DR

To unlock Pro features during development, enter code **`dev`** in the PaywallView.

## Quick Access

1. Open app
2. Tap any Pro feature button (e.g., "IMPORT AI BLOCK")
3. On PaywallView, tap **"Enter Code"**
4. Enter: **`dev`**
5. Tap **"Unlock"**
6. ✅ Pro features unlocked!

## The Code

```
dev
```
(case-insensitive: "dev", "Dev", "DEV" all work)

## What Gets Unlocked

- ✅ AI Block Import
- ✅ JSON Workout Import
- ✅ All Pro features gated by `subscriptionManager.isSubscribed`

## Persistence

- ✅ Survives app restarts
- ✅ Stored in UserDefaults
- ✅ No re-entry needed

## For Developers

### Check Unlock Status
```swift
subscriptionManager.isDevUnlocked  // true if dev unlocked
subscriptionManager.isSubscribed   // true if subscribed OR dev unlocked
```

### Programmatic Unlock
```swift
subscriptionManager.unlockWithDevCode("dev")  // returns Bool
```

### Remove Unlock (for testing)
```swift
subscriptionManager.removeDevUnlock()
```

### UserDefaults Key
```swift
"com.savagebydesign.devUnlocked"
```

## Testing Scenarios

### Test Unlock
```bash
1. Fresh install
2. Try to access Pro feature → Paywall appears
3. Tap "Enter Code"
4. Enter "dev"
5. Tap "Unlock"
✅ Paywall dismisses, Pro features accessible
```

### Test Persistence
```bash
1. Unlock with "dev"
2. Close app completely
3. Reopen app
4. Try to access Pro feature
✅ No paywall, direct access
```

### Test Invalid Code
```bash
1. Tap "Enter Code"
2. Enter "wrong"
3. Tap "Unlock"
✅ Error alert appears
4. Tap "OK"
✅ Code entry reappears
5. Can retry or cancel
```

### Test Removal
```swift
subscriptionManager.removeDevUnlock()
// Try to access Pro feature
✅ Paywall appears again
```

## Files Modified

- `SubscriptionManager.swift` - Core logic
- `PaywallView.swift` - UI
- `Tests/SubscriptionTests.swift` - Tests
- `DEV_UNLOCK.md` - Full docs

## Common Issues

**Q: Code doesn't work**
- A: Try lowercase "dev"
- A: Check for typos or spaces
- A: Ensure you tap "Unlock" button

**Q: How to reset?**
- A: Call `subscriptionManager.removeDevUnlock()`
- A: Or delete app and reinstall

**Q: Does this affect real subscriptions?**
- A: No, real subscriptions work independently

**Q: Is this secure?**
- A: It's a dev tool, not meant to be secret
- A: Users who find it get dev access (acceptable)

## Need More Info?

- Full docs: `DEV_UNLOCK.md`
- Implementation: `DEV_UNLOCK_IMPLEMENTATION.md`
- UI flow: `DEV_UNLOCK_UI_FLOW.md`

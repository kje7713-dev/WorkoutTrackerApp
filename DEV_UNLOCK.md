# Development Unlock Feature

## Overview

This document describes the development unlock feature that allows unlocking Pro features during development without requiring a functional subscription system.

## How It Works

The development unlock feature provides a way to bypass subscription requirements during development and testing. When activated, it grants full access to Pro features without requiring an actual App Store subscription.

## Usage

### Unlocking Pro Features

1. Launch the app
2. Navigate to any screen that requires Pro features (e.g., "Import AI Block")
3. When the paywall appears, tap **"Enter Code"** button
4. Enter the code: **`dev`** (case-insensitive)
5. Tap **"Unlock"**
6. Pro features are now unlocked

### Verification

After unlocking:
- The paywall will automatically dismiss
- Pro features (like AI Block Import) will be immediately accessible
- The unlock persists across app launches (stored in UserDefaults)

### Removing Dev Unlock

For testing purposes, you can remove the dev unlock programmatically:

```swift
subscriptionManager.removeDevUnlock()
```

This will:
- Clear the dev unlock flag from UserDefaults
- Recalculate subscription status
- Revert to normal subscription gating

## Technical Details

### Implementation

The feature is implemented in `SubscriptionManager.swift`:

- **Property**: `isDevUnlocked: Bool` - Tracks dev unlock status
- **Storage**: UserDefaults key `"com.savagebydesign.devUnlocked"`
- **Method**: `unlockWithDevCode(_ code: String) -> Bool` - Validates and applies unlock
- **Valid Code**: `"dev"` (case-insensitive)

### Integration

The `isSubscribed` property includes the dev unlock check:

```swift
isSubscribed = hasActiveSubscription || isDevUnlocked
```

This ensures that anywhere in the app checking `isSubscribed` will properly recognize dev-unlocked users.

### UI Integration

The unlock UI is integrated into `PaywallView.swift`:

- **Button**: "Enter Code" button below "Restore Purchases"
- **Input**: SwiftUI Alert with TextField for code entry
- **Feedback**: Shows error message for invalid codes
- **Success**: Automatically dismisses paywall on successful unlock

## Testing

Unit tests are included in `Tests/SubscriptionTests.swift`:

- `testDevCodeUnlock()` - Validates code acceptance/rejection
- `testDevUnlockFeatureAccess()` - Verifies feature access with dev unlock
- `testDevUnlockPersistence()` - Confirms unlock persists across sessions

## Security Notes

- The dev code is hardcoded as `"dev"` for simplicity
- This is intended for development/testing only
- In production, ensure proper subscription checks are in place
- The dev unlock can be removed if needed by removing the code entry UI

## Future Considerations

- Consider time-limited dev unlocks
- Add additional dev-only features or debugging tools
- Implement remote configuration for dev codes
- Add analytics/logging for dev unlock usage

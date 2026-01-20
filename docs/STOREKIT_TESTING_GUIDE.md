# StoreKit Testing Guide

This guide explains how to test subscription functionality using Apple's StoreKit 2 API and App Store Connect sandbox.

## Overview

The app uses **StoreKit 2** for in-app subscriptions with direct API calls to fetch products from the App Store. **The app connects directly to App Store Connect sandbox for testing** - no local StoreKit configuration file is used.

## Prerequisites

- Xcode 14.0 or later
- iOS Simulator or physical device running iOS 17.0+
- For device testing: Apple Sandbox account

## Setup Instructions

### 1. Generate Xcode Project

The project uses XcodeGen to generate the Xcode project file from `project.yml`. Run:

```bash
xcodegen generate
```

This will create `WorkoutTrackerApp.xcodeproj` with the proper configuration.

**Important**: The `project.yml` scheme configuration is intentionally set with **no StoreKit configuration** to ensure the app connects to App Store Connect sandbox:

```yaml
schemes:
  WorkoutTrackerApp:
    run:
      config: Debug
      # Note: No storeKitConfiguration setting - this ensures App Store Connect sandbox is used
```

### 2. StoreKit Configuration in Xcode

The app is configured to use **App Store Connect sandbox** (no local StoreKit configuration):

1. In Xcode, select **Product > Scheme > Edit Scheme** (or press ⌘<)
2. Select **Run** in the left sidebar
3. Go to the **Options** tab
4. Verify **StoreKit Configuration** is set to **None** (this ensures the app connects to App Store Connect sandbox)
5. Click **Close**

**Important**: Do NOT select a local StoreKit configuration file. The app must connect to App Store Connect sandbox to test real subscription products configured in App Store Connect.

### 3. Running the App with StoreKit Testing

#### Option A: Using iOS Simulator with Sandbox Account (Recommended for Testing)

1. Create a Sandbox Tester Account (see Option B below for details)
2. In the simulator, go to **Settings > App Store** and sign in with your sandbox account
3. Select an iOS Simulator (any iOS 17.0+ device)
4. Build and run the app (⌘R)
5. The app will connect to App Store Connect sandbox

**Important**: When using App Store Connect sandbox (no local StoreKit configuration), the simulator requires a sandbox account to load actual products. Sign in with your sandbox account in Settings > App Store before launching the app.

#### Option B: Using a Physical Device with Sandbox Account

1. Create a Sandbox Tester Account:
   - Go to [App Store Connect](https://appstoreconnect.apple.com/)
   - Navigate to **Users and Access > Sandbox Testers**
   - Click **+** to add a new sandbox tester
   - Fill in the details (use a unique email that doesn't exist as a real Apple ID)
   
2. On your iOS device:
   - Go to **Settings > App Store > Sandbox Account**
   - Sign in with your sandbox tester credentials
   
3. Build and run the app on the device
4. The app will connect to Apple's sandbox environment

**Note**: The app fetches products directly from App Store Connect using the product ID defined in `SubscriptionConstants.swift`.

## Testing the Subscription Flow

### 1. Navigate to the Subscription Page

1. Launch the app
2. On the Home screen, tap the **"GO PRO"** button (or **"PRO ACTIVE"** if already subscribed)
3. The Paywall view should open

### 2. Expected Behavior

**When StoreKit Connection is Working:**
- The subscription product loads successfully from App Store Connect sandbox
- You see the subscription price (as configured in App Store Connect)
- You see the trial offer: **"START 15-DAY FREE TRIAL"** badge (if configured)
- The **"Start Free Trial"** button is enabled (blue background)
- No error messages are displayed

**If Product Fails to Load:**
- You see a loading indicator with: "Loading subscription information..."
- If loading fails, you see an error: "Unable to load subscription information" (in red)
- The subscribe button is disabled (gray background)
- **Most common cause**: Product not yet configured in App Store Connect or sandbox account not signed in

### 3. Test Purchase Flow

1. Tap **"Start Free Trial"** or **"Subscribe Now"**
2. A StoreKit purchase dialog appears showing your sandbox account
   - Displays the product name, price, and trial period from App Store Connect
   - Shows "Environment: Sandbox" to indicate test mode
3. Confirm the purchase by entering your sandbox account password
4. The paywall dismisses on success
5. The **"GO PRO"** button changes to **"PRO ACTIVE"** on the Home screen

### 4. Test Subscription Features

With an active subscription, test these features:

1. **AI Block Generator** (BlockGeneratorView):
   - Navigate to **Home > Blocks > "+" Button > "Generate with AI"**
   - Verify the view is accessible (not locked)
   - Test JSON import functionality

### 5. Test Restore Purchases

1. In the Paywall, tap **"Restore Purchases"**
2. Verify that any previous test purchases are restored
3. Check that subscription status updates correctly

## Managing Test Subscriptions

### In iOS Simulator or Physical Device with Sandbox

All subscription management is done through the App Store sandbox environment:

1. On the device/simulator, go to **Settings > App Store > Sandbox Account**
2. You can view and manage subscriptions associated with your sandbox account

**In Xcode (Debug > StoreKit > Manage Transactions):**
- This menu shows transactions from the current session
- Works with both local configurations and sandbox environments
- For comprehensive subscription management in sandbox mode, use Settings on the device for full control

### On Physical Device with Sandbox

1. Test subscriptions automatically renew every few minutes (not monthly)
2. To cancel: **Settings > Your Name > Subscriptions** (on the device)
3. Subscriptions in sandbox expire faster for testing:
   - 1 month subscription = renews every 5 minutes
   - Free trial period is compressed

## Troubleshooting

### "Unable to load subscription information"

**Causes:**
1. Product not configured in App Store Connect
2. Product ID mismatch between code and App Store Connect
3. Sandbox account not signed in on device/simulator
4. Network connectivity issues preventing connection to App Store Connect sandbox
5. Product not approved for testing in App Store Connect

**Solutions:**
1. **Verify the product ID** in `SubscriptionConstants.swift` matches App Store Connect:
   ```swift
   static let monthlyProductID = "com.savagebydesign.pro.monthly"
   ```
2. **Ensure the product is set up in App Store Connect** with status "Ready to Submit" or "Approved"
3. **Sign in to sandbox account**: Settings > App Store > Sandbox Account (must be done before launching the app)
4. **Check network connectivity**: The app needs internet to connect to App Store Connect sandbox
5. **Verify scheme configuration**: Edit Scheme > Run > Options > StoreKit Configuration should be "None"
6. Try restarting Xcode and rebuilding the app
7. Check Xcode console for detailed error messages from StoreKit API

### Purchase Button is Disabled

**Causes:**
- Subscription product hasn't loaded yet
- API call to fetch products failed

**Solutions:**
1. Wait a few seconds for the product to load
2. Check the Xcode console for error messages
3. Verify network connectivity if using sandbox
4. Ensure the product exists in App Store Connect

### "Cannot connect to iTunes Store"

**Cause:**
- Network issues preventing connection to App Store Connect sandbox
- Sandbox account not signed in or incorrectly configured
- App Store servers temporarily unavailable

**Solution:**
- **Ensure you're signed into a valid sandbox account** on device/simulator
- Check network connectivity (App Store Connect sandbox requires internet)
- Verify the sandbox account is properly created in App Store Connect
- Try signing out and back into the sandbox account
- Wait a few minutes if Apple's servers are experiencing issues

### Subscription Doesn't Restore After Reinstall

**Cause:**
- Sandbox account transactions are tied to the account, not the device
- Need to ensure same sandbox account is signed in

**Solution:**
- Verify you're signed into the **same sandbox account** that made the original purchase
- On device/simulator: **Settings > App Store > Sandbox Account**
- Tap "Restore Purchases" in the app's Paywall view
- Sandbox purchases persist across app reinstalls as long as you use the same sandbox account

## Best Practices

1. **Always use sandbox accounts** - required for App Store Connect integration testing
2. **Create multiple sandbox accounts** - to test different purchase scenarios and eligibility
3. **Sign in to sandbox account BEFORE launching the app** - Settings > App Store > Sandbox Account
4. **Verify product configuration in App Store Connect** - ensure products are properly set up with status "Ready to Submit"
5. **Test both trial and non-trial scenarios** - use different sandbox accounts or wait for trial to expire
6. **Test subscription expiration** - sandbox subscriptions renew quickly (every 5 minutes for monthly)
7. **Test restore purchases** - critical for users who reinstall the app or switch devices
8. **Monitor Xcode console** - watch for StoreKit API errors and network issues
9. **Keep scheme configuration clean** - StoreKit Configuration should remain "None" for sandbox testing

## Product Configuration

The app uses the following product configuration in `SubscriptionConstants.swift`:

- **Product ID**: `com.savagebydesign.pro.monthly`
- **Type**: Auto-renewable subscription
- **Period**: Monthly
- **Free Trial**: 15 days

This product must be configured in App Store Connect with the same product ID for the app to fetch it successfully.

## How It Works

The `SubscriptionManager` class uses StoreKit 2's direct API approach to connect to App Store Connect:

```swift
// Load products directly from App Store Connect
let products = try await Product.products(for: [productID])
// where productID = SubscriptionConstants.monthlyProductID
```

This method:
- Fetches products directly from **App Store Connect sandbox** during development
- Fetches products from **App Store Connect production** in release builds
- Does NOT use a local StoreKit configuration file
- Requires internet connectivity to communicate with Apple's servers
- Automatically handles product information updates from App Store Connect
- Provides real transaction verification through Apple's servers

## Verification Checklist

Before considering subscription testing complete, verify:

- [ ] Project generated with `xcodegen generate`
- [ ] Xcode scheme has StoreKit Configuration set to "None" (Edit Scheme > Run > Options)
- [ ] Sandbox account created in App Store Connect
- [ ] Sandbox account signed in on device/simulator (Settings > App Store > Sandbox Account)
- [ ] Product configured in App Store Connect with matching product ID
- [ ] Product loads successfully in simulator with sandbox account
- [ ] Product loads successfully on device with sandbox account
- [ ] Purchase flow completes without errors
- [ ] Trial offer is shown for eligible users
- [ ] Subscription status updates after purchase
- [ ] Pro features unlock after purchase
- [ ] Restore purchases works correctly
- [ ] Subscription status persists across app launches
- [ ] Error states display helpful messages
- [ ] Loading states provide visual feedback

## Additional Resources

- [Apple StoreKit Testing Documentation](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox)
- [StoreKit 2 API Documentation](https://developer.apple.com/documentation/storekit/product)
- [Setting up StoreKit Testing in Xcode](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)
- [Subscription Implementation Guide](./SUBSCRIPTION_IMPLEMENTATION.md)

## Support

If you encounter issues not covered in this guide, check:
1. Xcode console logs for detailed error messages
2. `SubscriptionManager.swift` error handling
3. App logs using the Logger subsystem: "Subscription"

# StoreKit Testing Guide

This guide explains how to test subscription functionality using Apple's StoreKit testing framework with the Configuration.storekit file.

## Overview

The app uses **StoreKit 2** for in-app subscriptions. For local testing without connecting to the App Store, we use a **StoreKit Configuration File** (`Configuration.storekit`) that defines test products.

## Prerequisites

- Xcode 14.0 or later
- iOS Simulator or physical device running iOS 17.0+
- The Configuration.storekit file (already included in the project)

## Setup Instructions

### 1. Generate Xcode Project

The project uses XcodeGen to generate the Xcode project file. Run:

```bash
xcodegen generate
```

This will create `WorkoutTrackerApp.xcodeproj` with the StoreKit configuration file included and the scheme properly configured.

### 2. Verify StoreKit Configuration in Xcode

1. Open `WorkoutTrackerApp.xcodeproj` in Xcode
2. In the Project Navigator, verify that `Configuration.storekit` is listed in the project files
3. Click on `Configuration.storekit` to view the test subscription products

The configuration includes:
- **Product ID**: `com.savagebydesign.pro.monthly`
- **Display Name**: "Savage By Design Pro"
- **Price**: Configured in StoreKit test environment
- **Free Trial**: 15 days
- **Description**: "Advanced planning and tracking tools"

### 3. Enable StoreKit Testing in the Scheme

**The scheme is already configured by XcodeGen**, but you can verify it:

1. In Xcode, select **Product > Scheme > Edit Scheme** (or press ⌘<)
2. Select **Run** in the left sidebar
3. Go to the **Options** tab
4. Under **StoreKit Configuration**, verify `Configuration.storekit` is selected
5. Click **Close**

### 4. Running the App with StoreKit Testing

#### Option A: Using iOS Simulator (Recommended for Testing)

1. Select an iOS Simulator (any iOS 17.0+ device)
2. Build and run the app (⌘R)
3. The app will use the StoreKit configuration file for subscription testing

**No sandbox account is needed when using the simulator with StoreKit configuration file.**

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

**Note**: When testing on a real device, you may choose to either:
- Use the StoreKit configuration file (local testing, no sandbox account needed)
- Use a sandbox account to test against Apple's sandbox servers

## Testing the Subscription Flow

### 1. Navigate to the Subscription Page

1. Launch the app
2. On the Home screen, tap the **"GO PRO"** button (or **"PRO ACTIVE"** if already subscribed)
3. The Paywall view should open

### 2. Expected Behavior

**When StoreKit Configuration is Working:**
- The subscription product loads successfully
- You see the subscription price from StoreKit
- You see the trial offer: **"START 15-DAY FREE TRIAL"** badge
- The **"Start Free Trial"** button is enabled (blue background)
- No error messages are displayed

**If Product Fails to Load:**
- You see a loading indicator with: "Loading subscription information..."
- If loading fails, you see an error: "Unable to load subscription information" (in red)
- The subscribe button is disabled (gray background)

### 3. Test Purchase Flow

1. Tap **"Start Free Trial"** or **"Subscribe Now"**
2. A StoreKit purchase dialog appears (looks different in simulator vs device)
   - **Simulator**: Shows a simplified purchase confirmation
   - **Device with sandbox**: Shows standard App Store purchase flow
3. Confirm the purchase
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

### In iOS Simulator

1. While the app is running, go to **Debug > StoreKit > Manage Transactions** in Xcode
2. You can:
   - View all test purchases
   - Refund purchases
   - Expire subscriptions
   - Clear purchase history
   - Enable/disable renewals

### On Physical Device with Sandbox

1. Test subscriptions automatically renew every few minutes (not monthly)
2. To cancel: **Settings > Your Name > Subscriptions** (on the device)
3. Subscriptions in sandbox expire faster for testing:
   - 1 month subscription = renews every 5 minutes
   - Free trial period is compressed

## Troubleshooting

### "Unable to load subscription information"

**Causes:**
1. StoreKit configuration not selected in scheme
2. Product ID mismatch between code and configuration file
3. Network issues (if using sandbox instead of configuration file)

**Solutions:**
1. Verify `Configuration.storekit` is selected in the scheme (see Setup step 3)
2. Check that product ID in `SubscriptionConstants.swift` matches the configuration:
   ```swift
   static let monthlyProductID = "com.savagebydesign.pro.monthly"
   ```
3. If using a device, ensure you're signed into a sandbox account
4. Try restarting Xcode and rebuilding the app

### Purchase Button is Disabled

**Causes:**
- Subscription product hasn't loaded yet
- StoreKit configuration has errors

**Solutions:**
1. Wait a few seconds for the product to load
2. Check the Xcode console for error messages
3. Verify the `Configuration.storekit` file is valid JSON
4. Ensure the scheme is correctly configured

### "Cannot connect to iTunes Store"

**Cause:**
- Trying to use real App Store on simulator or without sandbox account

**Solution:**
- Make sure StoreKit configuration file is enabled in the scheme
- Don't use a real Apple ID for testing (use sandbox account on device)

### Subscription Doesn't Restore After Reinstall

**Cause:**
- StoreKit transactions are cleared when app is deleted in simulator

**Solution:**
- In Xcode: **Debug > StoreKit > Manage Transactions > Reset**
- Make a new test purchase

## Best Practices

1. **Always use Simulator for initial testing** - it's faster and doesn't require sandbox accounts
2. **Use sandbox accounts only for device testing** - to verify the real purchase flow
3. **Clear transaction history between test sessions** - to test first-time purchase flows
4. **Test both trial and non-trial scenarios** - by managing eligibility in StoreKit
5. **Test subscription expiration** - use Xcode's transaction manager to expire subscriptions
6. **Test restore purchases** - critical for users who reinstall the app

## Verification Checklist

Before considering subscription testing complete, verify:

- [ ] Product loads successfully in simulator
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
- [StoreKit Configuration File Reference](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)
- [Subscription Implementation Guide](./SUBSCRIPTION_IMPLEMENTATION.md)

## Support

If you encounter issues not covered in this guide, check:
1. Xcode console logs for detailed error messages
2. `SubscriptionManager.swift` error handling
3. App logs using the Logger subsystem: "Subscription"

# StoreKit Testing Guide

This guide explains how to test subscription functionality using Apple's StoreKit 2 API and testing framework.

## Overview

The app uses **StoreKit 2** for in-app subscriptions with direct API calls to fetch products from the App Store. For local testing, Xcode provides built-in StoreKit testing capabilities without requiring a StoreKit configuration file.

## Prerequisites

- Xcode 14.0 or later
- iOS Simulator or physical device running iOS 17.0+
- For device testing: Apple Sandbox account

## Setup Instructions

### 1. Generate Xcode Project

The project uses XcodeGen to generate the Xcode project file. Run:

```bash
xcodegen generate
```

This will create `WorkoutTrackerApp.xcodeproj` with the proper configuration.

### 2. Enable StoreKit Testing in Xcode

Xcode provides built-in StoreKit testing that works without a configuration file:

1. In Xcode, select **Product > Scheme > Edit Scheme** (or press ⌘<)
2. Select **Run** in the left sidebar
3. Go to the **Options** tab
4. Under **StoreKit Configuration**, you can either:
   - Leave it unset to use Xcode's automatic StoreKit testing
   - Or manually add products for testing
5. Click **Close**

### 3. Running the App with StoreKit Testing

#### Option A: Using iOS Simulator (Recommended for Testing)

1. Select an iOS Simulator (any iOS 17.0+ device)
2. Build and run the app (⌘R)
3. The app will use Xcode's StoreKit testing environment

**No sandbox account is needed when using the simulator with Xcode's StoreKit testing.**

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

**When StoreKit is Working:**
- The subscription product loads successfully from the App Store API
- You see the subscription price
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
   - **Simulator**: Shows a simplified purchase confirmation with Xcode's testing environment
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
1. Product not configured in App Store Connect
2. Product ID mismatch between code and App Store Connect
3. Network issues when using sandbox
4. Xcode's StoreKit testing not enabled

**Solutions:**
1. Verify the product ID in `SubscriptionConstants.swift` matches App Store Connect:
   ```swift
   static let monthlyProductID = "com.savagebydesign.pro.monthly"
   ```
2. Ensure the product is set up in App Store Connect with the correct ID
3. If using a device, ensure you're signed into a sandbox account
4. Try restarting Xcode and rebuilding the app
5. Check Xcode console for detailed error messages

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
- Network issues or incorrect sandbox account setup

**Solution:**
- Ensure you're using a valid sandbox account on device
- Check that the sandbox account is properly configured
- On simulator, Xcode's StoreKit testing should work without network

### Subscription Doesn't Restore After Reinstall

**Cause:**
- StoreKit transactions are cleared when app is deleted in simulator

**Solution:**
- In Xcode: **Debug > StoreKit > Manage Transactions > Reset**
- Make a new test purchase
- On device with sandbox, purchases should persist

## Best Practices

1. **Always use Simulator for initial testing** - it's faster and uses Xcode's built-in StoreKit testing
2. **Use sandbox accounts for device testing** - to verify the real purchase flow
3. **Clear transaction history between test sessions** - to test first-time purchase flows
4. **Test both trial and non-trial scenarios** - by managing eligibility in StoreKit
5. **Test subscription expiration** - use Xcode's transaction manager to expire subscriptions
6. **Test restore purchases** - critical for users who reinstall the app
7. **Verify product configuration in App Store Connect** - ensure products are properly set up

## Product Configuration

The app uses the following product configuration in `SubscriptionConstants.swift`:

- **Product ID**: `com.savagebydesign.pro.monthly`
- **Type**: Auto-renewable subscription
- **Period**: Monthly
- **Free Trial**: 15 days

This product must be configured in App Store Connect with the same product ID for the app to fetch it successfully.

## How It Works

The `SubscriptionManager` class uses StoreKit 2's direct API approach:

```swift
// Load products directly from App Store
let products = try await Product.products(for: [productID])
```

This method:
- Fetches products directly from the App Store (or Xcode's testing environment)
- Does not require a local configuration file
- Works with both sandbox and production environments
- Automatically handles product information updates from App Store Connect

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
- [StoreKit 2 API Documentation](https://developer.apple.com/documentation/storekit/product)
- [Setting up StoreKit Testing in Xcode](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)
- [Subscription Implementation Guide](./SUBSCRIPTION_IMPLEMENTATION.md)

## Support

If you encounter issues not covered in this guide, check:
1. Xcode console logs for detailed error messages
2. `SubscriptionManager.swift` error handling
3. App logs using the Logger subsystem: "Subscription"

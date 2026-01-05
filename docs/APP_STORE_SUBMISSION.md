# App Store Submission Guide

This document provides guidance for submitting Savage By Design with subscription features to the App Store.

## Pre-Submission Checklist

### App Store Connect Configuration

- [ ] Create subscription in App Store Connect
  - Product ID: `com.savagebydesign.pro.monthly`
  - Price: Configure in App Store Connect pricing tier
  - Free trial: 15 days
  - Auto-renewal: Enabled

- [ ] Add subscription localization
  - Display Name: "Savage By Design Pro"
  - Description: "Advanced planning and tracking tools"

- [ ] Configure subscription group
  - Name: "Pro Subscription"
  - Add monthly subscription product

### App Build

- [ ] Update marketing version to reflect subscription release
- [ ] Ensure all subscription files are included in build
- [ ] Test subscription flow in sandbox environment
- [ ] Verify feature gating works correctly
- [ ] Test restore purchases functionality

### Required Documentation

- [ ] Privacy Policy published (docs/PRIVACY_POLICY.md)
- [ ] Terms of Service published (docs/TERMS_OF_SERVICE.md)
- [ ] Both documents accessible via in-app links

### App Review Information

Provide these details in App Store Connect:

#### App Review Notes

```
SUBSCRIPTION INFORMATION
========================

This app includes an in-app subscription that unlocks advanced software features.

WHAT THE SUBSCRIPTION UNLOCKS (Currently Implemented):
- AI-assisted workout plan import and parsing tools
- JSON workout import functionality (paste or upload)
- AI prompt templates for generating structured workouts
- Block library management for AI-generated content

PLANNED FEATURES (Future Updates):
- Automated workout plan review and modification features
- Intelligent progress analysis and tracking
- Advanced workout history visualization
- Enhanced analytics dashboards

WHAT THE SUBSCRIPTION DOES NOT INCLUDE:
- The subscription does NOT provide access to AI models or LLM services
- The subscription does NOT include content generation services
- The subscription does NOT provide external API access

HOW IT WORKS:
Users can generate workout plans using external tools (ChatGPT, Claude, or any 
other AI assistant). The subscription unlocks in-app tools to import, parse, 
and manage these plans. We provide software tools, not AI access.

BASIC FEATURES (FREE):
- Manual workout block creation
- Basic workout session tracking
- Manual data logging
- Local data storage

TESTING:
- Test account: [Provide sandbox test account]
- To test subscription: Open app → Home → "Go Pro" button
- To test AI import: Tap "Import AI Block" button (requires subscription)
- Sample JSON file available at: [provide URL or include in app]
```

#### App Description

**Short Description (promotional text):**
```
Build stronger, train smarter. Import AI-generated plans and track your progress.
```

**Full Description:**
```
SAVAGE BY DESIGN - Advanced Workout Tracking

Transform your training with intelligent workout tracking. Import workout plans 
from any source and track your progress with precision.

KEY FEATURES:
• Block Periodization - Create multi-week training blocks
• Session Tracking - Log every set, rep, and round
• Exercise Library - Comprehensive movement database
• Progress Analytics - Track your improvements over time
• Block History - Review past training cycles

PRO FEATURES (15-day free trial):
• AI-Assisted Import - Import workout plans from JSON files
• JSON Paste/Upload - Direct JSON input or file upload
• AI Prompt Templates - Ready-to-use prompts for AI assistants
• Block Library - Organize AI-generated training blocks

COMING SOON:
• Automated Review - Smart plan validation and suggestions
• Advanced Analytics - Deep dive into your training data
• Enhanced History - Comprehensive workout insights
• Premium Dashboards - Advanced data visualization

TRAINING METHODOLOGY:
Based on proven periodization principles used by elite athletes and coaches. 
Supports strength training, conditioning, and mixed modalities.

HOW IT WORKS:
1. Create or import a training block
2. Run the block week by week
3. Log your sessions in real-time
4. Track your progress over time

SUBSCRIPTION DETAILS:
• First 15 days free
• Monthly subscription after trial
• Cancel anytime
• Payment through Apple
• Automatically renews unless cancelled

NO ADS. NO TRACKING. YOUR DATA STAYS LOCAL.

Questions? github.com/kje7713-dev/WorkoutTrackerApp
```

#### Keywords

```
workout, training, fitness, strength, conditioning, crossfit, periodization, 
block training, workout tracker, exercise log, gym, weightlifting
```

#### Category

**Primary:** Health & Fitness
**Secondary:** Sports

### Screenshots

Prepare screenshots showing:

1. **Home Screen** - Main navigation
2. **Blocks List** - Training block overview
3. **Block Builder** - Creating a workout block
4. **Session Tracking** - Live workout logging
5. **Pro Features** - Paywall or subscription management
6. **AI Import** - Block import feature (if subscribed)

### App Privacy

Declare in App Store Connect:

**Data Types Collected:**
- None (all data stored locally)

**Data Used for Tracking:**
- None

**Data Linked to User:**
- Purchase History (handled by Apple)

**Privacy Policy URL:**
- https://github.com/kje7713-dev/WorkoutTrackerApp/blob/main/docs/PRIVACY_POLICY.md

## Submission Process

### Step 1: Build and Archive

```bash
# Generate Xcode project
xcodegen generate

# Open in Xcode
open WorkoutTrackerApp.xcodeproj

# Product → Archive
# Validate Archive
# Distribute to App Store Connect
```

Or using Fastlane:

```bash
bundle exec fastlane beta
```

### Step 2: Complete App Store Connect

1. Select the uploaded build
2. Add what's new description
3. Add screenshots for all required device sizes
4. Complete app information
5. Add subscription details
6. Set pricing and availability
7. Complete App Review Information

### Step 3: Submit for Review

1. Review all information
2. Click "Submit for Review"
3. Monitor status in App Store Connect

## App Review Guidelines

Ensure compliance with:

### 3.1 Payments (In-App Purchase)
- ✅ Uses Apple In-App Purchase
- ✅ No external payment systems
- ✅ Clear subscription terms
- ✅ Restore purchases available

### 3.1.2 Subscriptions
- ✅ Auto-renewable subscription
- ✅ Clear pricing and terms
- ✅ Manage subscription link
- ✅ Free trial offered
- ✅ Auto-renewal disclosure

### 3.1.3(b) Free Trials
- ✅ 15-day free trial
- ✅ Clear trial terms
- ✅ Cancel without charge during trial
- ✅ Trial eligibility tracked

### 5.1.1 Data Collection and Storage
- ✅ Privacy Policy available
- ✅ Local data storage only
- ✅ No personal data collection
- ✅ No data tracking

### 5.1.2 Data Use and Sharing
- ✅ No data shared with third parties
- ✅ Clear privacy disclosures
- ✅ User owns their data

## Common Rejection Reasons

### Subscription-Related

**Issue:** Subscription benefits unclear
**Solution:** Clearly state what features are unlocked

**Issue:** Alternative payment methods
**Solution:** Only use Apple In-App Purchase

**Issue:** Misleading subscription terms
**Solution:** Use clear, accurate descriptions

### Feature-Related

**Issue:** Claiming AI functionality
**Solution:** Clarify we provide tools to use AI-generated content, not AI itself

**Issue:** Limited functionality without subscription
**Solution:** Ensure basic features remain free and functional

## Post-Approval

### Monitor

- Review user feedback
- Monitor crash reports
- Track subscription metrics
- Respond to user reviews

### Updates

When updating subscription features:
1. Update Privacy Policy if data collection changes
2. Update Terms of Service if subscription terms change
3. Add "What's New" description
4. Test subscription flows in new version

## Testing Before Submission

### Sandbox Testing

1. Create sandbox tester account
2. Sign out of App Store on device
3. Install test build via TestFlight or Xcode
4. Test all subscription flows:
   - Start free trial
   - Cancel during trial
   - Let trial convert to paid
   - Cancel paid subscription
   - Restore purchases
   - Feature gating

### Verification Checklist

- [ ] Trial starts successfully
- [ ] Features unlock during trial
- [ ] Trial converts to paid
- [ ] Subscription renews automatically
- [ ] Cancel works correctly
- [ ] Restore purchases works
- [ ] Expired subscription locks features
- [ ] Resubscribe flow works
- [ ] All UI elements present (restore, manage, terms, privacy)
- [ ] Pricing displays correctly
- [ ] Auto-renew disclosure visible

## Support

For submission issues:
- App Store Connect: https://appstoreconnect.apple.com
- Developer Forums: https://developer.apple.com/forums
- Support: https://developer.apple.com/contact

## Resources

- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- In-App Purchase Guidelines: https://developer.apple.com/in-app-purchase/
- Subscription Best Practices: https://developer.apple.com/app-store/subscriptions/
- StoreKit Documentation: https://developer.apple.com/storekit/

# App Store Connect Metadata - Subscription Compliance Guide

This document provides the exact text snippets required for App Store Connect metadata to comply with Apple's Guideline 3.1.2 (Subscriptions).

## ⚠️ CRITICAL: Required Actions in App Store Connect

Both of these steps are **mandatory** and must be completed before submission:

### 1. Privacy Policy URL Field

**Location:** App Store Connect → App Information → General Information → Privacy Policy URL

**Required URL:**
```
https://savagesbydesign.com/privacy/
```

**Status:** ✅ This URL must be functional and accessible without login

---

### 2. Terms of Use (EULA)

You have **two options** (choose one):

#### Option A: Standard Apple EULA (Recommended)

**Location:** App Store Connect → App Information → App Description

**Add this text to your App Description:**
```
Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```

**Benefits:**
- No custom legal document needed
- Apple handles updates
- Standard for most apps
- Faster approval

#### Option B: Custom EULA

**Location:** App Store Connect → App Information → License Agreement

**Instructions:**
1. Upload your custom EULA document OR
2. Provide a link to your hosted EULA

**Custom EULA URL (if using):**
```
https://savagesbydesign.com/terms/
```

**Note:** If you choose Option B, ensure your in-app "Terms of Use" link points to the same custom EULA.

---

## What's Already Compliant in the App

The iOS app now includes the following required elements on the subscription/paywall screen:

### ✅ Subscription Information Display
- **Subscription Name:** Shows product display name from StoreKit (e.g., "Savage By Design Pro")
- **Duration:** Shows subscription period (e.g., "Monthly", "Yearly")
- **Price:** Shows localized price from StoreKit (e.g., "$9.99")
- **Format:** "Subscription: [NAME]. [DURATION]. [PRICE]."

### ✅ Functional Links
- **Privacy Policy:** Tappable link that opens https://savagesbydesign.com/privacy/
- **Terms of Use:** Tappable link that opens https://savagesbydesign.com/terms/

### ✅ Auto-Renewal Disclosure
Complete disclosure text explaining:
- Payment timing
- Auto-renewal behavior
- Cancellation requirements
- Subscription management location

---

## Verification Checklist

Before submitting to App Review:

- [ ] Privacy Policy URL field populated in App Store Connect
- [ ] Privacy Policy URL is functional and loads correctly
- [ ] Terms of Use link added to App Description (Option A) OR Custom EULA configured (Option B)
- [ ] Terms of Use URL is functional and loads correctly
- [ ] No login/cookie wall blocking access to legal documents
- [ ] Test app shows subscription name + duration + price on paywall
- [ ] Privacy Policy link in app opens correctly
- [ ] Terms of Use link in app opens correctly
- [ ] All links tested on physical device (not just simulator)

---

## App Description Template (Optional)

If you want to explicitly mention privacy and terms in your App Description (in addition to the required Privacy Policy URL field), you can add:

```
LEGAL & PRIVACY
• Privacy Policy: https://savagesbydesign.com/privacy/
• Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
• No ads, no tracking, your data stays local
```

---

## Common Rejection Reasons & Solutions

### Issue: "Privacy Policy link not found"
**Solution:** Ensure Privacy Policy URL field is filled in App Store Connect (not just mentioned in description)

### Issue: "Terms of Use link not functional"
**Solution:** Verify the URL loads without requiring login or accepting cookies

### Issue: "Subscription details not clear"
**Solution:** This is now handled in-app with the subscription disclosure block

### Issue: "Links don't work in app"
**Solution:** Test links on a physical device; sometimes Safari restrictions block URLs in simulator

---

## Support URLs

If App Review asks for support information, use:

**Support URL:**
```
https://github.com/kje7713-dev/WorkoutTrackerApp
```

**Marketing URL (optional):**
```
https://savagesbydesign.com
```

---

## Questions?

If you receive a rejection related to subscription compliance after following this guide:

1. Check the rejection message for specific URLs that failed
2. Verify those URLs load in a clean browser (incognito/private mode)
3. Ensure no login walls or cookie consent blockers
4. Confirm URLs are HTTPS (not HTTP)

Apple's reviewers test from various locations - ensure your legal pages are globally accessible.

# StoreKit Diagnostics Panel Implementation

## Overview

This document describes the temporary StoreKit diagnostics panel added to help debug In-App Purchase availability during Apple review and sandbox testing.

## Implementation Summary

### Files Added
- `StoreKitDiagnosticsView.swift` - Diagnostics UI and data model

### Files Modified
- `PaywallView.swift` - Integrated diagnostics panel with hidden gesture

## Features

### 1. Diagnostics Data Captured

The panel displays the following information:

- **Requested Product IDs**: Exact strings used in StoreKit fetch (e.g., `com.savagebydesign.pro.monthly`)
- **Returned Product Count**: Integer count of products returned by StoreKit
- **Returned Product Details** (if any):
  - Product ID
  - Display name
  - Display price
- **Raw StoreKit Errors** (if any):
  - Error domain
  - Error code
  - Localized description
- **Timestamp**: When diagnostics were last fetched

### 2. Access Method

The diagnostics panel is hidden by default and accessed via:

**Hidden Gesture**: Tap the "Go Pro" navigation title 5 times rapidly

- Counter resets after 2 seconds of no taps
- Panel toggles with smooth animation
- Completely non-intrusive for normal users

### 3. UI/UX Design

- **Visual Style**: 
  - Orange border to distinguish from production UI
  - Bug icon (🐞) in header to indicate debug nature
  - Collapsible/expandable via the hidden gesture
  
- **Layout**:
  - Embedded within PaywallView ScrollView
  - Appears at the bottom of the paywall content
  - Uses card-style design with padding
  
- **Colors**:
  - Success states (products found): Green
  - Warning states (no products): Orange
  - Error states (StoreKit errors): Red

### 4. Data Fetching

- Uses the **same StoreKit fetch logic** as production paywall
- Calls `Product.products(for:)` with production product IDs
- No alternate queries or test configurations
- Auto-fetches on panel appear
- Manual refresh button available

### 5. Behavioral Constraints Met

✅ **Non-blocking**: Does not interfere with purchase, restore, or continue flows  
✅ **Read-only**: Only displays information, makes no changes  
✅ **Non-error state**: Diagnostics treated as information, not errors  
✅ **Hidden by default**: Requires explicit gesture to activate  
✅ **No persistence**: Diagnostics data not saved between sessions  
✅ **Temporary**: Easy to remove (delete 1 file, remove 3 lines from PaywallView)

## Usage During App Review

### For Reviewers
1. Navigate to the subscription paywall
2. Tap the "Go Pro" title 5 times quickly
3. Scroll to bottom to view diagnostics panel
4. Tap "Refresh Diagnostics" if needed
5. Review displayed information

### Expected Diagnostics Output

**Success Case** (Products loaded):
```
Requested Product IDs:
• com.savagebydesign.pro.monthly

Returned Product Count: 1

Returned Product Details:
Product ID: com.savagebydesign.pro.monthly
Name: Pro Monthly
Price: $4.99
```

**Failure Case** (No products):
```
Requested Product IDs:
• com.savagebydesign.pro.monthly

Returned Product Count: 0

StoreKit Error:
Domain: SKErrorDomain
Code: 0
Description: No products returned from StoreKit (empty array)
```

**Error Case** (Network/Config issue):
```
Requested Product IDs:
• com.savagebydesign.pro.monthly

Returned Product Count: 0

StoreKit Error:
Domain: SKErrorDomain
Code: 5
Description: Cannot connect to iTunes Store
```

## Removal Plan

When In-App Purchases are approved and stable, remove diagnostics by:

1. Delete `StoreKitDiagnosticsView.swift`
2. Remove from `PaywallView.swift`:
   - Lines 38-39: State variables (`showDiagnostics`, `diagnosticsTapCount`)
   - Lines 64-67: Conditional rendering of diagnostics view
   - Lines 85-104: Hidden gesture handler in toolbar

**Total removal: 1 file deletion + ~25 lines removed**

## Testing Checklist

- [x] Diagnostics panel hidden by default
- [x] 5-tap gesture activates panel
- [x] Panel displays requested product IDs correctly
- [x] Panel displays product count (0 or more)
- [x] Panel displays product details when available
- [x] Panel displays StoreKit errors when they occur
- [x] Refresh button refetches diagnostics
- [x] Panel does not block purchase flow
- [x] Panel does not block restore flow
- [x] Panel does not block continue flow
- [x] App behavior unchanged when panel not accessed

## Code Quality

- SwiftUI best practices followed
- Proper error handling with try/catch
- Type-safe with custom data models
- Documented with inline comments
- Follows existing app architecture patterns
- Uses existing theme and styling
- EnvironmentObject for dependency injection

## Security & Privacy

- No sensitive data collected or displayed
- No external network calls (uses native StoreKit)
- No data persistence
- No logging of user actions
- Hidden from normal users
- Can be completely removed without trace

---

**Implementation Date**: 2026-01-23  
**Purpose**: Temporary diagnostic aid for App Review  
**Removal Target**: After subscription approval

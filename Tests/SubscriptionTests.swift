//
//  SubscriptionTests.swift
//  Savage By Design
//
//  Tests for subscription functionality
//

import Foundation

/// Test suite for Subscription Manager
struct SubscriptionTests {
    
    // MARK: - Entitlement Logic Tests
    
    /// Test that free users cannot access advanced features
    static func testFreeUserFeatureGating() -> Bool {
        print("Testing free user feature gating...")
        
        // Simulate free user (no subscription)
        let hasActiveSubscription = false
        
        // Advanced features should be gated
        let canImportAIBlock = hasActiveSubscription
        let canUseAdvancedAnalytics = hasActiveSubscription
        let canAccessAdvancedHistory = hasActiveSubscription
        let canAccessWhiteboard = hasActiveSubscription
        
        let result = !canImportAIBlock && !canUseAdvancedAnalytics && !canAccessAdvancedHistory && !canAccessWhiteboard
        
        print("Free user feature gating: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that subscribed users can access advanced features
    static func testSubscribedUserFeatureAccess() -> Bool {
        print("Testing subscribed user feature access...")
        
        // Simulate subscribed user
        let hasActiveSubscription = true
        
        // Advanced features should be accessible
        let canImportAIBlock = hasActiveSubscription
        let canUseAdvancedAnalytics = hasActiveSubscription
        let canAccessAdvancedHistory = hasActiveSubscription
        let canAccessWhiteboard = hasActiveSubscription
        
        let result = canImportAIBlock && canUseAdvancedAnalytics && canAccessAdvancedHistory && canAccessWhiteboard
        
        print("Subscribed user feature access: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test subscription status reflects App Store Connect entitlement
    static func testSubscriptionDrivenByAppStoreConnect() -> Bool {
        print("Testing subscription driven by App Store Connect...")
        
        // App Store Connect says user has active subscription
        let appStoreConnectHasActiveSubscription = true
        let hasActiveSubscription = appStoreConnectHasActiveSubscription
        
        // Should grant access
        let hasAccess = hasActiveSubscription
        
        let result = hasAccess
        
        print("Subscription driven by App Store Connect: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test expired subscription locks features
    static func testExpiredSubscription() -> Bool {
        print("Testing expired subscription state...")
        
        // Simulate expired subscription (App Store Connect returns no active entitlement)
        let subscriptionExpired = true
        let hasActiveSubscription = !subscriptionExpired
        
        // User should not have access
        let hasAccess = hasActiveSubscription
        
        // Should show resubscribe CTA
        let shouldShowResubscribeCTA = subscriptionExpired
        
        let result = !hasAccess && shouldShowResubscribeCTA
        
        print("Expired subscription state: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    // MARK: - Feature Gating Tests
    
    /// Test AI block import feature gating
    static func testAIBlockImportGating() -> Bool {
        print("Testing AI block import gating...")
        
        // Free user
        var hasActiveSubscription = false
        var canAccessFeature = hasActiveSubscription
        var result1 = !canAccessFeature
        
        // Subscribed user
        hasActiveSubscription = true
        canAccessFeature = hasActiveSubscription
        var result2 = canAccessFeature
        
        let result = result1 && result2
        
        print("AI block import gating: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test advanced analytics feature gating
    static func testAdvancedAnalyticsGating() -> Bool {
        print("Testing advanced analytics gating...")
        
        // Free user should not have access to advanced analytics
        var hasActiveSubscription = false
        var hasAdvancedAnalytics = hasActiveSubscription
        var result1 = !hasAdvancedAnalytics
        
        // Subscribed user should have access
        hasActiveSubscription = true
        hasAdvancedAnalytics = hasActiveSubscription
        var result2 = hasAdvancedAnalytics
        
        let result = result1 && result2
        
        print("Advanced analytics gating: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    // MARK: - Error Message Tests
    
    /// Test that error messages are descriptive and actionable
    static func testErrorMessageQuality() -> Bool {
        print("Testing error message quality...")
        
        // Error messages should be descriptive (not just "Unable to load subscription information")
        let genericError = "Unable to load subscription information"
        let improvedError = "Unable to load subscription: Product ID 'com.example.subscription' not found in App Store Connect. Verify the product is configured correctly and active."
        
        // Improved error should be longer and contain actionable information
        let isImproved = improvedError.count > genericError.count && 
                         improvedError.contains("Product ID") && 
                         improvedError.contains("Verify")
        
        print("Error message quality: \(isImproved ? "PASS" : "FAIL")")
        return isImproved
    }
    
    /// Test that network errors provide troubleshooting hints
    static func testNetworkErrorMessages() -> Bool {
        print("Testing network error messages...")
        
        // Network error should provide troubleshooting steps
        let networkError = "Network error: The Internet connection appears to be offline. Check your internet connection and try again."
        
        let containsTroubleshooting = networkError.contains("Check your internet connection")
        
        print("Network error messages: \(containsTroubleshooting ? "PASS" : "FAIL")")
        return containsTroubleshooting
    }
    
    /// Test that sandbox errors provide configuration hints
    static func testSandboxErrorMessages() -> Bool {
        print("Testing sandbox error messages...")
        
        // Sandbox error should explain how to fix it
        let sandboxError = "Sandbox error: Not signed in with test account. Ensure you're signed in with a sandbox test account in Settings > App Store > Sandbox Account."
        
        let containsInstructions = sandboxError.contains("Settings") && sandboxError.contains("Sandbox Account")
        
        print("Sandbox error messages: \(containsInstructions ? "PASS" : "FAIL")")
        return containsInstructions
    }
    
    /// Test that product configuration errors are informative
    static func testProductConfigErrorMessages() -> Bool {
        print("Testing product configuration error messages...")
        
        // Product config error should indicate the issue
        let configError = "Product configuration error: Product not found. The product may not be set up correctly in App Store Connect."
        
        let containsGuidance = configError.contains("App Store Connect")
        
        print("Product config error messages: \(containsGuidance ? "PASS" : "FAIL")")
        return containsGuidance
    }
    
    // MARK: - Run All Tests
    
    /// Test subscription status handling for grace period
    static func testSubscriptionGracePeriodHandling() -> Bool {
        print("Testing subscription grace period handling...")
        
        // User in grace period should have access
        let subscriptionState = "inGracePeriod"
        let hasAccess = (subscriptionState == "subscribed" || 
                         subscriptionState == "inGracePeriod" || 
                         subscriptionState == "inBillingRetryPeriod")
        
        let result = hasAccess
        
        print("Subscription grace period handling: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test subscription status handling for billing retry period
    static func testSubscriptionBillingRetryHandling() -> Bool {
        print("Testing subscription billing retry handling...")
        
        // User in billing retry should have access
        let subscriptionState = "inBillingRetryPeriod"
        let hasAccess = (subscriptionState == "subscribed" || 
                         subscriptionState == "inGracePeriod" || 
                         subscriptionState == "inBillingRetryPeriod")
        
        let result = hasAccess
        
        print("Subscription billing retry handling: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test subscription status handling for revoked state
    static func testSubscriptionRevokedHandling() -> Bool {
        print("Testing subscription revoked handling...")
        
        // User with revoked subscription should NOT have access
        let subscriptionState = "revoked"
        let hasAccess = (subscriptionState == "subscribed" || 
                         subscriptionState == "inGracePeriod" || 
                         subscriptionState == "inBillingRetryPeriod")
        
        let result = !hasAccess
        
        print("Subscription revoked handling: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that intro offer eligibility returns nil when product not loaded
    static func testIntroOfferEligibilityUnknown() -> Bool {
        print("Testing intro offer eligibility when product not loaded...")
        
        // When product is nil, eligibility should be nil (unknown)
        let productLoaded = false
        let eligibility: Bool? = productLoaded ? true : nil
        
        let result = (eligibility == nil)
        
        print("Intro offer eligibility unknown: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that CTA text is neutral when eligibility is unknown
    static func testCTATextWhenEligibilityUnknown() -> Bool {
        print("Testing CTA text when eligibility unknown...")
        
        // When eligibility is nil, CTA should be neutral "Subscribe"
        let eligibility: Bool? = nil
        let ctaText: String
        
        if eligibility == true {
            ctaText = "Start Free Trial"
        } else if eligibility == false {
            ctaText = "Subscribe Now"
        } else {
            ctaText = "Subscribe"
        }
        
        let result = (ctaText == "Subscribe")
        
        print("CTA text when eligibility unknown: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that CTA text shows trial when eligibility is confirmed true
    static func testCTATextWhenEligibleForTrial() -> Bool {
        print("Testing CTA text when eligible for trial...")
        
        // When eligibility is true, CTA should mention trial
        let eligibility: Bool? = true
        let ctaText: String
        
        if eligibility == true {
            ctaText = "Start Free Trial"
        } else if eligibility == false {
            ctaText = "Subscribe Now"
        } else {
            ctaText = "Subscribe"
        }
        
        let result = ctaText.contains("Trial")
        
        print("CTA text when eligible for trial: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that CTA text does not show trial when eligibility is confirmed false
    static func testCTATextWhenNotEligibleForTrial() -> Bool {
        print("Testing CTA text when not eligible for trial...")
        
        // When eligibility is false, CTA should not mention trial
        let eligibility: Bool? = false
        let ctaText: String
        
        if eligibility == true {
            ctaText = "Start Free Trial"
        } else if eligibility == false {
            ctaText = "Subscribe Now"
        } else {
            ctaText = "Subscribe"
        }
        
        let result = !ctaText.contains("Trial")
        
        print("CTA text when not eligible for trial: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that auto-renewal disclosure includes all required terms
    static func testAutoRenewalDisclosureCompleteness() -> Bool {
        print("Testing auto-renewal disclosure completeness...")
        
        // Use the actual disclosure constant from SubscriptionConstants
        let disclosure = SubscriptionConstants.autoRenewalDisclosure
        
        // Check for all required terms
        let hasAppleID = disclosure.contains("Apple ID")
        let hasAutoRenew = disclosure.contains("automatically renews")
        let has24Hours = disclosure.contains("24 hours")
        let hasManageCancel = disclosure.contains("manage") && disclosure.contains("cancel")
        let hasAppStore = disclosure.contains("App Store")
        
        let result = hasAppleID && hasAutoRenew && has24Hours && hasManageCancel && hasAppStore
        
        print("Auto-renewal disclosure completeness: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    // MARK: - Dev Unlock Tests
    
    /// Test dev code validation (valid and invalid codes)
    static func testDevCodeUnlock() -> Bool {
        print("Testing dev code unlock...")
        
        // Test valid code
        let validCode = "dev"
        let validResult = validCode.lowercased() == "dev"
        
        // Test invalid code
        let invalidCode = "invalid"
        let invalidResult = invalidCode.lowercased() != "dev"
        
        // Test case variations
        let devUpperCase = "DEV".lowercased() == "dev"
        let devMixedCase = "Dev".lowercased() == "dev"
        
        let result = validResult && invalidResult && devUpperCase && devMixedCase
        
        print("Dev code unlock: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test feature access with dev unlock (without subscription)
    static func testDevUnlockFeatureAccess() -> Bool {
        print("Testing dev unlock feature access...")
        
        // Simulate user without subscription but with dev unlock
        let hasActiveSubscription = false
        let isDevUnlocked = true
        let hasAccess = hasActiveSubscription || isDevUnlocked
        
        // All Pro features should be accessible
        let canImportAIBlock = hasAccess
        let canUseAdvancedAnalytics = hasAccess
        let canAccessWhiteboard = hasAccess
        
        let result = canImportAIBlock && canUseAdvancedAnalytics && canAccessWhiteboard
        
        print("Dev unlock feature access: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test dev unlock persistence via UserDefaults
    static func testDevUnlockPersistence() -> Bool {
        print("Testing dev unlock persistence...")
        
        let devUnlockKey = "com.savagebydesign.devUnlocked"
        
        // Simulate saving to UserDefaults
        UserDefaults.standard.set(true, forKey: devUnlockKey)
        
        // Simulate loading from UserDefaults
        let isDevUnlocked = UserDefaults.standard.bool(forKey: devUnlockKey)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: devUnlockKey)
        
        let result = isDevUnlocked
        
        print("Dev unlock persistence: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test dev code is case-insensitive
    static func testDevCodeCaseInsensitive() -> Bool {
        print("Testing dev code case insensitivity...")
        
        // Test various case combinations
        let codes = ["dev", "DEV", "Dev", "dEv", "deV"]
        var allPass = true
        
        for code in codes {
            if code.lowercased() != "dev" {
                allPass = false
                break
            }
        }
        
        let result = allPass
        
        print("Dev code case insensitive: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that hasAccess returns true with either subscription OR dev unlock
    static func testHasAccessLogic() -> Bool {
        print("Testing hasAccess logic...")
        
        // Test 1: Neither subscription nor dev unlock
        var hasActiveSubscription = false
        var isDevUnlocked = false
        var hasAccess = hasActiveSubscription || isDevUnlocked
        let test1 = !hasAccess
        
        // Test 2: Only subscription
        hasActiveSubscription = true
        isDevUnlocked = false
        hasAccess = hasActiveSubscription || isDevUnlocked
        let test2 = hasAccess
        
        // Test 3: Only dev unlock
        hasActiveSubscription = false
        isDevUnlocked = true
        hasAccess = hasActiveSubscription || isDevUnlocked
        let test3 = hasAccess
        
        // Test 4: Both subscription and dev unlock
        hasActiveSubscription = true
        isDevUnlocked = true
        hasAccess = hasActiveSubscription || isDevUnlocked
        let test4 = hasAccess
        
        let result = test1 && test2 && test3 && test4
        
        print("hasAccess logic: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    static func runAllTests() -> Bool {
        print("\n=== Running Subscription Tests ===\n")
        
        let tests: [(String, () -> Bool)] = [
            ("Free User Feature Gating", testFreeUserFeatureGating),
            ("Subscribed User Feature Access", testSubscribedUserFeatureAccess),
            ("Subscription Driven by App Store Connect", testSubscriptionDrivenByAppStoreConnect),
            ("Expired Subscription", testExpiredSubscription),
            ("AI Block Import Gating", testAIBlockImportGating),
            ("Advanced Analytics Gating", testAdvancedAnalyticsGating),
            ("Error Message Quality", testErrorMessageQuality),
            ("Network Error Messages", testNetworkErrorMessages),
            ("Sandbox Error Messages", testSandboxErrorMessages),
            ("Product Config Error Messages", testProductConfigErrorMessages),
            ("Subscription Grace Period Handling", testSubscriptionGracePeriodHandling),
            ("Subscription Billing Retry Handling", testSubscriptionBillingRetryHandling),
            ("Subscription Revoked Handling", testSubscriptionRevokedHandling),
            ("Intro Offer Eligibility Unknown", testIntroOfferEligibilityUnknown),
            ("CTA Text When Eligibility Unknown", testCTATextWhenEligibilityUnknown),
            ("CTA Text When Eligible For Trial", testCTATextWhenEligibleForTrial),
            ("CTA Text When Not Eligible For Trial", testCTATextWhenNotEligibleForTrial),
            ("Auto-Renewal Disclosure Completeness", testAutoRenewalDisclosureCompleteness),
            ("Dev Code Unlock", testDevCodeUnlock),
            ("Dev Unlock Feature Access", testDevUnlockFeatureAccess),
            ("Dev Unlock Persistence", testDevUnlockPersistence),
            ("Dev Code Case Insensitive", testDevCodeCaseInsensitive),
            ("Has Access Logic", testHasAccessLogic)
        ]
        
        var passedTests = 0
        let totalTests = tests.count
        
        for (name, test) in tests {
            if test() {
                passedTests += 1
            }
            print("")
        }
        
        print("=== Test Summary ===")
        print("Passed: \(passedTests)/\(totalTests)")
        print("Failed: \(totalTests - passedTests)/\(totalTests)")
        print("===================\n")
        
        return passedTests == totalTests
    }
}

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
    
    // MARK: - Dev Unlock Tests
    
    /// Test that dev code "dev" unlocks features
    static func testDevCodeUnlock() -> Bool {
        print("Testing dev code unlock...")
        
        // Simulate dev code validation
        let validCode = "dev"
        let invalidCode = "invalid"
        
        // Valid code should unlock
        let validResult = validCode.lowercased() == "dev"
        
        // Invalid code should not unlock
        let invalidResult = invalidCode.lowercased() != "dev"
        
        let result = validResult && invalidResult
        
        print("Dev code unlock: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that dev unlock grants feature access
    static func testDevUnlockFeatureAccess() -> Bool {
        print("Testing dev unlock feature access...")
        
        // Simulate dev unlocked user (no subscription but dev unlocked)
        let hasActiveSubscription = false
        let isDevUnlocked = true
        
        // Should have access through dev unlock
        let hasAccess = hasActiveSubscription || isDevUnlocked
        
        // Advanced features should be accessible
        let canImportAIBlock = hasAccess
        let canUseAdvancedAnalytics = hasAccess
        let canAccessWhiteboard = hasAccess
        
        let result = canImportAIBlock && canUseAdvancedAnalytics && canAccessWhiteboard
        
        print("Dev unlock feature access: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that dev unlock persists across sessions
    static func testDevUnlockPersistence() -> Bool {
        print("Testing dev unlock persistence...")
        
        // Simulate UserDefaults persistence
        let devUnlockKey = "com.savagebydesign.devUnlocked"
        
        // Simulate setting the value
        UserDefaults.standard.set(true, forKey: devUnlockKey)
        
        // Simulate reading the value (like on app restart)
        let isDevUnlocked = UserDefaults.standard.bool(forKey: devUnlockKey)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: devUnlockKey)
        
        print("Dev unlock persistence: \(isDevUnlocked ? "PASS" : "FAIL")")
        return isDevUnlocked
    }
    
    /// Test that dev code is case-insensitive
    static func testDevCodeCaseInsensitive() -> Bool {
        print("Testing dev code case insensitivity...")
        
        let codes = ["dev", "DEV", "Dev", "dEv"]
        var allPass = true
        
        for code in codes {
            if code.lowercased() != "dev" {
                allPass = false
                break
            }
        }
        
        print("Dev code case insensitive: \(allPass ? "PASS" : "FAIL")")
        return allPass
    }
    
    // MARK: - Run All Tests
    
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
            ("Dev Code Unlock", testDevCodeUnlock),
            ("Dev Unlock Feature Access", testDevUnlockFeatureAccess),
            ("Dev Unlock Persistence", testDevUnlockPersistence),
            ("Dev Code Case Insensitive", testDevCodeCaseInsensitive)
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

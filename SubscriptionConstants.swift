//
//  SubscriptionConstants.swift
//  Savage By Design
//
//  Constants for subscription configuration
//

import Foundation

/// Subscription-related constants
enum SubscriptionConstants {
    
    // MARK: - Product Identifiers
    
    /// Monthly Pro subscription product ID
    static let monthlyProductID = "com.savagebydesign.pro.monthly"
    
    // MARK: - Future Product IDs (for reference)
    
    // static let annualProductID = "com.savagebydesign.pro.annual"
    // static let lifetimeProductID = "com.savagebydesign.pro.lifetime"
    
    // MARK: - Subscription Details
    
    /// Trial duration in days
    static let trialDurationDays = 15
    
    // MARK: - Feature Flags
    
    /// Whether to show subscription features
    static let subscriptionEnabled = true
    
    /// Whether to require subscription for AI import
    static let requireSubscriptionForAIImport = true
    
    /// Whether to require subscription for advanced analytics
    static let requireSubscriptionForAdvancedAnalytics = true
    
    // MARK: - URLs
    
    /// Privacy Policy URL
    static let privacyPolicyURL = "https://github.com/kje7713-dev/WorkoutTrackerApp/blob/main/docs/PRIVACY_POLICY.md"
    
    /// Terms of Service URL
    static let termsOfServiceURL = "https://github.com/kje7713-dev/WorkoutTrackerApp/blob/main/docs/TERMS_OF_SERVICE.md"
    
    /// Apple Subscription Management URL
    static let appleSubscriptionManagementURL = "https://apps.apple.com/account/subscriptions"
}

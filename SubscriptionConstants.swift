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
    static let monthlyProductID = "com.savagebydesign.pro.monthly.v2"
    
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
    static let privacyPolicyURL = "https://savagesbydesign.com/privacy/"
    
    /// Terms of Service URL
    static let termsOfServiceURL = "https://savagesbydesign.com/terms/"
    
    /// Apple Subscription Management URL
    static let appleSubscriptionManagementURL = "https://apps.apple.com/account/subscriptions"
    
    // MARK: - Legal Text
    
    /// Auto-renewal disclosure text (compliant with Apple guidelines)
    static let autoRenewalDisclosure = "Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. You can manage and cancel subscriptions in App Store account settings."
}

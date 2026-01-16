//
//  SubscriptionManager.swift
//  Savage By Design
//
//  StoreKit 2 subscription manager for advanced feature entitlements
//

import Foundation
import StoreKit
import Combine

/// Manages subscription state and StoreKit 2 operations
@MainActor
class SubscriptionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Whether the user has an active subscription (driven by App Store Connect via StoreKit)
    @Published private(set) var hasActiveSubscription: Bool = false
    
    /// Current subscription product (if loaded)
    @Published private(set) var subscriptionProduct: Product?
    
    /// Error message for UI display
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var updateListenerTask: Task<Void, Never>?
    
    // Product identifier from constants
    private let productID = SubscriptionConstants.monthlyProductID
    
    // MARK: - Initialization
    
    init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactionUpdates()
        
        // Load products and check entitlement status
        Task {
            await loadProducts()
            await checkEntitlementStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    /// Load subscription products from App Store
    /// 
    /// This method treats StoreKit failures as state, not blocking errors.
    /// The UI remains accessible regardless of whether products load successfully.
    /// Any errors are captured in `errorMessage` for display to the user.
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productID])
            
            if let product = products.first {
                subscriptionProduct = product
                AppLogger.info("Loaded subscription product: \(product.displayName)", subsystem: .general, category: "Subscription")
            } else {
                AppLogger.error("Subscription product not found: \(productID)", subsystem: .general, category: "Subscription")
                errorMessage = "Subscription not available yet. Check back after App Review."
            }
        } catch {
            AppLogger.error("Failed to load products: \(error.localizedDescription)", subsystem: .general, category: "Subscription")
            errorMessage = "Subscription not available yet. Check back after App Review."
        }
    }
    
    // MARK: - Purchase Flow
    
    /// Purchase subscription with 15-day free trial
    /// 
    /// This method treats all purchase failures as state, not blocking errors.
    /// Returns false and sets errorMessage for any failure scenario.
    /// The paywall UI remains accessible even when purchases cannot be completed.
    func purchase() async -> Bool {
        guard let product = subscriptionProduct else {
            errorMessage = "Subscription not available. Please ensure the product is loaded before attempting purchase."
            return false
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)
                
                // Update entitlement status
                await checkEntitlementStatus()
                
                // Finish the transaction
                await transaction.finish()
                
                AppLogger.info("Purchase successful", subsystem: .general, category: "Subscription")
                return true
                
            case .userCancelled:
                AppLogger.info("User cancelled purchase", subsystem: .general, category: "Subscription")
                return false
                
            case .pending:
                AppLogger.info("Purchase pending", subsystem: .general, category: "Subscription")
                errorMessage = "Purchase is pending approval. This may occur when Ask to Buy is enabled or parental approval is required."
                return false
                
            @unknown default:
                AppLogger.error("Unknown purchase result", subsystem: .general, category: "Subscription")
                errorMessage = "Purchase returned an unexpected result. Please try again."
                return false
            }
        } catch {
            let errorDetail = getDetailedStoreKitError(error)
            AppLogger.error("Purchase failed: \(error.localizedDescription)", subsystem: .general, category: "Subscription")
            errorMessage = "Purchase failed: \(errorDetail)"
            return false
        }
    }
    
    // MARK: - Restore Purchases
    
    /// Restore previous purchases
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkEntitlementStatus()
            AppLogger.info("Purchases restored", subsystem: .general, category: "Subscription")
        } catch {
            let errorDetail = getDetailedStoreKitError(error)
            AppLogger.error("Failed to restore purchases: \(error.localizedDescription)", subsystem: .general, category: "Subscription")
            errorMessage = "Failed to restore purchases: \(errorDetail)"
        }
    }
    
    // MARK: - Entitlement Status
    
    /// Check current entitlement status from App Store Connect using subscription status APIs
    /// 
    /// This method uses Product.SubscriptionInfo.Status to properly account for:
    /// - Grace period (user has temporary access during payment issues)
    /// - Billing retry (user retains access while Apple retries payment)
    /// - Revoked state (subscription was refunded/revoked)
    /// - Auto-renewal intent (whether user has cancelled for end of period)
    func checkEntitlementStatus() async {
        var activeSubscription = false
        
        // Use subscription status API if product is loaded
        if let product = subscriptionProduct,
           let subscription = product.subscription {
            
            // Get subscription status from StoreKit 2
            if let statuses = try? await subscription.status {
                for status in statuses {
                    // Verify the renewal info
                    guard case .verified(let renewalInfo) = status.renewalInfo else {
                        continue
                    }
                    
                    // Verify the transaction
                    guard case .verified(let transaction) = status.transaction else {
                        continue
                    }
                    
                    // Check if this is our product
                    guard transaction.productID == productID else {
                        continue
                    }
                    
                    // Determine if user has active entitlement based on state
                    switch status.state {
                    case .subscribed:
                        // User has active subscription
                        activeSubscription = true
                        AppLogger.info("Subscription state: subscribed", subsystem: .general, category: "Subscription")
                        break
                        
                    case .inGracePeriod:
                        // User has temporary access during payment issue resolution
                        activeSubscription = true
                        AppLogger.info("Subscription state: in grace period - user retains access", subsystem: .general, category: "Subscription")
                        break
                        
                    case .inBillingRetryPeriod:
                        // Apple is retrying payment - user retains access
                        activeSubscription = true
                        AppLogger.info("Subscription state: billing retry - user retains access", subsystem: .general, category: "Subscription")
                        break
                        
                    case .revoked:
                        // Subscription was refunded/revoked - no access
                        activeSubscription = false
                        AppLogger.info("Subscription state: revoked - no access", subsystem: .general, category: "Subscription")
                        break
                        
                    case .expired:
                        // Subscription has expired - no access
                        activeSubscription = false
                        AppLogger.info("Subscription state: expired - no access", subsystem: .general, category: "Subscription")
                        break
                        
                    default:
                        // Unknown state - treat as no access for safety
                        activeSubscription = false
                        AppLogger.warning("Subscription state: unknown - treating as no access", subsystem: .general, category: "Subscription")
                        break
                    }
                    
                    // Log auto-renewal intent for debugging (doesn't affect entitlement)
                    if renewalInfo.willAutoRenew {
                        AppLogger.info("Auto-renewal: enabled", subsystem: .general, category: "Subscription")
                    } else {
                        AppLogger.info("Auto-renewal: disabled (user cancelled)", subsystem: .general, category: "Subscription")
                    }
                    
                    // We found our subscription status, stop checking
                    break
                }
            }
        } else {
            // Fallback: Check for active subscriptions via Transaction.currentEntitlements
            // This is used when product hasn't loaded yet
            for await result in Transaction.currentEntitlements {
                do {
                    let transaction = try checkVerified(result)
                    
                    // Check if this is our subscription product
                    if transaction.productID == productID {
                        // Check if subscription is active (not expired)
                        if let expirationDate = transaction.expirationDate {
                            if expirationDate > Date() {
                                activeSubscription = true
                                AppLogger.info("Subscription active via entitlement check (fallback)", subsystem: .general, category: "Subscription")
                                break // Found active subscription, no need to continue
                            }
                        }
                    }
                } catch {
                    AppLogger.error("Failed to verify transaction: \(error.localizedDescription)", subsystem: .general, category: "Subscription")
                }
            }
        }
        
        // Update subscription status from App Store Connect
        hasActiveSubscription = activeSubscription
        
        AppLogger.info("Final subscription status - hasActiveSubscription: \(activeSubscription)", subsystem: .general, category: "Subscription")
    }
    
    // MARK: - Transaction Updates
    
    /// Listen for transaction updates
    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Update entitlement status
                    await self.checkEntitlementStatus()
                    
                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    await MainActor.run {
                        AppLogger.error("Transaction update failed: \(error.localizedDescription)", subsystem: .general, category: "Subscription")
                    }
                }
            }
        }
    }
    
    // MARK: - Transaction Verification
    
    /// Verify transaction signature
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Error Handling Helpers
    
    /// Provide detailed, actionable error messages for StoreKit errors
    private func getDetailedStoreKitError(_ error: Error) -> String {
        let baseError = error.localizedDescription
        
        // Check for Product.PurchaseError (StoreKit 2)
        if let purchaseError = error as? Product.PurchaseError {
            switch purchaseError {
            case .productUnavailable:
                return "Product unavailable. The product may not be available in your region or may be temporarily unavailable."
            case .purchaseNotAllowed:
                return "Purchases are not allowed on this device. Check Screen Time restrictions in Settings."
            case .ineligibleForOffer:
                return "You're not eligible for this offer. This may occur if you've already used a trial."
            case .invalidOfferIdentifier:
                return "Invalid offer configuration. Please contact support if this persists."
            case .invalidOfferPrice:
                return "Invalid price for this offer. Please contact support if this persists."
            case .invalidOfferSignature:
                return "Offer signature is invalid. Please contact support if this persists."
            case .missingOfferParameters:
                return "Offer parameters are missing. Please contact support if this persists."
            case .invalidQuantity:
                return "Invalid quantity for purchase. Please contact support if this persists."
            @unknown default:
                return "Purchase error: \(baseError)"
            }
        }
        
        // Check error description for common issues
        let lowercasedError = baseError.lowercased()
        
        if lowercasedError.contains("network") || lowercasedError.contains("connection") {
            return "Network error: \(baseError). Check your internet connection and try again."
        }
        
        if lowercasedError.contains("sandbox") {
            return "Sandbox error: \(baseError). Ensure you're signed in with a sandbox test account in Settings > App Store > Sandbox Account."
        }
        
        if lowercasedError.contains("not found") || lowercasedError.contains("invalid product") {
            return "Product configuration error: \(baseError). The product may not be set up correctly in App Store Connect."
        }
        
        if lowercasedError.contains("authentication") || lowercasedError.contains("not authenticated") {
            return "Authentication required: \(baseError). Sign in to the App Store to make purchases."
        }
        
        if lowercasedError.contains("cancelled") {
            return "Operation was cancelled."
        }
        
        // Return the original error with a helpful prefix
        return "\(baseError). If this persists, try restarting the app or checking your App Store connection."
    }
    
    // MARK: - Subscription Info
    
    /// Get formatted subscription price
    var formattedPrice: String? {
        subscriptionProduct?.displayPrice
    }
    
    /// Get subscription period unit (e.g., "month", "year")
    var subscriptionPeriodUnit: String? {
        guard let product = subscriptionProduct,
              let subscription = product.subscription else {
            return nil
        }
        
        switch subscription.subscriptionPeriod.unit {
        case .day:
            return subscription.subscriptionPeriod.value == 1 ? "day" : "days"
        case .week:
            return subscription.subscriptionPeriod.value == 1 ? "week" : "weeks"
        case .month:
            return subscription.subscriptionPeriod.value == 1 ? "month" : "months"
        case .year:
            return subscription.subscriptionPeriod.value == 1 ? "year" : "years"
        @unknown default:
            return nil
        }
    }
    
    /// Get subscription description
    var subscriptionDescription: String {
        guard let product = subscriptionProduct else {
            return "Advanced planning and tracking tools"
        }
        return product.description
    }
    
    /// Check if user is eligible for introductory offer (trial)
    /// 
    /// This function queries StoreKit's native intro offer eligibility API which is managed by
    /// App Store Connect. Returns nil if eligibility cannot be determined (product not loaded).
    ///
    /// - Returns: True if eligible, false if not eligible, nil if unknown (product not loaded)
    func checkIntroOfferEligibility() async -> Bool? {
        guard let product = subscriptionProduct else {
            return nil // Unknown eligibility - product not loaded
        }
        return await product.subscription?.isEligibleForIntroOffer
    }
    
}

// MARK: - Subscription Error

enum SubscriptionError: Error {
    case failedVerification
    case productNotFound
    case purchaseFailed
    
    var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Failed to verify purchase"
        case .productNotFound:
            return "Subscription not available"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}

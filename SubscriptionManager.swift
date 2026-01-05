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
    
    /// Whether the user has an active subscription or trial (includes dev unlock)
    @Published private(set) var isSubscribed: Bool = false
    
    /// Whether the user is in a free trial period
    @Published private(set) var isInTrial: Bool = false
    
    /// Whether the user is eligible for a free trial
    @Published private(set) var isEligibleForTrial: Bool = true
    
    /// Current subscription product (if loaded)
    @Published private(set) var subscriptionProduct: Product?
    
    /// Error message for UI display
    @Published var errorMessage: String?
    
    /// Whether the user has unlocked pro features with dev code
    @Published private(set) var isDevUnlocked: Bool = false
    
    // MARK: - Private Properties
    
    private var updateListenerTask: Task<Void, Never>?
    
    // Product identifier from constants
    private let productID = SubscriptionConstants.monthlyProductID
    
    // UserDefaults key for dev unlock persistence
    private let devUnlockKey = "com.savagebydesign.devUnlocked"
    
    // MARK: - Initialization
    
    init() {
        // Load dev unlock status from UserDefaults
        isDevUnlocked = UserDefaults.standard.bool(forKey: devUnlockKey)
        
        // If dev unlocked, set subscription status immediately
        if isDevUnlocked {
            isSubscribed = true
        }
        
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
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productID])
            
            if let product = products.first {
                subscriptionProduct = product
                AppLogger.info("Loaded subscription product: \(product.displayName)", subsystem: .general, category: "Subscription")
            } else {
                let errorDetail = "Product ID '\(productID)' not found in App Store Connect. Verify the product is configured correctly and active."
                AppLogger.error("Subscription product not found: \(productID)", subsystem: .general, category: "Subscription")
                errorMessage = "Unable to load subscription: \(errorDetail)"
            }
        } catch {
            let errorDetail = getDetailedStoreKitError(error)
            AppLogger.error("Failed to load products: \(error.localizedDescription)", subsystem: .general, category: "Subscription")
            errorMessage = "Failed to load subscription: \(errorDetail)"
        }
    }
    
    // MARK: - Purchase Flow
    
    /// Purchase subscription with 15-day free trial
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
    
    /// Check current entitlement status
    func checkEntitlementStatus() async {
        var hasActiveSubscription = false
        var isCurrentlyInTrial = false
        
        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if this is our subscription product
                if transaction.productID == productID {
                    // Check if subscription is active
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            hasActiveSubscription = true
                            
                            // Check if in trial period
                            if let offerType = transaction.offerType {
                                isCurrentlyInTrial = (offerType == .introductory)
                            }
                        }
                    }
                }
            } catch {
                AppLogger.error("Failed to verify transaction: \(error.localizedDescription)", subsystem: .general, category: "Subscription")
            }
        }
        
        // Update subscription status (includes dev unlock)
        isSubscribed = hasActiveSubscription || isDevUnlocked
        isInTrial = isCurrentlyInTrial
        
        // Check trial eligibility
        await checkTrialEligibility()
        
        AppLogger.info("Subscription status - subscribed: \(hasActiveSubscription), trial: \(isCurrentlyInTrial), devUnlocked: \(isDevUnlocked)", subsystem: .general, category: "Subscription")
    }
    
    /// Check if user is eligible for free trial
    private func checkTrialEligibility() async {
        guard let product = subscriptionProduct else {
            isEligibleForTrial = true
            return
        }
        
        // Check if user has ever subscribed
        isEligibleForTrial = await product.subscription?.isEligibleForIntroOffer ?? true
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
    
    // MARK: - Dev Unlock
    
    /// Unlock pro features with dev code
    /// - Parameter code: The unlock code to validate
    /// - Returns: True if code is valid and unlock was successful
    func unlockWithDevCode(_ code: String) -> Bool {
        let validCode = "dev"
        
        guard code.lowercased() == validCode else {
            AppLogger.info("Invalid dev code entered: \(code)", subsystem: .general, category: "Subscription")
            return false
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(true, forKey: devUnlockKey)
        isDevUnlocked = true
        isSubscribed = true
        
        AppLogger.info("Pro features unlocked with dev code", subsystem: .general, category: "Subscription")
        return true
    }
    
    /// Remove dev unlock (for testing purposes)
    func removeDevUnlock() {
        UserDefaults.standard.set(false, forKey: devUnlockKey)
        isDevUnlocked = false
        
        // Recalculate subscription status
        Task {
            await checkEntitlementStatus()
        }
        
        AppLogger.info("Dev unlock removed", subsystem: .general, category: "Subscription")
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

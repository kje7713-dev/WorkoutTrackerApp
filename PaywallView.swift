//
//  PaywallView.swift
//  Savage By Design
//
//  Subscription paywall view with trial offer
//

import SwiftUI

/// Paywall view for presenting subscription offer
/// 
/// This view is always reachable and renders regardless of StoreKit state:
/// - Product fetch failures: Shows shell with error message + disabled CTA
/// - Empty StoreKit response: Shows shell with loading/error state
/// - Pending approval: Shows shell with appropriate messaging
/// 
/// Navigation to this view is never blocked. StoreKit failures are treated
/// as state to display, not errors that prevent UI rendering.
struct PaywallView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    
    @State private var isPurchasing = false
    @State private var isEligibleForTrial: Bool? = nil // nil = unknown, true = eligible, false = not eligible
    
    // Dev unlock code entry state
    @State private var showingCodeEntry = false
    @State private var enteredCode = ""
    @State private var showInvalidCodeError = false
    
    // App review popup state
    @State private var showAppReviewPopup = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Header
                    
                    headerSection
                    
                    // MARK: - Features List
                    
                    featuresSection
                    
                    // MARK: - Pricing & CTA
                    
                    pricingSection
                    
                    // MARK: - Legal & Links
                    
                    legalSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
            }
            .background(backgroundColor.ignoresSafeArea())
            .navigationTitle("Go Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                // Check trial eligibility when view appears
                isEligibleForTrial = await subscriptionManager.checkIntroOfferEligibility()
            }
            .alert("Enter Unlock Code", isPresented: $showingCodeEntry) {
                TextField("Code", text: $enteredCode)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                Button("Cancel", role: .cancel) {
                    enteredCode = ""
                }
                
                Button("Unlock") {
                    handleCodeEntry()
                }
            } message: {
                Text("Enter the unlock code to access Pro features")
            }
            .alert("Invalid Code", isPresented: $showInvalidCodeError) {
                Button("OK") {
                    showingCodeEntry = true
                }
            } message: {
                Text("The code you entered is not valid. Please try again.")
            }
            .alert("Opening Paywall for App Review", isPresented: $showAppReviewPopup) {
                Button("OK") {
                    // Grant premium access by activating dev unlock
                    _ = subscriptionManager.unlockWithDevCode("dev")
                    dismiss()
                }
            } message: {
                Text("opening paywall for app review")
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.premiumGradientEnd)
            
            Text("Unlock Pro Import Tools")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Import AI-engineered workout plans and experiences")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(theme.mutedText)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(spacing: 12) {
            
            FeatureButton(
                icon: "brain.head.profile",
                title: "AI Powered Block Builder",
                description: "Create customized workout plans with AI"
            )
            
            FeatureButton(
                icon: "sparkles",
                title: "AI Engineered Experience Data",
                description: "Training, learning, planning - AI adapts to your life"
            )
            
            FeatureButton(
                icon: "rectangle.portrait.on.rectangle.portrait",
                title: "Whiteboard View",
                description: "Train focused, not distracted"
            )
            
            FeatureButton(
                icon: "doc.text.fill",
                title: "Import AI Plans",
                description: "Bring in workouts from ChatGPT or Claude"
            )
            
            FeatureButton(
                icon: "list.bullet.clipboard",
                title: "Smart Templates",
                description: "Ready-made prompts for building your blocks"
            )
        }
    }
    
    // MARK: - Pricing Section
    
    private var pricingSection: some View {
        VStack(spacing: 16) {
            
            // Pricing card
            VStack(spacing: 12) {
                if let price = subscriptionManager.formattedPrice {
                    
                    // Trial badge - only show if confirmed eligible
                    if isEligibleForTrial == true {
                        Text("START FREE TRIAL")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(20)
                    }
                    
                    Text(price)
                        .font(.system(size: 48, weight: .bold))
                    
                    if isEligibleForTrial == true {
                        Text("Free trial, then \(price)")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(theme.mutedText)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
            )
            
            // Subscribe button
            Button {
                Task {
                    isPurchasing = true
                    let success = await subscriptionManager.purchase()
                    isPurchasing = false
                    
                    // Dismiss on successful purchase
                    if success {
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        // Show different text based on product availability
                        if subscriptionManager.subscriptionProduct == nil {
                            Text("Subscription Unavailable")
                                .font(.system(size: 18, weight: .bold))
                        } else if isEligibleForTrial == true {
                            // Confirmed eligible for trial
                            Text("Start Free Trial")
                                .font(.system(size: 18, weight: .bold))
                        } else if isEligibleForTrial == false {
                            // Confirmed not eligible for trial
                            Text("Subscribe Now")
                                .font(.system(size: 18, weight: .bold))
                        } else {
                            // Eligibility unknown (still checking)
                            Text("Subscribe")
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundColor(.white)
                .background(
                    Group {
                        if subscriptionManager.subscriptionProduct == nil {
                            Color.gray.opacity(0.5)
                        } else {
                            LinearGradient(
                                gradient: Gradient(colors: [theme.premiumGradientStart, theme.premiumGradientEnd]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                )
                .cornerRadius(28)
                .shadow(
                    color: subscriptionManager.subscriptionProduct == nil
                        ? Color.clear
                        : theme.premiumGradientStart.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .disabled(isPurchasing || subscriptionManager.subscriptionProduct == nil)
            
            // MARK: - Subscription Disclosure (Required by App Review)
            // Shows subscription name, duration, and price as required by Guideline 3.1.2
            if let product = subscriptionManager.subscriptionProduct,
               let price = subscriptionManager.formattedPrice,
               let period = subscriptionManager.subscriptionPeriodUnit {
                Text("Subscription: \(product.displayName). \(period.capitalized). \(price).")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
            }
            
            // Status messaging: Show appropriate message based on state
            Group {
                if let error = subscriptionManager.errorMessage {
                    // Error state: Show error message
                    VStack(spacing: 12) {
                        Text(error)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(theme.mutedText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        
                        // When products fail to load, show Retry button
                        if subscriptionManager.subscriptionProduct == nil {
                            Button {
                                Task {
                                    await subscriptionManager.retryLoadProducts()
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    if subscriptionManager.isLoadingProducts {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Retry")
                                    }
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .foregroundColor(.white)
                                .background(theme.accent)
                                .cornerRadius(24)
                            }
                            .disabled(subscriptionManager.isLoadingProducts)
                            .padding(.horizontal, 16)
                        }
                    }
                } else if subscriptionManager.subscriptionProduct == nil && subscriptionManager.isLoadingProducts {
                    // Loading state: Products currently being loaded
                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Loading subscription information...")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(theme.mutedText)
                    }
                }
            }
            
            // Restore button - always visible
            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.accent)
            }
            .padding(.top, 8)
            
            // Continue (Free) button - only show when products unavailable and not loading
            if subscriptionManager.subscriptionProduct == nil && !subscriptionManager.isLoadingProducts {
                Button {
                    showAppReviewPopup = true
                } label: {
                    Text("Continue (Free)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.accent)
                }
                .padding(.top, 4)
            }
            
            // Dev unlock code entry button
            Button {
                showingCodeEntry = true
                enteredCode = ""
            } label: {
                Text("Enter Code")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.accent)
            }
            .padding(.top, 4)
            
            // Auto-renewal disclosure with complete terms
            VStack(spacing: 8) {
                Text(SubscriptionConstants.autoRenewalDisclosure)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(theme.mutedText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Legal Section
    
    private var legalSection: some View {
        HStack(spacing: 20) {
            Link("Privacy Policy", destination: URL(string: SubscriptionConstants.privacyPolicyURL)!)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(theme.accent)
            
            Text("•")
                .foregroundColor(theme.mutedText)
            
            Link("Terms of Use", destination: URL(string: SubscriptionConstants.termsOfServiceURL)!)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(theme.accent)
        }
    }
    
    // MARK: - Helpers
    
    private var backgroundColor: Color {
        colorScheme == .dark ? theme.backgroundDark : theme.backgroundLight
    }
    
    // MARK: - Code Entry Handler
    
    /// Handle dev unlock code entry
    private func handleCodeEntry() {
        let success = subscriptionManager.unlockWithDevCode(enteredCode)
        if success {
            dismiss()
        } else {
            showInvalidCodeError = true
        }
        enteredCode = ""
    }
}

// MARK: - Feature Button

struct FeatureButton: View {
    let icon: String
    let title: String
    let description: String
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(description)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            colorScheme == .dark 
                ? theme.primaryButtonBackgroundDark 
                : theme.primaryButtonBackgroundLight
        )
        .cornerRadius(12)
        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.clear : Color.black.opacity(0.15)
    }
}

// MARK: - Preview

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
            .environmentObject(SubscriptionManager())
    }
}

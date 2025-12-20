//
//  PaywallView.swift
//  Savage By Design
//
//  Subscription paywall view with trial offer
//

import SwiftUI

/// Paywall view for presenting subscription offer
struct PaywallView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    
    @State private var isPurchasing = false
    
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
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Unlock Advanced Features")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("AI-assisted planning, intelligent tracking, and advanced analytics")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(theme.mutedText)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            FeatureRow(
                icon: "doc.text.fill",
                title: "AI-Assisted Plan Ingestion",
                description: "Import and parse workout plans from any LLM"
            )
            
            FeatureRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Intelligent Progress Analysis",
                description: "Advanced analytics and progress tracking"
            )
            
            FeatureRow(
                icon: "wand.and.stars",
                title: "Automated Review & Modifications",
                description: "Smart suggestions for plan optimization"
            )
            
            FeatureRow(
                icon: "clock.arrow.circlepath",
                title: "Advanced Block History",
                description: "Comprehensive workout history and insights"
            )
            
            FeatureRow(
                icon: "square.grid.2x2.fill",
                title: "Enhanced Dashboard",
                description: "Advanced visualization and reporting"
            )
        }
    }
    
    // MARK: - Pricing Section
    
    private var pricingSection: some View {
        VStack(spacing: 16) {
            
            // Trial badge
            if subscriptionManager.isEligibleForTrial {
                Text("START 15-DAY FREE TRIAL")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(20)
            }
            
            // Pricing card
            VStack(spacing: 12) {
                if let price = subscriptionManager.formattedPrice {
                    Text(price)
                        .font(.system(size: 48, weight: .bold))
                    
                    Text("per month")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.mutedText)
                } else {
                    Text(SubscriptionConstants.fallbackPrice)
                        .font(.system(size: 48, weight: .bold))
                    
                    Text("per month")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.mutedText)
                }
                
                if subscriptionManager.isEligibleForTrial {
                    Text("First \(SubscriptionConstants.trialDurationDays) days free, then \(subscriptionManager.formattedPrice ?? SubscriptionConstants.fallbackPrice)/month")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(theme.mutedText)
                        .multilineTextAlignment(.center)
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
                    await subscriptionManager.purchase()
                    isPurchasing = false
                    
                    // Dismiss on successful purchase
                    if subscriptionManager.isSubscribed {
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(subscriptionManager.isEligibleForTrial ? "Start Free Trial" : "Subscribe Now")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(28)
            }
            .disabled(isPurchasing || subscriptionManager.subscriptionProduct == nil)
            
            // Restore button
            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
            }
            .padding(.top, 8)
            
            // Auto-renew disclosure
            Text("Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(theme.mutedText)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }
    
    // MARK: - Legal Section
    
    private var legalSection: some View {
        HStack(spacing: 20) {
            Link("Privacy Policy", destination: URL(string: SubscriptionConstants.privacyPolicyURL)!)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            
            Text("•")
                .foregroundColor(theme.mutedText)
            
            Link("Terms of Service", destination: URL(string: SubscriptionConstants.termsOfServiceURL)!)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
        }
    }
    
    // MARK: - Helpers
    
    private var backgroundColor: Color {
        colorScheme == .dark ? theme.backgroundDark : theme.backgroundLight
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(theme.mutedText)
            }
        }
    }
}

// MARK: - Preview

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
            .environmentObject(SubscriptionManager())
    }
}

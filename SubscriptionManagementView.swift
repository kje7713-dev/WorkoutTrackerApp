//
//  SubscriptionManagementView.swift
//  Savage By Design
//
//  View for managing active subscriptions
//

import SwiftUI
import StoreKit

/// View for managing active subscription
struct SubscriptionManagementView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    
    @State private var showingPaywall = false
    @State private var isEligibleForTrial = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    if subscriptionManager.hasActiveSubscription {
                        activeSubscriptionSection
                    } else {
                        inactiveSubscriptionSection
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
            }
            .background(backgroundColor.ignoresSafeArea())
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(subscriptionManager)
            }
            .task {
                // Check trial eligibility when view appears
                isEligibleForTrial = await subscriptionManager.isEligibleForIntroOffer
            }
        }
    }
    
    // MARK: - Active Subscription Section
    
    private var activeSubscriptionSection: some View {
        VStack(spacing: 24) {
            
            // Status badge
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text("Pro Subscription Active")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.green)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.1))
            )
            
            // Subscription details
            VStack(alignment: .leading, spacing: 16) {
                Text("Active Features")
                    .font(.system(size: 20, weight: .bold))
                
                VStack(alignment: .leading, spacing: 12) {
                    FeatureCheckRow(text: "AI-assisted plan ingestion")
                    FeatureCheckRow(text: "JSON workout import")
                    FeatureCheckRow(text: "AI prompt templates")
                    FeatureCheckRow(text: "Block library management")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Management options
            VStack(spacing: 16) {
                
                // Manage subscription link
                if let url = URL(string: SubscriptionConstants.appleSubscriptionManagementURL) {
                    Link(destination: url) {
                        HStack {
                            Text("Manage Subscription")
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                        )
                    }
                }
                
                // Restore purchases
                Button {
                    Task {
                        await subscriptionManager.restorePurchases()
                    }
                } label: {
                    HStack {
                        Text("Restore Purchases")
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Image(systemName: "arrow.clockwise")
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                    )
                }
            }
            
            // Info text about subscription
            if let price = subscriptionManager.formattedPrice {
                Text("Subscription renews at \(price) per month unless cancelled.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(theme.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Inactive Subscription Section
    
    private var inactiveSubscriptionSection: some View {
        VStack(spacing: 24) {
            
            // Status
            VStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundColor(theme.mutedText)
                
                Text("No Active Subscription")
                    .font(.system(size: 20, weight: .bold))
                
                Text("Subscribe to unlock AI-powered workout import tools")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(theme.mutedText)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 24)
            
            // Locked features
            VStack(alignment: .leading, spacing: 16) {
                Text("Premium Features")
                    .font(.system(size: 20, weight: .bold))
                
                VStack(alignment: .leading, spacing: 12) {
                    FeatureCheckRow(text: "AI-assisted plan ingestion", isLocked: true)
                    FeatureCheckRow(text: "JSON workout import", isLocked: true)
                    FeatureCheckRow(text: "AI prompt templates", isLocked: true)
                    FeatureCheckRow(text: "Block library management", isLocked: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Subscribe button
            Button {
                showingPaywall = true
            } label: {
                Text(isEligibleForTrial ? "Start 15-Day Free Trial" : "Subscribe Now")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [theme.premiumGradientStart, theme.premiumGradientEnd]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(28)
                    .shadow(color: theme.premiumGradientStart.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            // Restore purchases
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
        }
    }
    
    // MARK: - Helpers
    
    private var backgroundColor: Color {
        colorScheme == .dark ? theme.backgroundDark : theme.backgroundLight
    }
}

// MARK: - Feature Check Row

struct FeatureCheckRow: View {
    let text: String
    var isLocked: Bool = false
    
    @Environment(\.sbdTheme) private var theme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isLocked ? "lock.fill" : "checkmark.circle.fill")
                .foregroundColor(isLocked ? theme.mutedText : .green)
            
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(isLocked ? theme.mutedText : .primary)
        }
    }
}

// MARK: - Preview

struct SubscriptionManagementView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionManagementView()
            .environmentObject(SubscriptionManager())
    }
}

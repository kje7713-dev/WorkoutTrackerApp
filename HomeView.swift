//
//  HomeView.swift
//  Savage By Design
//
//  Pro Home – Premium branded home screen
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    @State private var showingSubscriptionManagement = false
    @State private var showingSettings = false
    
    private var buildBranchLabel: String {
        let branch = getBuildBranch()
        if branch.hasPrefix("copilot/") {
            return branch
        }
        return "copilot/\(branch)"
    }
    
    private func getBuildBranch() -> String {
        if let branch = Bundle.main.infoDictionary?["BUILD_BRANCH"] as? String, !branch.isEmpty {
            return branch
        }
        return "unknown"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.spacing16) {
                
                // MARK: - Top App Bar
                HStack(alignment: .center, spacing: DesignTokens.spacing12) {
                    // Logo in circle
                    ZStack {
                        Circle()
                            .fill(Color.proSurface)
                            .frame(width: 36, height: 36)
                        
                        Image("SBDPrimaryLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                    
                    Text("Savage by Design")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.proTextPrimary)
                    
                    Spacer()
                    
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18))
                            .foregroundColor(Color.proTextPrimary)
                    }
                }
                .padding(.horizontal, DesignTokens.spacing16)
                .padding(.vertical, DesignTokens.spacing12)
                
                // MARK: - Hero Card
                HeroCard {
                    VStack(spacing: DesignTokens.spacing12) {
                        // Top row: Badge + Status
                        HStack {
                            Text("SAVAGE BY DESIGN — PRO")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                            
                            Spacer()
                            
                            StatusPill(
                                text: subscriptionManager.isSubscribed ? "PRO ACTIVE" : "FREE",
                                isActive: subscriptionManager.isSubscribed
                            )
                        }
                        
                        // Main message
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Train with intent.")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Programs, progression, and curriculum in one place.")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Mini metrics
                        HStack(spacing: DesignTokens.spacing8) {
                            MetricChip(icon: "square.stack.3d.up.fill", label: "Blocks")
                            MetricChip(icon: "chart.bar.fill", label: "Progress")
                            MetricChip(icon: "wand.and.stars", label: "Builder")
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.spacing16)
                
                // MARK: - Feature Actions
                VStack(spacing: DesignTokens.spacing12) {
                    // Training Blocks
                    NavigationLink {
                        BlocksListView()
                    } label: {
                        FeatureRow(
                            icon: "square.stack.3d.up.fill",
                            title: "Training Blocks",
                            subtitle: "Browse 4–12 week programs and build sessions fast"
                        ) {}
                    }
                    
                    // Progress History
                    NavigationLink {
                        BlockHistoryListView()
                    } label: {
                        FeatureRow(
                            icon: "chart.bar.fill",
                            title: "Progress History",
                            subtitle: "See volume, sessions, and your training streak"
                        ) {}
                    }
                    
                    // Curriculum Builder / Data Management
                    NavigationLink {
                        DataManagementView()
                    } label: {
                        FeatureRow(
                            icon: "wand.and.stars",
                            title: "Curriculum Builder",
                            subtitle: "Design strength, grappling, or hybrid curricula"
                        ) {}
                    }
                }
                .padding(.horizontal, DesignTokens.spacing16)
                
                // MARK: - Secondary Actions
                HStack(spacing: DesignTokens.spacing12) {
                    // Manage Subscription
                    Button {
                        showingSubscriptionManagement = true
                    } label: {
                        Text("Manage Subscription")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .foregroundColor(.white)
                            .background(Color.proBrandBlack)
                            .cornerRadius(DesignTokens.cornerRow)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Restore Purchases
                    Button {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    } label: {
                        Text("Restore Purchases")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .foregroundColor(Color.proBrandBlack)
                            .background(Color.proSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.cornerRow)
                                    .stroke(Color.proDivider.opacity(1.0), lineWidth: 1)
                            )
                            .cornerRadius(DesignTokens.cornerRow)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, DesignTokens.spacing16)
                .padding(.top, DesignTokens.spacing20 - DesignTokens.spacing12)
                
                // MARK: - Support Footer
                VStack(spacing: DesignTokens.spacing8) {
                    Text("Questions? Contact support")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.proTextSecondary)
                        .underline()
                    
                    // Build branch label
                    Text(buildBranchLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.proTextPrimary.opacity(0.6))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: DesignTokens.cornerRow)
                                .fill(Color.proDivider)
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.top, DesignTokens.spacing8)
                .padding(.bottom, DesignTokens.spacing24)
            }
        }
        .background(Color.proBackground.ignoresSafeArea())
        .sheet(isPresented: $showingSubscriptionManagement) {
            SubscriptionManagementView()
                .environmentObject(subscriptionManager)
        }
        .sheet(isPresented: $showingSettings) {
            // Settings view placeholder
            NavigationStack {
                DataManagementView()
                    .navigationTitle("Settings")
            }
        }
    }
}
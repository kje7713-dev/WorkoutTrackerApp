//
//  HomeView.swift
//  Savage By Design
//
//  Branded home screen + navigation entry points
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    @State private var showingSubscriptionManagement = false
    
    private var buildBranchLabel: String {
        let branch = getBuildBranch()
        // If branch already starts with "copilot/", don't add it again
        if branch.hasPrefix("copilot/") {
            return branch
        }
        return "copilot/\(branch)"
    }
    
    private func getBuildBranch() -> String {
        // This will be replaced by the build script or default to "unknown"
        if let branch = Bundle.main.infoDictionary?["BUILD_BRANCH"] as? String, !branch.isEmpty {
            return branch
        }
        return "unknown"
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            backgroundColor.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Logo + Slogan
                HStack(alignment: .center, spacing: 16) {
                    Image("SBDPrimaryLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 64)
                        .clipped()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("SAVAGE BY DESIGN")
                            .font(.system(size: 20, weight: .heavy, design: .default))
                            .tracking(1.5)
                            .foregroundColor(primaryTextColor)

                        Text("WE ARE WHAT WE REPEATEDLY DO")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(primaryTextColor.opacity(0.7))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                .padding(.top, 40)

                // MARK: - Summary Card
                SBDCard {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BLOCKS")
                            .font(.system(size: 16, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(primaryTextColor)

                        Text("Build and run multi-week strength and conditioning blocks with full session history.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(theme.mutedText)
                    }
                }

                // MARK: - Primary Actions
                VStack(spacing: 12) {

                    // Blocks -> BlocksListView (Primary with Electric Green accent)
                    NavigationLink {
                        BlocksListView()
                    } label: {
                        HStack {
                            Rectangle()
                                .fill(theme.accent)  // Electric Green accent
                                .frame(width: 3)
                            
                            Text("BLOCKS")
                                .font(.system(size: 16, weight: .semibold))
                                .tracking(1.5)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(foregroundButtonColor)
                        }
                        .frame(height: 48)
                        .background(backgroundButtonColor)
                        .cornerRadius(12)
                        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Block History -> BlockHistoryListView (Secondary)
                    NavigationLink {
                        BlockHistoryListView()
                    } label: {
                        Text("BLOCK HISTORY")
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(1.5)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .foregroundColor(foregroundButtonColor)
                            .background(backgroundButtonColor)
                            .cornerRadius(12)
                            .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Data Management (Secondary)
                    NavigationLink {
                        DataManagementView()
                    } label: {
                        Text("DATA MANAGEMENT")
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(1.5)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .foregroundColor(foregroundButtonColor)
                            .background(backgroundButtonColor)
                            .cornerRadius(12)
                            .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Spacer(minLength: 0)
                
                // MARK: - Build Branch Label
                VStack(spacing: 4) {
                    Text(buildBranchLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(primaryTextColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(primaryTextColor.opacity(0.1))
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)  // 20px from bottom home indicator
            }
            .padding(.horizontal, 20)
            
            // MARK: - Pro Status Badge (Top-right corner)
            if subscriptionManager.isSubscribed {
                HStack(spacing: 6) {
                    Circle()
                        .fill(theme.accent)  // Electric Green glowing dot
                        .frame(width: 8, height: 8)
                        .shadow(color: theme.accent.opacity(0.8), radius: 4, x: 0, y: 0)
                    
                    Text("PRO ACTIVE")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.2)
                        .foregroundColor(primaryTextColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundButtonColor)
                        .shadow(color: theme.accent.opacity(0.2), radius: 4, x: 0, y: 2)
                )
                .padding(.top, 50)
                .padding(.trailing, 20)
                .onTapGesture {
                    showingSubscriptionManagement = true
                }
            } else {
                // Show "GO PRO" badge for non-subscribers
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(theme.premiumGold)
                    
                    Text("GO PRO")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.2)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [theme.premiumGradientStart, theme.premiumGradientEnd]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(8)
                )
                .shadow(color: theme.premiumGradientStart.opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(.top, 50)
                .padding(.trailing, 20)
                .onTapGesture {
                    showingSubscriptionManagement = true
                }
            }
        }
        .sheet(isPresented: $showingSubscriptionManagement) {
            SubscriptionManagementView()
                .environmentObject(subscriptionManager)
        }
    }

    // MARK: - Helpers

    private var backgroundColor: Color {
        colorScheme == .dark ? theme.backgroundDark : theme.backgroundLight
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? theme.primaryTextDark : theme.primaryTextLight
    }

    private var backgroundButtonColor: Color {
        colorScheme == .dark ? theme.primaryButtonBackgroundDark : theme.primaryButtonBackgroundLight
    }

    private var foregroundButtonColor: Color {
        colorScheme == .dark ? theme.primaryButtonForegroundDark : theme.primaryButtonForegroundLight
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.clear : Color.black.opacity(0.15)
    }
}
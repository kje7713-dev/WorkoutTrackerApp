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
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            backgroundColor.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Logo + Slogan
                VStack(alignment: .center, spacing: 8) {
                    Text("SAVAGE BY DESIGN")
                        .font(.system(size: 40, weight: .heavy, design: .default))
                        .tracking(1.5)
                        .foregroundColor(primaryTextColor)
                        .multilineTextAlignment(.center)

                    Text("WE ARE WHAT WE REPEATEDLY DO")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(primaryTextColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)

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
                    
                    // Feedback (Secondary)
                    NavigationLink {
                        FeedbackFormView()
                    } label: {
                        Text("FEEDBACK")
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
                
                // MARK: - User Guide Button
                Link(destination: URL(string: "https://savagesbydesign.com/app/")!) {
                    Text("USER GUIDE")
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
                .padding(.bottom, 20)  // Safe area bottom padding
            }
            .padding(.horizontal, 20)
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
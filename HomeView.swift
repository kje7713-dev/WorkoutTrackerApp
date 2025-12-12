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
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Logo + Slogan
                HStack(alignment: .center, spacing: 16) {
                    Image("SBDPrimaryLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 64)
                        .clipped()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("SAVAGE BY DESIGN")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(primaryTextColor)

                        Text("WE ARE WHAT WE REPEATEDLY DO")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(primaryTextColor.opacity(0.7))
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.top, 40)

                // MARK: - Copilot DateTime Display
                CopilotDateTimeView()

                // MARK: - Summary Card
                SBDCard {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BLOCKS")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(primaryTextColor)

                        Text("Build and run multi-week strength and conditioning blocks with full session history.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(theme.mutedText)
                    }
                }

                // MARK: - Primary Actions
                VStack(spacing: 12) {

                    // Blocks -> BlocksListView
                    NavigationLink {
                        BlocksListView()
                    } label: {
                        Text("BLOCKS")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .foregroundColor(foregroundButtonColor)
                            .background(backgroundButtonColor)
                            .cornerRadius(20)
                            .textCase(.uppercase)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Today (future)
                    SBDPrimaryButton("Today (Future)") {
                        // will wire up later
                    }

                    // History (future)
                    SBDPrimaryButton("History (Future)") {
                        // will wire up later
                    }
                }

                Spacer(minLength: 0)
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
        colorScheme == .dark ? .white : .black
    }

    private var foregroundButtonColor: Color {
        colorScheme == .dark ? .black : .white
    }
}
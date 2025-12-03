//
//  HomeView.swift
//  Savage By Design
//
//  Clean header with flame icon + title
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Logo + Slogan with Flame Icon
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 12) {
                        Image("SBDFlame")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipped()

                        Text("SAVAGE BY DESIGN")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(primaryTextColor)
                    }

                    Text("WE ARE WHAT WE REPEATEDLY DO")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(primaryTextColor.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 40)

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

                // MARK: - Primary Actions (navigation hooks later)
                VStack(spacing: 12) {
                    SBDPrimaryButton("Blocks") {
                        // navigation will hook in later phases
                    }

                    SBDPrimaryButton("Today (Future)") {
                        // stub
                    }

                    SBDPrimaryButton("History (Future)") {
                        // stub
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
}
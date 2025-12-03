//
//  BlocksListView.swift
//  Savage By Design
//
//  Phase 5 + 6: Blocks list UI + "New Block" entry point
//

import SwiftUI

struct BlocksListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme

    @EnvironmentObject private var blocksRepository: BlocksRepository
    @EnvironmentObject private var exerciseLibraryRepository: ExerciseLibraryRepository

    @State private var isPresentingBuilder: Bool = false

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                header

                // New Block button
                SBDPrimaryButton("New Block") {
                    isPresentingBuilder = true
                }

                if blocksRepository.allBlocks().isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(blocksRepository.allBlocks()) { block in
                                BlockCard(block: block)
                            }
                        }
                        .padding(.top, 4)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .navigationTitle("Blocks")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Seed exercise library for future use
            exerciseLibraryRepository.loadDefaultSeedIfEmpty()
        }
        .sheet(isPresented: $isPresentingBuilder) {
            NavigationStack {
                BlockBuilderView()
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Blocks")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(primaryTextColor)

            Text("Multi-week plans for strength, conditioning, and mixed work.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(theme.mutedText)
        }
    }

    private var emptyState: some View {
        SBDCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("No blocks yet")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryTextColor)

                Text("Create your first block to start tracking multi-week progress. The builder will let you mix strength, conditioning, and custom work.")
                    .font(.system(size: 14))
                    .foregroundColor(theme.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        colorScheme == .dark ? theme.backgroundDark : theme.backgroundLight
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? theme.primaryTextDark : theme.primaryTextLight
    }
}

// MARK: - Block Card

private struct BlockCard: View {
    @Environment(\.sbdTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let block: Block

    var body: some View {
        SBDCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(block.name.uppercased())
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(primaryTextColor)

                if let description = block.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(theme.mutedText)
                        .lineLimit(3)
                }

                HStack(spacing: 12) {
                    if block.numberOfWeeks > 0 {
                        Label("\(block.numberOfWeeks) weeks", systemImage: "calendar")
                            .font(.system(size: 12, weight: .medium))
                    }

                    if !block.days.isEmpty {
                        Label("\(block.days.count) days", systemImage: "square.grid.3x3")
                            .font(.system(size: 12, weight: .medium))
                    }

                    if let goal = block.goal {
                        Label(goalLabel(goal), systemImage: "flame")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .foregroundColor(theme.mutedText)
                .padding(.top, 4)
            }
        }
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? theme.primaryTextDark : theme.primaryTextLight
    }

    private func goalLabel(_ goal: TrainingGoal) -> String {
        switch goal {
        case .strength: return "Strength"
        case .hypertrophy: return "Hypertrophy"
        case .power: return "Power"
        case .conditioning: return "Conditioning"
        case .mixed: return "Mixed"
        case .peaking: return "Peaking"
        case .deload: return "Deload"
        case .rehab: return "Rehab"
        }
    }
}
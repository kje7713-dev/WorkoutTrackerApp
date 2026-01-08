import SwiftUI

/// Blocks screen – choose a block to run, or create a new one.
/// Phase 7: hooked to BlocksRepository (no ProgramStore, no extra layers).

struct BlocksListView: View {

    // Same repository the builder uses
    @EnvironmentObject private var blocksRepository: BlocksRepository
    @EnvironmentObject private var sessionsRepository: SessionsRepository
    @EnvironmentObject private var exerciseLibraryRepository: ExerciseLibraryRepository
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.sbdTheme) private var theme

    // Which builder mode is active (if any)?
    @State private var builderContext: BuilderContext?
    
    // AI block generator
    @State private var showingAIGenerator: Bool = false

    private enum BuilderContext: Identifiable {
        case new
        case edit(Block)
        case clone(Block)

        var id: String {
            switch self {
            case .new:
                return "new"
            case .edit(let block):
                return "edit-\(block.id)"
            case .clone(let block):
                return "clone-\(block.id)"
            }
        }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                header

                if blocksRepository.activeBlocks().isEmpty {
                    emptyState
                } else {
                    blocksList
                }

                Spacer()

                aiGeneratorButton
                
                newBlockButton
            }
            .padding(.horizontal)
            .padding(.top, 32)
        }
        .navigationTitle("Blocks")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAIGenerator) {
            BlockGeneratorView()
                .environmentObject(blocksRepository)
                .environmentObject(sessionsRepository)
                .environmentObject(subscriptionManager)
        }
        .sheet(item: $builderContext) { context in
            NavigationStack {
                switch context {
                case .new:
                    BlockBuilderView(mode: .new)
                        .environmentObject(blocksRepository)
                        .environmentObject(sessionsRepository)
                        .environmentObject(exerciseLibraryRepository)

                case .edit(let block):
                    BlockBuilderView(mode: .edit(block))
                        .environmentObject(blocksRepository)
                        .environmentObject(sessionsRepository)
                        .environmentObject(exerciseLibraryRepository)

                case .clone(let block):
                    BlockBuilderView(mode: .clone(block))
                        .environmentObject(blocksRepository)
                        .environmentObject(sessionsRepository)
                        .environmentObject(exerciseLibraryRepository)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "flame")
                .font(.largeTitle)
                .foregroundStyle(.orange)
                .accessibilityHidden(true)
            
            Text("Blocks")
                .font(.largeTitle).bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No blocks yet")
                .font(.title2).bold()

            Text("Create a block in the builder, then come back here to run it.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    // MARK: - List of Blocks

    private var blocksList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Only show active (non-archived) blocks
                // Note: Filter is called on each view update, but this is acceptable
                // for the expected number of blocks (<100) and simpler than caching
                ForEach(blocksRepository.activeBlocks()) { block in 
                    VStack(alignment: .leading, spacing: 12) {
                        // Active block indicator and title
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                // Active badge
                                if block.isActive {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                            .foregroundColor(theme.premiumGold)
                                        Text("ACTIVE BLOCK")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(theme.premiumGold)
                                    }
                                }
                                
                                // Title
                                Text(block.name)
                                    .font(.headline).bold()
                            }
                            
                            Spacer()
                            
                            // Set Active toggle
                            Button {
                                if block.isActive {
                                    blocksRepository.clearActiveBlock()
                                } else {
                                    blocksRepository.setActive(block)
                                }
                            } label: {
                                Image(systemName: block.isActive ? "star.fill" : "star")
                                    .font(.title3)
                                    .foregroundColor(block.isActive ? theme.premiumGold : .gray)
                            }
                            .accessibilityLabel(block.isActive ? "Remove active block" : "Set as active block")
                            .accessibilityHint(block.isActive ? "Deactivates this block" : "Makes this your active training block")
                        }

                        if let description = block.description, !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Block metadata
                        HStack(spacing: 12) {
                            // Number of weeks
                            Label("\(block.numberOfWeeks) weeks", systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // Goal
                            if let goal = block.goal {
                                Label(goal.rawValue.capitalized, systemImage: "target")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Source
                            if block.source == .ai {
                                Label("AI", systemImage: "sparkles")
                                    .font(.caption)
                                    .foregroundColor(theme.premiumGradientEnd)
                            }
                        }
                        
                        // Summary metrics card
                        let metrics = BlockMetrics.calculate(
                            for: block,
                            sessions: sessionsRepository.sessions(forBlockId: block.id)
                        )
                        BlockSummaryCard(metrics: metrics)

                        // Explicit action row: RUN / EDIT / NEXT BLOCK
                        HStack(spacing: 8) {
                            // RUN – navigate directly to BlockRunModeView
                            NavigationLink {
                                BlockRunModeView(block: block)
                                    .environmentObject(sessionsRepository)
                                    .environmentObject(blocksRepository)
                                    .environmentObject(exerciseLibraryRepository)
                                    .environmentObject(subscriptionManager)
                            } label: { 
                                Text("RUN")
                                    .font(.subheadline).bold()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.borderedProminent)


                            // EDIT – open builder in edit mode (update this block)
                            Button {
                                builderContext = .edit(block)
                            } label: {
                                Text("EDIT")
                                    .font(.subheadline).bold()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)

                            // NEXT BLOCK – open builder in clone mode (new block based on this one)
                            Button {
                                builderContext = .clone(block)
                            } label: {
                                Text("NEXT BLOCK")
                                    .font(.subheadline).bold()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                        }

                        // ARCHIVE button to move to history
                        Button {
                            blocksRepository.archive(block)
                        } label: {
                            Text("ARCHIVE")
                                .font(.footnote)
                        }
                        .padding(.top, 4)
                        
                        // Optional: explicit DELETE button (same behavior as old contextMenu delete)
                        Button(role: .destructive) {
                            blocksRepository.delete(block)
                        } label: {
                            Text("DELETE")
                                .font(.footnote)
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        block.isActive ? theme.premiumGold : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    )
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Import JSON Button
    
    private var aiGeneratorButton: some View {
        SBDPremiumButton(
            "IMPORT AI BLOCK",
            icon: "flame.fill",
            isLocked: !subscriptionManager.isSubscribed
        ) {
            showingAIGenerator = true
        }
        .padding(.bottom, 8)
    }

    // MARK: - New Block Button

    private var newBlockButton: some View {
        SBDPrimaryButton("NEW BLOCK") {
            builderContext = .new
        }
        .padding(.bottom, 24)
    }
} // <--- This closes the BlocksListView struct (CRITICAL CLOSURE)

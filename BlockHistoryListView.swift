import SwiftUI

/// Block history screen – review archived blocks.
/// Replicated from BlocksListView but shows archived blocks with REVIEW instead of RUN.

struct BlockHistoryListView: View {

    @EnvironmentObject private var blocksRepository: BlocksRepository
    @EnvironmentObject private var sessionsRepository: SessionsRepository
    @EnvironmentObject private var exerciseLibraryRepository: ExerciseLibraryRepository
    @Environment(\.sbdTheme) private var theme

    // Which builder mode is active (if any)?
    @State private var builderContext: BuilderContext?

    private enum BuilderContext: Identifiable {
        case edit(Block)
        case clone(Block)

        var id: String {
            switch self {
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

                if blocksRepository.archivedBlocks().isEmpty {
                    emptyState
                } else {
                    blocksList
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 32)
        }
        .navigationTitle("Block History")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $builderContext) { context in
            NavigationStack {
                switch context {
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
        VStack(alignment: .leading, spacing: 4) {
            Text("Block History")
                .font(.largeTitle).bold()

            Text("Review your archived blocks.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No archived blocks")
                .font(.title2).bold()

            Text("Completed or NLA blocks you archive will appear here.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    // MARK: - List of Archived Blocks

    private var blocksList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Note: Filter is called on each view update, but this is acceptable
                // for the expected number of blocks (<100) and simpler than caching
                ForEach(blocksRepository.archivedBlocks()) { block in 
                    VStack(alignment: .leading, spacing: 8) {
                        // Title / description
                        Text(block.name)
                            .font(.headline).bold()

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
                                    .foregroundColor(.purple)
                            }
                        }

                        // Explicit action row: REVIEW / EDIT / NEXT BLOCK
                        HStack(spacing: 8) {
                            // REVIEW – navigate to BlockRunModeView (read-only review)
                            NavigationLink {
                                BlockRunModeView(block: block)
                                    .environmentObject(sessionsRepository)
                                    .environmentObject(blocksRepository)
                                    .environmentObject(exerciseLibraryRepository)
                            } label: { 
                                Text("REVIEW")
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

                        // UNARCHIVE button to restore to active list
                        Button {
                            blocksRepository.unarchive(block)
                        } label: {
                            Text("UNARCHIVE")
                                .font(.footnote)
                        }
                        .padding(.top, 4)
                        
                        // Optional: DELETE button
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
                    )
                }
            }
            .padding(.top, 8)
        }
    }
}

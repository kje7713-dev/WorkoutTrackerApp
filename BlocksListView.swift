import SwiftUI

/// Blocks screen – choose a block to run, or create a new one.
/// Phase 7: hooked to BlocksRepository (no ProgramStore, no extra layers).



struct BlocksListView: View {

    // Same repository the builder uses
    @EnvironmentObject private var blocksRepository: BlocksRepository
    @Environment(\.sbdTheme) private var theme

    // Which builder mode is active (if any)?
    @State private var builderContext: BuilderContext?

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

                if blocksRepository.blocks.isEmpty {
                    emptyState
                } else {
                    blocksList
                }

                Spacer()

                newBlockButton
            }
            .padding(.horizontal)
            .padding(.top, 32)
        }
        .navigationTitle("Blocks")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $builderContext) { context in
            NavigationStack {
                switch context {
                case .new:
                    BlockBuilderView(mode: .new)
                        .environmentObject(blocksRepository)

                case .edit(let block):
                    BlockBuilderView(mode: .edit(block))
                        .environmentObject(blocksRepository)

                case .clone(let block):
                    BlockBuilderView(mode: .clone(block))
                        .environmentObject(blocksRepository)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Blocks")
                .font(.largeTitle).bold()

            Text("Choose a block to run.")
                .font(.body)
                .foregroundColor(.secondary)
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
                ForEach(Array(blocksRepository.blocks.enumerated()), id: \.offset) { _, block in
                    VStack(alignment: .leading, spacing: 8) {
                        // Title / description (unchanged behavior)
                        Text(block.name)
                            .font(.headline).bold()

                        if let description = block.description, !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        // Explicit action row: RUN / EDIT / NEXT BLOCK
                        HStack(spacing: 8) {
                            // RUN – same behavior as your old NavigationLink row
                            NavigationLink {
    BlockRunModeView(block: block)
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
                    )
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - New Block Button

    private var newBlockButton: some View {
        Button {
            builderContext = .new
        } label: {
            Text("NEW BLOCK")
                .font(.headline).bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(24)
        }
        .padding(.bottom, 24)
    }
}
// MARK: - BlockSessionEntryView

/// Entry point for running a block:
/// - Finds the first generated WorkoutSession for the block
/// - Shows WorkoutSessionView if found
/// - Otherwise shows a simple "No sessions" message
struct BlockSessionEntryView: View {
    @EnvironmentObject private var sessionsRepository: SessionsRepository
    @EnvironmentObject private var blocksRepository: BlocksRepository

    let block: Block

    var body: some View {
        let blockSessions = sessionsRepository.sessions(forBlockId: block.id)

        if let firstSession = blockSessions.first {
            WorkoutSessionView(session: firstSession)
        } else {
            VStack(spacing: 12) {
                Text("No sessions available for this block yet.")
                    .font(.headline)

                Text("Save this block again to generate sessions, then try running it.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle(block.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

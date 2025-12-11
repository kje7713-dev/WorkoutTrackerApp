import SwiftUI

/// Blocks screen – choose a block to run, or create a new one.
/// Phase 7: hooked to BlocksRepository (no ProgramStore, no extra layers).

struct BlocksListView: View {

    // Same repository the builder uses
    @EnvironmentObject private var blocksRepository: BlocksRepository
    @EnvironmentObject private var sessionsRepository: SessionsRepository
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
                        .environmentObject(sessionsRepository) // 🚨 FIX: Ensure session repo is passed

                case .edit(let block):
                    BlockBuilderView(mode: .edit(block))
                        .environmentObject(blocksRepository)
                        .environmentObject(sessionsRepository) // 🚨 FIX: Ensure session repo is passed

                case .clone(let block):
                    BlockBuilderView(mode: .clone(block))
                        .environmentObject(blocksRepository)
                        .environmentObject(sessionsRepository) // 🚨 FIX: Ensure session repo is passed
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
                            // RUN – calls the helper view below to find/create the session
                            NavigationLink {
                                BlockSessionEntryView(block: block)
                                    .environmentObject(blocksRepository)
                                    .environmentObject(sessionsRepository)
                            label {
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
        
// 🚨 RENAMED FROM BlockRunEntryView and calls the consolidated SessionRunView
private struct BlockSessionEntryView: View {
    let block: Block

    @EnvironmentObject private var sessionsRepository: SessionsRepository

    var body: some View {
        Group {
            if let firstSession = firstSessionForBlock() {
                // 🚨 Calls the consolidated SessionRunView (formerly BlockRunModeView)
                SessionRunView(session: firstSession)
            } else {
                Text("No sessions available for this block.")
            }
        }
    }

    // Ensure sessions exist for this block, then return the first uncompleted session
    private func firstSessionForBlock() -> WorkoutSession? {
        var existing = sessionsRepository.sessions(forBlockId: block.id)
        
        // 1. If no sessions exist, generate them
        if existing.isEmpty {
            let factory = SessionFactory()
            let generated = factory.makeSessions(for: block)
            sessionsRepository.replaceSessions(forBlockId: block.id, with: generated)
            existing = generated
        }

        // 2. Sort by weekIndex, then dayTemplateId
        let sortedSessions = existing.sorted(by: sessionSort)
        
        // 3. Find the first uncompleted session, or the very first one if all are completed
        let uncompleted = sortedSessions.first(where: { $0.status != .completed })
        
        // Return the first uncompleted session, falling back to the very first one if none are incomplete.
        return uncompleted ?? sortedSessions.first
    }

    private func sessionSort(_ lhs: WorkoutSession, _ rhs: WorkoutSession) -> Bool {
        if lhs.weekIndex != rhs.weekIndex {
            return lhs.weekIndex < rhs.weekIndex
        }
        // This relies on the UUID string comparison being stable, which is fine for ordering.
        return lhs.dayTemplateId.uuidString < rhs.dayTemplateId.uuidString
    }
}

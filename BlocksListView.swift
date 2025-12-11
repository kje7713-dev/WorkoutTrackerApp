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

    // In BlocksListView.swift, replace the body of BlockSessionEntryView (around line 240)

    var body: some View {
        let sessions = getSessions()
        
        Group {
            if sessions.isEmpty {
                Text("No sessions available for this block.")
            } else if let currentSession = sessions.first(where: { $0.id == selectedSessionId }) {
                VStack(spacing: 0) {
                    // FIX: Day Tab Bar now controls which SessionRunView is loaded
                    SessionDayTabBar(
                        block: block,
                        sessions: sessions,
                        selectedSessionId: $selectedSessionId
                    )
                    .padding(.vertical, 8)
                    
                    // Load the selected Session
                    SessionRunView(session: currentSession)
                }
            } else {
                Text("Select a day to start.")
            }
        }
        // 🚨 FIX: Move .onAppear to the Group (top-level view)
        .onAppear {
            if selectedSessionId == nil, let initialId = getInitialSession(from: sessions)?.id {
                selectedSessionId = initialId
            }
        }
        .navigationTitle(block.name)
        .navigationBarTitleDisplayMode(.inline)
    }

        .sheet(item: $builderContext) { context in
            NavigationStack {
                switch context {
                case .new:
                    BlockBuilderView(mode: .new)
                        .environmentObject(blocksRepository)
                        .environmentObject(sessionsRepository)

                case .edit(let block):
                    BlockBuilderView(mode: .edit(block))
                        .environmentObject(blocksRepository)
                        .environmentObject(sessionsRepository)

                case .clone(let block):
                    BlockBuilderView(mode: .clone(block))
                        .environmentObject(blocksRepository)
                        .environmentObject(sessionsRepository)
                }
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

// MARK: - Session Entry View (The Fix Target)

private struct BlockSessionEntryView: View {
    let block: Block

    @EnvironmentObject private var sessionsRepository: SessionsRepository
    
    // 🚨 FIX 1: State to track the currently selected session ID
    @State private var selectedSessionId: WorkoutSessionID? 

    // Helper to sort sessions
    private func sessionSort(_ lhs: WorkoutSession, _ rhs: WorkoutSession) -> Bool {
        if lhs.weekIndex != rhs.weekIndex {
            return lhs.weekIndex < rhs.weekIndex
        }
        return lhs.dayTemplateId.uuidString < rhs.dayTemplateId.uuidString
    }
    
    // Helper to determine the session list
    private func getSessions() -> [WorkoutSession] {
        var existing = sessionsRepository.sessions(forBlockId: block.id)
        
        // 1. If no sessions exist, generate them
        if existing.isEmpty {
            let factory = SessionFactory()
            let generated = factory.makeSessions(for: block)
            // Persist the newly generated sessions
            sessionsRepository.replaceSessions(forBlockId: block.id, with: generated)
            existing = generated
        }
        
        // 2. Sort sessions
        return existing.sorted(by: sessionSort)
    }
    
    // Helper to determine the initial session to load
    private func getInitialSession(from sessions: [WorkoutSession]) -> WorkoutSession? {
        // Find the first uncompleted session, or the very first one if all are completed
        let uncompleted = sessions.first(where: { $0.status != .completed })
        return uncompleted ?? sessions.first
    }


    var body: some View {
        let sessions = getSessions()
        
        // Initialize selectedSessionId on first appearance
        .onAppear {
            if selectedSessionId == nil, let initialId = getInitialSession(from: sessions)?.id {
                selectedSessionId = initialId
            }
        }
        
        Group {
            if sessions.isEmpty {
                Text("No sessions available for this block.")
            } else if let currentSession = sessions.first(where: { $0.id == selectedSessionId }) {
                VStack(spacing: 0) {
                    // 🚨 FIX 2: Day Tab Bar now controls which SessionRunView is loaded
                    SessionDayTabBar(
                        block: block,
                        sessions: sessions,
                        selectedSessionId: $selectedSessionId
                    )
                    .padding(.vertical, 8)
                    
                    // 🚨 FIX 3: Load the SessionRunView with the *selected* session
                    SessionRunView(session: currentSession)
                }
            } else {
                Text("Select a day to start.")
            }
        }
        .navigationTitle(block.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Session Day Tab Bar (NEW HELPER)

private struct SessionDayTabBar: View {
    let block: Block // Needed to look up day names/short codes
    let sessions: [WorkoutSession]
    @Binding var selectedSessionId: WorkoutSessionID?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Generate a chip for every unique session in the block
                ForEach(sessions, id: \.id) { session in
                    let isSelected = session.id == selectedSessionId
                    
                    // Look up the DayTemplate using the block
                    let dayTemplate = block.days.first { $0.id == session.dayTemplateId }
                    let dayLabel = dayTemplate?.shortCode ?? dayTemplate?.name ?? "Day"
                    
                    // Label format: W[weekIndex] [DayLabel] (e.g., W1 Day 1, W2 D3)
                    let sessionLabel = "W\(session.weekIndex) \(dayLabel)"
                    
                    Button {
                        selectedSessionId = session.id
                    } label: {
                        Text(sessionLabel)
                            .font(.subheadline)
                            .fontWeight(isSelected ? .bold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.black : Color.clear)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .foregroundColor(isSelected ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

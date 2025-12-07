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
                    NavigationLink {
                        BlockRunModeView(block: block)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(block.name)
                                .font(.headline).bold()

                            if let description = block.description, !description.isEmpty {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(uiColor: .secondarySystemBackground))
                        )
                    }
                    .contextMenu {
                        Button("Edit Block") {
                            builderContext = .edit(block)
                        }

                        Button("Edit as New") {
                            builderContext = .clone(block)
                        }

                        Button(role: .destructive) {
                            blocksRepository.delete(block)
                        } label: {
                            Text("Delete Block")
                        }
                    }
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
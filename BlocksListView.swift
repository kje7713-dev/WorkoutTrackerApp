import SwiftUI

/// Blocks screen – choose a block to run, or create a new one.
struct BlocksListView: View {

    // ✅ Use the same repository the builder uses
    @EnvironmentObject private var blocksRepository: BlocksRepository
    @Environment(\.sbdTheme) private var theme

    @State private var isShowingBuilder = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Blocks")
                        .font(.largeTitle).bold()

                    Text("Choose a block to run.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Content
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
        .sheet(isPresented: $isShowingBuilder) {
            NavigationStack {
                BlockBuilderView()
                // EnvironmentObjects from parent flow down automatically.
            }
        }
    }

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
                }
            }
            .padding(.top, 8)
        }
    }

    // ... keep `emptyState` and `newBlockButton` exactly as you have them ...
}

    // MARK: - Subviews

    /// Empty state when there are no blocks yet.
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

    /// List of existing blocks (placeholder for now).
    private var blocksList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(blocks.indices, id: \.self) { index in
                    let block = blocks[index]

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
                }
            }
            .padding(.top, 8)
        }
    }

    /// Big pill-style "New Block" button.
    private var newBlockButton: some View {
        Button {
            isShowingBuilder = true
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
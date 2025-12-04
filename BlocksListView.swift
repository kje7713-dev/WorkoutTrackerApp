import SwiftUI

/// Blocks screen – choose a block to run, or create a new one.
/// Phase 7: simple, no ProgramStore, no fancy data layer.
/// We will hook this up to real persisted blocks in a later sub-step.
struct BlocksListView: View {

    // For now this is just an in-memory list.
    // Later we can load/save from your existing JSON store.
    @State private var blocks: [Block] = []

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
                if blocks.isEmpty {
                    emptyState
                } else {
                    blocksList
                }

                Spacer()

                // New Block button
                newBlockButton
            }
            .padding(.horizontal)
            .padding(.top, 32)
        }
        .navigationTitle("Blocks")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingBuilder) {
            // Use your existing builder – no parameters
            NavigationStack {
                BlockBuilderView()
            }
        }
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
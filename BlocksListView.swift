import SwiftUI

struct BlocksListView: View {
    @EnvironmentObject var blocksRepository: BlocksRepository

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                header

                if blocksRepository.blocks.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(blocksRepository.blocks) { block in
                            NavigationLink {
                                BlockRunModeView(block: block)
                            } label: {
                                BlockCard(block: block)
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Blocks")
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Blocks")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(primaryTextColor)

            Text("Choose a block to run.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No blocks yet")
                .font(.headline)
                .foregroundColor(primaryTextColor)

            Text("Create a block in the builder, then come back here to run it.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 24)
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        Color(uiColor: .systemBackground)
    }

    private var primaryTextColor: Color {
        Color.primary
    }
}

// MARK: - Block Card

private struct BlockCard: View {
    let block: Block

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(block.name)
                .font(.headline)

            if let desc = block.description, !desc.isEmpty {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                if block.numberOfWeeks > 0 {
                    Text("\(block.numberOfWeeks) weeks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                let dayCount = block.days.count
                if dayCount > 0 {
                    Text("\(dayCount) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
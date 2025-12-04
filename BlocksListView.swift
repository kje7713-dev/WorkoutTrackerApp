import SwiftUI

struct BlocksListView: View {
    @EnvironmentObject var store: ProgramStore
    @State private var isShowingBuilder = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Blocks")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Choose a block to run or create a new one.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)

                // Content
                if store.blocks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No blocks yet")
                            .font(.headline)
                            .fontWeight(.bold)

                        Text("Create a block in the builder, then come back here to run it.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 16)

                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(store.blocks) { block in
                                NavigationLink {
                                    BlockRunModeView(block: block)
                                } label: {
                                    BlockCard(block: block)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal)

            // Primary “New Block” button
            Button {
                isShowingBuilder = true
            } label: {
                Text("New Block")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .navigationTitle("Blocks")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingBuilder) {
            NavigationStack {
                BlockBuilderView(isPresented: $isShowingBuilder)
                    .environmentObject(store)
            }
        }
    }
}

// Simple card for each block
struct BlockCard: View {
    let block: Block

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(block.name)
                .font(.headline)

            if let description = block.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Meta line: weeks + days/week
            let weeksText = "\(max(block.numberOfWeeks, 1)) week\(block.numberOfWeeks == 1 ? "" : "s")"
            let daysText = "\(block.days.count) day\(block.days.count == 1 ? "" : "s") / week"

            Text("\(weeksText) • \(daysText)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}
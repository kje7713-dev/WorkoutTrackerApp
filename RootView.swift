
import SwiftUI

/// Entry point root view for the simple block-based program.
struct SimpleProgramRootView: View {
    @StateObject private var store = ProgramStore()
    @State private var showingBuilder = false

    var body: some View {
        NavigationStack {
            VStack {
                if store.blocks.isEmpty {
                    Text("No blocks yet. Tap + to build one.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(store.blocks) { block in
                            NavigationLink {
                                BlockWeeksView(block: block)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(block.name)
                                        .font(.headline)
                                    Text("\(block.weeks) weeks • \(block.days.count) days • \(block.progression.rawValue) progression")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { indices in
                            store.blocks.remove(atOffsets: indices)
                        }
                    }
                }
            }
            .navigationTitle("Blocks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !store.blocks.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingBuilder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingBuilder) {
                NavigationStack {
                    BlockBuilderView()
                        .environmentObject(store)
                }
            }
        }
    }
}

// You can use this as your app entry root:
struct ContentView: View {
    var body: some View {
        SimpleProgramRootView()
    }
}

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }

            BlockListView()
                .tabItem {
                    Label("Blocks", systemImage: "square.grid.2x2")
                }
        }
    }
}

#Preview {
    ContentView()
}

import SwiftUI

// MARK: - Block Weeks & Summary

struct BlockWeeksView: View {
    let block: BlockTemplate
    @State private var selectedWeek: Int = 1

    var body: some View {
        List {
            Section {
                Picker("Week", selection: $selectedWeek) {
                    ForEach(1...block.weeks, id: \.self) { week in
                        Text("Week \(week)").tag(week)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Days") {
                ForEach(block.days) { day in
                    NavigationLink {
                        DayDetailView(block: block, day: day, week: selectedWeek)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(day.name)
                                .font(.headline)
                            Text("\(day.exercises.count) exercises")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(block.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

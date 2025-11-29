import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context

    // Grab all blocks; we'll pick an "active" one
    @Query(sort: \BlockTemplate.name, order: .forward)
    private var blocks: [BlockTemplate]

    @State private var isPushingSession = false
    @State private var currentSession: WorkoutSession?
    @State private var currentDay: DayTemplate?

    // MARK: - Derived

    /// Very simple: just use the first block for now
    private var activeBlock: BlockTemplate? {
        blocks.first
    }

    /// Sorted days in the active block
    private var sortedDaysInActiveBlock: [DayTemplate] {
        guard let block = activeBlock else { return [] }
        return block.days.sorted {
            if $0.weekIndex == $1.weekIndex {
                return $0.dayIndex < $1.dayIndex
            }
            return $0.weekIndex < $1.weekIndex
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if blocks.isEmpty {
                    VStack(spacing: 12) {
                        Text("No Block Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Create a block in the Blocks tab to get your first programmed workout.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else if let block = activeBlock,
                          let (day, session) = nextDayAndSession(for: block) {
                    // Show today's workout card + a link into the session
                    VStack(alignment: .leading, spacing: 24) {
                        QuoteHeader()

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today's Block")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(block.name)
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Today’s Workout")
                                .font(.headline)

                            Text("Week \(day.weekIndex) • Day \(day.dayIndex) – \(day.title)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(day.dayDescription)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                        )

                        NavigationLink(
                            destination: WorkoutSessionView(session: session, day: day),
                            isActive: $isPushingSession
                        ) {
                            Text("Start Today’s Workout")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }

                        Spacer()
                    }
                    .padding()
                    .onAppear {
                        // make sure state lines up if we navigated here fresh
                        self.currentSession = session
                        self.currentDay = day
                    }
                } else {
                    // Fallback if something is off
                    Text("No workout for today could be found.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Helpers

    /// Find the next "incomplete" day in the block and either:
    /// - reuse the existing WorkoutSession for that day, or
    /// - create a new one.
    private func nextDayAndSession(for block: BlockTemplate) -> (DayTemplate, WorkoutSession)? {
        // Sort days in a stable block order
        let days = sortedDaysInActiveBlock
        guard !days.isEmpty else { return nil }

        // Try to find the first day in the block where the session is
        // missing or not completed.
        for day in days {
            if let existing = fetchSession(for: day, in: block) {
                if !existing.isCompleted {
                    return (day, existing)
                } else {
                    continue
                }
            } else {
                // No session yet → create one
                let newSession = createSession(for: day, in: block)
                return (day, newSession)
            }
        }

        // If every session is completed, just use the last day’s session
        if let lastDay = days.last {
            let session = fetchSession(for: lastDay, in: block) ?? createSession(for: lastDay, in: block)
            return (lastDay, session)
        }

        return nil
    }

    // 🔧 SIMPLIFIED PREDICATE – fixes the macro error
    private func fetchSession(for day: DayTemplate, in block: BlockTemplate) -> WorkoutSession? {
        let week = day.weekIndex
        let dayIndex = day.dayIndex

        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { session in
                session.weekIndex == week &&
                session.dayIndex == dayIndex
            }
        )

        do {
            let results = try context.fetch(descriptor)
            return results.first
        } catch {
            print("Error fetching session for TodayView: \(error)")
            return nil
        }
    }

    private func createSession(for day: DayTemplate, in block: BlockTemplate) -> WorkoutSession {
        let session = WorkoutSession(
            weekIndex: day.weekIndex,
            dayIndex: day.dayIndex,
            isCompleted: false,
            notes: nil,
            blockTemplate: block,
            dayTemplate: day
        )

        // Build exercises + sets from this day’s plan
        for planned in day.exercises.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            let sessionExercise = SessionExercise(
                orderIndex: planned.orderIndex,
                session: session,
                exerciseTemplate: planned.exerciseTemplate,
                nameOverride: planned.exerciseTemplate?.name
            )

            for pSet in planned.prescribedSets.sorted(by: { $0.setIndex < $1.setIndex }) {
                let set = SessionSet(
                    setIndex: pSet.setIndex,
                    targetReps: pSet.targetReps,
                    targetWeight: pSet.targetWeight,
                    targetRPE: pSet.targetRPE,
                    actualReps: pSet.targetReps,
                    actualWeight: pSet.targetWeight,
                    actualRPE: nil,
                    completed: false,
                    timestamp: nil,
                    notes: nil,
                    sessionExercise: sessionExercise
                )
                sessionExercise.sets.append(set)
            }

            session.exercises.append(sessionExercise)
        }

        context.insert(session)
        do {
            try context.save()
        } catch {
            print("Error saving new session from TodayView: \(error)")
        }

        return session
    }
}
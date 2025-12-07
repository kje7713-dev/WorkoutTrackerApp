//
//  WorkoutSessionView.swift
//  Savage By Design
//
//  Phase 8: Session Execution (inline scroll log, Option 1)
//
//  Uses existing domain models:
//  - WorkoutSession
//  - SessionExercise
//  - SessionSet
//  - Block / DayTemplate via BlocksRepository
//
//  No model changes, no new fields.
//

import SwiftUI

struct WorkoutSessionView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.sbdTheme) private var theme

    @EnvironmentObject private var blocksRepository: BlocksRepository
    @EnvironmentObject private var sessionsRepository: SessionsRepository

    // MARK: - State

    @State private var session: WorkoutSession

    // MARK: - Init

    init(session: WorkoutSession) {
        _session = State(initialValue: session)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 16) {
                header

                progressBar

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(session.exercises.indices, id: \.self) { idx in
                            SessionExerciseCardView(exercise: $session.exercises[idx])
                        }
                    }
                    .padding(.vertical, 8)
                }

                footerButton
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(primaryButtonTitle) {
                    saveSessionAndDismiss()
                }
                .fontWeight(.bold)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        let block = blocksRepository.blocks.first { $0.id == session.blockId }
        let dayName = block?
            .days
            .first(where: { $0.id == session.dayTemplateId })?
            .name ?? "Day"

        return VStack(alignment: .leading, spacing: 4) {
            Text(block?.name ?? "Session")
                .font(.title2).bold()

            Text(dayName)
                .font(.subheadline)
                .foregroundColor(theme.mutedText)

            Text("Week \(session.weekIndex)")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Progress

    private var totalSetCount: Int {
        session.exercises.reduce(0) { partial, exercise in
            partial + exercise.loggedSets.count
        }
    }

    private var completedSetCount: Int {
        session.exercises.reduce(0) { partial, exercise in
            partial + exercise.loggedSets.filter { $0.isCompleted }.count
        }
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            if totalSetCount > 0 {
                ProgressView(
                    value: Double(completedSetCount),
                    total: Double(totalSetCount)
                )
                Text("\(completedSetCount) of \(totalSetCount) sets completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No sets in this session.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Footer

    private var footerButton: some View {
        Button {
            saveSessionAndDismiss()
        } label: {
            Text(primaryButtonTitle)
                .font(.headline).bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(24)
        }
        .padding(.bottom, 8)
    }

    private var primaryButtonTitle: String {
        switch session.status {
        case .notStarted:
            return "Start Session"
        case .inProgress:
            return "Save Session"
        case .completed:
            return "Save Changes"
        @unknown default:
            return "Save Session"
        }
    }

    // MARK: - Save

    private func saveSessionAndDismiss() {
        // Stamp date first time this session is saved/opened
        if session.date == nil {
            session.date = Date()
        }

        // Derive status from completion
        if totalSetCount > 0 && completedSetCount == totalSetCount {
            session.status = .completed
        } else if completedSetCount > 0 {
            session.status = .inProgress
        } else {
            session.status = .notStarted
        }

        sessionsRepository.save(session)
        dismiss()
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        theme.backgroundLight
    }
}

// MARK: - SessionExerciseCardView

/// A card showing one SessionExercise with its sets inline.
private struct SessionExerciseCardView: View {
    @Binding var exercise: SessionExercise
    @Environment(\.sbdTheme) private var theme

    private var exerciseName: String {
        if let custom = exercise.customName, !custom.isEmpty {
            return custom
        } else {
            return "Exercise"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title / name
            Text(exerciseName)
                .font(.headline)

            // Optional inline name editing (session-local)
            TextField(
                "Custom name (optional)",
                text: Binding(
                    get: { exercise.customName ?? "" },
                    set: { newValue in
                        exercise.customName = newValue.isEmpty ? nil : newValue
                    }
                )
            )
            .font(.subheadline)
            .textFieldStyle(.roundedBorder)
            .disableAutocorrection(true)
            .autocapitalization(.words)

            // Sets
            let count = min(exercise.expectedSets.count, exercise.loggedSets.count)
            if count > 0 {
                ForEach(0..<count, id: \.self) { index in
                    SessionSetRowView(
                        index: index,
                        expected: exercise.expectedSets[index],
                        logged: $exercise.loggedSets[index]
                    )
                }
            } else {
                Text("No sets configured for this exercise.")
                    .font(.footnote)
                    .foregroundColor(theme.mutedText)
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

// MARK: - SessionSetRowView

/// Shows a single SessionSet with expected vs logged values and a completion toggle.
private struct SessionSetRowView: View {
    let index: Int
    let expected: SessionSet
    @Binding var logged: SessionSet

    @Environment(\.sbdTheme) private var theme

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Set index
            Text("Set \(index + 1)")
                .font(.caption)
                .frame(width: 50, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                expectedRow
                loggedRow
            }

            Spacer()

            Button {
                logged.isCompleted.toggle()
            } label: {
                Image(systemName: logged.isCompleted ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.gray.opacity(0.2))
        )
    }

    // MARK: - Expected / Logged Rows

    private var expectedRow: some View {
        HStack(spacing: 8) {
            Text("Planned:")
                .font(.caption)
                .foregroundColor(.secondary)

            if let reps = expected.expectedReps {
                Text("\(reps)x")
                    .font(.caption)
            }

            if let weight = expected.expectedWeight {
                Text("\(clean(weight))")
                    .font(.caption)
            }

            if let time = expected.expectedTime {
                Text("\(clean(time))s")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if let distance = expected.expectedDistance {
                Text("\(clean(distance))m")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if let cals = expected.expectedCalories {
                Text("\(clean(cals)) cal")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var loggedRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("Logged:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Reps
                TextField(
                    "Reps",
                    text: bindingForInt(
                        get: { logged.loggedReps },
                        set: { logged.loggedReps = $0 }
                    )
                )
                .keyboardType(.numberPad)
                .font(.caption)
                .frame(width: 50)

                // Weight
                TextField(
                    "Wt",
                    text: bindingForDouble(
                        get: { logged.loggedWeight },
                        set: { logged.loggedWeight = $0 }
                    )
                )
                .keyboardType(.decimalPad)
                .font(.caption)
                .frame(width: 60)

                // Time
                TextField(
                    "Time (s)",
                    text: bindingForDouble(
                        get: { logged.loggedTime },
                        set: { logged.loggedTime = $0 }
                    )
                )
                .keyboardType(.decimalPad)
                .font(.caption2)
                .frame(width: 70)

                // Distance
                TextField(
                    "m",
                    text: bindingForDouble(
                        get: { logged.loggedDistance },
                        set: { logged.loggedDistance = $0 }
                    )
                )
                .keyboardType(.decimalPad)
                .font(.caption2)
                .frame(width: 60)

                // Calories
                TextField(
                    "cal",
                    text: bindingForDouble(
                        get: { logged.loggedCalories },
                        set: { logged.loggedCalories = $0 }
                    )
                )
                .keyboardType(.decimalPad)
                .font(.caption2)
                .frame(width: 60)
            }

            TextField(
                "Notes (optional)",
                text: Binding(
                    get: { logged.notes ?? "" },
                    set: { newValue in
                        logged.notes = newValue.isEmpty ? nil : newValue
                    }
                )
            )
            .font(.caption)
        }
    }

    // MARK: - Helpers

    private func clean(_ value: Double) -> String {
        if value.rounded(.towardZero) == value {
            return String(Int(value))
        } else {
            return String(value)
        }
    }

    private func bindingForInt(
        get: @escaping () -> Int?,
        set: @escaping (Int?) -> Void
    ) -> Binding<String> {
        Binding<String>(
            get: {
                guard let value = get() else { return "" }
                return String(value)
            },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty {
                    set(nil)
                } else if let intValue = Int(trimmed) {
                    set(intValue)
                }
            }
        )
    }

    private func bindingForDouble(
        get: @escaping () -> Double?,
        set: @escaping (Double?) -> Void
    ) -> Binding<String> {
        Binding<String>(
            get: {
                guard let value = get() else { return "" }
                return clean(value)
            },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty {
                    set(nil)
                } else if let doubleValue = Double(trimmed) {
                    set(doubleValue)
                }
            }
        )
    }
}
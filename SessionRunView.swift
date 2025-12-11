//
//  SessionRunView.swift
//  Savage By Design
//
//  Phase 7/8: Consolidated session execution view using canonical models.
//  (Previously BlockRunModeView)
//

import SwiftUI

// MARK: - Session Runner Container

// 🚨 RENAMED FROM BlockRunModeView
struct SessionRunView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.sbdTheme) private var theme
    @EnvironmentObject private var sessionsRepository: SessionsRepository
    @EnvironmentObject private var blocksRepository: BlocksRepository // Needed for header context

    // 🚨 NOW uses the canonical Session model
    @State private var session: WorkoutSession
    
    // This is ONLY used to get the day name/short code from the original block template.
    private var block: Block? {
        blocksRepository.blocks.first { $0.id == session.blockId }
    }
    
    // 🚨 Initializer now takes a WorkoutSession
    init(session: WorkoutSession) {
        _session = State(initialValue: session)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar // Now uses the session model for context

            // DayTabBar should ideally be in the parent view, but we keep it here 
            // for compilation compatibility if the parent hasn't been updated.
            DayTabBar(
                days: block?.days ?? [], 
                currentDayIndex: .constant(0) // FIX: Hardcode to constant for compilation safety
            )
            Divider()
            
            content
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    saveSessionAndDismiss(isCancel: true)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save Session") {
                    saveSessionAndDismiss(isCancel: false)
                }
                .fontWeight(.bold)
            }
        }
        .onDisappear {
            // FIX: Use onDisappear as the reliable save hook for gesture dismissals/cancellation
            saveSessionAndDismiss(isCancel: true)
        }
    } // <--- END OF SessionRunView.body


    private var content: some View {
        // We show all exercises in the loaded session object.
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach($session.exercises) { $exercise in
                    SessionExerciseCardView(exercise: $exercise)
                }
            }
            .padding(.horizontal)
            .padding(.vertical)
        }
    }

    private var topBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Block name BIG
            Text(block?.name ?? "Workout Session")
                .font(.largeTitle)
                .fontWeight(.black)
                .textCase(.uppercase)
                .kerning(1.2)

            // Full day name (primary)
            let dayTemplate = block?.days.first { $0.id == session.dayTemplateId }

            Text(dayTemplate?.name ?? "Day")
                .font(.headline)
                .fontWeight(.semibold)

            // Short code + week in secondary role
            Text("Week \(session.weekIndex) • \(dayTemplate?.shortCode?.uppercased() ?? "SESSION")")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .kerning(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
    

    private func saveSessionAndDismiss(isCancel: Bool) {
        // Stamp date first time this session is saved/opened
        if session.date == nil {
            session.date = Date()
        }

        let totalSetCount = session.exercises.reduce(0) { partial, exercise in
            partial + exercise.loggedSets.count
        }
        let completedSetCount = session.exercises.reduce(0) { partial, exercise in
            partial + exercise.loggedSets.filter { $0.isCompleted }.count
        }

        // Derive status from completion
        if totalSetCount > 0 && completedSetCount == totalSetCount {
            session.status = .completed
        } else if completedSetCount > 0 {
            session.status = .inProgress
        } else {
            // If the user hasn't logged anything, status remains notStarted
            session.status = .notStarted
        }

        // FIX: Persist the current state to the repository
        sessionsRepository.save(session)
        
        // Only explicitly dismiss if it's NOT a background/cancel save, 
        // as cancel/gesture-dismiss will be handled implicitly or by the button action.
        if !isCancel {
            dismiss()
        }
    }
} // <--- END OF SessionRunView struct (CRITICAL CLOSURE)


// MARK: - Day Tabs (Remains largely the same)

struct DayTabBar: View {
    let days: [DayTemplate]
    @Binding var currentDayIndex: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    dayButton(for: day, index: index)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private func dayButton(for day: DayTemplate, index: Int) -> some View {
        let isSelected = index == currentDayIndex
        let label: String

        if let short = day.shortCode, !short.isEmpty {
            label = short
        } else {
            label = day.name
        }

        return Button(action: {
            currentDayIndex = index
        }) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.black : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.black, lineWidth: isSelected ? 0 : 1)
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}


// MARK: - Exercise Card View

private struct SessionExerciseCardView: View {
    @Binding var exercise: SessionExercise
    @Environment(\.sbdTheme) private var theme

    private var exerciseName: String {
        // FIX: Prioritize the session-local custom name, which came from the template
        if let custom = exercise.customName, !custom.isEmpty {
            return custom
        } else {
            // Use a clear placeholder if no name exists.
            return "Untitled Exercise" 
        }
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Display/Edit name
            Text(exerciseName) // FIX: Display the resolved name
                .font(.headline)
                .padding(.top, 4)

            // Name edit field (using a binding helper)
            TextField("Exercise name", text: Binding(
                get: { exercise.customName ?? "" },
                set: { exercise.customName = $0.isEmpty ? nil : $0 }
            ))
            .font(.subheadline)
            .textFieldStyle(.roundedBorder)
            .disableAutocorrection(true)
            .autocapitalization(.words)

            // Sets
            // Uses loggedSets for the actual run-time data
            ForEach(exercise.loggedSets.indices, id: \.self) { index in
                SessionSetRunRow(
                    index: index,
                    expected: exercise.expectedSets[index],
                    logged: $exercise.loggedSets[index]
                )
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


// MARK: - Session Set Row View

private struct SessionSetRunRow: View {
    let index: Int
    let expected: SessionSet
    @Binding var logged: SessionSet

    @Environment(\.sbdTheme) private var theme

    // Formatters
    private static let integerFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.maximumFractionDigits = 0
        f.minimumFractionDigits = 0
        return f
    }()

    private static let weightFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.maximumFractionDigits = 1
        f.minimumFractionDigits = 0
        return f
    }()

    // Helper to format a Double for display
    private func cleanDouble(_ value: Double?) -> String? {
        guard let value = value, value > 0 else { return nil }
        if value.rounded(.towardZero) == value {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Text("Set \(index + 1)")
                .font(.subheadline).bold()
            
            // Planned summary (Display-only)
            expectedRow
            
            // Controls depend on the expected data in the set
            if expected.expectedReps != nil || expected.expectedWeight != nil || expected.rpe != nil || expected.rir != nil {
                strengthControls
            } else if expected.expectedTime != nil || expected.expectedCalories != nil || expected.expectedDistance != nil || expected.expectedRounds != nil {
                conditioningControls
            }

            // Notes field
            TextField(
                "Notes (RPE, cues, etc.)",
                text: $logged.notes.toNonOptionalString(), 
                axis: .vertical
            )
            .font(.footnote)
            .textFieldStyle(.roundedBorder)

            // Complete / Undo
            HStack {
                Spacer()
                Button {
                    logged.isCompleted.toggle()
                } label: {
                    Text(logged.isCompleted ? "Undo" : "Complete")
                }
                .font(logged.isCompleted ? .caption : .subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                // FIX: Use the branding fix previously requested
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(logged.isCompleted ? Color.gray.opacity(0.4) : Color.black, lineWidth: 1)
                )
                .foregroundColor(logged.isCompleted ? .secondary : .primary)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
                // FIX: Add a subtle green border on completion
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(logged.isCompleted ? .green : .clear, lineWidth: 2)
                )
        )
        // FIX: Remove the old checkmark overlay entirely
        .padding(.vertical, 2)
    }

    // MARK: - Expected Row Display

    private var expectedRow: some View {
        let plannedParts: [String] = [
            expected.expectedReps.map { "\($0)x" },
            expected.expectedWeight.flatMap(cleanDouble).map { "\($0)lb" },
            expected.expectedTime.flatMap(cleanDouble).map { "\($0)s" },
            expected.expectedDistance.flatMap(cleanDouble).map { "\($0)m" },
            expected.expectedCalories.flatMap(cleanDouble).map { "\($0) cal" },
            expected.tempo.map { "Tempo: \($0)" },
            expected.restSeconds.map { "Rest: \($0)s" }
        ].compactMap { $0 }

        return Text("Planned: \(plannedParts.joined(separator: " • "))")
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(.bottom, 4)
    }


    // MARK: - Strength UI (Uses SetControlView and Pickers)

    private var strengthControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(spacing: 20) {
                // Reps Control (if planned reps exist)
                if expected.expectedReps != nil {
                    SetControlView(
                        label: "REPS",
                        unit: "reps",
                        value: $logged.loggedReps.toDouble(),
                        step: 1.0,
                        formatter: Self.integerFormatter,
                        min: 0.0
                    )
                }

                // Weight Control (if planned weight exists)
                if expected.expectedWeight != nil {
                    SetControlView(
                        label: "WEIGHT",
                        unit: "lb",
                        value: $logged.loggedWeight,
                        step: 5.0,
                        formatter: Self.weightFormatter,
                        min: 0.0
                    )
                }
            }
            
            // 🚨 FIX: Integrate RPE/RIR Pickers
            HStack(spacing: 20) {
                RpePickerView(rpe: $logged.rpe)
                RirPickerView(rir: $logged.rir)
            }
        }
    }


    // MARK: - Conditioning UI (Uses SetControlView)

    private var conditioningControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ... (Conditioning controls remain the same, relying on SetControls.swift)
            
            // Time (Minutes) Control
            if expected.expectedTime != nil {
                SetControlView(
                    label: "TIME",
                    unit: "min",
                    value: $logged.loggedTime.toMinutes(),
                    step: 1.0, 
                    formatter: Self.integerFormatter,
                    min: 0.0
                )
            }

            // Distance Control
            if expected.expectedDistance != nil {
                SetControlView(
                    label: "DISTANCE",
                    unit: "m",
                    value: $logged.loggedDistance,
                    step: 100.0, 
                    formatter: Self.integerFormatter,
                    min: 0.0
                )
            }
            
            // Calories Control
            if expected.expectedCalories != nil {
                SetControlView(
                    label: "CALORIES",
                    unit: "cal",
                    value: $logged.loggedCalories,
                    step: 5.0, 
                    formatter: Self.integerFormatter,
                    min: 0.0
                )
            }
            
            // Rounds Control
            if expected.expectedRounds != nil {
                SetControlView(
                    label: "ROUNDS",
                    unit: "rounds",
                    value: $logged.loggedRounds.toDouble(),
                    step: 1.0, 
                    formatter: Self.integerFormatter,
                    min: 0.0
                )
            }
        }
    }
}

// MARK: - RPE/RIR Pickers (Standardized Ranges)

private struct RpePickerView: View {
    @Binding var rpe: Double?
    
    // RPE standard working range: 6.0 to 10.0 in 0.5 increments.
    private let rpeRange: [Double] = Array(stride(from: 6.0, through: 10.0, by: 0.5))

    var body: some View {
        HStack {
            Text("RPE")
                .font(.caption2)
                .foregroundColor(.secondary)

            // Picker
            Picker("RPE", selection: $rpe) {
                Text("-").tag(nil as Double?)
                ForEach(rpeRange, id: \.self) { value in
                    Text(value.truncatingRemainder(dividingBy: 1) == 0 ? 
                         String(format: "%.0f", value) : String(format: "%.1f", value))
                    .tag(Optional(value) as Double?)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 80)
        }
    }
}

private struct RirPickerView: View {
    @Binding var rir: Double?
    
    // RIR standard working range: 0 to 4 in 1.0 increments.
    private let rirRange: [Double] = Array(stride(from: 0.0, through: 4.0, by: 1.0))

    var body: some View {
        HStack {
            Text("RIR")
                .font(.caption2)
                .foregroundColor(.secondary)

            // Picker
            Picker("RIR", selection: $rir) {
                Text("-").tag(nil as Double?)
                ForEach(rirRange, id: \.self) { value in
                    Text(String(format: "%.0f", value))
                        .tag(Optional(value) as Double?)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: 80)
        }
    }
}

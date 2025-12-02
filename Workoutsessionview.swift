import SwiftUI

// MARK: - Session View

struct WorkoutSessionView: View {
    @State private var session: WorkoutSession

    init(session: WorkoutSession) {
        _session = State(initialValue: session)
    }

    private var completedCount: Int {
        session.exercises.filter { $0.isCompleted }.count
    }

    private var progress: Double {
        guard !session.exercises.isEmpty else { return 0 }
        return Double(completedCount) / Double(session.exercises.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard

                Text("EXERCISES")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                ForEach(session.exercises.indices, id: \.self) { index in
                    ExerciseCardView(
                        exercise: $session.exercises[index]
                    )
                    .padding(.horizontal)
                }

                Button {
                    let new = Exercise(name: "", reps: 5, weight: nil, isCompleted: false)
                    session.exercises.append(new)
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .padding(.top, 12)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Workout Session")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.dayTitle)
                .font(.title3).bold()

            Text(session.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider().padding(.vertical, 4)

            Text("Session Progress")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            ProgressView(value: progress)
                .tint(.blue)

            Text("\(completedCount) of \(session.exercises.count) sets completed")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}

// MARK: - Exercise Card with dropdown

struct ExerciseCardView: View {
    @Binding var exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Dropdown for exercise name
                ExerciseNamePicker(selectedName: $exercise.name)

                Spacer()

                Toggle(isOn: $exercise.isCompleted) {
                    Text("Done")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .labelsHidden()
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Reps:")
                        .font(.subheadline)
                    TextField("Reps", value: $exercise.reps, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                }

                HStack {
                    Text("Weight:")
                        .font(.subheadline)
                    TextField("lb", value: Binding(
                        get: { exercise.weight ?? 0 },
                        set: { exercise.weight = $0 }
                    ), format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 90)

                    Text("lb")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if exercise.isCompleted {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Set logged")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Exercise dropdown using master list

struct ExerciseNamePicker: View {
    @Binding var selectedName: String

    var body: some View {
        Menu {
            ForEach(ExerciseLibrary.masterNames, id: \.self) { name in
                Button(name) {
                    selectedName = name
                }
            }
        } label: {
            HStack {
                Text(selectedName.isEmpty ? "Choose exercise" : selectedName)
                    .font(.headline)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .tertiarySystemFill))
            )
        }
    }
}
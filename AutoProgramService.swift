import Foundation
import SwiftData

// MARK: - Auto-program config

/// Single source of truth for BlockGoal used by UI + service
enum BlockGoal: String, CaseIterable, Identifiable, Codable {
    case strength
    case hypertrophy
    case peaking

    var id: String { rawValue }
}

struct AutoProgramConfig {
    let name: String                 // "SBD Block 1 – 4 Week Strength"
    let goal: BlockGoal
    let weeksCount: Int              // e.g. 4
    let daysPerWeek: Int             // e.g. 4
    let mainLifts: [String]          // e.g. ["Squat", "Bench", "Deadlift"]

    /// Training maxes for main lifts (same names as mainLifts)
    let trainingMaxes: [String: Double]  // ["Squat": 405, "Bench": 285, ...]
}

// MARK: - Auto-programming service

enum AutoProgramError: Error {
    case noTrainingMax(String)
}

struct AutoProgramService {

    /// Generates a BlockTemplate (+ days/exercises/sets) and saves it to SwiftData.
    /// Returns the created BlockTemplate so you can use it in UI.
    @discardableResult
    static func generateBlock(
        in context: ModelContext,
        config: AutoProgramConfig
    ) throws -> BlockTemplate {

        // 1. Create the block
        let block = BlockTemplate(
            name: config.name,
            weeksCount: config.weeksCount,
            createdAt: .now,
            createdByUser: true,
            notes: "Auto-programmed \(config.goal.rawValue.capitalized) block"
        )

        context.insert(block)

        // 2. Define a simple weekly % pattern based on goal
        let percentPattern: [Double]
        switch config.goal {
        case .strength:
            // training block ramp
            percentPattern = [0.70, 0.75, 0.80, 0.85]
        case .hypertrophy:
            // a bit lighter, more volume
            percentPattern = [0.65, 0.70, 0.70, 0.75]
        case .peaking:
            // heavier, taper last week
            percentPattern = [0.80, 0.85, 0.90, 0.70]
        }

        // 3. Simple day “roles” for 4-day SBD style block (can expand later)
        let dayRoles: [Int: String] = [
            1: "Heavy Upper",
            2: "Volume Lower",
            3: "Heavy Lower",
            4: "Accessory / Conditioning"
        ]

        // 4. Ensure we have (or create) ExerciseTemplate entries
        var exerciseTemplatesByName: [String: ExerciseTemplate] = [:]

        func template(for name: String, category: String?) -> ExerciseTemplate {
            if let cached = exerciseTemplatesByName[name] {
                return cached
            }
            // Try to find existing template in store
            let descriptor = FetchDescriptor<ExerciseTemplate>(
                predicate: #Predicate { $0.name == name }
            )
            let existing = try? context.fetch(descriptor).first
            if let existing {
                exerciseTemplatesByName[name] = existing
                return existing
            }

            let tmpl = ExerciseTemplate(
                name: name,
                category: category,
                defaultReps: nil,
                defaultSets: nil,
                defaultRPE: nil,
                defaultTempo: nil,
                notes: nil
            )
            context.insert(tmpl)
            exerciseTemplatesByName[name] = tmpl
            return tmpl
        }

        // 5. Build weeks & days
        for weekIndex in 1...config.weeksCount {
            // Clamp % array if weeksCount > pattern size
            let pct = percentPattern[min(weekIndex - 1, percentPattern.count - 1)]

            for dayIndex in 1...config.daysPerWeek {
                let role = dayRoles[dayIndex] ?? "Day \(dayIndex)"
                let roleKey = canonicalRoleKey(for: role)

                let day = DayTemplate(
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    title: role,
    dayDescription: description(for: role, goal: config.goal),
    orderIndex: dayIndex,
    block: block
)

// Set the roleKey after init
day.roleKey = role

block.days.append(day)

                for (exerciseOrder, lift) in plannedLifts.enumerated() {
                    let exerciseName = lift.name
                    let category = lift.category
                    let sets = lift.sets
                    let reps = lift.reps

                    let tm = config.trainingMaxes[lift.tmKey]
                    if tm == nil && lift.usesTM {
                        throw AutoProgramError.noTrainingMax(lift.tmKey)
                    }

                    let eTemplate = template(for: exerciseName, category: category)

                    let planned = PlannedExercise(
                        orderIndex: exerciseOrder,
                        exerciseTemplate: eTemplate,
                        day: day,
                        notes: nil
                    )
                    day.exercises.append(planned)

                    // Build prescribed sets
                    for setIndex in 1...sets {
                        let weight: Double
                        if lift.usesTM, let tm {
                            weight = tm * pct
                        } else {
                            weight = lift.fixedWeight ?? 0
                        }

                        let set = PrescribedSet(
                            setIndex: setIndex,
                            targetReps: reps,
                            targetWeight: weight,
                            targetRPE: lift.targetRPE,
                            tempo: nil,
                            notes: nil,
                            plannedExercise: planned
                        )
                        planned.prescribedSets.append(set)
                    }
                }
            }
        }

        try context.save()
        return block
    }

    // MARK: - Helpers

    /// Machine-friendly key for the role label so ChatGPT can reliably act on it.
    private static func canonicalRoleKey(for role: String) -> String {
        // "Heavy Upper" -> "heavy_upper"
        // "Accessory / Conditioning" -> "accessory_conditioning"
        role
            .lowercased()
            .replacingOccurrences(of: " / ", with: "_")
            .replacingOccurrences(of: " ", with: "_")
    }

    /// Simple description templates
    private static func description(for role: String, goal: BlockGoal) -> String {
        switch (role, goal) {
        case ("Heavy Upper", .strength):
            return "Primary bench variation heavy for low reps plus upper-body accessories."
        case ("Volume Lower", .strength):
            return "Squat-focused volume work in moderate rep ranges."
        case ("Heavy Lower", .strength):
            return "Primary squat or deadlift heavy for low reps with posterior chain accessories."
        case ("Accessory / Conditioning", _):
            return "Single-leg work, core, and conditioning intervals. Keep RPE moderate."
        default:
            return "\(role) session focused on \(goal.rawValue)."
        }
    }

    /// A tiny internal “template” to drive per-day exercise choices.
    private struct DayLift {
        let name: String
        let category: String?
        let sets: Int
        let reps: Int
        let usesTM: Bool
        let tmKey: String
        let fixedWeight: Double?
        let targetRPE: Double?
    }

    private static func liftsForDay(
        role: String,
        mainLifts: [String]
    ) -> [DayLift] {
        let squat = mainLifts.first { $0.lowercased().contains("squat") } ?? "Back Squat"
        let bench = mainLifts.first { $0.lowercased().contains("bench") } ?? "Bench Press"
        let dead  = mainLifts.first { $0.lowercased().contains("dead")  } ?? "Deadlift"

        switch role {
        case "Heavy Upper":
            return [
                DayLift(name: bench, category: "Press", sets: 5, reps: 3,
                        usesTM: true, tmKey: bench, fixedWeight: nil, targetRPE: 8.0),
                DayLift(name: "Incline DB Press", category: "Press", sets: 4, reps: 8,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0),
                DayLift(name: "Barbell Row", category: "Pull", sets: 4, reps: 8,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0)
            ]

        case "Volume Lower":
            return [
                DayLift(name: squat, category: "Squat", sets: 4, reps: 6,
                        usesTM: true, tmKey: squat, fixedWeight: nil, targetRPE: 7.5),
                DayLift(name: "RDL", category: "Hinge", sets: 4, reps: 8,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0),
                DayLift(name: "Walking Lunge", category: "Single-leg", sets: 3, reps: 10,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0)
            ]

        case "Heavy Lower":
            return [
                DayLift(name: dead, category: "Hinge", sets: 5, reps: 3,
                        usesTM: true, tmKey: dead, fixedWeight: nil, targetRPE: 8.0),
                DayLift(name: "Paused Squat", category: "Squat", sets: 3, reps: 5,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 8.0),
                DayLift(name: "Back Extension", category: "Accessory", sets: 3, reps: 12,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0)
            ]

        case "Accessory / Conditioning":
            return [
                DayLift(name: "Bulgarian Split Squat", category: "Single-leg", sets: 3, reps: 10,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0),
                DayLift(name: "Hanging Leg Raise", category: "Core", sets: 3, reps: 12,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0),
                DayLift(name: "Bike Intervals", category: "Conditioning", sets: 6, reps: 30,
                        usesTM: false, tmKey: "", fixedWeight: 0, targetRPE: 7.0)
            ]

        default:
            // fallback: just cycle main lifts
            return [
                DayLift(name: squat, category: "Squat", sets: 4, reps: 5,
                        usesTM: true, tmKey: squat, fixedWeight: nil, targetRPE: 7.5),
                DayLift(name: bench, category: "Press", sets: 4, reps: 5,
                        usesTM: true, tmKey: bench, fixedWeight: nil, targetRPE: 7.5),
                DayLift(name: dead, category: "Hinge", sets: 3, reps: 3,
                        usesTM: true, tmKey: dead, fixedWeight: nil, targetRPE: 8.0)
            ]
        }
    }
}
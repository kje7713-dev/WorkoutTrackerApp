import Foundation
import SwiftData

// MARK: - Auto-program config

enum BlockGoal: String, CaseIterable, Identifiable, Codable {
    case strength
    case hypertrophy
    case peaking
    
    var id: String { rawValue }
}

struct AutoProgramConfig {
    let name: String                 // e.g. "SBD Block 1 – 4 Week Strength"
    let goal: BlockGoal
    let weeksCount: Int              // e.g. 4
    let daysPerWeek: Int             // e.g. 4
    let mainLifts: [String]          // e.g. ["Squat", "Bench", "Deadlift"]
    
    /// Training maxes for main lifts (same names as mainLifts)
    let trainingMaxes: [String: Double]  // ["Squat": 405, "Bench": 285, ...]
}

// MARK: - Auto-programming service

enum AutoProgramError: Error {
    case invalidConfig
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
        
        guard config.weeksCount > 0, config.daysPerWeek > 0 else {
            throw AutoProgramError.invalidConfig
        }
        
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
        
        // 3. Internal layout “roles” for how we place lifts.
        // Titles shown to the user will be derived from the actual lifts,
        // not these labels.
        let dayRoles = [
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
                let layoutRole = dayRoles[dayIndex] ?? "Day \(dayIndex)"
                
                // Decide which lifts live on this day
                let plannedLifts = liftsForDay(
                    role: layoutRole,
                    mainLifts: config.mainLifts
                )
                
                // Title shown to the user based on actual lifts
                let title = focusTitle(for: plannedLifts)
                
                let day = DayTemplate(
                    weekIndex: weekIndex,
                    dayIndex: dayIndex,
                    title: title,
                    dayDescription: description(for: title, goal: config.goal),
                    orderIndex: dayIndex,
                    block: block
                )
                block.days.append(day)
                
                for (exerciseOrder, lift) in plannedLifts.enumerated() {
                    let exerciseName = lift.name
                    let category = lift.category
                    let sets = lift.sets
                    let reps = lift.reps
                    
                    let tm = config.trainingMaxes[lift.tmKey]
                    if lift.usesTM, tm == nil {
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
    
    /// Description based on the focus title + goal
    private static func description(for role: String, goal: BlockGoal) -> String {
        let lower = role.lowercased()
        
        switch goal {
        case .strength:
            if lower.contains("bench") {
                return "Primary bench variation heavy for low reps plus upper-body accessories."
            } else if lower.contains("squat") {
                return "Squat-focused heavy work with supporting lower-body accessories."
            } else if lower.contains("deadlift") || lower.contains("dead") {
                return "Primary deadlift-focused heavy work with posterior chain accessories."
            }
            return "\(role) session focusing on strength."
            
        case .hypertrophy:
            if lower.contains("bench") {
                return "Bench-focused session with moderate reps and high upper-body volume."
            } else if lower.contains("squat") {
                return "Squat-focused session with moderate reps and high lower-body volume."
            } else if lower.contains("deadlift") || lower.contains("dead") {
                return "Deadlift-focused session with moderate reps and posterior chain volume."
            }
            return "\(role) session focusing on muscle growth."
            
        case .peaking:
            if lower.contains("bench") {
                return "Bench-focused peaking work with heavier loads and lower reps."
            } else if lower.contains("squat") {
                return "Squat-focused peaking work with heavier loads and lower reps."
            } else if lower.contains("deadlift") || lower.contains("dead") {
                return "Deadlift-focused peaking work with heavier loads and lower reps."
            }
            return "\(role) session focusing on peaking performance."
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
    
    /// Title shown to the user, based on what the main lift of the day is.
    private static func focusTitle(for lifts: [DayLift]) -> String {
        guard let primary = lifts.first(where: { $0.usesTM }) ?? lifts.first else {
            return "Training Day"
        }
        
        let lower = primary.name.lowercased()
        if lower.contains("bench") {
            return "Bench Focus"
        } else if lower.contains("squat") {
            return "Squat Focus"
        } else if lower.contains("dead") {
            return "Deadlift Focus"
        } else {
            return "\(primary.name) Focus"
        }
    }
    
    private static func liftsForDay(
        role: String,
        mainLifts: [String]
    ) -> [DayLift] {
        // We expect names like "Squat", "Bench", "Deadlift" from config.mainLifts
        let squat = mainLifts.first { $0.lowercased().contains("squat") } ?? "Squat"
        let bench = mainLifts.first { $0.lowercased().contains("bench") } ?? "Bench"
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
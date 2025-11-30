import Foundation
import SwiftData

// Top-level DTO we can send to ChatGPT
struct AIBlockExport: Codable {
    struct Day: Codable {
        let weekIndex: Int
        let dayIndex: Int
        let title: String
        let roleKey: String
        let description: String
        let exercises: [Exercise]
    }

    struct Exercise: Codable {
        let name: String
        let sets: Int
        let reps: Int
        let targetWeight: Double
    }

    let id: UUID
    let name: String
    let weeksCount: Int
    /// Optional string if you later want to pipe BlockGoal through
    let goal: String?
    let days: [Day]
}

extension BlockTemplate {
    /// Export this block into a compact format the ChatGPT API can reason about.
    func toAIExport(includeWeights: Bool = true) -> AIBlockExport {
        let sortedDays = days.sorted { lhs, rhs in
            if lhs.weekIndex == rhs.weekIndex {
                return lhs.dayIndex < rhs.dayIndex
            }
            return lhs.weekIndex < rhs.weekIndex
        }

        let dayExports: [AIBlockExport.Day] = sortedDays.map { day in
            let exerciseExports: [AIBlockExport.Exercise] = day.exercises
                .sorted { $0.orderIndex < $1.orderIndex }
                .map { planned in
                    let sortedSets = planned.prescribedSets.sorted { $0.setIndex < $1.setIndex }
                    let setsCount = sortedSets.count
                    let firstSet = sortedSets.first

                    return AIBlockExport.Exercise(
                        name: planned.exerciseTemplate?.name ?? "Exercise",
                        sets: setsCount,
                        reps: firstSet?.targetReps ?? 0,
                        targetWeight: includeWeights ? (firstSet?.targetWeight ?? 0.0) : 0.0
                    )
                }

            return AIBlockExport.Day(
                weekIndex: day.weekIndex,
                dayIndex: day.dayIndex,
                title: day.title,
                roleKey: day.roleKey,               // ✅ use the model property
                description: day.dayDescription,
                exercises: exerciseExports
            )
        }

        // We’re not currently storing BlockGoal on the BlockTemplate,
        // so goal is nil for now. You can wire that in later if you like.
        return AIBlockExport(
            id: id,
            name: name,
            weeksCount: weeksCount,
            goal: nil,
            days: dayExports
        )
    }
}
import Foundation
import SwiftData

// MARK: - AI-facing data transfer objects (DTOs)

/// High-level description of a block that can be JSON-encoded and sent to ChatGPT.
struct AIBlockDescriptor: Codable {
    let name: String
    let weeksCount: Int
    let days: [AIDayDescriptor]
}

/// Description of a single day (role, title, etc.)
struct AIDayDescriptor: Codable {
    let weekIndex: Int
    let dayIndex: Int
    let title: String
    let roleKey: String?          // e.g. "heavy_upper"
    let description: String
    let exercises: [AIExerciseDescriptor]
}

/// Description of one planned exercise for that day
struct AIExerciseDescriptor: Codable {
    let orderIndex: Int
    let name: String
    let category: String?
    let sets: [AISetDescriptor]
}

/// Description of a single set prescription
struct AISetDescriptor: Codable {
    let setIndex: Int
    let targetReps: Int
    let targetWeight: Double
    let targetRPE: Double?
}

// MARK: - Converters from your SwiftData models

extension BlockTemplate {
    /// Turn this block into a lightweight AI descriptor
    func toAIBlockDescriptor() -> AIBlockDescriptor {
        let dayDescriptors = days
            .sorted { lhs, rhs in
                if lhs.weekIndex == rhs.weekIndex {
                    return lhs.dayIndex < rhs.dayIndex
                }
                return lhs.weekIndex < rhs.weekIndex
            }
            .map { $0.toAIDayDescriptor() }

        return AIBlockDescriptor(
            name: name,
            weeksCount: weeksCount,
            days: dayDescriptors
        )
    }
}

extension DayTemplate {
    func toAIDayDescriptor() -> AIDayDescriptor {
        let exerciseDescriptors = exercises
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { $0.toAIExerciseDescriptor() }

        return AIDayDescriptor(
            weekIndex: weekIndex,
            dayIndex: dayIndex,
            title: title,
            roleKey: roleKey,                 // uses the roleKey we added in AutoProgramService
            description: dayDescription,
            exercises: exerciseDescriptors
        )
    }
}

extension PlannedExercise {
    func toAIExerciseDescriptor() -> AIExerciseDescriptor {
        let setDescriptors = prescribedSets
            .sorted { $0.setIndex < $1.setIndex }
            .map { $0.toAISetDescriptor() }

        return AIExerciseDescriptor(
            orderIndex: orderIndex,
            name: exerciseTemplate?.name ?? "Exercise",
            category: exerciseTemplate?.category,
            sets: setDescriptors
        )
    }
}

extension PrescribedSet {
    func toAISetDescriptor() -> AISetDescriptor {
        AISetDescriptor(
            setIndex: setIndex,
            targetReps: targetReps,
            targetWeight: targetWeight,
            targetRPE: targetRPE
        )
    }
}
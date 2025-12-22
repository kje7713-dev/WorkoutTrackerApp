//
//  BlockMetrics.swift
//  Savage By Design
//
//  Provides metrics calculations for training blocks
//

import Foundation

/// Summary metrics for a training block
public struct BlockMetrics {
    public let plannedSets: Int
    public let completedSets: Int
    public let plannedVolume: Double  // Total weight * reps for strength exercises
    public let completedVolume: Double
    public let totalWorkouts: Int
    public let completedWorkouts: Int
    
    /// Completion percentage (0.0 to 1.0)
    public var completionPercentage: Double {
        guard plannedSets > 0 else { return 0.0 }
        return Double(completedSets) / Double(plannedSets)
    }
    
    /// Volume completion percentage (0.0 to 1.0)
    public var volumePercentage: Double {
        guard plannedVolume > 0 else { return 0.0 }
        return completedVolume / plannedVolume
    }
    
    /// Workout completion percentage (0.0 to 1.0)
    public var workoutCompletionPercentage: Double {
        guard totalWorkouts > 0 else { return 0.0 }
        return Double(completedWorkouts) / Double(totalWorkouts)
    }
}

/// Extension to calculate metrics for a Block
extension BlockMetrics {
    
    /// Calculate metrics for a block using its sessions
    public static func calculate(for block: Block, sessions: [WorkoutSession]) -> BlockMetrics {
        var plannedSets = 0
        var completedSets = 0
        var plannedVolume = 0.0
        var completedVolume = 0.0
        var totalWorkouts = 0
        var completedWorkouts = 0
        
        // Filter sessions for this block
        let blockSessions = sessions.filter { $0.blockId == block.id }
        totalWorkouts = blockSessions.count
        
        for session in blockSessions {
            // Check if session is completed
            if session.status == .completed {
                completedWorkouts += 1
            }
            
            for exercise in session.exercises {
                // Count expected sets
                plannedSets += exercise.expectedSets.count
                
                // Calculate planned volume for strength exercises
                for expectedSet in exercise.expectedSets {
                    if let reps = expectedSet.expectedReps, let weight = expectedSet.expectedWeight {
                        plannedVolume += Double(reps) * weight
                    }
                }
                
                // Count completed sets and calculate actual volume
                for loggedSet in exercise.loggedSets where loggedSet.isCompleted {
                    completedSets += 1
                    
                    if let reps = loggedSet.loggedReps, let weight = loggedSet.loggedWeight {
                        completedVolume += Double(reps) * weight
                    }
                }
            }
        }
        
        return BlockMetrics(
            plannedSets: plannedSets,
            completedSets: completedSets,
            plannedVolume: plannedVolume,
            completedVolume: completedVolume,
            totalWorkouts: totalWorkouts,
            completedWorkouts: completedWorkouts
        )
    }
}

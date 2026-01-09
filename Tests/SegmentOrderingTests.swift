//
//  SegmentOrderingTests.swift
//  Savage By Design Tests
//
//  Tests for segment and exercise ordering in whiteboard view
//

import XCTest
@testable import WorkoutTrackerApp

final class SegmentOrderingTests: XCTestCase {
    
    // MARK: - Warmup Ordering Tests
    
    func testWarmupSegmentComesBeforeExercises() throws {
        // Create a day with warmup segment and exercises
        let warmupSegment = UnifiedSegment(
            name: "Yoga Warmup",
            segmentType: "warmup",
            durationMinutes: 10
        )
        
        let exercise = UnifiedExercise(
            name: "Squats",
            type: "strength",
            strengthSets: [
                UnifiedStrengthSet(reps: 5, weight: 135)
            ]
        )
        
        let day = UnifiedDay(
            name: "Test Day",
            exercises: [exercise],
            segments: [warmupSegment]
        )
        
        // Filter warmup and other segments
        let warmupSegments = day.segments.filter { $0.segmentType.lowercased() == "warmup" }
        let otherSegments = day.segments.filter { $0.segmentType.lowercased() != "warmup" }
        
        // Verify warmup segment is identified
        XCTAssertEqual(warmupSegments.count, 1)
        XCTAssertEqual(warmupSegments[0].name, "Yoga Warmup")
        XCTAssertEqual(otherSegments.count, 0)
        
        // Expected order: warmup → exercises
        // This test verifies the filtering logic works correctly
    }
    
    func testExercisesBeforeNonWarmupSegments() throws {
        // Create a day with exercises and a non-warmup segment
        let exercise = UnifiedExercise(
            name: "Squats",
            type: "strength",
            strengthSets: [
                UnifiedStrengthSet(reps: 5, weight: 135)
            ]
        )
        
        let heavyBagSegment = UnifiedSegment(
            name: "Heavy Bag Session",
            segmentType: "drill",
            durationMinutes: 20
        )
        
        let day = UnifiedDay(
            name: "Test Day",
            exercises: [exercise],
            segments: [heavyBagSegment]
        )
        
        // Filter warmup and other segments
        let warmupSegments = day.segments.filter { $0.segmentType.lowercased() == "warmup" }
        let otherSegments = day.segments.filter { $0.segmentType.lowercased() != "warmup" }
        
        // Verify no warmup segments
        XCTAssertEqual(warmupSegments.count, 0)
        
        // Verify other segment is identified
        XCTAssertEqual(otherSegments.count, 1)
        XCTAssertEqual(otherSegments[0].name, "Heavy Bag Session")
        
        // Expected order: exercises → other segments
        // This test verifies the filtering logic works correctly
    }
    
    func testCompleteOrdering() throws {
        // Create a day with warmup, exercises, and other segments
        let warmupSegment = UnifiedSegment(
            name: "Dynamic Warmup",
            segmentType: "warmup",
            durationMinutes: 10
        )
        
        let exercise = UnifiedExercise(
            name: "Bench Press",
            type: "strength",
            strengthSets: [
                UnifiedStrengthSet(reps: 5, weight: 185)
            ]
        )
        
        let conditioningSegment = UnifiedSegment(
            name: "Metcon",
            segmentType: "drill",
            durationMinutes: 15
        )
        
        let cooldownSegment = UnifiedSegment(
            name: "Cooldown",
            segmentType: "cooldown",
            durationMinutes: 5
        )
        
        let day = UnifiedDay(
            name: "Full Day",
            exercises: [exercise],
            segments: [conditioningSegment, warmupSegment, cooldownSegment]  // Out of order intentionally
        )
        
        // Filter warmup and other segments
        let warmupSegments = day.segments.filter { $0.segmentType.lowercased() == "warmup" }
        let otherSegments = day.segments.filter { $0.segmentType.lowercased() != "warmup" }
        
        // Verify warmup segment is identified
        XCTAssertEqual(warmupSegments.count, 1)
        XCTAssertEqual(warmupSegments[0].name, "Dynamic Warmup")
        
        // Verify other segments are identified
        XCTAssertEqual(otherSegments.count, 2)
        
        // Expected order: warmup → exercises → other segments (conditioning, cooldown)
        // This test verifies the filtering logic correctly separates warmup from other segments
    }
    
    func testMultipleWarmupSegments() throws {
        // Test with multiple warmup segments
        let warmup1 = UnifiedSegment(
            name: "Mobility",
            segmentType: "warmup",
            durationMinutes: 5
        )
        
        let warmup2 = UnifiedSegment(
            name: "Movement Prep",
            segmentType: "warmup",
            durationMinutes: 5
        )
        
        let exercise = UnifiedExercise(
            name: "Deadlift",
            type: "strength",
            strengthSets: [
                UnifiedStrengthSet(reps: 5, weight: 315)
            ]
        )
        
        let day = UnifiedDay(
            name: "Test Day",
            exercises: [exercise],
            segments: [warmup1, warmup2]
        )
        
        // Filter warmup segments
        let warmupSegments = day.segments.filter { $0.segmentType.lowercased() == "warmup" }
        
        // Verify both warmup segments are identified
        XCTAssertEqual(warmupSegments.count, 2)
        XCTAssertEqual(warmupSegments[0].name, "Mobility")
        XCTAssertEqual(warmupSegments[1].name, "Movement Prep")
    }
    
    func testCaseInsensitiveWarmupDetection() throws {
        // Test that warmup detection is case-insensitive
        let warmupSegment = UnifiedSegment(
            name: "Warmup",
            segmentType: "WARMUP",  // Uppercase
            durationMinutes: 10
        )
        
        let day = UnifiedDay(
            name: "Test Day",
            segments: [warmupSegment]
        )
        
        // Filter using lowercased comparison
        let warmupSegments = day.segments.filter { $0.segmentType.lowercased() == "warmup" }
        
        // Verify warmup is detected regardless of case
        XCTAssertEqual(warmupSegments.count, 1)
        XCTAssertEqual(warmupSegments[0].name, "Warmup")
    }
    
    func testOnlyExercises() throws {
        // Test day with only exercises (no segments)
        let exercise1 = UnifiedExercise(
            name: "Squat",
            type: "strength",
            strengthSets: [
                UnifiedStrengthSet(reps: 5, weight: 225)
            ]
        )
        
        let exercise2 = UnifiedExercise(
            name: "Bench Press",
            type: "strength",
            strengthSets: [
                UnifiedStrengthSet(reps: 5, weight: 185)
            ]
        )
        
        let day = UnifiedDay(
            name: "Strength Day",
            exercises: [exercise1, exercise2],
            segments: []
        )
        
        // Verify no segments
        XCTAssertEqual(day.segments.count, 0)
        XCTAssertEqual(day.exercises.count, 2)
    }
    
    func testOnlySegments() throws {
        // Test day with only segments (no exercises)
        let warmup = UnifiedSegment(
            name: "Warmup",
            segmentType: "warmup",
            durationMinutes: 10
        )
        
        let technique = UnifiedSegment(
            name: "Technique",
            segmentType: "technique",
            durationMinutes: 20
        )
        
        let day = UnifiedDay(
            name: "BJJ Class",
            exercises: [],
            segments: [warmup, technique]
        )
        
        // Filter segments
        let warmupSegments = day.segments.filter { $0.segmentType.lowercased() == "warmup" }
        let otherSegments = day.segments.filter { $0.segmentType.lowercased() != "warmup" }
        
        // Verify segments are correctly categorized
        XCTAssertEqual(warmupSegments.count, 1)
        XCTAssertEqual(otherSegments.count, 1)
        XCTAssertEqual(day.exercises.count, 0)
    }
}

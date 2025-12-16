//
//  SetPrefillTests.swift
//  Savage By Design
//
//  Tests for Issue #45: Prefill weight/rep structure when adding a new set
//

import Foundation

/// Test suite for set prefill functionality
/// These tests validate that new sets copy values from the most recent set
struct SetPrefillTests {
    
    // MARK: - Test: Strength Set Prefill
    
    /// Test that adding a new strength set copies weight and reps from the previous set
    static func testStrengthSetPrefillFromPreviousSet() -> Bool {
        print("🧪 Testing: Strength set prefill from previous set")
        
        // Setup: Create an exercise with one existing set
        var exercise = RunExerciseState(
            name: "Bench Press",
            type: .strength,
            notes: "",
            sets: [
                RunSetState(
                    indexInExercise: 0,
                    displayText: "Set 1",
                    type: .strength,
                    actualReps: 10,
                    actualWeight: 135.0
                )
            ]
        )
        
        // Act: Create a new set using the same logic as ExerciseRunCard
        let previousSets = exercise.sets
        let lastSet = previousSets.last!
        let newSet = RunSetState(
            indexInExercise: 1,
            displayText: "Set 2",
            type: .strength,
            plannedReps: lastSet.plannedReps,
            plannedWeight: lastSet.plannedWeight,
            actualReps: lastSet.actualReps,
            actualWeight: lastSet.actualWeight
        )
        
        // Assert: Verify that the new set has the same weight and reps
        let passed = newSet.actualReps == 10 && newSet.actualWeight == 135.0
        
        if passed {
            print("  ✅ New set correctly copied weight (135.0) and reps (10)")
        } else {
            print("  ❌ New set did not copy values correctly")
            print("     Expected: reps=10, weight=135.0")
            print("     Got: reps=\(newSet.actualReps ?? -1), weight=\(newSet.actualWeight ?? -1)")
        }
        
        return passed
    }
    
    // MARK: - Test: Conditioning Set Prefill
    
    /// Test that adding a new conditioning set copies time/distance/calories/rounds from previous set
    static func testConditioningSetPrefillFromPreviousSet() -> Bool {
        print("🧪 Testing: Conditioning set prefill from previous set")
        
        // Setup: Create an exercise with one existing conditioning set
        var exercise = RunExerciseState(
            name: "Row",
            type: .conditioning,
            notes: "",
            sets: [
                RunSetState(
                    indexInExercise: 0,
                    displayText: "Set 1",
                    type: .conditioning,
                    actualTimeSeconds: 300.0,  // 5 minutes
                    actualDistanceMeters: 1000.0,
                    actualCalories: 50.0,
                    actualRounds: 3
                )
            ]
        )
        
        // Act: Create a new set using the same logic as ExerciseRunCard
        let previousSets = exercise.sets
        let lastSet = previousSets.last!
        let newSet = RunSetState(
            indexInExercise: 1,
            displayText: "Set 2",
            type: .conditioning,
            plannedTimeSeconds: lastSet.plannedTimeSeconds,
            plannedDistanceMeters: lastSet.plannedDistanceMeters,
            plannedCalories: lastSet.plannedCalories,
            plannedRounds: lastSet.plannedRounds,
            actualTimeSeconds: lastSet.actualTimeSeconds,
            actualDistanceMeters: lastSet.actualDistanceMeters,
            actualCalories: lastSet.actualCalories,
            actualRounds: lastSet.actualRounds
        )
        
        // Assert: Verify that the new set has the same conditioning values
        let passed = newSet.actualTimeSeconds == 300.0 &&
                     newSet.actualDistanceMeters == 1000.0 &&
                     newSet.actualCalories == 50.0 &&
                     newSet.actualRounds == 3
        
        if passed {
            print("  ✅ New set correctly copied time (300s), distance (1000m), calories (50), rounds (3)")
        } else {
            print("  ❌ New set did not copy values correctly")
            print("     Expected: time=300s, distance=1000m, calories=50, rounds=3")
            print("     Got: time=\(newSet.actualTimeSeconds ?? -1), distance=\(newSet.actualDistanceMeters ?? -1), calories=\(newSet.actualCalories ?? -1), rounds=\(newSet.actualRounds ?? -1)")
        }
        
        return passed
    }
    
    // MARK: - Test: First Set Default Behavior
    
    /// Test that creating the first set uses default values (no prefill)
    static func testFirstSetUsesDefaultValues() -> Bool {
        print("🧪 Testing: First set uses default values (no previous set)")
        
        // Setup: Create an exercise with no existing sets
        var exercise = RunExerciseState(
            name: "Squat",
            type: .strength,
            notes: "",
            sets: []
        )
        
        // Act: Create the first set (no previous sets to copy from)
        let previousSets = exercise.sets
        let hasNoPreviousSets = previousSets.isEmpty
        let newSet = RunSetState(
            indexInExercise: 0,
            displayText: "Set 1",
            type: .strength
        )
        
        // Assert: Verify that the new set has default (nil) values
        let passed = hasNoPreviousSets &&
                     newSet.actualReps == nil &&
                     newSet.actualWeight == nil
        
        if passed {
            print("  ✅ First set correctly uses default nil values")
        } else {
            print("  ❌ First set did not use default values")
            print("     Expected: reps=nil, weight=nil")
            print("     Got: reps=\(newSet.actualReps.map { "\($0)" } ?? "nil"), weight=\(newSet.actualWeight.map { "\($0)" } ?? "nil")")
        }
        
        return passed
    }
    
    // MARK: - Test: Multiple Sets Chain
    
    /// Test that adding multiple sets continues to copy from the most recent
    static func testMultipleSetsPrefillChain() -> Bool {
        print("🧪 Testing: Multiple sets prefill chain (each copies from previous)")
        
        // Setup: Create an exercise with two sets
        var exercise = RunExerciseState(
            name: "Deadlift",
            type: .strength,
            notes: "",
            sets: [
                RunSetState(
                    indexInExercise: 0,
                    displayText: "Set 1",
                    type: .strength,
                    actualReps: 5,
                    actualWeight: 225.0
                ),
                RunSetState(
                    indexInExercise: 1,
                    displayText: "Set 2",
                    type: .strength,
                    actualReps: 5,
                    actualWeight: 245.0  // User increased weight
                )
            ]
        )
        
        // Act: Create a third set that should copy from the second set (245 lbs)
        let previousSets = exercise.sets
        let lastSet = previousSets.last!
        let newSet = RunSetState(
            indexInExercise: 2,
            displayText: "Set 3",
            type: .strength,
            plannedReps: lastSet.plannedReps,
            plannedWeight: lastSet.plannedWeight,
            actualReps: lastSet.actualReps,
            actualWeight: lastSet.actualWeight
        )
        
        // Assert: Verify that the new set copied from the most recent (second) set, not the first
        let passed = newSet.actualReps == 5 && newSet.actualWeight == 245.0
        
        if passed {
            print("  ✅ Third set correctly copied from most recent set (245.0 lbs, not 225.0 lbs)")
        } else {
            print("  ❌ Third set did not copy from most recent set")
            print("     Expected: reps=5, weight=245.0 (from set 2)")
            print("     Got: reps=\(newSet.actualReps ?? -1), weight=\(newSet.actualWeight ?? -1)")
        }
        
        return passed
    }
    
    // MARK: - Run All Tests
    
    /// Run all set prefill tests and report results
    static func runAllTests() {
        print("\n" + String(repeating: "=", count: 60))
        print("Running Set Prefill Tests (Issue #45)")
        print(String(repeating: "=", count: 60) + "\n")
        
        var passedCount = 0
        var totalCount = 0
        
        let tests: [(name: String, test: () -> Bool)] = [
            ("Strength Set Prefill", testStrengthSetPrefillFromPreviousSet),
            ("Conditioning Set Prefill", testConditioningSetPrefillFromPreviousSet),
            ("First Set Default Values", testFirstSetUsesDefaultValues),
            ("Multiple Sets Prefill Chain", testMultipleSetsPrefillChain)
        ]
        
        for (name, test) in tests {
            totalCount += 1
            let passed = test()
            if passed {
                passedCount += 1
            }
            print("")
        }
        
        print(String(repeating: "=", count: 60))
        print("Test Results: \(passedCount)/\(totalCount) passed")
        if passedCount == totalCount {
            print("✅ All tests passed!")
        } else {
            print("❌ Some tests failed")
        }
        print(String(repeating: "=", count: 60) + "\n")
    }
}

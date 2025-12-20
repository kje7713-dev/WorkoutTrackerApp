//
//  CompletionTimestampTests.swift
//  Savage By Design
//
//  Tests for completion timestamp functionality
//

import Foundation

/// Test suite for completion timestamp functionality
/// Validates that completedAt timestamps are properly set and persisted
struct CompletionTimestampTests {
    
    // MARK: - Test Cases
    
    /// Test that SessionSet includes completedAt field
    static func testSessionSetHasCompletedAtField() -> Bool {
        print("🧪 Testing: SessionSet has completedAt field")
        
        // Create a session set with completedAt timestamp
        let now = Date()
        let set = SessionSet(
            index: 0,
            expectedReps: 10,
            expectedWeight: 135.0,
            loggedReps: 10,
            loggedWeight: 135.0,
            isCompleted: true,
            completedAt: now
        )
        
        // Verify the timestamp is set correctly
        guard let completedAt = set.completedAt else {
            print("❌ FAILED: completedAt is nil when it should be set")
            return false
        }
        
        if completedAt != now {
            print("❌ FAILED: completedAt timestamp doesn't match expected value")
            return false
        }
        
        print("✅ PASSED: SessionSet completedAt field works correctly")
        return true
    }
    
    /// Test that RunSetState includes completedAt field
    static func testRunSetStateHasCompletedAtField() -> Bool {
        print("🧪 Testing: RunSetState has completedAt field")
        
        // Create a run set state with completedAt timestamp
        let now = Date()
        let runSet = RunSetState(
            indexInExercise: 0,
            displayText: "Set 1",
            type: .strength,
            plannedReps: 10,
            plannedWeight: 135.0,
            actualReps: 10,
            actualWeight: 135.0,
            isCompleted: true,
            completedAt: now
        )
        
        // Verify the timestamp is set correctly
        guard let completedAt = runSet.completedAt else {
            print("❌ FAILED: completedAt is nil when it should be set")
            return false
        }
        
        if completedAt != now {
            print("❌ FAILED: completedAt timestamp doesn't match expected value")
            return false
        }
        
        print("✅ PASSED: RunSetState completedAt field works correctly")
        return true
    }
    
    /// Test that completedAt is nil for incomplete sets
    static func testCompletedAtNilForIncompleteSets() -> Bool {
        print("🧪 Testing: completedAt is nil for incomplete sets")
        
        // Create an incomplete session set
        let set = SessionSet(
            index: 0,
            expectedReps: 10,
            expectedWeight: 135.0,
            isCompleted: false
        )
        
        // Verify completedAt is nil
        if set.completedAt != nil {
            print("❌ FAILED: completedAt should be nil for incomplete sets")
            return false
        }
        
        print("✅ PASSED: completedAt is nil for incomplete sets")
        return true
    }
    
    /// Test that timestamp can be set when marking set complete
    static func testTimestampSetOnCompletion() -> Bool {
        print("🧪 Testing: Timestamp is set when marking set complete")
        
        // Create an incomplete set
        var runSet = RunSetState(
            indexInExercise: 0,
            displayText: "Set 1",
            type: .strength,
            plannedReps: 10,
            plannedWeight: 135.0,
            isCompleted: false
        )
        
        // Verify initially no timestamp
        if runSet.completedAt != nil {
            print("❌ FAILED: completedAt should be nil initially")
            return false
        }
        
        // Mark as complete with timestamp
        let completionTime = Date()
        runSet.isCompleted = true
        runSet.completedAt = completionTime
        
        // Verify timestamp is set
        guard let completedAt = runSet.completedAt else {
            print("❌ FAILED: completedAt should be set after completion")
            return false
        }
        
        if completedAt != completionTime {
            print("❌ FAILED: completedAt doesn't match expected completion time")
            return false
        }
        
        print("✅ PASSED: Timestamp is properly set on completion")
        return true
    }
    
    /// Test that timestamp can be cleared when undoing completion
    static func testTimestampClearedOnUndo() -> Bool {
        print("🧪 Testing: Timestamp is cleared when undoing completion")
        
        // Create a completed set with timestamp
        var runSet = RunSetState(
            indexInExercise: 0,
            displayText: "Set 1",
            type: .strength,
            plannedReps: 10,
            plannedWeight: 135.0,
            isCompleted: true,
            completedAt: Date()
        )
        
        // Verify timestamp is set
        if runSet.completedAt == nil {
            print("❌ FAILED: completedAt should be set initially")
            return false
        }
        
        // Undo completion
        runSet.isCompleted = false
        runSet.completedAt = nil
        
        // Verify timestamp is cleared
        if runSet.completedAt != nil {
            print("❌ FAILED: completedAt should be nil after undo")
            return false
        }
        
        print("✅ PASSED: Timestamp is properly cleared on undo")
        return true
    }
    
    // MARK: - Test Runner
    
    /// Run all completion timestamp tests
    static func runAllTests() -> Bool {
        print("\n" + String(repeating: "=", count: 60))
        print("🏋️ Running Completion Timestamp Tests")
        print(String(repeating: "=", count: 60) + "\n")
        
        var allPassed = true
        
        allPassed = testSessionSetHasCompletedAtField() && allPassed
        allPassed = testRunSetStateHasCompletedAtField() && allPassed
        allPassed = testCompletedAtNilForIncompleteSets() && allPassed
        allPassed = testTimestampSetOnCompletion() && allPassed
        allPassed = testTimestampClearedOnUndo() && allPassed
        
        print("\n" + String(repeating: "=", count: 60))
        if allPassed {
            print("✅ All completion timestamp tests PASSED")
        } else {
            print("❌ Some completion timestamp tests FAILED")
        }
        print(String(repeating: "=", count: 60) + "\n")
        
        return allPassed
    }
}

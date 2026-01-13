//
//  BlockRunModeCompletionTests.swift
//  Savage By Design
//
//  Tests for week and block completion modal triggering logic (Issue #49)
//

import Foundation

/// Test suite for completion modal functionality
/// Validates that week and block completion modals trigger correctly
struct BlockRunModeCompletionTests {
    
    // MARK: - Mock Structures
    
    /// Minimal mock for RunWeekState to simulate completion detection
    struct MockRunWeekState {
        let index: Int
        var isCompleted: Bool
    }
    
    /// Minimal mock for Block to satisfy method signature
    struct MockBlock {
        let id = UUID()
        let name = "Test Block"
        let numberOfWeeks = 4
    }
    
    // MARK: - Test Helper: Simulate Completion Transition Logic
    
    /// Simulates the completion detection logic from BlockRunModeView
    /// Returns tuple: (showWeekModal, showBlockModal)
    static func simulateCompletionCheck(
        previousWeeks: [MockRunWeekState],
        currentWeeks: [MockRunWeekState]
    ) -> (showWeekModal: Bool, showBlockModal: Bool) {
        var showWeekModal = false
        var showBlockModal = false
        
        // Find the first week that transitioned from incomplete to complete
        for (index, currentWeek) in currentWeeks.enumerated() {
            guard index < previousWeeks.count else { continue }
            
            let previousWeek = previousWeeks[index]
            let wasCompleted = previousWeek.isCompleted
            let isNowCompleted = currentWeek.isCompleted
            
            // Detect transition from incomplete to complete
            if !wasCompleted && isNowCompleted {
                // Check if all weeks are now completed (block completion)
                let allWeeksCompleted = currentWeeks.allSatisfy { $0.isCompleted }
                let hadIncompleteWeeks = !previousWeeks.allSatisfy { $0.isCompleted }
                
                if allWeeksCompleted && hadIncompleteWeeks {
                    // Block completion takes precedence
                    showBlockModal = true
                    showWeekModal = false
                } else {
                    showWeekModal = true
                }
                
                // Only show modal for the first completed week found
                return (showWeekModal, showBlockModal)
            }
        }
        
        return (showWeekModal, showBlockModal)
    }
    
    // MARK: - Test Cases
    
    /// Test that week completion modal triggers when a single week completes
    static func testWeekCompletionModalTriggersOnSingleWeekCompletion() -> Bool {
        print("🧪 Testing: Week completion modal triggers on single week completion")
        
        // Setup: 4 weeks, none completed
        let previousWeeks = [
            MockRunWeekState(index: 0, isCompleted: false),
            MockRunWeekState(index: 1, isCompleted: false),
            MockRunWeekState(index: 2, isCompleted: false),
            MockRunWeekState(index: 3, isCompleted: false)
        ]
        
        // Act: Complete first week
        let currentWeeks = [
            MockRunWeekState(index: 0, isCompleted: true),  // Just completed
            MockRunWeekState(index: 1, isCompleted: false),
            MockRunWeekState(index: 2, isCompleted: false),
            MockRunWeekState(index: 3, isCompleted: false)
        ]
        
        let result = simulateCompletionCheck(
            previousWeeks: previousWeeks,
            currentWeeks: currentWeeks
        )
        
        // Assert: Week modal should show, block modal should not
        let passed = result.showWeekModal && !result.showBlockModal
        
        if passed {
            print("  ✅ PASS: Week modal triggered correctly")
        } else {
            print("  ❌ FAIL: Expected week modal=true, block modal=false")
            print("     Got: week modal=\(result.showWeekModal), block modal=\(result.showBlockModal)")
        }
        
        return passed
    }
    
    /// Test that block completion modal triggers when the final week completes
    static func testBlockCompletionModalTriggersOnFinalWeekCompletion() -> Bool {
        print("🧪 Testing: Block completion modal triggers when final week completes")
        
        // Setup: 4 weeks, first 3 already completed
        let previousWeeks = [
            MockRunWeekState(index: 0, isCompleted: true),
            MockRunWeekState(index: 1, isCompleted: true),
            MockRunWeekState(index: 2, isCompleted: true),
            MockRunWeekState(index: 3, isCompleted: false)  // Last week not done
        ]
        
        // Act: Complete final week
        let currentWeeks = [
            MockRunWeekState(index: 0, isCompleted: true),
            MockRunWeekState(index: 1, isCompleted: true),
            MockRunWeekState(index: 2, isCompleted: true),
            MockRunWeekState(index: 3, isCompleted: true)  // Just completed
        ]
        
        let result = simulateCompletionCheck(
            previousWeeks: previousWeeks,
            currentWeeks: currentWeeks
        )
        
        // Assert: Block modal should show, week modal should not
        let passed = !result.showWeekModal && result.showBlockModal
        
        if passed {
            print("  ✅ PASS: Block modal triggered correctly (takes precedence)")
        } else {
            print("  ❌ FAIL: Expected week modal=false, block modal=true")
            print("     Got: week modal=\(result.showWeekModal), block modal=\(result.showBlockModal)")
        }
        
        return passed
    }
    
    /// Test that no modal triggers if no week completes
    static func testNoModalWhenNoWeekCompletes() -> Bool {
        print("🧪 Testing: No modal triggers when no week completes")
        
        // Setup: 4 weeks, first one already completed
        let previousWeeks = [
            MockRunWeekState(index: 0, isCompleted: true),
            MockRunWeekState(index: 1, isCompleted: false),
            MockRunWeekState(index: 2, isCompleted: false),
            MockRunWeekState(index: 3, isCompleted: false)
        ]
        
        // Act: No change in completion state
        let currentWeeks = [
            MockRunWeekState(index: 0, isCompleted: true),
            MockRunWeekState(index: 1, isCompleted: false),
            MockRunWeekState(index: 2, isCompleted: false),
            MockRunWeekState(index: 3, isCompleted: false)
        ]
        
        let result = simulateCompletionCheck(
            previousWeeks: previousWeeks,
            currentWeeks: currentWeeks
        )
        
        // Assert: No modals should show
        let passed = !result.showWeekModal && !result.showBlockModal
        
        if passed {
            print("  ✅ PASS: No modal triggered (correct)")
        } else {
            print("  ❌ FAIL: Expected no modals to trigger")
            print("     Got: week modal=\(result.showWeekModal), block modal=\(result.showBlockModal)")
        }
        
        return passed
    }
    
    /// Test that completing the last week of a single-week block shows block modal
    static func testSingleWeekBlockCompletion() -> Bool {
        print("🧪 Testing: Single-week block completion shows block modal")
        
        // Setup: 1 week block, not completed
        let previousWeeks = [
            MockRunWeekState(index: 0, isCompleted: false)
        ]
        
        // Act: Complete the only week
        let currentWeeks = [
            MockRunWeekState(index: 0, isCompleted: true)
        ]
        
        let result = simulateCompletionCheck(
            previousWeeks: previousWeeks,
            currentWeeks: currentWeeks
        )
        
        // Assert: Block modal should show (week completion equals block completion)
        let passed = !result.showWeekModal && result.showBlockModal
        
        if passed {
            print("  ✅ PASS: Block modal triggered for single-week block")
        } else {
            print("  ❌ FAIL: Expected block modal for single-week block")
            print("     Got: week modal=\(result.showWeekModal), block modal=\(result.showBlockModal)")
        }
        
        return passed
    }
    
    /// Test that manually completing a week triggers the completion modal
    static func testManualWeekCompletion() -> Bool {
        print("🧪 Testing: Manual week completion triggers modal")
        
        // Setup: 4 weeks, none completed, but some sets incomplete
        let previousWeeks = [
            MockRunWeekState(index: 0, isCompleted: false),
            MockRunWeekState(index: 1, isCompleted: false),
            MockRunWeekState(index: 2, isCompleted: false),
            MockRunWeekState(index: 3, isCompleted: false)
        ]
        
        // Act: Manually complete first week (even with incomplete sets)
        let currentWeeks = [
            MockRunWeekState(index: 0, isCompleted: true),  // Manually marked complete
            MockRunWeekState(index: 1, isCompleted: false),
            MockRunWeekState(index: 2, isCompleted: false),
            MockRunWeekState(index: 3, isCompleted: false)
        ]
        
        let result = simulateCompletionCheck(
            previousWeeks: previousWeeks,
            currentWeeks: currentWeeks
        )
        
        // Assert: Week modal should show
        let passed = result.showWeekModal && !result.showBlockModal
        
        if passed {
            print("  ✅ PASS: Week modal triggered for manual completion")
        } else {
            print("  ❌ FAIL: Expected week modal for manual completion")
            print("     Got: week modal=\(result.showWeekModal), block modal=\(result.showBlockModal)")
        }
        
        return passed
    }
    
    // MARK: - Test Runner
    
    /// Runs all tests and reports results
    static func runAllTests() {
        print("\n" + String(repeating: "=", count: 60))
        print("🧪 Running Block Completion Modal Tests")
        print(String(repeating: "=", count: 60) + "\n")
        
        var passed = 0
        var failed = 0
        
        let tests: [(String, () -> Bool)] = [
            ("Week Completion Modal", testWeekCompletionModalTriggersOnSingleWeekCompletion),
            ("Block Completion Modal", testBlockCompletionModalTriggersOnFinalWeekCompletion),
            ("No Modal When No Completion", testNoModalWhenNoWeekCompletes),
            ("Single Week Block", testSingleWeekBlockCompletion),
            ("Manual Week Completion", testManualWeekCompletion)
        ]
        
        for (_, test) in tests {
            if test() {
                passed += 1
            } else {
                failed += 1
            }
            print("")
        }
        
        print(String(repeating: "=", count: 60))
        print("📊 Test Results: \(passed) passed, \(failed) failed")
        print(String(repeating: "=", count: 60) + "\n")
        
        if failed == 0 {
            print("✅ All tests passed!")
        } else {
            print("❌ Some tests failed")
        }
    }
}

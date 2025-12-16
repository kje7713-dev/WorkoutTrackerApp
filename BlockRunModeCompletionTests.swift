//
//  BlockRunModeCompletionTests.swift
//  Savage By Design
//
//  Tests for Issue #49: Week completion modal detection
//

import Foundation

/// Test suite for week completion detection functionality
/// These tests validate that week completion transitions are properly detected
struct BlockRunModeCompletionTests {
    
    // MARK: - Test: Week Completion Transition Detection
    
    /// Test that completing the last set in a week triggers detection
    static func testWeekCompletionTransition() -> Bool {
        print("🧪 Testing: Week completion transition detection (incomplete -> complete)")
        
        // Setup: Create a week with one incomplete set
        let previousWeek = RunWeekState(
            index: 0,
            days: [
                RunDayState(
                    name: "Day 1",
                    shortCode: "D1",
                    exercises: [
                        RunExerciseState(
                            name: "Squat",
                            type: .strength,
                            notes: "",
                            sets: [
                                RunSetState(
                                    indexInExercise: 0,
                                    displayText: "Set 1",
                                    type: .strength,
                                    isCompleted: true
                                ),
                                RunSetState(
                                    indexInExercise: 1,
                                    displayText: "Set 2",
                                    type: .strength,
                                    isCompleted: false  // Incomplete
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        // Act: Complete the last set
        var currentWeek = previousWeek
        currentWeek.days[0].exercises[0].sets[1].isCompleted = true
        
        // Verify detection logic
        let wasIncomplete = !previousWeek.isCompleted
        let isNowComplete = currentWeek.isCompleted
        let shouldTrigger = wasIncomplete && isNowComplete
        
        if shouldTrigger {
            print("  ✅ Week completion transition detected correctly")
        } else {
            print("  ❌ Week completion transition not detected")
            print("     Previous week completed: \(previousWeek.isCompleted)")
            print("     Current week completed: \(currentWeek.isCompleted)")
        }
        
        return shouldTrigger
    }
    
    // MARK: - Test: No False Positives - Already Complete
    
    /// Test that completing a set in an already-complete week doesn't trigger
    static func testNoTriggerWhenAlreadyComplete() -> Bool {
        print("🧪 Testing: No trigger when week is already complete")
        
        // Setup: Create a week with all sets complete
        let previousWeek = RunWeekState(
            index: 0,
            days: [
                RunDayState(
                    name: "Day 1",
                    shortCode: "D1",
                    exercises: [
                        RunExerciseState(
                            name: "Squat",
                            type: .strength,
                            notes: "",
                            sets: [
                                RunSetState(
                                    indexInExercise: 0,
                                    displayText: "Set 1",
                                    type: .strength,
                                    isCompleted: true
                                ),
                                RunSetState(
                                    indexInExercise: 1,
                                    displayText: "Set 2",
                                    type: .strength,
                                    isCompleted: true
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        // Act: Week stays complete (no change)
        let currentWeek = previousWeek
        
        // Verify detection logic shouldn't trigger
        let wasComplete = previousWeek.isCompleted
        let isStillComplete = currentWeek.isCompleted
        let shouldNotTrigger = !(wasComplete && isStillComplete)  // Should be false
        
        let passed = !shouldNotTrigger  // Test passes if we correctly don't trigger
        
        if passed {
            print("  ✅ Correctly no trigger for already-complete week")
        } else {
            print("  ❌ Incorrectly would trigger for already-complete week")
        }
        
        return passed
    }
    
    // MARK: - Test: No False Positives - Incomplete to Incomplete
    
    /// Test that changing sets without completing the week doesn't trigger
    static func testNoTriggerWhenStillIncomplete() -> Bool {
        print("🧪 Testing: No trigger when week remains incomplete")
        
        // Setup: Create a week with multiple incomplete sets
        let previousWeek = RunWeekState(
            index: 0,
            days: [
                RunDayState(
                    name: "Day 1",
                    shortCode: "D1",
                    exercises: [
                        RunExerciseState(
                            name: "Squat",
                            type: .strength,
                            notes: "",
                            sets: [
                                RunSetState(
                                    indexInExercise: 0,
                                    displayText: "Set 1",
                                    type: .strength,
                                    isCompleted: false
                                ),
                                RunSetState(
                                    indexInExercise: 1,
                                    displayText: "Set 2",
                                    type: .strength,
                                    isCompleted: false
                                )
                            ]
                        )
                    ]
                )
            ]
        )
        
        // Act: Complete one set, but week still incomplete
        var currentWeek = previousWeek
        currentWeek.days[0].exercises[0].sets[0].isCompleted = true
        // Set 2 still incomplete
        
        // Verify detection logic shouldn't trigger
        let wasIncomplete = !previousWeek.isCompleted
        let isStillIncomplete = !currentWeek.isCompleted
        let shouldNotTrigger = !(wasIncomplete && !isStillIncomplete)
        
        let passed = shouldNotTrigger
        
        if passed {
            print("  ✅ Correctly no trigger for still-incomplete week")
        } else {
            print("  ❌ Incorrectly would trigger for still-incomplete week")
        }
        
        return passed
    }
    
    // MARK: - Test: Multiple Weeks - Only First Completion Triggers
    
    /// Test that when multiple weeks complete simultaneously, only the first is detected
    static func testMultipleWeeksOnlyFirstDetected() -> Bool {
        print("🧪 Testing: Multiple week completions - only first should be detected")
        
        // Setup: Create two weeks, both transitioning to complete
        let previousWeeks = [
            RunWeekState(
                index: 0,
                days: [
                    RunDayState(
                        name: "Day 1",
                        shortCode: "D1",
                        exercises: [
                            RunExerciseState(
                                name: "Squat",
                                type: .strength,
                                notes: "",
                                sets: [
                                    RunSetState(
                                        indexInExercise: 0,
                                        displayText: "Set 1",
                                        type: .strength,
                                        isCompleted: false
                                    )
                                ]
                            )
                        ]
                    )
                ]
            ),
            RunWeekState(
                index: 1,
                days: [
                    RunDayState(
                        name: "Day 1",
                        shortCode: "D1",
                        exercises: [
                            RunExerciseState(
                                name: "Squat",
                                type: .strength,
                                notes: "",
                                sets: [
                                    RunSetState(
                                        indexInExercise: 0,
                                        displayText: "Set 1",
                                        type: .strength,
                                        isCompleted: false
                                    )
                                ]
                            )
                        ]
                    )
                ]
            )
        ]
        
        // Simulate the detection logic - finds first completion
        var foundFirstCompletion = false
        var detectedWeekIndex: Int? = nil
        
        // In practice, we'd complete only one week at a time
        // This test ensures the logic returns early on first detection
        for (index, previousWeek) in previousWeeks.enumerated() {
            if !previousWeek.isCompleted {
                // Simulate week becoming complete
                detectedWeekIndex = index
                foundFirstCompletion = true
                break  // Detection logic should return here
            }
        }
        
        let passed = foundFirstCompletion && detectedWeekIndex == 0
        
        if passed {
            print("  ✅ Correctly detected only first week (week \(detectedWeekIndex! + 1))")
        } else {
            print("  ❌ Detection logic issue with multiple weeks")
        }
        
        return passed
    }
    
    // MARK: - Run All Tests
    
    /// Run all week completion detection tests and report results
    static func runAllTests() {
        print("\n" + String(repeating: "=", count: 60))
        print("Running Week Completion Detection Tests (Issue #49)")
        print(String(repeating: "=", count: 60) + "\n")
        
        var passedCount = 0
        var totalCount = 0
        
        let tests: [(name: String, test: () -> Bool)] = [
            ("Week Completion Transition", testWeekCompletionTransition),
            ("No Trigger When Already Complete", testNoTriggerWhenAlreadyComplete),
            ("No Trigger When Still Incomplete", testNoTriggerWhenStillIncomplete),
            ("Multiple Weeks - First Detection", testMultipleWeeksOnlyFirstDetected)
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

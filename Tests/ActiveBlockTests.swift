//
//  ActiveBlockTests.swift
//  Savage By Design
//
//  Tests for active block selection and metrics calculation
//

import Foundation

/// Test suite for active block functionality
struct ActiveBlockTests {
    
    // MARK: - Test: Set Block as Active
    
    static func testSetBlockAsActive() -> Bool {
        print("🧪 Testing: Set block as active")
        
        // Create test blocks
        let testBlock1 = Block(
            name: "Test Block 1",
            description: "First test block",
            numberOfWeeks: 4,
            goal: .strength,
            days: [
                DayTemplate(
                    name: "Day 1",
                    shortCode: "D1",
                    exercises: []
                )
            ],
            source: .user,
            isArchived: false,
            isActive: false
        )
        
        let testBlock2 = Block(
            name: "Test Block 2",
            description: "Second test block",
            numberOfWeeks: 3,
            goal: .hypertrophy,
            days: [
                DayTemplate(
                    name: "Day 1",
                    shortCode: "D1",
                    exercises: []
                )
            ],
            source: .user,
            isArchived: false,
            isActive: false
        )
        
        // Initialize repository
        let repository = BlocksRepository(blocks: [testBlock1, testBlock2])
        
        // Test: No active blocks initially
        if repository.activeBlock() != nil {
            print("  ❌ Expected no active blocks initially")
            return false
        }
        print("  ✅ No active blocks initially")
        
        // Test: Set block 1 as active
        repository.setActive(testBlock1)
        guard let activeBlock = repository.activeBlock() else {
            print("  ❌ Expected block 1 to be active")
            return false
        }
        
        if activeBlock.id != testBlock1.id {
            print("  ❌ Wrong block is active")
            return false
        }
        print("  ✅ Block 1 is now active")
        
        return true
    }
    
    // MARK: - Test: Only One Block Active
    
    static func testOnlyOneBlockCanBeActive() -> Bool {
        print("🧪 Testing: Only one block can be active at a time")
        
        // Create test blocks
        let testBlock1 = Block(
            name: "Test Block 1",
            numberOfWeeks: 4,
            days: [DayTemplate(name: "Day 1", shortCode: "D1", exercises: [])],
            isActive: false
        )
        
        let testBlock2 = Block(
            name: "Test Block 2",
            numberOfWeeks: 3,
            days: [DayTemplate(name: "Day 1", shortCode: "D1", exercises: [])],
            isActive: false
        )
        
        let repository = BlocksRepository(blocks: [testBlock1, testBlock2])
        
        // Set block 1 as active
        repository.setActive(testBlock1)
        
        // Set block 2 as active
        repository.setActive(testBlock2)
        
        // Check that only block 2 is active
        guard let activeBlock = repository.activeBlock() else {
            print("  ❌ Expected block 2 to be active")
            return false
        }
        
        if activeBlock.id != testBlock2.id {
            print("  ❌ Wrong block is active")
            return false
        }
        
        // Check that block 1 is not active
        let block1 = repository.getBlock(id: testBlock1.id)
        if block1?.isActive == true {
            print("  ❌ Block 1 should not be active")
            return false
        }
        
        print("  ✅ Only block 2 is active")
        return true
    }
    
    // MARK: - Test: Clear Active Block
    
    static func testClearActiveBlock() -> Bool {
        print("🧪 Testing: Clear active block")
        
        let testBlock = Block(
            name: "Test Block",
            numberOfWeeks: 4,
            days: [DayTemplate(name: "Day 1", shortCode: "D1", exercises: [])],
            isActive: false
        )
        
        let repository = BlocksRepository(blocks: [testBlock])
        
        // Set as active
        repository.setActive(testBlock)
        
        if repository.activeBlock() == nil {
            print("  ❌ Block should be active")
            return false
        }
        
        // Clear active
        repository.clearActiveBlock()
        
        if repository.activeBlock() != nil {
            print("  ❌ No block should be active after clear")
            return false
        }
        
        print("  ✅ Active block cleared successfully")
        return true
    }
    
    // MARK: - Test: Block Metrics Calculation
    
    static func testBlockMetricsCalculation() -> Bool {
        print("🧪 Testing: Block metrics calculation")
        
        let testBlock = Block(
            name: "Test Block",
            numberOfWeeks: 4,
            days: [DayTemplate(name: "Day 1", shortCode: "D1", exercises: [])]
        )
        
        // Test with no sessions
        let emptyMetrics = BlockMetrics.calculate(for: testBlock, sessions: [])
        
        if emptyMetrics.plannedSets != 0 || emptyMetrics.completedSets != 0 {
            print("  ❌ Empty block should have zero metrics")
            return false
        }
        print("  ✅ Empty block metrics are zero")
        
        // Test with a session containing sets
        let session = WorkoutSession(
            blockId: testBlock.id,
            weekIndex: 0,
            dayTemplateId: testBlock.days[0].id,
            date: Date(),
            status: .completed,
            exercises: [
                SessionExercise(
                    customName: "Test Exercise",
                    expectedSets: [
                        SessionSet(
                            index: 0,
                            expectedReps: 10,
                            expectedWeight: 100.0,
                            isCompleted: false
                        ),
                        SessionSet(
                            index: 1,
                            expectedReps: 10,
                            expectedWeight: 100.0,
                            isCompleted: false
                        )
                    ],
                    loggedSets: [
                        SessionSet(
                            index: 0,
                            loggedReps: 10,
                            loggedWeight: 100.0,
                            isCompleted: true
                        )
                    ]
                )
            ]
        )
        
        let metrics = BlockMetrics.calculate(for: testBlock, sessions: [session])
        
        // Verify metrics
        if metrics.plannedSets != 2 {
            print("  ❌ Expected 2 planned sets, got \(metrics.plannedSets)")
            return false
        }
        
        if metrics.completedSets != 1 {
            print("  ❌ Expected 1 completed set, got \(metrics.completedSets)")
            return false
        }
        
        if metrics.plannedVolume != 2000.0 {
            print("  ❌ Expected planned volume of 2000, got \(metrics.plannedVolume)")
            return false
        }
        
        if metrics.completedVolume != 1000.0 {
            print("  ❌ Expected completed volume of 1000, got \(metrics.completedVolume)")
            return false
        }
        
        if metrics.completionPercentage != 0.5 {
            print("  ❌ Expected completion percentage of 0.5, got \(metrics.completionPercentage)")
            return false
        }
        
        print("  ✅ Block metrics calculated correctly")
        return true
    }
    
    // MARK: - Run All Tests
    
    static func runAll() -> Bool {
        print("\n========================================")
        print("Active Block Tests")
        print("========================================")
        
        var allPassed = true
        
        if !testSetBlockAsActive() {
            allPassed = false
        }
        
        if !testOnlyOneBlockCanBeActive() {
            allPassed = false
        }
        
        if !testClearActiveBlock() {
            allPassed = false
        }
        
        if !testBlockMetricsCalculation() {
            allPassed = false
        }
        
        print("========================================\n")
        return allPassed
    }
}


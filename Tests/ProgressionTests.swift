//
//  ProgressionTests.swift
//  Savage By Design
//
//  Tests for progression logic in SessionFactory
//

import Foundation

/// Test suite for progression functionality
struct ProgressionTests {
    
    // MARK: - Test: Weight Progression
    
    /// Test that weight increases correctly across weeks
    static func testWeightProgressionAcrossWeeks() -> Bool {
        print("🧪 Testing: Weight progression increases weight across weeks")
        
        // Create a 4-week block with weight progression
        let strengthSet = StrengthSetTemplate(
            id: UUID(),
            index: 0,
            reps: 5,
            weight: 100.0,  // Starting weight
            rpe: 8.0
        )
        
        let exerciseTemplate = ExerciseTemplate(
            id: UUID(),
            customName: "Squat",
            type: .strength,
            strengthSets: [strengthSet],
            progressionRule: ProgressionRule(
                type: .weight,
                deltaWeight: 10.0  // Add 10 lbs per week
            )
        )
        
        let dayTemplate = DayTemplate(
            id: UUID(),
            name: "Day 1",
            exercises: [exerciseTemplate]
        )
        
        let block = Block(
            id: UUID(),
            name: "Test Block",
            numberOfWeeks: 4,
            days: [dayTemplate]
        )
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        // Verify we have 4 sessions (1 per week)
        guard sessions.count == 4 else {
            print("  ❌ Expected 4 sessions, got \(sessions.count)")
            return false
        }
        
        // Check expected weights for each week
        let expectedWeights = [
            1: 100.0,  // Week 1: baseline
            2: 110.0,  // Week 2: +10
            3: 120.0,  // Week 3: +20
            4: 130.0   // Week 4: +30
        ]
        
        var allPassed = true
        for session in sessions {
            guard let exercise = session.exercises.first,
                  let set = exercise.expectedSets.first else {
                print("  ❌ Session \(session.weekIndex) missing exercise or set")
                return false
            }
            
            let expectedWeight = expectedWeights[session.weekIndex]!
            if set.expectedWeight == expectedWeight {
                print("  ✅ Week \(session.weekIndex): Weight = \(set.expectedWeight ?? 0) (expected \(expectedWeight))")
            } else {
                print("  ❌ Week \(session.weekIndex): Weight = \(set.expectedWeight ?? 0), expected \(expectedWeight)")
                allPassed = false
            }
        }
        
        return allPassed
    }
    
    // MARK: - Test: Volume Progression
    
    /// Test that additional sets are added for volume progression
    static func testVolumeProgressionAddssets() -> Bool {
        print("🧪 Testing: Volume progression adds sets across weeks")
        
        // Create a 3-week block with volume progression
        let strengthSets = [
            StrengthSetTemplate(id: UUID(), index: 0, reps: 10, weight: 135.0),
            StrengthSetTemplate(id: UUID(), index: 1, reps: 10, weight: 135.0),
            StrengthSetTemplate(id: UUID(), index: 2, reps: 10, weight: 135.0)
        ]
        
        let exerciseTemplate = ExerciseTemplate(
            id: UUID(),
            customName: "Bench Press",
            type: .strength,
            strengthSets: strengthSets,
            progressionRule: ProgressionRule(
                type: .volume,
                deltaSets: 1  // Add 1 set per week
            )
        )
        
        let dayTemplate = DayTemplate(
            id: UUID(),
            name: "Day 1",
            exercises: [exerciseTemplate]
        )
        
        let block = Block(
            id: UUID(),
            name: "Test Block",
            numberOfWeeks: 3,
            days: [dayTemplate]
        )
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        // Check expected number of sets for each week
        let expectedSetCounts = [
            1: 3,  // Week 1: 3 base sets
            2: 4,  // Week 2: 3 base + 1 additional
            3: 5   // Week 3: 3 base + 2 additional
        ]
        
        var allPassed = true
        for session in sessions {
            guard let exercise = session.exercises.first else {
                print("  ❌ Session \(session.weekIndex) missing exercise")
                return false
            }
            
            let expectedCount = expectedSetCounts[session.weekIndex]!
            let actualCount = exercise.expectedSets.count
            
            if actualCount == expectedCount {
                print("  ✅ Week \(session.weekIndex): \(actualCount) sets (expected \(expectedCount))")
            } else {
                print("  ❌ Week \(session.weekIndex): \(actualCount) sets, expected \(expectedCount)")
                allPassed = false
            }
        }
        
        return allPassed
    }
    
    // MARK: - Test: Deload Week
    
    /// Test that deload weeks don't apply progression
    static func testDeloadWeekNoProgression() -> Bool {
        print("🧪 Testing: Deload week does not apply progression")
        
        // Create a 4-week block with week 4 as deload
        let strengthSet = StrengthSetTemplate(
            id: UUID(),
            index: 0,
            reps: 5,
            weight: 100.0
        )
        
        let exerciseTemplate = ExerciseTemplate(
            id: UUID(),
            customName: "Deadlift",
            type: .strength,
            strengthSets: [strengthSet],
            progressionRule: ProgressionRule(
                type: .weight,
                deltaWeight: 5.0,
                deloadWeekIndexes: [4]  // Week 4 is deload
            )
        )
        
        let dayTemplate = DayTemplate(
            id: UUID(),
            name: "Day 1",
            exercises: [exerciseTemplate]
        )
        
        let block = Block(
            id: UUID(),
            name: "Test Block",
            numberOfWeeks: 4,
            days: [dayTemplate]
        )
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        // Check weights - week 4 should be same as week 1
        let week1Weight = sessions[0].exercises.first?.expectedSets.first?.expectedWeight
        let week4Weight = sessions[3].exercises.first?.expectedSets.first?.expectedWeight
        
        guard let w1 = week1Weight, let w4 = week4Weight else {
            print("  ❌ Could not get weights from sessions")
            return false
        }
        
        if w1 == w4 && w1 == 100.0 {
            print("  ✅ Week 4 (deload) weight = \(w4), same as Week 1 (\(w1))")
            return true
        } else {
            print("  ❌ Week 4 weight = \(w4), Week 1 = \(w1), expected both to be 100.0")
            return false
        }
    }
    
    // MARK: - Test: Week 1 Baseline
    
    /// Test that week 1 uses base values with no progression
    static func testWeek1UsesBaselineValues() -> Bool {
        print("🧪 Testing: Week 1 uses baseline values (no progression)")
        
        let strengthSet = StrengthSetTemplate(
            id: UUID(),
            index: 0,
            reps: 8,
            weight: 225.0
        )
        
        let exerciseTemplate = ExerciseTemplate(
            id: UUID(),
            customName: "Military Press",
            type: .strength,
            strengthSets: [strengthSet],
            progressionRule: ProgressionRule(
                type: .weight,
                deltaWeight: 2.5
            )
        )
        
        let dayTemplate = DayTemplate(
            id: UUID(),
            name: "Day 1",
            exercises: [exerciseTemplate]
        )
        
        let block = Block(
            id: UUID(),
            name: "Test Block",
            numberOfWeeks: 2,
            days: [dayTemplate]
        )
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        guard let week1Exercise = sessions.first?.exercises.first,
              let week1Set = week1Exercise.expectedSets.first else {
            print("  ❌ Could not get week 1 exercise/set")
            return false
        }
        
        if week1Set.expectedWeight == 225.0 {
            print("  ✅ Week 1 uses baseline weight: \(week1Set.expectedWeight ?? 0)")
            return true
        } else {
            print("  ❌ Week 1 weight = \(week1Set.expectedWeight ?? 0), expected 225.0")
            return false
        }
    }
    
    // MARK: - Test: Conditioning Volume Progression
    
    /// Test that volume progression works for conditioning exercises
    static func testConditioningVolumeProgression() -> Bool {
        print("🧪 Testing: Conditioning exercises support volume progression")
        
        let conditioningSets = [
            ConditioningSetTemplate(
                id: UUID(),
                index: 0,
                durationSeconds: 300,  // 5 minutes
                distanceMeters: 1000.0
            ),
            ConditioningSetTemplate(
                id: UUID(),
                index: 1,
                durationSeconds: 300,
                distanceMeters: 1000.0
            )
        ]
        
        let exerciseTemplate = ExerciseTemplate(
            id: UUID(),
            customName: "Row",
            type: .conditioning,
            conditioningSets: conditioningSets,
            progressionRule: ProgressionRule(
                type: .volume,
                deltaSets: 1
            )
        )
        
        let dayTemplate = DayTemplate(
            id: UUID(),
            name: "Day 1",
            exercises: [exerciseTemplate]
        )
        
        let block = Block(
            id: UUID(),
            name: "Test Block",
            numberOfWeeks: 3,
            days: [dayTemplate]
        )
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        // Check set counts
        let week1Count = sessions[0].exercises.first?.expectedSets.count ?? 0
        let week2Count = sessions[1].exercises.first?.expectedSets.count ?? 0
        let week3Count = sessions[2].exercises.first?.expectedSets.count ?? 0
        
        if week1Count == 2 && week2Count == 3 && week3Count == 4 {
            print("  ✅ Conditioning sets: Week 1 = \(week1Count), Week 2 = \(week2Count), Week 3 = \(week3Count)")
            return true
        } else {
            print("  ❌ Conditioning sets: Week 1 = \(week1Count), Week 2 = \(week2Count), Week 3 = \(week3Count)")
            print("     Expected: 2, 3, 4")
            return false
        }
    }
    
    // MARK: - Run All Tests
    
    /// Run all progression tests and report results
    static func runAllTests() {
        print("\n" + String(repeating: "=", count: 60))
        print("Running Progression Tests")
        print(String(repeating: "=", count: 60) + "\n")
        
        var passedCount = 0
        var totalCount = 0
        
        let tests: [(name: String, test: () -> Bool)] = [
            ("Weight Progression Across Weeks", testWeightProgressionAcrossWeeks),
            ("Volume Progression Adds Sets", testVolumeProgressionAddssets),
            ("Deload Week No Progression", testDeloadWeekNoProgression),
            ("Week 1 Uses Baseline Values", testWeek1UsesBaselineValues),
            ("Conditioning Volume Progression", testConditioningVolumeProgression)
        ]
        
        for (_, test) in tests {
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

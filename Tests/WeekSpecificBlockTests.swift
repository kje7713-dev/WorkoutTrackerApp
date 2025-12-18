//
//  WeekSpecificBlockTests.swift
//  Savage By Design
//
//  Tests for week-specific exercise variations in blocks
//

import Foundation

/// Test suite for week-specific block functionality
struct WeekSpecificBlockTests {
    
    // MARK: - Test Week-Specific Template Storage
    
    /// Test that Block model correctly stores week-specific templates
    static func testBlockWeekTemplatesStorage() -> Bool {
        print("Test: Block stores week-specific templates correctly")
        
        // Create day templates for week 1
        let week1Day1 = DayTemplate(
            name: "Week 1 - Day 1",
            exercises: [
                ExerciseTemplate(
                    customName: "Back Squat",
                    type: .strength,
                    strengthSets: [
                        StrengthSetTemplate(index: 0, reps: 5, weight: 185.0)
                    ],
                    progressionRule: ProgressionRule(type: .weight)
                )
            ]
        )
        
        // Create day templates for week 2 (different exercise)
        let week2Day1 = DayTemplate(
            name: "Week 2 - Day 1",
            exercises: [
                ExerciseTemplate(
                    customName: "Front Squat",
                    type: .strength,
                    strengthSets: [
                        StrengthSetTemplate(index: 0, reps: 5, weight: 155.0)
                    ],
                    progressionRule: ProgressionRule(type: .weight)
                )
            ]
        )
        
        // Create block with week-specific templates
        let weekTemplates = [[week1Day1], [week2Day1]]
        
        let block = Block(
            name: "Week-Specific Test Block",
            numberOfWeeks: 2,
            days: [week1Day1], // Default days
            weekTemplates: weekTemplates
        )
        
        // Validate
        guard let storedWeekTemplates = block.weekTemplates else {
            print("❌ FAIL: weekTemplates is nil")
            return false
        }
        
        guard storedWeekTemplates.count == 2 else {
            print("❌ FAIL: Expected 2 week templates, got \(storedWeekTemplates.count)")
            return false
        }
        
        guard storedWeekTemplates[0][0].exercises[0].customName == "Back Squat" else {
            print("❌ FAIL: Week 1 exercise name mismatch")
            return false
        }
        
        guard storedWeekTemplates[1][0].exercises[0].customName == "Front Squat" else {
            print("❌ FAIL: Week 2 exercise name mismatch")
            return false
        }
        
        print("✅ PASS: Block correctly stores week-specific templates")
        return true
    }
    
    // MARK: - Test SessionFactory with Week-Specific Templates
    
    /// Test that SessionFactory generates correct sessions for week-specific blocks
    static func testSessionFactoryWeekSpecific() -> Bool {
        print("Test: SessionFactory generates week-specific sessions")
        
        // Create week 1 day
        let week1Day1 = DayTemplate(
            name: "Day 1",
            exercises: [
                ExerciseTemplate(
                    customName: "Exercise A",
                    type: .strength,
                    strengthSets: [
                        StrengthSetTemplate(index: 0, reps: 5)
                    ],
                    progressionRule: ProgressionRule(type: .weight)
                )
            ]
        )
        
        // Create week 2 day with different exercise
        let week2Day1 = DayTemplate(
            name: "Day 1",
            exercises: [
                ExerciseTemplate(
                    customName: "Exercise B",
                    type: .strength,
                    strengthSets: [
                        StrengthSetTemplate(index: 0, reps: 5)
                    ],
                    progressionRule: ProgressionRule(type: .weight)
                )
            ]
        )
        
        // Create block
        let block = Block(
            name: "Test Block",
            numberOfWeeks: 2,
            days: [week1Day1],
            weekTemplates: [[week1Day1], [week2Day1]]
        )
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        // Validate
        guard sessions.count == 2 else {
            print("❌ FAIL: Expected 2 sessions, got \(sessions.count)")
            return false
        }
        
        let week1Session = sessions.first { $0.weekIndex == 1 }
        let week2Session = sessions.first { $0.weekIndex == 2 }
        
        guard let w1 = week1Session, let w2 = week2Session else {
            print("❌ FAIL: Could not find week 1 or week 2 sessions")
            return false
        }
        
        guard let w1ExerciseName = w1.exercises.first?.customName,
              let w2ExerciseName = w2.exercises.first?.customName else {
            print("❌ FAIL: Could not get exercise names")
            return false
        }
        
        guard w1ExerciseName == "Exercise A" else {
            print("❌ FAIL: Week 1 should have Exercise A, got \(w1ExerciseName)")
            return false
        }
        
        guard w2ExerciseName == "Exercise B" else {
            print("❌ FAIL: Week 2 should have Exercise B, got \(w2ExerciseName)")
            return false
        }
        
        print("✅ PASS: SessionFactory correctly generates week-specific sessions")
        return true
    }
    
    // MARK: - Test SessionFactory Fallback to Standard Mode
    
    /// Test that SessionFactory falls back to standard mode when weekTemplates is nil
    static func testSessionFactoryFallback() -> Bool {
        print("Test: SessionFactory falls back to standard mode")
        
        let dayTemplate = DayTemplate(
            name: "Day 1",
            exercises: [
                ExerciseTemplate(
                    customName: "Exercise A",
                    type: .strength,
                    strengthSets: [
                        StrengthSetTemplate(index: 0, reps: 5)
                    ],
                    progressionRule: ProgressionRule(type: .weight)
                )
            ]
        )
        
        // Create block WITHOUT weekTemplates
        let block = Block(
            name: "Standard Block",
            numberOfWeeks: 3,
            days: [dayTemplate],
            weekTemplates: nil  // No week-specific templates
        )
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        // Validate
        guard sessions.count == 3 else {
            print("❌ FAIL: Expected 3 sessions, got \(sessions.count)")
            return false
        }
        
        // All weeks should have same exercise
        for (index, session) in sessions.enumerated() {
            guard let exerciseName = session.exercises.first?.customName else {
                print("❌ FAIL: Could not get exercise name for week \(index + 1)")
                return false
            }
            
            guard exerciseName == "Exercise A" else {
                print("❌ FAIL: Week \(index + 1) should have Exercise A, got \(exerciseName)")
                return false
            }
        }
        
        print("✅ PASS: SessionFactory correctly falls back to standard mode")
        return true
    }
    
    // MARK: - Test JSON Import with Week-Specific Format
    
    /// Test that BlockGenerator correctly parses week-specific JSON
    static func testJSONWeekSpecificParsing() -> Bool {
        print("Test: BlockGenerator parses week-specific JSON")
        
        let jsonString = """
        {
          "Title": "Week Variation Block",
          "Goal": "strength",
          "TargetAthlete": "Intermediate",
          "NumberOfWeeks": 2,
          "DurationMinutes": 60,
          "Difficulty": 3,
          "Equipment": "Barbell",
          "WarmUp": "5 min",
          "Weeks": [
            [
              {
                "name": "Day 1",
                "exercises": [
                  {
                    "name": "Back Squat",
                    "setsReps": "5x5"
                  }
                ]
              }
            ],
            [
              {
                "name": "Day 1",
                "exercises": [
                  {
                    "name": "Front Squat",
                    "setsReps": "4x6"
                  }
                ]
              }
            ]
          ],
          "Finisher": "Stretch",
          "Notes": "Test",
          "EstimatedTotalTimeMinutes": 60,
          "Progression": "Linear"
        }
        """
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌ FAIL: Could not convert string to data")
            return false
        }
        
        do {
            let decoder = JSONDecoder()
            let imported = try decoder.decode(ImportedBlock.self, from: jsonData)
            
            // Validate imported block
            guard let weeks = imported.Weeks else {
                print("❌ FAIL: Weeks field is nil")
                return false
            }
            
            guard weeks.count == 2 else {
                print("❌ FAIL: Expected 2 weeks, got \(weeks.count)")
                return false
            }
            
            guard weeks[0][0].exercises[0].name == "Back Squat" else {
                print("❌ FAIL: Week 1 exercise name mismatch")
                return false
            }
            
            guard weeks[1][0].exercises[0].name == "Front Squat" else {
                print("❌ FAIL: Week 2 exercise name mismatch")
                return false
            }
            
            // Convert to Block
            let block = BlockGenerator.convertToBlock(imported)
            
            guard let weekTemplates = block.weekTemplates else {
                print("❌ FAIL: Block weekTemplates is nil after conversion")
                return false
            }
            
            guard weekTemplates.count == 2 else {
                print("❌ FAIL: Expected 2 week templates in block, got \(weekTemplates.count)")
                return false
            }
            
            print("✅ PASS: BlockGenerator correctly parses and converts week-specific JSON")
            return true
            
        } catch {
            print("❌ FAIL: JSON parsing error: \(error)")
            return false
        }
    }
    
    // MARK: - Test Backward Compatibility
    
    /// Test that existing blocks (without weekTemplates) still work
    static func testBackwardCompatibility() -> Bool {
        print("Test: Backward compatibility with existing blocks")
        
        let dayTemplate = DayTemplate(
            name: "Day 1",
            exercises: [
                ExerciseTemplate(
                    customName: "Exercise A",
                    type: .strength,
                    strengthSets: [
                        StrengthSetTemplate(index: 0, reps: 5)
                    ],
                    progressionRule: ProgressionRule(type: .weight)
                )
            ]
        )
        
        // Create old-style block (no weekTemplates parameter)
        let block = Block(
            name: "Legacy Block",
            numberOfWeeks: 4,
            days: [dayTemplate]
        )
        
        // Should have nil weekTemplates
        guard block.weekTemplates == nil else {
            print("❌ FAIL: weekTemplates should be nil for legacy blocks")
            return false
        }
        
        // Generate sessions should work
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        guard sessions.count == 4 else {
            print("❌ FAIL: Expected 4 sessions, got \(sessions.count)")
            return false
        }
        
        print("✅ PASS: Backward compatibility maintained")
        return true
    }
    
    // MARK: - Run All Tests
    
    /// Run all week-specific block tests
    static func runAll() -> Bool {
        print("\n=== Week-Specific Block Tests ===\n")
        
        var allPassed = true
        
        if !testBlockWeekTemplatesStorage() {
            allPassed = false
        }
        print("")
        
        if !testSessionFactoryWeekSpecific() {
            allPassed = false
        }
        print("")
        
        if !testSessionFactoryFallback() {
            allPassed = false
        }
        print("")
        
        if !testJSONWeekSpecificParsing() {
            allPassed = false
        }
        print("")
        
        if !testBackwardCompatibility() {
            allPassed = false
        }
        print("")
        
        if allPassed {
            print("✅ All week-specific block tests passed!")
        } else {
            print("❌ Some tests failed")
        }
        
        return allPassed
    }
}

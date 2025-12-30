//
//  BlockGeneratorTests.swift
//  Savage By Design
//
//  Tests for BlockGenerator parsing functionality
//

import Foundation

/// Test suite for BlockGenerator parsing
struct BlockGeneratorTests {
    
    // MARK: - Test JSON Parsing
    
    /// Test parsing a valid JSON section
    static func testJSONParsing() -> Bool {
        let testResponse = """
Here is your workout:

HUMAN-READABLE SUMMARY:
Title: Full Body Strength
Goal: Build foundational strength
Target Athlete: Intermediate
Duration (minutes): 45
Difficulty (1-5): 3
Equipment: Barbell, Dumbbells
Warm-Up: 5 min dynamic stretching
Exercises:
  Squat | 3x8 | 180 | RPE 7
  Bench Press | 3x8 | 120 | RPE 7
Finisher: 10 min cooldown
Notes: Focus on form
Estimated Total Time (minutes): 45
Progression: Add 5 lbs per week

JSON:
{
  "Title": "Full Body Strength",
  "Goal": "Build foundational strength",
  "TargetAthlete": "Intermediate",
  "DurationMinutes": 45,
  "Difficulty": 3,
  "Equipment": "Barbell, Dumbbells",
  "WarmUp": "5 min dynamic stretching",
  "Exercises": [
    {
      "name": "Squat",
      "setsReps": "3x8",
      "restSeconds": 180,
      "intensityCue": "RPE 7"
    },
    {
      "name": "Bench Press",
      "setsReps": "3x8",
      "restSeconds": 120,
      "intensityCue": "RPE 7"
    }
  ],
  "Finisher": "10 min cooldown",
  "Notes": "Focus on form",
  "EstimatedTotalTimeMinutes": 45,
  "Progression": "Add 5 lbs per week"
}
"""
        
        let result = BlockGenerator.decodeBlock(from: testResponse)
        
        switch result {
        case .success(let imported):
            print("✅ JSON parsing succeeded")
            print("   Title: \(imported.Title)")
            print("   Exercises: \(imported.Exercises?.count ?? 0)")
            
            // Validate content
            guard imported.Title == "Full Body Strength" else {
                print("❌ Title mismatch")
                return false
            }
            
            guard imported.Exercises?.count == 2 else {
                print("❌ Exercise count mismatch")
                return false
            }
            
            guard imported.DurationMinutes == 45 else {
                print("❌ Duration mismatch")
                return false
            }
            
            return true
            
        case .failure(let error):
            print("❌ JSON parsing failed: \(error)")
            return false
        }
    }
    
    // MARK: - Test HumanReadable Fallback
    
    /// Test parsing HumanReadable section when JSON is not present
    static func testHumanReadableParsing() -> Bool {
        let testResponse = """
HUMAN-READABLE SUMMARY:
Title: Upper Body Power
Goal: Build explosive strength
Target Athlete: Advanced
Duration (minutes): 60
Difficulty (1-5): 4
Equipment: Barbell, Dumbbells, Rack
Warm-Up: 10 min mobility work
Exercises:
  Power Clean | 5x3 | 240 | Explosive
  Overhead Press | 4x6 | 180 | Controlled
  Pull-ups | 4x8 | 120 | Full ROM
Finisher: 5 min stretching
Notes: Focus on speed
Estimated Total Time (minutes): 60
Progression: Increase weight by 2.5%
"""
        
        let result = BlockGenerator.decodeBlock(from: testResponse)
        
        switch result {
        case .success(let imported):
            print("✅ HumanReadable parsing succeeded")
            print("   Title: \(imported.Title)")
            print("   Exercises: \(imported.Exercises?.count ?? 0)")
            
            // Validate content
            guard imported.Title == "Upper Body Power" else {
                print("❌ Title mismatch: \(imported.Title)")
                return false
            }
            
            guard imported.Exercises?.count == 3 else {
                print("❌ Exercise count mismatch: \(imported.Exercises?.count ?? 0)")
                return false
            }
            
            guard imported.TargetAthlete == "Advanced" else {
                print("❌ Target athlete mismatch")
                return false
            }
            
            return true
            
        case .failure(let error):
            print("❌ HumanReadable parsing failed: \(error)")
            return false
        }
    }
    
    // MARK: - Test Block Conversion
    
    /// Test converting ImportedBlock to app's Block model
    static func testBlockConversion() -> Bool {
        let imported = ImportedBlock(
            Title: "Test Block",
            Goal: "Strength",
            TargetAthlete: "Intermediate",
            DurationMinutes: 45,
            Difficulty: 3,
            Equipment: "Barbell",
            WarmUp: "Dynamic stretching",
            Exercises: [
                ImportedExercise(
                    name: "Squat",
                    setsReps: "3x5",
                    restSeconds: 180,
                    intensityCue: "RPE 8"
                )
            ],
            Finisher: "Cooldown",
            Notes: "Test notes",
            EstimatedTotalTimeMinutes: 45,
            Progression: "Linear"
        )
        
        let block = BlockGenerator.convertToBlock(imported, numberOfWeeks: 4)
        
        print("✅ Block conversion succeeded")
        print("   Block name: \(block.name)")
        print("   Number of weeks: \(block.numberOfWeeks)")
        print("   Days: \(block.days.count)")
        print("   Source: \(block.source)")
        
        // Validate conversion
        guard block.name == "Test Block" else {
            print("❌ Block name mismatch")
            return false
        }
        
        guard block.numberOfWeeks == 4 else {
            print("❌ Number of weeks mismatch")
            return false
        }
        
        guard block.days.count == 1 else {
            print("❌ Days count mismatch")
            return false
        }
        
        guard block.source == .ai else {
            print("❌ Source should be .ai")
            return false
        }
        
        let firstDay = block.days[0]
        guard firstDay.exercises.count == 1 else {
            print("❌ Exercise count mismatch in day")
            return false
        }
        
        let firstExercise = firstDay.exercises[0]
        guard firstExercise.customName == "Squat" else {
            print("❌ Exercise name mismatch")
            return false
        }
        
        guard let strengthSets = firstExercise.strengthSets else {
            print("❌ Strength sets missing")
            return false
        }
        
        guard strengthSets.count == 3 else {
            print("❌ Sets count mismatch (expected 3, got \(strengthSets.count))")
            return false
        }
        
        guard strengthSets[0].reps == 5 else {
            print("❌ Reps mismatch")
            return false
        }
        
        return true
    }
    
    // MARK: - Test Segment-Only Day Parsing
    
    /// Test parsing a day with segments but no exercises field
    static func testSegmentOnlyDayParsing() -> Bool {
        let testJSON = """
        {
          "Title": "BJJ Fundamentals Class",
          "Goal": "mixed",
          "TargetAthlete": "Beginner",
          "NumberOfWeeks": 1,
          "DurationMinutes": 60,
          "Difficulty": 3,
          "Equipment": "Grappling mats, gi",
          "WarmUp": "See segments",
          "Days": [
            {
              "name": "Class: Guard Basics",
              "shortCode": "BJJ1",
              "goal": "mixed",
              "notes": "Focus on fundamentals"
            }
          ],
          "Finisher": "Cooldown",
          "Notes": "Focus on safety",
          "EstimatedTotalTimeMinutes": 60,
          "Progression": "Increase resistance"
        }
        """
        
        guard let data = testJSON.data(using: .utf8) else {
            print("❌ Failed to convert JSON to data")
            return false
        }
        
        do {
            let decoder = JSONDecoder()
            let imported = try decoder.decode(ImportedBlock.self, from: data)
            
            print("✅ Segment-only day parsing succeeded")
            print("   Title: \(imported.Title)")
            print("   Days: \(imported.Days?.count ?? 0)")
            
            guard imported.Title == "BJJ Fundamentals Class" else {
                print("❌ Title mismatch")
                return false
            }
            
            guard let days = imported.Days, days.count == 1 else {
                print("❌ Days count mismatch")
                return false
            }
            
            let firstDay = days[0]
            guard firstDay.name == "Class: Guard Basics" else {
                print("❌ Day name mismatch")
                return false
            }
            
            // Exercises should be nil or empty since not provided
            guard firstDay.exercises == nil || firstDay.exercises?.isEmpty == true else {
                print("❌ Exercises should be nil or empty")
                return false
            }
            
            // Convert to Block to ensure conversion works
            let block = BlockGenerator.convertToBlock(imported)
            
            guard block.days.count == 1 else {
                print("❌ Block days count mismatch")
                return false
            }
            
            let convertedDay = block.days[0]
            guard convertedDay.exercises.isEmpty else {
                print("❌ Converted day should have empty exercises array")
                return false
            }
            
            return true
            
        } catch {
            print("❌ Segment-only day parsing failed: \(error)")
            return false
        }
    }
    
    // MARK: - Run All Tests
    
    /// Run all BlockGenerator tests
    static func runAll() -> Bool {
        print("\n=== BlockGenerator Tests ===\n")
        
        var allPassed = true
        
        print("Test 1: JSON Parsing")
        if !testJSONParsing() {
            allPassed = false
        }
        print("")
        
        print("Test 2: HumanReadable Parsing")
        if !testHumanReadableParsing() {
            allPassed = false
        }
        print("")
        
        print("Test 3: Block Conversion")
        if !testBlockConversion() {
            allPassed = false
        }
        print("")
        
        print("Test 4: Segment-Only Day Parsing")
        if !testSegmentOnlyDayParsing() {
            allPassed = false
        }
        print("")
        
        if allPassed {
            print("✅ All BlockGenerator tests passed!")
        } else {
            print("❌ Some tests failed")
        }
        
        return allPassed
    }
}

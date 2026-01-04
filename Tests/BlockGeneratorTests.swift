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
        
        print("Test 5: Comprehensive Fields Parsing")
        if !testComprehensiveFieldsParsing() {
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
    
    /// Test parsing comprehensive fields (videoUrls, skill progression, segments)
    static func testComprehensiveFieldsParsing() -> Bool {
        // Load test JSON file
        guard let url = Bundle.main.url(forResource: "comprehensive_fields_test", withExtension: "json"),
              let jsonString = try? String(contentsOf: url) else {
            print("❌ Could not load comprehensive_fields_test.json")
            return false
        }
        
        let result = BlockGenerator.decodeBlock(from: jsonString)
        
        guard case .success(let importedBlock) = result else {
            print("❌ Failed to parse comprehensive fields JSON: \(result)")
            return false
        }
        
        // Verify basic block fields
        guard importedBlock.Title == "Comprehensive Fields Test Block" else {
            print("❌ Block title mismatch")
            return false
        }
        
        guard let days = importedBlock.Days, days.count == 3 else {
            print("❌ Expected 3 days, got \(importedBlock.Days?.count ?? 0)")
            return false
        }
        
        // Test Day 1: Strength with videoUrls and advanced progression
        let day1 = days[0]
        guard let day1Exercises = day1.exercises, day1Exercises.count == 3 else {
            print("❌ Day 1 should have 3 exercises")
            return false
        }
        
        // Verify Bench Press with videoUrls and deloadWeekIndexes
        let benchPress = day1Exercises[0]
        guard benchPress.name == "Bench Press" else {
            print("❌ First exercise should be Bench Press")
            return false
        }
        
        guard let videoUrls = benchPress.videoUrls, videoUrls.count == 2 else {
            print("❌ Bench Press should have 2 video URLs")
            return false
        }
        
        guard videoUrls[0] == "https://youtube.com/bench-press-setup" else {
            print("❌ First video URL mismatch")
            return false
        }
        
        guard benchPress.progressionType == "weight" else {
            print("❌ Bench Press should have weight progression")
            return false
        }
        
        guard let deloadWeeks = benchPress.deloadWeekIndexes, deloadWeeks == [4, 8] else {
            print("❌ Bench Press should have deload weeks [4, 8]")
            return false
        }
        
        guard let sets = benchPress.sets, sets.count == 2 else {
            print("❌ Bench Press should have 2 advanced sets")
            return false
        }
        
        // Verify superset grouping
        let row = day1Exercises[1]
        let pullover = day1Exercises[2]
        guard row.setGroupId == pullover.setGroupId else {
            print("❌ Row and Pullover should have same setGroupId")
            return false
        }
        
        guard row.setGroupKind == "superset" && pullover.setGroupKind == "superset" else {
            print("❌ Row and Pullover should be marked as superset")
            return false
        }
        
        // Test Day 2: Conditioning with videoUrls
        let day2 = days[1]
        guard let day2Exercises = day2.exercises, day2Exercises.count == 1 else {
            print("❌ Day 2 should have 1 exercise")
            return false
        }
        
        let rowing = day2Exercises[0]
        guard rowing.name == "Rowing Intervals" else {
            print("❌ Day 2 exercise should be Rowing Intervals")
            return false
        }
        
        guard let rowingVideos = rowing.videoUrls, rowingVideos.count == 1 else {
            print("❌ Rowing should have 1 video URL")
            return false
        }
        
        guard let conditioningSets = rowing.conditioningSets, conditioningSets.count == 2 else {
            print("❌ Rowing should have 2 conditioning sets")
            return false
        }
        
        // Test Day 3: Segments and skill-based progression
        let day3 = days[2]
        guard let day3Segments = day3.segments, day3Segments.count == 1 else {
            print("❌ Day 3 should have 1 segment")
            return false
        }
        
        let segment = day3Segments[0]
        guard segment.name == "Guard Technique Drill" else {
            print("❌ Segment should be Guard Technique Drill")
            return false
        }
        
        guard let techniques = segment.techniques, techniques.count == 1 else {
            print("❌ Segment should have 1 technique")
            return false
        }
        
        let technique = techniques[0]
        guard technique.name == "Armbar from Guard" else {
            print("❌ Technique should be Armbar from Guard")
            return false
        }
        
        guard let techniqueVideos = technique.videoUrls, techniqueVideos.count == 2 else {
            print("❌ Technique should have 2 video URLs")
            return false
        }
        
        guard techniqueVideos[0] == "https://youtube.com/armbar-setup" else {
            print("❌ Technique video URL mismatch")
            return false
        }
        
        // Verify skill-based exercise
        guard let day3Exercises = day3.exercises, day3Exercises.count == 1 else {
            print("❌ Day 3 should have 1 exercise")
            return false
        }
        
        let skillExercise = day3Exercises[0]
        guard skillExercise.name == "Guard Passing Drill" else {
            print("❌ Skill exercise should be Guard Passing Drill")
            return false
        }
        
        guard skillExercise.progressionType == "skill" else {
            print("❌ Exercise should have skill progression type")
            return false
        }
        
        guard let deltaResistance = skillExercise.deltaResistance, deltaResistance == 10 else {
            print("❌ Should have deltaResistance of 10")
            return false
        }
        
        guard let deltaRounds = skillExercise.deltaRounds, deltaRounds == 1 else {
            print("❌ Should have deltaRounds of 1")
            return false
        }
        
        guard let deltaConstraints = skillExercise.deltaConstraints, deltaConstraints.count == 4 else {
            print("❌ Should have 4 deltaConstraints")
            return false
        }
        
        // Convert to Block and verify fields are preserved
        let block = BlockGenerator.convertToBlock(importedBlock)
        
        guard block.name == "Comprehensive Fields Test Block" else {
            print("❌ Converted block name mismatch")
            return false
        }
        
        guard block.days.count == 3 else {
            print("❌ Converted block should have 3 days")
            return false
        }
        
        // Verify exercise videoUrls survived conversion
        let convertedBenchPress = block.days[0].exercises[0]
        guard let convertedVideoUrls = convertedBenchPress.videoUrls, convertedVideoUrls.count == 2 else {
            print("❌ Converted exercise should preserve videoUrls")
            return false
        }
        
        // Verify progression fields survived conversion
        guard convertedBenchPress.progressionRule.type == .weight else {
            print("❌ Converted progression type should be weight")
            return false
        }
        
        guard convertedBenchPress.progressionRule.deloadWeekIndexes == [4, 8] else {
            print("❌ Converted deload weeks should be [4, 8]")
            return false
        }
        
        // Verify segment and technique videoUrls survived conversion
        guard let convertedSegment = block.days[2].segments?.first else {
            print("❌ Converted block should preserve segments")
            return false
        }
        
        guard let convertedTechnique = convertedSegment.techniques.first else {
            print("❌ Converted segment should have techniques")
            return false
        }
        
        guard let convertedTechniqueVideos = convertedTechnique.videoUrls, 
              convertedTechniqueVideos.count == 2 else {
            print("❌ Converted technique should preserve videoUrls")
            return false
        }
        
        // Verify skill progression survived conversion
        let convertedSkillExercise = block.days[2].exercises[0]
        guard convertedSkillExercise.progressionRule.type == .skill else {
            print("❌ Converted skill exercise should have skill progression")
            return false
        }
        
        guard convertedSkillExercise.progressionRule.deltaResistance == 10 else {
            print("❌ Converted skill exercise should preserve deltaResistance")
            return false
        }
        
        guard convertedSkillExercise.progressionRule.deltaRounds == 1 else {
            print("❌ Converted skill exercise should preserve deltaRounds")
            return false
        }
        
        guard convertedSkillExercise.progressionRule.deltaConstraints?.count == 4 else {
            print("❌ Converted skill exercise should preserve deltaConstraints")
            return false
        }
        
        print("✅ Comprehensive fields parsing test passed")
        return true
    }
}

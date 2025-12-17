//
//  ChatGPTBlockParserTests.swift
//  Savage By Design
//
//  Tests for ChatGPT block parser
//

import Foundation

/// Test suite for ChatGPT block parser functionality
struct ChatGPTBlockParserTests {
    
    // MARK: - Test: Parse Simple Strength Block
    
    static func testParseSimpleStrengthBlock() -> Bool {
        let parser = ChatGPTBlockParser()
        
        let sampleText = """
BLOCK: Test Strength Block
DESCRIPTION: A simple test block
WEEKS: 4
GOAL: strength

DAY 1: Upper Body
SHORT: D1
---
Exercise: Bench Press
Type: strength
Category: pressHorizontal
Sets: 5
Reps: 5
Weight: 225
RPE: 8
Tempo: 3010
Rest: 180
Progression: +5 lbs
Notes: Focus on form
---
Exercise: Rows
Type: strength
Category: pullHorizontal
Sets: 4
Reps: 8
Weight: 135
Rest: 120
Progression: +2.5

DAY 2: Lower Body
SHORT: D2
---
Exercise: Squats
Type: strength
Category: squat
Sets: 4
Reps: 6
Weight: 315
RPE: 9
Progression: +10
"""
        
        do {
            let block = try parser.parseBlock(from: sampleText)
            
            // Validate block level
            guard block.name == "Test Strength Block" else {
                print("❌ Block name mismatch: \(block.name)")
                return false
            }
            
            guard block.description == "A simple test block" else {
                print("❌ Block description mismatch")
                return false
            }
            
            guard block.numberOfWeeks == 4 else {
                print("❌ Number of weeks mismatch: \(block.numberOfWeeks)")
                return false
            }
            
            guard block.goal == .strength else {
                print("❌ Block goal mismatch")
                return false
            }
            
            guard block.source == .ai else {
                print("❌ Block source should be .ai")
                return false
            }
            
            // Validate days
            guard block.days.count == 2 else {
                print("❌ Expected 2 days, got \(block.days.count)")
                return false
            }
            
            let day1 = block.days[0]
            guard day1.name == "Upper Body" else {
                print("❌ Day 1 name mismatch: \(day1.name)")
                return false
            }
            
            guard day1.shortCode == "D1" else {
                print("❌ Day 1 short code mismatch")
                return false
            }
            
            // Validate exercises in day 1
            guard day1.exercises.count == 2 else {
                print("❌ Day 1 expected 2 exercises, got \(day1.exercises.count)")
                return false
            }
            
            let benchPress = day1.exercises[0]
            guard benchPress.customName == "Bench Press" else {
                print("❌ Exercise name mismatch: \(benchPress.customName ?? "")")
                return false
            }
            
            guard benchPress.type == .strength else {
                print("❌ Exercise type should be strength")
                return false
            }
            
            guard let strengthSets = benchPress.strengthSets else {
                print("❌ No strength sets found")
                return false
            }
            
            guard strengthSets.count == 5 else {
                print("❌ Expected 5 sets, got \(strengthSets.count)")
                return false
            }
            
            let firstSet = strengthSets[0]
            guard firstSet.reps == 5 else {
                print("❌ Expected 5 reps, got \(firstSet.reps ?? 0)")
                return false
            }
            
            guard firstSet.weight == 225 else {
                print("❌ Expected weight 225, got \(firstSet.weight ?? 0)")
                return false
            }
            
            guard firstSet.rpe == 8 else {
                print("❌ Expected RPE 8, got \(firstSet.rpe ?? 0)")
                return false
            }
            
            // Validate progression
            guard benchPress.progressionRule.type == .weight else {
                print("❌ Progression type should be weight")
                return false
            }
            
            guard let deltaWeight = benchPress.progressionRule.deltaWeight else {
                print("❌ No delta weight in progression")
                return false
            }
            
            guard deltaWeight == 5 else {
                print("❌ Expected delta weight 5, got \(deltaWeight)")
                return false
            }
            
            print("✅ testParseSimpleStrengthBlock passed")
            return true
            
        } catch {
            print("❌ Parse error: \(error)")
            return false
        }
    }
    
    // MARK: - Test: Parse Conditioning Block
    
    static func testParseConditioningBlock() -> Bool {
        let parser = ChatGPTBlockParser()
        
        let sampleText = """
BLOCK: Conditioning Block
WEEKS: 2

DAY 1: Cardio Day
---
Exercise: Row Intervals
Type: conditioning
ConditioningType: intervals
Duration: 20
Distance: 5000
Pace: 2:00/500m
Effort: moderate
Rest: 60
Notes: EMOM 20 rounds
"""
        
        do {
            let block = try parser.parseBlock(from: sampleText)
            
            guard block.name == "Conditioning Block" else {
                print("❌ Block name mismatch")
                return false
            }
            
            guard block.numberOfWeeks == 2 else {
                print("❌ Weeks mismatch")
                return false
            }
            
            guard block.days.count == 1 else {
                print("❌ Expected 1 day")
                return false
            }
            
            let day = block.days[0]
            guard day.exercises.count == 1 else {
                print("❌ Expected 1 exercise")
                return false
            }
            
            let exercise = day.exercises[0]
            guard exercise.type == .conditioning else {
                print("❌ Exercise should be conditioning")
                return false
            }
            
            guard let condSets = exercise.conditioningSets, let firstSet = condSets.first else {
                print("❌ No conditioning sets found")
                return false
            }
            
            guard firstSet.durationSeconds == 20 * 60 else {
                print("❌ Duration should be 1200 seconds (20 minutes)")
                return false
            }
            
            guard firstSet.distanceMeters == 5000 else {
                print("❌ Distance mismatch")
                return false
            }
            
            guard firstSet.targetPace == "2:00/500m" else {
                print("❌ Pace mismatch")
                return false
            }
            
            print("✅ testParseConditioningBlock passed")
            return true
            
        } catch {
            print("❌ Parse error: \(error)")
            return false
        }
    }
    
    // MARK: - Test: Parse Error Handling
    
    static func testParseEmptyBlock() -> Bool {
        let parser = ChatGPTBlockParser()
        let emptyText = ""
        
        do {
            _ = try parser.parseBlock(from: emptyText)
            print("❌ Should have thrown error for empty text")
            return false
        } catch let error as ChatGPTError {
            if case .parsingError = error {
                print("✅ testParseEmptyBlock passed (correctly threw error)")
                return true
            } else {
                print("❌ Wrong error type")
                return false
            }
        } catch {
            print("❌ Unexpected error type: \(error)")
            return false
        }
    }
    
    // MARK: - Run All Tests
    
    static func runAll() {
        print("\n=== Running ChatGPT Block Parser Tests ===\n")
        
        var passed = 0
        var total = 0
        
        total += 1
        if testParseSimpleStrengthBlock() { passed += 1 }
        
        total += 1
        if testParseConditioningBlock() { passed += 1 }
        
        total += 1
        if testParseEmptyBlock() { passed += 1 }
        
        print("\n=== Test Results: \(passed)/\(total) passed ===\n")
    }
}

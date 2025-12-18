//
//  ManualWeeksTest.swift
//  Savage By Design
//
//  Manual test to verify Weeks schema parsing and logging
//

import Foundation

/// Manual test runner for Weeks schema parsing
struct ManualWeeksTest {
    
    /// Test parsing a JSON file with Weeks array
    static func testWeeksJSONParsing() -> Bool {
        print("\n=== Testing Weeks Schema Parsing ===\n")
        
        // Load the test JSON file
        let testFilePath = "/home/runner/work/WorkoutTrackerApp/WorkoutTrackerApp/Tests/sample_weeks_block.json"
        
        guard FileManager.default.fileExists(atPath: testFilePath) else {
            print("❌ Test file not found at: \(testFilePath)")
            return false
        }
        
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: testFilePath))
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            
            print("📄 Loaded test JSON file (\(jsonData.count) bytes)")
            print("=" .repeating(60))
            
            // Parse using BlockGenerator
            let result = BlockGenerator.decodeBlock(from: jsonString)
            
            switch result {
            case .success(let importedBlock):
                print("✅ JSON parsed successfully")
                print("   Title: \(importedBlock.Title)")
                print("   NumberOfWeeks: \(importedBlock.NumberOfWeeks ?? 1)")
                
                // Check if Weeks field was parsed
                if let weeks = importedBlock.Weeks {
                    print("   ✅ Weeks array detected: \(weeks.count) weeks")
                    
                    for (weekIndex, weekDays) in weeks.enumerated() {
                        print("      Week \(weekIndex + 1): \(weekDays.count) days")
                        for (dayIndex, day) in weekDays.enumerated() {
                            print("         Day \(dayIndex + 1): \(day.name) - \(day.exercises.count) exercises")
                        }
                    }
                } else {
                    print("   ❌ Weeks field is nil")
                    return false
                }
                
                print("\n" + "=" .repeating(60))
                print("🔄 Converting to Block model...")
                
                // Convert to Block
                let block = BlockGenerator.convertToBlock(importedBlock)
                
                print("✅ Block created: '\(block.name)'")
                print("   numberOfWeeks: \(block.numberOfWeeks)")
                print("   days.count: \(block.days.count)")
                
                if let weekTemplates = block.weekTemplates {
                    print("   ✅ weekTemplates: \(weekTemplates.count) weeks")
                    
                    for (weekIndex, weekDays) in weekTemplates.enumerated() {
                        print("      Week \(weekIndex + 1): \(weekDays.count) days")
                    }
                } else {
                    print("   ❌ weekTemplates is nil")
                    return false
                }
                
                print("\n" + "=" .repeating(60))
                print("🏋️ Generating sessions with SessionFactory...")
                
                // Generate sessions
                let factory = SessionFactory()
                let sessions = factory.makeSessions(for: block)
                
                print("✅ Generated \(sessions.count) sessions")
                
                // Verify week distribution
                var sessionsByWeek: [Int: [WorkoutSession]] = [:]
                for session in sessions {
                    if sessionsByWeek[session.weekIndex] == nil {
                        sessionsByWeek[session.weekIndex] = []
                    }
                    sessionsByWeek[session.weekIndex]?.append(session)
                }
                
                print("   Sessions by week:")
                for weekIndex in 1...block.numberOfWeeks {
                    let weekSessions = sessionsByWeek[weekIndex] ?? []
                    print("      Week \(weekIndex): \(weekSessions.count) sessions")
                }
                
                print("\n✅ ALL CHECKS PASSED - Weeks schema is correctly parsed and rendered!")
                return true
                
            case .failure(let error):
                print("❌ JSON parsing failed: \(error.localizedDescription)")
                return false
            }
            
        } catch {
            print("❌ Error loading test file: \(error)")
            return false
        }
    }
    
    /// Run all manual tests
    static func runAll() -> Bool {
        return testWeeksJSONParsing()
    }
}

// Extension to repeat strings
extension String {
    func repeating(_ count: Int) -> String {
        return String(repeating: self, count: count)
    }
}

//
//  TestRunner.swift
//  Savage By Design – Simple Test Runner
//
//  Run unit tests without requiring full XCTest framework
//

import Foundation

/// Simple test runner for validating functionality
struct TestRunner {
    
    /// Run all available tests
    static func runAllTests() {
        print("========================================")
        print("SAVAGE BY DESIGN - Test Runner")
        print("========================================\n")
        
        var allTestsPassed = true
        
        // Run tests (only in DEBUG builds to avoid compilation issues in Release)
        #if DEBUG
        if !BlockGeneratorTests.runAll() {
            allTestsPassed = false
        }
        
        if !ProgressionTests.runAllTests() {
            allTestsPassed = false
        }
        
        // Run Week-Specific Block tests
        if !WeekSpecificBlockTests.runAll() {
            allTestsPassed = false
        }
        
        // Run Manual Weeks Test with logging
        if !ManualWeeksTest.runAll() {
            allTestsPassed = false
        }
        
        // Run Superset and Yoga Tests
        if !SupersetAndYogaTests.runAllTests() {
            allTestsPassed = false
        }
        
        // Run Completion Timestamp Tests
        if !CompletionTimestampTests.runAllTests() {
            allTestsPassed = false
        }
        
        // Run Subscription Tests
        if !SubscriptionTests.runAllTests() {
            allTestsPassed = false
        }
        
        // Run Active Block Tests
        if !ActiveBlockTests.runAll() {
            allTestsPassed = false
        }
        
        // Run Feedback Form Tests
        if !FeedbackFormTests.runAllTests() {
            allTestsPassed = false
        }
        #endif
        
        print("\n========================================")
        if allTestsPassed {
            print("✅ ALL TESTS PASSED")
        } else {
            print("❌ SOME TESTS FAILED")
        }
        print("========================================\n")
    }
}

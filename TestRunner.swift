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
        
        // Run BlockGenerator tests (only in DEBUG builds)
        #if DEBUG
        if !BlockGeneratorTests.runAll() {
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

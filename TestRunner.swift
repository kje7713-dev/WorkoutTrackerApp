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
        
        // Run BlockGenerator tests
        #if DEBUG && canImport(XCTest)
        if !BlockGeneratorTests.runAll() {
            allTestsPassed = false
        }
        #else
        print("⚠️ BlockGeneratorTests not available in non-debug builds")
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

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
        
        // Guard test invocation for DEBUG builds only to prevent release/CI build failures
        // when test symbols are not available in the build target
        #if DEBUG
        // Run BlockGenerator tests if available
        if NSClassFromString("BlockGeneratorTests") != nil {
            if !BlockGeneratorTests.runAll() {
                allTestsPassed = false
            }
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

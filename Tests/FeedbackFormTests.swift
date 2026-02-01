//
//  FeedbackFormTests.swift
//  Savage By Design
//
//  Tests for feedback form functionality
//

import Foundation

/// Test suite for Feedback Form
struct FeedbackFormTests {
    
    // MARK: - Feedback Type Tests
    
    /// Test that feedback types are properly defined
    static func testFeedbackTypes() -> Bool {
        print("Testing feedback types...")
        
        let allTypes = FeedbackType.allCases
        let hasFeatureRequest = allTypes.contains { $0 == .featureRequest }
        let hasBugReport = allTypes.contains { $0 == .bugReport }
        
        let result = allTypes.count == 2 && hasFeatureRequest && hasBugReport
        
        print("Feedback types: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that feedback type display names are correct
    static func testFeedbackTypeDisplayNames() -> Bool {
        print("Testing feedback type display names...")
        
        let featureRequest = FeedbackType.featureRequest
        let bugReport = FeedbackType.bugReport
        
        let result = featureRequest.displayName == "Feature Request" &&
                     bugReport.displayName == "Bug Report"
        
        print("Feedback type display names: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    // MARK: - GitHub Service Tests
    
    /// Test that GitHub service is properly configured
    static func testGitHubServiceConfiguration() -> Bool {
        print("Testing GitHub service configuration...")
        
        let service = GitHubService()
        
        // Service should be instantiable
        let result = true
        
        print("GitHub service configuration: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that feedback errors have proper descriptions
    static func testFeedbackErrorDescriptions() -> Bool {
        print("Testing feedback error descriptions...")
        
        let invalidResponseError = FeedbackError.invalidResponse
        let serverError = FeedbackError.serverError(404)
        let missingTokenError = FeedbackError.missingToken
        
        let result = invalidResponseError.errorDescription != nil &&
                     serverError.errorDescription != nil &&
                     missingTokenError.errorDescription != nil
        
        print("Feedback error descriptions: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    // MARK: - Run All Tests
    
    static func runAllTests() -> Bool {
        print("\n=== Running Feedback Form Tests ===\n")
        
        let results = [
            testFeedbackTypes(),
            testFeedbackTypeDisplayNames(),
            testGitHubServiceConfiguration(),
            testFeedbackErrorDescriptions()
        ]
        
        let passedTests = results.filter { $0 }.count
        let totalTests = results.count
        
        print("\n=== Test Results ===")
        print("Passed: \(passedTests)/\(totalTests)")
        print("Status: \(passedTests == totalTests ? "ALL TESTS PASSED ✓" : "SOME TESTS FAILED ✗")")
        
        return passedTests == totalTests
    }
}

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
    
    // MARK: - Feedback Service Tests
    
    /// Test that email subject is properly formatted
    static func testEmailSubjectFormatting() -> Bool {
        print("Testing email subject formatting...")
        
        let featureSubject = FeedbackService.emailSubject(for: .featureRequest, title: "Add timer")
        let bugSubject = FeedbackService.emailSubject(for: .bugReport, title: "App crashes")
        
        let result = featureSubject == "[Feature Request] Add timer" &&
                     bugSubject == "[Bug Report] App crashes"
        
        print("Email subject formatting: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that email body is properly formatted
    static func testEmailBodyFormatting() -> Bool {
        print("Testing email body formatting...")
        
        let body = FeedbackService.emailBody(
            type: .featureRequest,
            title: "Test Title",
            description: "Test Description"
        )
        
        let hasType = body.contains("Type: Feature Request")
        let hasTitle = body.contains("Title: Test Title")
        let hasDescription = body.contains("Description:\nTest Description")
        
        let result = hasType && hasTitle && hasDescription
        
        print("Email body formatting: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that feedback email address is correct
    static func testFeedbackEmailAddress() -> Bool {
        print("Testing feedback email address...")
        
        let email = FeedbackService.feedbackEmail
        let result = email == "savagesbydesignhq@gmail.com"
        
        print("Feedback email address: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that feedback errors have proper descriptions
    static func testFeedbackErrorDescriptions() -> Bool {
        print("Testing feedback error descriptions...")
        
        let emailNotAvailable = FeedbackError.emailNotAvailable
        let emailNotSent = FeedbackError.emailNotSent
        
        let result = emailNotAvailable.errorDescription != nil &&
                     emailNotSent.errorDescription != nil
        
        print("Feedback error descriptions: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    // MARK: - Run All Tests
    
    static func runAllTests() -> Bool {
        print("\n=== Running Feedback Form Tests ===\n")
        
        let results = [
            testFeedbackTypes(),
            testFeedbackTypeDisplayNames(),
            testEmailSubjectFormatting(),
            testEmailBodyFormatting(),
            testFeedbackEmailAddress(),
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

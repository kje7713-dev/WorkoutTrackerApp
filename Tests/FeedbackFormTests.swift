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
    
    /// Test that mailto URL is properly generated
    static func testMailtoURLGeneration() -> Bool {
        print("Testing mailto URL generation...")
        
        let mailtoURL = FeedbackService.mailtoURL(
            for: .featureRequest,
            title: "Test Feature",
            description: "Test Description"
        )
        
        guard let url = mailtoURL else {
            print("Mailto URL generation: FAIL (URL is nil)")
            return false
        }
        
        let urlString = url.absoluteString
        let hasMailto = urlString.starts(with: "mailto:")
        let hasEmail = urlString.contains(FeedbackService.feedbackEmail)
        let hasSubject = urlString.contains("subject=")
        let hasBody = urlString.contains("body=")
        
        let result = hasMailto && hasEmail && hasSubject && hasBody
        
        print("Mailto URL generation: \(result ? "PASS" : "FAIL")")
        return result
    }
    
    /// Test that mailto URL properly encodes special characters
    static func testMailtoURLEncoding() -> Bool {
        print("Testing mailto URL encoding...")
        
        let mailtoURL = FeedbackService.mailtoURL(
            for: .bugReport,
            title: "Test & Special",
            description: "Description with spaces and special chars: @#$%"
        )
        
        guard let url = mailtoURL else {
            print("Mailto URL encoding: FAIL (URL is nil)")
            return false
        }
        
        let urlString = url.absoluteString
        // Check that spaces are encoded
        let hasNoSpaces = !urlString.contains(" ")
        
        // Check that ampersand in the title/body is encoded (not the & in URL params)
        // Extract just the query parameters portion (after the ?)
        if let queryStart = urlString.firstIndex(of: "?") {
            let queryString = String(urlString[queryStart...])
            let hasEncodedAmpersand = queryString.contains("%26") // & in title should be %26
            
            let result = hasNoSpaces && hasEncodedAmpersand
            print("Mailto URL encoding: \(result ? "PASS" : "FAIL")")
            return result
        }
        
        // Fallback: at minimum check no spaces
        let result = hasNoSpaces
        print("Mailto URL encoding: \(result ? "PASS" : "FAIL")")
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
            testFeedbackErrorDescriptions(),
            testMailtoURLGeneration(),
            testMailtoURLEncoding()
        ]
        
        let passedTests = results.filter { $0 }.count
        let totalTests = results.count
        
        print("\n=== Test Results ===")
        print("Passed: \(passedTests)/\(totalTests)")
        print("Status: \(passedTests == totalTests ? "ALL TESTS PASSED ✓" : "SOME TESTS FAILED ✗")")
        
        return passedTests == totalTests
    }
}

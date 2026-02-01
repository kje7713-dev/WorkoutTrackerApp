//
//  FeedbackService.swift
//  Savage By Design
//
//  Service for submitting feedback via email
//

import Foundation
import MessageUI

/// Service for sending feedback emails
class FeedbackService {
    static let feedbackEmail = "savagesbydesignhq@gmail.com"
    
    /// Check if device can send email
    static func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    /// Create email subject from feedback type
    static func emailSubject(for type: FeedbackType, title: String) -> String {
        let prefix = type == .featureRequest ? "[Feature Request]" : "[Bug Report]"
        return "\(prefix) \(title)"
    }
    
    /// Create email body from feedback
    static func emailBody(type: FeedbackType, title: String, description: String) -> String {
        return """
        Type: \(type.displayName)
        Title: \(title)
        
        Description:
        \(description)
        
        ---
        Submitted from Savage By Design iOS App
        """
    }
}

/// Type of feedback submission
enum FeedbackType: String, CaseIterable, Identifiable {
    case featureRequest = "Feature Request"
    case bugReport = "Bug Report"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
}

/// Errors that can occur during feedback submission
enum FeedbackError: LocalizedError {
    case emailNotAvailable
    case emailNotSent
    
    var errorDescription: String? {
        switch self {
        case .emailNotAvailable:
            return "Email is not available on this device. Please check your email settings."
        case .emailNotSent:
            return "Failed to send feedback. Please try again."
        }
    }
}

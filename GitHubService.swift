//
//  GitHubService.swift
//  Savage By Design
//
//  Service for submitting feedback to GitHub issues
//

import Foundation

/// Service for creating GitHub issues for feedback
class GitHubService {
    private let owner = "kje7713-dev"
    private let repo = "WorkoutTrackerApp"
    
    /// Submit feedback as a GitHub issue
    /// - Parameters:
    ///   - type: Type of feedback (Feature Request or Bug Report)
    ///   - title: Issue title
    ///   - description: Issue description
    ///   - token: GitHub personal access token
    /// - Returns: Issue URL if successful
    func submitFeedback(
        type: FeedbackType,
        title: String,
        description: String,
        token: String
    ) async throws -> String {
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/issues")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let label = type == .featureRequest ? "enhancement" : "bug"
        let body: [String: Any] = [
            "title": title,
            "body": description,
            "labels": [label]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FeedbackError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw FeedbackError.serverError(httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let htmlUrl = json?["html_url"] as? String else {
            throw FeedbackError.invalidResponse
        }
        
        return htmlUrl
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
    case invalidResponse
    case serverError(Int)
    case missingToken
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error: \(code)"
        case .missingToken:
            return "Configuration error. Please try again later."
        }
    }
}

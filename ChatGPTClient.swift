//
//  ChatGPTClient.swift
//  Savage By Design – OpenAI Chat Completions Streaming Client
//
//  Direct integration with OpenAI's Chat Completions API with streaming support.
//

import Foundation

// MARK: - ChatGPT Client Errors

public enum ChatGPTClientError: Error, LocalizedError {
    case noAPIKey
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case streamParsingError(String)
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "OpenAI API key not found. Please configure your API key in settings."
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .streamParsingError(let details):
            return "Stream parsing error: \(details)"
        case .cancelled:
            return "Request was cancelled"
        }
    }
}

// MARK: - API Response Structures

private struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let stream: Bool
    let temperature: Double?
    
    init(model: String, messages: [ChatMessage], stream: Bool = true, temperature: Double? = 0.7) {
        self.model = model
        self.messages = messages
        self.stream = stream
        self.temperature = temperature
    }
}

private struct ChatCompletionChunk: Codable {
    struct Choice: Codable {
        struct Delta: Codable {
            let content: String?
        }
        let delta: Delta
    }
    let choices: [Choice]
}

// MARK: - ChatGPT Client

/// Client for OpenAI Chat Completions API with streaming support
public class ChatGPTClient {
    
    // MARK: - Configuration
    
    /// OpenAI API base URL
    /// NOTE: Change this to use a proxy if needed (e.g., for rate limiting or custom routing)
    private let baseURL = "https://api.openai.com/v1"
    
    /// Supported models
    public enum Model: String, CaseIterable {
        case gpt35Turbo = "gpt-3.5-turbo"
        case gpt4 = "gpt-4"
        
        public var displayName: String {
            switch self {
            case .gpt35Turbo: return "GPT-3.5 Turbo"
            case .gpt4: return "GPT-4"
            }
        }
    }
    
    // MARK: - State
    
    private var currentTask: URLSessionDataTask?
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Streaming API
    
    /// Stream completion from OpenAI with incremental updates
    /// - Parameters:
    ///   - messages: Array of chat messages (system + user)
    ///   - model: The model to use (default: gpt-3.5-turbo)
    ///   - onChunk: Called for each incremental content delta
    ///   - onComplete: Called when streaming ends with the full combined text
    ///   - onError: Called if an error occurs
    public func streamCompletion(
        messages: [ChatMessage],
        model: Model = .gpt35Turbo,
        onChunk: @escaping (String) -> Void,
        onComplete: @escaping (String) -> Void,
        onError: @escaping (ChatGPTClientError) -> Void
    ) {
        // Get API key from keychain
        let apiKey: String
        do {
            apiKey = try KeychainHelper.readOpenAIAPIKey()
        } catch {
            onError(.noAPIKey)
            return
        }
        
        // Build request URL
        // NOTE: If using a proxy, modify the baseURL constant above
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            onError(.invalidURL)
            return
        }
        
        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build request body
        let requestBody = ChatCompletionRequest(
            model: model.rawValue,
            messages: messages,
            stream: true
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            onError(.networkError(error))
            return
        }
        
        // Create data task
        let session = URLSession.shared
        var accumulatedText = ""
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard self?.currentTask != nil else {
                onError(.cancelled)
                return
            }
            
            if let error = error {
                onError(.networkError(error))
                return
            }
            
            guard let data = data else {
                onError(.invalidResponse)
                return
            }
            
            // Parse the streaming response
            let result = self?.parseStreamingResponse(data: data, onChunk: { chunk in
                accumulatedText += chunk
                onChunk(chunk)
            })
            
            if let error = result?.error {
                onError(error)
            } else {
                onComplete(accumulatedText)
            }
            
            self?.currentTask = nil
        }
        
        self.currentTask = task
        task.resume()
    }
    
    // MARK: - Cancellation
    
    /// Cancel the current streaming request
    public func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    // MARK: - Streaming Response Parser
    
    /// Parse OpenAI's server-sent-events format
    /// - Parameters:
    ///   - data: Raw response data
    ///   - onChunk: Callback for each content chunk
    /// - Returns: Result indicating success or error
    private func parseStreamingResponse(
        data: Data,
        onChunk: (String) -> Void
    ) -> (error: ChatGPTClientError?) {
        guard let responseString = String(data: data, encoding: .utf8) else {
            return (error: .streamParsingError("Could not decode response as UTF-8"))
        }
        
        // Split by newlines and process each line
        let lines = responseString.components(separatedBy: .newlines)
        
        for line in lines {
            // Skip empty lines
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            
            // Look for "data: " prefix
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6)) // Remove "data: " prefix
                
                // Check for [DONE] marker
                if jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                    // Stream complete
                    continue
                }
                
                // Parse JSON chunk
                guard let jsonData = jsonString.data(using: .utf8) else {
                    continue
                }
                
                do {
                    let chunk = try JSONDecoder().decode(ChatCompletionChunk.self, from: jsonData)
                    if let content = chunk.choices.first?.delta.content {
                        onChunk(content)
                    }
                } catch {
                    // Some chunks may not have content (e.g., role assignment), skip them
                    continue
                }
            }
        }
        
        return (error: nil)
    }
}

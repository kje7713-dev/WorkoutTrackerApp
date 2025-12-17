//
//  ChatGPTClient.swift
//  Savage By Design
//
//  OpenAI Chat Completions API client with streaming support
//

import Foundation

// MARK: - Message Types

public struct ChatMessage: Codable, Equatable {
    public let role: String
    public let content: String
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

// MARK: - API Request/Response Types

private struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let stream: Bool
    let temperature: Double?
    let max_tokens: Int?
}

private struct ChatCompletionResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
        let finish_reason: String?
    }
    let choices: [Choice]
}

private struct ChatCompletionStreamResponse: Codable {
    struct Choice: Codable {
        struct Delta: Codable {
            let content: String?
            let role: String?
        }
        let delta: Delta
        let finish_reason: String?
    }
    let choices: [Choice]
}

// MARK: - Error Types

public enum ChatGPTError: Error, LocalizedError {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    case cancelled
    case parsingError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid or missing API key"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .apiError(let message):
            return "API error: \(message)"
        case .cancelled:
            return "Request was cancelled"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        }
    }
}

// MARK: - ChatGPT Client

public class ChatGPTClient {
    
    private let apiBaseURL = "https://api.openai.com/v1/chat/completions"
    private var currentTask: URLSessionDataTask?
    
    public init() {}
    
    // MARK: - Streaming Completion
    
    /// Stream a chat completion from OpenAI with incremental updates
    /// - Parameters:
    ///   - messages: Array of chat messages (system, user, assistant)
    ///   - model: OpenAI model to use (default: "gpt-3.5-turbo")
    ///   - apiKey: OpenAI API key
    ///   - temperature: Sampling temperature (0-2, default: 0.7)
    ///   - maxTokens: Maximum tokens in response (optional)
    ///   - onChunk: Callback for each chunk of text received
    ///   - onComplete: Callback when streaming completes with full text or error
    public func streamCompletion(
        messages: [ChatMessage],
        model: String = "gpt-3.5-turbo",
        apiKey: String,
        temperature: Double = 0.7,
        maxTokens: Int? = nil,
        onChunk: @escaping (String) -> Void,
        onComplete: @escaping (Result<String, ChatGPTError>) -> Void
    ) {
        // Cancel any existing request
        cancel()
        
        guard !apiKey.isEmpty else {
            onComplete(.failure(.invalidAPIKey))
            return
        }
        
        // Create request
        guard let url = URL(string: apiBaseURL) else {
            onComplete(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ChatCompletionRequest(
            model: model,
            messages: messages,
            stream: true,
            temperature: temperature,
            max_tokens: maxTokens
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            onComplete(.failure(.parsingError("Failed to encode request: \(error.localizedDescription)")))
            return
        }
        
        // Create streaming session with custom delegate for true incremental streaming
        let session = URLSession.shared
        var accumulatedText = ""
        
        // Note: Using standard dataTask which provides data in chunks.
        // For production, consider using URLSessionDataDelegate for true streaming.
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard self?.currentTask != nil else {
                onComplete(.failure(.cancelled))
                return
            }
            
            if let error = error {
                onComplete(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                onComplete(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                onComplete(.failure(.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")))
                return
            }
            
            guard let data = data else {
                onComplete(.failure(.invalidResponse))
                return
            }
            
            // Parse SSE stream from received data
            // Note: This is called once with all data. For true incremental updates,
            // use URLSessionDataDelegate methods which receive chunks incrementally.
            if let text = String(data: data, encoding: .utf8) {
                let lines = text.components(separatedBy: "\n")
                
                for line in lines {
                    if line.hasPrefix("data: ") {
                        let jsonString = String(line.dropFirst(6))
                        
                        if jsonString == "[DONE]" {
                            onComplete(.success(accumulatedText))
                            return
                        }
                        
                        if let jsonData = jsonString.data(using: .utf8) {
                            do {
                                let streamResponse = try JSONDecoder().decode(ChatCompletionStreamResponse.self, from: jsonData)
                                if let content = streamResponse.choices.first?.delta.content {
                                    accumulatedText += content
                                    onChunk(content)
                                }
                                
                                if streamResponse.choices.first?.finish_reason != nil {
                                    onComplete(.success(accumulatedText))
                                    return
                                }
                            } catch {
                                // Continue processing other chunks even if one fails
                                continue
                            }
                        }
                    }
                }
            }
        }
        
        currentTask = task
        task.resume()
    }
    
    // MARK: - Non-Streaming Completion
    
    /// Get a chat completion from OpenAI (non-streaming)
    /// - Parameters:
    ///   - messages: Array of chat messages
    ///   - model: OpenAI model to use
    ///   - apiKey: OpenAI API key
    ///   - temperature: Sampling temperature
    ///   - maxTokens: Maximum tokens in response
    /// - Returns: The completion text
    public func completion(
        messages: [ChatMessage],
        model: String = "gpt-3.5-turbo",
        apiKey: String,
        temperature: Double = 0.7,
        maxTokens: Int? = nil
    ) async throws -> String {
        guard !apiKey.isEmpty else {
            throw ChatGPTError.invalidAPIKey
        }
        
        guard let url = URL(string: apiBaseURL) else {
            throw ChatGPTError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ChatCompletionRequest(
            model: model,
            messages: messages,
            stream: false,
            temperature: temperature,
            max_tokens: maxTokens
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatGPTError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ChatGPTError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        let completionResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        
        guard let content = completionResponse.choices.first?.message.content else {
            throw ChatGPTError.invalidResponse
        }
        
        return content
    }
    
    // MARK: - Cancellation
    
    /// Cancel the current streaming request
    public func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }
}

//
//  KeychainHelper.swift
//  Savage By Design
//
//  Secure storage for API keys using iOS Keychain Services
//

import Foundation
import Security

public class KeychainHelper {
    
    public static let shared = KeychainHelper()
    
    private init() {}
    
    // MARK: - Save
    
    /// Save a string value to the keychain
    /// - Parameters:
    ///   - value: The string value to save
    ///   - key: The key to store the value under
    /// - Returns: True if successful, false otherwise
    @discardableResult
    public func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }
        
        // Delete any existing value first
        delete(forKey: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Load
    
    /// Load a string value from the keychain
    /// - Parameter key: The key to retrieve the value for
    /// - Returns: The stored string value, or nil if not found
    public func load(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    // MARK: - Delete
    
    /// Delete a value from the keychain
    /// - Parameter key: The key to delete
    /// - Returns: True if successful or item didn't exist, false otherwise
    @discardableResult
    public func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

// MARK: - Convenience Keys

extension KeychainHelper {
    
    private static let openAIAPIKeyKey = "com.kje7713.WorkoutTrackerApp.openai.apikey"
    
    /// Save OpenAI API key
    public func saveOpenAIAPIKey(_ apiKey: String) -> Bool {
        return save(apiKey, forKey: Self.openAIAPIKeyKey)
    }
    
    /// Load OpenAI API key
    public func loadOpenAIAPIKey() -> String? {
        return load(forKey: Self.openAIAPIKeyKey)
    }
    
    /// Delete OpenAI API key
    public func deleteOpenAIAPIKey() -> Bool {
        return delete(forKey: Self.openAIAPIKeyKey)
    }
}

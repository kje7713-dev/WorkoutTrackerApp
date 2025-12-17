//
//  KeychainHelper.swift
//  Savage By Design – Keychain Wrapper
//
//  Simple wrapper for storing/retrieving sensitive data like API keys.
//

import Foundation
import Security

// MARK: - Keychain Errors

public enum KeychainError: Error, LocalizedError {
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
    case itemNotFound
    case duplicateItem
    
    public var errorDescription: String? {
        switch self {
        case .unexpectedPasswordData:
            return "Unexpected password data format"
        case .unhandledError(let status):
            return "Keychain error: \(status)"
        case .itemNotFound:
            return "Item not found in keychain"
        case .duplicateItem:
            return "Item already exists in keychain"
        }
    }
}

// MARK: - KeychainHelper

/// Helper for storing and retrieving sensitive data in the Keychain
public struct KeychainHelper {
    
    // Key identifier for OpenAI API key
    private static let openAIAPIKeyIdentifier = "OpenAIAPIKey_v1"
    
    // MARK: - OpenAI API Key Operations
    
    /// Save OpenAI API key to keychain
    public static func saveOpenAIAPIKey(_ key: String) throws {
        try save(key: openAIAPIKeyIdentifier, value: key)
    }
    
    /// Read OpenAI API key from keychain
    public static func readOpenAIAPIKey() throws -> String {
        try read(key: openAIAPIKeyIdentifier)
    }
    
    /// Delete OpenAI API key from keychain
    public static func deleteOpenAIAPIKey() throws {
        try delete(key: openAIAPIKeyIdentifier)
    }
    
    // MARK: - Generic Keychain Operations
    
    /// Save a string value to keychain
    private static func save(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }
        
        // Build query for keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // First, try to delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            if status == errSecDuplicateItem {
                throw KeychainError.duplicateItem
            }
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    /// Read a string value from keychain
    private static func read(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unhandledError(status: status)
        }
        
        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return string
    }
    
    /// Delete a value from keychain
    private static func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}

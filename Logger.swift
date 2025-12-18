//
//  Logger.swift
//  WorkoutTrackerApp
//
//  Centralized logging utility for production-safe logging
//

import Foundation
import os.log

/// Centralized logging system that respects build configuration
enum AppLogger {
    
    /// Log levels following standard severity
    enum Level {
        case debug
        case info
        case warning
        case error
        case critical
        
        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
            }
        }
        
        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .critical: return "🔥"
            }
        }
    }
    
    /// Log subsystems for filtering
    enum Subsystem: String {
        case repository = "com.kje7713.WorkoutTrackerApp.repository"
        case ui = "com.kje7713.WorkoutTrackerApp.ui"
        case session = "com.kje7713.WorkoutTrackerApp.session"
        case persistence = "com.kje7713.WorkoutTrackerApp.persistence"
        case general = "com.kje7713.WorkoutTrackerApp"
    }
    
    // MARK: - Configuration
    
    /// Enable/disable logging based on build configuration
    private static var isLoggingEnabled: Bool {
        #if DEBUG
        return true
        #else
        // In production, only log warnings and above
        return false
        #endif
    }
    
    // MARK: - Logging Methods
    
    /// Log a debug message (only in DEBUG builds)
    static func debug(_ message: String, subsystem: Subsystem = .general, category: String = "General") {
        #if DEBUG
        log(message, level: .debug, subsystem: subsystem, category: category)
        #endif
    }
    
    /// Log an informational message
    static func info(_ message: String, subsystem: Subsystem = .general, category: String = "General") {
        log(message, level: .info, subsystem: subsystem, category: category)
    }
    
    /// Log a warning message
    static func warning(_ message: String, subsystem: Subsystem = .general, category: String = "General") {
        log(message, level: .warning, subsystem: subsystem, category: category)
    }
    
    /// Log an error message
    static func error(_ message: String, subsystem: Subsystem = .general, category: String = "General") {
        log(message, level: .error, subsystem: subsystem, category: category)
    }
    
    /// Log a critical error message
    static func critical(_ message: String, subsystem: Subsystem = .general, category: String = "General") {
        log(message, level: .critical, subsystem: subsystem, category: category)
    }
    
    // MARK: - Private Implementation
    
    private static func log(_ message: String, level: Level, subsystem: Subsystem, category: String) {
        let logger = OSLog(subsystem: subsystem.rawValue, category: category)
        
        #if DEBUG
        // In debug, also print to console with emoji
        print("\(level.emoji) [\(subsystem.rawValue):\(category)] \(message)")
        #endif
        
        // Always log to unified logging system for Instruments/Console.app
        os_log("%{public}@", log: logger, type: level.osLogType, message)
    }
    
    // MARK: - Convenience Methods
    
    /// Log an error with context
    static func error(_ error: Error, context: String = "", subsystem: Subsystem = .general) {
        let message = context.isEmpty ? "\(error.localizedDescription)" : "\(context): \(error.localizedDescription)"
        log(message, level: .error, subsystem: subsystem, category: "Error")
    }
}

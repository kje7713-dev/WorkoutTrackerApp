//
//  DataManagementService.swift
//  Savage By Design
//
//  Service for data export/import and retention management
//

import Foundation

// MARK: - Export/Import Models

/// Container for all exportable app data
public struct AppDataExport: Codable {
    public var version: String
    public var exportDate: Date
    public var blocks: [Block]
    public var sessions: [WorkoutSession]
    public var exercises: [ExerciseDefinition]
    
    public init(
        version: String = "1.0",
        exportDate: Date = Date(),
        blocks: [Block],
        sessions: [WorkoutSession],
        exercises: [ExerciseDefinition]
    ) {
        self.version = version
        self.exportDate = exportDate
        self.blocks = blocks
        self.sessions = sessions
        self.exercises = exercises
    }
}

/// CSV export options
public enum CSVExportType {
    case workoutHistory
    case blockSummary
}

// MARK: - Data Management Service

public final class DataManagementService {
    
    private let blocksRepository: BlocksRepository
    private let sessionsRepository: SessionsRepository
    private let exerciseRepository: ExerciseLibraryRepository
    
    public init(
        blocksRepository: BlocksRepository,
        sessionsRepository: SessionsRepository,
        exerciseRepository: ExerciseLibraryRepository
    ) {
        self.blocksRepository = blocksRepository
        self.sessionsRepository = sessionsRepository
        self.exerciseRepository = exerciseRepository
    }
    
    // MARK: - Export
    
    /// Export all data as JSON
    public func exportAllDataAsJSON() throws -> Data {
        let exportData = AppDataExport(
            blocks: blocksRepository.allBlocks(),
            sessions: sessionsRepository.sessions,
            exercises: exerciseRepository.all()
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        return try encoder.encode(exportData)
    }
    
    /// Export workout history as CSV
    public func exportWorkoutHistoryAsCSV() -> String {
        var csv = "Date,Block,Week,Day,Exercise,Sets Completed,Total Reps,Total Weight\n"
        
        let sessions = sessionsRepository.sessions.sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
        
        for session in sessions {
            guard let date = session.date else { continue }
            
            let blockName = blocksRepository.getBlock(id: session.blockId)?.name ?? "Unknown"
            let dateString = ISO8601DateFormatter().string(from: date)
            let weekNum = session.weekIndex + 1
            
            for exercise in session.exercises {
                let exerciseName = getExerciseName(
                    definitionId: exercise.exerciseDefinitionId,
                    customName: exercise.customName
                )
                
                let completedSets = exercise.loggedSets.filter { $0.isCompleted }.count
                let totalReps = exercise.loggedSets.filter { $0.isCompleted }.compactMap { $0.loggedReps }.reduce(0, +)
                let totalWeight = exercise.loggedSets.filter { $0.isCompleted }.compactMap { $0.loggedWeight }.reduce(0.0, +)
                
                csv += "\(dateString),\(blockName),\(weekNum),Day \(session.dayTemplateId),\(exerciseName),\(completedSets),\(totalReps),\(totalWeight)\n"
            }
        }
        
        return csv
    }
    
    /// Export blocks summary as CSV
    public func exportBlocksSummaryAsCSV() -> String {
        var csv = "Block Name,Weeks,Days,Total Exercises,Goal,Source,Archived\n"
        
        for block in blocksRepository.allBlocks() {
            let totalExercises = block.days.reduce(0) { $0 + $1.exercises.count }
            let goal = block.goal?.rawValue ?? "N/A"
            let source = block.source.rawValue
            let archived = block.isArchived ? "Yes" : "No"
            
            csv += "\"\(block.name)\",\(block.numberOfWeeks),\(block.days.count),\(totalExercises),\(goal),\(source),\(archived)\n"
        }
        
        return csv
    }
    
    // MARK: - Import
    
    public enum ImportStrategy {
        case replace  // Replace all existing data
        case merge    // Merge with existing (skip duplicates by ID)
    }
    
    /// Import data from JSON
    public func importDataFromJSON(_ data: Data, strategy: ImportStrategy) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let importData = try decoder.decode(AppDataExport.self, from: data)
        
        AppLogger.info("Importing data from export version \(importData.version)", subsystem: .persistence, category: "DataManagement")
        
        switch strategy {
        case .replace:
            // Replace all data
            blocksRepository.replaceAll(with: importData.blocks)
            sessionsRepository.replaceAll(with: importData.sessions)
            // Note: Exercise library is intentionally not replaced to preserve user's custom exercises
            
        case .merge:
            // Merge blocks (skip duplicates by ID)
            let existingBlockIds = Set(blocksRepository.allBlocks().map { $0.id })
            let newBlocks = importData.blocks.filter { !existingBlockIds.contains($0.id) }
            newBlocks.forEach { blocksRepository.add($0) }
            
            // Merge sessions
            let existingSessionIds = Set(sessionsRepository.sessions.map { $0.id })
            let newSessions = importData.sessions.filter { !existingSessionIds.contains($0.id) }
            newSessions.forEach { sessionsRepository.add($0) }
            
            // Merge exercises
            let existingExerciseIds = Set(exerciseRepository.all().map { $0.id })
            let newExercises = importData.exercises.filter { !existingExerciseIds.contains($0.id) }
            newExercises.forEach { exerciseRepository.add($0) }
        }
        
        AppLogger.info("Import completed: \(importData.blocks.count) blocks, \(importData.sessions.count) sessions, \(importData.exercises.count) exercises", subsystem: .persistence, category: "DataManagement")
    }
    
    // MARK: - Data Retention & Cleanup
    
    public struct RetentionPolicy {
        public var keepSessionsDays: Int // Keep sessions from last N days
        public var maxArchivedBlocks: Int // Maximum archived blocks to keep
        
        public static let `default` = RetentionPolicy(
            keepSessionsDays: 365,
            maxArchivedBlocks: 50
        )
        
        public init(keepSessionsDays: Int, maxArchivedBlocks: Int) {
            self.keepSessionsDays = keepSessionsDays
            self.maxArchivedBlocks = maxArchivedBlocks
        }
    }
    
    /// Apply retention policy to clean up old data
    public func applyRetentionPolicy(_ policy: RetentionPolicy) {
        // Clean up old sessions
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -policy.keepSessionsDays, to: Date()) ?? Date.distantPast
        
        let sessionsToKeep = sessionsRepository.sessions.filter { session in
            guard let date = session.date else { return true } // Keep sessions without dates
            return date > cutoffDate || session.status != .completed
        }
        
        let removedSessionsCount = sessionsRepository.sessions.count - sessionsToKeep.count
        if removedSessionsCount > 0 {
            sessionsRepository.replaceAll(with: sessionsToKeep)
            AppLogger.info("Cleaned up \(removedSessionsCount) old sessions", subsystem: .persistence, category: "DataManagement")
        }
        
        // Clean up excess archived blocks (keep most recent)
        let archivedBlocks = blocksRepository.archivedBlocks()
        if archivedBlocks.count > policy.maxArchivedBlocks {
            let blocksToRemove = archivedBlocks.dropFirst(policy.maxArchivedBlocks)
            blocksToRemove.forEach { block in
                blocksRepository.delete(block)
                // Also clean up associated sessions
                sessionsRepository.deleteSessions(forBlockId: block.id)
            }
            AppLogger.info("Cleaned up \(blocksToRemove.count) archived blocks", subsystem: .persistence, category: "DataManagement")
        }
    }
    
    /// Get data size statistics
    public func getDataSizeStatistics() -> DataSizeStatistics {
        let blocks = blocksRepository.allBlocks()
        let sessions = sessionsRepository.sessions
        let exercises = exerciseRepository.all()
        
        // Estimate size in bytes
        let encoder = JSONEncoder()
        let blocksSize = (try? encoder.encode(blocks))?.count ?? 0
        let sessionsSize = (try? encoder.encode(sessions))?.count ?? 0
        let exercisesSize = (try? encoder.encode(exercises))?.count ?? 0
        
        return DataSizeStatistics(
            blocksCount: blocks.count,
            archivedBlocksCount: blocks.filter { $0.isArchived }.count,
            sessionsCount: sessions.count,
            completedSessionsCount: sessions.filter { $0.status == .completed }.count,
            exercisesCount: exercises.count,
            estimatedTotalSizeBytes: blocksSize + sessionsSize + exercisesSize,
            blocksFileSize: blocksSize,
            sessionsFileSize: sessionsSize,
            exercisesFileSize: exercisesSize
        )
    }
    
    // MARK: - Helper Methods
    
    private func getExerciseName(definitionId: ExerciseDefinitionID?, customName: String?) -> String {
        if let customName = customName, !customName.isEmpty {
            return customName
        }
        if let definitionId = definitionId,
           let definition = exerciseRepository.all().first(where: { $0.id == definitionId }) {
            return definition.name
        }
        return "Unknown Exercise"
    }
}

// MARK: - Data Size Statistics

public struct DataSizeStatistics {
    public var blocksCount: Int
    public var archivedBlocksCount: Int
    public var sessionsCount: Int
    public var completedSessionsCount: Int
    public var exercisesCount: Int
    public var estimatedTotalSizeBytes: Int
    public var blocksFileSize: Int
    public var sessionsFileSize: Int
    public var exercisesFileSize: Int
    
    public var estimatedTotalSizeMB: Double {
        Double(estimatedTotalSizeBytes) / 1_048_576.0
    }
    
    public init(
        blocksCount: Int,
        archivedBlocksCount: Int,
        sessionsCount: Int,
        completedSessionsCount: Int,
        exercisesCount: Int,
        estimatedTotalSizeBytes: Int,
        blocksFileSize: Int,
        sessionsFileSize: Int,
        exercisesFileSize: Int
    ) {
        self.blocksCount = blocksCount
        self.archivedBlocksCount = archivedBlocksCount
        self.sessionsCount = sessionsCount
        self.completedSessionsCount = completedSessionsCount
        self.exercisesCount = exercisesCount
        self.estimatedTotalSizeBytes = estimatedTotalSizeBytes
        self.blocksFileSize = blocksFileSize
        self.sessionsFileSize = sessionsFileSize
        self.exercisesFileSize = exercisesFileSize
    }
}

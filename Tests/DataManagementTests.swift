//
//  DataManagementTests.swift
//  WorkoutTrackerApp Tests
//
//  Tests for data export/import and retention functionality
//

import XCTest
@testable import WorkoutTrackerApp

final class DataManagementTests: XCTestCase {
    
    var blocksRepository: BlocksRepository!
    var sessionsRepository: SessionsRepository!
    var exerciseRepository: ExerciseLibraryRepository!
    var dataService: DataManagementService!
    
    override func setUp() {
        super.setUp()
        
        // Create fresh repositories for each test
        blocksRepository = BlocksRepository(blocks: [])
        sessionsRepository = SessionsRepository(sessions: [])
        exerciseRepository = ExerciseLibraryRepository(exercises: [])
        
        dataService = DataManagementService(
            blocksRepository: blocksRepository,
            sessionsRepository: sessionsRepository,
            exerciseRepository: exerciseRepository
        )
    }
    
    override func tearDown() {
        blocksRepository = nil
        sessionsRepository = nil
        exerciseRepository = nil
        dataService = nil
        super.tearDown()
    }
    
    // MARK: - Export Tests
    
    func testExportEmptyData() throws {
        // Given empty repositories
        
        // When exporting
        let data = try dataService.exportAllDataAsJSON()
        
        // Then data should be valid JSON
        XCTAssertGreaterThan(data.count, 0)
        
        // Verify it can be decoded
        let decoded = try JSONDecoder().decode(AppDataExport.self, from: data)
        XCTAssertEqual(decoded.blocks.count, 0)
        XCTAssertEqual(decoded.sessions.count, 0)
        XCTAssertEqual(decoded.exercises.count, 0)
    }
    
    func testExportBlockData() throws {
        // Given a block with exercises
        let exercise = ExerciseTemplate(
            exerciseDefinitionId: nil,
            customName: "Test Exercise",
            type: .strength,
            strengthSets: [
                StrengthSetTemplate(index: 0, reps: 5, weight: 100)
            ],
            progressionRule: ProgressionRule(type: .weight, deltaWeight: 2.5)
        )
        
        let day = DayTemplate(
            name: "Day 1",
            exercises: [exercise]
        )
        
        let block = Block(
            name: "Test Block",
            numberOfWeeks: 4,
            days: [day]
        )
        
        blocksRepository.add(block)
        
        // When exporting
        let data = try dataService.exportAllDataAsJSON()
        
        // Then block should be in export
        let decoded = try JSONDecoder().decode(AppDataExport.self, from: data)
        XCTAssertEqual(decoded.blocks.count, 1)
        XCTAssertEqual(decoded.blocks[0].name, "Test Block")
        XCTAssertEqual(decoded.blocks[0].numberOfWeeks, 4)
        XCTAssertEqual(decoded.blocks[0].days.count, 1)
    }
    
    func testExportSessionData() throws {
        // Given a session
        let blockId = UUID()
        let session = WorkoutSession(
            blockId: blockId,
            weekIndex: 0,
            dayTemplateId: UUID(),
            date: Date(),
            status: .completed,
            exercises: []
        )
        
        sessionsRepository.add(session)
        
        // When exporting
        let data = try dataService.exportAllDataAsJSON()
        
        // Then session should be in export
        let decoded = try JSONDecoder().decode(AppDataExport.self, from: data)
        XCTAssertEqual(decoded.sessions.count, 1)
        XCTAssertEqual(decoded.sessions[0].blockId, blockId)
        XCTAssertEqual(decoded.sessions[0].status, .completed)
    }
    
    func testExportCSVWorkoutHistory() {
        // Given completed sessions
        let block = Block(
            name: "Test Block",
            numberOfWeeks: 2,
            days: [DayTemplate(name: "Day 1")]
        )
        blocksRepository.add(block)
        
        let exercise = SessionExercise(
            exerciseDefinitionId: nil,
            customName: "Squat",
            expectedSets: [],
            loggedSets: [
                SessionSet(
                    index: 0,
                    loggedReps: 5,
                    loggedWeight: 100,
                    isCompleted: true
                )
            ]
        )
        
        let session = WorkoutSession(
            blockId: block.id,
            weekIndex: 0,
            dayTemplateId: block.days[0].id,
            date: Date(),
            status: .completed,
            exercises: [exercise]
        )
        
        sessionsRepository.add(session)
        
        // When exporting CSV
        let csv = dataService.exportWorkoutHistoryAsCSV()
        
        // Then CSV should contain session data
        XCTAssertTrue(csv.contains("Test Block"))
        XCTAssertTrue(csv.contains("Squat"))
        XCTAssertTrue(csv.contains("Date,Block,Week,Day"))
    }
    
    func testExportCSVBlocksSummary() {
        // Given blocks
        let block1 = Block(
            name: "Strength Block",
            numberOfWeeks: 4,
            goal: .strength,
            days: [DayTemplate(name: "Day 1")]
        )
        
        let block2 = Block(
            name: "Hypertrophy Block",
            numberOfWeeks: 6,
            goal: .hypertrophy,
            days: [DayTemplate(name: "Day 1"), DayTemplate(name: "Day 2")],
            source: .ai,
            isArchived: true
        )
        
        blocksRepository.add(block1)
        blocksRepository.add(block2)
        
        // When exporting CSV
        let csv = dataService.exportBlocksSummaryAsCSV()
        
        // Then CSV should contain blocks
        XCTAssertTrue(csv.contains("Strength Block"))
        XCTAssertTrue(csv.contains("Hypertrophy Block"))
        XCTAssertTrue(csv.contains("Block Name,Weeks,Days"))
    }
    
    // MARK: - Import Tests
    
    func testImportReplaceStrategy() throws {
        // Given existing data
        let existingBlock = Block(name: "Existing", numberOfWeeks: 2, days: [])
        blocksRepository.add(existingBlock)
        
        // And import data
        let importBlock = Block(name: "Imported", numberOfWeeks: 3, days: [])
        let importData = AppDataExport(blocks: [importBlock], sessions: [], exercises: [])
        let data = try JSONEncoder().encode(importData)
        
        // When importing with replace strategy
        try dataService.importDataFromJSON(data, strategy: .replace)
        
        // Then only imported data should exist
        XCTAssertEqual(blocksRepository.allBlocks().count, 1)
        XCTAssertEqual(blocksRepository.allBlocks()[0].name, "Imported")
    }
    
    func testImportMergeStrategy() throws {
        // Given existing data
        let existingBlock = Block(name: "Existing", numberOfWeeks: 2, days: [])
        blocksRepository.add(existingBlock)
        
        // And import data with different ID
        let importBlock = Block(id: UUID(), name: "Imported", numberOfWeeks: 3, days: [])
        let importData = AppDataExport(blocks: [importBlock], sessions: [], exercises: [])
        let data = try JSONEncoder().encode(importData)
        
        // When importing with merge strategy
        try dataService.importDataFromJSON(data, strategy: .merge)
        
        // Then both blocks should exist
        XCTAssertEqual(blocksRepository.allBlocks().count, 2)
        let names = Set(blocksRepository.allBlocks().map { $0.name })
        XCTAssertTrue(names.contains("Existing"))
        XCTAssertTrue(names.contains("Imported"))
    }
    
    func testImportMergeSkipsDuplicates() throws {
        // Given existing block
        let blockId = UUID()
        let existingBlock = Block(id: blockId, name: "Original", numberOfWeeks: 2, days: [])
        blocksRepository.add(existingBlock)
        
        // And import data with same ID but different name
        let importBlock = Block(id: blockId, name: "Modified", numberOfWeeks: 3, days: [])
        let importData = AppDataExport(blocks: [importBlock], sessions: [], exercises: [])
        let data = try JSONEncoder().encode(importData)
        
        // When importing with merge strategy
        try dataService.importDataFromJSON(data, strategy: .merge)
        
        // Then duplicate should be skipped, original preserved
        XCTAssertEqual(blocksRepository.allBlocks().count, 1)
        XCTAssertEqual(blocksRepository.allBlocks()[0].name, "Original")
    }
    
    // MARK: - Retention Tests
    
    func testRetentionPolicyRemovesOldSessions() {
        // Given sessions with various dates
        let oldDate = Calendar.current.date(byAdding: .day, value: -400, to: Date())!
        let recentDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        
        let oldSession = WorkoutSession(
            blockId: UUID(),
            weekIndex: 0,
            dayTemplateId: UUID(),
            date: oldDate,
            status: .completed,
            exercises: []
        )
        
        let recentSession = WorkoutSession(
            blockId: UUID(),
            weekIndex: 0,
            dayTemplateId: UUID(),
            date: recentDate,
            status: .completed,
            exercises: []
        )
        
        sessionsRepository.add(oldSession)
        sessionsRepository.add(recentSession)
        
        // When applying retention policy (keep 365 days)
        let policy = DataManagementService.RetentionPolicy(
            keepSessionsDays: 365,
            maxArchivedBlocks: 50
        )
        dataService.applyRetentionPolicy(policy)
        
        // Then old session should be removed, recent kept
        XCTAssertEqual(sessionsRepository.sessions.count, 1)
        XCTAssertEqual(sessionsRepository.sessions[0].date, recentDate)
    }
    
    func testRetentionPolicyKeepsInProgressSessions() {
        // Given old in-progress session
        let oldDate = Calendar.current.date(byAdding: .day, value: -400, to: Date())!
        
        let inProgressSession = WorkoutSession(
            blockId: UUID(),
            weekIndex: 0,
            dayTemplateId: UUID(),
            date: oldDate,
            status: .inProgress,
            exercises: []
        )
        
        sessionsRepository.add(inProgressSession)
        
        // When applying retention policy
        let policy = DataManagementService.RetentionPolicy(
            keepSessionsDays: 365,
            maxArchivedBlocks: 50
        )
        dataService.applyRetentionPolicy(policy)
        
        // Then in-progress session should be kept
        XCTAssertEqual(sessionsRepository.sessions.count, 1)
    }
    
    func testRetentionPolicyRemovesOldNotStartedSessions() {
        // Given old not-started session
        let oldDate = Calendar.current.date(byAdding: .day, value: -400, to: Date())!
        
        let notStartedSession = WorkoutSession(
            blockId: UUID(),
            weekIndex: 0,
            dayTemplateId: UUID(),
            date: oldDate,
            status: .notStarted,
            exercises: []
        )
        
        sessionsRepository.add(notStartedSession)
        
        // When applying retention policy
        let policy = DataManagementService.RetentionPolicy(
            keepSessionsDays: 365,
            maxArchivedBlocks: 50
        )
        dataService.applyRetentionPolicy(policy)
        
        // Then old not-started session should be removed
        XCTAssertEqual(sessionsRepository.sessions.count, 0)
    }
    
    func testRetentionPolicyLimitsArchivedBlocks() {
        // Given more archived blocks than limit
        for i in 0..<60 {
            let block = Block(
                name: "Block \(i)",
                numberOfWeeks: 2,
                days: [],
                isArchived: true
            )
            blocksRepository.add(block)
        }
        
        // When applying retention policy (max 50 archived)
        let policy = DataManagementService.RetentionPolicy(
            keepSessionsDays: 365,
            maxArchivedBlocks: 50
        )
        dataService.applyRetentionPolicy(policy)
        
        // Then only 50 archived blocks should remain
        XCTAssertEqual(blocksRepository.archivedBlocks().count, 50)
    }
    
    func testRetentionPolicyDeletesBlockSessions() {
        // Given archived block with sessions
        let block = Block(
            name: "Old Block",
            numberOfWeeks: 2,
            days: [],
            isArchived: true
        )
        blocksRepository.add(block)
        
        let session = WorkoutSession(
            blockId: block.id,
            weekIndex: 0,
            dayTemplateId: UUID(),
            exercises: []
        )
        sessionsRepository.add(session)
        
        // Add 50 more blocks to exceed limit
        for i in 0..<50 {
            blocksRepository.add(Block(
                name: "Block \(i)",
                numberOfWeeks: 2,
                days: [],
                isArchived: true
            ))
        }
        
        // When applying retention policy (max 50 archived)
        let policy = DataManagementService.RetentionPolicy(
            keepSessionsDays: 365,
            maxArchivedBlocks: 50
        )
        dataService.applyRetentionPolicy(policy)
        
        // Then block's session should also be deleted
        XCTAssertEqual(sessionsRepository.sessions(forBlockId: block.id).count, 0)
    }
    
    // MARK: - Statistics Tests
    
    func testDataSizeStatistics() {
        // Given data
        let block = Block(name: "Test", numberOfWeeks: 2, days: [])
        blocksRepository.add(block)
        blocksRepository.archive(block)
        
        let session = WorkoutSession(
            blockId: block.id,
            weekIndex: 0,
            dayTemplateId: UUID(),
            status: .completed,
            exercises: []
        )
        sessionsRepository.add(session)
        
        let exercise = ExerciseDefinition(name: "Squat", type: .strength)
        exerciseRepository.add(exercise)
        
        // When getting statistics
        let stats = dataService.getDataSizeStatistics()
        
        // Then statistics should be accurate
        XCTAssertEqual(stats.blocksCount, 1)
        XCTAssertEqual(stats.archivedBlocksCount, 1)
        XCTAssertEqual(stats.sessionsCount, 1)
        XCTAssertEqual(stats.completedSessionsCount, 1)
        XCTAssertEqual(stats.exercisesCount, 1)
        XCTAssertGreaterThan(stats.estimatedTotalSizeBytes, 0)
    }
}

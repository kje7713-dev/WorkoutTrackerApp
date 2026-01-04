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
    
    func testCSVEscapingWorkoutHistory() {
        // Given session with special characters in names
        let block = Block(
            name: "Week 1, Day 3",  // Contains comma
            numberOfWeeks: 2,
            days: [DayTemplate(name: "Push Day \"Heavy\"")]  // Contains quotes
        )
        blocksRepository.add(block)
        
        let exercise = SessionExercise(
            exerciseDefinitionId: nil,
            customName: "Barbell \"Push\" Press, 3x5",  // Contains both comma and quotes
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
        
        // Then CSV should properly escape special characters
        XCTAssertTrue(csv.contains("\"Week 1, Day 3\""), "Block name with comma should be quoted")
        XCTAssertTrue(csv.contains("\"Push Day \"\"Heavy\"\"\""), "Day name with quotes should have escaped quotes")
        XCTAssertTrue(csv.contains("\"Barbell \"\"Push\"\" Press, 3x5\""), "Exercise name should escape both comma and quotes")
        
        // Verify CSV structure is valid (can be split by commas correctly)
        let lines = csv.split(separator: "\n")
        XCTAssertGreaterThan(lines.count, 1, "Should have header and at least one data row")
    }
    
    func testCSVEscapingBlocksSummary() {
        // Given blocks with special characters in names
        let block1 = Block(
            name: "Block A, Phase 1",  // Contains comma
            numberOfWeeks: 4,
            days: [DayTemplate(name: "Day 1")]
        )
        
        let block2 = Block(
            name: "Block \"The Beast\"",  // Contains quotes
            numberOfWeeks: 6,
            days: [DayTemplate(name: "Day 1")]
        )
        
        let block3 = Block(
            name: "Test\nMultiline",  // Contains newline
            numberOfWeeks: 2,
            days: [DayTemplate(name: "Day 1")]
        )
        
        blocksRepository.add(block1)
        blocksRepository.add(block2)
        blocksRepository.add(block3)
        
        // When exporting CSV
        let csv = dataService.exportBlocksSummaryAsCSV()
        
        // Then CSV should properly escape special characters
        XCTAssertTrue(csv.contains("\"Block A, Phase 1\""), "Block name with comma should be quoted")
        XCTAssertTrue(csv.contains("\"Block \"\"The Beast\"\"\""), "Block name with quotes should have escaped quotes")
        XCTAssertTrue(csv.contains("\"Test\nMultiline\""), "Block name with newline should be quoted")
        
        // Verify CSV structure
        let lines = csv.split(separator: "\n", omittingEmptySubsequences: false)
        // Should have header + 3 blocks, but block3 has embedded newline creating extra line
        XCTAssertGreaterThanOrEqual(lines.count, 4, "Should have header and data rows")
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

// MARK: - Comprehensive Field Coverage Tests

extension DataManagementTests {
    
    /// Test that all new fields (videoUrls, skill progression, segments) are properly exported and imported
    func testComprehensiveFieldExportImport() throws {
        // Given a block with ALL possible fields populated
        
        // Create technique with videoUrls
        let technique = Technique(
            name: "Armbar from Guard",
            variant: "Traditional",
            keyDetails: ["Control head", "Angle hips"],
            commonErrors: ["Not breaking posture"],
            counters: ["Stack"],
            followUps: ["Triangle", "Omoplata"],
            videoUrls: ["https://youtube.com/armbar-1", "https://youtube.com/armbar-2"]
        )
        
        // Create segment with all fields
        let segment = Segment(
            name: "Technique Drill",
            segmentType: .technique,
            domain: .grappling,
            durationMinutes: 15,
            objective: "Master armbar mechanics",
            constraints: ["No submissions"],
            coachingCues: ["Control first", "Hip angle matters"],
            positions: ["closed_guard", "mount"],
            techniques: [technique],
            roundPlan: RoundPlan(
                rounds: 5,
                roundDurationSeconds: 180,
                restSeconds: 60,
                intensityCue: "moderate",
                winConditions: ["Secure position 3 seconds"]
            ),
            notes: "Progressive resistance"
        )
        
        // Create exercise with videoUrls and advanced progression
        let exerciseWithVideo = ExerciseTemplate(
            customName: "Bench Press",
            type: .strength,
            category: .pressHorizontal,
            notes: "Competition style",
            strengthSets: [
                StrengthSetTemplate(
                    index: 0,
                    reps: 5,
                    weight: 225.0,
                    percentageOfMax: 0.85,
                    rpe: 8.5,
                    rir: 1.5,
                    tempo: "3-1-1-0",
                    restSeconds: 240,
                    notes: "Controlled eccentric"
                )
            ],
            progressionRule: ProgressionRule(
                type: .weight,
                deltaWeight: 5.0,
                deltaSets: nil,
                deloadWeekIndexes: [4, 8],
                customParams: ["notes": "Conservative progression"],
                deltaResistance: nil,
                deltaRounds: nil,
                deltaConstraints: nil
            ),
            videoUrls: ["https://youtube.com/bench-setup", "https://youtube.com/bench-technique"]
        )
        
        // Create exercise with skill-based progression
        let skillExercise = ExerciseTemplate(
            customName: "Guard Passing Drill",
            type: .other,
            category: .other,
            notes: "Progressive resistance",
            progressionRule: ProgressionRule(
                type: .skill,
                deltaWeight: nil,
                deltaSets: nil,
                deloadWeekIndexes: nil,
                customParams: nil,
                deltaResistance: 10,  // Increase resistance 10% per week
                deltaRounds: 1,       // Add 1 round every 2 weeks
                deltaConstraints: ["Week 1: No grips", "Week 2: One grip only"]
            )
        )
        
        // Create conditioning exercise with videoUrls
        let conditioningExercise = ExerciseTemplate(
            customName: "Rowing Intervals",
            type: .conditioning,
            category: .conditioning,
            conditioningType: .intervals,
            notes: "Maintain stroke rate 24-26",
            conditioningSets: [
                ConditioningSetTemplate(
                    index: 0,
                    durationSeconds: 120,
                    distanceMeters: 500.0,
                    calories: 25.0,
                    targetPace: "1:45/500m",
                    effortDescriptor: "hard",
                    restSeconds: 60,
                    notes: "Focus on consistent pacing"
                )
            ],
            progressionRule: ProgressionRule(type: .custom),
            videoUrls: ["https://youtube.com/rowing-technique"]
        )
        
        // Create day template with both exercises and segments
        let day = DayTemplate(
            name: "Hybrid Training Day",
            shortCode: "HTD",
            goal: .mixed,
            notes: "Combination strength and skill work",
            exercises: [exerciseWithVideo, skillExercise, conditioningExercise],
            segments: [segment]
        )
        
        // Create week-specific templates
        let week1Days = [day]
        let week2Days = [DayTemplate(
            name: "Hybrid Training Day - Week 2",
            shortCode: "HTD2",
            exercises: [exerciseWithVideo],
            segments: [segment]
        )]
        
        // Create block with all metadata fields
        let block = Block(
            name: "Comprehensive Test Block",
            description: "Block with all possible fields",
            numberOfWeeks: 2,
            goal: .mixed,
            days: week1Days,
            weekTemplates: [week1Days, week2Days],
            source: .ai,
            aiMetadata: AIMetadata(prompt: "Test prompt", createdAt: Date()),
            isArchived: false,
            isActive: true,
            tags: ["test", "comprehensive"],
            disciplines: [.bjj, .yoga],
            ruleset: .ibjjf,
            attire: .gi,
            classType: .advanced
        )
        
        // Create exercise definition with videoUrls
        let exerciseDef = ExerciseDefinition(
            name: "Squat",
            type: .strength,
            category: .squat,
            tags: ["compound", "lower"],
            videoUrls: ["https://youtube.com/squat-form"]
        )
        
        blocksRepository.add(block)
        exerciseRepository.add(exerciseDef)
        
        // When exporting
        let exportData = try dataService.exportAllDataAsJSON()
        
        // Then verify export contains data
        XCTAssertGreaterThan(exportData.count, 0)
        
        // Decode to verify structure
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(AppDataExport.self, from: exportData)
        
        XCTAssertEqual(decoded.blocks.count, 1)
        XCTAssertEqual(decoded.exercises.count, 1)
        
        let exportedBlock = decoded.blocks[0]
        
        // Verify block metadata fields
        XCTAssertEqual(exportedBlock.name, "Comprehensive Test Block")
        XCTAssertEqual(exportedBlock.numberOfWeeks, 2)
        XCTAssertEqual(exportedBlock.goal, .mixed)
        XCTAssertEqual(exportedBlock.tags, ["test", "comprehensive"])
        XCTAssertEqual(exportedBlock.disciplines, [.bjj, .yoga])
        XCTAssertEqual(exportedBlock.ruleset, .ibjjf)
        XCTAssertEqual(exportedBlock.attire, .gi)
        XCTAssertEqual(exportedBlock.classType, .advanced)
        
        // Verify weekTemplates
        XCTAssertNotNil(exportedBlock.weekTemplates)
        XCTAssertEqual(exportedBlock.weekTemplates?.count, 2)
        
        // Verify day has segments
        let exportedDay = exportedBlock.days[0]
        XCTAssertNotNil(exportedDay.segments)
        XCTAssertEqual(exportedDay.segments?.count, 1)
        
        // Verify segment fields
        let exportedSegment = exportedDay.segments![0]
        XCTAssertEqual(exportedSegment.name, "Technique Drill")
        XCTAssertEqual(exportedSegment.segmentType, .technique)
        XCTAssertEqual(exportedSegment.domain, .grappling)
        XCTAssertEqual(exportedSegment.techniques.count, 1)
        
        // Verify technique videoUrls
        let exportedTechnique = exportedSegment.techniques[0]
        XCTAssertEqual(exportedTechnique.videoUrls?.count, 2)
        XCTAssertEqual(exportedTechnique.videoUrls?[0], "https://youtube.com/armbar-1")
        XCTAssertEqual(exportedTechnique.videoUrls?[1], "https://youtube.com/armbar-2")
        
        // Verify exercise with videoUrls
        let exportedExercise = exportedDay.exercises[0]
        XCTAssertEqual(exportedExercise.customName, "Bench Press")
        XCTAssertEqual(exportedExercise.videoUrls?.count, 2)
        XCTAssertEqual(exportedExercise.videoUrls?[0], "https://youtube.com/bench-setup")
        
        // Verify progression with deloadWeekIndexes
        XCTAssertEqual(exportedExercise.progressionRule.type, .weight)
        XCTAssertEqual(exportedExercise.progressionRule.deltaWeight, 5.0)
        XCTAssertEqual(exportedExercise.progressionRule.deloadWeekIndexes, [4, 8])
        
        // Verify skill-based progression
        let exportedSkillExercise = exportedDay.exercises[1]
        XCTAssertEqual(exportedSkillExercise.customName, "Guard Passing Drill")
        XCTAssertEqual(exportedSkillExercise.progressionRule.type, .skill)
        XCTAssertEqual(exportedSkillExercise.progressionRule.deltaResistance, 10)
        XCTAssertEqual(exportedSkillExercise.progressionRule.deltaRounds, 1)
        XCTAssertEqual(exportedSkillExercise.progressionRule.deltaConstraints?.count, 2)
        
        // Verify conditioning exercise with videoUrls
        let exportedCondExercise = exportedDay.exercises[2]
        XCTAssertEqual(exportedCondExercise.customName, "Rowing Intervals")
        XCTAssertEqual(exportedCondExercise.videoUrls?.count, 1)
        XCTAssertEqual(exportedCondExercise.videoUrls?[0], "https://youtube.com/rowing-technique")
        
        // Verify exercise definition videoUrls
        let exportedExerciseDef = decoded.exercises[0]
        XCTAssertEqual(exportedExerciseDef.name, "Squat")
        XCTAssertEqual(exportedExerciseDef.videoUrls?.count, 1)
        XCTAssertEqual(exportedExerciseDef.videoUrls?[0], "https://youtube.com/squat-form")
        
        // Now test round-trip by importing back
        let freshBlocksRepo = BlocksRepository(blocks: [])
        let freshSessionsRepo = SessionsRepository(sessions: [])
        let freshExerciseRepo = ExerciseLibraryRepository(exercises: [])
        
        let importService = DataManagementService(
            blocksRepository: freshBlocksRepo,
            sessionsRepository: freshSessionsRepo,
            exerciseRepository: freshExerciseRepo
        )
        
        // When importing with replace strategy
        try importService.importDataFromJSON(exportData, strategy: .replace)
        
        // Then all data should be imported correctly
        XCTAssertEqual(freshBlocksRepo.allBlocks().count, 1)
        XCTAssertEqual(freshExerciseRepo.all().count, 1)
        
        let importedBlock = freshBlocksRepo.allBlocks()[0]
        
        // Verify all fields survived the round-trip
        XCTAssertEqual(importedBlock.name, "Comprehensive Test Block")
        XCTAssertEqual(importedBlock.tags, ["test", "comprehensive"])
        XCTAssertEqual(importedBlock.disciplines, [.bjj, .yoga])
        XCTAssertNotNil(importedBlock.weekTemplates)
        XCTAssertEqual(importedBlock.weekTemplates?.count, 2)
        
        let importedDay = importedBlock.days[0]
        XCTAssertNotNil(importedDay.segments)
        XCTAssertEqual(importedDay.segments?.count, 1)
        
        let importedSegment = importedDay.segments![0]
        XCTAssertEqual(importedSegment.techniques[0].videoUrls?.count, 2)
        
        let importedExercise = importedDay.exercises[0]
        XCTAssertEqual(importedExercise.videoUrls?.count, 2)
        XCTAssertEqual(importedExercise.progressionRule.deloadWeekIndexes, [4, 8])
        
        let importedSkillExercise = importedDay.exercises[1]
        XCTAssertEqual(importedSkillExercise.progressionRule.type, .skill)
        XCTAssertEqual(importedSkillExercise.progressionRule.deltaResistance, 10)
        XCTAssertEqual(importedSkillExercise.progressionRule.deltaRounds, 1)
        
        let importedExerciseDef = freshExerciseRepo.all()[0]
        XCTAssertEqual(importedExerciseDef.videoUrls?.count, 1)
    }
}

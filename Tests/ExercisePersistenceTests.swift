//
//  ExercisePersistenceTests.swift
//  Savage By Design
//
//  Tests for exercise persistence to future weeks (Issue: persist-added exercise to future weeks)
//

import Foundation

/// Test suite for exercise persistence functionality
/// Validates that exercises added with "persist to future weeks" appear in all future sessions
struct ExercisePersistenceTests {
    
    // MARK: - Helper: Create Test Block
    
    /// Creates a minimal test block with specified weeks and days
    static func createTestBlock(numberOfWeeks: Int, numberOfDays: Int) -> Block {
        let days = (0..<numberOfDays).map { dayIndex in
            DayTemplate(
                name: "Day \(dayIndex + 1)",
                shortCode: "D\(dayIndex + 1)",
                exercises: []
            )
        }
        
        return Block(
            name: "Test Block",
            numberOfWeeks: numberOfWeeks,
            days: days
        )
    }
    
    // MARK: - Helper: Create Test Repositories
    
    /// Creates test repositories with a block and its sessions
    static func createTestRepositories(
        block: Block
    ) -> (blocks: BlocksRepository, sessions: SessionsRepository) {
        let blocksRepo = BlocksRepository(blocks: [block])
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        let sessionsRepo = SessionsRepository(sessions: sessions)
        
        return (blocksRepo, sessionsRepo)
    }
    
    // MARK: - Helper: Simulate Adding Exercise to Block Template
    
    /// Simulates the addExerciseToBlockTemplate logic
    static func simulateAddExerciseToBlockTemplate(
        block: Block,
        dayIndex: Int,
        weekIndex: Int,
        exerciseName: String,
        exerciseType: ExerciseType,
        blocksRepo: BlocksRepository,
        sessionsRepo: SessionsRepository
    ) -> Bool {
        var updatedBlock = block
        
        // Validate dayIndex
        guard dayIndex < updatedBlock.days.count else {
            print("❌ Test Error: Invalid dayIndex \(dayIndex)")
            return false
        }
        
        let initialExerciseCount = updatedBlock.days[dayIndex].exercises.count
        
        // Create new exercise template
        let newTemplate = ExerciseTemplate(
            customName: exerciseName,
            type: exerciseType,
            progressionRule: ProgressionRule(type: .custom)
        )
        
        // Add to day template
        updatedBlock.days[dayIndex].exercises.append(newTemplate)
        
        // Update block in repository
        blocksRepo.update(updatedBlock)
        
        // Re-read committed block
        guard let committedBlock = blocksRepo.getBlock(id: updatedBlock.id) else {
            print("❌ Test Error: Failed to read back committed block")
            return false
        }
        
        let finalExerciseCount = committedBlock.days[dayIndex].exercises.count
        if finalExerciseCount != initialExerciseCount + 1 {
            print("❌ Test Error: Block exercise count mismatch (expected \(initialExerciseCount + 1), got \(finalExerciseCount))")
            return false
        }
        
        // Regenerate sessions for future weeks
        regenerateSessionsForFutureWeeks(
            newTemplate: newTemplate,
            fromBlock: committedBlock,
            currentWeekIndex: weekIndex,
            dayIndex: dayIndex,
            sessionsRepo: sessionsRepo
        )
        
        return true
    }
    
    // MARK: - Helper: Regenerate Sessions for Future Weeks
    
    /// Simulates the regenerateSessionsForFutureWeeks logic
    private static func regenerateSessionsForFutureWeeks(
        newTemplate: ExerciseTemplate,
        fromBlock: Block,
        currentWeekIndex: Int,
        dayIndex: Int,
        sessionsRepo: SessionsRepository
    ) {
        let factory = SessionFactory()
        
        guard dayIndex < fromBlock.days.count else {
            print("❌ Test Error: Invalid dayIndex in regeneration")
            return
        }
        
        var allSessions = sessionsRepo.sessions(forBlockId: fromBlock.id)
        let currentWeekNumber = currentWeekIndex + 1 // Convert to 1-based
        let dayTemplateId = fromBlock.days[dayIndex].id
        
        for futureWeekNumber in (currentWeekNumber + 1)...fromBlock.numberOfWeeks {
            if let sessionIndex = allSessions.firstIndex(where: {
                $0.blockId == fromBlock.id &&
                $0.weekIndex == futureWeekNumber &&
                $0.dayTemplateId == dayTemplateId
            }) {
                // Check if exercise already exists
                let exerciseAlreadyExists = allSessions[sessionIndex].exercises.contains { exercise in
                    exercise.customName == newTemplate.customName &&
                    exercise.exerciseTemplateId == newTemplate.id
                }
                
                if exerciseAlreadyExists {
                    continue
                }
                
                // Create SessionExercise from template
                let expectedSets = factory.makeSessionSetsFromTemplate(newTemplate, weekIndex: futureWeekNumber)
                let loggedSets = expectedSets.map { SessionSet(
                    id: UUID(),
                    index: $0.index,
                    expectedReps: $0.expectedReps,
                    expectedWeight: $0.expectedWeight,
                    expectedTime: $0.expectedTime,
                    expectedDistance: $0.expectedDistance,
                    expectedCalories: $0.expectedCalories,
                    expectedRounds: $0.expectedRounds,
                    loggedReps: $0.loggedReps,
                    loggedWeight: $0.loggedWeight,
                    loggedTime: $0.loggedTime,
                    loggedDistance: $0.loggedDistance,
                    loggedCalories: $0.loggedCalories,
                    loggedRounds: $0.loggedRounds,
                    rpe: $0.rpe,
                    rir: $0.rir,
                    tempo: $0.tempo,
                    restSeconds: $0.restSeconds,
                    notes: $0.notes,
                    isCompleted: $0.isCompleted
                ) }
                
                let newSessionExercise = SessionExercise(
                    id: UUID(),
                    exerciseTemplateId: newTemplate.id,
                    exerciseDefinitionId: newTemplate.exerciseDefinitionId,
                    customName: newTemplate.customName,
                    expectedSets: expectedSets,
                    loggedSets: loggedSets
                )
                
                allSessions[sessionIndex].exercises.append(newSessionExercise)
            }
        }
        
        sessionsRepo.replaceSessions(forBlockId: fromBlock.id, with: allSessions)
    }
    
    // MARK: - Test Cases
    
    /// Test that adding an exercise in week 1 persists to all future weeks
    static func testAddExerciseInWeek1PersistsToFutureWeeks() -> Bool {
        print("🧪 Testing: Exercise added in Week 1 appears in all future weeks")
        
        // Setup: Create block with 4 weeks and 2 days
        let block = createTestBlock(numberOfWeeks: 4, numberOfDays: 2)
        let (blocksRepo, sessionsRepo) = createTestRepositories(block: block)
        
        let dayIndex = 0
        let weekIndex = 0 // Week 1 (0-based)
        let exerciseName = "Test Squat"
        let exerciseType = ExerciseType.strength
        
        // Act: Add exercise with persistence
        let success = simulateAddExerciseToBlockTemplate(
            block: block,
            dayIndex: dayIndex,
            weekIndex: weekIndex,
            exerciseName: exerciseName,
            exerciseType: exerciseType,
            blocksRepo: blocksRepo,
            sessionsRepo: sessionsRepo
        )
        
        guard success else {
            print("  ❌ FAIL: Failed to add exercise to block template")
            return false
        }
        
        // Assert: Check that exercise exists in future weeks (2, 3, 4)
        let dayTemplateId = block.days[dayIndex].id
        var allChecksPass = true
        
        for futureWeek in 2...4 {
            let sessions = sessionsRepo.sessions(forBlockId: block.id, weekIndex: futureWeek)
            let session = sessions.first { $0.dayTemplateId == dayTemplateId }
            
            guard let session = session else {
                print("  ❌ FAIL: Week \(futureWeek) - Session not found")
                allChecksPass = false
                continue
            }
            
            let hasExercise = session.exercises.contains { $0.customName == exerciseName }
            
            if hasExercise {
                print("  ✅ Week \(futureWeek): Exercise found")
            } else {
                print("  ❌ FAIL: Week \(futureWeek) - Exercise NOT found")
                allChecksPass = false
            }
        }
        
        if allChecksPass {
            print("  ✅ PASS: Exercise persisted to all future weeks")
        }
        
        return allChecksPass
    }
    
    /// Test that adding an exercise in middle week only persists to remaining weeks
    static func testAddExerciseInMiddleWeekPersistsToRemainingWeeks() -> Bool {
        print("🧪 Testing: Exercise added in Week 2 appears only in weeks 3-4 (not week 1)")
        
        // Setup: Create block with 4 weeks and 2 days
        let block = createTestBlock(numberOfWeeks: 4, numberOfDays: 2)
        let (blocksRepo, sessionsRepo) = createTestRepositories(block: block)
        
        let dayIndex = 0
        let weekIndex = 1 // Week 2 (0-based)
        let exerciseName = "Test Deadlift"
        let exerciseType = ExerciseType.strength
        
        // Act: Add exercise with persistence from week 2
        let success = simulateAddExerciseToBlockTemplate(
            block: block,
            dayIndex: dayIndex,
            weekIndex: weekIndex,
            exerciseName: exerciseName,
            exerciseType: exerciseType,
            blocksRepo: blocksRepo,
            sessionsRepo: sessionsRepo
        )
        
        guard success else {
            print("  ❌ FAIL: Failed to add exercise to block template")
            return false
        }
        
        // Assert: Check exercise does NOT exist in week 1
        let dayTemplateId = block.days[dayIndex].id
        let week1Sessions = sessionsRepo.sessions(forBlockId: block.id, weekIndex: 1)
        let week1Session = week1Sessions.first { $0.dayTemplateId == dayTemplateId }
        
        var allChecksPass = true
        
        if let week1Session = week1Session {
            let hasExerciseInWeek1 = week1Session.exercises.contains { $0.customName == exerciseName }
            if hasExerciseInWeek1 {
                print("  ❌ FAIL: Week 1 - Exercise should NOT exist but was found")
                allChecksPass = false
            } else {
                print("  ✅ Week 1: Exercise correctly NOT present")
            }
        }
        
        // Assert: Check exercise exists in weeks 3, 4
        for futureWeek in 3...4 {
            let sessions = sessionsRepo.sessions(forBlockId: block.id, weekIndex: futureWeek)
            let session = sessions.first { $0.dayTemplateId == dayTemplateId }
            
            guard let session = session else {
                print("  ❌ FAIL: Week \(futureWeek) - Session not found")
                allChecksPass = false
                continue
            }
            
            let hasExercise = session.exercises.contains { $0.customName == exerciseName }
            
            if hasExercise {
                print("  ✅ Week \(futureWeek): Exercise found")
            } else {
                print("  ❌ FAIL: Week \(futureWeek) - Exercise NOT found")
                allChecksPass = false
            }
        }
        
        if allChecksPass {
            print("  ✅ PASS: Exercise persisted only to future weeks (not past weeks)")
        }
        
        return allChecksPass
    }
    
    /// Test that adding an exercise in last week does nothing (no future weeks)
    static func testAddExerciseInLastWeekDoesNothing() -> Bool {
        print("🧪 Testing: Exercise added in last week has no future weeks to update")
        
        // Setup: Create block with 3 weeks and 1 day
        let block = createTestBlock(numberOfWeeks: 3, numberOfDays: 1)
        let (blocksRepo, sessionsRepo) = createTestRepositories(block: block)
        
        let dayIndex = 0
        let weekIndex = 2 // Week 3 (last week, 0-based)
        let exerciseName = "Test Bench Press"
        let exerciseType = ExerciseType.strength
        
        // Get initial session counts
        let initialSessions = sessionsRepo.sessions(forBlockId: block.id)
        let initialExerciseCounts = initialSessions.map { $0.exercises.count }
        
        // Act: Add exercise in last week
        let success = simulateAddExerciseToBlockTemplate(
            block: block,
            dayIndex: dayIndex,
            weekIndex: weekIndex,
            exerciseName: exerciseName,
            exerciseType: exerciseType,
            blocksRepo: blocksRepo,
            sessionsRepo: sessionsRepo
        )
        
        guard success else {
            print("  ❌ FAIL: Failed to add exercise to block template")
            return false
        }
        
        // Assert: Exercise counts in weeks 1-2 should remain unchanged
        let finalSessions = sessionsRepo.sessions(forBlockId: block.id)
        let finalExerciseCounts = finalSessions.map { $0.exercises.count }
        
        var allChecksPass = true
        
        for (index, (initial, final)) in zip(initialExerciseCounts, finalExerciseCounts).enumerated() {
            if initial == final {
                print("  ✅ Session \(index): Exercise count unchanged (\(initial) exercises)")
            } else {
                print("  ❌ FAIL: Session \(index) - Exercise count changed (was \(initial), now \(final))")
                allChecksPass = false
            }
        }
        
        // Verify block template was updated
        guard let updatedBlock = blocksRepo.getBlock(id: block.id) else {
            print("  ❌ FAIL: Could not retrieve updated block")
            return false
        }
        
        let hasExerciseInTemplate = updatedBlock.days[dayIndex].exercises.contains { $0.customName == exerciseName }
        
        if hasExerciseInTemplate {
            print("  ✅ Block template correctly updated with new exercise")
        } else {
            print("  ❌ FAIL: Block template was not updated")
            allChecksPass = false
        }
        
        if allChecksPass {
            print("  ✅ PASS: Last week behavior correct (template updated, no future sessions changed)")
        }
        
        return allChecksPass
    }
    
    /// Test that duplicate exercises are not added
    static func testDuplicateExercisesNotAdded() -> Bool {
        print("🧪 Testing: Duplicate exercises are not added to future weeks")
        
        // Setup: Create block with 3 weeks and 1 day
        let block = createTestBlock(numberOfWeeks: 3, numberOfDays: 1)
        let (blocksRepo, sessionsRepo) = createTestRepositories(block: block)
        
        let dayIndex = 0
        let weekIndex = 0 // Week 1
        let exerciseName = "Test Pull-up"
        let exerciseType = ExerciseType.strength
        
        // Act: Add exercise twice
        let success1 = simulateAddExerciseToBlockTemplate(
            block: block,
            dayIndex: dayIndex,
            weekIndex: weekIndex,
            exerciseName: exerciseName,
            exerciseType: exerciseType,
            blocksRepo: blocksRepo,
            sessionsRepo: sessionsRepo
        )
        
        guard success1 else {
            print("  ❌ FAIL: First add failed")
            return false
        }
        
        // Get updated block for second add
        guard let updatedBlock = blocksRepo.getBlock(id: block.id) else {
            print("  ❌ FAIL: Could not retrieve block after first add")
            return false
        }
        
        let success2 = simulateAddExerciseToBlockTemplate(
            block: updatedBlock,
            dayIndex: dayIndex,
            weekIndex: weekIndex,
            exerciseName: exerciseName,
            exerciseType: exerciseType,
            blocksRepo: blocksRepo,
            sessionsRepo: sessionsRepo
        )
        
        guard success2 else {
            print("  ❌ FAIL: Second add failed")
            return false
        }
        
        // Assert: Check that weeks 2-3 have exactly 1 exercise with that name
        let dayTemplateId = block.days[dayIndex].id
        var allChecksPass = true
        
        for futureWeek in 2...3 {
            let sessions = sessionsRepo.sessions(forBlockId: block.id, weekIndex: futureWeek)
            let session = sessions.first { $0.dayTemplateId == dayTemplateId }
            
            guard let session = session else {
                print("  ❌ FAIL: Week \(futureWeek) - Session not found")
                allChecksPass = false
                continue
            }
            
            let exerciseCount = session.exercises.filter { $0.customName == exerciseName }.count
            
            if exerciseCount == 1 {
                print("  ✅ Week \(futureWeek): Exactly 1 exercise found (no duplicate)")
            } else {
                print("  ❌ FAIL: Week \(futureWeek) - Found \(exerciseCount) exercises (expected 1)")
                allChecksPass = false
            }
        }
        
        if allChecksPass {
            print("  ✅ PASS: Duplicate prevention works correctly")
        }
        
        return allChecksPass
    }
    
    // MARK: - Test Runner
    
    /// Runs all tests and reports results
    static func runAllTests() {
        print("\n" + String(repeating: "=", count: 70))
        print("🧪 Running Exercise Persistence Tests")
        print(String(repeating: "=", count: 70) + "\n")
        
        var passed = 0
        var failed = 0
        
        let tests: [(String, () -> Bool)] = [
            ("Add Exercise in Week 1 Persists to Future Weeks", testAddExerciseInWeek1PersistsToFutureWeeks),
            ("Add Exercise in Middle Week", testAddExerciseInMiddleWeekPersistsToRemainingWeeks),
            ("Add Exercise in Last Week", testAddExerciseInLastWeekDoesNothing),
            ("Duplicate Prevention", testDuplicateExercisesNotAdded)
        ]
        
        for (testName, test) in tests {
            print("Running: \(testName)")
            if test() {
                passed += 1
            } else {
                failed += 1
            }
            print("")
        }
        
        print(String(repeating: "=", count: 70))
        print("📊 Test Results: \(passed) passed, \(failed) failed")
        print(String(repeating: "=", count: 70) + "\n")
        
        if failed == 0 {
            print("✅ All tests passed!")
        } else {
            print("❌ Some tests failed")
        }
    }
}

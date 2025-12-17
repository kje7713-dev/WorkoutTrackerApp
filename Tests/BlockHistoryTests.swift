import XCTest
@testable import WorkoutTrackerApp

/// Tests for block archive/unarchive functionality
final class BlockHistoryTests: XCTestCase {
    
    var repository: BlocksRepository!
    var testBlock: Block!
    
    override func setUp() {
        super.setUp()
        
        // Create a test block
        testBlock = Block(
            name: "Test Block",
            description: "Test description",
            numberOfWeeks: 4,
            goal: .strength,
            days: [],
            source: .user,
            isArchived: false
        )
        
        // Initialize repository with test block
        repository = BlocksRepository(blocks: [testBlock])
    }
    
    override func tearDown() {
        repository = nil
        testBlock = nil
        super.tearDown()
    }
    
    // MARK: - Archive Tests
    
    func testArchiveBlock() {
        // Given: A block in the repository
        XCTAssertEqual(repository.blocks.count, 1)
        XCTAssertFalse(testBlock.isArchived)
        
        // When: Archiving the block
        repository.archive(testBlock)
        
        // Then: Block should be archived
        let archivedBlock = repository.blocks.first
        XCTAssertNotNil(archivedBlock)
        XCTAssertTrue(archivedBlock?.isArchived ?? false)
    }
    
    func testUnarchiveBlock() {
        // Given: An archived block
        let archivedBlock = Block(
            name: "Test Block",
            description: "Test description",
            numberOfWeeks: 4,
            goal: .strength,
            days: [],
            source: .user,
            isArchived: true
        )
        repository = BlocksRepository(blocks: [archivedBlock])
        
        XCTAssertTrue(archivedBlock.isArchived)
        
        // When: Unarchiving the block
        repository.unarchive(archivedBlock)
        
        // Then: Block should not be archived
        let unarchivedBlock = repository.blocks.first
        XCTAssertNotNil(unarchivedBlock)
        XCTAssertFalse(unarchivedBlock?.isArchived ?? true)
    }
    
    // MARK: - Filter Tests
    
    func testActiveBlocksFilter() {
        // Given: Mix of archived and active blocks
        let activeBlock1 = Block(
            name: "Active 1",
            description: nil,
            numberOfWeeks: 4,
            goal: nil,
            days: [],
            source: .user,
            isArchived: false
        )
        let activeBlock2 = Block(
            name: "Active 2",
            description: nil,
            numberOfWeeks: 4,
            goal: nil,
            days: [],
            source: .user,
            isArchived: false
        )
        let archivedBlock = Block(
            name: "Archived",
            description: nil,
            numberOfWeeks: 4,
            goal: nil,
            days: [],
            source: .user,
            isArchived: true
        )
        
        repository = BlocksRepository(blocks: [activeBlock1, archivedBlock, activeBlock2])
        
        // When: Getting active blocks
        let activeBlocks = repository.activeBlocks()
        
        // Then: Should only return non-archived blocks
        XCTAssertEqual(activeBlocks.count, 2)
        XCTAssertTrue(activeBlocks.allSatisfy { !$0.isArchived })
        XCTAssertTrue(activeBlocks.contains(where: { $0.name == "Active 1" }))
        XCTAssertTrue(activeBlocks.contains(where: { $0.name == "Active 2" }))
        XCTAssertFalse(activeBlocks.contains(where: { $0.name == "Archived" }))
    }
    
    func testArchivedBlocksFilter() {
        // Given: Mix of archived and active blocks
        let activeBlock = Block(
            name: "Active",
            description: nil,
            numberOfWeeks: 4,
            goal: nil,
            days: [],
            source: .user,
            isArchived: false
        )
        let archivedBlock1 = Block(
            name: "Archived 1",
            description: nil,
            numberOfWeeks: 4,
            goal: nil,
            days: [],
            source: .user,
            isArchived: true
        )
        let archivedBlock2 = Block(
            name: "Archived 2",
            description: nil,
            numberOfWeeks: 4,
            goal: nil,
            days: [],
            source: .user,
            isArchived: true
        )
        
        repository = BlocksRepository(blocks: [archivedBlock1, activeBlock, archivedBlock2])
        
        // When: Getting archived blocks
        let archivedBlocks = repository.archivedBlocks()
        
        // Then: Should only return archived blocks
        XCTAssertEqual(archivedBlocks.count, 2)
        XCTAssertTrue(archivedBlocks.allSatisfy { $0.isArchived })
        XCTAssertTrue(archivedBlocks.contains(where: { $0.name == "Archived 1" }))
        XCTAssertTrue(archivedBlocks.contains(where: { $0.name == "Archived 2" }))
        XCTAssertFalse(archivedBlocks.contains(where: { $0.name == "Active" }))
    }
    
    func testEmptyActiveBlocks() {
        // Given: Only archived blocks
        let archivedBlock = Block(
            name: "Archived",
            description: nil,
            numberOfWeeks: 4,
            goal: nil,
            days: [],
            source: .user,
            isArchived: true
        )
        
        repository = BlocksRepository(blocks: [archivedBlock])
        
        // When: Getting active blocks
        let activeBlocks = repository.activeBlocks()
        
        // Then: Should return empty array
        XCTAssertEqual(activeBlocks.count, 0)
    }
    
    func testEmptyArchivedBlocks() {
        // Given: Only active blocks
        let activeBlock = Block(
            name: "Active",
            description: nil,
            numberOfWeeks: 4,
            goal: nil,
            days: [],
            source: .user,
            isArchived: false
        )
        
        repository = BlocksRepository(blocks: [activeBlock])
        
        // When: Getting archived blocks
        let archivedBlocks = repository.archivedBlocks()
        
        // Then: Should return empty array
        XCTAssertEqual(archivedBlocks.count, 0)
    }
    
    // MARK: - Integration Tests
    
    func testArchiveUnarchiveCycle() {
        // Given: An active block
        XCTAssertFalse(testBlock.isArchived)
        XCTAssertEqual(repository.activeBlocks().count, 1)
        XCTAssertEqual(repository.archivedBlocks().count, 0)
        
        // When: Archiving
        repository.archive(testBlock)
        
        // Then: Should be in archived list
        XCTAssertEqual(repository.activeBlocks().count, 0)
        XCTAssertEqual(repository.archivedBlocks().count, 1)
        
        // When: Unarchiving
        let archivedBlock = repository.archivedBlocks().first!
        repository.unarchive(archivedBlock)
        
        // Then: Should be back in active list
        XCTAssertEqual(repository.activeBlocks().count, 1)
        XCTAssertEqual(repository.archivedBlocks().count, 0)
    }
}

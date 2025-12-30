//
//  BJJImportTests.swift
//  Savage By Design Tests
//
//  Tests for importing BJJ segment-based JSON
//

import XCTest
@testable import WorkoutTrackerApp

final class BJJImportTests: XCTestCase {
    
    func testBJJSegmentJSONImport() throws {
        // Load the BJJ example JSON
        let testBundle = Bundle(for: type(of: self))
        guard let url = testBundle.url(forResource: "bjj_class_segments_example", withExtension: "json") else {
            // If running in a different test environment, try relative path
            let currentDir = FileManager.default.currentDirectoryPath
            let jsonPath = "\(currentDir)/Tests/bjj_class_segments_example.json"
            
            guard FileManager.default.fileExists(atPath: jsonPath),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
                XCTFail("Could not load bjj_class_segments_example.json")
                return
            }
            
            // Parse the JSON
            try verifyBJJJSON(data: data)
            return
        }
        
        let data = try Data(contentsOf: url)
        try verifyBJJJSON(data: data)
    }
    
    private func verifyBJJJSON(data: Data) throws {
        // Decode as AuthoringBlock
        let decoder = JSONDecoder()
        let authoringBlock = try decoder.decode(AuthoringBlock.self, from: data)
        
        // Verify basic block properties
        XCTAssertEqual(authoringBlock.Title, "BJJ_Class_Segments_Example")
        XCTAssertEqual(authoringBlock.NumberOfWeeks, 1)
        XCTAssertEqual(authoringBlock.DurationMinutes, 60)
        
        // Verify days exist
        XCTAssertNotNil(authoringBlock.Days)
        guard let days = authoringBlock.Days else {
            XCTFail("Days should not be nil")
            return
        }
        
        XCTAssertEqual(days.count, 1)
        let day = days[0]
        
        // Verify day properties
        XCTAssertEqual(day.name, "Day 1: Inside Tie → Single (BJJ Class)")
        XCTAssertEqual(day.shortCode, "BJJ1")
        
        // Verify segments exist
        XCTAssertNotNil(day.segments)
        guard let segments = day.segments else {
            XCTFail("Segments should not be nil")
            return
        }
        
        // Verify we have 7 segments (warmup, 2 technique, drill, 2 positional spar, cooldown)
        XCTAssertEqual(segments.count, 7)
        
        // Verify first segment (warmup)
        let warmup = segments[0]
        XCTAssertEqual(warmup.name, "General Warm-up + Grappling Movement")
        XCTAssertEqual(warmup.segmentType, "warmup")
        XCTAssertEqual(warmup.domain, "grappling")
        XCTAssertEqual(warmup.durationMinutes, 8)
        XCTAssertNotNil(warmup.objective)
        XCTAssertNotNil(warmup.coachingCues)
        XCTAssertEqual(warmup.coachingCues?.count, 3)
        
        // Verify drill plan in warmup
        XCTAssertNotNil(warmup.drillPlan)
        XCTAssertNotNil(warmup.drillPlan?.items)
        XCTAssertEqual(warmup.drillPlan?.items?.count, 4)
        
        // Verify first drill item
        let firstDrill = warmup.drillPlan?.items?[0]
        XCTAssertEqual(firstDrill?.name, "Stance-in-motion")
        XCTAssertEqual(firstDrill?.workSeconds, 60)
        XCTAssertEqual(firstDrill?.restSeconds, 15)
        
        // Verify safety in warmup
        XCTAssertNotNil(warmup.safety)
        XCTAssertNotNil(warmup.safety?.contraindications)
        XCTAssertEqual(warmup.safety?.contraindications?.count, 2)
        
        // Verify technique segment
        let technique1 = segments[1]
        XCTAssertEqual(technique1.segmentType, "technique")
        XCTAssertEqual(technique1.durationMinutes, 12)
        XCTAssertNotNil(technique1.positions)
        XCTAssertEqual(technique1.positions?.count, 2)
        
        // Verify techniques array
        XCTAssertNotNil(technique1.techniques)
        XCTAssertEqual(technique1.techniques?.count, 1)
        let tech = technique1.techniques?[0]
        XCTAssertEqual(tech?.name, "Inside tie to single entry")
        XCTAssertEqual(tech?.variant, "inside tie pull + penetration step")
        XCTAssertNotNil(tech?.keyDetails)
        XCTAssertEqual(tech?.keyDetails?.count, 3)
        XCTAssertNotNil(tech?.commonErrors)
        XCTAssertEqual(tech?.commonErrors?.count, 3)
        
        // Verify partner plan
        XCTAssertNotNil(technique1.partnerPlan)
        XCTAssertEqual(technique1.partnerPlan?.rounds, 3)
        XCTAssertEqual(technique1.partnerPlan?.roundDurationSeconds, 180)
        XCTAssertEqual(technique1.partnerPlan?.resistance, 25)
        
        // Verify roles
        XCTAssertNotNil(technique1.partnerPlan?.roles)
        XCTAssertNotNil(technique1.partnerPlan?.roles?.attackerGoal)
        XCTAssertNotNil(technique1.partnerPlan?.roles?.defenderGoal)
        
        // Verify quality targets
        XCTAssertNotNil(technique1.partnerPlan?.qualityTargets)
        XCTAssertEqual(technique1.partnerPlan?.qualityTargets?.cleanRepsTarget, 10)
        XCTAssertEqual(technique1.partnerPlan?.qualityTargets?.successRateTarget, 0.8)
        
        // Verify positional sparring segment
        let positionalSpar = segments[4]
        XCTAssertEqual(positionalSpar.segmentType, "positionalSpar")
        XCTAssertEqual(positionalSpar.durationMinutes, 12)
        XCTAssertNotNil(positionalSpar.startPosition)
        XCTAssertEqual(positionalSpar.startPosition, "standing_tieup")
        
        // Verify starting state
        XCTAssertNotNil(positionalSpar.startingState)
        XCTAssertNotNil(positionalSpar.startingState?.grips)
        XCTAssertNotNil(positionalSpar.startingState?.roles)
        
        // Verify round plan
        XCTAssertNotNil(positionalSpar.roundPlan)
        XCTAssertEqual(positionalSpar.roundPlan?.rounds, 6)
        XCTAssertEqual(positionalSpar.roundPlan?.roundDurationSeconds, 120)
        
        // Verify scoring
        XCTAssertNotNil(positionalSpar.scoring)
        XCTAssertNotNil(positionalSpar.scoring?.attackerScoresIf)
        XCTAssertEqual(positionalSpar.scoring?.attackerScoresIf?.count, 2)
        XCTAssertNotNil(positionalSpar.scoring?.defenderScoresIf)
        XCTAssertEqual(positionalSpar.scoring?.defenderScoresIf?.count, 2)
        
        // Verify constraints
        XCTAssertNotNil(positionalSpar.constraints)
        XCTAssertEqual(positionalSpar.constraints?.count, 2)
        
        // Verify cooldown segment
        let cooldown = segments[6]
        XCTAssertEqual(cooldown.segmentType, "cooldown")
        XCTAssertEqual(cooldown.domain, "mobility")
        XCTAssertNotNil(cooldown.breathwork)
        XCTAssertEqual(cooldown.breathwork?.style, "nasal breathing")
        XCTAssertEqual(cooldown.breathwork?.pattern, "4s inhale / 6s exhale")
        XCTAssertEqual(cooldown.breathwork?.durationSeconds, 120)
    }
    
    func testBJJJSONNormalization() throws {
        // Load and parse the JSON
        let currentDir = FileManager.default.currentDirectoryPath
        let jsonPath = "\(currentDir)/Tests/bjj_class_segments_example.json"
        
        guard FileManager.default.fileExists(atPath: jsonPath),
              let data = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
            // Skip test if JSON not available in this context
            throw XCTSkip("BJJ JSON file not available")
        }
        
        // Decode as AuthoringBlock
        let decoder = JSONDecoder()
        let authoringBlock = try decoder.decode(AuthoringBlock.self, from: data)
        
        // Normalize to UnifiedBlock
        let unifiedBlock = BlockNormalizer.normalize(authoringBlock: authoringBlock)
        
        // Verify normalized structure
        XCTAssertEqual(unifiedBlock.title, "BJJ_Class_Segments_Example")
        XCTAssertEqual(unifiedBlock.numberOfWeeks, 1)
        XCTAssertEqual(unifiedBlock.weeks.count, 1)
        
        let week = unifiedBlock.weeks[0]
        XCTAssertEqual(week.count, 1)
        
        let day = week[0]
        XCTAssertEqual(day.name, "Day 1: Inside Tie → Single (BJJ Class)")
        
        // Verify segments were normalized
        XCTAssertEqual(day.segments.count, 7)
        
        // Verify first segment normalization
        let warmup = day.segments[0]
        XCTAssertEqual(warmup.name, "General Warm-up + Grappling Movement")
        XCTAssertEqual(warmup.segmentType, "warmup")
        XCTAssertEqual(warmup.domain, "grappling")
        XCTAssertEqual(warmup.durationMinutes, 8)
        XCTAssertEqual(warmup.coachingCues.count, 3)
        XCTAssertEqual(warmup.drillItems.count, 4)
        
        // Verify technique segment normalization
        let technique = day.segments[1]
        XCTAssertEqual(technique.techniques.count, 1)
        XCTAssertEqual(technique.techniques[0].keyDetails.count, 3)
        XCTAssertEqual(technique.resistance, 25)
        XCTAssertNotNil(technique.attackerGoal)
        XCTAssertNotNil(technique.defenderGoal)
    }
    
    func testWhiteboardFormattingWithSegments() throws {
        // Create a simple day with segments
        let segment = UnifiedSegment(
            name: "Test Segment",
            segmentType: "technique",
            domain: "grappling",
            durationMinutes: 15,
            objective: "Test objective",
            coachingCues: ["Cue 1", "Cue 2"]
        )
        
        let day = UnifiedDay(
            name: "Test Day",
            segments: [segment]
        )
        
        // Format for whiteboard
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Verify sections were created
        XCTAssertGreaterThan(sections.count, 0)
        
        // Find technique section
        let techniqueSection = sections.first { $0.title == "Technique Development" }
        XCTAssertNotNil(techniqueSection)
        XCTAssertEqual(techniqueSection?.items.count, 1)
        
        let item = techniqueSection?.items[0]
        XCTAssertEqual(item?.primary, "Test Segment")
        XCTAssertNotNil(item?.secondary)
    }
}

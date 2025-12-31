//
//  SegmentEndToEndTests.swift
//  Savage By Design Tests
//
//  End-to-end tests for segment field flow from JSON to UI
//

import XCTest
@testable import WorkoutTrackerApp

final class SegmentEndToEndTests: XCTestCase {
    
    // MARK: - JSON to UnifiedBlock Test
    
    func testJSONToUnifiedBlockConversion() throws {
        // Load the comprehensive test JSON
        guard let url = Bundle(for: type(of: self)).url(forResource: "segment_all_fields_test", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to load segment_all_fields_test.json")
            return
        }
        
        // Parse the JSON to AuthoringBlock
        let decoder = JSONDecoder()
        let authoringBlock = try decoder.decode(AuthoringBlock.self, from: data)
        
        // Normalize to UnifiedBlock
        let unifiedBlock = BlockNormalizer.normalize(authoringBlock: authoringBlock)
        
        // Basic structure validation
        XCTAssertEqual(unifiedBlock.title, "SegmentAllFields_Demo")
        XCTAssertEqual(unifiedBlock.numberOfWeeks, 1)
        XCTAssertEqual(unifiedBlock.weeks.count, 1)
        
        let day = unifiedBlock.weeks[0][0]
        XCTAssertEqual(day.segments.count, 2)
        
        // Validate first segment has all critical fields
        let segment = day.segments[0]
        
        // Core fields
        XCTAssertEqual(segment.name, "Warm-up & Movement Prep")
        XCTAssertEqual(segment.segmentType, "warmup")
        XCTAssertEqual(segment.durationMinutes, 10)
        
        // Technique with all subfields
        XCTAssertEqual(segment.techniques.count, 1)
        let technique = segment.techniques[0]
        XCTAssertFalse(technique.keyDetails.isEmpty, "Should have keyDetails")
        XCTAssertFalse(technique.commonErrors.isEmpty, "Should have commonErrors")
        XCTAssertFalse(technique.counters.isEmpty, "Should have counters")
        XCTAssertFalse(technique.followUps.isEmpty, "Should have followUps")
        
        // Quality targets
        XCTAssertNotNil(segment.successRateTarget)
        XCTAssertNotNil(segment.cleanRepsTarget)
        XCTAssertNotNil(segment.decisionSpeedSeconds)
        XCTAssertNotNil(segment.controlTimeSeconds)
        
        // Round plan
        XCTAssertNotNil(segment.rounds)
        XCTAssertNotNil(segment.intensityCue)
        XCTAssertNotNil(segment.resetRule)
        XCTAssertFalse(segment.winConditions.isEmpty)
        
        // Partner plan
        XCTAssertNotNil(segment.switchEverySeconds)
        
        // Flow sequence
        XCTAssertFalse(segment.flowSequence.isEmpty, "Should have flow sequence")
        
        // Breathwork
        XCTAssertNotNil(segment.breathworkStyle)
        XCTAssertNotNil(segment.breathworkPattern)
        XCTAssertNotNil(segment.breathworkDurationSeconds)
        XCTAssertNotNil(segment.breathCount)
        
        // Media
        XCTAssertNotNil(segment.mediaVideoUrl)
        XCTAssertNotNil(segment.mediaImageUrl)
        XCTAssertNotNil(segment.mediaDiagramAssetId)
        
        // Safety
        XCTAssertFalse(segment.contraindications.isEmpty)
        XCTAssertFalse(segment.stopIf.isEmpty)
        XCTAssertNotNil(segment.intensityCeiling)
        
        // Starting state
        XCTAssertFalse(segment.startingStateGrips.isEmpty)
        XCTAssertFalse(segment.startingStateRoles.isEmpty)
        
        // Other fields
        XCTAssertNotNil(segment.endCondition)
        XCTAssertNotNil(segment.startPosition)
    }
    
    // MARK: - UnifiedBlock to Whiteboard Test
    
    func testUnifiedBlockToWhiteboardFormatting() throws {
        // Load and parse JSON
        guard let url = Bundle(for: type(of: self)).url(forResource: "segment_all_fields_test", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to load segment_all_fields_test.json")
            return
        }
        
        let decoder = JSONDecoder()
        let authoringBlock = try decoder.decode(AuthoringBlock.self, from: data)
        let unifiedBlock = BlockNormalizer.normalize(authoringBlock: authoringBlock)
        
        // Get first day
        let day = unifiedBlock.weeks[0][0]
        
        // Format the day for whiteboard display
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Should have at least one section for segments
        XCTAssertGreaterThan(sections.count, 0, "Should have sections")
        
        // Find the section containing segments
        let segmentSections = sections.filter { section in
            section.title.contains("Warm") || 
            section.title.contains("Technique") ||
            section.title.contains("Drill")
        }
        
        XCTAssertGreaterThan(segmentSections.count, 0, "Should have segment sections")
        
        // Get items from first segment section
        let firstSection = segmentSections[0]
        XCTAssertGreaterThan(firstSection.items.count, 0, "Section should have items")
        
        let item = firstSection.items[0]
        
        // Verify primary name is present
        XCTAssertFalse(item.primary.isEmpty, "Should have primary name")
        
        // Verify bullets contain formatted information
        XCTAssertGreaterThan(item.bullets.count, 0, "Should have bullets with details")
        
        // Check that key information is formatted into bullets
        let allBullets = item.bullets.joined(separator: "\n")
        
        // Verify various field types are present in bullets
        let expectedKeywords = [
            "Objective",      // Should have objective
            "technique",      // Should mention techniques (case insensitive check below)
            "Quality",        // Quality targets
            "Safety",         // Safety information
            "Breathwork",     // Breathwork details
            "Media",          // Media references
        ]
        
        var foundKeywords: [String] = []
        for keyword in expectedKeywords {
            if allBullets.lowercased().contains(keyword.lowercased()) {
                foundKeywords.append(keyword)
            }
        }
        
        // Should find most keywords (at least 4 out of 6)
        XCTAssertGreaterThanOrEqual(foundKeywords.count, 4, 
            "Should include most key field categories. Found: \(foundKeywords.joined(separator: ", "))")
    }
    
    // MARK: - App Model to UnifiedBlock Test
    
    func testAppModelToUnifiedBlockConversion() throws {
        // Create a Segment using app models
        let technique = Technique(
            name: "Test Technique",
            variant: "Standard",
            keyDetails: ["Detail 1", "Detail 2"],
            commonErrors: ["Error 1"],
            counters: ["Counter 1"],
            followUps: ["Follow-up 1"]
        )
        
        let flowStep = FlowStep(
            poseName: "Downward Dog",
            holdSeconds: 30,
            transitionCue: "Breathe"
        )
        
        let breathwork = BreathworkPlan(
            style: "Box breathing",
            pattern: "4-4-4-4",
            durationSeconds: 120
        )
        
        let media = Media(
            videoUrl: "https://example.com/video",
            imageUrl: "https://example.com/image",
            diagramAssetId: "diagram_123"
        )
        
        let safety = Safety(
            contraindications: ["No neck cranks"],
            stopIf: ["Sharp pain", "Dizziness"],
            intensityCeiling: "80%"
        )
        
        let qualityTargets = QualityTargets(
            successRateTarget: 0.8,
            cleanRepsTarget: 10,
            decisionSpeedSeconds: 4.0,
            controlTimeSeconds: 5
        )
        
        let roundPlan = RoundPlan(
            rounds: 3,
            roundDurationSeconds: 180,
            restSeconds: 60,
            intensityCue: "moderate",
            resetRule: "Reset on score",
            winConditions: ["Control 5s", "Escape 5s"]
        )
        
        let startingState = StartingState(
            grips: ["inside_tie", "collar_tie"],
            roles: ["attacker", "defender"]
        )
        
        let segment = Segment(
            name: "App Model Test Segment",
            segmentType: .technique,
            domain: .grappling,
            durationMinutes: 20,
            objective: "Test all fields from app models",
            constraints: ["No submissions"],
            coachingCues: ["Stay focused", "Breathe"],
            positions: ["standing", "ground"],
            techniques: [technique],
            roundPlan: roundPlan,
            qualityTargets: qualityTargets,
            startPosition: "standing",
            endCondition: "Complete all rounds",
            startingState: startingState,
            holdSeconds: 30,
            breathCount: 5,
            flowSequence: [flowStep],
            intensityScale: .moderate,
            props: ["mat", "timer"],
            breathwork: breathwork,
            media: media,
            safety: safety,
            notes: "Test notes"
        )
        
        let day = DayTemplate(
            name: "Test Day",
            segments: [segment]
        )
        
        let block = Block(
            name: "Test Block",
            numberOfWeeks: 1,
            days: [day]
        )
        
        // Normalize to UnifiedBlock
        let unifiedBlock = BlockNormalizer.normalize(block: block)
        
        // Verify conversion
        XCTAssertEqual(unifiedBlock.weeks[0][0].segments.count, 1)
        
        let unifiedSegment = unifiedBlock.weeks[0][0].segments[0]
        
        // Verify all fields were preserved
        XCTAssertEqual(unifiedSegment.name, "App Model Test Segment")
        XCTAssertFalse(unifiedSegment.techniques[0].counters.isEmpty)
        XCTAssertFalse(unifiedSegment.techniques[0].followUps.isEmpty)
        XCTAssertNotNil(unifiedSegment.decisionSpeedSeconds)
        XCTAssertNotNil(unifiedSegment.controlTimeSeconds)
        XCTAssertFalse(unifiedSegment.winConditions.isEmpty)
        XCTAssertNotNil(unifiedSegment.breathworkDurationSeconds)
        XCTAssertNotNil(unifiedSegment.breathCount)
        XCTAssertFalse(unifiedSegment.flowSequence.isEmpty)
        XCTAssertNotNil(unifiedSegment.mediaVideoUrl)
        XCTAssertFalse(unifiedSegment.stopIf.isEmpty)
        XCTAssertNotNil(unifiedSegment.intensityCeiling)
        XCTAssertFalse(unifiedSegment.startingStateGrips.isEmpty)
        XCTAssertNotNil(unifiedSegment.endCondition)
    }
}

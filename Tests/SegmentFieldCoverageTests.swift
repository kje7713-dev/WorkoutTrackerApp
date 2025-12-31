//
//  SegmentFieldCoverageTests.swift
//  Savage By Design Tests
//
//  Tests to validate that all segment fields flow through parsing to UI
//

import XCTest
@testable import WorkoutTrackerApp

final class SegmentFieldCoverageTests: XCTestCase {
    
    // MARK: - Comprehensive Field Coverage Test
    
    func testAllSegmentFieldsParsing() throws {
        // Load the comprehensive test JSON
        guard let url = Bundle(for: type(of: self)).url(forResource: "segment_all_fields_test", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            XCTFail("Failed to load segment_all_fields_test.json")
            return
        }
        
        // Parse the JSON
        let decoder = JSONDecoder()
        let authoringBlock = try decoder.decode(AuthoringBlock.self, from: data)
        
        // Normalize to unified block
        let unifiedBlock = BlockNormalizer.normalize(authoringBlock: authoringBlock)
        
        // Verify block structure
        XCTAssertEqual(unifiedBlock.title, "SegmentAllFields_Demo")
        XCTAssertEqual(unifiedBlock.numberOfWeeks, 1)
        XCTAssertEqual(unifiedBlock.weeks.count, 1)
        XCTAssertEqual(unifiedBlock.weeks[0].count, 1)
        
        // Get the day with segments
        let day = unifiedBlock.weeks[0][0]
        XCTAssertEqual(day.name, "Day 1: Segment Field Coverage")
        XCTAssertEqual(day.segments.count, 2)
        
        // Test first segment (Warm-up) - comprehensive field coverage
        let segment1 = day.segments[0]
        XCTAssertEqual(segment1.name, "Warm-up & Movement Prep")
        XCTAssertEqual(segment1.segmentType, "warmup")
        XCTAssertEqual(segment1.domain, "grappling")
        XCTAssertEqual(segment1.durationMinutes, 10)
        XCTAssertEqual(segment1.objective, "Increase temperature and prep positions for technique with structured movement drills.")
        XCTAssertEqual(segment1.startPosition, "standing")
        
        // Test positions
        XCTAssertEqual(segment1.positions.count, 3)
        XCTAssertTrue(segment1.positions.contains("standing"))
        XCTAssertTrue(segment1.positions.contains("inside_tie"))
        XCTAssertTrue(segment1.positions.contains("front_headlock"))
        
        // Test techniques with all fields
        XCTAssertEqual(segment1.techniques.count, 1)
        let technique = segment1.techniques[0]
        XCTAssertEqual(technique.name, "Snap-down to front headlock")
        XCTAssertEqual(technique.variant, "collar tie snap")
        XCTAssertEqual(technique.keyDetails.count, 3)
        XCTAssertTrue(technique.keyDetails.contains("Elbows tight"))
        XCTAssertEqual(technique.commonErrors.count, 3)
        XCTAssertTrue(technique.commonErrors.contains("Reaching with arms"))
        XCTAssertEqual(technique.counters.count, 1)
        XCTAssertTrue(technique.counters.contains("Posture up and circle out"))
        XCTAssertEqual(technique.followUps.count, 2)
        XCTAssertTrue(technique.followUps.contains("Go-behind spin"))
        
        // Test drill plan
        XCTAssertEqual(segment1.drillItems.count, 2)
        let drill1 = segment1.drillItems[0]
        XCTAssertEqual(drill1.name, "Stance-in-motion")
        XCTAssertEqual(drill1.workSeconds, 60)
        XCTAssertEqual(drill1.restSeconds, 15)
        XCTAssertEqual(drill1.notes, "Level change + circle + recover to stance.")
        
        // Test quality targets with all fields
        XCTAssertEqual(segment1.successRateTarget, 0.85)
        XCTAssertEqual(segment1.cleanRepsTarget, 10)
        XCTAssertEqual(segment1.decisionSpeedSeconds, 3.0)
        XCTAssertEqual(segment1.controlTimeSeconds, 2)
        
        // Test partner plan fields
        XCTAssertEqual(segment1.resistance, 25)
        XCTAssertEqual(segment1.switchEverySeconds, 90)
        XCTAssertEqual(segment1.attackerGoal, "Win inside tie and snap to front headlock cleanly")
        XCTAssertEqual(segment1.defenderGoal, "Provide posture/frame reactions without full resistance")
        
        // Test round plan fields
        XCTAssertEqual(segment1.rounds, 2)
        XCTAssertEqual(segment1.roundDurationSeconds, 60)
        XCTAssertEqual(segment1.restSeconds, 30)
        XCTAssertEqual(segment1.intensityCue, "moderate")
        XCTAssertEqual(segment1.resetRule, "Reset after clean front headlock control is achieved")
        XCTAssertEqual(segment1.winConditions.count, 2)
        XCTAssertTrue(segment1.winConditions.contains("Control 2 seconds"))
        
        // Test scoring
        XCTAssertEqual(segment1.scoring.count, 4)
        XCTAssertTrue(segment1.scoring.contains("Attacker: Front headlock control 2s"))
        XCTAssertTrue(segment1.scoring.contains("Defender: Clear tie and disengage to neutral 2s"))
        
        // Test flow sequence
        XCTAssertEqual(segment1.flowSequence.count, 1)
        let flow = segment1.flowSequence[0]
        XCTAssertEqual(flow.poseName, "Cat-Cow")
        XCTAssertEqual(flow.holdSeconds, 20)
        XCTAssertEqual(flow.transitionCue, "Breathe and move slowly through spine.")
        
        // Test breathwork
        XCTAssertEqual(segment1.breathworkStyle, "Box breathing")
        XCTAssertEqual(segment1.breathworkPattern, "4s inhale / 4s hold / 4s exhale / 4s hold")
        XCTAssertEqual(segment1.breathworkDurationSeconds, 120)
        XCTAssertEqual(segment1.breathCount, 4)
        
        // Test yoga/mobility fields
        XCTAssertEqual(segment1.holdSeconds, 20)
        XCTAssertEqual(segment1.intensityScale, "easy")
        XCTAssertEqual(segment1.props.count, 2)
        XCTAssertTrue(segment1.props.contains("wall"))
        XCTAssertTrue(segment1.props.contains("block"))
        
        // Test constraints and cues
        XCTAssertEqual(segment1.constraints.count, 3)
        XCTAssertTrue(segment1.constraints.contains("No submissions"))
        XCTAssertEqual(segment1.coachingCues.count, 3)
        XCTAssertTrue(segment1.coachingCues.contains("Hands inside"))
        
        // Test media fields
        XCTAssertEqual(segment1.mediaVideoUrl, "https://example.com/video/front-headlock-snapdown")
        XCTAssertEqual(segment1.mediaImageUrl, "https://example.com/image/front-headlock.png")
        XCTAssertEqual(segment1.mediaDiagramAssetId, "diagram_front_headlock_snapdown_v1")
        
        // Test safety fields
        XCTAssertEqual(segment1.contraindications.count, 2)
        XCTAssertTrue(segment1.contraindications.contains("Avoid neck cranks"))
        XCTAssertEqual(segment1.stopIf.count, 3)
        XCTAssertTrue(segment1.stopIf.contains("Sharp pain"))
        XCTAssertEqual(segment1.intensityCeiling, "75%")
        
        // Test end condition
        XCTAssertEqual(segment1.endCondition, "Complete all drill items and partner rounds")
        
        // Test starting state
        XCTAssertEqual(segment1.startingStateGrips.count, 2)
        XCTAssertTrue(segment1.startingStateGrips.contains("inside_tie"))
        XCTAssertEqual(segment1.startingStateRoles.count, 2)
        XCTAssertTrue(segment1.startingStateRoles.contains("attacker"))
        
        // Test notes
        XCTAssertNotNil(segment1.notes)
        XCTAssertTrue(segment1.notes!.contains("every optional field"))
        
        // Test second segment (Technique) - verify different values
        let segment2 = day.segments[1]
        XCTAssertEqual(segment2.name, "Technique: Inside Tie → Single (Full Detail)")
        XCTAssertEqual(segment2.segmentType, "technique")
        XCTAssertEqual(segment2.durationMinutes, 15)
        XCTAssertEqual(segment2.resistance, 50)
        XCTAssertEqual(segment2.intensityCue, "hard")
        XCTAssertEqual(segment2.intensityScale, "moderate")
        XCTAssertEqual(segment2.breathworkStyle, "Cadence breathing")
        XCTAssertEqual(segment2.breathCount, 3)
        XCTAssertEqual(segment2.intensityCeiling, "85%")
    }
    
    // MARK: - Whiteboard Formatting Test
    
    func testWhiteboardFormatterIncludesAllFields() throws {
        // Create a segment with all fields populated
        let flowStep = UnifiedFlowStep(
            poseName: "Downward Dog",
            holdSeconds: 30,
            transitionCue: "Breathe deeply"
        )
        
        let technique = UnifiedTechnique(
            name: "Test Technique",
            variant: "Standard",
            keyDetails: ["Detail 1"],
            commonErrors: ["Error 1"],
            counters: ["Counter 1"],
            followUps: ["Follow-up 1"]
        )
        
        let drillItem = UnifiedDrillItem(
            name: "Test Drill",
            workSeconds: 60,
            restSeconds: 30,
            notes: "Test notes"
        )
        
        let segment = UnifiedSegment(
            name: "Comprehensive Test Segment",
            segmentType: "technique",
            domain: "grappling",
            durationMinutes: 20,
            objective: "Test all fields",
            constraints: ["No submissions"],
            coachingCues: ["Stay focused"],
            positions: ["standing"],
            techniques: [technique],
            rounds: 3,
            roundDurationSeconds: 180,
            restSeconds: 60,
            resistance: 50,
            attackerGoal: "Control position",
            defenderGoal: "Escape",
            successRateTarget: 0.75,
            cleanRepsTarget: 8,
            decisionSpeedSeconds: 4.0,
            controlTimeSeconds: 5,
            startPosition: "standing",
            endCondition: "Complete all rounds",
            scoring: ["Attacker: Control 5s"],
            winConditions: ["Control achieved"],
            resetRule: "Reset on score",
            intensityCue: "hard",
            switchEverySeconds: 90,
            breathworkStyle: "Box breathing",
            breathworkPattern: "4-4-4-4",
            breathworkDurationSeconds: 120,
            breathCount: 5,
            holdSeconds: 30,
            intensityScale: "moderate",
            props: ["block", "strap"],
            flowSequence: [flowStep],
            notes: "Test notes",
            contraindications: ["No neck cranks"],
            stopIf: ["Sharp pain"],
            intensityCeiling: "80%",
            drillItems: [drillItem],
            startingStateGrips: ["inside_tie"],
            startingStateRoles: ["attacker"],
            mediaVideoUrl: "https://example.com/video",
            mediaImageUrl: "https://example.com/image",
            mediaDiagramAssetId: "diagram_123"
        )
        
        let day = UnifiedDay(
            name: "Test Day",
            segments: [segment]
        )
        
        // Format the day
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Verify that a section was created
        XCTAssertGreaterThan(sections.count, 0)
        
        let section = sections[0]
        XCTAssertGreaterThan(section.items.count, 0)
        
        let item = section.items[0]
        XCTAssertEqual(item.primary, "Comprehensive Test Segment")
        
        // Verify bullets contain all key fields
        let bulletsText = item.bullets.joined(separator: "\n")
        
        // Check for various field types
        XCTAssertTrue(bulletsText.contains("Objective:"), "Should include objective")
        XCTAssertTrue(bulletsText.contains("Start Position:"), "Should include start position")
        XCTAssertTrue(bulletsText.contains("Test Technique"), "Should include technique")
        XCTAssertTrue(bulletsText.contains("Counter"), "Should include counters")
        XCTAssertTrue(bulletsText.contains("Follow-up"), "Should include follow-ups")
        XCTAssertTrue(bulletsText.contains("Flow Sequence"), "Should include flow sequence")
        XCTAssertTrue(bulletsText.contains("Downward Dog"), "Should include flow step")
        XCTAssertTrue(bulletsText.contains("Quality Targets"), "Should include quality targets")
        XCTAssertTrue(bulletsText.contains("Decision speed"), "Should include decision speed")
        XCTAssertTrue(bulletsText.contains("Control time"), "Should include control time")
        XCTAssertTrue(bulletsText.contains("Switch roles"), "Should include switch timing")
        XCTAssertTrue(bulletsText.contains("Win Conditions"), "Should include win conditions")
        XCTAssertTrue(bulletsText.contains("Reset:"), "Should include reset rule")
        XCTAssertTrue(bulletsText.contains("End Condition"), "Should include end condition")
        XCTAssertTrue(bulletsText.contains("Breathwork"), "Should include breathwork")
        XCTAssertTrue(bulletsText.contains("Breath count"), "Should include breath count")
        XCTAssertTrue(bulletsText.contains("Props:"), "Should include props")
        XCTAssertTrue(bulletsText.contains("Media"), "Should include media section")
        XCTAssertTrue(bulletsText.contains("Video"), "Should include video URL")
        XCTAssertTrue(bulletsText.contains("Safety"), "Should include safety section")
        XCTAssertTrue(bulletsText.contains("Stop If"), "Should include stopIf conditions")
        XCTAssertTrue(bulletsText.contains("Intensity Ceiling"), "Should include intensity ceiling")
        XCTAssertTrue(bulletsText.contains("Starting State"), "Should include starting state")
    }
}

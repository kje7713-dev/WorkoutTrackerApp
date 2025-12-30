//
//  SegmentTests.swift
//  Savage By Design Tests
//
//  Tests for segment models and JSON serialization
//

import XCTest
@testable import WorkoutTrackerApp

final class SegmentTests: XCTestCase {
    
    // MARK: - Segment Serialization Tests
    
    func testSegmentCodable() throws {
        // Create a sample segment
        let segment = Segment(
            name: "Test Warmup",
            segmentType: .warmup,
            domain: .grappling,
            durationMinutes: 10,
            objective: "Prepare for training",
            coachingCues: ["Stay loose", "Focus on breathing"]
        )
        
        // Encode to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(segment)
        
        // Decode back
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Segment.self, from: data)
        
        // Verify
        XCTAssertEqual(decoded.name, segment.name)
        XCTAssertEqual(decoded.segmentType, segment.segmentType)
        XCTAssertEqual(decoded.domain, segment.domain)
        XCTAssertEqual(decoded.durationMinutes, segment.durationMinutes)
        XCTAssertEqual(decoded.objective, segment.objective)
        XCTAssertEqual(decoded.coachingCues, segment.coachingCues)
    }
    
    func testSegmentWithTechniques() throws {
        let technique = Technique(
            name: "Single leg takedown",
            variant: "inside tie",
            keyDetails: ["Level change", "Head position"],
            commonErrors: ["Reaching with arms"]
        )
        
        let segment = Segment(
            name: "Technique Drill",
            segmentType: .technique,
            domain: .grappling,
            techniques: [technique]
        )
        
        // Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(segment)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Segment.self, from: data)
        
        // Verify technique details
        XCTAssertEqual(decoded.techniques.count, 1)
        XCTAssertEqual(decoded.techniques[0].name, "Single leg takedown")
        XCTAssertEqual(decoded.techniques[0].variant, "inside tie")
        XCTAssertEqual(decoded.techniques[0].keyDetails.count, 2)
    }
    
    func testDayTemplateWithSegments() throws {
        let segment1 = Segment(
            name: "Warmup",
            segmentType: .warmup,
            durationMinutes: 10
        )
        
        let segment2 = Segment(
            name: "Drilling",
            segmentType: .drill,
            durationMinutes: 20
        )
        
        let day = DayTemplate(
            name: "BJJ Day 1",
            goal: .mixed,
            segments: [segment1, segment2]
        )
        
        // Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(day)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DayTemplate.self, from: data)
        
        // Verify
        XCTAssertEqual(decoded.segments?.count, 2)
        XCTAssertEqual(decoded.segments?[0].name, "Warmup")
        XCTAssertEqual(decoded.segments?[1].name, "Drilling")
    }
    
    func testBlockWithSegmentDays() throws {
        let segment = Segment(
            name: "Technique Work",
            segmentType: .technique,
            durationMinutes: 30
        )
        
        let day = DayTemplate(
            name: "BJJ Class",
            segments: [segment]
        )
        
        let block = Block(
            name: "BJJ Block",
            numberOfWeeks: 1,
            days: [day],
            tags: ["grappling", "bjj"],
            disciplines: [.bjj]
        )
        
        // Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Block.self, from: data)
        
        // Verify
        XCTAssertEqual(decoded.name, "BJJ Block")
        XCTAssertEqual(decoded.tags, ["grappling", "bjj"])
        XCTAssertEqual(decoded.disciplines, [.bjj])
        XCTAssertEqual(decoded.days[0].segments?.count, 1)
    }
    
    func testSessionSegmentTracking() throws {
        let sessionSegment = SessionSegment(
            name: "Positional Sparring",
            segmentType: .positionalSpar,
            isCompleted: true,
            actualDurationMinutes: 12,
            successRate: 0.65,
            cleanReps: 8,
            roundsCompleted: 5
        )
        
        // Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(sessionSegment)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SessionSegment.self, from: data)
        
        // Verify tracked metrics
        XCTAssertEqual(decoded.isCompleted, true)
        XCTAssertEqual(decoded.actualDurationMinutes, 12)
        XCTAssertEqual(decoded.successRate, 0.65)
        XCTAssertEqual(decoded.cleanReps, 8)
        XCTAssertEqual(decoded.roundsCompleted, 5)
    }
    
    func testWorkoutSessionWithSegments() throws {
        let sessionSegment = SessionSegment(
            name: "Warmup",
            segmentType: .warmup,
            isCompleted: true
        )
        
        let session = WorkoutSession(
            blockId: UUID(),
            weekIndex: 0,
            dayTemplateId: UUID(),
            exercises: [],
            segments: [sessionSegment]
        )
        
        // Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(session)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(WorkoutSession.self, from: data)
        
        // Verify
        XCTAssertEqual(decoded.segments?.count, 1)
        XCTAssertEqual(decoded.segments?[0].name, "Warmup")
        XCTAssertEqual(decoded.segments?[0].isCompleted, true)
    }
    
    // MARK: - Backward Compatibility Tests
    
    func testDayTemplateWithoutSegmentsStillWorks() throws {
        // Create a traditional day template without segments
        let exercise = ExerciseTemplate(
            customName: "Squat",
            type: .strength,
            progressionRule: ProgressionRule(type: .weight)
        )
        
        let day = DayTemplate(
            name: "Leg Day",
            exercises: [exercise],
            segments: nil  // Explicitly nil
        )
        
        // Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(day)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DayTemplate.self, from: data)
        
        // Verify traditional structure still works
        XCTAssertEqual(decoded.exercises.count, 1)
        XCTAssertEqual(decoded.segments, nil)
    }
    
    func testBlockWithMixedDays() throws {
        // Create a block with both traditional and segment-based days
        let traditionalDay = DayTemplate(
            name: "Strength Day",
            exercises: [
                ExerciseTemplate(
                    customName: "Bench Press",
                    type: .strength,
                    progressionRule: ProgressionRule(type: .weight)
                )
            ]
        )
        
        let segmentDay = DayTemplate(
            name: "BJJ Day",
            segments: [
                Segment(name: "Drilling", segmentType: .drill, durationMinutes: 30)
            ]
        )
        
        let block = Block(
            name: "Hybrid Block",
            numberOfWeeks: 1,
            days: [traditionalDay, segmentDay]
        )
        
        // Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Block.self, from: data)
        
        // Verify both day types work
        XCTAssertEqual(decoded.days[0].exercises.count, 1)
        XCTAssertEqual(decoded.days[0].segments, nil)
        XCTAssertEqual(decoded.days[1].exercises.count, 0)
        XCTAssertEqual(decoded.days[1].segments?.count, 1)
    }
}

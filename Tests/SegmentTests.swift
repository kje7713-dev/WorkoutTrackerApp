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
    
    // MARK: - SessionFactory Segment Conversion Tests
    
    func testSessionFactoryConvertsSegmentsToSessionSegments() throws {
        // Create a block with segment-based day
        let segment1 = Segment(
            name: "Warmup Flow",
            segmentType: .warmup,
            domain: .grappling,
            durationMinutes: 10,
            objective: "Prepare body for training"
        )
        
        let segment2 = Segment(
            name: "Technique Practice",
            segmentType: .technique,
            domain: .grappling,
            durationMinutes: 20,
            objective: "Learn single leg takedown"
        )
        
        let day = DayTemplate(
            name: "BJJ Class Day 1",
            shortCode: "BJJ1",
            goal: .mixed,
            segments: [segment1, segment2]
        )
        
        let block = Block(
            name: "BJJ Fundamentals",
            numberOfWeeks: 2,
            days: [day]
        )
        
        // Generate sessions using SessionFactory
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        // Verify sessions were created (2 weeks × 1 day = 2 sessions)
        XCTAssertEqual(sessions.count, 2)
        
        // Verify first session has segments
        let firstSession = sessions[0]
        XCTAssertNotNil(firstSession.segments, "Session should have segments")
        XCTAssertEqual(firstSession.segments?.count, 2, "Session should have 2 segments")
        
        // Verify segment details
        guard let sessionSegments = firstSession.segments else {
            XCTFail("Session segments should not be nil")
            return
        }
        
        XCTAssertEqual(sessionSegments[0].name, "Warmup Flow")
        XCTAssertEqual(sessionSegments[0].segmentType, .warmup)
        XCTAssertEqual(sessionSegments[0].actualDurationMinutes, 10)
        XCTAssertEqual(sessionSegments[0].isCompleted, false)
        XCTAssertNotNil(sessionSegments[0].segmentId, "Session segment should reference original segment ID")
        
        XCTAssertEqual(sessionSegments[1].name, "Technique Practice")
        XCTAssertEqual(sessionSegments[1].segmentType, .technique)
        XCTAssertEqual(sessionSegments[1].actualDurationMinutes, 20)
        XCTAssertEqual(sessionSegments[1].isCompleted, false)
        
        // Verify second week session also has segments
        let secondSession = sessions[1]
        XCTAssertNotNil(secondSession.segments)
        XCTAssertEqual(secondSession.segments?.count, 2)
    }
    
    func testSessionFactoryHandlesDaysWithoutSegments() throws {
        // Create a traditional day without segments
        let exercise = ExerciseTemplate(
            customName: "Squat",
            type: .strength,
            strengthSets: [
                StrengthSetTemplate(index: 0, reps: 5, weight: 225)
            ],
            progressionRule: ProgressionRule(type: .weight, deltaWeight: 5.0)
        )
        
        let day = DayTemplate(
            name: "Leg Day",
            exercises: [exercise],
            segments: nil
        )
        
        let block = Block(
            name: "Strength Block",
            numberOfWeeks: 1,
            days: [day]
        )
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        // Verify session created without segments
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions[0].exercises.count, 1)
        XCTAssertNil(sessions[0].segments, "Session should not have segments for traditional workout")
    }
    
    func testSessionFactoryHandlesHybridDays() throws {
        // Create a day with both exercises and segments
        let exercise = ExerciseTemplate(
            customName: "Deadlift",
            type: .strength,
            strengthSets: [
                StrengthSetTemplate(index: 0, reps: 3, weight: 315)
            ],
            progressionRule: ProgressionRule(type: .weight)
        )
        
        let segment = Segment(
            name: "Mobility Cooldown",
            segmentType: .cooldown,
            domain: .mobility,
            durationMinutes: 10
        )
        
        let day = DayTemplate(
            name: "Hybrid Day",
            exercises: [exercise],
            segments: [segment]
        )
        
        let block = Block(
            name: "Hybrid Block",
            numberOfWeeks: 1,
            days: [day]
        )
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        // Verify session has both exercises and segments
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions[0].exercises.count, 1, "Session should have exercises")
        XCTAssertNotNil(sessions[0].segments, "Session should have segments")
        XCTAssertEqual(sessions[0].segments?.count, 1, "Session should have 1 segment")
    }
    
    // MARK: - Generalized Use Case Tests
    
    func testNewSegmentTypesSerialization() throws {
        // Test all new segment types for proper serialization
        let newTypes: [SegmentType] = [
            .practice,
            .presentation,
            .review,
            .demonstration,
            .discussion,
            .assessment
        ]
        
        for segmentType in newTypes {
            let segment = Segment(
                name: "Test \(segmentType.rawValue)",
                segmentType: segmentType,
                durationMinutes: 15
            )
            
            // Encode and decode
            let encoder = JSONEncoder()
            let data = try encoder.encode(segment)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Segment.self, from: data)
            
            // Verify
            XCTAssertEqual(decoded.segmentType, segmentType)
            XCTAssertEqual(decoded.name, segment.name)
        }
    }
    
    func testNewDomainsSerialization() throws {
        // Test all new domain types for proper serialization
        let newDomains: [Domain] = [
            .sports,
            .business,
            .education,
            .analytics
        ]
        
        for domain in newDomains {
            let segment = Segment(
                name: "Test Segment",
                segmentType: .practice,
                domain: domain,
                durationMinutes: 20
            )
            
            // Encode and decode
            let encoder = JSONEncoder()
            let data = try encoder.encode(segment)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Segment.self, from: data)
            
            // Verify
            XCTAssertEqual(decoded.domain, domain)
        }
    }
    
    func testSportsPracticeSession() throws {
        // Create a soccer practice session with multiple segments
        let warmupSegment = Segment(
            name: "Dynamic Warmup",
            segmentType: .warmup,
            domain: .sports,
            durationMinutes: 10,
            objective: "Prepare players for practice"
        )
        
        let drillSegment = Segment(
            name: "Passing Drills",
            segmentType: .drill,
            domain: .sports,
            durationMinutes: 20,
            objective: "Improve passing accuracy and speed"
        )
        
        let practiceSegment = Segment(
            name: "Small-Sided Games",
            segmentType: .practice,
            domain: .sports,
            durationMinutes: 25,
            objective: "Apply skills in game-like situations"
        )
        
        let cooldownSegment = Segment(
            name: "Cool Down",
            segmentType: .cooldown,
            domain: .sports,
            durationMinutes: 5
        )
        
        let day = DayTemplate(
            name: "Soccer Practice - Week 1",
            segments: [warmupSegment, drillSegment, practiceSegment, cooldownSegment]
        )
        
        let block = Block(
            name: "Soccer Season Training",
            numberOfWeeks: 4,
            days: [day],
            tags: ["soccer", "youth", "team"],
            disciplines: nil
        )
        
        // Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Block.self, from: data)
        
        // Verify
        XCTAssertEqual(decoded.days[0].segments?.count, 4)
        XCTAssertEqual(decoded.days[0].segments?[2].segmentType, .practice)
        XCTAssertEqual(decoded.days[0].segments?[2].domain, .sports)
    }
    
    func testBusinessTrainingSession() throws {
        // Create a PowerBI training session
        let presentationSegment = Segment(
            name: "PowerBI Overview",
            segmentType: .presentation,
            domain: .analytics,
            durationMinutes: 15,
            objective: "Introduce PowerBI interface and capabilities"
        )
        
        let demonstrationSegment = Segment(
            name: "Creating Your First Dashboard",
            segmentType: .demonstration,
            domain: .analytics,
            durationMinutes: 30,
            objective: "Step-by-step dashboard creation"
        )
        
        let practiceSegment = Segment(
            name: "Hands-On Practice",
            segmentType: .practice,
            domain: .analytics,
            durationMinutes: 45,
            objective: "Build a dashboard with sample data"
        )
        
        let reviewSegment = Segment(
            name: "Review and Q&A",
            segmentType: .review,
            domain: .analytics,
            durationMinutes: 20,
            objective: "Review common issues and answer questions"
        )
        
        let assessmentSegment = Segment(
            name: "Knowledge Check",
            segmentType: .assessment,
            domain: .analytics,
            durationMinutes: 10,
            objective: "Verify understanding of key concepts"
        )
        
        let day = DayTemplate(
            name: "PowerBI Training - Day 1",
            segments: [presentationSegment, demonstrationSegment, practiceSegment, reviewSegment, assessmentSegment]
        )
        
        let block = Block(
            name: "PowerBI Fundamentals Course",
            description: "Complete PowerBI training for business analysts",
            numberOfWeeks: 1,
            days: [day],
            tags: ["powerbi", "analytics", "training"]
        )
        
        // Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Block.self, from: data)
        
        // Verify all segment types
        XCTAssertEqual(decoded.days[0].segments?.count, 5)
        XCTAssertEqual(decoded.days[0].segments?[0].segmentType, .presentation)
        XCTAssertEqual(decoded.days[0].segments?[1].segmentType, .demonstration)
        XCTAssertEqual(decoded.days[0].segments?[2].segmentType, .practice)
        XCTAssertEqual(decoded.days[0].segments?[3].segmentType, .review)
        XCTAssertEqual(decoded.days[0].segments?[4].segmentType, .assessment)
        XCTAssertEqual(decoded.days[0].segments?[0].domain, .analytics)
    }
    
    func testEducationalWorkshopSession() throws {
        // Create a general educational workshop
        let discussionSegment = Segment(
            name: "Opening Discussion",
            segmentType: .discussion,
            domain: .education,
            durationMinutes: 15,
            objective: "Introduce topic and gather initial thoughts"
        )
        
        let lectureSegment = Segment(
            name: "Core Concepts",
            segmentType: .lecture,
            domain: .education,
            durationMinutes: 30,
            objective: "Cover fundamental concepts"
        )
        
        let practiceSegment = Segment(
            name: "Group Activity",
            segmentType: .practice,
            domain: .education,
            durationMinutes: 25,
            objective: "Apply concepts in small groups"
        )
        
        let reviewSegment = Segment(
            name: "Closing Review",
            segmentType: .review,
            domain: .education,
            durationMinutes: 10,
            objective: "Summarize key takeaways"
        )
        
        let day = DayTemplate(
            name: "Workshop Day",
            segments: [discussionSegment, lectureSegment, practiceSegment, reviewSegment]
        )
        
        let block = Block(
            name: "Educational Workshop Series",
            numberOfWeeks: 1,
            days: [day]
        )
        
        // Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(block)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Block.self, from: data)
        
        // Verify
        XCTAssertEqual(decoded.days[0].segments?.count, 4)
        XCTAssertEqual(decoded.days[0].segments?[0].segmentType, .discussion)
        XCTAssertEqual(decoded.days[0].segments?[0].domain, .education)
    }
    
    func testSessionFactoryWithNewSegmentTypes() throws {
        // Test that SessionFactory handles new segment types correctly
        let segment = Segment(
            name: "Team Practice",
            segmentType: .practice,
            domain: .sports,
            durationMinutes: 45,
            objective: "Scrimmage and game situations"
        )
        
        let day = DayTemplate(
            name: "Practice Day",
            segments: [segment]
        )
        
        let block = Block(
            name: "Sports Block",
            numberOfWeeks: 2,
            days: [day]
        )
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        
        // Verify sessions created with new segment type
        XCTAssertEqual(sessions.count, 2)
        XCTAssertNotNil(sessions[0].segments)
        XCTAssertEqual(sessions[0].segments?[0].segmentType, .practice)
    }
    
    func testBackwardCompatibilityWithNewEnums() throws {
        // Verify that adding new enum cases doesn't break existing segment-based content
        let existingBJJSegment = Segment(
            name: "Rolling",
            segmentType: .rolling,
            domain: .grappling,
            durationMinutes: 30
        )
        
        let existingYogaSegment = Segment(
            name: "Flow Sequence",
            segmentType: .mobility,
            domain: .yoga,
            durationMinutes: 20
        )
        
        let day = DayTemplate(
            name: "Mixed Day",
            segments: [existingBJJSegment, existingYogaSegment]
        )
        
        // Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(day)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DayTemplate.self, from: data)
        
        // Verify existing types still work
        XCTAssertEqual(decoded.segments?[0].segmentType, .rolling)
        XCTAssertEqual(decoded.segments?[0].domain, .grappling)
        XCTAssertEqual(decoded.segments?[1].segmentType, .mobility)
        XCTAssertEqual(decoded.segments?[1].domain, .yoga)
    }
    
    func testGeneralizedUseCasesExampleJSON() throws {
        // Test that the generalized_use_cases_example.json file can be parsed correctly
        guard let testBundle = Bundle(for: type(of: self)).path(forResource: "generalized_use_cases_example", ofType: "json") else {
            XCTFail("Could not find generalized_use_cases_example.json in test bundle")
            return
        }
        
        let data = try Data(contentsOf: URL(fileURLWithPath: testBundle))
        
        // Parse the imported block
        let decoder = JSONDecoder()
        let importedBlock = try decoder.decode(ImportedBlock.self, from: data)
        
        // Verify structure
        XCTAssertEqual(importedBlock.Title, "Multi-Domain Training Examples")
        XCTAssertEqual(importedBlock.NumberOfWeeks, 1)
        XCTAssertNotNil(importedBlock.Days)
        XCTAssertEqual(importedBlock.Days?.count, 5, "Should have 5 example days")
        
        // Verify Soccer Practice Day
        let soccerDay = importedBlock.Days?[0]
        XCTAssertEqual(soccerDay?.name, "Soccer Practice Day")
        XCTAssertEqual(soccerDay?.segments?.count, 4)
        XCTAssertEqual(soccerDay?.segments?[2].name, "Small-Sided Games")
        XCTAssertEqual(soccerDay?.segments?[2].segmentType, "practice")
        XCTAssertEqual(soccerDay?.segments?[2].domain, "sports")
        
        // Verify PowerBI Training Day
        let powerBIDay = importedBlock.Days?[1]
        XCTAssertEqual(powerBIDay?.name, "PowerBI Training - Day 1")
        XCTAssertEqual(powerBIDay?.segments?.count, 6)
        XCTAssertEqual(powerBIDay?.segments?[0].segmentType, "presentation")
        XCTAssertEqual(powerBIDay?.segments?[0].domain, "analytics")
        XCTAssertEqual(powerBIDay?.segments?[1].segmentType, "demonstration")
        XCTAssertEqual(powerBIDay?.segments?[3].segmentType, "discussion")
        XCTAssertEqual(powerBIDay?.segments?[5].segmentType, "assessment")
        
        // Verify Business Workshop Day
        let businessDay = importedBlock.Days?[2]
        XCTAssertEqual(businessDay?.name, "Business Workshop")
        XCTAssertEqual(businessDay?.segments?.count, 5)
        XCTAssertEqual(businessDay?.segments?[0].domain, "business")
        
        // Verify Educational Course Day
        let eduDay = importedBlock.Days?[3]
        XCTAssertEqual(eduDay?.name, "Educational Course Session")
        XCTAssertEqual(eduDay?.segments?.count, 6)
        XCTAssertEqual(eduDay?.segments?[0].domain, "education")
        
        // Verify Basketball Training Day
        let basketballDay = importedBlock.Days?[4]
        XCTAssertEqual(basketballDay?.name, "Basketball Skills Training")
        XCTAssertEqual(basketballDay?.segments?.count, 5)
        XCTAssertEqual(basketballDay?.segments?[0].domain, "sports")
        
        // Convert to Block model using BlockGenerator
        let block = try BlockGenerator.mapImportedBlock(importedBlock)
        
        // Verify block structure
        XCTAssertEqual(block.name, "Multi-Domain Training Examples")
        XCTAssertEqual(block.numberOfWeeks, 1)
        XCTAssertEqual(block.days.count, 5)
        
        // Verify all segment types are correctly parsed
        let allSegments = block.days.flatMap { $0.segments ?? [] }
        XCTAssertTrue(allSegments.contains { $0.segmentType == .practice })
        XCTAssertTrue(allSegments.contains { $0.segmentType == .presentation })
        XCTAssertTrue(allSegments.contains { $0.segmentType == .demonstration })
        XCTAssertTrue(allSegments.contains { $0.segmentType == .discussion })
        XCTAssertTrue(allSegments.contains { $0.segmentType == .review })
        XCTAssertTrue(allSegments.contains { $0.segmentType == .assessment })
        
        // Verify all domains are correctly parsed
        XCTAssertTrue(allSegments.contains { $0.domain == .sports })
        XCTAssertTrue(allSegments.contains { $0.domain == .analytics })
        XCTAssertTrue(allSegments.contains { $0.domain == .business })
        XCTAssertTrue(allSegments.contains { $0.domain == .education })
    }
}

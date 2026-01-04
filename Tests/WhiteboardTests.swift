//
//  WhiteboardTests.swift
//  Savage By Design Tests
//
//  Tests for whiteboard normalization and formatting
//

import XCTest
@testable import WorkoutTrackerApp

final class WhiteboardTests: XCTestCase {
    
    // MARK: - Normalization Tests
    
    func testNormalizeBlockWithDays() {
        // Given: A block with Days (multi-day repeated)
        let block = Block(
            name: "Test Block",
            numberOfWeeks: 3,
            goal: .strength,
            days: [
                DayTemplate(
                    name: "Day 1",
                    exercises: [
                        ExerciseTemplate(
                            customName: "Squat",
                            type: .strength,
                            category: .squat,
                            strengthSets: [
                                StrengthSetTemplate(index: 0, reps: 5),
                                StrengthSetTemplate(index: 1, reps: 5)
                            ],
                            progressionRule: ProgressionRule(type: .weight)
                        )
                    ]
                ),
                DayTemplate(
                    name: "Day 2",
                    exercises: []
                )
            ]
        )
        
        // When: Normalizing the block
        let unified = BlockNormalizer.normalize(block: block)
        
        // Then: Should have 3 weeks with 2 days each
        XCTAssertEqual(unified.numberOfWeeks, 3)
        XCTAssertEqual(unified.weeks.count, 3)
        XCTAssertEqual(unified.weeks[0].count, 2)
        XCTAssertEqual(unified.weeks[1].count, 2)
        XCTAssertEqual(unified.weeks[2].count, 2)
        XCTAssertEqual(unified.weeks[0][0].name, "Day 1")
        XCTAssertEqual(unified.weeks[0][0].exercises.count, 1)
        XCTAssertEqual(unified.weeks[0][0].exercises[0].name, "Squat")
    }
    
    func testNormalizeBlockWithWeekTemplates() {
        // Given: A block with weekTemplates (week-specific days)
        let block = Block(
            name: "DUP Block",
            numberOfWeeks: 2,
            goal: .strength,
            days: [],
            weekTemplates: [
                [
                    DayTemplate(
                        name: "Week 1 - Heavy",
                        exercises: [
                            ExerciseTemplate(
                                customName: "Back Squat",
                                type: .strength,
                                category: .squat,
                                strengthSets: [
                                    StrengthSetTemplate(index: 0, reps: 5)
                                ],
                                progressionRule: ProgressionRule(type: .weight)
                            )
                        ]
                    )
                ],
                [
                    DayTemplate(
                        name: "Week 2 - Volume",
                        exercises: [
                            ExerciseTemplate(
                                customName: "Front Squat",
                                type: .strength,
                                category: .squat,
                                strengthSets: [
                                    StrengthSetTemplate(index: 0, reps: 8)
                                ],
                                progressionRule: ProgressionRule(type: .weight)
                            )
                        ]
                    )
                ]
            ]
        )
        
        // When: Normalizing the block
        let unified = BlockNormalizer.normalize(block: block)
        
        // Then: Should have week-specific days
        XCTAssertEqual(unified.numberOfWeeks, 2)
        XCTAssertEqual(unified.weeks.count, 2)
        XCTAssertEqual(unified.weeks[0][0].name, "Week 1 - Heavy")
        XCTAssertEqual(unified.weeks[0][0].exercises[0].name, "Back Squat")
        XCTAssertEqual(unified.weeks[1][0].name, "Week 2 - Volume")
        XCTAssertEqual(unified.weeks[1][0].exercises[0].name, "Front Squat")
    }
    
    func testNormalizeBlockWithFewerWeekTemplatesThanNumberOfWeeks() {
        // Given: A 4-week block with only 2 week templates (should cycle)
        let block = Block(
            name: "4 Week Block",
            numberOfWeeks: 4,
            goal: .strength,
            days: [],
            weekTemplates: [
                [
                    DayTemplate(
                        name: "Week 1 Day",
                        exercises: [
                            ExerciseTemplate(
                                customName: "Squat",
                                type: .strength,
                                category: .squat,
                                strengthSets: [
                                    StrengthSetTemplate(index: 0, reps: 5)
                                ],
                                progressionRule: ProgressionRule(type: .weight)
                            )
                        ]
                    )
                ],
                [
                    DayTemplate(
                        name: "Week 2 Day",
                        exercises: [
                            ExerciseTemplate(
                                customName: "Deadlift",
                                type: .strength,
                                category: .hinge,
                                strengthSets: [
                                    StrengthSetTemplate(index: 0, reps: 3)
                                ],
                                progressionRule: ProgressionRule(type: .weight)
                            )
                        ]
                    )
                ]
            ]
        )
        
        // When: Normalizing the block
        let unified = BlockNormalizer.normalize(block: block)
        
        // Then: Should have 4 weeks by cycling through the 2 templates
        XCTAssertEqual(unified.numberOfWeeks, 4)
        XCTAssertEqual(unified.weeks.count, 4)
        // Week 1 and 3 should use first template (cycling)
        XCTAssertEqual(unified.weeks[0][0].name, "Week 1 Day")
        XCTAssertEqual(unified.weeks[2][0].name, "Week 1 Day")
        // Week 2 and 4 should use second template (cycling)
        XCTAssertEqual(unified.weeks[1][0].name, "Week 2 Day")
        XCTAssertEqual(unified.weeks[3][0].name, "Week 2 Day")
    }
    
    func testNormalizeBlockWithMoreWeekTemplatesThanNumberOfWeeks() {
        // Given: A 2-week block with 4 week templates (should truncate)
        let block = Block(
            name: "2 Week Block",
            numberOfWeeks: 2,
            goal: .strength,
            days: [],
            weekTemplates: [
                [DayTemplate(name: "Week 1", exercises: [])],
                [DayTemplate(name: "Week 2", exercises: [])],
                [DayTemplate(name: "Week 3", exercises: [])],
                [DayTemplate(name: "Week 4", exercises: [])]
            ]
        )
        
        // When: Normalizing the block
        let unified = BlockNormalizer.normalize(block: block)
        
        // Then: Should only use first 2 weeks
        XCTAssertEqual(unified.numberOfWeeks, 2)
        XCTAssertEqual(unified.weeks.count, 2)
        XCTAssertEqual(unified.weeks[0][0].name, "Week 1")
        XCTAssertEqual(unified.weeks[1][0].name, "Week 2")
    }
    
    func testNormalizeAuthoringBlockWithWeeks() {
        // Given: An authoring block with Weeks
        let authoringBlock = AuthoringBlock(
            Title: "Powerlifting Block",
            NumberOfWeeks: 2,
            Weeks: [
                [
                    AuthoringDay(
                        name: "Week 1 Day 1",
                        exercises: [
                            AuthoringExercise(
                                name: "Squat",
                                type: "strength",
                                setsReps: "5x5"
                            )
                        ]
                    )
                ],
                [
                    AuthoringDay(
                        name: "Week 2 Day 1",
                        exercises: [
                            AuthoringExercise(
                                name: "Deadlift",
                                type: "strength",
                                setsReps: "3x8"
                            )
                        ]
                    )
                ]
            ]
        )
        
        // When: Normalizing
        let unified = BlockNormalizer.normalize(authoringBlock: authoringBlock)
        
        // Then: Should preserve week structure
        XCTAssertEqual(unified.numberOfWeeks, 2)
        XCTAssertEqual(unified.weeks.count, 2)
        XCTAssertEqual(unified.weeks[0][0].name, "Week 1 Day 1")
        XCTAssertEqual(unified.weeks[0][0].exercises[0].name, "Squat")
        XCTAssertEqual(unified.weeks[0][0].exercises[0].strengthSets.count, 5)
        XCTAssertEqual(unified.weeks[0][0].exercises[0].strengthSets[0].reps, 5)
    }
    
    func testNormalizeAuthoringBlockWithExercises() {
        // Given: An authoring block with only Exercises (single day)
        let authoringBlock = AuthoringBlock(
            Title: "Single Day Block",
            NumberOfWeeks: 3,
            Exercises: [
                AuthoringExercise(
                    name: "Bench Press",
                    type: "strength",
                    setsReps: "3x10"
                )
            ]
        )
        
        // When: Normalizing
        let unified = BlockNormalizer.normalize(authoringBlock: authoringBlock)
        
        // Then: Should create "Day 1" repeated across weeks
        XCTAssertEqual(unified.numberOfWeeks, 3)
        XCTAssertEqual(unified.weeks.count, 3)
        XCTAssertEqual(unified.weeks[0].count, 1)
        XCTAssertEqual(unified.weeks[0][0].name, "Day 1")
        XCTAssertEqual(unified.weeks[0][0].exercises[0].name, "Bench Press")
        XCTAssertEqual(unified.weeks[0][0].exercises[0].strengthSets.count, 3)
        XCTAssertEqual(unified.weeks[0][0].exercises[0].strengthSets[0].reps, 10)
    }
    
    // MARK: - Formatting Tests
    
    func testFormatStrengthPrescription() {
        // Given: A day with strength exercises
        let day = UnifiedDay(
            name: "Strength Day",
            exercises: [
                UnifiedExercise(
                    name: "Back Squat",
                    type: "strength",
                    category: "squat",
                    notes: "@ RPE 8",
                    strengthSets: [
                        UnifiedStrengthSet(reps: 5, restSeconds: 180),
                        UnifiedStrengthSet(reps: 5, restSeconds: 180),
                        UnifiedStrengthSet(reps: 5, restSeconds: 180),
                        UnifiedStrengthSet(reps: 5, restSeconds: 180),
                        UnifiedStrengthSet(reps: 5, restSeconds: 180)
                    ]
                )
            ]
        )
        
        // When: Formatting the day
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should create Strength section with proper prescription
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].title, "Strength")
        XCTAssertEqual(sections[0].items.count, 1)
        
        let item = sections[0].items[0]
        XCTAssertEqual(item.primary, "Back Squat")
        XCTAssertEqual(item.secondary, "5 × 5 @ RPE 8")
        XCTAssertEqual(item.tertiary, "Rest: 3:00")
    }
    
    func testFormatStrengthPrescriptionWithWeight() {
        // Given: A day with strength exercises that have weight
        let day = UnifiedDay(
            name: "Strength Day",
            exercises: [
                UnifiedExercise(
                    name: "Back Squat",
                    type: "strength",
                    category: "squat",
                    strengthSets: [
                        UnifiedStrengthSet(reps: 5, weight: 225, restSeconds: 180),
                        UnifiedStrengthSet(reps: 5, weight: 225, restSeconds: 180),
                        UnifiedStrengthSet(reps: 5, weight: 225, restSeconds: 180),
                        UnifiedStrengthSet(reps: 5, weight: 225, restSeconds: 180),
                        UnifiedStrengthSet(reps: 5, weight: 225, restSeconds: 180)
                    ]
                )
            ]
        )
        
        // When: Formatting the day
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should include weight in prescription
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].title, "Strength")
        XCTAssertEqual(sections[0].items.count, 1)
        
        let item = sections[0].items[0]
        XCTAssertEqual(item.primary, "Back Squat")
        XCTAssertEqual(item.secondary, "5 × 5 @ 225 lbs")
        XCTAssertEqual(item.tertiary, "Rest: 3:00")
    }
    
    func testFormatStrengthPrescriptionWithWeightAndRPE() {
        // Given: A day with strength exercises that have weight and RPE
        let day = UnifiedDay(
            name: "Strength Day",
            exercises: [
                UnifiedExercise(
                    name: "Deadlift",
                    type: "strength",
                    category: "hinge",
                    notes: "@ RPE 8",
                    strengthSets: [
                        UnifiedStrengthSet(reps: 3, weight: 315, restSeconds: 240),
                        UnifiedStrengthSet(reps: 3, weight: 315, restSeconds: 240),
                        UnifiedStrengthSet(reps: 3, weight: 315, restSeconds: 240)
                    ]
                )
            ]
        )
        
        // When: Formatting the day
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should include both weight and RPE
        let item = sections[0].items[0]
        XCTAssertEqual(item.primary, "Deadlift")
        XCTAssertEqual(item.secondary, "3 × 3 @ 315 lbs @ RPE 8")
        XCTAssertEqual(item.tertiary, "Rest: 4:00")
    }
    
    func testFormatStrengthPrescriptionWithVaryingWeights() {
        // Given: Strength exercise with varying weights (pyramid)
        let day = UnifiedDay(
            name: "Pyramid Day",
            exercises: [
                UnifiedExercise(
                    name: "Bench Press",
                    type: "strength",
                    strengthSets: [
                        UnifiedStrengthSet(reps: 5, weight: 135),
                        UnifiedStrengthSet(reps: 5, weight: 185),
                        UnifiedStrengthSet(reps: 5, weight: 225)
                    ]
                )
            ]
        )
        
        // When: Formatting
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should show weights breakdown
        let item = sections[0].items[0]
        XCTAssertEqual(item.secondary, "3 × 5 @ 135/185/225 lbs")
    }
    
    func testFormatStrengthPrescriptionVaryingReps() {
        // Given: Strength exercise with varying reps
        let day = UnifiedDay(
            name: "Pyramid Day",
            exercises: [
                UnifiedExercise(
                    name: "Deadlift",
                    type: "strength",
                    strengthSets: [
                        UnifiedStrengthSet(reps: 5),
                        UnifiedStrengthSet(reps: 3),
                        UnifiedStrengthSet(reps: 1)
                    ]
                )
            ]
        )
        
        // When: Formatting
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should show reps breakdown
        let item = sections[0].items[0]
        XCTAssertEqual(item.secondary, "3 sets: 5/3/1")
    }
    
    func testFormatAMRAP() {
        // Given: An AMRAP conditioning exercise
        let day = UnifiedDay(
            name: "Conditioning",
            exercises: [
                UnifiedExercise(
                    name: "Metcon",
                    type: "conditioning",
                    notes: "10 Burpees, 15 KB Swings, 20 Box Jumps",
                    conditioningType: "amrap",
                    conditioningSets: [
                        UnifiedConditioningSet(
                            durationSeconds: 1200
                        )
                    ]
                )
            ]
        )
        
        // When: Formatting
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should format AMRAP properly
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].title, "Conditioning")
        
        let item = sections[0].items[0]
        XCTAssertEqual(item.primary, "Metcon")
        XCTAssertEqual(item.secondary, "20 min AMRAP")
        XCTAssertEqual(item.bullets.count, 3)
        XCTAssertTrue(item.bullets.contains("10 Burpees"))
    }
    
    func testFormatEMOM() {
        // Given: An EMOM conditioning exercise
        let day = UnifiedDay(
            name: "Conditioning",
            exercises: [
                UnifiedExercise(
                    name: "EMOM Work",
                    type: "conditioning",
                    notes: "5 Pull-ups, 10 Push-ups, 15 Air Squats",
                    conditioningType: "emom",
                    conditioningSets: [
                        UnifiedConditioningSet(
                            durationSeconds: 900
                        )
                    ]
                )
            ]
        )
        
        // When: Formatting
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should format EMOM properly
        let item = sections[0].items[0]
        XCTAssertEqual(item.secondary, "EMOM 15 min")
        XCTAssertEqual(item.bullets.count, 3)
    }
    
    func testFormatIntervals() {
        // Given: Intervals exercise
        let day = UnifiedDay(
            name: "Intervals",
            exercises: [
                UnifiedExercise(
                    name: "Row",
                    type: "conditioning",
                    conditioningType: "intervals",
                    conditioningSets: [
                        UnifiedConditioningSet(
                            durationSeconds: 120,
                            rounds: 8,
                            effortDescriptor: "hard",
                            restSeconds: 60
                        )
                    ]
                )
            ]
        )
        
        // When: Formatting
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should format intervals with work/rest
        let item = sections[0].items[0]
        XCTAssertEqual(item.secondary, "8 rounds")
        XCTAssertTrue(item.bullets.contains(":2:00 hard"))
        XCTAssertTrue(item.bullets.contains(":1:00 rest"))
    }
    
    func testFormatRestTime() {
        // Given: Exercise with various rest times
        let day = UnifiedDay(
            name: "Test",
            exercises: [
                UnifiedExercise(
                    name: "Exercise 1",
                    type: "strength",
                    strengthSets: [
                        UnifiedStrengthSet(reps: 5, restSeconds: 90)
                    ]
                ),
                UnifiedExercise(
                    name: "Exercise 2",
                    type: "strength",
                    strengthSets: [
                        UnifiedStrengthSet(reps: 5, restSeconds: 125)
                    ]
                )
            ]
        )
        
        // When: Formatting
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should format rest as M:SS
        XCTAssertEqual(sections[0].items[0].tertiary, "Rest: 1:30")
        XCTAssertEqual(sections[0].items[1].tertiary, "Rest: 2:05")
    }
    
    func testPartitionStrengthAndAccessory() {
        // Given: Mixed strength exercises
        let day = UnifiedDay(
            name: "Mixed Day",
            exercises: [
                UnifiedExercise(
                    name: "Back Squat",
                    type: "strength",
                    category: "squat",
                    strengthSets: Array(repeating: UnifiedStrengthSet(reps: 5), count: 5)
                ),
                UnifiedExercise(
                    name: "Bicep Curls",
                    type: "strength",
                    category: "other",
                    strengthSets: Array(repeating: UnifiedStrengthSet(reps: 12), count: 3)
                )
            ]
        )
        
        // When: Formatting
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should separate into Strength and Accessory
        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections[0].title, "Strength")
        XCTAssertEqual(sections[0].items[0].primary, "Back Squat")
        XCTAssertEqual(sections[1].title, "Accessory")
        XCTAssertEqual(sections[1].items[0].primary, "Bicep Curls")
    }
    
    func testConditioningSetNotesDisplayed() {
        // Given: Conditioning exercise with set-level notes
        let day = UnifiedDay(
            name: "Conditioning",
            exercises: [
                UnifiedExercise(
                    name: "AMRAP Workout",
                    type: "conditioning",
                    notes: "10 Burpees, 15 KB Swings",
                    conditioningType: "amrap",
                    conditioningSets: [
                        UnifiedConditioningSet(
                            durationSeconds: 1200,
                            notes: "Scale as needed, focus on form"
                        )
                    ]
                )
            ]
        )
        
        // When: Formatting
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should include both exercise and set notes
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].title, "Conditioning")
        
        let item = sections[0].items[0]
        XCTAssertEqual(item.primary, "AMRAP Workout")
        XCTAssertEqual(item.secondary, "20 min AMRAP")
        
        // Verify both exercise-level notes and set-level notes are in bullets
        XCTAssertTrue(item.bullets.contains("10 Burpees"))
        XCTAssertTrue(item.bullets.contains("15 KB Swings"))
        XCTAssertTrue(item.bullets.contains("Scale as needed, focus on form"))
    }
    
    func testConditioningSetNotesOnly() {
        // Given: Conditioning exercise with only set-level notes (no exercise notes)
        let day = UnifiedDay(
            name: "Conditioning",
            exercises: [
                UnifiedExercise(
                    name: "Row",
                    type: "conditioning",
                    conditioningType: "forTime",
                    conditioningSets: [
                        UnifiedConditioningSet(
                            distanceMeters: 2000,
                            notes: "Target pace: 2:00/500m"
                        )
                    ]
                )
            ]
        )
        
        // When: Formatting
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should display set-level notes
        let item = sections[0].items[0]
        XCTAssertEqual(item.primary, "Row")
        XCTAssertTrue(item.bullets.contains("Target pace: 2:00/500m"))
    }
    
    func testConditioningEMOMWithSetNotes() {
        // Given: EMOM exercise with set-level notes
        let day = UnifiedDay(
            name: "Conditioning",
            exercises: [
                UnifiedExercise(
                    name: "EMOM Workout",
                    type: "conditioning",
                    notes: "5 Pull-ups, 10 Push-ups",
                    conditioningType: "emom",
                    conditioningSets: [
                        UnifiedConditioningSet(
                            durationSeconds: 900,
                            notes: "Rest remaining time each minute"
                        )
                    ]
                )
            ]
        )
        
        // When: Formatting
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should include set notes
        let item = sections[0].items[0]
        XCTAssertTrue(item.bullets.contains("5 Pull-ups"))
        XCTAssertTrue(item.bullets.contains("10 Push-ups"))
        XCTAssertTrue(item.bullets.contains("Rest remaining time each minute"))
    }
    
    func testTechniqueSegmentWithMinimalPartnerPlan() {
        // Given: A technique segment with partner plan but no attacker/defender goals
        let day = UnifiedDay(
            name: "Technique Development",
            segments: [
                UnifiedSegment(
                    name: "Technique: Hand-fighting → Snap/Threat → Guard Pull",
                    segmentType: "technique",
                    domain: "grappling",
                    durationMinutes: 20,
                    positions: ["standing", "guard"],
                    techniques: [
                        UnifiedTechnique(
                            name: "2-on-1 / collar tie → off-balance → pull to angle",
                            keyDetails: [
                                "Create reaction first",
                                "Pull to outside hip line",
                                "Immediate shin shield entry"
                            ]
                        )
                    ],
                    rounds: 5,
                    roundDurationSeconds: 150,
                    restSeconds: 45
                )
            ]
        )
        
        // When: Formatting the day
        let sections = WhiteboardFormatter.formatDay(day)
        
        // Then: Should create Technique Development section
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].title, "Technique Development")
        XCTAssertEqual(sections[0].items.count, 1)
        
        let item = sections[0].items[0]
        
        // Verify primary line (segment name)
        XCTAssertEqual(item.primary, "Technique: Hand-fighting → Snap/Threat → Guard Pull")
        
        // Verify secondary line includes rounds and duration
        XCTAssertNotNil(item.secondary)
        XCTAssertTrue(item.secondary!.contains("20 min"))
        XCTAssertTrue(item.secondary!.contains("5 rounds"))
        XCTAssertTrue(item.secondary!.contains("2:30"))
        
        // Verify tertiary line includes rest
        XCTAssertNotNil(item.tertiary)
        XCTAssertTrue(item.tertiary!.contains("Rest"))
        XCTAssertTrue(item.tertiary!.contains("0:45"))
        
        // Verify techniques are in bullets
        XCTAssertTrue(item.bullets.contains(where: { $0.contains("2-on-1 / collar tie") }))
        XCTAssertTrue(item.bullets.contains(where: { $0.contains("Create reaction first") }))
    }
}

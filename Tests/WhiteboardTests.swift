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
}

//
//  WhiteboardPreview.swift
//  Savage By Design
//
//  Preview and example usage for Whiteboard View
//

import SwiftUI

#if DEBUG

// MARK: - Preview with Sample Data

struct WhiteboardPreview: View {
    
    private let sampleBlock: Block = {
        // Create a sample DUP (Daily Undulating Periodization) block
        let heavySquatDay = DayTemplate(
            name: "Heavy Squat Day",
            shortCode: "SQ-H",
            goal: .strength,
            exercises: [
                ExerciseTemplate(
                    customName: "Back Squat",
                    type: .strength,
                    category: .squat,
                    notes: "@ RPE 8-9",
                    strengthSets: [
                        StrengthSetTemplate(index: 0, reps: 5, weight: 225, restSeconds: 180),
                        StrengthSetTemplate(index: 1, reps: 5, weight: 225, restSeconds: 180),
                        StrengthSetTemplate(index: 2, reps: 5, weight: 225, restSeconds: 180),
                        StrengthSetTemplate(index: 3, reps: 5, weight: 225, restSeconds: 180),
                        StrengthSetTemplate(index: 4, reps: 5, weight: 225, restSeconds: 180)
                    ],
                    progressionRule: ProgressionRule(type: .weight, deltaWeight: 5.0)
                ),
                ExerciseTemplate(
                    customName: "Romanian Deadlift",
                    type: .strength,
                    category: .hinge,
                    strengthSets: [
                        StrengthSetTemplate(index: 0, reps: 8, weight: 185, restSeconds: 90),
                        StrengthSetTemplate(index: 1, reps: 8, weight: 185, restSeconds: 90),
                        StrengthSetTemplate(index: 2, reps: 8, weight: 185, restSeconds: 90)
                    ],
                    progressionRule: ProgressionRule(type: .weight)
                ),
                ExerciseTemplate(
                    customName: "Leg Curls",
                    type: .strength,
                    category: .other,
                    strengthSets: [
                        StrengthSetTemplate(index: 0, reps: 12, weight: 90, restSeconds: 60),
                        StrengthSetTemplate(index: 1, reps: 12, weight: 90, restSeconds: 60),
                        StrengthSetTemplate(index: 2, reps: 12, weight: 90, restSeconds: 60)
                    ],
                    progressionRule: ProgressionRule(type: .volume)
                )
            ]
        )
        
        let conditioningDay = DayTemplate(
            name: "Conditioning Day",
            shortCode: "COND",
            goal: .conditioning,
            exercises: [
                ExerciseTemplate(
                    customName: "Metcon",
                    type: .conditioning,
                    conditioningType: .amrap,
                    notes: "10 Burpees, 15 KB Swings (53/35), 20 Box Jumps (24/20)",
                    conditioningSets: [
                        ConditioningSetTemplate(
                            index: 0,
                            durationSeconds: 1200
                        )
                    ],
                    progressionRule: ProgressionRule(type: .custom)
                ),
                ExerciseTemplate(
                    customName: "Row Intervals",
                    type: .conditioning,
                    conditioningType: .intervals,
                    notes: "Hard effort",
                    conditioningSets: [
                        ConditioningSetTemplate(
                            index: 0,
                            durationSeconds: 120,
                            rounds: 8,
                            effortDescriptor: "hard",
                            restSeconds: 60
                        )
                    ],
                    progressionRule: ProgressionRule(type: .custom)
                )
            ]
        )
        
        let volumeDay = DayTemplate(
            name: "Volume Squat Day",
            shortCode: "SQ-V",
            goal: .hypertrophy,
            exercises: [
                ExerciseTemplate(
                    customName: "Front Squat",
                    type: .strength,
                    category: .squat,
                    notes: "@ RPE 7",
                    strengthSets: [
                        StrengthSetTemplate(index: 0, reps: 8, weight: 185, restSeconds: 120),
                        StrengthSetTemplate(index: 1, reps: 8, weight: 185, restSeconds: 120),
                        StrengthSetTemplate(index: 2, reps: 8, weight: 185, restSeconds: 120),
                        StrengthSetTemplate(index: 3, reps: 8, weight: 185, restSeconds: 120)
                    ],
                    progressionRule: ProgressionRule(type: .weight, deltaWeight: 2.5)
                ),
                ExerciseTemplate(
                    customName: "Bulgarian Split Squats",
                    type: .strength,
                    category: .other,
                    strengthSets: [
                        StrengthSetTemplate(index: 0, reps: 10, weight: 40, restSeconds: 75),
                        StrengthSetTemplate(index: 1, reps: 10, weight: 40, restSeconds: 75),
                        StrengthSetTemplate(index: 2, reps: 10, weight: 40, restSeconds: 75)
                    ],
                    progressionRule: ProgressionRule(type: .weight)
                )
            ]
        )
        
        return Block(
            name: "Powerlifting DUP Block",
            description: "4-week Daily Undulating Periodization block",
            numberOfWeeks: 2,
            goal: .strength,
            days: [heavySquatDay, conditioningDay, volumeDay]
        )
    }()
    
    var body: some View {
        NavigationView {
            WhiteboardWeekView(
                unifiedBlock: BlockNormalizer.normalize(block: sampleBlock)
            )
            .navigationTitle("Whiteboard Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Example: Authoring JSON Usage

struct AuthoringJSONExample {
    static let sampleJSON = """
    {
      "Title": "CrossFit Metcon Block",
      "Goal": "conditioning",
      "NumberOfWeeks": 4,
      "Days": [
        {
          "name": "Monday - AMRAP",
          "shortCode": "MON",
          "exercises": [
            {
              "name": "Fran",
              "type": "conditioning",
              "conditioningType": "roundsForTime",
              "rounds": 3,
              "notes": "21-15-9 Thrusters (95/65), Pull-ups"
            }
          ]
        },
        {
          "name": "Wednesday - EMOM",
          "shortCode": "WED",
          "exercises": [
            {
              "name": "EMOM 12",
              "type": "conditioning",
              "conditioningType": "emom",
              "durationSeconds": 720,
              "notes": "Min 1: 10 Box Jumps, Min 2: 15 Wall Balls, Min 3: 20 Double Unders"
            }
          ]
        }
      ]
    }
    """
    
    static func parseAndDisplay() -> UnifiedBlock? {
        guard let jsonData = sampleJSON.data(using: .utf8),
              let authoringBlock = try? JSONDecoder().decode(AuthoringBlock.self, from: jsonData) else {
            return nil
        }
        
        return BlockNormalizer.normalize(authoringBlock: authoringBlock)
    }
}

// MARK: - Xcode Preview

struct WhiteboardPreview_Previews: PreviewProvider {
    static var previews: some View {
        WhiteboardPreview()
            .previewDisplayName("Whiteboard View")
    }
}

#endif

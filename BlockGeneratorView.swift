//
//  BlockGeneratorView.swift
//  Savage By Design – Block JSON Import UI
//
//  User interface for importing blocks from JSON files.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Block Importer View

struct BlockGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    
    @EnvironmentObject private var blocksRepository: BlocksRepository
    @EnvironmentObject private var sessionsRepository: SessionsRepository
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    // MARK: - Constants
    
    private let confirmationDisplayDuration: TimeInterval = 2.0
    
    // MARK: - State
    
    @State private var showingFileImporter: Bool = false
    @State private var importedBlock: Block?
    @State private var errorMessage: String?
    @State private var showCopyConfirmation: Bool = false
    @State private var hideConfirmationTask: DispatchWorkItem?
    @State private var pastedJSON: String = ""
    @State private var showingPaywall: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if subscriptionManager.isSubscribed {
                mainContent
            } else {
                lockedContent
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(subscriptionManager)
        }
    }
    
    // MARK: - Main Content (Pro Users)
    
    private var mainContent: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header
                    
                    headerSection
                    
                    // MARK: - Import JSON Section
                    
                    importJSONSection
                    
                    // MARK: - Block Preview
                    
                    if let block = importedBlock {
                        blockPreviewSection(block: block)
                    }
                    
                    // MARK: - Error Display
                    
                    if let error = errorMessage {
                        errorSection(message: error)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(backgroundColor.ignoresSafeArea())
            .navigationTitle("Import Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result: result)
            }
            .overlay(
                Group {
                    if showCopyConfirmation {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                Text("Copied to clipboard!")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .padding(.bottom, 50)
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: showCopyConfirmation)
                    }
                }
            )
        }
    }
    
    // MARK: - Locked Content (Free Users)
    
    private var lockedContent: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 60))
                    .foregroundColor(theme.mutedText)
                
                Text("Pro Feature")
                    .font(.system(size: 28, weight: .bold))
                
                Text("AI-assisted plan ingestion is a Pro feature. Subscribe to import and parse workout plans from JSON.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(theme.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Button {
                    showingPaywall = true
                } label: {
                    Text(subscriptionManager.isEligibleForTrial ? "Start 15-Day Free Trial" : "Subscribe Now")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [theme.premiumGradientStart, theme.premiumGradientEnd]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: theme.premiumGradientStart.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .background(backgroundColor.ignoresSafeArea())
            .navigationTitle("Import Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Import Workout Block")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            Text("Import a training block from a JSON file. You can generate JSON files using ChatGPT, Claude, or any other AI assistant. See AI prompt assistance below.")
                .font(.system(size: 14))
                .foregroundColor(theme.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var importJSONSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import JSON")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            Text("The JSON should contain a training block with exercises, sets, reps, and other training parameters. You can either paste JSON directly or upload a file. After parsing or uploading, scroll to the bottom to preview the block.")
                .font(.system(size: 14))
                .foregroundColor(theme.mutedText)
            
            // Paste JSON Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Option 1: Paste JSON")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                
                TextEditor(text: $pastedJSON)
                    .font(.system(size: 12, design: .monospaced))
                    .frame(minHeight: 150, maxHeight: 200)
                    .padding(8)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.separator), lineWidth: 1)
                    )
                
                Button {
                    parseJSONFromText()
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                        Text("Parse JSON")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(pastedJSON.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : theme.accent)
                    .cornerRadius(12)
                }
                .disabled(pastedJSON.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            Text("OR")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.mutedText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            
            // Upload File Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Option 2: Upload JSON File")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                
                Button {
                    showingFileImporter = true
                } label: {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("Choose JSON File")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(theme.accent)
                    .cornerRadius(12)
                }
            }
            
            Divider()
            
            // AI Prompt Template Section
            aiPromptTemplateSection
            
            Divider()
            
            // JSON Format Example
            jsonFormatExampleSection
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    // MARK: - AI Prompt Template Section
    
    private var aiPromptTemplateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI Prompt Template")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                
                Spacer()
                
                Button {
                    copyToClipboard(aiPromptTemplate)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(theme.accent)
                    .cornerRadius(6)
                }
            }
            
            Text("Copy this template and paste it into ChatGPT, Claude, or any AI assistant. Then add your specific workout requirements at the bottom.")
                .font(.system(size: 12))
                .foregroundColor(theme.mutedText)
            
            ScrollView(.horizontal, showsIndicators: true) {
                Text(aiPromptTemplate)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(theme.mutedText)
                    .padding(12)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 150)
        }
    }
    
    // MARK: - JSON Format Example Section
    
    private var jsonFormatExampleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("JSON Format Example")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                
                Spacer()
                
                Button {
                    copyToClipboard(jsonFormatExample)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(theme.accent)
                    .cornerRadius(6)
                }
            }
            
            Text("This is the expected format. All fields are required. Save as .json file.")
                .font(.system(size: 12))
                .foregroundColor(theme.mutedText)
            
            ScrollView(.horizontal, showsIndicators: true) {
                Text(jsonFormatExample)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(theme.mutedText)
                    .padding(12)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 200)
        }
    }
    
    private func blockPreviewSection(block: Block) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Block Preview")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            VStack(alignment: .leading, spacing: 12) {
                // Block name
                HStack {
                    Text("Name:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.mutedText)
                    Text(block.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(primaryTextColor)
                }
                
                // Description
                if let description = block.description {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(theme.mutedText)
                }
                
                // Stats
                HStack(spacing: 16) {
                    Label("\(block.days.count) day(s)", systemImage: "calendar")
                        .font(.system(size: 14))
                        .foregroundColor(theme.mutedText)
                    
                    Label("\(block.numberOfWeeks) week(s)", systemImage: "calendar.badge.clock")
                        .font(.system(size: 14))
                        .foregroundColor(theme.mutedText)
                }
                
                // Exercise count
                if let firstDay = block.days.first {
                    Label("\(firstDay.exercises.count) exercise(s)", systemImage: "figure.strengthtraining.traditional")
                        .font(.system(size: 14))
                        .foregroundColor(theme.mutedText)
                }
                
                Divider()
                
                // Save button
                Button {
                    saveBlock(block)
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Block to Library")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(theme.success)
                    .cornerRadius(12)
                    .shadow(color: theme.success.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func errorSection(message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(theme.error)
                Text("Error")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(theme.error)
            }
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(primaryTextColor)
        }
        .padding()
        .background(theme.error.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Template Strings
    
    private var aiPromptTemplate: String {
        """
        I need you to generate a workout block in JSON format for the Savage By Design workout tracker app.
        
        MY REQUIREMENTS:
        [Describe your training goals, experience level, available equipment, time constraints, and specific exercises/activities you want.]
        
        IMPORTANT - JSON Format Specification:
        - The file MUST be valid JSON with proper syntax (commas, quotes, brackets)
        - All BLOCK-LEVEL fields are REQUIRED (Title, Goal, TargetAthlete, DurationMinutes, etc.)
        - You can structure Days with EXERCISES (sets/reps/weight gym work) or SEGMENTS (technique-focused classes) or BOTH
        - You must provide ONE OF: "Exercises" (single-day), "Days" (multi-day), OR "Weeks" (week-specific)
        - Save output as a .json file: [BlockName]_[Weeks]W_[Days]D.json
        - Example: UpperLower_4W_4D.json or BJJ_Class_1W_1D.json
        
        ⚠️ NOTE: Segment import support is currently limited. Segments in JSON will be parsed but not imported.
        For full segment support (BJJ, yoga, etc.), use the whiteboard authoring feature after import or focus on exercise-based blocks.
        
        ═══════════════════════════════════════════════════════════════
        CHOOSING BETWEEN EXERCISES vs SEGMENTS:
        ═══════════════════════════════════════════════════════════════
        
        Use EXERCISES for:
        - Traditional gym workouts (sets, reps, weights)
        - Strength training with progressive overload
        - Conditioning workouts with time/distance/calories
        
        Use SEGMENTS for:
        - Martial arts classes (BJJ, wrestling, judo, MMA)
        - Yoga and mobility sessions
        - Skill-based training with technique instruction
        - Drills with specific constraints and coaching cues
        - Sessions structured by phases (warmup, technique, drilling, sparring, cooldown)
        
        Use BOTH in same Day when:
        - Combining strength work with skill training
        - Gym session followed by technique work
        
        ═══════════════════════════════════════════════════════════════
        COMPLETE JSON Structure (ALL FIELDS AVAILABLE):
        ═══════════════════════════════════════════════════════════════
        {
          "Title": "Block name (under 50 characters)",
          "Goal": "Primary training objective (strength/hypertrophy/power/conditioning/mixed/peaking/deload/rehab)",
          "TargetAthlete": "Experience level (Beginner/Intermediate/Advanced)",
          "NumberOfWeeks": <number: total weeks in block> [OPTIONAL, defaults to 1],
          "DurationMinutes": <number: estimated workout duration per session>,
          "Difficulty": <number: 1-5 scale>,
          "Equipment": "Comma-separated equipment list",
          "WarmUp": "Detailed warm-up instructions",
          "Finisher": "Cooldown or finisher instructions",
          "Notes": "Important context, form cues, safety notes",
          "EstimatedTotalTimeMinutes": <number: total session time including warm-up/finisher>,
          "Progression": "Week-to-week progression strategy",
          
          // OPTION A: Single-Day Block (use "Exercises")
          "Exercises": [
            {
              "name": "Exercise name",
              "type": "strength|conditioning|mixed|other" [OPTIONAL, defaults to "strength"],
              "category": "squat|hinge|pressHorizontal|pressVertical|pullHorizontal|pullVertical|carry|core|olympic|conditioning|mobility|mixed|other" [OPTIONAL],
              
              // SIMPLE FORMAT (for quick blocks):
              "setsReps": "3x8" [OPTIONAL if using "sets" array],
              "restSeconds": 120 [OPTIONAL],
              "intensityCue": "RPE 7" [OPTIONAL],
              
              // ADVANCED FORMAT (for detailed programming):
              "sets": [ [OPTIONAL - replaces "setsReps"]
                {
                  "reps": 8,
                  "weight": 135.0 [OPTIONAL],
                  "percentageOfMax": 0.75 [OPTIONAL - 0.0 to 1.0],
                  "rpe": 7.5 [OPTIONAL - 1.0 to 10.0],
                  "rir": 2.5 [OPTIONAL - reps in reserve],
                  "tempo": "3-0-1-0" [OPTIONAL],
                  "restSeconds": 180 [OPTIONAL],
                  "notes": "Focus on depth" [OPTIONAL]
                }
              ],
              
              // CONDITIONING PARAMETERS:
              "conditioningType": "monostructural|mixedModal|emom|amrap|intervals|forTime|forDistance|forCalories|roundsForTime|other" [OPTIONAL],
              "conditioningSets": [ [OPTIONAL]
                {
                  "durationSeconds": 300 [OPTIONAL],
                  "distanceMeters": 1000.0 [OPTIONAL],
                  "calories": 20.0 [OPTIONAL],
                  "rounds": 5 [OPTIONAL],
                  "targetPace": "2:00/500m" [OPTIONAL],
                  "effortDescriptor": "moderate" [OPTIONAL],
                  "restSeconds": 60 [OPTIONAL],
                  "notes": "Maintain steady pace" [OPTIONAL]
                }
              ],
              
              // SUPERSET/CIRCUIT GROUPING:
              "setGroupId": "UUID-string" [OPTIONAL],
              "setGroupKind": "superset|circuit|giantSet|emom|amrap" [OPTIONAL],
              
              // PROGRESSION:
              "progressionType": "weight|volume|custom|skill" [OPTIONAL, defaults to "weight"],
              "progressionDeltaWeight": 5.0 [OPTIONAL],
              "progressionDeltaSets": 1 [OPTIONAL],
              
              "notes": "Exercise-specific notes" [OPTIONAL]
            }
          ],
          
          // OPTION B: Multi-Day Block (use "Days")
          "Days": [ [OPTIONAL - same days repeated for all weeks]
            {
              "name": "Day 1: Upper Body",
              "shortCode": "U1" [OPTIONAL],
              "goal": "strength|hypertrophy|power|conditioning|mixed" [OPTIONAL],
              "notes": "Focus on compound movements" [OPTIONAL],
              
              // GYM WORK - Use exercises array:
              "exercises": [
                // Same exercise structure as above
              ],
              
              // SKILL/TECHNIQUE WORK - Use segments array:
              "segments": [
                {
                  "name": "Warm-up & Movement Drills",  // Or "Technique: Guard Basics", "Live Rolling", etc.
                  "segmentType": "warmup|mobility|technique|drill|positionalSpar|rolling|cooldown|lecture|breathwork|other",
                  "domain": "grappling|yoga|strength|conditioning|mobility|other" [OPTIONAL],
                  "durationMinutes": 15 [OPTIONAL],
                  "objective": "Clear learning objective" [OPTIONAL],
                  
                  // POSITIONS & TECHNIQUES (for martial arts):
                  "positions": ["standing", "guard", "mount", etc.] [OPTIONAL],
                  "techniques": [ [OPTIONAL]
                    {
                      "name": "Technique name",
                      "variant": "Style variation" [OPTIONAL],
                      "keyDetails": ["Key point 1", "Key point 2"],
                      "commonErrors": ["Error 1", "Error 2"],
                      "counters": ["Counter 1"],
                      "followUps": ["Follow-up 1"]
                    }
                  ],
                  
                  // DRILLING STRUCTURE:
                  "drillPlan": { [OPTIONAL - for warmup drills]
                    "items": [
                      {
                        "name": "Drill name",
                        "workSeconds": 60,
                        "restSeconds": 15,
                        "notes": "Coaching point"
                      }
                    ]
                  },
                  
                  // PARTNER WORK:
                  "partnerPlan": { [OPTIONAL - for technique practice]
                    "rounds": 3,
                    "roundDurationSeconds": 180,
                    "restSeconds": 60,
                    "roles": {
                      "attackerGoal": "Complete technique",
                      "defenderGoal": "Provide resistance",
                      "resistance": 25 [0-100 scale],
                      "switchEverySeconds": 90
                    },
                    "qualityTargets": {
                      "cleanRepsTarget": 10,
                      "successRateTarget": 0.8,
                      "decisionSpeedSeconds": 2.5
                    }
                  },
                  
                  // LIVE ROUNDS:
                  "roundPlan": { [OPTIONAL - for sparring]
                    "rounds": 5,
                    "roundDurationSeconds": 300,
                    "restSeconds": 60,
                    "intensityCue": "moderate|hard|live",
                    "resetRule": "Reset on score/submission",
                    "winConditions": ["Submission", "Points"]
                  },
                  
                  // POSITIONAL SPARRING:
                  "startPosition": "guard" [OPTIONAL],
                  "scoring": { [OPTIONAL]
                    "attackerScoresIf": ["Sweep", "Submission"],
                    "defenderScoresIf": ["Pass guard", "Escape"]
                  },
                  
                  // YOGA/MOBILITY:
                  "flowSequence": [ [OPTIONAL]
                    {
                      "poseName": "Downward Dog",
                      "holdSeconds": 30,
                      "transitionCue": "Flow to plank"
                    }
                  ],
                  "intensityScale": "restorative|easy|moderate|strong|peak" [OPTIONAL],
                  "holdSeconds": 30 [OPTIONAL],
                  "breathCount": 5 [OPTIONAL],
                  "props": ["block", "strap", "bolster"] [OPTIONAL],
                  
                  // BREATHWORK:
                  "breathwork": { [OPTIONAL]
                    "style": "Box breathing",
                    "pattern": "4s inhale / 4s hold / 4s exhale / 4s hold",
                    "durationSeconds": 300
                  },
                  
                  // COACHING & SAFETY:
                  "constraints": ["Constraint 1", "Constraint 2"] [OPTIONAL],
                  "coachingCues": ["Cue 1", "Cue 2"] [OPTIONAL],
                  "safety": { [OPTIONAL]
                    "contraindications": ["No slamming"],
                    "stopIf": ["Sharp pain", "Dizziness"],
                    "intensityCeiling": "75%"
                  },
                  "notes": "Additional notes" [OPTIONAL]
                }
              ]
            }
          ],
          
          // OPTION C: Week-Specific Block (for periodization)
          "Weeks": [ [OPTIONAL - different days for each week]
            [
              // Week 1 days
              {
                "name": "Day 1",
                "exercises": [...],  // Can use exercises
                "segments": [...]    // OR segments OR both
              }
            ],
            [
              // Week 2 days (can differ from Week 1)
              {"name": "Day 1", "exercises": [...]}
            ]
          ]
        }
        
        ═══════════════════════════════════════════════════════════════
        USAGE GUIDELINES:
        ═══════════════════════════════════════════════════════════════
        
        FOR GYM WORKOUTS (EXERCISES):
        1. SIMPLE blocks: Use "Exercises" with "setsReps" format
        2. MULTI-DAY blocks: Use "Days" with detailed "sets" arrays
        3. WEEK-SPECIFIC: Use "Weeks" array for exercise variations
        4. CONDITIONING: Set type="conditioning" and use "conditioningSets"
        5. SUPERSETS: Give exercises same "setGroupId" UUID
        
        FOR SKILL SESSIONS (SEGMENTS):
        1. BJJ/GRAPPLING: Use technique, drill, positionalSpar, rolling segments
        2. YOGA: Use mobility/warmup segments with flowSequence
        3. BREATHWORK: Use breathwork segment with pattern details
        4. STRUCTURED CLASSES: Organize by segment phases (warmup → technique → drilling → live → cooldown)
        5. QUALITY TRACKING: Use qualityTargets for skill-based progression
        6. CONSTRAINTS: Add specific rules to focus training (e.g., "Must start from inside tie")
        
        HYBRID SESSIONS:
        - Put strength work in "exercises" array
        - Put skill/technique work in "segments" array
        - Both can coexist in the same Day
        """
    }
    
    private var jsonFormatExample: String {
        """
        // EXAMPLE 1: Gym Workout (Exercise-Based)
        {
          "Title": "Full Body Strength",
          "Goal": "strength",
          "TargetAthlete": "Intermediate",
          "NumberOfWeeks": 4,
          "DurationMinutes": 45,
          "Difficulty": 3,
          "Equipment": "Barbell, Dumbbells, Rack",
          "WarmUp": "5 min dynamic stretching",
          "Exercises": [
            {
              "name": "Barbell Back Squat",
              "type": "strength",
              "category": "squat",
              "setsReps": "3x8",
              "restSeconds": 180,
              "intensityCue": "RPE 7",
              "progressionDeltaWeight": 5.0
            },
            {
              "name": "Barbell Bench Press",
              "type": "strength",
              "category": "pressHorizontal",
              "sets": [
                {"reps": 8, "weight": 135, "rpe": 7, "restSeconds": 120},
                {"reps": 8, "weight": 135, "rpe": 7.5, "restSeconds": 120},
                {"reps": 8, "weight": 135, "rpe": 8, "restSeconds": 120}
              ],
              "progressionDeltaWeight": 5.0
            }
          ],
          "Finisher": "10 min cooldown",
          "Notes": "Focus on form. Deload week 4.",
          "EstimatedTotalTimeMinutes": 45,
          "Progression": "Add 5 lbs per week, deload week 4"
        }
        
        // EXAMPLE 2: BJJ Class (Segment-Based)
        {
          "Title": "BJJ Fundamentals Class",
          "Goal": "mixed",
          "TargetAthlete": "Beginner",
          "NumberOfWeeks": 1,
          "DurationMinutes": 60,
          "Difficulty": 3,
          "Equipment": "Grappling mats, gi, training partners",
          "WarmUp": "See segments",
          "Days": [
            {
              "name": "Class: Guard Retention Basics",
              "shortCode": "BJJ1",
              "goal": "mixed",
              "segments": [
                {
                  "name": "Warm-up & Movement Drills",
                  "segmentType": "warmup",
                  "domain": "grappling",
                  "durationMinutes": 10,
                  "objective": "Prepare body for training",
                  "drillPlan": {
                    "items": [
                      {"name": "Hip escapes", "workSeconds": 60, "restSeconds": 15},
                      {"name": "Technical standup", "workSeconds": 60, "restSeconds": 15}
                    ]
                  }
                },
                {
                  "name": "Technique: Closed Guard Basics",
                  "segmentType": "technique",
                  "domain": "grappling",
                  "durationMinutes": 20,
                  "objective": "Learn closed guard structure and basic sweep",
                  "positions": ["closed_guard"],
                  "techniques": [
                    {
                      "name": "Closed guard posture break",
                      "keyDetails": ["Break posture with legs", "Control head", "Create angle"],
                      "commonErrors": ["Opening guard too early", "Not controlling head"]
                    }
                  ],
                  "partnerPlan": {
                    "rounds": 4,
                    "roundDurationSeconds": 180,
                    "restSeconds": 60,
                    "roles": {
                      "attackerGoal": "Break posture and attempt sweep",
                      "defenderGoal": "Maintain posture with light resistance"
                    },
                    "resistance": 30,
                    "switchEverySeconds": 90,
                    "qualityTargets": {
                      "cleanRepsTarget": 8,
                      "successRateTarget": 0.7
                    }
                  }
                },
                {
                  "name": "Positional Sparring",
                  "segmentType": "positionalSpar",
                  "domain": "grappling",
                  "durationMinutes": 15,
                  "objective": "Apply techniques under pressure",
                  "startPosition": "closed_guard",
                  "roundPlan": {
                    "rounds": 5,
                    "roundDurationSeconds": 180,
                    "restSeconds": 30,
                    "intensityCue": "moderate"
                  },
                  "scoring": {
                    "attackerScoresIf": ["Sweep to top", "Submit"],
                    "defenderScoresIf": ["Pass guard", "Stand up"]
                  }
                },
                {
                  "name": "Cooldown",
                  "segmentType": "cooldown",
                  "domain": "mobility",
                  "durationMinutes": 5,
                  "breathwork": {
                    "style": "Box breathing",
                    "pattern": "4s inhale / 4s hold / 4s exhale / 4s hold",
                    "durationSeconds": 300
                  }
                }
              ]
            }
          ],
          "Finisher": "See cooldown segment",
          "Notes": "Focus on fundamentals and safety",
          "EstimatedTotalTimeMinutes": 60,
          "Progression": "Increase resistance 10% per week, add constraints"
        }
        
        // EXAMPLE 3: Hybrid Session (Exercises + Segments)
        {
          "Title": "Strength + Yoga Recovery",
          "Goal": "mixed",
          "TargetAthlete": "Intermediate",
          "NumberOfWeeks": 1,
          "DurationMinutes": 60,
          "Difficulty": 3,
          "Equipment": "Barbell, yoga mat, blocks",
          "Days": [
            {
              "name": "Upper Body + Mobility",
              "exercises": [
                {
                  "name": "Bench Press",
                  "setsReps": "3x8",
                  "restSeconds": 180
                },
                {
                  "name": "Pull-ups",
                  "setsReps": "3x10",
                  "restSeconds": 120
                }
              ],
              "segments": [
                {
                  "name": "Restorative Yoga Flow",
                  "segmentType": "mobility",
                  "domain": "yoga",
                  "durationMinutes": 20,
                  "intensityScale": "easy",
                  "flowSequence": [
                    {"poseName": "Child's Pose", "holdSeconds": 60},
                    {"poseName": "Cat-Cow", "holdSeconds": 45},
                    {"poseName": "Downward Dog", "holdSeconds": 60}
                  ],
                  "props": ["block", "strap"]
                }
              ]
            }
          ],
          "WarmUp": "5 min general",
          "Finisher": "See segments",
          "Notes": "Strength work first, then mobility",
          "EstimatedTotalTimeMinutes": 60,
          "Progression": "Add weight to strength, extend holds in yoga"
        }
        """
    }
    
    // MARK: - Actions
    
    private func parseJSONFromText() {
        let trimmedJSON = pastedJSON.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedJSON.isEmpty else {
            errorMessage = "Please paste JSON content"
            return
        }
        
        guard let data = trimmedJSON.data(using: .utf8) else {
            errorMessage = "Failed to convert text to data"
            return
        }
        
        parseJSONData(data)
    }
    
    private func parseJSONData(_ data: Data) {
        // Clear previous state
        importedBlock = nil
        errorMessage = nil
        
        do {
            let decoder = JSONDecoder()
            let imported = try decoder.decode(ImportedBlock.self, from: data)
            let block = BlockGenerator.convertToBlock(imported, numberOfWeeks: 1)
            importedBlock = block
            errorMessage = nil
        } catch let decodingError as DecodingError {
            errorMessage = "Invalid JSON format: \(formatDecodingError(decodingError))"
        } catch {
            errorMessage = "Failed to parse JSON: \(error.localizedDescription)"
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        
        // Cancel any existing hide task
        hideConfirmationTask?.cancel()
        
        // Show confirmation feedback
        showCopyConfirmation = true
        
        // Hide confirmation after configured duration
        let task = DispatchWorkItem {
            showCopyConfirmation = false
        }
        hideConfirmationTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + confirmationDisplayDuration, execute: task)
    }
    
    private func saveBlock(_ block: Block) {
        blocksRepository.add(block)
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        for session in sessions {
            sessionsRepository.add(session)
        }
        
        dismiss()
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                errorMessage = "No file selected"
                return
            }
            
            // Security-scoped resource access
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Failed to access file. Please try again."
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let data = try Data(contentsOf: url)
                parseJSONData(data)
            } catch {
                errorMessage = "Failed to read file: \(error.localizedDescription)"
            }
            
        case .failure(let error):
            errorMessage = "File selection error: \(error.localizedDescription)"
        }
    }
    
    private func formatDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .keyNotFound(let key, _):
            return "Missing required field: \(key.stringValue)"
        case .typeMismatch(let type, let context):
            return "Type mismatch at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): expected \(type)"
        case .valueNotFound(let type, let context):
            return "Missing value at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): expected \(type)"
        case .dataCorrupted(let context):
            return "Data corrupted: \(context.debugDescription)"
        @unknown default:
            return "Unknown decoding error"
        }
    }
    
    // MARK: - Theme Colors
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color(UIColor.systemGray6)
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemGray6).opacity(0.3) : Color.white
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
}

// MARK: - Preview

struct BlockGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        BlockGeneratorView()
            .environmentObject(BlocksRepository())
            .environmentObject(SessionsRepository())
    }
}

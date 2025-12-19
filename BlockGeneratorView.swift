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
    
    // MARK: - Constants
    
    private let documentationURL = "https://github.com/kje7713-dev/WorkoutTrackerApp/blob/main/BLOCK_JSON_IMPORT_README.md"
    private let confirmationDisplayDuration: TimeInterval = 2.0
    
    // MARK: - State
    
    @State private var showingFileImporter: Bool = false
    @State private var importedBlock: Block?
    @State private var errorMessage: String?
    @State private var showCopyConfirmation: Bool = false
    @State private var hideConfirmationTask: DispatchWorkItem?
    @State private var pastedJSON: String = ""
    
    // MARK: - Body
    
    var body: some View {
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
            
            Text("The JSON should contain a training block with exercises, sets, reps, and other training parameters. You can either paste JSON directly or upload a file.")
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
            
            // Link to full documentation
            if let docURL = URL(string: documentationURL) {
                Link(destination: docURL) {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("View Complete Documentation & Examples")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(theme.accent)
                }
                .padding(.top, 8)
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
                    .background(Color.blue)
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
                    .background(Color.blue)
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
                    .background(Color.green)
                    .cornerRadius(12)
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
                    .foregroundColor(.red)
                Text("Error")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.red)
            }
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(primaryTextColor)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Template Strings
    
    private var aiPromptTemplate: String {
        """
        I need you to generate a workout block in JSON format for the Savage By Design workout tracker app.
        
        MY REQUIREMENTS:
        [Describe your training goals, experience level, available equipment, time constraints, and specific exercises you want]
        
        IMPORTANT - JSON Format Specification:
        - The file MUST be valid JSON with proper syntax (commas, quotes, brackets)
        - All BLOCK-LEVEL fields are REQUIRED (Title, Goal, TargetAthlete, DurationMinutes, etc.)
        - Exercise fields vary: name is required, others marked [OPTIONAL] are truly optional
        - You must provide ONE OF: "Exercises" (single-day), "Days" (multi-day), OR "Weeks" (week-specific)
        - Save output as a .json file: [BlockName]_[Weeks]W_[Days]D.json
        - Example: UpperLower_4W_4D.json or Strength_8W_3D.json
        
        COMPLETE JSON Structure (ALL FIELDS AVAILABLE):
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
          "Progression": "Week-to-week progression strategy (e.g., 'Add 5 lbs per week, deload week 4')",
          
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
                  "weight": 135.0 [OPTIONAL - pounds or kg],
                  "percentageOfMax": 0.75 [OPTIONAL - 0.0 to 1.0, e.g., 0.75 = 75%],
                  "rpe": 7.5 [OPTIONAL - 1.0 to 10.0],
                  "rir": 2.5 [OPTIONAL - reps in reserve],
                  "tempo": "3-0-1-0" [OPTIONAL - eccentric-pause-concentric-pause],
                  "restSeconds": 180 [OPTIONAL],
                  "notes": "Focus on depth" [OPTIONAL]
                }
              ],
              
              // CONDITIONING PARAMETERS (for type: "conditioning"):
              "conditioningType": "monostructural|mixedModal|emom|amrap|intervals|forTime|forDistance|forCalories|roundsForTime|other" [OPTIONAL],
              "conditioningSets": [ [OPTIONAL - for conditioning exercises]
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
              "setGroupId": "UUID-string" [OPTIONAL - same ID for exercises in a superset/circuit],
              "setGroupKind": "superset|circuit|giantSet|emom|amrap" [OPTIONAL],
              
              // PROGRESSION:
              "progressionType": "weight|volume|custom" [OPTIONAL, defaults to "weight"],
              "progressionDeltaWeight": 5.0 [OPTIONAL - lbs to add per week],
              "progressionDeltaSets": 1 [OPTIONAL - sets to add per week],
              
              "notes": "Exercise-specific notes" [OPTIONAL]
            }
          ],
          
          // OPTION B: Multi-Day Block (use "Days" instead of "Exercises")
          "Days": [ [OPTIONAL - same days repeated for all weeks]
            {
              "name": "Day 1: Upper Body",
              "shortCode": "U1" [OPTIONAL],
              "goal": "strength|hypertrophy|power|conditioning|mixed" [OPTIONAL],
              "notes": "Focus on compound movements" [OPTIONAL],
              "exercises": [
                // Same exercise structure as above
              ]
            },
            {
              "name": "Day 2: Lower Body",
              "shortCode": "L1" [OPTIONAL],
              "goal": "strength",
              "exercises": [...]
            }
          ],
          
          // OPTION C: Week-Specific Block (NEW - for exercise variations across weeks)
          "Weeks": [ [OPTIONAL - different days for each week]
            [
              // Week 1 days
              {
                "name": "Day 1: Heavy Squat",
                "shortCode": "L1",
                "goal": "strength",
                "exercises": [
                  {"name": "Back Squat", "setsReps": "5x5", "restSeconds": 240, "intensityCue": "RPE 8"}
                ]
              },
              {
                "name": "Day 2: Heavy Bench",
                "shortCode": "U1",
                "exercises": [...]
              }
            ],
            [
              // Week 2 days (can have different exercises!)
              {
                "name": "Day 1: Heavy Squat",
                "shortCode": "L1",
                "goal": "strength",
                "exercises": [
                  {"name": "Back Squat", "setsReps": "5x3", "restSeconds": 240, "intensityCue": "RPE 9"}
                ]
              },
              {
                "name": "Day 2: Heavy Bench",
                "exercises": [...]
              }
            ],
            [
              // Week 3 days (different exercises possible)
              {
                "name": "Day 1: Front Squat Variation",
                "shortCode": "L1",
                "goal": "strength",
                "exercises": [
                  {"name": "Front Squat", "setsReps": "4x6", "restSeconds": 180, "intensityCue": "RPE 8"}
                ]
              }
            ]
          ]
        }
        
        USAGE GUIDELINES:
        1. For SIMPLE blocks: Use "Exercises" with "setsReps" format
        2. For MULTI-DAY blocks (same all weeks): Use "Days" with detailed "sets" arrays
        3. For WEEK-SPECIFIC variations: Use "Weeks" array (NEW - allows different exercises each week!)
        4. For MULTI-WEEK blocks: Set "NumberOfWeeks" (e.g., 4, 8, 12)
        5. For CONDITIONING: Set type="conditioning" and use "conditioningSets"
        6. For SUPERSETS: Give exercises same "setGroupId" UUID
        7. Specify WEIGHT when known (helps with progression tracking)
        8. Use "Weeks" format for PERIODIZATION with exercise variations (e.g., deload weeks, exercise rotations)
        """
    }
    
    private var jsonFormatExample: String {
        """
        // EXAMPLE 1: Simple Single-Day Block
        {
          "Title": "Full Body Strength",
          "Goal": "Build foundational strength",
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
          "Finisher": "10 min cooldown stretch",
          "Notes": "Focus on form. Deload week 4.",
          "EstimatedTotalTimeMinutes": 45,
          "Progression": "Add 5 lbs per week, deload week 4"
        }
        
        // EXAMPLE 2: Multi-Day Block with Conditioning
        {
          "Title": "Upper/Lower Split",
          "Goal": "Build strength and work capacity",
          "TargetAthlete": "Advanced",
          "NumberOfWeeks": 8,
          "DurationMinutes": 60,
          "Difficulty": 4,
          "Equipment": "Full gym, rowing machine",
          "WarmUp": "10 min general warm-up",
          "Days": [
            {
              "name": "Day 1: Upper",
              "shortCode": "U1",
              "goal": "strength",
              "exercises": [
                {
                  "name": "Bench Press",
                  "type": "strength",
                  "category": "pressHorizontal",
                  "sets": [
                    {"reps": 5, "weight": 185, "percentageOfMax": 0.80, "rpe": 8, "restSeconds": 240}
                  ],
                  "progressionDeltaWeight": 5.0
                },
                {
                  "name": "Rowing Intervals",
                  "type": "conditioning",
                  "conditioningType": "intervals",
                  "conditioningSets": [
                    {"durationSeconds": 120, "distanceMeters": 500, "targetPace": "1:50/500m", "restSeconds": 60}
                  ]
                }
              ]
            },
            {
              "name": "Day 2: Lower",
              "shortCode": "L1",
              "goal": "strength",
              "exercises": [
                {
                  "name": "Back Squat",
                  "type": "strength",
                  "category": "squat",
                  "sets": [
                    {"reps": 5, "weight": 225, "rpe": 8, "tempo": "3-0-1-0", "restSeconds": 300}
                  ]
                }
              ]
            }
          ],
          "Finisher": "Mobility work",
          "Notes": "Progressive overload each week",
          "EstimatedTotalTimeMinutes": 60,
          "Progression": "Linear progression, add 5-10 lbs weekly"
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

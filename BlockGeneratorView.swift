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
            
            Text("Import a training block from a JSON file. You can generate JSON files using ChatGPT, Claude, or any other AI assistant.")
                .font(.system(size: 14))
                .foregroundColor(theme.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var importJSONSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select JSON File")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            Text("The JSON file should contain a training block with exercises, sets, reps, and other training parameters.")
                .font(.system(size: 14))
                .foregroundColor(theme.mutedText)
            
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
        
        IMPORTANT - JSON Format Specification:
        - The file MUST be valid JSON with proper syntax (commas, quotes, brackets)
        - ALL fields listed below are REQUIRED (no optional fields)
        - Save output as a .json file with descriptive name: [BlockName]_[Weeks]W.json
        - Example filename: UpperLower_4W.json or Strength_Intermediate.json
        
        Required JSON Structure:
        {
          "Title": "Block name (under 50 characters)",
          "Goal": "Primary training objective (strength/hypertrophy/power/conditioning/mixed)",
          "TargetAthlete": "Experience level (Beginner/Intermediate/Advanced)",
          "DurationMinutes": <number: estimated workout duration>,
          "Difficulty": <number: 1-5 scale>,
          "Equipment": "Comma-separated equipment list",
          "WarmUp": "Detailed warm-up instructions",
          "Exercises": [
            {
              "name": "Exercise name (be specific: 'Barbell Back Squat' not 'Squat')",
              "setsReps": "SxR format like 3x8, 4x10, 5x5",
              "restSeconds": <number: rest in seconds>,
              "intensityCue": "Coaching cue (RPE 7, RIR 2, 75% 1RM, Tempo 3-0-1-0, etc.)"
            }
          ],
          "Finisher": "Cooldown or finisher instructions",
          "Notes": "Important context, form cues, safety notes, progression details",
          "EstimatedTotalTimeMinutes": <number: total session time>,
          "Progression": "Week-to-week progression strategy (e.g., 'Add 5 lbs per week, deload week 4')"
        }
        
        MY REQUIREMENTS:
        [Describe your training goals, experience level, available equipment, time constraints, and specific exercises you want]
        
        Example requirements:
        - Create a 4-week upper/lower split for intermediate lifter
        - Goal: Build overall strength
        - 60 minutes per session
        - Equipment: Full commercial gym
        - Include RPE-based intensity
        - Progression: Add 5-10 lbs per week, deload week 4
        """
    }
    
    private var jsonFormatExample: String {
        """
        {
          "Title": "Full Body Strength",
          "Goal": "Build foundational strength",
          "TargetAthlete": "Intermediate",
          "DurationMinutes": 45,
          "Difficulty": 3,
          "Equipment": "Barbell, Dumbbells, Rack, Bench",
          "WarmUp": "5 min dynamic stretching, mobility work",
          "Exercises": [
            {
              "name": "Barbell Back Squat",
              "setsReps": "3x8",
              "restSeconds": 180,
              "intensityCue": "RPE 7"
            },
            {
              "name": "Barbell Bench Press",
              "setsReps": "3x8",
              "restSeconds": 120,
              "intensityCue": "RPE 7"
            },
            {
              "name": "Barbell Row",
              "setsReps": "3x8",
              "restSeconds": 120,
              "intensityCue": "RPE 7"
            },
            {
              "name": "Overhead Press",
              "setsReps": "3x10",
              "restSeconds": 90,
              "intensityCue": "RPE 7.5"
            }
          ],
          "Finisher": "10 min cooldown stretch, foam rolling",
          "Notes": "Focus on form over weight. Increase load gradually. Week 4 is deload at 80% intensity.",
          "EstimatedTotalTimeMinutes": 45,
          "Progression": "Add 5 lbs per week on main lifts, deload week 4"
        }
        """
    }
    
    // MARK: - Actions
    
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
        // Clear previous state
        importedBlock = nil
        errorMessage = nil
        
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
                let decoder = JSONDecoder()
                let imported = try decoder.decode(ImportedBlock.self, from: data)
                let block = BlockGenerator.convertToBlock(imported, numberOfWeeks: 1)
                importedBlock = block
                errorMessage = nil
            } catch let decodingError as DecodingError {
                errorMessage = "Invalid JSON format: \(formatDecodingError(decodingError))"
            } catch {
                errorMessage = "Failed to import file: \(error.localizedDescription)"
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

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
    
    // MARK: - State
    
    @State private var showingFileImporter: Bool = false
    @State private var importedBlock: Block?
    @State private var errorMessage: String?
    
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
            
            // JSON Format Example
            VStack(alignment: .leading, spacing: 8) {
                Text("Expected JSON Format")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                
                Text("""
                {
                  "Title": "Block Name",
                  "Goal": "Training objective",
                  "TargetAthlete": "Experience level",
                  "DurationMinutes": 45,
                  "Difficulty": 3,
                  "Equipment": "Available equipment",
                  "WarmUp": "Warm-up description",
                  "Exercises": [
                    {
                      "name": "Exercise name",
                      "setsReps": "3x8",
                      "restSeconds": 180,
                      "intensityCue": "RPE 7"
                    }
                  ],
                  "Finisher": "Finisher description",
                  "Notes": "Additional notes",
                  "EstimatedTotalTimeMinutes": 45,
                  "Progression": "Progression strategy"
                }
                """)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(theme.mutedText)
                .padding(12)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
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
    
    // MARK: - Actions
    
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

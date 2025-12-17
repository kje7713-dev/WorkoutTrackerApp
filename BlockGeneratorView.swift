//
//  BlockGeneratorView.swift
//  Savage By Design – AI Block Generator UI
//
//  User interface for generating blocks via ChatGPT or importing from JSON file.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Block Generator View

struct BlockGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    
    @EnvironmentObject private var blocksRepository: BlocksRepository
    @EnvironmentObject private var sessionsRepository: SessionsRepository
    
    // MARK: - State
    
    @State private var apiKey: String = ""
    @State private var hasAPIKey: Bool = false
    @State private var selectedModel: ChatGPTClient.Model = .gpt35Turbo
    
    // Prompt inputs
    @State private var availableTimeMinutes: String = "45"
    @State private var athleteLevel: String = "Intermediate"
    @State private var focus: String = "Full Body Strength"
    @State private var allowedEquipment: String = "Barbell, Dumbbells, Rack"
    @State private var excludeExercises: String = "None"
    @State private var primaryConstraints: String = "None"
    @State private var goalNotes: String = "Build strength and muscle"
    
    // Generation state
    @State private var isGenerating: Bool = false
    @State private var generatedText: String = ""
    @State private var streamingText: String = ""
    @State private var generatedBlock: Block?
    @State private var errorMessage: String?
    
    // JSON import state
    @State private var showingFileImporter: Bool = false
    @State private var importedBlock: Block?
    
    // Client
    private let chatClient = ChatGPTClient()
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - API Key Section
                    
                    apiKeySection
                    
                    // MARK: - Model Selection
                    
                    if hasAPIKey {
                        modelSelectionSection
                    }
                    
                    // MARK: - Prompt Input Form
                    
                    if hasAPIKey {
                        promptInputSection
                    }
                    
                    // MARK: - Generate Button
                    
                    if hasAPIKey {
                        generateButton
                    }
                    
                    // MARK: - Streaming Output
                    
                    if isGenerating || !streamingText.isEmpty {
                        streamingOutputSection
                    }
                    
                    // MARK: - Generated Block Preview
                    
                    if let block = generatedBlock {
                        blockPreviewSection(block: block)
                    }
                    
                    // MARK: - Error Display
                    
                    if let error = errorMessage {
                        errorSection(message: error)
                    }
                    
                    // MARK: - Import JSON Section
                    
                    importJSONSection
                }
                .padding()
            }
            .background(backgroundColor.ignoresSafeArea())
            .navigationTitle("AI Block Generator")
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
            .onAppear {
                checkForAPIKey()
            }
        }
    }
    
    // MARK: - Sections
    
    private var apiKeySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OpenAI API Key")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            if hasAPIKey {
                HStack {
                    Text("API Key configured ✓")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Button("Update") {
                        showAPIKeyInput()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.accent)
                    
                    Button("Delete") {
                        deleteAPIKey()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    SecureField("Enter API Key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Save API Key") {
                        saveAPIKey()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(theme.accent)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private var modelSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Model Selection")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            Picker("Model", selection: $selectedModel) {
                ForEach(ChatGPTClient.Model.allCases, id: \.self) { model in
                    Text(model.displayName).tag(model)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private var promptInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Parameters")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            VStack(alignment: .leading, spacing: 12) {
                inputField(label: "Available Time (minutes)", text: $availableTimeMinutes)
                inputField(label: "Athlete Level", text: $athleteLevel)
                inputField(label: "Focus", text: $focus)
                inputField(label: "Allowed Equipment", text: $allowedEquipment)
                inputField(label: "Exclude Exercises", text: $excludeExercises)
                inputField(label: "Primary Constraints", text: $primaryConstraints)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Goal Notes")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(primaryTextColor)
                    
                    TextEditor(text: $goalNotes)
                        .frame(height: 80)
                        .padding(8)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private var generateButton: some View {
        Button {
            generateBlock()
        } label: {
            HStack {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(isGenerating ? "Generating..." : "Generate Block")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isGenerating ? Color.gray : theme.accent)
            .cornerRadius(12)
        }
        .disabled(isGenerating)
    }
    
    private func streamingOutputSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Response")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            ScrollView {
                Text(streamingText.isEmpty ? "Waiting for response..." : streamingText)
                    .font(.system(size: 12, family: .monospaced))
                    .foregroundColor(primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 200)
            .padding(12)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func blockPreviewSection(block: Block) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Generated Block")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(block.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                
                if let description = block.description {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(theme.mutedText)
                }
                
                Text("\(block.days.count) day(s), \(block.numberOfWeeks) week(s)")
                    .font(.system(size: 14))
                    .foregroundColor(theme.mutedText)
                
                if let firstDay = block.days.first {
                    Text("\(firstDay.exercises.count) exercise(s)")
                        .font(.system(size: 14))
                        .foregroundColor(theme.mutedText)
                }
            }
            
            Button {
                saveBlock(block)
            } label: {
                Text("Save to Blocks")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.green)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func errorSection(message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Error")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.red)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(primaryTextColor)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var importJSONSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Import from JSON")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            Text("Import a block from a JSON file generated by any LLM.")
                .font(.system(size: 14))
                .foregroundColor(theme.mutedText)
            
            Button {
                showingFileImporter = true
            } label: {
                Text("Choose JSON File")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    // MARK: - Helper Views
    
    private func inputField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(primaryTextColor)
            
            TextField(label, text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    // MARK: - Actions
    
    private func checkForAPIKey() {
        do {
            _ = try KeychainHelper.readOpenAIAPIKey()
            hasAPIKey = true
        } catch {
            hasAPIKey = false
        }
    }
    
    private func saveAPIKey() {
        do {
            try KeychainHelper.saveOpenAIAPIKey(apiKey)
            hasAPIKey = true
            apiKey = ""
        } catch {
            errorMessage = "Failed to save API key: \(error.localizedDescription)"
        }
    }
    
    private func showAPIKeyInput() {
        hasAPIKey = false
    }
    
    private func deleteAPIKey() {
        do {
            try KeychainHelper.deleteOpenAIAPIKey()
            hasAPIKey = false
            errorMessage = nil
        } catch {
            errorMessage = "Failed to delete API key: \(error.localizedDescription)"
        }
    }
    
    private func generateBlock() {
        // Clear previous state
        generatedText = ""
        streamingText = ""
        generatedBlock = nil
        errorMessage = nil
        isGenerating = true
        
        // Build prompt
        // Validate and clamp time to positive values
        var timeMinutes = Int(availableTimeMinutes) ?? 45
        if timeMinutes <= 0 {
            timeMinutes = 45
        }
        
        let inputs = PromptTemplates.PromptInputs(
            availableTimeMinutes: timeMinutes,
            athleteLevel: athleteLevel,
            focus: focus,
            allowedEquipment: allowedEquipment,
            excludeExercises: excludeExercises,
            primaryConstraints: primaryConstraints,
            goalNotes: goalNotes
        )
        
        let userMessage = PromptTemplates.defaultUserTemplate(promptInputs: inputs)
        let messages = PromptTemplates.buildMessages(
            system: PromptTemplates.systemMessageExact,
            user: userMessage
        )
        
        // Stream completion
        chatClient.streamCompletion(
            messages: messages,
            model: selectedModel,
            onChunk: { chunk in
                DispatchQueue.main.async {
                    streamingText += chunk
                }
            },
            onComplete: { fullText in
                DispatchQueue.main.async {
                    generatedText = fullText
                    isGenerating = false
                    parseGeneratedBlock(from: fullText)
                }
            },
            onError: { error in
                DispatchQueue.main.async {
                    isGenerating = false
                    errorMessage = error.localizedDescription
                }
            }
        )
    }
    
    private func parseGeneratedBlock(from text: String) {
        let result = BlockGenerator.decodeBlock(from: text)
        
        switch result {
        case .success(let imported):
            let block = BlockGenerator.convertToBlock(imported, numberOfWeeks: 1)
            generatedBlock = block
            errorMessage = nil
        case .failure(let error):
            errorMessage = "Failed to parse block: \(error.localizedDescription)"
        }
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
            guard let url = urls.first else { return }
            
            // Security-scoped resource access
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Failed to access file"
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let imported = try decoder.decode(ImportedBlock.self, from: data)
                let block = BlockGenerator.convertToBlock(imported, numberOfWeeks: 1)
                generatedBlock = block
                errorMessage = nil
            } catch {
                errorMessage = "Failed to import JSON: \(error.localizedDescription)"
            }
            
        case .failure(let error):
            errorMessage = "File import error: \(error.localizedDescription)"
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

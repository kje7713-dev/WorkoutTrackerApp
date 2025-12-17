//
//  ChatGPTSettingsView.swift
//  Savage By Design
//
//  Settings UI for ChatGPT integration (DEV mode)
//

import SwiftUI

struct ChatGPTSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    
    @State private var apiKey: String = ""
    @State private var selectedModel: String = "gpt-3.5-turbo"
    @State private var showSaveAlert: Bool = false
    @State private var saveAlertMessage: String = ""
    @State private var showDeleteAlert: Bool = false
    @State private var isTestingConnection: Bool = false
    @State private var testResult: String = ""
    
    private let availableModels = [
        "gpt-3.5-turbo",
        "gpt-4",
        "gpt-4-turbo-preview"
    ]
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            Form {
                Section("OpenAI API Configuration") {
                    SecureField("API Key", text: $apiKey)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    Picker("Model", selection: $selectedModel) {
                        ForEach(availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                    
                    Text("Your API key is stored securely in the iOS Keychain and never leaves your device.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Actions") {
                    Button("Save API Key") {
                        saveAPIKey()
                    }
                    .disabled(apiKey.isEmpty)
                    
                    Button("Test Connection") {
                        testConnection()
                    }
                    .disabled(apiKey.isEmpty || isTestingConnection)
                    
                    if isTestingConnection {
                        HStack {
                            ProgressView()
                                .progressViewStyle(.circular)
                            Text("Testing...")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !testResult.isEmpty {
                        Text(testResult)
                            .font(.caption)
                            .foregroundColor(testResult.contains("Success") ? .green : .red)
                    }
                    
                    Button("Delete API Key", role: .destructive) {
                        showDeleteAlert = true
                    }
                }
                
                Section("How to get an API Key") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Go to platform.openai.com")
                        Text("2. Sign in or create an account")
                        Text("3. Navigate to API Keys section")
                        Text("4. Create a new API key")
                        Text("5. Copy and paste it above")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("ChatGPT Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            loadSavedAPIKey()
        }
        .alert("API Key", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveAlertMessage)
        }
        .alert("Delete API Key", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAPIKey()
            }
        } message: {
            Text("Are you sure you want to delete your stored API key? You'll need to enter it again to use AI features.")
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? theme.backgroundDark : theme.backgroundLight
    }
    
    private func loadSavedAPIKey() {
        if let savedKey = KeychainHelper.shared.loadOpenAIAPIKey() {
            apiKey = savedKey
        }
    }
    
    private func saveAPIKey() {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            saveAlertMessage = "Please enter a valid API key"
            showSaveAlert = true
            return
        }
        
        if KeychainHelper.shared.saveOpenAIAPIKey(trimmedKey) {
            saveAlertMessage = "API key saved successfully"
            UserDefaults.standard.set(selectedModel, forKey: "chatgpt.selectedModel")
        } else {
            saveAlertMessage = "Failed to save API key. Please try again."
        }
        showSaveAlert = true
    }
    
    private func deleteAPIKey() {
        if KeychainHelper.shared.deleteOpenAIAPIKey() {
            apiKey = ""
            saveAlertMessage = "API key deleted successfully"
        } else {
            saveAlertMessage = "Failed to delete API key"
        }
        showSaveAlert = true
    }
    
    private func testConnection() {
        isTestingConnection = true
        testResult = ""
        
        let client = ChatGPTClient()
        let messages = [
            ChatMessage(role: "user", content: "Hello, this is a test. Please respond with 'OK'.")
        ]
        
        Task {
            do {
                let response = try await client.completion(
                    messages: messages,
                    model: selectedModel,
                    apiKey: apiKey
                )
                
                await MainActor.run {
                    testResult = "✓ Success: \(response.prefix(50))..."
                    isTestingConnection = false
                }
            } catch {
                await MainActor.run {
                    testResult = "✗ Error: \(error.localizedDescription)"
                    isTestingConnection = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatGPTSettingsView()
            .environment(\.sbdTheme, SBDTheme())
    }
}

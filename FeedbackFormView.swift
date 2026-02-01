//
//  FeedbackFormView.swift
//  Savage By Design
//
//  View for submitting feedback (feature requests and bug reports)
//

import SwiftUI

struct FeedbackFormView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    @State private var feedbackType: FeedbackType = .featureRequest
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isSubmitting = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private let githubService = GitHubService()
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FEEDBACK")
                            .font(.system(size: 32, weight: .heavy, design: .default))
                            .tracking(1.5)
                            .foregroundColor(primaryTextColor)
                        
                        Text("Help us improve your experience")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(mutedTextColor)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Feedback Type Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TYPE")
                            .font(.system(size: 14, weight: .semibold))
                            .tracking(1.2)
                            .foregroundColor(mutedTextColor)
                        
                        Picker("Feedback Type", selection: $feedbackType) {
                            ForEach(FeedbackType.allCases) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(theme.accent)
                    }
                    
                    // MARK: - Title Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TITLE")
                            .font(.system(size: 14, weight: .semibold))
                            .tracking(1.2)
                            .foregroundColor(mutedTextColor)
                        
                        TextField("Brief summary", text: $title)
                            .font(.system(size: 16))
                            .padding(12)
                            .background(textFieldBackground)
                            .foregroundColor(primaryTextColor)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(textFieldBorder, lineWidth: 1)
                            )
                    }
                    
                    // MARK: - Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DESCRIPTION")
                            .font(.system(size: 14, weight: .semibold))
                            .tracking(1.2)
                            .foregroundColor(mutedTextColor)
                        
                        TextEditor(text: $description)
                            .font(.system(size: 16))
                            .padding(8)
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                            .background(textFieldBackground)
                            .foregroundColor(primaryTextColor)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(textFieldBorder, lineWidth: 1)
                            )
                    }
                    
                    // MARK: - Submit Button
                    Button(action: submitFeedback) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: foregroundButtonColor))
                                    .scaleEffect(0.8)
                            }
                            Text(isSubmitting ? "SUBMITTING..." : "SUBMIT")
                                .font(.system(size: 16, weight: .semibold))
                                .tracking(1.5)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .foregroundColor(foregroundButtonColor)
                        .background(submitButtonEnabled ? backgroundButtonColor : disabledButtonColor)
                        .cornerRadius(12)
                        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                    }
                    .disabled(!submitButtonEnabled || isSubmitting)
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 8)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success!", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Thank you for your feedback! We've received your submission.")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Actions
    
    private func submitFeedback() {
        guard submitButtonEnabled else { return }
        
        isSubmitting = true
        
        Task {
            do {
                // Get GitHub token from environment or configuration
                // In production, this would come from a secure backend
                guard let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] else {
                    throw FeedbackError.missingToken
                }
                
                _ = try await githubService.submitFeedback(
                    type: feedbackType,
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                    token: token
                )
                
                await MainActor.run {
                    isSubmitting = false
                    showingSuccess = true
                    // Reset form
                    title = ""
                    description = ""
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var submitButtonEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? theme.backgroundDark : theme.backgroundLight
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? theme.primaryTextDark : theme.primaryTextLight
    }
    
    private var mutedTextColor: Color {
        theme.mutedText
    }
    
    private var textFieldBackground: Color {
        colorScheme == .dark ? theme.cardBackgroundDark : theme.cardBackgroundLight
    }
    
    private var textFieldBorder: Color {
        colorScheme == .dark ? theme.cardBorderDark : theme.cardBorderLight
    }
    
    private var backgroundButtonColor: Color {
        colorScheme == .dark ? theme.primaryButtonBackgroundDark : theme.primaryButtonBackgroundLight
    }
    
    private var foregroundButtonColor: Color {
        colorScheme == .dark ? theme.primaryButtonForegroundDark : theme.primaryButtonForegroundLight
    }
    
    private var disabledButtonColor: Color {
        colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2)
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.clear : Color.black.opacity(0.15)
    }
}

#Preview {
    NavigationStack {
        FeedbackFormView()
    }
}

//
//  FeedbackFormView.swift
//  Savage By Design
//
//  View for submitting feedback (feature requests and bug reports)
//

import SwiftUI
import MessageUI

struct FeedbackFormView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    @State private var feedbackType: FeedbackType = .featureRequest
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var showingMailComposer = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
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
                        Text("SUBMIT")
                            .font(.system(size: 16, weight: .semibold))
                            .tracking(1.5)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .foregroundColor(foregroundButtonColor)
                            .background(submitButtonEnabled ? backgroundButtonColor : disabledButtonColor)
                            .cornerRadius(12)
                            .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                    }
                    .disabled(!submitButtonEnabled)
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 8)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingMailComposer) {
            MailComposeView(
                recipients: [FeedbackService.feedbackEmail],
                subject: FeedbackService.emailSubject(for: feedbackType, title: title),
                body: FeedbackService.emailBody(
                    type: feedbackType,
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines)
                ),
                onComplete: { result in
                    showingMailComposer = false
                    if result == .sent {
                        // Reset form on successful send
                        title = ""
                        description = ""
                    }
                }
            )
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
        
        // Trim whitespace from inputs
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If Mail app is available, use native composer
        if FeedbackService.canSendMail() {
            showingMailComposer = true
        } else {
            // Fallback to mailto: URL for other email clients (Gmail, Outlook, etc.)
            guard let mailtoURL = FeedbackService.mailtoURL(
                for: feedbackType,
                title: trimmedTitle,
                description: trimmedDescription
            ) else {
                errorMessage = "Failed to create email. Please try again."
                showingError = true
                return
            }
            
            // Open mailto URL - iOS will show app chooser if multiple email apps available
            // or open the default email app, or show error if no email apps installed
            UIApplication.shared.open(mailtoURL) { success in
                if success {
                    // Reset form on successful open
                    DispatchQueue.main.async {
                        self.title = ""
                        self.description = ""
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to launch email client. Please install an email app (Mail, Gmail, Outlook, etc.) to send feedback."
                        self.showingError = true
                    }
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

// MARK: - Mail Compose View Wrapper

struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let body: String
    let onComplete: (MFMailComposeResult) -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(recipients)
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onComplete: (MFMailComposeResult) -> Void
        
        init(onComplete: @escaping (MFMailComposeResult) -> Void) {
            self.onComplete = onComplete
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            onComplete(result)
        }
    }
}

#Preview {
    NavigationStack {
        FeedbackFormView()
    }
}

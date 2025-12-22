//
//  WeekCompletionModal.swift
//  Savage By Design – Week and Block Completion Modals
//
//  Displays strongly-styled completion messages for week and block milestones
//

import SwiftUI

/// Reusable completion modal with strong styling
/// Displays a title, message, and dismiss button with gradient accent header
struct WeekCompletionModal: View {
    let title: String
    let message: String
    let onDismiss: () -> Void
    let isBlockCompletion: Bool
    
    @Environment(\.sbdTheme) private var theme
    
    init(
        title: String,
        message: String,
        isBlockCompletion: Bool = false,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.isBlockCompletion = isBlockCompletion
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
                .accessibilityHidden(true)
            
            // Modal card
            VStack(spacing: 0) {
                // Gradient header
                gradientHeader
                
                // Content area
                VStack(spacing: 20) {
                    Text(message)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    
                    Button(action: onDismiss) {
                        Text("OK")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(Color(uiColor: .systemBackground))
            }
            .frame(maxWidth: 320)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(title)
            .accessibilityHint(message)
        }
    }
    
    private var gradientHeader: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .textCase(.uppercase)
                .kerning(1.2)
        }
        .frame(height: 80)
    }
    
    private var gradientColors: [Color] {
        if isBlockCompletion {
            // Brighter gradient for block completion using theme colors
            return [theme.premiumGradientStart, theme.premiumGradientEnd]
        } else {
            // Standard accent gradient for week completion
            return [
                theme.accent.opacity(0.8),
                theme.accent.opacity(0.5)
            ]
        }
    }
    
    private var accentColor: Color {
        if isBlockCompletion {
            return theme.premiumGradientStart
        } else {
            return theme.accent
        }
    }
}

// MARK: - Preview

struct WeekCompletionModal_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Week completion preview
            WeekCompletionModal(
                title: "WEEK COMPLETE",
                message: "Solid work — keep grinding.",
                isBlockCompletion: false,
                onDismiss: {}
            )
            .previewDisplayName("Week Completion")
            
            // Block completion preview
            WeekCompletionModal(
                title: "BLOCK COMPLETE",
                message: "Fuck yeah — block built.",
                isBlockCompletion: true,
                onDismiss: {}
            )
            .previewDisplayName("Block Completion")
        }
    }
}

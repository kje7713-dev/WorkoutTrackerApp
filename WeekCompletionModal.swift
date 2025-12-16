//
//  WeekCompletionModal.swift
//  Savage By Design
//
//  Week completion modal shown when user completes all sets in a week.
//  Issue #49: Week completion confirmation message
//

import SwiftUI

/// Modal displayed when a week is completed in run mode
struct WeekCompletionModal: View {
    let weekNumber: Int
    let onDismiss: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Semi-transparent background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Modal card
            VStack(spacing: 0) {
                // Title section with gradient background
                VStack(spacing: 8) {
                    Text("Week completed")
                        .font(.system(size: 32, weight: .black))
                        .textCase(.uppercase)
                        .kerning(1.5)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Text("WEEK \(weekNumber)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.1),
                            Color.black
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Message section
                VStack(spacing: 24) {
                    Text("Excellence is not an act but a habit.")
                        .font(.system(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.horizontal, 24)
                    
                    // OK button
                    Button(action: onDismiss) {
                        Text("OK")
                            .font(.system(size: 18, weight: .bold))
                            .textCase(.uppercase)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .background(colorScheme == .dark ? .white : .black)
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 32)
                .background(colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : .white)
            }
            .frame(maxWidth: 360)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - SwiftUI Preview

#Preview("Week Completion Modal") {
    WeekCompletionModal(weekNumber: 1, onDismiss: {})
}

#Preview("Week 3 Completed - Dark Mode") {
    WeekCompletionModal(weekNumber: 3, onDismiss: {})
        .preferredColorScheme(.dark)
}

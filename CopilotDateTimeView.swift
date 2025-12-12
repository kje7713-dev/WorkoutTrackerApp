//
//  CopilotDateTimeView.swift
//  Savage By Design
//
//  Copilot datetime display component
//

import SwiftUI
import Combine

struct CopilotDateTimeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    @State private var currentDateTime: String = ""
    @State private var timerCancellable: Cancellable?
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var body: some View {
        SBDCard {
            HStack(spacing: 12) {
                Text("Copilot")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(primaryTextColor)
                
                Spacer()
                
                Text(currentDateTime)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.mutedText)
            }
        }
        .onAppear {
            updateDateTime()
            timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    updateDateTime()
                }
        }
        .onDisappear {
            timerCancellable?.cancel()
            timerCancellable = nil
        }
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? theme.primaryTextDark : theme.primaryTextLight
    }
    
    private func updateDateTime() {
        currentDateTime = Self.dateFormatter.string(from: Date())
    }
}

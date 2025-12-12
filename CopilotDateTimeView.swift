//
//  CopilotDateTimeView.swift
//  Savage By Design
//
//  Copilot datetime display component
//

import SwiftUI

struct CopilotDateTimeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    @State private var currentDateTime: String = ""
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
        }
        .onReceive(timer) { _ in
            updateDateTime()
        }
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? theme.primaryTextDark : theme.primaryTextLight
    }
    
    private func updateDateTime() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        currentDateTime = formatter.string(from: Date())
    }
}

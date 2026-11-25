//
//  FreeAccessView.swift
//  Savage By Design
//
//  Explicit free-mode screen used wherever the subscription UI would
//  otherwise be presented.
//

import SwiftUI

struct FreeAccessView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.sbdTheme) private var theme

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56))
                    .foregroundColor(theme.accent)

                Text("Free Access")
                    .font(.system(size: 28, weight: .bold))

                Text("All Savage By Design features are currently available at no cost.")
                    .font(.system(size: 17))
                    .foregroundColor(theme.mutedText)
                    .multilineTextAlignment(.center)

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background((Color.black.opacity(0.001)).ignoresSafeArea())
            .navigationTitle("Free Access")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// HomeView.swift

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("SAVAGE BY DESIGN")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)

                Text("WE ARE WHAT WE REPEATEDLY DO")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

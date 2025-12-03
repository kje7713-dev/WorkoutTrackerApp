//
//  SavageByDesignApp.swift
//  Savage By Design
//
//  Phase 3: App entry -> HomeView
//

import SwiftUI

@main
struct SavageByDesignApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                // If we ever want to override the theme, we can inject here:
                // .environment(\.sbdTheme, .default)
        }
    }
}
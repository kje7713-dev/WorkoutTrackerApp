//
//  SavageByDesignApp.swift
//  Savage By Design
//
//  App entry + environment objects + navigation shell
//

import SwiftUI

// MARK: - App-wide Notification Names

extension Notification.Name {
    /// Notification to dismiss the entire navigation stack back to root (HomeView)
    static let dismissToRoot = Notification.Name("dismissToRoot")
}

@main
struct SavageByDesignApp: App {

    @StateObject private var blocksRepository = BlocksRepository()
    @StateObject private var sessionsRepository = SessionsRepository()
    @StateObject private var exerciseLibraryRepository = ExerciseLibraryRepository()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(blocksRepository)
            .environmentObject(sessionsRepository)
            .environmentObject(exerciseLibraryRepository)
        }
    }
}
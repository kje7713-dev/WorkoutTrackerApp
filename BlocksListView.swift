//
//  SavageByDesignApp.swift
//  Savage By Design
//
//  App entry + environment objects + navigation shell
//

import SwiftUI

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
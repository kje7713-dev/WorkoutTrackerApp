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

    init() {
        // Seed exercise library with default exercises on first launch
        let tempRepo = ExerciseLibraryRepository()
        tempRepo.loadDefaultSeedIfEmpty()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(blocksRepository)
            .environmentObject(sessionsRepository)
            .environmentObject(exerciseLibraryRepository)
            .onAppear {
                // Load default exercises when app appears
                exerciseLibraryRepository.loadDefaultSeedIfEmpty()
            }
        }
    }
}
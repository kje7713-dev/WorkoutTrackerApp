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
    
    // Data management service for background cleanup
    @State private var dataService: DataManagementService?

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
                
                // Initialize data service and perform background cleanup
                setupDataManagement()
            }
        }
    }
    
    // MARK: - Data Management Setup
    
    private func setupDataManagement() {
        dataService = DataManagementService(
            blocksRepository: blocksRepository,
            sessionsRepository: sessionsRepository,
            exerciseRepository: exerciseLibraryRepository
        )
        
        // Apply retention policy on app launch (background cleanup)
        // This runs asynchronously to not block app startup
        DispatchQueue.global(qos: .utility).async {
            applyRetentionPolicyIfNeeded()
        }
    }
    
    private func applyRetentionPolicyIfNeeded() {
        guard let service = dataService else { return }
        
        // Check if we need to run cleanup based on last cleanup date
        let lastCleanupKey = "lastDataCleanupDate"
        let userDefaults = UserDefaults.standard
        let calendar = Calendar(identifier: .gregorian)
        
        let daysSinceLastCleanup: Int
        if let lastCleanup = userDefaults.object(forKey: lastCleanupKey) as? Date {
            daysSinceLastCleanup = calendar.dateComponents([.day], from: lastCleanup, to: Date()).day ?? 0
        } else {
            daysSinceLastCleanup = Int.max // Never run before
        }
        
        // Run cleanup once per week
        if daysSinceLastCleanup >= 7 {
            let policy = DataManagementService.RetentionPolicy.default
            service.applyRetentionPolicy(policy)
            userDefaults.set(Date(), forKey: lastCleanupKey)
            
            AppLogger.info("Background data cleanup completed", subsystem: .persistence, category: "DataManagement")
        }
    }
}
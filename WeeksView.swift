//
//  WeeksView.swift
//  Savage By Design
//
//  Interim view between Block selection and SessionView.
//  Displays weeks as chips and navigates to SessionView for the selected week.
//

import SwiftUI

struct WeeksView: View {
    let block: Block
    
    @EnvironmentObject private var sessionsRepository: SessionsRepository
    @EnvironmentObject private var blocksRepository: BlocksRepository
    @Environment(\.sbdTheme) private var theme
    
    // Track which week was selected
    @State private var selectedWeekIndex: Int?
    
    // Helper to get or generate sessions for this block
    private func getSessions() -> [WorkoutSession] {
        var existing = sessionsRepository.sessions(forBlockId: block.id)
        
        // Generate sessions if they don't exist
        if existing.isEmpty {
            let factory = SessionFactory()
            let generated = factory.makeSessions(for: block)
            sessionsRepository.replaceSessions(forBlockId: block.id, with: generated)
            existing = generated
        }
        
        return existing
    }
    
    // Helper to determine the active week based on session progress
    private func getActiveWeekIndex(from sessions: [WorkoutSession]) -> Int {
        // Find the first week with an uncompleted session
        let weekIndexes = Set(sessions.map { $0.weekIndex }).sorted()
        
        for weekIndex in weekIndexes {
            let weekSessions = sessions.filter { $0.weekIndex == weekIndex }
            if weekSessions.contains(where: { $0.status != .completed }) {
                return weekIndex
            }
        }
        
        // If all weeks are completed, return the last week
        return weekIndexes.last ?? 1
    }
    
    var body: some View {
        let sessions = getSessions()
        let activeWeek = getActiveWeekIndex(from: sessions)
        
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                header
                
                weeksGrid(activeWeek: activeWeek)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 32)
        }
        .navigationTitle(block.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Set initial selected week to the active week
            if selectedWeekIndex == nil {
                selectedWeekIndex = activeWeek
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Select Week")
                .font(.largeTitle).bold()
            
            Text("Choose a week to view and track your sessions.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Weeks Grid
    
    private func weeksGrid(activeWeek: Int) -> some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(1...block.numberOfWeeks, id: \.self) { weekIndex in
                    NavigationLink {
                        WeekSessionsView(
                            block: block,
                            weekIndex: weekIndex
                        )
                        .environmentObject(sessionsRepository)
                        .environmentObject(blocksRepository)
                    } label: {
                        WeekChipView(
                            weekIndex: weekIndex,
                            isActive: weekIndex == activeWeek
                        )
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Week Chip View

private struct WeekChipView: View {
    let weekIndex: Int
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Week \(weekIndex)")
                .font(.title2)
                .fontWeight(.bold)
            
            if isActive {
                Text("ACTIVE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isActive ? Color.green.opacity(0.1) : Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive ? Color.green : Color.clear, lineWidth: 2)
        )
        .foregroundColor(.primary)
    }
}

// MARK: - Week Sessions View

private struct WeekSessionsView: View {
    let block: Block
    let weekIndex: Int
    
    @EnvironmentObject private var sessionsRepository: SessionsRepository
    @EnvironmentObject private var blocksRepository: BlocksRepository
    
    @State private var selectedSessionId: WorkoutSessionID?
    
    // Get sessions for this specific week
    private func getSessionsForWeek() -> [WorkoutSession] {
        let allSessions = sessionsRepository.sessions(forBlockId: block.id)
        return allSessions
            .filter { $0.weekIndex == weekIndex }
            .sorted { lhs, rhs in
                lhs.dayTemplateId.uuidString < rhs.dayTemplateId.uuidString
            }
    }
    
    // Helper to determine the initial session to load
    private func getInitialSession(from sessions: [WorkoutSession]) -> WorkoutSession? {
        // Find the first uncompleted session, or the very first one if all are completed
        let uncompleted = sessions.first(where: { $0.status != .completed })
        return uncompleted ?? sessions.first
    }
    
    var body: some View {
        let sessions = getSessionsForWeek()
        
        Group {
            if sessions.isEmpty {
                Text("No sessions available for this week.")
            } else if let currentSession = sessions.first(where: { $0.id == selectedSessionId }) {
                VStack(spacing: 0) {
                    // Day Tab Bar - only shows days from this week
                    SessionDayTabBar(
                        block: block,
                        sessions: sessions,
                        selectedSessionId: $selectedSessionId
                    )
                    .padding(.vertical, 8)
                    
                    // Load the SessionRunView with the selected session
                    SessionRunView(session: currentSession)
                }
            } else {
                Text("Select a day to start.")
            }
        }
        .onAppear {
            if selectedSessionId == nil, let initialId = getInitialSession(from: sessions)?.id {
                selectedSessionId = initialId
            }
        }
        .navigationTitle("Week \(weekIndex)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Session Day Tab Bar (for week-filtered days)

private struct SessionDayTabBar: View {
    let block: Block
    let sessions: [WorkoutSession]
    @Binding var selectedSessionId: WorkoutSessionID?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(sessions, id: \.id) { session in
                    let isSelected = session.id == selectedSessionId
                    
                    // Look up the DayTemplate using the block
                    let dayTemplate = block.days.first { $0.id == session.dayTemplateId }
                    let dayLabel = dayTemplate?.shortCode ?? dayTemplate?.name ?? "Day"
                    
                    Button {
                        selectedSessionId = session.id
                    } label: {
                        Text(dayLabel)
                            .font(.subheadline)
                            .fontWeight(isSelected ? .bold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.black : Color.clear)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .foregroundColor(isSelected ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

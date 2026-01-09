//
//  BlockGeneratorView.swift
//  Savage By Design – Block JSON Import UI
//
//  User interface for importing blocks from JSON files.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Block Importer View

struct BlockGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    
    @EnvironmentObject private var blocksRepository: BlocksRepository
    @EnvironmentObject private var sessionsRepository: SessionsRepository
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    // MARK: - Constants
    
    private let confirmationDisplayDuration: TimeInterval = 2.0
    
    // MARK: - State
    
    @State private var showingFileImporter: Bool = false
    @State private var importedBlock: Block?
    @State private var errorMessage: String?
    @State private var showCopyConfirmation: Bool = false
    @State private var hideConfirmationTask: DispatchWorkItem?
    @State private var pastedJSON: String = ""
    @State private var showingPaywall: Bool = false
    @State private var userRequirements: String = ""
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if subscriptionManager.isSubscribed {
                mainContent
            } else {
                lockedContent
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(subscriptionManager)
        }
    }
    
    // MARK: - Main Content (Pro Users)
    
    private var mainContent: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header
                    
                    headerSection
                    
                    // MARK: - Import JSON Section
                    
                    importJSONSection
                    
                    // MARK: - Block Preview
                    
                    if let block = importedBlock {
                        blockPreviewSection(block: block)
                    }
                    
                    // MARK: - Error Display
                    
                    if let error = errorMessage {
                        errorSection(message: error)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(backgroundColor.ignoresSafeArea())
            .navigationTitle("Import Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result: result)
            }
            .overlay(
                Group {
                    if showCopyConfirmation {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                Text("Copied to clipboard!")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .padding(.bottom, 50)
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: showCopyConfirmation)
                    }
                }
            )
        }
    }
    
    // MARK: - Locked Content (Free Users)
    
    private var lockedContent: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 60))
                    .foregroundColor(theme.mutedText)
                
                Text("Pro Feature")
                    .font(.system(size: 28, weight: .bold))
                
                Text("AI-assisted plan ingestion is a Pro feature. Subscribe to import and parse workout plans from JSON.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(theme.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Button {
                    showingPaywall = true
                } label: {
                    Text(subscriptionManager.isEligibleForTrial ? "Start 15-Day Free Trial" : "Subscribe Now")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [theme.premiumGradientStart, theme.premiumGradientEnd]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: theme.premiumGradientStart.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .background(backgroundColor.ignoresSafeArea())
            .navigationTitle("Import Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Import Workout Block")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            Text("Import a training block from a JSON file. You can generate JSON files using ChatGPT, Claude, or any other AI assistant. See AI prompt assistance below.")
                .font(.system(size: 14))
                .foregroundColor(theme.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var importJSONSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import JSON")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            Text("The JSON should contain a training block with exercises, sets, reps, and other training parameters. You can either paste JSON directly or upload a file. After parsing or uploading, scroll to the bottom to preview the block.")
                .font(.system(size: 14))
                .foregroundColor(theme.mutedText)
            
            // Paste JSON Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Option 1: Paste JSON")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                
                TextEditor(text: $pastedJSON)
                    .font(.system(size: 12, design: .monospaced))
                    .frame(minHeight: 150, maxHeight: 200)
                    .padding(8)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.separator), lineWidth: 1)
                    )
                
                Button {
                    parseJSONFromText()
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                        Text("Parse JSON")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(pastedJSON.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : theme.accent)
                    .cornerRadius(12)
                }
                .disabled(pastedJSON.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            Text("OR")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.mutedText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            
            // Upload File Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Option 2: Upload JSON File")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                
                Button {
                    showingFileImporter = true
                } label: {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("Choose JSON File")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(theme.accent)
                    .cornerRadius(12)
                }
            }
            
            Divider()
            
            // AI Prompt Template Section
            aiPromptTemplateSection
            
            Divider()
            
            // JSON Format Example
            jsonFormatExampleSection
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    // MARK: - AI Prompt Template Section
    
    private var aiPromptTemplateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Prompt Template")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(primaryTextColor)
            
            Text("Fill in your specific requirements below, then copy the complete prompt to use with ChatGPT, Claude, or any AI assistant.")
                .font(.system(size: 12))
                .foregroundColor(theme.mutedText)
            
            // Requirements input field
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Requirements (Optional)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(primaryTextColor)
                
                TextEditor(text: $userRequirements)
                    .font(.system(size: 13))
                    .frame(minHeight: 100, maxHeight: 150)
                    .padding(8)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.separator), lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if userRequirements.isEmpty {
                                Text("Example: I want a 4-week upper/lower split for intermediate lifters, 4 days per week, focusing on strength and hypertrophy. I have access to a full gym with barbells, dumbbells, and machines.")
                                    .font(.system(size: 13))
                                    .foregroundColor(theme.mutedText.opacity(0.6))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )
            }
            
            // Copy button with prompt preview
            HStack {
                Spacer()
                
                Button {
                    copyToClipboard(aiPromptTemplate(withRequirements: userRequirements))
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy Complete Prompt")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(theme.accent)
                    .cornerRadius(6)
                }
            }
            
            // Prompt preview (collapsible)
            DisclosureGroup("Preview Full Prompt") {
                ScrollView(.horizontal, showsIndicators: true) {
                    Text(aiPromptTemplate(withRequirements: userRequirements))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(theme.mutedText)
                        .padding(12)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 150)
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(primaryTextColor)
        }
    }
    
    // MARK: - JSON Format Example Section
    
    private var jsonFormatExampleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("JSON Format Example")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                
                Spacer()
                
                Button {
                    copyToClipboard(jsonFormatExample)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(theme.accent)
                    .cornerRadius(6)
                }
            }
            
            Text("This is the expected format. All fields are required. Save as .json file.")
                .font(.system(size: 12))
                .foregroundColor(theme.mutedText)
            
            ScrollView(.horizontal, showsIndicators: true) {
                Text(jsonFormatExample)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(theme.mutedText)
                    .padding(12)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 200)
        }
    }
    
    private func blockPreviewSection(block: Block) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Block Preview")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(primaryTextColor)
            
            VStack(alignment: .leading, spacing: 12) {
                // Block name
                HStack {
                    Text("Name:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.mutedText)
                    Text(block.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(primaryTextColor)
                }
                
                // Description
                if let description = block.description {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(theme.mutedText)
                }
                
                // Stats
                HStack(spacing: 16) {
                    Label("\(block.days.count) day(s)", systemImage: "calendar")
                        .font(.system(size: 14))
                        .foregroundColor(theme.mutedText)
                    
                    Label("\(block.numberOfWeeks) week(s)", systemImage: "calendar.badge.clock")
                        .font(.system(size: 14))
                        .foregroundColor(theme.mutedText)
                }
                
                // Exercise count
                if let firstDay = block.days.first {
                    Label("\(firstDay.exercises.count) exercise(s)", systemImage: "figure.strengthtraining.traditional")
                        .font(.system(size: 14))
                        .foregroundColor(theme.mutedText)
                }
                
                Divider()
                
                // Save button
                Button {
                    saveBlock(block)
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Block to Library")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(theme.success)
                    .cornerRadius(12)
                    .shadow(color: theme.success.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func errorSection(message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(theme.error)
                Text("Error")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(theme.error)
            }
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(primaryTextColor)
        }
        .padding()
        .background(theme.error.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Template Strings
    
    private func aiPromptTemplate(withRequirements requirements: String?) -> String {
        let trimmedRequirements = requirements?.trimmingCharacters(in: .whitespacesAndNewlines)
        let requirementsText: String
        
        if let trimmed = trimmedRequirements, !trimmed.isEmpty {
            requirementsText = trimmed
        } else {
            requirementsText = "[Describe your training goals, experience level, available equipment, time constraints, and specific exercises/activities you want.]"
        }
        
        return """
        You are a coach-grade training program designer generating structured content for the Savage By Design workout tracker app.
        
        Schema correctness is NON-NEGOTIABLE. Output MUST be valid JSON and conform exactly to the provided schema.
        
        VOLUME & RECOVERY OWNERSHIP (AGENT-OWNED):
        You are responsible for determining appropriate volume, intensity, and recovery based on:
        - Stated training goal
        - Athlete experience level
        - Training frequency
        - Block length and periodization
        - Competitive intent and athlete dedication level
        
        DO NOT ask the user to define volume parameters or recovery capacity.
        DO NOT expose internal reasoning about minimum/maximum volume unless explaining a safety or recovery concern.
        DO NOT default to conservative or minimal programming when information is ambiguous.
        
        If your analysis indicates that volume or intensity would compromise the primary training stimulus or recovery:
        - FIRST, ask clarifying questions if critical information is missing
        - THEN, adjust the programming based on actual user context
        - Briefly justify the adjustment in your output
        - Prioritize training quality and long-term progress over rigid volume targets
        
        When ambiguous or missing information:
        - Bias toward performance optimization, not conservative safety margins
        - ASK questions rather than reducing volume preemptively
        - Use competitive context as a signal for advanced programming
        - Silence is NOT permission to program conservatively
        
        MY REQUIREMENTS:
        \(requirementsText)
        
        ═══════════════════════════════════════════════════════════════
        SAVAGE BY DESIGN — CLARIFICATION OVER ASSUMPTION
        ═══════════════════════════════════════════════════════════════
        
        CORE PHILOSOPHY:
        Do NOT default to conservative or minimal programming.
        
        If a request is HIGH entropy and any critical input is missing
        (e.g. training frequency, session duration, competitive intent, structure),
        you MUST ask clarifying questions before generating the program.
        
        Competition or meet prep IMPLIES a dedicated athlete.
        Conservative defaults are DISABLED in competitive contexts.
        
        WHEN INFORMATION IS MISSING:
        - ASK, do not assume down.
        - Optimize for performance, not convenience.
        - Use recovery management to support higher output, not to justify reduced exposure.
        
        Silence from the user is NOT permission to be conservative.
        
        COMPETITIVE CONTEXT RULES:
        - Competition prep = dedicated athlete with higher training capacity
        - Meet prep = advanced programming with appropriate volume
        - Performance goals = prioritize stimulus over safety margins
        - When competitive intent is stated, assume advanced recovery capacity unless contradicted
        
        DEFAULT BIAS:
        - When ambiguous: bias toward performance optimization
        - When uncertain about volume: ask rather than reduce
        - When recovery is unclear: ask rather than add conservative buffers
        - When intensity is unspecified: match the stated goal (competition = high intensity)
        
        REQUIRED QUESTIONS FOR HIGH-ENTROPY REQUESTS:
        If request is HIGH entropy and missing critical parameters, you MUST ask:
        1. Training frequency
        2. Session duration available
        3. Competitive intent
        4. Experience level with stated goal
        5. Current training volume baseline
        
        DO NOT proceed with conservative assumptions. DO NOT reduce volume preemptively.
        ASK first, then program appropriately based on user's actual context.
        
        ═══════════════════════════════════════════════════════════════
        ENTROPY DETECTION AND SCOPE CONTRACT (REQUIRED)
        ═══════════════════════════════════════════════════════════════
        
        ENTROPY DETECTION:
        Classify each request as LOW or HIGH entropy.
        HIGH entropy includes multi-day, multi-week, curriculum, protocol, or hybrid (strength + skill + conditioning) requests.
        If HIGH entropy, all steps below are mandatory.
        
        SCOPE SUMMARY (INITIAL) — REQUIRED OUTPUT:
        contentType: workout | seminar | course | curriculum | protocol | other
        primaryItem: exercise | technique | drill | concept | task | skill
        mediaImpact: low | medium | high
        
        GOAL STIMULUS — REQUIRED:
        Primary Stimulus:
        Secondary Stimulus:
        Tertiary Stimulus (optional):
        
        If goal stimulus is unclear or contradictory, STOP and ask for clarification.
        
        PRE-SCOPE SUFFICIENCY ANALYSIS — INTERNAL REASONING (DO NOT EXPOSE):
        Internally analyze:
        1) Minimum effective volume needed to address the primary stimulus
        2) Maximum recoverable volume based on goal, athlete level, frequency, and block length
        3) Time constraints given session duration
        4) Interference between training stimuli
        
        Use this analysis to determine appropriate volume and intensity.
        DO NOT ask the user to define volume parameters.
        DO NOT expose your internal reasoning about minimum/maximum volumes unless there is a safety or recovery concern that must be explained.
        
        UNIT JUSTIFICATION — REQUIRED OUTPUT BEFORE JSON:
        Primary Stimulus:
        Chosen Units per Session:
        Rejected Alternatives (if significant):
        Final Justification (brief):
        
        QUESTION GATE — REQUIRED FOR HIGH ENTROPY WHEN CRITICAL INFO MISSING:
        For HIGH-ENTROPY requests, if any critical information is missing:
        - Training frequency (days per week)
        - Session duration available
        - Competitive intent (recreational, serious, meet prep)
        - Experience level with the specific goal
        
        You MUST ask clarifying questions. DO NOT proceed with conservative assumptions.
        
        Additional clarifying questions you MAY ask if genuinely needed for program design:
        1) Detail depth: brief | moderate | detailed
        2) Structure preference: identical | progressive | rotational
        3) Video policy (ONLY if mediaImpact = high): Ask video policy preference
        4) Current training volume baseline (if relevant for scaling decisions)
        
        DO NOT ask about:
        - Volume parameters (unit counts, exercise density) - you determine these based on context
        - Recovery capacity directly - you assess this from other inputs
        - Intensity levels unless truly ambiguous
        
        You are responsible for determining appropriate volume, intensity, and recovery based on stated goal, athlete level, frequency, block length, and competitive intent.
        
        CRITICAL: If user provides competitive context (meet prep, competition goal), this signals:
        - Advanced/dedicated athlete
        - Higher training capacity
        - Performance optimization priority
        - DO NOT apply conservative defaults
        
        SMART DEFAULTS (ONLY IF ALL CRITICAL INFORMATION PROVIDED):
        If all critical information is provided (frequency, duration, experience, competitive intent),
        determine appropriate volume based on:
        - Goal (strength goals typically need 2-4 main exercises, but can be higher for advanced athletes)
        - Athlete level (beginners need less volume than advanced, but don't assume beginner without evidence)
        - Session duration (available time constrains volume, but optimize within constraints)
        - Recovery capacity (adjust based on frequency and intensity, bias toward performance)
        - Competitive intent (meet prep = advanced programming with appropriate volume)
        
        DEFAULT BIAS:
        - When context suggests dedicated training: program accordingly (not conservatively)
        - When competitive intent stated: assume advanced capacity unless contradicted
        - When experience unclear but goal is advanced: ask rather than assume beginner programming
        
        If conditioning or skill is appended to strength work:
        - Adjust total volume to preserve training quality and recovery
        - Place conditioning after strength to prioritize main stimulus
        - Do not automatically reduce strength volume - assess based on total session time
        
        General defaults (if truly no preference given):
        - UnitDuration = moderate
        - DetailDepth = medium
        - StructureConsistency = progressive (for multi-week blocks)
        - MediaPolicy = none if mediaImpact = low
        
        SCOPE SUMMARY (FINAL) — REQUIRED OUTPUT:
        contentType:
        primaryItem:
        mediaImpact:
        unitDuration:
        unitsPerSession:
        detailDepth:
        structureConsistency:
        
        After FINAL SCOPE LOCK:
        - No scope changes
        - No unit additions
        - No schema reshaping
        
        ───────────────────────────────────────────────────────────────
        SCHEMA PRIORITY RULES
        ───────────────────────────────────────────────────────────────
        - Never alter schema shape, field names, required fields, or types
        - Never add filler units to appear complete
        - Reduce scope or ask questions instead
        
        HARD FAILURE CONDITIONS — STOP AND ASK:
        If you determine that:
        - The requested volume cannot be recovered from given the athlete level, frequency, and intensity
        - Session duration is insufficient for the requested work
        - Secondary work would significantly undermine the primary training stimulus
        - The program structure would compromise training quality or safety
        - Schema compliance cannot be maintained
        - Critical inputs are missing for HIGH-ENTROPY requests
        
        Then STOP and briefly explain the conflict, suggest alternatives, and ask for clarification.
        Keep explanations focused on training outcomes (e.g., "This volume may compromise recovery") rather than internal metrics.
        
        IMPORTANT: When missing critical information for HIGH-ENTROPY requests:
        - DO NOT default to conservative/minimal programming
        - DO NOT reduce volume preemptively
        - ASK clarifying questions to understand the user's actual context
        - Only after receiving answers should you program appropriately
        
        Operating principle:
        "You own volume and recovery decisions. Prioritize training quality and long-term progress. When ambiguous, bias toward performance optimization and ASK rather than assume conservative. Adjust programming based on actual user context, not worst-case assumptions."
        
        ═══════════════════════════════════════════════════════════════
        
        IMPORTANT - JSON Format Specification:
        - The file MUST be valid JSON with proper syntax (commas, quotes, brackets)
        - All BLOCK-LEVEL fields are REQUIRED (Title, Goal, TargetAthlete, DurationMinutes, etc.)
        - You can structure Days with EXERCISES (sets/reps/weight gym work) or SEGMENTS (technique-focused classes) or BOTH
        - You must provide ONE OF: "Exercises" (single-day), "Days" (multi-day), OR "Weeks" (week-specific)
        - Save output as a .json file: [BlockName]_[Weeks]W_[Days]D.json
        - Example: UpperLower_4W_4D.json or BJJ_Class_1W_1D.json
        
        ═══════════════════════════════════════════════════════════════
        CHOOSING BETWEEN EXERCISES vs SEGMENTS:
        ═══════════════════════════════════════════════════════════════
        
        IMPORTANT: Each Day must have exactly ONE of each array (not multiple):
        - If using exercises: ONE "exercises": [...] array per Day
        - If using segments: ONE "segments": [...] array per Day  
        - If using both: ONE "exercises": [...] AND ONE "segments": [...] per Day
        
        Use EXERCISES ONLY for:
        - Traditional gym workouts (sets, reps, weights)
        - Strength training with progressive overload
        - Powerlifting programs (squat, bench, deadlift focus)
        - Bodybuilding routines
        - Conditioning workouts with time/distance/calories
        
        Use SEGMENTS ONLY for:
        - Martial arts classes (BJJ, wrestling, judo, MMA)
        - Yoga and mobility sessions
        - Skill-based training with technique instruction
        - Drills with specific constraints and coaching cues
        - Sessions structured by phases (warmup, technique, drilling, sparring, cooldown)
        
        Use BOTH (exercises AND segments) in same Day only when:
        - Combining strength work with skill training
        - Gym session followed by technique work
        - CRITICAL: Still only ONE "exercises" array and ONE "segments" array per Day
        
        ═══════════════════════════════════════════════════════════════
        CRITICAL STRUCTURAL CONSTRAINTS:
        ═══════════════════════════════════════════════════════════════
        
        JSON STRUCTURE RULES (NON-NEGOTIABLE):
        1. Use exactly ONE "segments" array per Day (if needed)
        2. Use exactly ONE "exercises" array per Day (if needed)
        3. NEVER duplicate JSON keys - each key appears once per object
        4. Arrays ("segments", "exercises") must be properly formatted with square brackets []
        5. All array items must be separated by commas, with no trailing comma after last item
        
        POWERLIFTING/STRENGTH PROGRAMS:
        - For pure strength/powerlifting programs, use ONLY "exercises" array
        - Do NOT add "segments" array unless explicitly mixing strength with skill work
        - Each Day should have ONE "exercises" array containing all lifts for that day
        - Example structure for 3-week powerlifting program:
          "Days": [
            {
              "name": "Day 1: Squat Focus",
              "exercises": [ /* all exercises here */ ]
            },
            {
              "name": "Day 2: Bench Focus", 
              "exercises": [ /* all exercises here */ ]
            },
            {
              "name": "Day 3: Deadlift Focus",
              "exercises": [ /* all exercises here */ ]
            }
          ]
        
        SKILL/TECHNIQUE PROGRAMS:
        - For skill-based training (BJJ, yoga, etc.), use ONLY "segments" array
        - Do NOT add "exercises" array unless explicitly mixing with strength work
        
        HYBRID PROGRAMS (Strength + Skill):
        - When combining strength and skill work in same Day:
          * Use ONE "exercises" array for all strength exercises
          * Use ONE "segments" array for all skill/technique work
          * Never duplicate these keys
        
        ═══════════════════════════════════════════════════════════════
        COMPLETE JSON Structure (ALL FIELDS AVAILABLE):
        ═══════════════════════════════════════════════════════════════
        {
          "Title": "Block name (under 50 characters)",
          "Goal": "Primary training objective (strength/hypertrophy/power/conditioning/mixed/peaking/deload/rehab)",
          "TargetAthlete": "Experience level (Beginner/Intermediate/Advanced)",
          "NumberOfWeeks": <number: total weeks in block> [OPTIONAL, defaults to 1],
          "DurationMinutes": <number: estimated workout duration per session>,
          "Difficulty": <number: 1-5 scale>,
          "Equipment": "Comma-separated equipment list",
          "WarmUp": "Detailed warm-up instructions",
          "Finisher": "Cooldown or finisher instructions",
          "Notes": "Important context, form cues, safety notes",
          "EstimatedTotalTimeMinutes": <number: total session time including warm-up/finisher>,
          "Progression": "Week-to-week progression strategy",
          
          // OPTION A: Single-Day Block (use "Exercises")
          "Exercises": [
            {
              "name": "Exercise name",
              "type": "strength|conditioning|mixed|other" [OPTIONAL, defaults to "strength"],
              "category": "squat|hinge|pressHorizontal|pressVertical|pullHorizontal|pullVertical|carry|core|olympic|conditioning|mobility|mixed|other" [OPTIONAL],
              
              // SIMPLE FORMAT (for quick blocks):
              "setsReps": "3x8" [OPTIONAL if using "sets" array],
              "restSeconds": 120 [OPTIONAL],
              "intensityCue": "RPE 7" [OPTIONAL],
              
              // ADVANCED FORMAT (for detailed programming):
              "sets": [ [OPTIONAL - replaces "setsReps"]
                {
                  "reps": 8,
                  "weight": 135.0 [OPTIONAL],
                  "percentageOfMax": 0.75 [OPTIONAL - 0.0 to 1.0],
                  "rpe": 7.5 [OPTIONAL - 1.0 to 10.0],
                  "rir": 2.5 [OPTIONAL - reps in reserve],
                  "tempo": "3-0-1-0" [OPTIONAL],
                  "restSeconds": 180 [OPTIONAL],
                  "notes": "Focus on depth" [OPTIONAL]
                }
              ],
              
              // CONDITIONING PARAMETERS:
              "conditioningType": "monostructural|mixedModal|emom|amrap|intervals|forTime|forDistance|forCalories|roundsForTime|other" [OPTIONAL],
              "conditioningSets": [ [OPTIONAL]
                {
                  "durationSeconds": 300 [OPTIONAL],
                  "distanceMeters": 1000.0 [OPTIONAL],
                  "calories": 20.0 [OPTIONAL],
                  "rounds": 5 [OPTIONAL],
                  "targetPace": "2:00/500m" [OPTIONAL],
                  "effortDescriptor": "moderate" [OPTIONAL],
                  "restSeconds": 60 [OPTIONAL],
                  "notes": "Maintain steady pace" [OPTIONAL]
                }
              ],
              
              // SUPERSET/CIRCUIT GROUPING:
              "setGroupId": "UUID-string" [OPTIONAL],
              "setGroupKind": "superset|circuit|giantSet|emom|amrap" [OPTIONAL],
              
              // PROGRESSION:
              "progressionType": "weight|volume|custom|skill" [OPTIONAL, defaults to "weight"],
              "progressionDeltaWeight": 5.0 [OPTIONAL],
              "progressionDeltaSets": 1 [OPTIONAL],
              
              // VIDEO DEMONSTRATION:
              "videoUrls": ["https://youtube.com/video1", "https://youtube.com/video2"] [OPTIONAL - array of video URLs for technique demonstration],
              
              "notes": "Exercise-specific notes" [OPTIONAL]
            }
          ],
          
          // OPTION B: Multi-Day Block (use "Days")
          "Days": [ [OPTIONAL - same days repeated for all weeks]
            {
              "name": "Day 1: Upper Body",
              "shortCode": "U1" [OPTIONAL],
              "goal": "strength|hypertrophy|power|conditioning|mixed" [OPTIONAL],
              "notes": "Focus on compound movements" [OPTIONAL],
              
              // GYM WORK - Use exercises array:
              "exercises": [
                // Same exercise structure as above
              ],
              
              // SKILL/TECHNIQUE WORK - Use segments array:
              "segments": [
                {
                  "name": "Warm-up & Movement Drills",  // Or "Technique: Guard Basics", "Live Rolling", etc.
                  "segmentType": "warmup|mobility|technique|drill|positionalSpar|rolling|cooldown|lecture|breathwork|practice|presentation|review|demonstration|discussion|assessment|other",
                  "domain": "grappling|yoga|strength|conditioning|mobility|sports|business|education|analytics|other" [OPTIONAL],
                  "durationMinutes": 15 [OPTIONAL],
                  "objective": "Clear learning objective" [OPTIONAL],
                  
                  // POSITIONS & TECHNIQUES (for martial arts):
                  "positions": ["standing", "guard", "mount", etc.] [OPTIONAL],
                  "techniques": [ [OPTIONAL]
                    {
                      "name": "Technique name",
                      "variant": "Style variation" [OPTIONAL],
                      "keyDetails": ["Key point 1", "Key point 2"],
                      "commonErrors": ["Error 1", "Error 2"],
                      "counters": ["Counter 1"],
                      "followUps": ["Follow-up 1"],
                      "videoUrls": ["https://youtube.com/technique-demo"] [OPTIONAL - array of instructional video URLs]
                    }
                  ],
                  
                  // DRILLING STRUCTURE:
                  "drillPlan": { [OPTIONAL - for warmup drills]
                    "items": [
                      {
                        "name": "Drill name",
                        "workSeconds": 60,
                        "restSeconds": 15,
                        "notes": "Coaching point"
                      }
                    ]
                  },
                  
                  // PARTNER WORK:
                  "partnerPlan": { [OPTIONAL - for technique practice]
                    "rounds": 3,
                    "roundDurationSeconds": 180,
                    "restSeconds": 60,
                    "roles": {
                      "attackerGoal": "Complete technique",
                      "defenderGoal": "Provide resistance",
                      "resistance": 25 [0-100 scale],
                      "switchEverySeconds": 90
                    },
                    "qualityTargets": {
                      "cleanRepsTarget": 10,
                      "successRateTarget": 0.8,
                      "decisionSpeedSeconds": 2.5
                    }
                  },
                  
                  // LIVE ROUNDS:
                  "roundPlan": { [OPTIONAL - for sparring]
                    "rounds": 5,
                    "roundDurationSeconds": 300,
                    "restSeconds": 60,
                    "intensityCue": "moderate|hard|live",
                    "resetRule": "Reset on score/submission",
                    "winConditions": ["Submission", "Points"]
                  },
                  
                  // POSITIONAL SPARRING:
                  "startPosition": "guard" [OPTIONAL],
                  "scoring": { [OPTIONAL]
                    "attackerScoresIf": ["Sweep", "Submission"],
                    "defenderScoresIf": ["Pass guard", "Escape"]
                  },
                  
                  // YOGA/MOBILITY:
                  "flowSequence": [ [OPTIONAL]
                    {
                      "poseName": "Downward Dog",
                      "holdSeconds": 30,
                      "transitionCue": "Flow to plank"
                    }
                  ],
                  "intensityScale": "restorative|easy|moderate|strong|peak" [OPTIONAL],
                  "holdSeconds": 30 [OPTIONAL],
                  "breathCount": 5 [OPTIONAL],
                  "props": ["block", "strap", "bolster"] [OPTIONAL],
                  
                  // BREATHWORK:
                  "breathwork": { [OPTIONAL]
                    "style": "Box breathing",
                    "pattern": "4s inhale / 4s hold / 4s exhale / 4s hold",
                    "durationSeconds": 300
                  },
                  
                  // MEDIA & RESOURCES:
                  "media": { [OPTIONAL]
                    "videoUrl": "https://youtube.com/segment-overview" [OPTIONAL - primary video URL for the segment],
                    "imageUrl": "https://example.com/diagram.png" [OPTIONAL - reference image URL],
                    "diagramAssetId": "asset-id-123" [OPTIONAL - diagram asset identifier],
                    "coachNotesMarkdown": "## Coach Notes\n- Point 1\n- Point 2" [OPTIONAL - markdown formatted coaching notes],
                    "commonFaults": ["Fault 1", "Fault 2"] [OPTIONAL - common mistakes],
                    "keyCues": ["Cue 1", "Cue 2"] [OPTIONAL - key coaching cues],
                    "checkpoints": ["Checkpoint 1", "Checkpoint 2"] [OPTIONAL - assessment checkpoints]
                  },
                  
                  // COACHING & SAFETY:
                  "constraints": ["Constraint 1", "Constraint 2"] [OPTIONAL],
                  "coachingCues": ["Cue 1", "Cue 2"] [OPTIONAL],
                  "safety": { [OPTIONAL]
                    "contraindications": ["No slamming"],
                    "stopIf": ["Sharp pain", "Dizziness"],
                    "intensityCeiling": "75%"
                  },
                  "notes": "Additional notes" [OPTIONAL]
                }
              ]
            }
          ],
          
          // OPTION C: Week-Specific Block (for periodization)
          "Weeks": [ [OPTIONAL - different days for each week]
            [
              // Week 1 days
              {
                "name": "Day 1",
                "exercises": [...],  // Can use exercises
                "segments": [...]    // OR segments OR both
              }
            ],
            [
              // Week 2 days (can differ from Week 1)
              {"name": "Day 1", "exercises": [...]}
            ]
          ]
        }
        
        ═══════════════════════════════════════════════════════════════
        WEEKS INVARIANTS (NON-NEGOTIABLE):
        ═══════════════════════════════════════════════════════════════
        
        When using the "Weeks" array format, the following rules are ABSOLUTE and MUST be enforced:
        
        1. **NumberOfWeeks MUST equal Weeks.length**
           - If you have 4 weeks of data, "NumberOfWeeks": 4 and "Weeks" must contain exactly 4 arrays
           - NEVER set NumberOfWeeks to a different value than the actual number of week arrays provided
           - Example: "NumberOfWeeks": 4 requires "Weeks": [week1, week2, week3, week4]
        
        2. **Each Weeks[i] MUST be an array of Day objects**
           - Week 1 = Weeks[0] = array of Day objects
           - Week 2 = Weeks[1] = array of Day objects
           - NO exceptions - every week must be an array containing Day objects
        
        3. **Each Day MUST contain exactly ONE "exercises" array OR exactly ONE "segments" array (or one of each)**
           - ✅ CORRECT: { "name": "Day 1", "exercises": [...] }
           - ✅ CORRECT: { "name": "Day 1", "segments": [...] }
           - ✅ CORRECT: { "name": "Day 1", "exercises": [...], "segments": [...] }
           - ❌ WRONG: { "name": "Day 1" } // Missing exercises/segments
           - ❌ WRONG: Multiple "exercises" keys in same Day
           - ❌ WRONG: Multiple "segments" keys in same Day
        
        4. **NO placeholder days, NO "progression rule" objects, NO narrative items**
           - Every Day object must be a real, actionable training day
           - NO placeholder text like "Week 2: Similar to Week 1 but..."
           - NO progression rule objects in the Weeks array
           - NO narrative descriptions where Day objects should be
           - If a week truly has fewer training days, include only those days explicitly
        
        5. **If a week has fewer days than others, that MUST be explicit and intentional**
           - Example: If Week 1 has 4 days and Week 4 (deload) has 2 days, provide exactly 2 Day objects in Week 4
           - ✅ CORRECT: Week 4 deload with 2 explicit days
           - ❌ WRONG: Week 4 with "Continue with 2 days from Week 1"
           - ❌ WRONG: Week 4 with placeholder text instead of Day objects
        
        VALIDATION EXAMPLES:
        
        ✅ CORRECT Week Structure:
        {
          "NumberOfWeeks": 3,
          "Weeks": [
            [
              {"name": "Week 1 Day 1", "exercises": [...]},
              {"name": "Week 1 Day 2", "exercises": [...]}
            ],
            [
              {"name": "Week 2 Day 1", "exercises": [...]},
              {"name": "Week 2 Day 2", "exercises": [...]}
            ],
            [
              {"name": "Week 3 Day 1", "exercises": [...]}
            ]
          ]
        }
        
        ❌ WRONG - NumberOfWeeks doesn't match:
        {
          "NumberOfWeeks": 4,  // Claims 4 weeks
          "Weeks": [
            [...],
            [...],
            [...]  // Only 3 weeks provided
          ]
        }
        
        ❌ WRONG - Week contains non-Day objects:
        {
          "Weeks": [
            [{"name": "Day 1", "exercises": [...]}],
            ["Week 2: Same as Week 1 with 5lbs added"]  // Not a Day object!
          ]
        }
        
        ❌ WRONG - Day missing exercises/segments:
        {
          "Weeks": [
            [
              {"name": "Day 1"}  // No exercises or segments!
            ]
          ]
        }
        
        REMEMBER: These invariants are NON-NEGOTIABLE. If you cannot satisfy them, you MUST either:
        - Use "Days" format instead of "Weeks" (if all weeks are identical)
        - Ask the user for clarification
        - Stop and explain why the Weeks format cannot be used
        
        ═══════════════════════════════════════════════════════════════
        USAGE GUIDELINES:
        ═══════════════════════════════════════════════════════════════
        
        FOR GYM WORKOUTS (EXERCISES) - POWERLIFTING, BODYBUILDING, GENERAL STRENGTH:
        1. SIMPLE blocks: Use "Exercises" with "setsReps" format
        2. MULTI-DAY blocks: Use "Days" with detailed "sets" arrays
        3. WEEK-SPECIFIC: Use "Weeks" array for exercise variations
        4. CONDITIONING: Set type="conditioning" and use "conditioningSets"
        5. SUPERSETS: Give exercises same "setGroupId" UUID
        6. CRITICAL: Each Day has exactly ONE "exercises" array containing ALL exercises
        7. NEVER create multiple "exercises" keys or duplicate arrays
        
        FOR SKILL SESSIONS (SEGMENTS) - BJJ, YOGA, MARTIAL ARTS:
        1. BJJ/GRAPPLING: Use technique, drill, positionalSpar, rolling segments
        2. YOGA: Use mobility/warmup segments with flowSequence
        3. BREATHWORK: Use breathwork segment with pattern details
        4. STRUCTURED CLASSES: Organize by segment phases (warmup → technique → drilling → live → cooldown)
        5. QUALITY TRACKING: Use qualityTargets for skill-based progression
        6. CONSTRAINTS: Add specific rules to focus training (e.g., "Must start from inside tie")
        7. CRITICAL: Each Day has exactly ONE "segments" array containing ALL segments
        8. NEVER create multiple "segments" keys or duplicate arrays
        
        HYBRID SESSIONS (Strength + Skill):
        - Put ALL strength work in ONE "exercises" array
        - Put ALL skill/technique work in ONE "segments" array
        - Each array appears exactly ONCE per Day
        - Both can coexist in the same Day but each key appears only once
        """
    }
    
    private var jsonFormatExample: String {
        """
        // EXAMPLE 1: 3-Week Powerlifting Program (3 Days per Week)
        {
          "Title": "3-Week Powerlifting Block",
          "Goal": "strength",
          "TargetAthlete": "Intermediate",
          "NumberOfWeeks": 3,
          "DurationMinutes": 60,
          "Difficulty": 4,
          "Equipment": "Barbell, Rack, Bench, Deadlift Platform",
          "WarmUp": "10 min mobility and activation work",
          "Days": [
            {
              "name": "Day 1: Squat Focus",
              "shortCode": "SQ",
              "goal": "strength",
              "exercises": [
                {
                  "name": "Barbell Back Squat",
                  "type": "strength",
                  "category": "squat",
                  "setsReps": "5x5",
                  "restSeconds": 240,
                  "intensityCue": "RPE 8",
                  "progressionDeltaWeight": 10.0
                },
                {
                  "name": "Romanian Deadlift",
                  "type": "strength",
                  "category": "hinge",
                  "setsReps": "3x8",
                  "restSeconds": 180,
                  "intensityCue": "RPE 7",
                  "progressionDeltaWeight": 5.0
                },
                {
                  "name": "Leg Press",
                  "type": "strength",
                  "category": "squat",
                  "setsReps": "3x10",
                  "restSeconds": 120,
                  "intensityCue": "RPE 7"
                }
              ]
            },
            {
              "name": "Day 2: Bench Press Focus",
              "shortCode": "BP",
              "goal": "strength",
              "exercises": [
                {
                  "name": "Barbell Bench Press",
                  "type": "strength",
                  "category": "pressHorizontal",
                  "setsReps": "5x5",
                  "restSeconds": 240,
                  "intensityCue": "RPE 8",
                  "progressionDeltaWeight": 5.0
                },
                {
                  "name": "Barbell Row",
                  "type": "strength",
                  "category": "pullHorizontal",
                  "setsReps": "4x8",
                  "restSeconds": 180,
                  "intensityCue": "RPE 7",
                  "progressionDeltaWeight": 5.0
                },
                {
                  "name": "Overhead Press",
                  "type": "strength",
                  "category": "pressVertical",
                  "setsReps": "3x8",
                  "restSeconds": 180,
                  "intensityCue": "RPE 7"
                }
              ]
            },
            {
              "name": "Day 3: Deadlift Focus",
              "shortCode": "DL",
              "goal": "strength",
              "exercises": [
                {
                  "name": "Barbell Deadlift",
                  "type": "strength",
                  "category": "hinge",
                  "setsReps": "5x3",
                  "restSeconds": 300,
                  "intensityCue": "RPE 8-9",
                  "progressionDeltaWeight": 10.0
                },
                {
                  "name": "Front Squat",
                  "type": "strength",
                  "category": "squat",
                  "setsReps": "3x6",
                  "restSeconds": 180,
                  "intensityCue": "RPE 7",
                  "progressionDeltaWeight": 5.0
                },
                {
                  "name": "Pull-ups",
                  "type": "strength",
                  "category": "pullVertical",
                  "setsReps": "3xAMRAP",
                  "restSeconds": 120,
                  "intensityCue": "RPE 8"
                }
              ]
            }
          ],
          "Finisher": "10 min core work: planks and ab rollouts",
          "Notes": "Focus on bar speed and technique. Week 3 reduce volume by 20% for recovery.",
          "EstimatedTotalTimeMinutes": 60,
          "Progression": "Add 5-10 lbs per week to main lifts. Week 3 is deload."
        }
        
        // EXAMPLE 2: Full Body Strength (Single Day Format)
        {
          "Title": "Full Body Strength",
          "Goal": "strength",
          "TargetAthlete": "Intermediate",
          "NumberOfWeeks": 4,
          "DurationMinutes": 45,
          "Difficulty": 3,
          "Equipment": "Barbell, Dumbbells, Rack",
          "WarmUp": "5 min dynamic stretching",
          "Exercises": [
            {
              "name": "Barbell Back Squat",
              "type": "strength",
              "category": "squat",
              "setsReps": "3x8",
              "restSeconds": 180,
              "intensityCue": "RPE 7",
              "progressionDeltaWeight": 5.0,
              "videoUrls": ["https://youtube.com/squat-form"]
            },
            {
              "name": "Barbell Bench Press",
              "type": "strength",
              "category": "pressHorizontal",
              "sets": [
                {"reps": 8, "weight": 135, "rpe": 7, "restSeconds": 120},
                {"reps": 8, "weight": 135, "rpe": 7.5, "restSeconds": 120},
                {"reps": 8, "weight": 135, "rpe": 8, "restSeconds": 120}
              ],
              "progressionDeltaWeight": 5.0,
              "videoUrls": ["https://youtube.com/bench-setup", "https://youtube.com/bench-technique"]
            }
          ],
          "Finisher": "10 min cooldown",
          "Notes": "Focus on form. Deload week 4.",
          "EstimatedTotalTimeMinutes": 45,
          "Progression": "Add 5 lbs per week, deload week 4"
        }
        
        // EXAMPLE 3: BJJ Class (Segment-Based)
        {
          "Title": "BJJ Fundamentals Class",
          "Goal": "mixed",
          "TargetAthlete": "Beginner",
          "NumberOfWeeks": 1,
          "DurationMinutes": 60,
          "Difficulty": 3,
          "Equipment": "Grappling mats, gi, training partners",
          "WarmUp": "See segments",
          "Days": [
            {
              "name": "Class: Guard Retention Basics",
              "shortCode": "BJJ1",
              "goal": "mixed",
              "segments": [
                {
                  "name": "Warm-up & Movement Drills",
                  "segmentType": "warmup",
                  "domain": "grappling",
                  "durationMinutes": 10,
                  "objective": "Prepare body for training",
                  "drillPlan": {
                    "items": [
                      {"name": "Hip escapes", "workSeconds": 60, "restSeconds": 15},
                      {"name": "Technical standup", "workSeconds": 60, "restSeconds": 15}
                    ]
                  }
                },
                {
                  "name": "Technique: Closed Guard Basics",
                  "segmentType": "technique",
                  "domain": "grappling",
                  "durationMinutes": 20,
                  "objective": "Learn closed guard structure and basic sweep",
                  "positions": ["closed_guard"],
                  "techniques": [
                    {
                      "name": "Closed guard posture break",
                      "keyDetails": ["Break posture with legs", "Control head", "Create angle"],
                      "commonErrors": ["Opening guard too early", "Not controlling head"],
                      "videoUrls": ["https://youtube.com/closed-guard-posture-break"]
                    }
                  ],
                  "media": {
                    "videoUrl": "https://youtube.com/closed-guard-fundamentals",
                    "coachNotesMarkdown": "## Key Points\n- Maintain tight guard\n- Control distance\n- Break posture first",
                    "keyCues": ["Squeeze knees", "Control head", "Create angle"]
                  },
                  "partnerPlan": {
                    "rounds": 4,
                    "roundDurationSeconds": 180,
                    "restSeconds": 60,
                    "roles": {
                      "attackerGoal": "Break posture and attempt sweep",
                      "defenderGoal": "Maintain posture with light resistance"
                    },
                    "resistance": 30,
                    "switchEverySeconds": 90,
                    "qualityTargets": {
                      "cleanRepsTarget": 8,
                      "successRateTarget": 0.7
                    }
                  }
                },
                {
                  "name": "Positional Sparring",
                  "segmentType": "positionalSpar",
                  "domain": "grappling",
                  "durationMinutes": 15,
                  "objective": "Apply techniques under pressure",
                  "startPosition": "closed_guard",
                  "roundPlan": {
                    "rounds": 5,
                    "roundDurationSeconds": 180,
                    "restSeconds": 30,
                    "intensityCue": "moderate"
                  },
                  "scoring": {
                    "attackerScoresIf": ["Sweep to top", "Submit"],
                    "defenderScoresIf": ["Pass guard", "Stand up"]
                  }
                },
                {
                  "name": "Cooldown",
                  "segmentType": "cooldown",
                  "domain": "mobility",
                  "durationMinutes": 5,
                  "breathwork": {
                    "style": "Box breathing",
                    "pattern": "4s inhale / 4s hold / 4s exhale / 4s hold",
                    "durationSeconds": 300
                  }
                }
              ]
            }
          ],
          "Finisher": "See cooldown segment",
          "Notes": "Focus on fundamentals and safety",
          "EstimatedTotalTimeMinutes": 60,
          "Progression": "Increase resistance 10% per week, add constraints"
        }
        
        // EXAMPLE 4: Hybrid Session (Exercises + Segments)
        {
          "Title": "Strength + Yoga Recovery",
          "Goal": "mixed",
          "TargetAthlete": "Intermediate",
          "NumberOfWeeks": 1,
          "DurationMinutes": 60,
          "Difficulty": 3,
          "Equipment": "Barbell, yoga mat, blocks",
          "Days": [
            {
              "name": "Upper Body + Mobility",
              "exercises": [
                {
                  "name": "Bench Press",
                  "setsReps": "3x8",
                  "restSeconds": 180
                },
                {
                  "name": "Pull-ups",
                  "setsReps": "3x10",
                  "restSeconds": 120
                }
              ],
              "segments": [
                {
                  "name": "Restorative Yoga Flow",
                  "segmentType": "mobility",
                  "domain": "yoga",
                  "durationMinutes": 20,
                  "intensityScale": "easy",
                  "flowSequence": [
                    {"poseName": "Child's Pose", "holdSeconds": 60},
                    {"poseName": "Cat-Cow", "holdSeconds": 45},
                    {"poseName": "Downward Dog", "holdSeconds": 60}
                  ],
                  "props": ["block", "strap"]
                }
              ]
            }
          ],
          "WarmUp": "5 min general",
          "Finisher": "See segments",
          "Notes": "Strength work first, then mobility",
          "EstimatedTotalTimeMinutes": 60,
          "Progression": "Add weight to strength, extend holds in yoga"
        }
        """
    }
    
    // MARK: - Actions
    
    private func parseJSONFromText() {
        let trimmedJSON = pastedJSON.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedJSON.isEmpty else {
            errorMessage = "Please paste JSON content"
            return
        }
        
        guard let data = trimmedJSON.data(using: .utf8) else {
            errorMessage = "Failed to convert text to data"
            return
        }
        
        parseJSONData(data)
    }
    
    private func parseJSONData(_ data: Data) {
        // Clear previous state
        importedBlock = nil
        errorMessage = nil
        
        do {
            let decoder = JSONDecoder()
            let imported = try decoder.decode(ImportedBlock.self, from: data)
            let block = BlockGenerator.convertToBlock(imported, numberOfWeeks: 1)
            importedBlock = block
            errorMessage = nil
        } catch let decodingError as DecodingError {
            errorMessage = "Invalid JSON format: \(formatDecodingError(decodingError))"
        } catch {
            errorMessage = "Failed to parse JSON: \(error.localizedDescription)"
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        
        // Cancel any existing hide task
        hideConfirmationTask?.cancel()
        
        // Show confirmation feedback
        showCopyConfirmation = true
        
        // Hide confirmation after configured duration
        let task = DispatchWorkItem {
            showCopyConfirmation = false
        }
        hideConfirmationTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + confirmationDisplayDuration, execute: task)
    }
    
    private func saveBlock(_ block: Block) {
        blocksRepository.add(block)
        
        // Generate sessions
        let factory = SessionFactory()
        let sessions = factory.makeSessions(for: block)
        for session in sessions {
            sessionsRepository.add(session)
        }
        
        dismiss()
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                errorMessage = "No file selected"
                return
            }
            
            // Security-scoped resource access
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Failed to access file. Please try again."
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let data = try Data(contentsOf: url)
                parseJSONData(data)
            } catch {
                errorMessage = "Failed to read file: \(error.localizedDescription)"
            }
            
        case .failure(let error):
            errorMessage = "File selection error: \(error.localizedDescription)"
        }
    }
    
    private func formatDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .keyNotFound(let key, _):
            return "Missing required field: \(key.stringValue)"
        case .typeMismatch(let type, let context):
            return "Type mismatch at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): expected \(type)"
        case .valueNotFound(let type, let context):
            return "Missing value at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): expected \(type)"
        case .dataCorrupted(let context):
            return "Data corrupted: \(context.debugDescription)"
        @unknown default:
            return "Unknown decoding error"
        }
    }
    
    // MARK: - Theme Colors
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color(UIColor.systemGray6)
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemGray6).opacity(0.3) : Color.white
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : .black
    }
}

// MARK: - Preview

struct BlockGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        BlockGeneratorView()
            .environmentObject(BlocksRepository())
            .environmentObject(SessionsRepository())
    }
}

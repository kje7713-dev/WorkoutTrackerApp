//
//  Repositories.swift
//  Savage By Design – Repositories
//
//  Phase 4+ : In-memory data layer, now with JSON persistence for Blocks.
//

import Foundation
import Combine

// MARK: - BlocksRepository

/// In-memory store for block templates, with simple JSON disk persistence.
/// Phase 6.5: append-only semantics (each Save creates a new Block),
/// keeping the same public API you already use elsewhere.
public final class BlocksRepository: ObservableObject {

    @Published private(set) public var blocks: [Block]

    // Location of the blocks JSON file on disk.
    private static var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("blocks.json")
    }

    public init(blocks: [Block] = []) {
        // Try to load from disk first; if nothing on disk, use the injected seed.
        if let saved = Self.loadFromDisk() {
            self.blocks = saved
        } else {
            self.blocks = blocks
        }
    }

    // MARK: - Public API (same signatures as before)

    /// Return all blocks
    public func allBlocks() -> [Block] {
        blocks
    }

    /// Add a new block (append semantics – each Save creates a new block)
    public func add(_ block: Block) {
        blocks.append(block)
        saveToDisk()
    }

    /// Replace an existing block by id
    public func update(_ block: Block) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else { return }
        blocks[index] = block
        saveToDisk()
    }

    /// Remove a block
    public func delete(_ block: Block) {
        blocks.removeAll { $0.id == block.id }
        saveToDisk()
    }

    /// Replace entire collection (e.g., from cloud sync in future)
    public func replaceAll(with newBlocks: [Block]) {
        blocks = newBlocks
        saveToDisk()
    }

    // MARK: - Persistence

    /// Load blocks from disk if the JSON file exists.
    private static func loadFromDisk() -> [Block]? {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            // No file yet – first launch, or user has never saved a block.
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Block].self, from: data)
            return decoded
        } catch {
            // Non-fatal: log and fall back to in-memory seed.
            print("⚠️ BlocksRepository.loadFromDisk failed: \(error)")
            return nil
        }
    }

    /// Save the current blocks array to disk as JSON with backup mechanism.
    private func saveToDisk() {
        let url = Self.fileURL
        let backupURL = url.deletingLastPathComponent().appendingPathComponent("blocks.backup.json")

        do {
            // Create backup of existing file before overwriting
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: backupURL)
                try? FileManager.default.copyItem(at: url, to: backupURL)
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(blocks)
            
            // Validate data before writing
            _ = try JSONDecoder().decode([Block].self, from: data)
            
            // Write atomically to prevent corruption
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            
            // Clean up old backup after successful write
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try? FileManager.default.removeItem(at: backupURL)
            }
        } catch let encodingError as EncodingError {
            print("⚠️ BlocksRepository.saveToDisk encoding failed: \(encodingError)")
            // Attempt to restore from backup if available
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try? FileManager.default.copyItem(at: backupURL, to: url)
            }
        } catch {
            print("⚠️ BlocksRepository.saveToDisk failed: \(error)")
            // Attempt to restore from backup if available
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try? FileManager.default.copyItem(at: backupURL, to: url)
            }
        }
    }
}

// MARK: - SessionsRepository

/// In-memory store for generated workout sessions, now with JSON persistence.
/// Phase 4: simple flat array; now with disk persistence.
public final class SessionsRepository: ObservableObject {
    @Published private(set) public var sessions: [WorkoutSession]

    // Location of the sessions JSON file on disk. 🚨 ADDED
    private static var fileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("sessions.json")
    }

    public init(sessions: [WorkoutSession] = []) {
        // 🚨 Load from disk first; if nothing on disk, use the injected seed.
        if let saved = Self.loadFromDisk() {
            self.sessions = saved
        } else {
            self.sessions = sessions
        }
    }

    // All sessions for a given block
    public func sessions(forBlockId blockId: BlockID) -> [WorkoutSession] {
        sessions.filter { $0.blockId == blockId }
    }

    // All sessions for a given block + week index
    public func sessions(forBlockId blockId: BlockID, weekIndex: Int) -> [WorkoutSession] {
        sessions.filter { $0.blockId == blockId && $0.weekIndex == weekIndex }
    }

    // Fetch a specific session
    public func session(id: WorkoutSessionID) -> WorkoutSession? {
        sessions.first { $0.id == id }
    }

    // Insert or update a session
    public func save(_ session: WorkoutSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }
        saveToDisk() // 🚨 ADDED
    }

    // Remove all sessions for a given block (e.g., if block structure changes)
    public func deleteSessions(forBlockId blockId: BlockID) {
        sessions.removeAll { $0.blockId == blockId }
        saveToDisk() // 🚨 ADDED
    }

    // Replace all sessions at once (future: after regeneration)
    public func replaceAll(with newSessions: [WorkoutSession]) {
        sessions = newSessions
        saveToDisk() // 🚨 ADDED
    }

    // ✅ NEW: replace sessions for a single block
    public func replaceSessions(forBlockId blockId: BlockID, with new: [WorkoutSession]) {
        sessions.removeAll { $0.blockId == blockId }
        sessions.append(contentsOf: new)
        saveToDisk() // 🚨 ADDED
    }
    
    // MARK: - Persistence 🚨 ADDED METHODS

    /// Load sessions from disk if the JSON file exists.
    private static func loadFromDisk() -> [WorkoutSession]? {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([WorkoutSession].self, from: data)
            return decoded
        } catch {
            print("⚠️ SessionsRepository.loadFromDisk failed: \(error)")
            return nil
        }
    }

    /// Save the current sessions array to disk as JSON with backup mechanism.
    private func saveToDisk() {
        let url = Self.fileURL
        let backupURL = url.deletingLastPathComponent().appendingPathComponent("sessions.backup.json")

        do {
            // Create backup of existing file before overwriting
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: backupURL)
                try? FileManager.default.copyItem(at: url, to: backupURL)
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(sessions)
            
            // Validate data before writing
            _ = try JSONDecoder().decode([WorkoutSession].self, from: data)
            
            // Write atomically to prevent corruption
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            
            // Clean up old backup after successful write
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try? FileManager.default.removeItem(at: backupURL)
            }
        } catch let encodingError as EncodingError {
            print("⚠️ SessionsRepository.saveToDisk encoding failed: \(encodingError)")
            // Attempt to restore from backup if available
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try? FileManager.default.copyItem(at: backupURL, to: url)
            }
        } catch {
            print("⚠️ SessionsRepository.saveToDisk failed: \(error)")
            // Attempt to restore from backup if available
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try? FileManager.default.copyItem(at: backupURL, to: url)
            }
        }
    }
}


// MARK: - ExerciseLibraryRepository

/// Global exercise library used by block builder and sessions.
/// Phase 4: in-memory with optional default seeds.
public final class ExerciseLibraryRepository: ObservableObject {
    @Published private(set) public var exercises: [ExerciseDefinition]

    public init(exercises: [ExerciseDefinition] = []) {
        self.exercises = exercises
    }

    // All exercises
    public func all() -> [ExerciseDefinition] {
        exercises
    }

    // Add a new exercise
    public func add(_ exercise: ExerciseDefinition) {
        exercises.append(exercise)
    }

    // Add by name (e.g., from text in the UI)
    @discardableResult
    public func addCustom(
        name: String,
        type: ExerciseType = .strength,
        category: ExerciseCategory? = nil
    ) -> ExerciseDefinition {
        let definition = ExerciseDefinition(
            name: name,
            type: type,
            category: category,
            defaultConditioningType: nil,
            tags: []
        )
        exercises.append(definition)
        return definition
    }

    // Update an existing exercise
    public func update(_ exercise: ExerciseDefinition) {
        guard let index = exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
        exercises[index] = exercise
    }

    // Delete an exercise
    public func delete(_ exercise: ExerciseDefinition) {
        exercises.removeAll { $0.id == exercise.id }
    }

    // Seed with a small default strength + conditioning library
    public func loadDefaultSeedIfEmpty() {
        guard exercises.isEmpty else { return }

        var seeded: [ExerciseDefinition] = []

        func seed(
            _ name: String,
            type: ExerciseType,
            category: ExerciseCategory? = nil,
            defaultConditioningType: ConditioningType? = nil,
            tags: [String] = []
        ) {
            let def = ExerciseDefinition(
                name: name,
                type: type,
                category: category,
                defaultConditioningType: defaultConditioningType,
                tags: tags
            )
            seeded.append(def)
        }

        // Strength basics
        seed("Back Squat", type: .strength, category: .squat)
        seed("Front Squat", type: .strength, category: .squat)
        seed("Deadlift", type: .strength, category: .hinge)
        seed("Bench Press", type: .strength, category: .pressHorizontal)
        seed("Overhead Press", type: .strength, category: .pressVertical)
        seed("Barbell Row", type: .strength, category: .pullHorizontal)
        seed("Pull-Up", type: .strength, category: .pullVertical)

        // Conditioning basics
        seed("Assault Bike", type: .conditioning, category: .conditioning, defaultConditioningType: .monostructural)
        seed("Row Erg", type: .conditioning, category: .conditioning, defaultConditioningType: .monostructural)
        seed("Ski Erg", type: .conditioning, category: .conditioning, defaultConditioningType: .monostructural)
        seed("Run", type: .conditioning, category: .conditioning, defaultConditioningType: .forDistance)
        seed("Burpee", type: .conditioning, category: .conditioning, defaultConditioningType: .mixedModal)

        exercises = seeded
    }
}

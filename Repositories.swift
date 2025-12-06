//
//  Repositories.swift
//  Savage By Design – Repositories
//
//  Phase 4+: In-memory data layer, now with JSON persistence for Blocks.
//

import Foundation
import Combine

// MARK: - BlocksRepository

/// In-memory store for block templates, with simple JSON disk persistence.
/// Phase 6.5: append-only semantics (each Save creates a new Block).
public final class BlocksRepository: ObservableObject {

    @Published private(set) public var blocks: [Block] {
        didSet {
            persistToDisk()
        }
    }

    public init(blocks: [Block] = []) {
        // Try to load from disk first; if nothing on disk, use the injected seed.
        if let saved = Self.loadFromDisk() {
            self.blocks = saved
        } else {
            self.blocks = blocks
        }
    }

    // Return all blocks
    public func allBlocks() -> [Block] {
        blocks
    }

    // Add a new block (append semantics – each Save creates a new block)
    public func add(_ block: Block) {
        blocks.append(block)
        // didSet on `blocks` will persist
    }

    // Replace an existing block by id
    public func update(_ block: Block) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else { return }
        blocks[index] = block
        // didSet on `blocks` will persist
    }

    // Remove a block
    public func delete(_ block: Block) {
        blocks.removeAll { $0.id == block.id }
        // didSet on `blocks` will persist
    }

    // Replace entire collection (e.g., when loading from disk in the future)
    public func replaceAll(with newBlocks: [Block]) {
        blocks = newBlocks
        // didSet on `blocks` will persist
    }
}

// MARK: - BlocksRepository Persistence

private extension BlocksRepository {

    /// Location of the blocks JSON file on disk.
    static var blocksFileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("blocks.json")
    }

    /// Persist the current blocks array to disk as JSON.
    func persistToDisk() {
        do {
            let data = try JSONEncoder().encode(blocks)
            try data.write(to: Self.blocksFileURL, options: [.atomic])
        } catch {
            // For now we just log; we are not surfacing errors in the UI in Phase 6.5.
            print("⚠️ Failed to save blocks to disk:", error)
        }
    }

    /// Load blocks from disk if the file exists and is decodable.
    static func loadFromDisk() -> [Block]? {
        let url = blocksFileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Block].self, from: data)
            return decoded
        } catch {
            print("⚠️ Failed to load blocks from disk:", error)
            return nil
        }
    }
}

    // MARK: - Public API (unchanged signatures)

    // Return all blocks
    public func allBlocks() -> [Block] {
        blocks
    }

    // Add a new block
    public func add(_ block: Block) {
        blocks.append(block)
        saveToDisk()
    }

    // Replace an existing block by id
    public func update(_ block: Block) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else { return }
        blocks[index] = block
        saveToDisk()
    }

    // Remove a block
    public func delete(_ block: Block) {
        blocks.removeAll { $0.id == block.id }
        saveToDisk()
    }

    // Replace entire collection (e.g., when loading from cloud later)
    public func replaceAll(with newBlocks: [Block]) {
        blocks = newBlocks
        saveToDisk()
    }

    // MARK: - Persistence

    /// Load blocks from disk if the JSON file exists.
    private func loadFromDiskIfAvailable() {
        let path = fileURL.path
        guard FileManager.default.fileExists(atPath: path) else {
            // No file yet – keep whatever was passed into init.
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([Block].self, from: data)
            self.blocks = decoded
        } catch {
            // Non-fatal: just log. Keeps the app running even if the file is corrupted.
            print("⚠️ BlocksRepository.loadFromDiskIfAvailable failed: \(error)")
        }
    }

    /// Save the current blocks array to disk as JSON.
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(blocks)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("⚠️ BlocksRepository.saveToDisk failed: \(error)")
        }
    }
}

// MARK: - SessionsRepository

/// In-memory store for generated workout sessions.
/// Phase 4: simple flat array; later we can add helpers + persistence.
public final class SessionsRepository: ObservableObject {
    @Published private(set) public var sessions: [WorkoutSession]

    public init(sessions: [WorkoutSession] = []) {
        self.sessions = sessions
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
    }

    // Remove all sessions for a given block (e.g., if block structure changes)
    public func deleteSessions(forBlockId blockId: BlockID) {
        sessions.removeAll { $0.blockId == blockId }
    }

    // Replace all sessions at once (future: after regeneration)
    public func replaceAll(with newSessions: [WorkoutSession]) {
        sessions = newSessions
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
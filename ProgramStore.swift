
import Foundation
import Combine

/// Simple JSON file-backed store for all blocks.
final class ProgramStore: ObservableObject {
    @Published var blocks: [BlockTemplate] = [] {
        didSet { save() }
    }

    private let fileName = "blocks.json"
    private var fileURL: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    private func load() {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([BlockTemplate].self, from: data)
            blocks = decoded
        } catch {
            print("❌ Failed to load blocks.json: \(error)")
        }
    }

    private func save() {
        let url = fileURL
        do {
            let data = try JSONEncoder().encode(blocks)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("❌ Failed to save blocks.json: \(error)")
        }
    }

    /// For debugging if you want to wipe everything.
    func deleteAllBlocks() {
        blocks.removeAll()
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("❌ Failed to delete blocks.json: \(error)")
        }
    }
}

import Foundation

extension Notification.Name {
    static let historyDidChange = Self("historyDidChange")
}

@MainActor
final class HistoryStore: @unchecked Sendable {
    private let fileURL: URL
    private let lock = NSLock()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let dir = appSupport.appendingPathComponent("Dikte/History", isDirectory: true)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            self.fileURL = dir.appendingPathComponent("history.json")
        }
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func load() -> [HistoryEntry] {
        lock.lock()
        defer { lock.unlock() }

        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let entries = try? decoder.decode([HistoryEntry].self, from: data) else {
            return []
        }

        return entries.sorted { $0.date > $1.date }
    }

    func save(_ entries: [HistoryEntry]) {
        lock.lock()
        defer { lock.unlock() }

        let sorted = entries.sorted { $0.date > $1.date }
        guard let data = try? encoder.encode(sorted) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func append(_ entry: HistoryEntry) {
        var entries = load()
        entries.append(entry)
        save(entries)
        NotificationCenter.default.post(name: .historyDidChange, object: nil)
    }

    func delete(id: UUID) {
        var entries = load()
        guard let entry = entries.first(where: { $0.id == id }) else { return }
        entries.removeAll { $0.id == id }
        save(entries)
        deleteAssets(for: entry)
        NotificationCenter.default.post(name: .historyDidChange, object: nil)
    }

    func clearAll() {
        let entries = load()
        save([])
        for entry in entries {
            deleteAssets(for: entry)
        }
        cleanupOrphanAssets()
        NotificationCenter.default.post(name: .historyDidChange, object: nil)
    }

    func prune(olderThanDays days: Int) {
        let cutoff = Date().addingTimeInterval(-Double(days) * 24 * 60 * 60)
        var entries = load()
        let toDelete = entries.filter { $0.date < cutoff }
        entries.removeAll { $0.date < cutoff }
        save(entries)
        for entry in toDelete {
            deleteAssets(for: entry)
        }
        cleanupOrphanAssets()
        if !toDelete.isEmpty {
            NotificationCenter.default.post(name: .historyDidChange, object: nil)
        }
    }

    func cleanupOrphanAssets() {
        let entries = load()
        let referencedPaths = Set(entries.flatMap { $0.clipboardItems.compactMap { $0.imageFilePath } })

        let assetDir = ClipboardMonitorService.clipboardAssetsDir
        guard let contents = try? FileManager.default.contentsOfDirectory(at: assetDir, includingPropertiesForKeys: nil) else { return }

        for fileURL in contents {
            if !referencedPaths.contains(fileURL.path) {
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
    }

    private func deleteAssets(for entry: HistoryEntry) {
        for item in entry.clipboardItems {
            if let path = item.imageFilePath {
                try? FileManager.default.removeItem(atPath: path)
            }
        }
    }
}
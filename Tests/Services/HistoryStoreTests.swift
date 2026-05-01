import XCTest
@testable import Dikte

@MainActor
final class HistoryStoreTests: XCTestCase {
    private var store: HistoryStore!
    private var tempDir: URL!
    private var historyFileURL: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("dikte_test_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        historyFileURL = tempDir.appendingPathComponent("history.json")
        store = HistoryStore(fileURL: historyFileURL)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    func testLoadEmptyReturnsEmptyArray() {
        XCTAssertTrue(store.load().isEmpty)
    }

    func testAppendAndLoadReturnsEntries() {
        let entry = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 10.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "test output"
        )
        store.append(entry)
        let loaded = store.load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].id, entry.id)
        XCTAssertEqual(loaded[0].mergedOutput, "test output")
    }

    func testAppendMultipleEntriesSortedByDateDescending() {
        let entry1 = HistoryEntry(
            id: UUID(),
            date: Date().addingTimeInterval(-10),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "first"
        )
        let entry2 = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 10.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "second"
        )
        store.append(entry1)
        store.append(entry2)
        let loaded = store.load()
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].id, entry2.id)
        XCTAssertEqual(loaded[1].id, entry1.id)
    }

    func testDeleteRemovesCorrectEntry() {
        let entry1 = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "keep"
        )
        let entry2 = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 10.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "delete"
        )
        store.append(entry1)
        store.append(entry2)
        store.delete(id: entry2.id)
        let loaded = store.load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].id, entry1.id)
    }

    func testClearAllRemovesAllEntries() {
        let entry = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "test"
        )
        store.append(entry)
        store.clearAll()
        XCTAssertTrue(store.load().isEmpty)
    }

    func testHistoryEntryCodableRoundtrip() {
        let segments = [
            TranscriptSegment(
                id: UUID(),
                text: "Hello world",
                startTime: 0.0,
                endTime: 1.5,
                words: [
                    TranscriptWord(text: "Hello", startTime: 0.0, endTime: 0.5),
                    TranscriptWord(text: "world", startTime: 0.6, endTime: 1.5)
                ]
            )
        ]
        let clipboardItems = [
            ClipboardItem(
                id: UUID(),
                timestamp: Date(),
                type: .text,
                textContent: "copied text",
                imageFilePath: "/tmp/test.txt",
                sourceApp: "Notes",
                fileSize: 1024
            )
        ]
        let entry = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 1.5,
            transcriptSegments: segments,
            clipboardItems: clipboardItems,
            mergedOutput: "Hello world ¹"
        )

        let data = try! JSONEncoder().encode(entry)
        let decoded = try! JSONDecoder().decode(HistoryEntry.self, from: data)

        XCTAssertEqual(decoded.id, entry.id)
        XCTAssertEqual(decoded.mergedOutput, entry.mergedOutput)
        XCTAssertEqual(decoded.transcriptSegments.count, 1)
        XCTAssertEqual(decoded.transcriptSegments[0].text, "Hello world")
        XCTAssertEqual(decoded.clipboardItems.count, 1)
        XCTAssertEqual(decoded.clipboardItems[0].textContent, "copied text")
    }

    func testFormattedProperties() {
        let entry = HistoryEntry(
            id: UUID(),
            date: Date(timeIntervalSince1970: 1_700_000_000),
            duration: 65.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "test"
        )
        XCTAssertEqual(entry.formattedDuration, "01:05")
        XCTAssertEqual(entry.transcriptText, "")
        XCTAssertEqual(entry.clipboardCount, 0)
    }

    func testAppendPostsNotification() {
        let entry = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "test"
        )
        var received = false
        let token = NotificationCenter.default.addObserver(forName: .historyDidChange, object: nil, queue: nil) { _ in
            received = true
        }
        defer { NotificationCenter.default.removeObserver(token) }

        store.append(entry)
        XCTAssertTrue(received, "append should post historyDidChange notification")
    }

    func testDeletePostsNotification() {
        let entry = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "test"
        )
        store.append(entry)

        var received = false
        let token = NotificationCenter.default.addObserver(forName: .historyDidChange, object: nil, queue: nil) { _ in
            received = true
        }
        defer { NotificationCenter.default.removeObserver(token) }

        store.delete(id: entry.id)
        XCTAssertTrue(received, "delete should post historyDidChange notification")
    }

    func testClearAllPostsNotification() {
        let entry = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "test"
        )
        store.append(entry)

        var received = false
        let token = NotificationCenter.default.addObserver(forName: .historyDidChange, object: nil, queue: nil) { _ in
            received = true
        }
        defer { NotificationCenter.default.removeObserver(token) }

        store.clearAll()
        XCTAssertTrue(received, "clearAll should post historyDidChange notification")
    }

    func testPruneRemovesOldEntries() {
        let oldEntry = HistoryEntry(
            id: UUID(),
            date: Date().addingTimeInterval(-8 * 24 * 60 * 60),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "old"
        )
        let recentEntry = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 10.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "recent"
        )
        store.append(oldEntry)
        store.append(recentEntry)

        store.prune(olderThanDays: 7)

        let loaded = store.load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].id, recentEntry.id)
    }

    func testPruneKeepsNewEntries() {
        let entry = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "recent"
        )
        store.append(entry)

        store.prune(olderThanDays: 7)

        let loaded = store.load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].id, entry.id)
    }

    func testPruneDeletesOldEntryAssets() {
        let assetFile = tempDir.appendingPathComponent("clipboard_test_asset.txt")
        try? "asset content".write(to: assetFile, atomically: true, encoding: .utf8)

        let oldEntry = HistoryEntry(
            id: UUID(),
            date: Date().addingTimeInterval(-8 * 24 * 60 * 60),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [
                ClipboardItem(
                    id: UUID(),
                    timestamp: Date(),
                    type: .text,
                    textContent: "test",
                    imageFilePath: assetFile.path,
                    sourceApp: "Notes",
                    fileSize: 1024
                )
            ],
            mergedOutput: "old"
        )
        store.append(oldEntry)

        XCTAssertTrue(FileManager.default.fileExists(atPath: assetFile.path))

        store.prune(olderThanDays: 7)

        XCTAssertFalse(FileManager.default.fileExists(atPath: assetFile.path))
    }

    func testClearAllDeletesAllAssets() {
        let assetFile1 = tempDir.appendingPathComponent("clipboard_asset1.txt")
        let assetFile2 = tempDir.appendingPathComponent("clipboard_asset2.txt")
        try? "content1".write(to: assetFile1, atomically: true, encoding: .utf8)
        try? "content2".write(to: assetFile2, atomically: true, encoding: .utf8)

        let entry = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [
                ClipboardItem(
                    id: UUID(),
                    timestamp: Date(),
                    type: .text,
                    textContent: "test1",
                    imageFilePath: assetFile1.path,
                    sourceApp: "Notes",
                    fileSize: 1024
                ),
                ClipboardItem(
                    id: UUID(),
                    timestamp: Date(),
                    type: .image,
                    textContent: nil,
                    imageFilePath: assetFile2.path,
                    sourceApp: "Safari",
                    fileSize: 2048
                )
            ],
            mergedOutput: "test"
        )
        store.append(entry)

        XCTAssertTrue(FileManager.default.fileExists(atPath: assetFile1.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: assetFile2.path))

        store.clearAll()

        XCTAssertFalse(FileManager.default.fileExists(atPath: assetFile1.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: assetFile2.path))
        XCTAssertTrue(store.load().isEmpty)
    }

    func testDeleteRemovesEntryAssets() {
        let assetFile = tempDir.appendingPathComponent("clipboard_delete_asset.txt")
        try? "asset content".write(to: assetFile, atomically: true, encoding: .utf8)

        let entry = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [
                ClipboardItem(
                    id: UUID(),
                    timestamp: Date(),
                    type: .text,
                    textContent: "test",
                    imageFilePath: assetFile.path,
                    sourceApp: "Notes",
                    fileSize: 1024
                )
            ],
            mergedOutput: "test"
        )
        store.append(entry)
        XCTAssertTrue(FileManager.default.fileExists(atPath: assetFile.path))

        store.delete(id: entry.id)

        XCTAssertFalse(FileManager.default.fileExists(atPath: assetFile.path))
        XCTAssertTrue(store.load().isEmpty)
    }

    func testClearAllCleansOrphanAssets() {
        let orphanFile = ClipboardMonitorService.clipboardAssetsDir.appendingPathComponent("orphan_test_\(UUID().uuidString).txt")
        try? "orphan content".write(to: orphanFile, atomically: true, encoding: .utf8)
        XCTAssertTrue(FileManager.default.fileExists(atPath: orphanFile.path))

        store.clearAll()

        XCTAssertFalse(FileManager.default.fileExists(atPath: orphanFile.path))
    }

    func testPruneCleansOrphanAssets() {
        let recentEntry = HistoryEntry(
            id: UUID(),
            date: Date(),
            duration: 5.0,
            transcriptSegments: [],
            clipboardItems: [],
            mergedOutput: "recent"
        )
        store.append(recentEntry)

        let orphanFile = ClipboardMonitorService.clipboardAssetsDir.appendingPathComponent("orphan_prune_\(UUID().uuidString).txt")
        try? "orphan content".write(to: orphanFile, atomically: true, encoding: .utf8)
        XCTAssertTrue(FileManager.default.fileExists(atPath: orphanFile.path))

        store.prune(olderThanDays: 7)

        XCTAssertFalse(FileManager.default.fileExists(atPath: orphanFile.path))
        XCTAssertEqual(store.load().count, 1)
    }
}

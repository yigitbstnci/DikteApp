import XCTest
@testable import Dikte

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
}

import XCTest
@testable import Dikte

final class OutputFormatTests: XCTestCase {
    private let service = MergerService()
    private let recordingStart = Date(timeIntervalSince1970: 1_000)

    // MARK: - Whitespace & Formatting Tests

    func testMergedOutputContainsNoTrailingWhitespace() {
        let segments = [
            segment("Test sentence.", start: 0, end: 2)
        ]
        let item = clipboardItem(timestamp: recordingStart.addingTimeInterval(1))

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: [item],
            recordingStartTime: recordingStart
        )

        XCTAssertEqual(output, output.trimmingCharacters(in: .whitespacesAndNewlines))
        XCTAssertFalse(output.hasSuffix(" "))
        XCTAssertFalse(output.hasSuffix("\n"))
    }

    func testMergedOutputNoExtraSpacesBetweenAnnotations() {
        let segments = [
            segment("Hello.", start: 0, end: 1)
        ]
        let item1 = clipboardItem(
            timestamp: recordingStart.addingTimeInterval(0.5),
            path: "/tmp/a.txt",
            sourceApp: "App1"
        )
        let item2 = clipboardItem(
            timestamp: recordingStart.addingTimeInterval(0.8),
            path: "/tmp/b.txt",
            sourceApp: "App2"
        )

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: [item1, item2],
            recordingStartTime: recordingStart
        )

        let annotationPattern = "\\[focus-context [¹²]\\]"
        let annotationRange = output.range(of: annotationPattern, options: .regularExpression)
        XCTAssertNotNil(annotationRange)
    }

    // MARK: - Focus-Context Format Tests

    func testMergedOutputFocusContextMarkersAreMonotonic() {
        let segments = [
            segment("First.", start: 0, end: 1),
            segment("Second.", start: 2, end: 3)
        ]
        let items = [
            clipboardItem(timestamp: recordingStart.addingTimeInterval(0.5), path: "/tmp/1.txt", sourceApp: "App"),
            clipboardItem(timestamp: recordingStart.addingTimeInterval(1.5), path: "/tmp/2.txt", sourceApp: "App"),
            clipboardItem(timestamp: recordingStart.addingTimeInterval(2.5), path: "/tmp/3.txt", sourceApp: "App")
        ]

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: items,
            recordingStartTime: recordingStart
        )

        XCTAssertTrue(output.contains("[focus-context ¹]"), "[focus-context ¹] appears once inline")
        XCTAssertTrue(output.contains("[focus-context ²]"), "[focus-context ²] appears once inline")
        XCTAssertTrue(output.contains("[focus-context ³]"), "[focus-context ³] appears once inline")
    }

    func testMergedOutputAnnotationCountMatchesClipboardItems() {
        let segments = [
            segment("Testing.", start: 0, end: 2)
        ]
        let items = [
            clipboardItem(timestamp: recordingStart.addingTimeInterval(1), path: "/tmp/a.txt", sourceApp: "App"),
            clipboardItem(timestamp: recordingStart.addingTimeInterval(1.5), path: "/tmp/b.txt", sourceApp: "App")
        ]

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: items,
            recordingStartTime: recordingStart
        )

        XCTAssertTrue(output.contains("[focus-context ¹]"), "inline annotation ¹ appears")
        XCTAssertTrue(output.contains("[focus-context ²]"), "inline annotation ² appears")
        XCTAssertTrue(output.contains("1  /tmp/a.txt"), "Attachment section uses regular numbers")
        XCTAssertTrue(output.contains("2  /tmp/b.txt"), "Attachment section uses regular numbers")
    }

    // MARK: - Attachments Section Format Tests

    func testMergedOutputAttachmentsSectionExistsWhenClipboardItemsPresent() {
        let segments = [
            segment("Hello world.", start: 0, end: 2)
        ]
        let item = clipboardItem(
            timestamp: recordingStart.addingTimeInterval(1),
            path: "/tmp/test.txt",
            sourceApp: "TestApp",
            fileSize: 100
        )

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: [item],
            recordingStartTime: recordingStart
        )

        XCTAssertTrue(output.contains("Attachments [each file = what speaker is looking at in that moment, in chronological order - read to understand speech references]"), "Output should contain formatted attachments header")
        XCTAssertTrue(output.contains("1  /tmp/test.txt [TestApp]"), "Output should contain formatted attachment line")
    }

    func testMergedOutputAttachmentsSectionHasCorrectNewlineStructure() {
        let segments = [
            segment("Test.", start: 0, end: 1)
        ]
        let item = clipboardItem(timestamp: recordingStart.addingTimeInterval(1))

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: [item],
            recordingStartTime: recordingStart
        )

        XCTAssertTrue(output.contains("\n\nAttachments [each file = what speaker is looking at in that moment, in chronological order - read to understand speech references]\n"), "Attachments section should be preceded by double newline")
        XCTAssertTrue(output.contains("\n1  /tmp/test.txt"), "Attachment lines should start with newline and index")
    }

    func testMergedOutputMultipleAttachmentsAreNumberedSequentially() {
        let segments = [
            segment("Test.", start: 0, end: 1)
        ]
        let items = [
            clipboardItem(timestamp: recordingStart.addingTimeInterval(0.5), path: "/tmp/1.txt", sourceApp: "App", fileSize: 50),
            clipboardItem(timestamp: recordingStart.addingTimeInterval(0.7), path: "/tmp/2.txt", sourceApp: "App", fileSize: 60),
            clipboardItem(timestamp: recordingStart.addingTimeInterval(0.9), path: "/tmp/3.txt", sourceApp: "App", fileSize: 70)
        ]

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: items,
            recordingStartTime: recordingStart
        )

        XCTAssertTrue(output.contains("1  "))
        XCTAssertTrue(output.contains("2  "))
        XCTAssertTrue(output.contains("3  "))
    }

    func testMergedOutputEmptyTranscriptOnlyShowsAttachments() {
        let output = service.merge(
            transcriptSegments: [],
            clipboardItems: [
                clipboardItem(timestamp: recordingStart, path: "/tmp/test.txt", sourceApp: "App", fileSize: 10)
            ],
            recordingStartTime: recordingStart
        )

        XCTAssertTrue(output.hasPrefix("Attachments [each file = what speaker is looking at in that moment, in chronological order - read to understand speech references]"))
    }

    // MARK: - Edge Cases

    func testMergedOutputEmptyClipboardItemPath() {
        let segments = [
            segment("Test.", start: 0, end: 1)
        ]
        let item = ClipboardItem(
            id: UUID(),
            timestamp: recordingStart.addingTimeInterval(1),
            type: .text,
            textContent: "content",
            imageFilePath: nil,
            sourceApp: nil,
            fileSize: nil
        )

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: [item],
            recordingStartTime: recordingStart
        )

        XCTAssertTrue(output.contains("(inline text)"))
    }

    func testMergedOutputURLItemShowsURLInAttachments() {
        let segments = [
            segment("See link.", start: 0, end: 1)
        ]
        let item = ClipboardItem(
            id: UUID(),
            timestamp: recordingStart.addingTimeInterval(1),
            type: .url,
            textContent: "https://example.com",
            imageFilePath: nil,
            sourceApp: "Browser",
            fileSize: 20
        )

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: [item],
            recordingStartTime: recordingStart
        )

        XCTAssertTrue(output.contains("https://example.com"))
        XCTAssertTrue(output.contains("[Browser]"))
    }

    // MARK: - Helper

    private func segment(_ text: String, start: TimeInterval, end: TimeInterval) -> TranscriptSegment {
        TranscriptSegment(
            id: UUID(),
            text: text,
            startTime: start,
            endTime: end
        )
    }

    private func clipboardItem(
        timestamp: Date,
        path: String? = "/tmp/test.txt",
        sourceApp: String? = "TestApp",
        fileSize: Int64 = 1024
    ) -> ClipboardItem {
        ClipboardItem(
            id: UUID(),
            timestamp: timestamp,
            type: .text,
            textContent: "test",
            imageFilePath: path,
            sourceApp: sourceApp,
            fileSize: fileSize
        )
    }
}
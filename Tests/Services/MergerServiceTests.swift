import XCTest
@testable import Dikte

final class MergerServiceTests: XCTestCase {
    private let service = MergerService()
    private let recordingStart = Date(timeIntervalSince1970: 1_000)

    func testMergeInsertsAnnotationsAndAttachmentsInTimestampOrder() {
        let segments = [
            segment("Ilk cumle.", start: 0, end: 2),
            segment("Ikinci cumle.", start: 4, end: 6),
        ]

        let laterImage = clipboardItem(
            type: .image,
            timestamp: recordingStart.addingTimeInterval(7),
            textContent: nil,
            path: "/tmp/dikte-image.png",
            sourceApp: "CleanShot X",
            fileSize: 2_048
        )
        let duringFirstSegment = clipboardItem(
            type: .text,
            timestamp: recordingStart.addingTimeInterval(1),
            textContent: "copied text",
            path: "/tmp/dikte-text.txt",
            sourceApp: "Notes",
            fileSize: 11
        )
        let betweenSegments = clipboardItem(
            type: .url,
            timestamp: recordingStart.addingTimeInterval(3),
            textContent: "https://example.com/docs",
            path: nil,
            sourceApp: "Safari",
            fileSize: 24
        )

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: [laterImage, betweenSegments, duringFirstSegment],
            recordingStartTime: recordingStart
        )

        XCTAssertEqual(
            output,
            """
            Ilk cumle. ¹ ² Ikinci cumle. ³

            Attachments

            1  /tmp/dikte-text.txt [Notes] (11 B)
            2  https://example.com/docs [Safari] (24 B)
            3  /tmp/dikte-image.png [CleanShot X] (2 KB)
            """
        )
    }

    func testMergeReturnsOnlyAttachmentsWhenTranscriptIsEmpty() {
        let item = clipboardItem(
            type: .text,
            timestamp: recordingStart.addingTimeInterval(1),
            textContent: "only clipboard",
            path: "/tmp/clipboard.txt",
            sourceApp: "Ghostty",
            fileSize: 1_536
        )

        let output = service.merge(
            transcriptSegments: [],
            clipboardItems: [item],
            recordingStartTime: recordingStart
        )

        XCTAssertEqual(
            output,
            """
            Attachments

            1  /tmp/clipboard.txt [Ghostty] (1 KB)
            """
        )
    }

    func testMergeReturnsEmptyStringWhenThereIsNoTranscriptOrClipboardItem() {
        let output = service.merge(
            transcriptSegments: [],
            clipboardItems: [],
            recordingStartTime: recordingStart
        )

        XCTAssertEqual(output, "")
    }

    func testMergeUsesWordTimingsForClipboardPlacementInsideLongSegment() {
        let segments = [
            TranscriptSegment(
                text: "Clipboard oncesi ve sonrasi",
                startTime: 0,
                endTime: 4,
                words: [
                    TranscriptWord(text: "Clipboard", startTime: 0.1, endTime: 0.7),
                    TranscriptWord(text: "oncesi", startTime: 0.8, endTime: 1.3),
                    TranscriptWord(text: "ve", startTime: 2.0, endTime: 2.2),
                    TranscriptWord(text: "sonrasi", startTime: 2.3, endTime: 2.9),
                ]
            )
        ]
        let item = clipboardItem(
            type: .text,
            timestamp: recordingStart.addingTimeInterval(1.6),
            textContent: "copied",
            path: "/tmp/copied.txt",
            sourceApp: "Xcode",
            fileSize: 6
        )

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: [item],
            recordingStartTime: recordingStart
        )

        XCTAssertEqual(
            output,
            """
            Clipboard oncesi ¹ ve sonrasi

            Attachments

            1  /tmp/copied.txt [Xcode] (6 B)
            """
        )
    }

    func testMergeHandlesMultipleClipboardItemsAtSameTimestamp() {
        let segments = [
            segment("Test.", start: 0, end: 1)
        ]
        let item1 = clipboardItem(
            type: .text,
            timestamp: recordingStart.addingTimeInterval(0.5),
            textContent: "first",
            path: "/tmp/first.txt",
            sourceApp: "App1",
            fileSize: 5
        )
        let item2 = clipboardItem(
            type: .image,
            timestamp: recordingStart.addingTimeInterval(0.5),
            textContent: nil,
            path: "/tmp/second.png",
            sourceApp: "App2",
            fileSize: 100
        )

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: [item1, item2],
            recordingStartTime: recordingStart
        )

        XCTAssertTrue(output.contains("¹"))
        XCTAssertTrue(output.contains("²"))
        XCTAssertTrue(output.contains("/tmp/first.txt"))
        XCTAssertTrue(output.contains("/tmp/second.png"))
    }

    func testMergePlacesAnnotationsAtSegmentBoundaries() {
        let segments = [
            segment("Start end.", start: 0, end: 2)
        ]
        let itemAtStart = clipboardItem(
            type: .text,
            timestamp: recordingStart.addingTimeInterval(0.0),
            textContent: "at start",
            path: "/tmp/start.txt",
            sourceApp: "App",
            fileSize: 10
        )
        let itemAtEnd = clipboardItem(
            type: .text,
            timestamp: recordingStart.addingTimeInterval(2.0),
            textContent: "at end",
            path: "/tmp/end.txt",
            sourceApp: "App",
            fileSize: 10
        )

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: [itemAtStart, itemAtEnd],
            recordingStartTime: recordingStart
        )

        XCTAssertTrue(output.contains("¹"))
        XCTAssertTrue(output.contains("²"))
    }

    func testMergeHandlesUnsortedClipboardItems() {
        let segments = [
            segment("Ordered.", start: 0, end: 2)
        ]
        let unsortedItems = [
            clipboardItem(
                type: .image,
                timestamp: recordingStart.addingTimeInterval(5),
                textContent: nil,
                path: "/tmp/third.png",
                sourceApp: "App",
                fileSize: 300
            ),
            clipboardItem(
                type: .text,
                timestamp: recordingStart.addingTimeInterval(1),
                textContent: "second",
                path: "/tmp/second.txt",
                sourceApp: "App",
                fileSize: 10
            ),
            clipboardItem(
                type: .url,
                timestamp: recordingStart.addingTimeInterval(0.5),
                textContent: "https://first.com",
                path: nil,
                sourceApp: "App",
                fileSize: 20
            )
        ]

        let output = service.merge(
            transcriptSegments: segments,
            clipboardItems: unsortedItems,
            recordingStartTime: recordingStart
        )

        XCTAssertTrue(output.contains("https://first.com"))
        XCTAssertTrue(output.contains("second"))
        XCTAssertTrue(output.contains("third.png"))
    }

    private func segment(_ text: String, start: TimeInterval, end: TimeInterval) -> TranscriptSegment {
        TranscriptSegment(
            id: UUID(),
            text: text,
            startTime: start,
            endTime: end
        )
    }

    private func clipboardItem(
        type: ClipboardItem.ClipboardItemType,
        timestamp: Date,
        textContent: String?,
        path: String?,
        sourceApp: String?,
        fileSize: Int64
    ) -> ClipboardItem {
        ClipboardItem(
            id: UUID(),
            timestamp: timestamp,
            type: type,
            textContent: textContent,
            imageFilePath: path,
            sourceApp: sourceApp,
            fileSize: fileSize
        )
    }
}

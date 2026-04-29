import XCTest
@testable import Dikte

final class ClipboardItemTests: XCTestCase {
    private let recordingStart = Date(timeIntervalSince1970: 1_000)

    // MARK: - formattedFileSize Tests

    func testFormattedFileSizeBytes() {
        let item = makeClipboardItem(fileSize: 512)
        XCTAssertEqual(item.formattedFileSize, "512 B")
    }

    func testFormattedFileSizeKilobytes() {
        let item = makeClipboardItem(fileSize: 2_048)
        XCTAssertEqual(item.formattedFileSize, "2 KB")
    }

    func testFormattedFileSizeMegabytes() {
        let item = makeClipboardItem(fileSize: 1_234_567)
        XCTAssertEqual(item.formattedFileSize, "1.2 MB")
    }

    func testFormattedFileSizeExactly1KB() {
        let item = makeClipboardItem(fileSize: 1024)
        XCTAssertEqual(item.formattedFileSize, "1 KB")
    }

    func testFormattedFileSizeNilReturnsZeroKB() {
        let item = ClipboardItem(
            id: UUID(),
            timestamp: recordingStart,
            type: .text,
            textContent: "test",
            imageFilePath: nil,
            sourceApp: "TestApp",
            fileSize: nil
        )
        XCTAssertEqual(item.formattedFileSize, "0 KB")
    }

    // MARK: - attachmentPath Tests

    func testAttachmentPathForTextType() {
        let item = makeClipboardItem(type: .text, path: "/tmp/text.txt")
        XCTAssertEqual(item.attachmentPath, "/tmp/text.txt")
    }

    func testAttachmentPathForURLType() {
        let item = makeClipboardItem(type: .url, textContent: "https://example.com")
        XCTAssertEqual(item.attachmentPath, "https://example.com")
    }

    func testAttachmentPathForImageType() {
        let item = makeClipboardItem(type: .image, path: "/tmp/image.png")
        XCTAssertEqual(item.attachmentPath, "/tmp/image.png")
    }

    func testAttachmentPathForTextWithNilPathReturnsInlineText() {
        let item = ClipboardItem(
            id: UUID(),
            timestamp: recordingStart,
            type: .text,
            textContent: "some text",
            imageFilePath: nil,
            sourceApp: "TestApp",
            fileSize: 10
        )
        XCTAssertEqual(item.attachmentPath, "(inline text)")
    }

    // MARK: - attachmentLine Tests

    func testAttachmentLineTextItem() {
        let item = makeClipboardItem(
            type: .text,
            path: "/tmp/dikte-text.txt",
            sourceApp: "Notes",
            fileSize: 11
        )
        let line = item.attachmentLine(index: 1)
        XCTAssertEqual(line, "1  /tmp/dikte-text.txt [Notes] (11 B)")
    }

    func testAttachmentLineURLItem() {
        let item = makeClipboardItem(
            type: .url,
            textContent: "https://example.com/docs",
            sourceApp: "Safari",
            fileSize: 24
        )
        let line = item.attachmentLine(index: 2)
        XCTAssertEqual(line, "2  https://example.com/docs [Safari] (24 B)")
    }

    func testAttachmentLineImageItem() {
        let item = makeClipboardItem(
            type: .image,
            path: "/tmp/dikte-image.png",
            sourceApp: "CleanShot X",
            fileSize: 2_048
        )
        let line = item.attachmentLine(index: 3)
        XCTAssertEqual(line, "3  /tmp/dikte-image.png [CleanShot X] (2 KB)")
    }

    func testAttachmentLineWithoutSourceApp() {
        let item = makeClipboardItem(
            type: .text,
            path: "/tmp/no-app.txt",
            sourceApp: nil,
            fileSize: 15
        )
        let line = item.attachmentLine(index: 5)
        XCTAssertEqual(line, "5  /tmp/no-app.txt (15 B)")
    }

    // MARK: - Helper

    private func makeClipboardItem(
        type: ClipboardItem.ClipboardItemType = .text,
        textContent: String? = "test content",
        path: String? = "/tmp/test.txt",
        sourceApp: String? = "TestApp",
        fileSize: Int64 = 1024
    ) -> ClipboardItem {
        ClipboardItem(
            id: UUID(),
            timestamp: recordingStart,
            type: type,
            textContent: textContent,
            imageFilePath: path,
            sourceApp: sourceApp,
            fileSize: fileSize
        )
    }
}
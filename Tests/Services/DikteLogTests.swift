import XCTest
@testable import Dikte

final class DikteLogTests: XCTestCase {
    func testMakeLineAppendsEscapedMetadataWithoutDroppingColumns() {
        let line = DikteLog.makeLine(
            timestamp: Date(timeIntervalSince1970: 1_800_000_000),
            level: .info,
            area: "app",
            event: "processing.complete",
            message: "Done.",
            metadata: [
                "bad key": "value",
                "count": 2,
                "flag": true,
                "path": "/tmp/Dikte Output.txt",
                "session": "abc123"
            ]
        )

        XCTAssertTrue(line.contains("INF app.processing.complete"))
        XCTAssertTrue(line.contains("Done. |"))
        XCTAssertTrue(line.contains("bad_key=value"))
        XCTAssertTrue(line.contains("count=2"))
        XCTAssertTrue(line.contains("flag=true"))
        XCTAssertTrue(line.contains("path=\"/tmp/Dikte Output.txt\""))
        XCTAssertTrue(line.contains("session=abc123"))
    }

    func testMakeLineCanRenderMetadataOnlyMessages() {
        let line = DikteLog.makeLine(
            timestamp: Date(timeIntervalSince1970: 1_800_000_000),
            level: .warning,
            area: "audio",
            event: "recording.empty",
            message: "",
            metadata: [
                "frames": 0,
                "session": "abc123"
            ]
        )

        XCTAssertTrue(line.contains("WRN audio.recording.empty"))
        XCTAssertTrue(line.contains("frames=0"))
        XCTAssertTrue(line.contains("session=abc123"))
        XCTAssertEqual(line.components(separatedBy: " | ").count, 2)
    }
}

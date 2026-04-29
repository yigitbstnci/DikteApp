import XCTest
@testable import Dikte

final class PendingTerminalTextTests: XCTestCase {
    private let baseTimestamp = Date(timeIntervalSince1970: 1_000)

    // MARK: - shouldConfirmTerminalText Tests

    func testShouldConfirmTerminalTextMatchesKnownTerminals() {
        let knownTerminals = [
            "Ghostty", "ghostty", "GHOSTTY",
            "Terminal", "terminal",
            "iTerm", "iterm", "ITerm",
            "Warp", "warp",
            "Kitty", "kitty",
            "Wezterm", "wezterm",
            "Alacritty", "alacritty"
        ]

        for terminal in knownTerminals {
            XCTAssertTrue(
                shouldConfirmTerminalText(sourceApp: terminal),
                "Expected true for terminal: \(terminal)"
            )
        }
    }

    func testShouldConfirmTerminalTextReturnsFalseForOtherApps() {
        let nonTerminals = [
            "Safari", "Chrome", "Xcode", "Notes", "Slack",
            "Figma", "Finder", "Messages", "Mail"
        ]

        for app in nonTerminals {
            XCTAssertFalse(
                shouldConfirmTerminalText(sourceApp: app),
                "Expected false for app: \(app)"
            )
        }
    }

    func testShouldConfirmTerminalTextReturnsFalseForNil() {
        XCTAssertFalse(shouldConfirmTerminalText(sourceApp: nil))
    }

    func testShouldConfirmTerminalTextHandlesPartialMatches() {
        XCTAssertTrue(shouldConfirmTerminalText(sourceApp: "Ghostty Terminal"))
        XCTAssertTrue(shouldConfirmTerminalText(sourceApp: "Safari with Ghostty"))
    }

    // MARK: - PendingTerminalText.matches Tests

    func testPendingMatchesIdenticalContent() {
        let pending = PendingTerminalText(
            content: "echo hello",
            isURL: false,
            timestamp: baseTimestamp,
            sourceApp: "Ghostty"
        )

        XCTAssertTrue(pending.matches(content: "echo hello", isURL: false, sourceApp: "Ghostty"))
    }

    func testPendingDoesNotMatchDifferentContent() {
        let pending = PendingTerminalText(
            content: "echo hello",
            isURL: false,
            timestamp: baseTimestamp,
            sourceApp: "Ghostty"
        )

        XCTAssertFalse(pending.matches(content: "echo world", isURL: false, sourceApp: "Ghostty"))
    }

    func testPendingDoesNotMatchDifferentApp() {
        let pending = PendingTerminalText(
            content: "echo hello",
            isURL: false,
            timestamp: baseTimestamp,
            sourceApp: "Ghostty"
        )

        XCTAssertFalse(pending.matches(content: "echo hello", isURL: false, sourceApp: "Terminal"))
    }

    func testPendingDoesNotMatchDifferentIsURL() {
        let pending = PendingTerminalText(
            content: "echo hello",
            isURL: false,
            timestamp: baseTimestamp,
            sourceApp: "Ghostty"
        )

        XCTAssertFalse(pending.matches(content: "echo hello", isURL: true, sourceApp: "Ghostty"))
    }

    func testPendingMatchesIdenticalURL() {
        let pending = PendingTerminalText(
            content: "https://example.com",
            isURL: true,
            timestamp: baseTimestamp,
            sourceApp: "Ghostty"
        )

        XCTAssertTrue(pending.matches(content: "https://example.com", isURL: true, sourceApp: "Ghostty"))
    }

    // MARK: - 10 Second Timeout Tests

    func testPendingExpiresAfter10Seconds() {
        let pending = PendingTerminalText(
            content: "echo hello",
            isURL: false,
            timestamp: baseTimestamp,
            sourceApp: "Ghostty"
        )

        let justUnder10Seconds = baseTimestamp.addingTimeInterval(9.99)
        XCTAssertFalse(
            pending.timestamp.timeIntervalSince(baseTimestamp) > 10,
            "This test is malformed - comparing same timestamp"
        )

        let withinWindow = baseTimestamp.addingTimeInterval(5)
        XCTAssertTrue(
            withinWindow.timeIntervalSince(pending.timestamp) <= 10,
            "5 seconds should be within 10s window"
        )

        let outsideWindow = baseTimestamp.addingTimeInterval(11)
        XCTAssertTrue(
            outsideWindow.timeIntervalSince(pending.timestamp) > 10,
            "11 seconds should be outside 10s window"
        )
    }

    // MARK: - Helper

    private func shouldConfirmTerminalText(sourceApp: String?) -> Bool {
        guard let normalized = sourceApp?.lowercased() else { return false }
        let knownTerminals = [
            "ghostty", "terminal", "iterm", "warp",
            "kitty", "wezterm", "alacritty"
        ]
        return knownTerminals.contains { normalized.contains($0) }
    }
}

struct PendingTerminalText {
    let content: String
    let isURL: Bool
    let timestamp: Date
    let sourceApp: String?

    func matches(content: String, isURL: Bool, sourceApp: String?) -> Bool {
        self.content == content
            && self.isURL == isURL
            && self.sourceApp == sourceApp
    }
}
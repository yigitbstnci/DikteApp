import XCTest
@testable import Dikte

final class PendingTerminalTextTests: XCTestCase {
    private let baseTimestamp = Date(timeIntervalSince1970: 1_000)

    // MARK: - TerminalClipboardTextConfirmation Tests

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
                TerminalClipboardTextConfirmation.shouldRequireConfirmation(sourceApp: terminal),
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
                TerminalClipboardTextConfirmation.shouldRequireConfirmation(sourceApp: app),
                "Expected false for app: \(app)"
            )
        }
    }

    func testShouldConfirmTerminalTextReturnsFalseForNil() {
        XCTAssertFalse(TerminalClipboardTextConfirmation.shouldRequireConfirmation(sourceApp: nil))
    }

    func testShouldConfirmTerminalTextHandlesPartialMatches() {
        XCTAssertTrue(TerminalClipboardTextConfirmation.shouldRequireConfirmation(sourceApp: "Ghostty Terminal"))
        XCTAssertTrue(TerminalClipboardTextConfirmation.shouldRequireConfirmation(sourceApp: "Safari with Ghostty"))
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

    // MARK: - Confirmation Window Tests

    func testPendingConfirmsWithin10Seconds() {
        let pending = PendingTerminalText(
            content: "echo hello",
            isURL: false,
            timestamp: baseTimestamp,
            sourceApp: "Ghostty"
        )

        let withinWindow = baseTimestamp.addingTimeInterval(5)
        XCTAssertTrue(
            pending.isConfirmed(
                content: "echo hello",
                isURL: false,
                sourceApp: "Ghostty",
                timestamp: withinWindow
            )
        )
    }

    func testPendingConfirmsAt10SecondBoundary() {
        let pending = PendingTerminalText(
            content: "echo hello",
            isURL: false,
            timestamp: baseTimestamp,
            sourceApp: "Ghostty"
        )

        XCTAssertTrue(
            pending.isConfirmed(
                content: "echo hello",
                isURL: false,
                sourceApp: "Ghostty",
                timestamp: baseTimestamp.addingTimeInterval(TerminalClipboardTextConfirmation.confirmationWindow)
            )
        )
    }

    func testPendingExpiresAfter10Seconds() {
        let pending = PendingTerminalText(
            content: "echo hello",
            isURL: false,
            timestamp: baseTimestamp,
            sourceApp: "Ghostty"
        )

        let outsideWindow = baseTimestamp.addingTimeInterval(11)
        XCTAssertFalse(
            pending.isConfirmed(
                content: "echo hello",
                isURL: false,
                sourceApp: "Ghostty",
                timestamp: outsideWindow
            )
        )
    }

    func testPendingDoesNotConfirmBeforeOriginalTimestamp() {
        let pending = PendingTerminalText(
            content: "echo hello",
            isURL: false,
            timestamp: baseTimestamp,
            sourceApp: "Ghostty"
        )

        XCTAssertFalse(
            pending.isConfirmed(
                content: "echo hello",
                isURL: false,
                sourceApp: "Ghostty",
                timestamp: baseTimestamp.addingTimeInterval(-1)
            )
        )
    }
}

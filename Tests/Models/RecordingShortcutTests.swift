import KeyboardShortcuts
import XCTest
@testable import Dikte

final class RecordingShortcutTests: XCTestCase {
    private func withDefaults(_ test: (UserDefaults) -> Void) {
        let suite = "RecordingShortcutTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        test(defaults)
    }

    func testLegacyDefaultMigratesOnce() {
        withDefaults { defaults in
            XCTAssertEqual(
                RecordingShortcut.migrate(RecordingShortcut.legacyDefault, defaults: defaults),
                .init(.space, modifiers: [.control, .shift])
            )
            XCTAssertEqual(
                RecordingShortcut.migrate(RecordingShortcut.legacyDefault, defaults: defaults),
                RecordingShortcut.legacyDefault
            )
        }
    }

    func testCustomShortcutIsPreserved() {
        withDefaults { defaults in
            let custom = KeyboardShortcuts.Shortcut(.r, modifiers: [.control, .shift])
            XCTAssertEqual(RecordingShortcut.migrate(custom, defaults: defaults), custom)
        }
    }

    func testDisabledShortcutIsPreserved() {
        withDefaults { defaults in
            XCTAssertNil(RecordingShortcut.migrate(nil, defaults: defaults))
        }
    }
}

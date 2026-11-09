import Foundation
import KeyboardShortcuts

enum RecordingShortcut {
    static let defaultShortcut = KeyboardShortcuts.Shortcut(.space, modifiers: [.control, .shift])
    static let legacyDefault = KeyboardShortcuts.Shortcut(.space, modifiers: [.command, .shift])

    static func migrate(
        _ shortcut: KeyboardShortcuts.Shortcut?,
        defaults: UserDefaults
    ) -> KeyboardShortcuts.Shortcut? {
        let key = "dikte.recordingShortcutDefaultMigrated"
        guard !defaults.bool(forKey: key) else { return shortcut }
        defaults.set(true, forKey: key)
        return shortcut == legacyDefault ? defaultShortcut : shortcut
    }
}

extension KeyboardShortcuts.Name {
    static let toggleRecording = Self("toggleRecording", default: RecordingShortcut.defaultShortcut)
}

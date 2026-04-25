import Foundation
import AppKit

/// Represents a single item captured from the clipboard during recording.
struct ClipboardItem: Identifiable, Sendable {
    let id: UUID
    let timestamp: Date          // When it was copied
    let type: ClipboardItemType
    let textContent: String?     // For text / URL
    let imageFilePath: String?   // For saved image file path

    /// Relative time in seconds since recording started
    var relativeTime: TimeInterval = 0

    enum ClipboardItemType: String, Sendable {
        case text
        case url
        case image
    }

    /// Returns a markdown representation of this clipboard item.
    var markdownRepresentation: String {
        switch type {
        case .text:
            return "```\n\(textContent ?? "")\n```"
        case .url:
            return "[\(textContent ?? "link")](\(textContent ?? ""))"
        case .image:
            if let path = imageFilePath {
                return "![Ekran Görüntüsü](\(path))"
            }
            return "[Görsel kaydedilemedi]"
        }
    }
}

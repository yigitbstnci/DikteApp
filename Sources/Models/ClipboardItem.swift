import Foundation
import AppKit

/// Represents a single item captured from the clipboard during recording.
struct ClipboardItem: Identifiable, Sendable {
    let id: UUID
    let timestamp: Date          // When it was copied
    let type: ClipboardItemType
    let textContent: String?     // For text / URL
    let imageFilePath: String?   // For saved image file path
    let sourceApp: String?       // Which app the content was copied from
    let fileSize: Int64?         // File size in bytes (for saved items)

    enum ClipboardItemType: String, Sendable {
        case text
        case url
        case image
    }

    /// Human-readable file size string (e.g. "2252 KB", "1.2 MB")
    var formattedFileSize: String {
        guard let size = fileSize else { return "0 KB" }
        if size < 1024 {
            return "\(size) B"
        } else if size < 1024 * 1024 {
            return "\(size / 1024) KB"
        } else {
            return String(format: "%.1f MB", Double(size) / (1024 * 1024))
        }
    }

    /// The file path or content description used in the Attachments section.
    var attachmentPath: String {
        switch type {
        case .text:
            // For text, save to a temp file and return path (handled at capture time)
            return imageFilePath ?? "(inline text)"
        case .url:
            return textContent ?? "(url)"
        case .image:
            return imageFilePath ?? "(image)"
        }
    }

    /// Single-line attachment description: `/path/to/file [AppName] (Size)`
    func attachmentLine(index: Int) -> String {
        let appLabel = sourceApp.map { " [\($0)]" } ?? ""
        return "\(index)  \(attachmentPath)\(appLabel) (\(formattedFileSize))"
    }
}

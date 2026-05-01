import Foundation

struct HistoryEntry: Identifiable, Codable, Sendable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let transcriptSegments: [TranscriptSegment]
    let clipboardItems: [ClipboardItem]
    let mergedOutput: String

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var transcriptText: String {
        transcriptSegments.map(\.text).joined(separator: " ")
    }

    var clipboardCount: Int {
        clipboardItems.count
    }
}

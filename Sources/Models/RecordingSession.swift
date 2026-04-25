import Foundation

/// A single segment from the speech-to-text transcription with timing info.
struct TranscriptSegment: Identifiable, Sendable {
    let id: UUID
    let text: String
    let startTime: TimeInterval   // seconds from start of recording
    let endTime: TimeInterval     // seconds from start of recording
}

/// Represents a complete recording session with all associated data.
struct RecordingSession: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let audioFileURL: URL
    let transcriptSegments: [TranscriptSegment]
    let clipboardItems: [ClipboardItem]
    let mergedOutput: String
}

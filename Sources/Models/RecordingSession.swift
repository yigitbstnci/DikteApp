import Foundation

/// A single segment from the speech-to-text transcription with timing info.
struct TranscriptSegment: Identifiable, Sendable {
    let id: UUID
    let text: String
    let startTime: TimeInterval   // seconds from start of recording
    let endTime: TimeInterval     // seconds from start of recording
    let words: [TranscriptWord]

    init(
        id: UUID = UUID(),
        text: String,
        startTime: TimeInterval,
        endTime: TimeInterval,
        words: [TranscriptWord] = []
    ) {
        self.id = id
        self.text = text
        self.startTime = startTime
        self.endTime = endTime
        self.words = words
    }
}

/// A word-level transcript item, used to place clipboard markers more accurately.
struct TranscriptWord: Sendable {
    let text: String
    let startTime: TimeInterval
    let endTime: TimeInterval
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

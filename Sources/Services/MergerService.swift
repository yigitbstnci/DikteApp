import Foundation

/// Merges transcription segments with clipboard items based on timestamps.
/// Produces output with inline numbered annotations and an Attachments footer.
///
/// Example output:
/// ```
/// Birkaç problemlerimiz var. Burada şu tarz problemler gelmiş. ¹ Bak şu fotoğraf
/// içerisine baktığım zaman ² şu birinci kısım. Bu problemi bul, neden
/// kaynaklanıyormuş çözelim. ³
///
/// Attachments
///
/// 1  /path/to/file.txt [Ghostty] (4 KB)
/// 2  /path/to/screenshot.png [CleanShot X] (2252 KB)
/// 3  /path/to/terminal.png [Ghostty] (2252 KB)
/// ```
final class MergerService: Sendable {

    /// Unicode superscript digits for inline annotations
    private static let superscriptDigits: [Character: Character] = [
        "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
        "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹"
    ]

    /// Converts an integer to its superscript representation (e.g. 12 → "¹²")
    private static func superscript(_ number: Int) -> String {
        String(String(number).map { superscriptDigits[$0] ?? $0 })
    }

    /// Merges transcript segments and clipboard items in chronological order.
    ///
    /// - Parameters:
    ///   - transcriptSegments: Segments from WhisperKit with start/end times (seconds).
    ///   - clipboardItems: Items captured from the clipboard with relative timestamps.
    ///   - recordingStartTime: The absolute Date when recording started.
    /// - Returns: A merged string with inline annotations and an Attachments section.
    func merge(
        transcriptSegments: [TranscriptSegment],
        clipboardItems: [ClipboardItem],
        recordingStartTime: Date
    ) -> String {
        guard !transcriptSegments.isEmpty else {
            // No speech — just list clipboard items as attachments
            if clipboardItems.isEmpty { return "" }
            var output = "Attachments\n"
            for (i, item) in clipboardItems.enumerated() {
                output += "\n" + item.attachmentLine(index: i + 1)
            }
            return output
        }

        // Convert clipboard items' absolute timestamps to relative seconds
        let sortedClipboard = clipboardItems
            .map { item -> (item: ClipboardItem, relativeTime: TimeInterval) in
                let relative = item.timestamp.timeIntervalSince(recordingStartTime)
                return (item, relative)
            }
            .sorted { $0.relativeTime < $1.relativeTime }

        let transcriptPieces = Self.makeTranscriptPieces(from: transcriptSegments)
        guard !transcriptPieces.isEmpty else {
            if clipboardItems.isEmpty { return "" }
            var output = "Attachments\n"
            for (i, item) in clipboardItems.enumerated() {
                output += "\n" + item.attachmentLine(index: i + 1)
            }
            return output
        }

        // Build continuous text with inline annotation markers
        var textParts: [String] = []
        var attachments: [(index: Int, item: ClipboardItem)] = []
        var clipboardIndex = 0
        var annotationCounter = 0

        func appendAnnotation(for item: ClipboardItem) {
            annotationCounter += 1
            attachments.append((annotationCounter, item))
            Self.appendAnnotationMarker(Self.superscript(annotationCounter), to: &textParts)
        }

        for piece in transcriptPieces {
            // Insert annotations for clipboard items that fall BEFORE this transcript piece.
            while clipboardIndex < sortedClipboard.count {
                let clipRelative = sortedClipboard[clipboardIndex].relativeTime
                if clipRelative < piece.startTime {
                    appendAnnotation(for: sortedClipboard[clipboardIndex].item)
                    clipboardIndex += 1
                } else {
                    break
                }
            }

            Self.appendSpeech(piece.text, to: &textParts)

            // Insert annotations for clipboard items that fall inside this piece.
            while clipboardIndex < sortedClipboard.count {
                let clipRelative = sortedClipboard[clipboardIndex].relativeTime
                if clipRelative >= piece.startTime && clipRelative <= piece.endTime {
                    appendAnnotation(for: sortedClipboard[clipboardIndex].item)
                    clipboardIndex += 1
                } else {
                    break
                }
            }
        }

        // Append any remaining clipboard items after the last segment
        while clipboardIndex < sortedClipboard.count {
            appendAnnotation(for: sortedClipboard[clipboardIndex].item)
            clipboardIndex += 1
        }

        // Assemble final output
        var output = textParts.joined()

        // Add Attachments section if there are any
        if !attachments.isEmpty {
            output += "\n\nAttachments\n"
            for (index, item) in attachments {
                output += "\n" + item.attachmentLine(index: index)
            }
        }

        return output
    }

    private struct TranscriptPiece {
        let text: String
        let startTime: TimeInterval
        let endTime: TimeInterval
    }

    private static func makeTranscriptPieces(from segments: [TranscriptSegment]) -> [TranscriptPiece] {
        segments.flatMap { segment -> [TranscriptPiece] in
            let words = segment.words.compactMap { word -> TranscriptPiece? in
                let trimmed = word.text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }
                return TranscriptPiece(
                    text: trimmed,
                    startTime: word.startTime,
                    endTime: max(word.endTime, word.startTime)
                )
            }

            if !words.isEmpty {
                return words
            }

            let trimmed = segment.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return [] }
            return [
                TranscriptPiece(
                    text: trimmed,
                    startTime: segment.startTime,
                    endTime: max(segment.endTime, segment.startTime)
                )
            ]
        }
    }

    private static func appendSpeech(_ speech: String, to textParts: inout [String]) {
        let trimmed = speech.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if textParts.isEmpty {
            textParts.append(trimmed)
            return
        }

        if startsWithPunctuation(trimmed) {
            textParts.append(trimmed)
            return
        }

        if let last = textParts.last, !last.hasSuffix(" "), !last.hasSuffix("\n") {
            textParts.append(" ")
        }
        textParts.append(trimmed)
    }

    private static func appendAnnotationMarker(_ marker: String, to textParts: inout [String]) {
        if let last = textParts.last, !last.hasSuffix(" "), !last.hasSuffix("\n") {
            textParts.append(" ")
        }
        textParts.append(marker)
    }

    private static func startsWithPunctuation(_ text: String) -> Bool {
        guard let scalar = text.unicodeScalars.first else { return false }
        return CharacterSet.punctuationCharacters.contains(scalar)
    }
}

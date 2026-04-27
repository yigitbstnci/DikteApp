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

        // Build continuous text with inline annotation markers
        var textParts: [String] = []
        var attachments: [(index: Int, item: ClipboardItem)] = []
        var clipboardIndex = 0
        var annotationCounter = 0

        for (segIndex, segment) in transcriptSegments.enumerated() {
            // Insert annotations for clipboard items that fall BEFORE this segment
            while clipboardIndex < sortedClipboard.count {
                let clipRelative = sortedClipboard[clipboardIndex].relativeTime
                if clipRelative < segment.startTime {
                    annotationCounter += 1
                    attachments.append((annotationCounter, sortedClipboard[clipboardIndex].item))
                    textParts.append(" " + Self.superscript(annotationCounter))
                    clipboardIndex += 1
                } else {
                    break
                }
            }

            // Add the speech text (trim and join into continuous flow)
            let trimmed = segment.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                // Add space between segments if needed
                if let last = textParts.last, !last.hasSuffix(" ") && !last.hasSuffix("\n") {
                    textParts.append(" ")
                }
                textParts.append(trimmed)
            }

            // Insert annotations for clipboard items DURING this segment
            while clipboardIndex < sortedClipboard.count {
                let clipRelative = sortedClipboard[clipboardIndex].relativeTime
                if clipRelative >= segment.startTime && clipRelative <= segment.endTime {
                    annotationCounter += 1
                    attachments.append((annotationCounter, sortedClipboard[clipboardIndex].item))
                    textParts.append(" " + Self.superscript(annotationCounter))
                    clipboardIndex += 1
                } else {
                    break
                }
            }

            // Insert annotations for clips between this segment and the next
            if segIndex < transcriptSegments.count - 1 {
                let nextStart = transcriptSegments[segIndex + 1].startTime
                while clipboardIndex < sortedClipboard.count {
                    let clipRelative = sortedClipboard[clipboardIndex].relativeTime
                    if clipRelative > segment.endTime && clipRelative < nextStart {
                        annotationCounter += 1
                        attachments.append((annotationCounter, sortedClipboard[clipboardIndex].item))
                        textParts.append(" " + Self.superscript(annotationCounter))
                        clipboardIndex += 1
                    } else {
                        break
                    }
                }
            }
        }

        // Append any remaining clipboard items after the last segment
        while clipboardIndex < sortedClipboard.count {
            annotationCounter += 1
            attachments.append((annotationCounter, sortedClipboard[clipboardIndex].item))
            textParts.append(" " + Self.superscript(annotationCounter))
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
}


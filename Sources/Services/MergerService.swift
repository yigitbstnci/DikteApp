import Foundation

/// Merges transcription segments with clipboard items based on timestamps.
/// Produces a single copyable text output that weaves speech and clipboard data together.
final class MergerService: Sendable {

    /// Merges transcript segments and clipboard items in chronological order.
    ///
    /// The algorithm:
    /// 1. Walk through transcript segments in order.
    /// 2. Before each segment, insert any clipboard items whose timestamp
    ///    falls between the previous segment's end and the current segment's start.
    /// 3. Any remaining clipboard items are appended at the end.
    ///
    /// - Parameters:
    ///   - transcriptSegments: Segments from WhisperKit with start/end times (seconds).
    ///   - clipboardItems: Items captured from the clipboard with relative timestamps.
    ///   - recordingStartTime: The absolute Date when recording started.
    /// - Returns: A single merged string ready for copying.
    func merge(
        transcriptSegments: [TranscriptSegment],
        clipboardItems: [ClipboardItem],
        recordingStartTime: Date
    ) -> String {
        guard !transcriptSegments.isEmpty else {
            // No speech — just list clipboard items
            if clipboardItems.isEmpty { return "" }
            return clipboardItems.map { $0.markdownRepresentation }.joined(separator: "\n\n")
        }

        // Convert clipboard items' absolute timestamps to relative seconds
        let sortedClipboard = clipboardItems
            .map { item -> (item: ClipboardItem, relativeTime: TimeInterval) in
                let relative = item.timestamp.timeIntervalSince(recordingStartTime)
                return (item, relative)
            }
            .sorted { $0.relativeTime < $1.relativeTime }

        var output = ""
        var clipboardIndex = 0

        for (segIndex, segment) in transcriptSegments.enumerated() {
            // Insert clipboard items that fall BEFORE this segment
            while clipboardIndex < sortedClipboard.count {
                let clipRelative = sortedClipboard[clipboardIndex].relativeTime
                let clipItem = sortedClipboard[clipboardIndex].item

                // Insert if clipboard time < segment start
                // Or if it falls between previous segment end and this segment start
                if clipRelative < segment.startTime {
                    if !output.isEmpty { output += "\n\n" }
                    output += clipItem.markdownRepresentation
                    clipboardIndex += 1
                }
                // Insert if clipboard time is during this segment (within it)
                else if clipRelative >= segment.startTime && clipRelative <= segment.endTime {
                    // Will be placed right after this segment's text
                    break
                } else {
                    break
                }
            }

            // Add the speech text
            if !output.isEmpty { output += "\n\n" }
            output += segment.text

            // Insert clipboard items that occurred DURING this segment
            while clipboardIndex < sortedClipboard.count {
                let clipRelative = sortedClipboard[clipboardIndex].relativeTime
                let clipItem = sortedClipboard[clipboardIndex].item

                if clipRelative >= segment.startTime && clipRelative <= segment.endTime {
                    output += "\n\n" + clipItem.markdownRepresentation
                    clipboardIndex += 1
                } else {
                    break
                }
            }

            // Check for clips between this segment and the next
            if segIndex < transcriptSegments.count - 1 {
                let nextStart = transcriptSegments[segIndex + 1].startTime
                while clipboardIndex < sortedClipboard.count {
                    let clipRelative = sortedClipboard[clipboardIndex].relativeTime
                    let clipItem = sortedClipboard[clipboardIndex].item

                    if clipRelative > segment.endTime && clipRelative < nextStart {
                        output += "\n\n" + clipItem.markdownRepresentation
                        clipboardIndex += 1
                    } else {
                        break
                    }
                }
            }
        }

        // Append any remaining clipboard items after the last segment
        while clipboardIndex < sortedClipboard.count {
            let clipItem = sortedClipboard[clipboardIndex].item
            output += "\n\n" + clipItem.markdownRepresentation
            clipboardIndex += 1
        }

        return output
    }
}

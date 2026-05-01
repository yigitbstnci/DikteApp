# Dikte Task Archive

Detailed notes for completed tasks live here so `docs/tasks.md` can stay compact during startup context loading.

## DKT-TASK-0009: Persistent History Screen

- Status: Completed
- Goal: Add a usable history screen with transcript outputs, focus-context references, and clipboard context.
- Implementation Details:
  - `HistoryEntry` model (Identifiable, Codable): id, date, duration, transcriptSegments, clipboardItems, mergedOutput.
  - `HistoryStore` service: JSON persistence under `~/Library/Application Support/Dikte/History/history.json`, append/delete/clearAll, NotificationCenter posting.
  - `HistoryView.swift`: left list panel (240px) + right detail panel with search, date/duration, transcript text, colored `[focus-context N]` inline markers via AttributedString, and attachment preview rows.
  - `HistoryWindowManager`: NSWindow with `.resizable`, `minSize = 680×480`, `setFrameAutosaveName`, `isReleasedWhenClosed = false`, AppDelegate guard so ⌘W doesn't quit app.
  - Output format changed: `¹` → `[focus-context ¹]`; `Attachments` → `Attachments [each file = what speaker is looking at in that moment, in chronological order - read to understand speech references]`.
  - Attachment rows in history UI: colored pill with superscript index (¹, ², ³) and type-based colors (image=purple, url=blue, text=indigo).
  - Hover popover preview on attachment rows: image thumbnail (420×280) or text/URL preview (340×260 scrollable), plus source app and file size.
  - `AppState` saves entry after each recording, deletes temp WAV after transcription.
  - `AppDelegate.applicationShouldTerminateAfterLastWindowClosed = false` in `DikteApp`.
  - Tests: `HistoryStoreTests` (10 tests: load, append, sorted, delete, clearAll, Codable roundtrip, formatted properties, 3 notification tests).
- Completed: 2026-05-01

## DKT-TASK-0008: Audio Optimization and Transcription Speed

- Status: Completed
- Goal: Optimize transcription speed with 16kHz mono audio normalization and add transcription option selection tests.
- Implementation Details:
  - Add `prepareAudioForTranscription` and `normalizeAudio` to `TranscriptionService`
  - Skip normalization if audio is already 16kHz mono
  - Fallback to original audio if normalization fails
  - Log `audio_normalized`, `prep_elapsed_s`, `normalized_sample_rate_hz`, `normalized_channels`, `rtf`, `total_elapsed_s`, `decode_elapsed_s`, `primary_elapsed_s`, `fallback_elapsed_s`, `model_wait_elapsed_s`
  - Dynamic word timestamps: `requiresWordTimestamps = !clipboardItems.isEmpty`
  - Enhanced transcription logs: `total_elapsed_s`, `decode_elapsed_s`, `primary_elapsed_s`, `fallback_elapsed_s`, `rtf`
  - Context-aware hallucination cleanup: only trailing hallucinations removed (not mid-sentence), handles multiple suffix patterns
- Notes: Avoid tests that download Whisper models or require live microphone.
- Completed: 2026-04-29

## DKT-TASK-0004: Broaden Regression Coverage

- Status: Completed
- Goal: Add focused tests around clipboard capture rules, transcript cleanup, audio route behavior, and output formatting.
- Notes: Avoid tests that download Whisper models or require live microphone permissions.
- Implementation: 46 test additions across 5 test files
  - `Tests/Models/ClipboardItemTests.swift`: 13 tests (file size, attachment path/line)
  - `Tests/Services/PendingTerminalTextTests.swift`: 13 tests (terminal confirmation logic)
  - `Tests/Integration/OutputFormatTests.swift`: 10 tests (output format validation)
  - `Tests/Services/MergerServiceTests.swift`: +3 tests (edge cases)
  - `Tests/Services/TranscriptionServiceTests.swift`: +7 tests (text cleaning)
- Completed: 2026-04-29

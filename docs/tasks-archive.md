# Dikte Task Archive

Detailed notes for completed tasks live here so `docs/tasks.md` can stay compact during startup context loading.

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

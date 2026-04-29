# Dikte Tasks

This file tracks active work and follow-ups that survive across agent sessions.

## Active

No active tasks are currently recorded.

## Ongoing

### DKT-TASK-0001: Keep Repo Context System Healthy

- Status: Ongoing
- Owner: Any coding agent working in this repo
- Goal: Keep `docs/current-state.md`, `docs/tasks.md`, `docs/decisions.md`, and `docs/context/index.yml` aligned with meaningful project changes.
- Acceptance: `make context-check` passes and `make context-load` gives a useful bounded startup context.

## Backlog

### DKT-TASK-0009: Evaluate `faster-whisper` As A Separate Transcription Path

- Status: Backlog
- Goal: Run a low-urgency spike to evaluate whether the current transcription path can be mirrored with `faster-whisper` for better throughput without destabilizing the working app flow.
- Constraints:
  - Do not replace or regress the current production path while testing.
  - Keep the existing transcription flow available as the default behavior until the experiment proves itself.
- Notes:
  - Reference: https://github.com/SYSTRAN/faster-whisper
  - The experiment should compare the current path against a `faster-whisper`-based structure and focus first on transcription speed, integration cost, and output quality.
  - No rush; treat this as a background evaluation task, not an immediate migration.

### DKT-TASK-0008: Audio Optimization and Transcription Speed

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

### DKT-TASK-0006: Wire Onboarding Into First Launch

- Status: Backlog
- Goal: Connect `OnboardingView` to first-run setup and local Whisper model download state.
- Notes: Be careful around model download behavior and tests that should not trigger app-start side effects.

### DKT-TASK-0007: Replace Placeholder Settings Bindings

- Status: Backlog
- Goal: Persist real settings for options currently represented by `.constant(...)` bindings.
- Notes: Keep settings native to macOS and preserve the local-first privacy model.

### DKT-TASK-0004: Broaden Regression Coverage

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

## Blocked

No blocked tasks are currently recorded.

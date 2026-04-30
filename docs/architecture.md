# Dikte Architecture

This file is the compact architecture reference for agent startup. Keep it limited to runtime shape, critical invariants, and operator-facing facts.

## Runtime Shape

Dikte is a native macOS menu bar app for context-aware dictation.

1. `AppState` starts and stops a recording session.
2. `AudioRecorderService` writes microphone input to a temporary WAV file.
3. `ClipboardMonitorService` polls `NSPasteboard.general.changeCount` during recording.
4. `TranscriptionService` prepares audio and transcribes locally with WhisperKit.
5. `MergerService` injects clipboard markers into transcript text by timestamp.
6. `AppState` copies the final Markdown result back to the system clipboard.

## Core Modules

- `Sources/AppState.swift`: central coordinator for recording, transcription, merge, clipboard output, and HUD state.
- `Sources/Services/AudioRecorderService.swift`: `AVAudioEngine` capture, WAV persistence, and signal metrics.
- `Sources/Services/ClipboardMonitorService.swift`: clipboard polling, source-app detection, and asset persistence.
- `Sources/Services/TranscriptionService.swift`: WhisperKit model load, audio normalization, fallback decode path, and transcript cleanup.
- `Sources/Services/MergerService.swift`: transcript-plus-clipboard merge logic.
- `Sources/Services/DikteLog.swift`: structured local logs with per-recording session IDs.
- `Sources/Views/`: menu bar controls, floating HUD, and settings surfaces.

## Critical Behavior

- Audio is captured into a temporary `.wav` file and anchored with a `recordingStartTime` used for clipboard timing.
- Clipboard polling runs every `0.3` seconds while recording.
- Terminal-like apps can emit selection-side pasteboard noise; text capture is held pending and only confirmed on copy-like repetition.
- Transcription normalizes audio to 16kHz mono when needed.
- Word timestamps are enabled when clipboard items exist; fallback decode can run without them.
- Transcript cleanup removes Whisper special tokens and known trailing hallucination patterns.
- Logs must not contain raw transcript text or clipboard text.

## Runtime Storage

- Whisper models: `~/Library/Application Support/Dikte/Models`
- Clipboard assets: `~/Library/Application Support/Dikte/ClipboardAssets`
- Structured logs: `~/Library/Logs/Dikte/dikte.log`
- Derived app path marker: `.build/dikte-app-path`

## Build And Context Workflow

- `project.yml` is the source of truth; `Dikte.xcodeproj` is generated.
- Local work should use `make run`, `make test`, and `make stop`.
- `make context-load` loads `docs/current-state.md`, `docs/tasks.md`, the latest two session summaries, `docs/decisions.md`, and this file.
- Context docs are durable summaries, not raw conversation or runtime log storage.

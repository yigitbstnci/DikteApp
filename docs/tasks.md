# Dikte Tasks

This file tracks active work and follow-ups that survive across agent sessions.

## Active

No active tasks are currently recorded.

## Ongoing

### DKT-TASK-0001: Keep Repo Context System Healthy

- Status: Ongoing
- Goal: Keep `docs/current-state.md`, `docs/tasks.md`, `docs/decisions.md`, and `docs/context/index.yml` aligned with meaningful project changes.
- Acceptance: `make context-check` passes and `make context-load` stays compact and useful.

## Backlog

## Completed

### DKT-TASK-0011: Portable Project-Native Context Protocol

- Status: Completed
- Goal: Convert Dikte's repo-resident context model into reusable MYB `.opencode` protocol guidance and a setup template for other projects.
- Date: 2026-05-12

### DKT-TASK-0010: History Retention and Cleanup

- Status: Completed
- Goal: Add configurable history retention cleanup (1/7/30 days, unlimited) and manual cleanup with confirmation dialogs.
- Date: 2026-05-01

### DKT-TASK-0009: Persistent History Screen

- Status: Completed
- Goal: Add a usable history screen with transcript outputs, focus-context references, and clipboard context.
- Date: 2026-05-01

### DKT-TASK-0007: Replace Placeholder Settings Bindings

- Status: Completed
- Goal: Persist real settings for options currently represented by `.constant(...)` bindings.
- Details: `AppSettings` model added with `WhisperModel`, `DictationLanguage` settings and `UserDefaults` persistence. The menu bar now opens a SwiftUI panel with an embedded settings tab and `KeyboardShortcuts.Recorder`; model/language settings are live bindings with disabled states during recording/processing.
- Date: 2026-04-30

### DKT-TASK-0008: Audio Optimization and Transcription Speed

- Status: Completed
- Goal: Optimize transcription speed with 16kHz mono normalization and transcription option selection tests.
- Details: `docs/tasks-archive.md#dkt-task-0008-audio-optimization-and-transcription-speed`

### DKT-TASK-0004: Broaden Regression Coverage

- Status: Completed
- Goal: Add focused tests around clipboard capture rules, transcript cleanup, audio route behavior, and output formatting.
- Details: `docs/tasks-archive.md#dkt-task-0004-broaden-regression-coverage`

## Blocked

No blocked tasks are currently recorded.

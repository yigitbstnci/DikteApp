# Dikte Tasks

This file tracks active work and follow-ups that should survive across agent sessions.

## Active

No active tasks are currently recorded.

## Ongoing

### DKT-TASK-0001: Keep Repo Context System Healthy

- Status: Ongoing
- Owner: Any coding agent working in this repo
- Goal: Keep `docs/current-state.md`, `docs/tasks.md`, `docs/decisions.md`, and `docs/context/index.yml` aligned with meaningful project changes.
- Acceptance: `make context-check` passes and `make context-load` gives a useful bounded startup context.

## Test Development Rule

When implementing new functionality that requires tests:

1. Add a test task to this file under Backlog with:
   - Status: Backlog
   - Goal: Clear description of what needs testing
   - Notes: Any constraints (no network, no microphone, etc.)

2. Implement tests in the appropriate test file:
   - `Tests/Services/` for service layer tests
   - `Tests/Models/` for model/unit tests
   - `Tests/Integration/` for multi-component tests

3. All tests must:
   - NOT download Whisper models
   - NOT require microphone permissions
   - NOT require GUI/app launch
   - Be runnable via `make test`

## Backlog

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
- Implementation: 24 new tests across 5 test files
  - `Tests/Models/ClipboardItemTests.swift`: 13 tests (file size, attachment path/line)
  - `Tests/Services/PendingTerminalTextTests.swift`: 10 tests (terminal confirmation logic)
  - `Tests/Integration/OutputFormatTests.swift`: 10 tests (output format validation)
  - `Tests/Services/MergerServiceTests.swift`: +3 tests (edge cases)
  - `Tests/Services/TranscriptionServiceTests.swift`: +7 tests (text cleaning)
- Completed: 2026-04-29

## Blocked

No blocked tasks are currently recorded.

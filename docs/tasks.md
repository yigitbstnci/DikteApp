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

## Backlog

### DKT-TASK-0002: Wire Onboarding Into First Launch

- Status: Backlog
- Goal: Connect `OnboardingView` to first-run setup and local Whisper model download state.
- Notes: Be careful around model download behavior and tests that should not trigger app-start side effects.

### DKT-TASK-0003: Replace Placeholder Settings Bindings

- Status: Backlog
- Goal: Persist real settings for options currently represented by `.constant(...)` bindings.
- Notes: Keep settings native to macOS and preserve the local-first privacy model.

### DKT-TASK-0004: Broaden Regression Coverage

- Status: Backlog
- Goal: Add focused tests around clipboard capture rules, transcript cleanup, audio route behavior, and output formatting.
- Notes: Avoid tests that download Whisper models or require live microphone permissions.

## Blocked

No blocked tasks are currently recorded.

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

### DKT-TASK-0009: Evaluate `faster-whisper` As A Separate Transcription Path

- Status: Backlog
- Goal: Run a low-urgency spike to evaluate whether the current transcription path can be mirrored with `faster-whisper` for better throughput without destabilizing the working app flow.
- Notes: Keep the current production path as default; compare speed, integration cost, and output quality against [SYSTRAN/faster-whisper](https://github.com/SYSTRAN/faster-whisper).

### DKT-TASK-0006: Wire Onboarding Into First Launch

- Status: In Progress (partial)
- Goal: Connect `OnboardingView` to first-run setup and local Whisper model download state.
- Notes: Partial implementation exists through HUD model readiness; standalone first-launch flow is still open.
- Started: 2026-04-30

### DKT-TASK-0007: Replace Placeholder Settings Bindings

- Status: Backlog
- Goal: Persist real settings for options currently represented by `.constant(...)` bindings.
- Notes: Keep settings native to macOS and preserve the local-first privacy model.

## Completed

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

<!-- Context: software-studio/guides | Priority: high | Version: 1.0 | Updated: 2026-05-09 -->

# Implementation Standards

**Core Idea**: Preserve the codebase shape with small, testable, privacy-safe changes.

## Code Shape

- Keep domain logic in services/models, not SwiftUI views.
- Keep `AppState` as coordinator; avoid turning it into a utility dumping ground.
- Do not hand-edit generated project files such as `Dikte.xcodeproj/`.
- Prefer explicit types and simple control flow over clever abstractions.
- Preserve existing service boundaries unless the approved plan changes them.

## Algorithmic Expectations

- Prefer simple linear scans for small in-memory session/history data unless evidence shows scale issues.
- Avoid repeated expensive filesystem, pasteboard, audio, or model-cache work inside tight polling loops.
- Do not introduce async/concurrency complexity unless the touched boundary already requires it.
- Treat clipboard, audio, transcription, merge, and HUD paths as latency-sensitive.
- Choose data structures based on current expected scale, not hypothetical future scale.

## Testing Standards

- Keep tests headless: no microphone permission prompts, GUI-driven app launches, or Whisper model downloads.
- Add focused regression tests when touching merge behavior, transcript cleanup, settings persistence, history, clipboard capture, logging, or output formatting.
- Prefer narrow unit/integration tests over broad UI-driven tests.
- Keep `make test` green for code changes and `make context-check` green for docs/context/system changes.

## Privacy and Logging

- Never log raw transcript text, clipboard text, secrets, or private user content.
- Log counts, durations, sizes, sources, cache state, errors, and non-sensitive diagnostic metadata.
- Do not add telemetry, remote transcription, analytics, or network dependencies without explicit approval.
- Preserve local-first behavior by default.

## Scope Control

- Make the smallest correct change that satisfies the approved plan.
- Avoid broad refactors, rewrites, or style churn unless explicitly approved.
- Preserve existing output format unless the task explicitly changes it.
- If a change requires scope expansion, stop and ask for approval.

## Validation Defaults

- For code changes, prefer `make test` unless the handoff specifies a narrower command.
- For docs/context/agent/command/workflow changes, prefer `make context-check`.
- For project file changes, regenerate through `make generate` or approved Make targets; do not manually edit generated files.

## Related

- `../../core/guides/execution-workflow.md`
- `../../../agent/subagents/myb-Implementation-Builder.md`

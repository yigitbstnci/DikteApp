# Dikte Agent Notes

## Project Snapshot

Dikte is a native macOS menu bar app for privacy-first dictation with clipboard context. It records audio locally, captures clipboard changes during recording, transcribes with WhisperKit, merges speech with copied context, and writes Markdown output back to the clipboard.

## Working Rules

- Treat `project.yml` as the project source of truth. Regenerate `Dikte.xcodeproj` with `xcodegen generate`; do not hand-edit generated project files.
- Keep changes scoped to the requested behavior and prefer existing native macOS / SwiftUI patterns.
- Preserve the local-first model. Do not add network transcription, telemetry, or remote dependencies without explicit approval.
- Be careful around microphone permissions, pasteboard access, sandbox settings, and model download behavior.

## Context Workflow

At session start:

1. Run `make context-load`.
2. Read `docs/current-state.md` and `docs/tasks.md` first.
3. Read `docs/decisions.md` or `docs/architecture.md` only when the task needs deeper historical or structural context.

Before ending meaningful work:

1. Update `docs/current-state.md`, `docs/tasks.md`, or `docs/decisions.md` when repo facts changed.
2. Add a concise session summary with `make context-save SUMMARY=/path/to/session.md TITLE="short-title"` when the work represents a meaningful development block.
3. Keep `docs/context/index.yml` aligned with session, task, and decision IDs/status.
4. Run `make context-check`, or `make verify` when code or tests changed.

Committed context must stay distilled. Do not commit raw conversations, secrets, clipboard contents, dictated transcript text, or full runtime logs.

## Common Commands

```bash
make run
make test
make stop
make context-load
make context-save SUMMARY=/path/to/session.md TITLE="short-title"
make context-check
make verify
```

Use `make run` as the default debug path. It launches the built app via LaunchServices and tails `~/Library/Logs/Dikte/dikte.log`.

## Important Files

- `Sources/AppState.swift`: recording, transcription, merge, clipboard, and HUD coordination.
- `Sources/Services/TranscriptionService.swift`: WhisperKit load/transcribe path and transcript cleanup.
- `Sources/Services/ClipboardMonitorService.swift`: pasteboard polling and clipboard artifact capture.
- `Sources/Views/`: menu bar UI, floating HUD, settings, and onboarding surfaces.
- `docs/current-state.md`: live repo snapshot.
- `docs/tasks.md`: active, ongoing, backlog, and compact completed task index.

## Output And Test Rules

- Output format uses inline superscript attachment markers and an `Attachments` list.
- If a feature needs tests, open a concrete task in `docs/tasks.md`; `make test` must stay green.
- Tests must not require Whisper model downloads, microphone permissions, or GUI-driven app launch.

# Dikte Current State

Last updated: 2026-04-30

## Snapshot

Dikte is a macOS SwiftUI menu bar app for privacy-first dictation with clipboard context. It records audio locally, captures clipboard changes during recording, transcribes with WhisperKit, merges transcript text with copied context, and copies Markdown output back to the system clipboard.

## Current Implementation

- `project.yml` drives the generated Xcode project.
- `make run` is the default debug path, launches the built `.app` through LaunchServices, and stops its terminal log stream when the Dikte process exits.
- `make test` runs the unit-test scheme.
- The menu bar icon opens a native dropdown menu for recording, clipboard status, settings, and quit actions.
- Structured logs are written to `~/Library/Logs/Dikte/dikte.log` with session correlation IDs and key-value diagnostic metadata.
- Clipboard assets are persisted under `~/Library/Application Support/Dikte/ClipboardAssets`.
- Whisper models are cached under `~/Library/Application Support/Dikte/Models`.
- Unit tests currently cover merge behavior, output formatting, clipboard item formatting, terminal text confirmation helpers, transcript cleanup, cached model folder detection, and log line formatting.
- Transcription uses dynamic word timestamps: when clipboard items exist, `wordTimestamps: true`; otherwise `wordTimestamps: false`.
- Enhanced transcription logging includes: `total_elapsed_s`, `decode_elapsed_s`, `primary_elapsed_s`, `fallback_elapsed_s`, `model_wait_elapsed_s`, `rtf` (real-time factor).
- Audio normalization to 16kHz mono is now implemented in TranscriptionService.
- HUD model readiness: floating HUD shows model preparation state (preparing/ready/failed) on app launch; `Model Ready` card appears when idle.

## Known Gaps

- Settings UI still contains placeholder `.constant(...)` bindings for several options.
- HUD shows model readiness on launch; `OnboardingView` is wired to `AppState.modelReadyState` but its standalone first-launch window flow is not yet implemented.
- Test coverage is still narrow around app lifecycle, live audio routing, pasteboard integration, and UI behavior.
- Documentation must stay aligned with implementation details such as polling interval, decode options, and model name.

## Current Context System Status

- Repo-resident context docs live under `docs/`.
- The maintained architecture reference is `docs/architecture.md`; the old root-level `PROJECT_DETAIL.md` reference has been removed.
- `docs/context/index.yml` is the structured context index.
- `make context-load` prints bounded agent startup context and defaults to the latest two session summaries.
- `make context-save` creates a session summary and updates the index.
- Context session summaries are reserved for meaningful development blocks or daily summaries; runtime log sessions and raw log dumps stay out of committed context.
- `make context-check` validates the context surface.
- No active context-system implementation task remains; `DKT-TASK-0001` is now an ongoing maintenance protocol.

## Branch And Workflow Notes

- Current durable workflow assumes `main` is the primary branch.
- Do not hand-edit `Dikte.xcodeproj/`; regenerate with `xcodegen generate` through Makefile targets when needed.
- Skip app build/tests for docs-only context changes unless a script or Makefile edit needs direct verification.

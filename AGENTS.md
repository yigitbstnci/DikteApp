# Dikte Agent Notes

## Project Purpose

Dikte is a native macOS menu bar app for context-aware dictation. It records the user's voice, watches clipboard changes during the recording, transcribes audio locally with WhisperKit, then merges speech and copied context into one Markdown-ready clipboard output.

Primary workflow:

1. User presses `Command + Shift + Space` to start recording.
2. User speaks while copying text, URLs, or images from other apps.
3. User presses the shortcut again to stop.
4. The app transcribes locally and injects clipboard references into the transcript as superscript markers.
5. The final Markdown output is copied to the system clipboard.

## Technology

- SwiftUI and AppKit for a native macOS app.
- macOS menu bar app via `MenuBarExtra`.
- `AVAudioEngine` for microphone capture.
- `NSPasteboard` polling for clipboard capture.
- WhisperKit for local speech-to-text.
- KeyboardShortcuts for the global hotkey.
- XcodeGen drives the Xcode project from `project.yml`.

## Repository Rules

- Treat `project.yml` as the source of truth for project structure.
- Do not hand-edit generated `Dikte.xcodeproj` files unless explicitly asked. Regenerate with `xcodegen generate`.
- Keep changes scoped to the requested behavior.
- Prefer native macOS and SwiftUI patterns already used in the repo.
- Preserve the local-first privacy model. Do not add network transcription or telemetry without explicit approval.
- Be careful around microphone permissions, global pasteboard access, sandbox settings, and model download behavior.

## Repo-Resident Context Protocol

This repo keeps agent continuity in committed Markdown files under `docs/`, plus a small structured index at `docs/context/index.yml`. Treat those files as the durable source of truth instead of relying on any one agent's private memory store.

At session start:

1. Read `docs/current-state.md` and `docs/tasks.md`.
2. Run `make context-load` when deeper continuity is useful.
3. Use `docs/architecture.md` and `docs/decisions.md` for stable system context and prior decisions.

Before ending meaningful work:

1. Add a concise session summary with `make context-save SUMMARY=/path/to/session.md TITLE="short-title"`.
2. Update `docs/current-state.md`, `docs/tasks.md`, or `docs/decisions.md` when facts, open work, or decisions changed.
3. Run `make context-check`.

Session summaries are for meaningful development blocks or daily summaries, not every recording, runtime log session, or small debugging attempt. Runtime log session IDs such as `session=d8a84ed8` belong in `~/Library/Logs/Dikte/dikte.log`; committed context should only keep distilled facts, decisions, verification, and follow-ups.

Do not commit raw conversations, secrets, tokens, pasted private data, copied clipboard contents, dictated transcript text, or full logs into the context docs. Commit context updates together with the related code or documentation change.

## Useful Commands

```bash
xcodegen generate
make run
make test
make stop
make context-load
make context-save SUMMARY=/path/to/session.md TITLE="short-title"
make context-check
xcodebuild -list -project Dikte.xcodeproj
xcodebuild -scheme Dikte -project Dikte.xcodeproj -configuration Debug build
```

Use `make run` as the default debugging path. It builds into `.build/DerivedData`, stops any already-running Dikte process, launches `Dikte.app` via LaunchServices, and tails `~/Library/Logs/Dikte/dikte.log` so structured app logs stay in the terminal.

If test targets are present:

```bash
xcodebuild test -scheme Dikte -project Dikte.xcodeproj -destination 'platform=macOS'
```

## Important Paths

- `Sources/DikteApp.swift`: app entry point, menu bar scene, settings scene, HUD visibility.
- `Sources/AppState.swift`: central state coordinator for recording, processing, merging, and clipboard output.
- `Sources/Models/RecordingSession.swift`: transcript segment and recording session models.
- `Sources/Models/ClipboardItem.swift`: clipboard item model and attachment-line formatting.
- `Sources/Services/AudioRecorderService.swift`: microphone capture to temporary WAV files.
- `Sources/Services/ClipboardMonitorService.swift`: clipboard polling and artifact persistence.
- `Sources/Services/TranscriptionService.swift`: WhisperKit model loading, transcription, and transcript cleanup.
- `Sources/Services/MergerService.swift`: timestamp-based transcript and clipboard merge algorithm.
- `Sources/Views/`: SwiftUI menu bar, floating HUD, settings, design system, and onboarding views.
- `Resources/Info.plist`: app metadata, microphone usage string, menu bar-only mode.
- `Resources/Dikte.entitlements`: sandbox and audio/input entitlements.
- `design.md` and `design_prd.md`: product/design direction for the Fluid Zen interface.

## Output Format

Merged output should read naturally as transcript text, with inline superscript references:

```text
Konuşma metni burada devam eder. ¹ Sonra kullanıcı başka bir bağlamdan bahseder. ²

Attachments

1  /path/to/copied-text.txt [Source App] (4 KB)
2  https://example.com [Browser] (128 B)
```

Text and image clipboard items are persisted under:

```text
~/Library/Application Support/Dikte/ClipboardAssets
```

Whisper models are cached under:

```text
~/Library/Application Support/Dikte/Models
```

## Current Product Gaps

- Settings UI contains placeholder `.constant(...)` bindings for several options.
- `OnboardingView` exists but is not wired into the app launch/model download flow.
- Build/test coverage is minimal unless a test target has been added.
- Keep documentation aligned with implementation details such as polling interval, decode options, and model name.

## Development Rules

### Test Coverage Rule
Feature değişikliği test etkisi açısından değerlendirilmeli; test gerekiyorsa `docs/tasks.md` içinde somut task açılmalı. Test yazılacak genel kural değil; "X feature için Y testleri eklenecek" gibi somut task'lar açılmalı.

# Dikte Agent Notes

## Start Here

- Run `make context-load` before work; then read `docs/current-state.md` and `docs/tasks.md`. Use `docs/architecture.md` or `docs/decisions.md` when behavior or workflow is unclear.
- `project.yml` is the Xcode source of truth. `Dikte.xcodeproj/` is generated and ignored; use `xcodegen generate` or Make targets, never hand-edit project files.
- Dikte is a macOS 15 SwiftUI menu bar app (`Sources/DikteApp.swift`) with `AppState` coordinating recording, clipboard capture, local WhisperKit transcription, merge, clipboard output, and HUD state.

## MYB Software Studio Integration

- SYSTEM_ROOT: ./.opencode
- Primary agent: ./.opencode/agents/myb-Orchestrator.md
- Context navigation: ./.opencode/context/navigation.md
- System manifest: ./.opencode/system-manifest.json

Project AGENTS.md rules remain higher priority. For Dikte, project memory and context source of truth is the repo-native protocol: run `make context-load`, then use `docs/current-state.md`, `docs/tasks.md`, `docs/decisions.md`, and `docs/context/index.yml` for current project state, tasks, decisions, and handoff memory.

`.opencode/context` describes the MYB agent system, commands, workflows, and reusable agent operating knowledge. It is not Dikte's project-state memory. Before any Dikte project work, follow the Start Here protocol above; update Dikte context through the existing `docs/` + `make context-save` / `make context-check` workflow when a durable context update is needed.

## Commands

- Toolchain: XcodeGen >= 2.38.0, Xcode 16 project settings, Swift 5.9, macOS 15 deployment target.
- Install setup dependency with `brew install xcodegen` before build/test commands.
- Generate project: `make generate`.
- Debug app: `make run` stops any running Dikte, regenerates/builds, launches via `open -n`, clears/tails `~/Library/Logs/Dikte/dikte.log`, and kills the app on Ctrl-C.
- Stop app: `make stop`.
- Full tests: `make test`.
- Focused test class: `xcodegen generate && xcodebuild -quiet -project Dikte.xcodeproj -scheme Dikte -destination 'platform=macOS' -only-testing:DikteTests/MergerServiceTests test`. Append `/testMethodName` for one test method.
- Full verification: `make verify` runs `make context-check` then `make test`.
- Docs/instruction-only changes usually need `make context-check`; skip app build/tests unless scripts, project config, or code changed.

## Local Skills

- Repo-local skills live under `.opencode/skills/`.
- When a task explicitly names one of these skills, or clearly matches its purpose, read that skill's `SKILL.md` before planning or making changes.
- `coding-guidelines` -> `.opencode/skills/coding-guidelines/SKILL.md`; use for coding, review, debugging, or refactor work that should stay simple, surgical, and verifiable.
- `git-commit-standard` -> `.opencode/skills/git-commit-standard/SKILL.md`; use whenever writing, reviewing, editing, or suggesting git commit messages.
- Future skills should be added here with `name -> path` and a one-line usage note.
  
## Runtime Invariants

- Preserve local-first behavior. Do not add network transcription, telemetry, or remote dependencies without explicit approval.
- WhisperKit uses `openai_whisper-large-v3_turbo`; first real app run may download ~954 MB into `~/Library/Application Support/Dikte/Models`.
- `AppState.init()` preloads the model and shows the HUD outside tests; `XCTestConfigurationFilePath` detection avoids model downloads and GUI side effects in tests.
- App sandbox is disabled in `Resources/Dikte.entitlements`, microphone entitlement is enabled, and `Resources/Info.plist` sets `LSUIElement=true`; change these only deliberately.
- `ClipboardMonitorService` polls `NSPasteboard.general.changeCount` every `0.3` seconds during recording and stores artifacts in `~/Library/Application Support/Dikte/ClipboardAssets`.
- Terminal-like apps (`ghostty`, `terminal`, `iterm`, `warp`, `kitty`, `wezterm`, `alacritty`) hold text pending until copy-like repetition; keep regression coverage if this changes.
- `TranscriptionService` decodes Turkish (`language: "tr"`), normalizes audio to 16 kHz mono when needed, and only enables `wordTimestamps` when clipboard items exist.
- Output format is speech with `[focus-context ¹]` inline markers plus an `Attachments [each file = ...]` footer; see `Sources/Services/MergerService.swift` and `Tests/Integration/OutputFormatTests.swift`.
- Runtime logs live at `~/Library/Logs/Dikte/dikte.log`; log counts, durations, sizes, sources, and cache state, never raw transcript or clipboard text.

## Key Files

- `Sources/AppState.swift`: recording/transcription/merge/clipboard/HUD coordinator.
- `Sources/Services/AudioRecorderService.swift`: microphone capture and temporary WAV creation.
- `Sources/Services/ClipboardMonitorService.swift`: pasteboard polling, source-app detection, asset persistence.
- `Sources/Services/TranscriptionService.swift`: WhisperKit load/cache, audio normalization, fallback decode, transcript cleanup.
- `Sources/Services/MergerService.swift`: timestamp-based output composition and attachment markers.
- `Sources/Views/`: menu bar, floating HUD, settings, and onboarding surfaces.

## Context Updates

- Do not update context docs for every small edit. During active development, avoid repeatedly touching `docs/current-state.md`, `docs/tasks.md`, `docs/decisions.md`, or session summaries just because code changed.
- Batch context updates when the user asks to commit/push, when preparing a handoff, or when the request is explicitly about docs/context rules.
- At that boundary, update only the context files needed to reflect durable facts, open tasks, decisions, and verification.
- If feature work needs tests that are not added immediately, record a concrete task in `docs/tasks.md` during commit/push preparation if the gap still exists; `make test` must stay green.
- Tests must stay headless: no Whisper model downloads, microphone permission prompts, or GUI-driven app launches.
- Use `make context-save SUMMARY=/path/to/session.md TITLE="short-title"` only for meaningful development summaries, normally as part of commit/push preparation.
- Committed context must not include raw conversations, secrets, clipboard contents, dictated transcript text, or raw runtime logs.

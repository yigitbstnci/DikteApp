# Session: Recording Shortcut and Terminal Startup

## Delivered

- Bare `make` now launches Dikte instead of only generating the project. Build and test use repo-local DerivedData rather than the stale shared Xcode cache.
- Control + Shift + Space is the recording default. The old default migrates once; custom and disabled choices are retained. The settings window supports changes and reset, and the menu and HUD reflect the saved shortcut.

## Verification

- `make verify` passed with 87 tests, including shortcut migration. The updated shortcut appeared in the running HUD. Live microphone shortcut checks remain in DKT-TASK-0012.

## Investigation and Next Steps

- Xcode's outdated CoreSimulator component does not block the native macOS build. Explicitly selecting arm64 removed the separate destination ambiguity in a diagnostic build; no destination or system settings were changed.
- Two warm, clipboard-free Turkish recordings took about 14 seconds to transcribe 16-17 seconds of audio. Cached model readiness took about 23 seconds. Compare Debug and Release with the same local audio before changing inference settings or engines.

# Session: HUD Model Readiness On Launch

**Date:** 2026-04-30
**Title:** HUD model readiness on launch
**ID:** 2026-04-30-hud-model-readiness-on-launch

## Goal

Show onboarding-style "Model Ready" card in the HUD when the app launches, so users know the app is initializing and the Whisper model is being prepared.

## Completed

1. **Model readiness state in AppState**
   - Added `ModelReadyState` enum: `.preparing`, `.ready`, `.failed(String)`
   - `modelReadyState` property on `AppState`
   - `AppState.init()` now captures preload result and updates `modelReadyState`

2. **TranscriptionService.preload error propagation**
   - Changed `preload()` from void-swallowing-errors to `throws`
   - Errors now propagate to `AppState` and set `.failed(message)`

3. **HUD shown on app launch**
   - `FloatingHUDManager.showHUD()` is now called from `AppState.init()` (non-test path)
   - App launch immediately shows the floating HUD with model preparation status

4. **FloatingHUDView model readiness card**
   - When idle (not recording/processing/showing result), HUD now shows model state card instead of blank
   - `.preparing` → spinner + "Model hazırlanıyor..."
   - `.ready` → green check + "Model Ready" + "⌘⇧Space" hint
   - `.failed` → red X + error message
   - Auto-hide after 5 seconds when model becomes `.ready` and user stays idle

5. **OnboardingView cleanup**
   - Removed hardcoded `.onAppear` simulation that auto-completed after 2 seconds
   - Replaced `@State` internals with `@Binding` to `AppState.ModelReadyState`
   - Added `#Preview` variants for each state

6. **Context index fix**
   - Added missing `DKT-TASK-0009` to `docs/context/index.yml` backlog

## Files Changed

| File | Change |
|------|--------|
| `Sources/AppState.swift` | Added `ModelReadyState` enum, `modelReadyState` property, updated preload to capture result |
| `Sources/Services/TranscriptionService.swift` | `preload()` now throws instead of swallowing errors |
| `Sources/DikteApp.swift` | Added `onChange` for `modelReadyState` to show/hide HUD on state transitions |
| `Sources/Views/FloatingHUDView.swift` | Added `modelReadyCard` view; `else` branch in body shows readiness when idle |
| `Sources/Views/OnboardingView.swift` | Replaced hardcoded simulation with `@Binding modelReadyState`; added state previews |
| `docs/context/index.yml` | Added missing `DKT-TASK-0009` to backlog |

## Verification

- `xcodebuild -scheme Dikte -project Dikte.xcodeproj -configuration Debug build` succeeded
- `xcodebuild test -scheme Dikte -project Dikte.xcodeproj -destination 'platform=macOS'` passed (59 tests, 0 failures)
- `make context-check` passed

## Follow-ups

- `DKT-TASK-0006` (Wire OnboardingView into first launch) remains open; `OnboardingView` is now driven by `modelReadyState` binding but full first-launch UX flow (separate window vs. HUD integration) is not yet finalized.
- Consider auto-hide timing tuning (currently 5 s) based on actual model load duration on first launch.

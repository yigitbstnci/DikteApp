# Session: History and Focus-Context UI

**Date:** 2026-05-01
**Title:** history focus context
**ID:** 2026-05-01-history-focus-context

## Goal

Add a usable history screen with persistent transcript storage, resizable window, and focus-context marker UI. Also update output format to use `[focus-context N]` markers and a descriptive Attachments header.

## Completed

1. **Persistent History**
   - `HistoryEntry` model (Identifiable, Codable): id, date, duration, transcriptSegments, clipboardItems, mergedOutput.
   - `HistoryStore` service: JSON persistence under `~/Library/Application Support/Dikte/History/history.json`, append/delete/clearAll, NotificationCenter posting.
   - `AppState` saves entry after each recording, deletes temp WAV after transcription.

2. **History Window UI**
   - `HistoryView.swift`: left list panel (240px) + right detail panel with search, date/duration, transcript text.
   - Colored `[focus-context N]` inline markers via AttributedString (image=purple, url=blue, text=indigo).
   - Attachment rows with colored pill showing superscript index and type-based colors.
   - Hover popover preview on attachment rows: image thumbnail (420×280) or text/URL preview (340×260 scrollable), plus source app and file size.
   - `HistoryWindowManager`: NSWindow with `.resizable`, `minSize = 680×480`, `setFrameAutosaveName`, `isReleasedWhenClosed = false`.
   - `AppDelegate.applicationShouldTerminateAfterLastWindowClosed = false` so ⌘W doesn't quit app.
   - Resizable window with macOS autosave frame.

3. **Output Format Update**
   - Inline markers changed: `¹` → `[focus-context ¹]`
   - Attachments header changed: `Attachments` → `Attachments [each file = what speaker is looking at in that moment, in chronological order - read to understand speech references]`
   - `MergerService` updated with `annotationMarker()` returning `[focus-context N]` format.
   - Tests updated for new format.

4. **Menu Bar Integration**
   - `MenuBarView` now has a "Geçmiş" entry in menu bar dropdown.
   - `⌘W` on history window closes window without quitting app.

## Files Changed

| File | Change |
|------|--------|
| `Sources/Models/HistoryEntry.swift` | New: History entry model |
| `Sources/Services/HistoryStore.swift` | New: JSON persistence service |
| `Sources/Views/HistoryView.swift` | New: History window UI with inline markers and attachment previews |
| `Sources/Views/HistoryWindowManager.swift` | New: NSWindow manager with autosave and resize |
| `Sources/AppState.swift` | Saves entry after recording, deletes temp WAV |
| `Sources/DikteApp.swift` | AppDelegate with applicationShouldTerminateAfterLastWindowClosed = false |
| `Sources/Views/MenuBarView.swift` | Added Geçmiş menu item |
| `Sources/Services/MergerService.swift` | [focus-context N] markers and descriptive Attachments header |
| `Sources/Models/ClipboardItem.swift` | Added Codable conformance |
| `Sources/Models/RecordingSession.swift` | Added Codable to TranscriptSegment/Word |
| `Tests/Services/HistoryStoreTests.swift` | New: 10 tests for store and notifications |
| `Tests/Integration/OutputFormatTests.swift` | Updated for new marker format |
| `Tests/Services/MergerServiceTests.swift` | Updated for new marker format |
| `docs/architecture.md` | Added HistoryStore, HistoryView, HistoryWindowManager |
| `docs/current-state.md` | Updated with history screen and 77 tests |
| `docs/decisions.md` | Added DKT-ADR-0008: History stores metadata, not audio |
| `docs/tasks.md` | Added DKT-TASK-0009 completed |
| `docs/tasks-archive.md` | Added DKT-TASK-0009 details |
| `docs/context/index.yml` | Added DKT-ADR-0008, DKT-TASK-0009, session summary |

## Verification

- `make context-check` passes.
- `make test` passes (77 tests, 0 failures).
- `make verify` passes.

## Follow-ups

- None. DKT-TASK-0009 is complete.
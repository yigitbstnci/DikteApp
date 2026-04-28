# Structured Logging Metadata

## Goal

Improve Dikte runtime logs so recording, clipboard capture, transcription, merge, and output-copy events can be diagnosed across services.

## Changes

- Extended `DikteLog` with sorted `key=value` metadata rendering, value escaping, key sanitizing, and testable line formatting.
- Changed log lines to a compact one-line format: `HH:mm:ss.SSS LVL area.event | message | key=value`.
- Reworked `make run` coloring so time, level, target, message, and metadata use distinct colors instead of painting the full line one color.
- Added a short per-recording session ID in `AppState` and passed it through audio, clipboard, transcription, merge, routing, output silence, and final clipboard-copy logs.
- Added detailed diagnostic fields for durations, byte counts, frame/sample counts, RMS/peak signal metrics, source app names, pasteboard change counts, model/cache state, device identifiers, and output character counts.
- Kept privacy boundaries intact by logging counts and persisted artifact metadata instead of raw transcript text or copied clipboard text.
- Added `DikteLogTests` for log line metadata formatting.
- Updated repo context docs for the new structured logging behavior and durable logging decision.
- Added a context granularity decision: committed session summaries are for meaningful development blocks or daily summaries, while runtime log sessions stay local.
- Added a `context-save` guard that refuses likely raw Dikte runtime log dumps and asks for a concise summary instead.

## Verification

- `make test` completed successfully.
- `make -n run` and an AWK sample render completed successfully.
- `make context-check` completed successfully.

## Follow-ups

- Run `make run` during the next live app debugging pass and inspect `~/Library/Logs/Dikte/dikte.log` with a real recording to validate field usefulness.

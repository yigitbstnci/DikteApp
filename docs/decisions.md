# Dikte Decisions

This file records durable workflow and architecture decisions. Keep entries short.

## DKT-ADR-0001: Repo-Resident Context Is The Durable Source

- Date: 2026-04-28
- Status: Accepted
- Decision: Durable agent context lives in committed Markdown docs plus `docs/context/index.yml`.
- Consequence: Keep `docs/current-state.md`, `docs/tasks.md`, `docs/decisions.md`, and meaningful session summaries aligned at commit/push or handoff boundaries.

## DKT-ADR-0002: Hook Automation Uses Repo Scripts

- Date: 2026-04-28
- Status: Accepted
- Decision: The standard context interface is `make context-load`, `make context-save`, and `make context-check`.
- Consequence: Tool-specific automation must call the repo scripts instead of inventing a parallel format.

## DKT-ADR-0003: Store Summaries, Not Raw Conversations

- Date: 2026-04-28
- Status: Accepted
- Decision: Commit concise summaries, decisions, tasks, and current state; do not commit raw conversations or raw logs.
- Consequence: Runtime diagnostics stay local; committed context keeps only distilled facts, verification, and follow-ups.

## DKT-ADR-0004: Architecture Reference Lives Under Docs

- Date: 2026-04-28
- Status: Accepted
- Decision: `docs/architecture.md` is the maintained architecture reference.
- Consequence: Future docs should link there instead of recreating separate architecture summaries.

## DKT-ADR-0005: Logs Use Diagnostic Metadata Without Raw Content

- Date: 2026-04-28
- Status: Accepted
- Decision: Runtime logs use stable events, sorted `key=value` metadata, and a short per-recording session ID.
- Consequence: Log counts, durations, sizes, sources, and device/cache state; never log raw transcript or clipboard text.

## DKT-ADR-0006: Context Sessions Are Meaningful Work Summaries

- Date: 2026-04-28
- Status: Accepted
- Decision: Context updates are batched for meaningful development blocks, normally during commit/push preparation or handoff, not after every small code change.
- Consequence: During active development, avoid repeated docs churn; update current state, tasks, decisions, and session summaries once the durable outcome is known.

## DKT-ADR-0007: Feature Work Must Track Test Coverage

- Date: 2026-04-29
- Status: Accepted
- Decision: Every feature change must be evaluated for test impact; if tests are needed, a concrete test task must be added to `docs/tasks.md`.
- Consequence: `make test` must stay green, and tests must not require model downloads, microphone permissions, or GUI-driven launch.

## DKT-ADR-0008: History Stores Transcript/Output/Clipboard Metadata, Not Audio

- Date: 2026-05-01
- Status: Accepted
- Decision: History persists `mergedOutput`, `transcriptSegments`, and `clipboardItems` as JSON; audio files are deleted after transcription.
- Consequence: Memory savings; no audio stored; transcript + clipboard context preserved for review.

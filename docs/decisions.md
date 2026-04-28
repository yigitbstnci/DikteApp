# Dikte Decisions

This file records durable architecture and workflow decisions. Use short ADR-style entries with stable IDs.

## DKT-ADR-0001: Repo-Resident Context Is The Durable Source

- Date: 2026-04-28
- Status: Accepted
- Decision: Agent continuity for this repo is stored in committed Markdown docs plus a small YAML index.
- Rationale: The context must survive across agents, machines, and sessions without depending on one tool's private memory database.
- Consequences: Agents must keep `docs/current-state.md`, `docs/tasks.md`, `docs/decisions.md`, and session summaries aligned with meaningful work.

## DKT-ADR-0002: Hook Automation Uses Repo Scripts

- Date: 2026-04-28
- Status: Accepted
- Decision: The universal context interface is `make context-load`, `make context-save`, and `make context-check`.
- Rationale: Shell scripts and Makefile targets are portable across Codex, Claude, Gemini, and manual terminal workflows.
- Consequences: Tool-specific hooks can be added later, but they must call the repo scripts instead of introducing a separate format.

## DKT-ADR-0003: Store Summaries, Not Raw Conversations

- Date: 2026-04-28
- Status: Accepted
- Decision: Commit concise session summaries, decisions, tasks, and current state; do not commit raw conversation transcripts, secrets, pasted private data, or full logs.
- Rationale: The repo should preserve useful engineering continuity without turning private interactions or local debugging artifacts into project history.
- Consequences: Session summaries should include goal, facts learned, changes made, verification, and follow-ups. Runtime log lines and recording-level session IDs belong in local log files, not committed context summaries.

## DKT-ADR-0004: Architecture Reference Lives Under Docs

- Date: 2026-04-28
- Status: Accepted
- Decision: `docs/architecture.md` is the maintained architecture reference; the old root-level `PROJECT_DETAIL.md` file is removed.
- Rationale: The repo context system should keep durable project knowledge under `docs/` so agents and humans have one canonical place to read and update architecture context.
- Consequences: README and future docs should link to `docs/architecture.md` instead of recreating root-level architecture summaries.

## DKT-ADR-0005: Logs Use Diagnostic Metadata Without Raw Content

- Date: 2026-04-28
- Status: Accepted
- Decision: Runtime logs should use stable event names plus sorted `key=value` metadata and a short per-recording session ID.
- Rationale: Debugging audio routing, clipboard capture, transcription, and merge behavior requires correlating events across services without reading private dictated or copied content.
- Consequences: Add counts, durations, byte sizes, source apps, device IDs, and cache state to logs; do not log raw transcript text or clipboard text.

## DKT-ADR-0006: Context Sessions Are Meaningful Work Summaries

- Date: 2026-04-28
- Status: Accepted
- Decision: `docs/context/sessions/` entries should represent meaningful development blocks or daily summaries, not every runtime recording, log session, or small debugging attempt.
- Rationale: Context should preserve durable engineering continuity without growing into a token-heavy chronological log.
- Consequences: Prefer updating `docs/current-state.md`, `docs/tasks.md`, or an existing same-day summary for small follow-ups. Create a new session summary only when it captures a coherent change set, decision, verification result, or follow-up plan.

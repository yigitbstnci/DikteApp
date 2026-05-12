<!-- Context: agent-system/lookup | Priority: high | Version: 1.0 | Updated: 2026-05-12 -->

# Project-Native Context Template

Use this as a portable setup checklist. Replace placeholders before writing files. Preview all proposed files and wait for approval.

## Parameters

| Parameter | Default | Notes |
|---|---|---|
| `PROJECT_NAME` | required | Human-readable project name. |
| `TASK_PREFIX` | `PROJ-TASK` | Example: `APP-TASK`, `WEB-TASK`, `DKT-TASK`. |
| `DECISION_PREFIX` | `PROJ-ADR` | Example: `APP-ADR`, `WEB-ADR`, `DKT-ADR`. |
| `CONTEXT_DIR` | `docs/context` | Directory for index and session summaries. |
| `SESSION_LIMIT` | `2` | Number of latest summaries loaded by default. |
| `MAX_LINES_PER_FILE` | `160` | Startup line budget per file. |
| `RUNNER` | `make` | Use Make, npm scripts, just, or shell wrappers. |

## Files To Create

```text
docs/current-state.md
docs/tasks.md
docs/decisions.md
docs/architecture.md
docs/context/index.yml
docs/context/sessions/.gitkeep
scripts/context/load.sh
scripts/context/save-session.sh
scripts/context/check.sh
```

If the project does not use shell scripts, keep the same behavior in the selected runner and document the commands in `AGENTS.md`.

## Starter Docs

`docs/current-state.md`:

```md
# PROJECT_NAME Current State

Last updated: YYYY-MM-DD

## Snapshot

Short description of what the project does.

## Current Implementation

- Main runtime shape, commands, storage, integrations, and constraints.

## Known Gaps

- Gaps that future agents should know before making changes.

## Workflow Notes

- Source-of-truth files, generated files, build/test commands, and safety rules.
```

`docs/tasks.md`:

```md
# PROJECT_NAME Tasks

This file tracks active work and follow-ups that survive across agent sessions.

## Active

No active tasks are currently recorded.

## Ongoing

### TASK_PREFIX-0001: Keep Project Context Healthy

- Status: Ongoing
- Goal: Keep project context docs and index aligned with meaningful changes.
- Acceptance: `context-check` passes and `context-load` stays compact and useful.

## Backlog

## Completed

## Blocked

No blocked tasks are currently recorded.
```

`docs/decisions.md`:

```md
# PROJECT_NAME Decisions

This file records durable workflow and architecture decisions. Keep entries short.

## DECISION_PREFIX-0001: Project Context Is Repo-Resident

- Date: YYYY-MM-DD
- Status: Accepted
- Decision: Durable agent context lives in committed Markdown docs plus `docs/context/index.yml`.
- Consequence: Keep current state, tasks, decisions, and meaningful session summaries aligned at handoff boundaries.
```

`docs/architecture.md`:

```md
# PROJECT_NAME Architecture

Compact architecture reference for agent startup. Keep it limited to runtime shape, critical invariants, and operator-facing facts.

## Runtime Shape

1. Describe the main request, event, or workflow path.

## Core Modules

- `path/to/module`: purpose.

## Critical Behavior

- Invariants future agents must preserve.

## Build And Context Workflow

- Build/test commands.
- `context-load`, `context-save`, and `context-check` behavior.
```

## Index Template

```yaml
version: 1
updated_at: "YYYY-MM-DD"
project: "PROJECT_NAME"
context_contract:
  source_of_truth: "committed Markdown files"
  load_command: "make context-load"
  save_command: "make context-save SUMMARY=/path/to/session.md TITLE=\"short-title\""
  check_command: "make context-check"
settings:
  task_prefix: "TASK_PREFIX"
  decision_prefix: "DECISION_PREFIX"
  session_limit: 2
  max_lines_per_file: 160
  forbidden_patterns: []
load_order:
  - docs/current-state.md
  - docs/tasks.md
  - docs/context/sessions
  - docs/decisions.md
  - docs/architecture.md
session_summaries: []
decisions:
  - DECISION_PREFIX-0001
tasks:
  active: []
  ongoing:
    - TASK_PREFIX-0001
  backlog: []
  completed: []
  blocked: []
```

## Portable Check Requirements

The implementation may be shell, JavaScript, Python, Ruby, or the project's native tooling, but it must enforce:

- Required file presence.
- Index path resolution.
- Duplicate session ID detection.
- Decision ID parity between decisions doc and index.
- Task ID parity between tasks doc and index.
- Secret and raw-dump guard.
- Optional project-specific forbidden patterns from the index.

## Sentinel Test

Run this after creating or porting the protocol:

1. Add one temporary task, one temporary decision, and one temporary session summary.
2. Sync `docs/context/index.yml`.
3. Confirm `context-check` passes.
4. Remove the task from the index and confirm `context-check` fails.
5. Restore the index and add a fake private marker such as `API_KEY=example` to a temp docs file; confirm `context-check` fails.
6. Remove sentinel content and confirm `context-check` passes again.

Do not commit sentinel failures or fake secrets.

## Runner Mapping

| Runner | Commands |
|---|---|
| Make | `make context-load`, `make context-save`, `make context-check` |
| npm | `npm run context:load`, `npm run context:save -- --summary ...`, `npm run context:check` |
| just | `just context-load`, `just context-save ...`, `just context-check` |
| shell | `scripts/context/load.sh`, `scripts/context/save-session.sh`, `scripts/context/check.sh` |

Whichever runner is chosen, `AGENTS.md` must show the exact commands.

## Related

- ../guides/project-native-context-protocol.md
- ../guides/init-project-onboarding.md
- ../guides/manage-context.md

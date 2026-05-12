<!-- Context: agent-system/guides | Priority: high | Version: 1.0 | Updated: 2026-05-12 -->

# Project-Native Context Protocol

**Core Idea**: Project state belongs in the target project, not in MYB reusable context. Use this protocol when a project needs durable agent memory for current state, tasks, decisions, architecture, and handoff summaries.

## When To Use

- Use a project-native protocol when future agents must resume project work without private chat history.
- Use it before creating broad MYB context for project-specific state.
- Keep `.opencode/context` for reusable MYB operating knowledge, agent design rules, command workflows, and cross-project patterns.
- Keep target-project facts in the target project under `docs/` or an equivalent committed docs area.

## Minimum Contract

Every project-native context protocol should expose the same operator interface, even if the implementation uses Make, npm scripts, just, or direct shell scripts:

| Command | Purpose |
|---|---|
| `context-load` | Print bounded startup context for an agent. |
| `context-save` | Save a concise session summary and update the context index. |
| `context-check` | Validate file presence, index resolution, drift, and safety rules. |

Preferred Make targets:

```text
make context-load
make context-save SUMMARY=/path/to/session.md TITLE="short-title"
make context-check
```

Equivalent wrappers are acceptable when the project does not use Make. The command names and behavior should remain stable in `AGENTS.md`.

## Minimum File Set

Use these paths by default unless the project already has an equivalent convention:

| Path | Role |
|---|---|
| `docs/current-state.md` | Compact current implementation, known gaps, workflow notes. |
| `docs/tasks.md` | Active, ongoing, backlog, completed, and blocked tasks. |
| `docs/decisions.md` | Durable ADR-style decisions and consequences. |
| `docs/architecture.md` | Compact architecture/reference map for agent startup. |
| `docs/context/index.yml` | Machine-readable context contract and summary index. |
| `docs/context/sessions/` | Concise session summaries for meaningful work blocks. |

## Index Contract

`docs/context/index.yml` should describe the protocol, not duplicate every doc:

```yaml
version: 1
updated_at: "YYYY-MM-DD"
project: "Project Name"
context_contract:
  source_of_truth: "committed Markdown files"
  load_command: "make context-load"
  save_command: "make context-save SUMMARY=/path/to/session.md TITLE=\"short-title\""
  check_command: "make context-check"
settings:
  task_prefix: "PROJ-TASK"
  decision_prefix: "PROJ-ADR"
  session_limit: 2
  max_lines_per_file: 160
load_order:
  - docs/current-state.md
  - docs/tasks.md
  - docs/context/sessions
  - docs/decisions.md
  - docs/architecture.md
session_summaries: []
decisions: []
tasks:
  active: []
  ongoing: []
  backlog: []
  completed: []
  blocked: []
```

## Load Behavior

- Load only bounded startup context; do not dump every session summary.
- Default order: current state, tasks, latest session summaries, decisions, architecture.
- Default budget: latest 2 session summaries and about 160 lines per file.
- If the project needs a stricter budget, prefer fewer sessions before truncating core state files.

## Save Behavior

- Save summaries, not raw conversations or logs.
- Require an existing non-empty summary file.
- Derive a stable session ID from date plus slug unless the project has a stronger ID rule.
- Add new sessions near the top of `session_summaries`.
- Refuse likely secrets, raw runtime logs, raw transcripts, clipboard contents, and private keys.
- Do not update context docs after every small edit; batch at commit, push, handoff, or explicit context-maintenance boundaries.

## Check Behavior

`context-check` should validate:

- Required files exist.
- Every `docs/...` path listed in the index resolves.
- Session IDs are unique.
- Decision IDs in `docs/decisions.md` match the index.
- Task IDs in `docs/tasks.md` match the index.
- Secret and raw-dump patterns are not present in committed docs.
- Project-specific forbidden patterns are checked when configured.

Use project-specific prefixes from the index when possible. For example, a project can use `WEB-ADR` and `WEB-TASK` instead of Dikte's `DKT-ADR` and `DKT-TASK`.

## Session Lifecycle

Use `status: active` as the default. Add only statuses that change loading behavior:

| Status | Meaning |
|---|---|
| `active` | Recent or useful summary; eligible for normal loading. |
| `important` | Durable reference; can be loaded on demand or by explicit task. |
| `archived` | Retained for history; not part of normal startup. |
| `stale` | Superseded; keep only if historical trace matters. |

## AGENTS.md Integration

Project `AGENTS.md` should name the protocol explicitly:

```md
## Project Context

- Run `make context-load` before project work.
- Use `docs/current-state.md`, `docs/tasks.md`, `docs/decisions.md`, and `docs/context/index.yml` as the source of truth for project state.
- Update context with `make context-save` and validate with `make context-check` only at meaningful handoff, commit, push, or explicit context-maintenance boundaries.
- `.opencode/context` stores reusable agent-system knowledge, not this project's current state.
```

## Related

- project-native-context-template.md
- init-project-onboarding.md
- manage-context.md

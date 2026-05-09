---
description: Initialize MYB Software Studio in an existing or fresh project
dependencies:
  - workflow:init-project
  - context:agent-system/guides/init-project-onboarding
  - context:core/guides/path-resolution
---

# /init-project

**Purpose**: Onboard the MYB Software Studio system into a project safely.

**Arguments**: `$ARGUMENTS`

## Usage

```text
/init-project
/init-project --existing
/init-project --fresh
/init-project --dry-run
```

## Modes

| Mode | Use When |
|---|---|
| `--existing` | Project already has files, docs, configs, or AGENTS.md |
| `--fresh` | New project with no meaningful structure yet |
| `--dry-run` | Analyze and preview only; do not write |

## Workflow

1. Resolve `SYSTEM_ROOT`.
2. Detect project mode: existing, fresh, or unclear.
3. Analyze read-only first: files, docs, configs, commands, existing `AGENTS.md`.
4. Report findings with confidence scores and missing information.
5. Propose setup plan.
6. Ask approval before writing.
7. For existing projects, merge the MYB block from `AGENTS_TEMPLATE.md`; never overwrite existing `AGENTS.md`.
8. For fresh projects, ask start questions and create a base project `AGENTS.md`.
9. Create/update project context only after approval.

## Start Questions For Fresh Projects

1. Project name and purpose?
2. Target users?
3. Product type: web, backend, mobile, data, agentic, docs/business?
4. Preferred tech stack, if known?
5. UI/content language?
6. MVP scope and non-goals?
7. Security/privacy sensitivity?
8. Deployment target, if known?
9. Success criteria?

## Existing Project Report Format

```text
Detected Mode: Existing Project
Evidence:
- package/config/docs found
- AGENTS.md: exists/absent

Confidence:
- Tech stack: high|medium|low|unknown
- Test command: high|medium|low|unknown
- Deploy process: high|medium|low|unknown

Missing Information:
1. ...

Proposed Setup:
- Merge AGENTS integration block
- Create/update project context
- Recommend specialist agents if needed
```

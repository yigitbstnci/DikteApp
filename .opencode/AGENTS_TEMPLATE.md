# AGENTS.md

## First Step After Installation / Integration

Update this file before using the system in a new project or integrating it into an existing project.

Set or confirm:

- project name and purpose
- `SYSTEM_ROOT`
- runtime integration mode
- primary orchestrator path
- context root
- command discovery path
- project-specific safety and privacy rules
- active agents and commands

If the target project already has an `AGENTS.md`, do not overwrite it. Keep the target project's instructions as higher priority and merge only the MYB Software Studio integration block below.

## MYB Software Studio System

This folder contains a portable agent system for managing software products from idea to delivery.

- `SYSTEM_ROOT`: folder containing `system-manifest.json`
- Primary agent: `{SYSTEM_ROOT}/agents/myb-Orchestrator.md`
- Context navigation: `{SYSTEM_ROOT}/context/navigation.md`
- System manifest: `{SYSTEM_ROOT}/system-manifest.json`

## Integration Block For Existing AGENTS.md

If the target project already has an `AGENTS.md`, add a short block like this instead of replacing the file:

```md
## MYB Software Studio Integration

This project uses the MYB Software Studio agent system.

- SYSTEM_ROOT: ./newsystem
- Primary agent: ./newsystem/agents/myb-Orchestrator.md
- Context navigation: ./newsystem/context/navigation.md
- System manifest: ./newsystem/system-manifest.json

Target project instructions remain higher priority. Use MYB workflows only when they do not conflict with local project rules.
```

## Context Loading

Start with:

1. `{SYSTEM_ROOT}/context/navigation.md`
2. `{SYSTEM_ROOT}/context/core/guides/path-resolution.md`
3. Task-specific context from navigation routes

Do not assume the runtime working directory is the system root.

## Commands

- `/create-agent` — create new specialist agents through interview and context intake
- `/update-agent` — update existing agents with user-requested changes
- `/manage-context` — create/update/map context files
- `/check-context-deps` — validate dependency health

## Persistent Rules

If the user gives a rule meant to apply beyond the current task, ask whether to integrate it into the relevant agent, command, workflow, or context guide.

Behavior-changing rules should be integrated into agent/command prompts, not only stored as context.

## Safety

- Ask before file writes, destructive operations, or system structure changes.
- Preview create/update changes before applying them.
- Stop on validation failure, report the issue, propose a fix, and wait for approval.
- Never expose secrets or private credentials.

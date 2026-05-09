<!-- Context: agent-system/lookup | Priority: critical | Version: 1.0 | Updated: 2026-05-09 -->

# Dependency Standards

**Purpose**: Standard dependency format for agents, commands, contexts, workflows, and registry.

| Type | Format | Example |
|---|---|---|
| Agent | `agent:{id}` | `agent:agent-system-designer` |
| Context | `context:{category}/{function}/{file}` | `context:agent-system/guides/create-agent` |
| Workflow | `workflow:{id}` | `workflow:create-agent` |
| Command | `command:{id}` | `command:create-agent` |

## Rules

- Declare context used by agents and commands.
- Registry entries must point to real files.
- Navigation should list important context files.
- Report orphaned or broken references; do not auto-fix without approval.
- Use `context:root/navigation` for the top-level context navigation file.

## Related

- ../../../command/check-context-deps.md

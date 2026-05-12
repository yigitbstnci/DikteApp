---
description: Create, update, map, and organize context files for agents and workflows
dependencies:
  - agent:agent-system-designer
  - workflow:manage-context
  - context:agent-system/guides/manage-context
  - context:agent-system/guides/project-native-context-protocol
---

# /manage-context

**Purpose**: Manage persistent knowledge for agents, workflows, and commands.

**Arguments**: `$ARGUMENTS`

## Usage

```text
/manage-context map
/manage-context create for frontend-agent
/manage-context update context/agent-system/guides/context-intake-rules.md
```

## Rules

- Create context only for reusable knowledge.
- Keep project current state, tasks, decisions, and handoff summaries in the target project's native context protocol.
- Keep files small and focused.
- Ask whether missing knowledge should be collected from the user or extracted from files.
- Update navigation and system manifest when context changes.
- Navigation files must follow: Purpose → Structure → Quick Routes → By Concern/Type → Related Context.
- Agent/command-facing paths must resolve from `SYSTEM_ROOT`.
- Preview before writing.

## Operations

| Operation | Behavior |
|---|---|
| `map` | Show context categories, loading strategy, and project/native authority split |
| `create for <agent>` | Ask what reusable knowledge the agent needs |
| `update <file>` | Revise context with preview and version note |
| `organize <category>` | Move files into function-based folders |

## Context Creation Questions

1. Which agent/workflow will use this context?
2. Is the knowledge persistent or task-specific?
3. What decision should this context improve?
4. Which folder fits: concepts, guides, lookup, examples, or errors?
5. What related files should be linked?

If the answer is current project state or task memory, route it to the target project's native context files instead of `.opencode/context`.

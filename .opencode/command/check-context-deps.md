---
description: Validate dependency health across agents, commands, workflows, context, and registry
dependencies:
  - workflow:check-context-deps
  - context:agent-system/lookup/dependency-standards
---

# /check-context-deps

**Purpose**: Keep the system coherent as agents and contexts grow.

**Arguments**: `$ARGUMENTS`

## Usage

```text
/check-context-deps
/check-context-deps agent-system-designer
/check-context-deps --verbose
```

## Checks

- Referenced context files exist.
- Agent/command dependencies are declared.
- Registry entries point to real files.
- Navigation files include relevant contexts.
- Context files are not orphaned.
- Workflow references resolve.

## Modes

| Mode | Behavior |
|---|---|
| no args | Analyze entire system |
| `<agent-or-command>` | Analyze one component |
| `--verbose` | Include reference locations and registry entries |

## Dependency Format

Use `type:path` consistently:

```text
context:root/navigation
context:agent-system/guides/create-agent
workflow:create-agent
agent:agent-system-designer
command:create-agent
```

## Output

Report only by default. Do not auto-fix unless the user explicitly approves a fix plan.

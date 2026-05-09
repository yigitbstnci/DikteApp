---
description: Update an existing agent using user requests plus structural analysis
dependencies:
  - agent:agent-system-designer
  - workflow:update-agent
  - context:agent-system/guides/update-agent
---

# /update-agent

**Purpose**: Improve an existing agent based on user feedback, observed gaps, or system standards.

**Arguments**: `$ARGUMENTS`

## Usage

```text
/update-agent agent-system-designer
/update-agent myb-orchestrator "make approval gates stricter"
```

## Behavior

The command must accept an optional user update request. If no request is provided, analyze the target agent and ask what improvement is desired.

## Workflow

1. Parse target agent and optional update request from `$ARGUMENTS`.
2. If target is missing, ask which agent should be updated.
3. If update request is missing, ask what behavior should change.
4. Read current agent responsibilities and dependencies.
5. Detect conflicts, overreach, missing context, or registry impact.
6. Preview proposed edits and affected files.
7. Ask approval before writing.
8. Recommend `/check-context-deps`.

## Update Request Examples

```text
/update-agent myb-orchestrator "make approval gates stricter"
/update-agent frontend-agent "add accessibility review"
/update-agent agent-system-designer "ask more context questions before creating agents"
```

## Preview Format

```text
Target Agent: <agent>
User Request: <request>
Proposed Changes:
- <change>
Dependencies Affected:
- <dependency>
Approval needed before editing.
```

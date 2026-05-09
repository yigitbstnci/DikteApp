<!-- Context: agent-system/lookup | Priority: critical | Version: 1.0 | Updated: 2026-05-09 -->

# Agent Recommendation Rules

**Purpose**: Decide when MYB Orchestrator should recommend a new specialist agent.

## Recommend When 2+ Are True

| Signal | Example |
|---|---|
| Repeated expertise | Many frontend/UI tasks |
| Persistent context needed | Framework/component standards |
| Multi-step workflow | Research → design → build → validate |
| Domain quality rules | Accessibility, security, compliance |
| Existing agent too general | Orchestrator cannot own details well |

## Do Not Recommend When

- It is a one-off task.
- A simple context file solves the gap.
- A workflow checklist is enough.
- Responsibilities overlap heavily with an existing agent.

## Recommendation Format

```text
This looks like a web app workflow.
Recommended: Frontend Agent
Why: UI architecture + component standards + accessibility
Options: A) create plan B) continue without agent C) create context only
```

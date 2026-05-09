<!-- Context: core/concepts | Priority: critical | Version: 1.0 | Updated: 2026-05-09 -->

# Operating Principles

**Core Idea**: MYB Software Studio should be intelligent but simple: a small core that can grow through explicit agent, context, and workflow creation.

## Key Points

- Start with one orchestrator and one system-design specialist.
- Add agents only for durable, repeated, specialist capabilities.
- Prefer context or workflow over a new agent for simple gaps.
- Keep every generated file focused and easy to scan.
- User approval controls all writes and structural changes.

## Minimal Example

```text
Need frontend expertise?
→ Check if recurring/specialized
→ Ask for frontend context
→ Preview Frontend Agent
→ Create only after approval
```

## Related

- ../guides/execution-workflow.md
- ../../agent-system/lookup/agent-recommendation-rules.md

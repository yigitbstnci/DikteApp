<!-- Context: agent-system/concepts | Priority: critical | Version: 1.0 | Updated: 2026-05-09 -->

# Agent Design Principles

**Core Idea**: Agents are durable specialists, not one-off helpers. Each agent needs a clear responsibility, boundaries, context dependencies, and validation expectations.

## Key Points

- One agent should own one coherent capability.
- Do not overlap responsibilities with existing agents.
- Every specialist should know what context it must load.
- Prefer explicit workflows over vague autonomy.
- Commands should route to agents, not duplicate agent logic.

## Minimal Example

```text
Frontend Agent:
Owns UI architecture, component standards, accessibility.
Does not own backend, deployment, or product strategy.
```

## Related

- ../lookup/agent-recommendation-rules.md
- ../guides/context-intake-rules.md

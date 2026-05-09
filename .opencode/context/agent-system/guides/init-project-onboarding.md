<!-- Context: agent-system/guides | Priority: critical | Version: 1.0 | Updated: 2026-05-09 -->

# Init Project Onboarding

**Core Idea**: `/init-project` teaches the system a project before real work begins. It supports both existing project onboarding and fresh project initialization.

## Key Rules

- Analyze read-only first; write only after approval.
- Never overwrite an existing `AGENTS.md`.
- Existing project rules have higher priority than MYB template guidance.
- Use `SYSTEM_ROOT` for MYB system paths.
- Report confidence and missing information instead of guessing.

## Existing Project Output

```text
Mode: Existing Project
Evidence: package.json, README, AGENTS.md
Confidence: stack=high, tests=medium, deploy=unknown
Next: merge AGENTS block + create project context
```

## Fresh Project Output

```text
Mode: Fresh Project
Ask: purpose, users, stack, MVP, privacy, deployment
Next: create base AGENTS.md + project context
```

## Related

- ../../core/guides/path-resolution.md
- create-agent.md
- manage-context.md

<!-- Context: core/guides | Priority: critical | Version: 1.0 | Updated: 2026-05-09 -->

# Safety and Approval

**Core Idea**: The user stays in control. The system previews risky or persistent changes before execution and stops on failures.

## Rules

- Ask approval before file writes, deletes, destructive commands, dependency changes, or system structure changes.
- Never auto-delete or cleanup without explicit confirmation.
- On validation failure: report, propose fix, request approval, then fix.
- Do not expose secrets or private data.
- Keep scope small and avoid unrelated changes.

## Approval Format

```text
Proposed Plan:
1. Create agent X
2. Add context Y
3. Update registry

Approval needed before proceeding.
```

## Related

- execution-workflow.md

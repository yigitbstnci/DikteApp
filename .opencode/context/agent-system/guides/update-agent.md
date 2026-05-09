<!-- Context: agent-system/guides | Priority: high | Version: 1.0 | Updated: 2026-05-09 -->

# Update Agent Workflow

**Core Idea**: Agent updates combine the user’s requested change with structural analysis of the existing agent.

## Steps

1. Identify target agent.
2. Capture user update request, if provided.
3. Read current purpose, rules, workflow, and dependencies.
4. Detect conflicts, missing context, or overreach.
5. Propose focused edits.
6. Preview before writing.
7. Validate dependencies after update.

## Example

```text
/update-agent frontend-agent "add accessibility review"
→ Adds responsibility only if frontend-agent owns UI quality
→ Suggests accessibility context if missing
```

## Related

- ../lookup/dependency-standards.md

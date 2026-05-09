<!-- Context: core/guides | Priority: critical | Version: 1.0 | Updated: 2026-05-09 -->

# Path Resolution

**Core Idea**: All portable system paths resolve from `SYSTEM_ROOT`, the folder that contains `system-manifest.json`.

## Rules

- Define `SYSTEM_ROOT` before loading agents, commands, context, or workflows.
- Resolve context as `{SYSTEM_ROOT}/context/...`.
- Resolve agents as `{SYSTEM_ROOT}/agent/...`.
- Resolve commands as `{SYSTEM_ROOT}/command/...`.
- If a file is missing, first verify `SYSTEM_ROOT` before assuming the file is absent.

## Minimal Example

```text
SYSTEM_ROOT=/path/to/newsystem
Context navigation={SYSTEM_ROOT}/context/navigation.md
Manifest={SYSTEM_ROOT}/system-manifest.json
```

## Related

- execution-workflow.md
- safety-and-approval.md

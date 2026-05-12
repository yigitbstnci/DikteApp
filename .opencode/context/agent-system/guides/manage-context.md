<!-- Context: agent-system/guides | Priority: high | Version: 1.0 | Updated: 2026-05-12 -->

# Manage Context Workflow

**Core Idea**: Context stores reusable knowledge that improves future agent behavior. It should not store temporary task details.

Project-specific current state, tasks, decisions, and handoff memory should live in the target project's native context protocol when one exists. `.opencode/context` stores reusable MYB operating knowledge and cross-project patterns.

## Steps

1. Decide if knowledge is persistent and reusable.
2. Decide authority: target-project context for project state, `.opencode/context` for reusable MYB knowledge.
3. Choose function folder: concepts, guides, lookup, examples, or errors.
4. Keep content minimal: core idea, key points, example, related files.
5. Update category navigation using Structure → Quick Routes → By Concern/Type → Related Context format.
6. Update registry if used.
7. Run dependency check when agent/command references change.

## Authority Split

| Knowledge | Destination |
|---|---|
| Current project state | Target project `docs/current-state.md` or equivalent |
| Active/backlog/completed tasks | Target project `docs/tasks.md` or equivalent |
| Project decisions | Target project `docs/decisions.md` or equivalent |
| Handoff/session summaries | Target project `docs/context/sessions/` or equivalent |
| Reusable agent behavior | `.opencode/context` |
| Command/workflow operating rules | `.opencode/context` |
| Cross-project templates and patterns | `.opencode/context` |

If a project lacks a native context protocol, recommend `project-native-context-protocol.md` and `lookup/project-native-context-template.md` before creating broad project-state docs inside `.opencode/context`.

## Navigation Format

Every generated `navigation.md` should include:

1. `Purpose`
2. `Structure` ASCII tree
3. `Quick Routes` table with `Task` and `Path`
4. `By Concern` or `By Type`
5. `Related Context`

Path references inside generated guidance should resolve from `SYSTEM_ROOT` when used by agents or commands.

## Related

- context-intake-rules.md
- project-native-context-protocol.md
- ../lookup/dependency-standards.md

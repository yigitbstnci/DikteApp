<!-- Context: agent-system/guides | Priority: high | Version: 1.0 | Updated: 2026-05-09 -->

# Manage Context Workflow

**Core Idea**: Context stores reusable knowledge that improves future agent behavior. It should not store temporary task details.

## Steps

1. Decide if knowledge is persistent and reusable.
2. Choose function folder: concepts, guides, lookup, examples, or errors.
3. Keep content minimal: core idea, key points, example, related files.
4. Update category navigation using Structure → Quick Routes → By Concern/Type → Related Context format.
5. Update registry if used.
6. Run dependency check when agent/command references change.

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
- ../lookup/dependency-standards.md

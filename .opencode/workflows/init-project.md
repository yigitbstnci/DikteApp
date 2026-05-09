# Workflow: Init Project

## Purpose

Initialize MYB Software Studio for an existing or fresh project without overwriting local project rules.

## Existing Project Steps

1. Resolve `SYSTEM_ROOT`.
2. Scan project files read-only.
3. Detect stack, commands, docs, AGENTS.md, and existing context.
4. Produce findings, confidence scores, and missing questions.
5. Propose AGENTS merge block and project context files.
6. Ask approval before writing.
7. Merge; never overwrite existing `AGENTS.md`.
8. Recommend `/check-context-deps`.

## Fresh Project Steps

1. Ask start questions.
2. Draft base project `AGENTS.md`.
3. Draft project context structure.
4. Ask approval before writing.
5. Create approved files.
6. Recommend first specialist agents only when justified.

## Safety

- Analysis is read-only until approval.
- Existing project instructions have higher priority.
- Missing information should be reported, not guessed.

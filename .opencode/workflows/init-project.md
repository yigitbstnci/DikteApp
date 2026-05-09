# Workflow: Init Project

## Purpose

Initialize MYB Software Studio for an existing or fresh project without overwriting local project rules.

## Existing Project Steps

1. Resolve `SYSTEM_ROOT`.
2. Scan project files read-only.
3. Detect stack, commands, docs, AGENTS.md, and existing context.
4. Read project docs enough to summarize purpose, workflow, rules, commands, and safety/privacy notes.
5. Produce Turkish findings, confidence scores, missing questions, and a project understanding summary.
6. Standardize paths using `{SYSTEM_ROOT}/...` in the output.
7. Propose AGENTS merge block and project context files.
8. Present options: AGENTS block only, AGENTS block + project context, or no change.
9. Ask approval before writing.
10. Merge; never overwrite existing `AGENTS.md`.
11. Recommend `/check-context-deps`.

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
- Default user-facing output is Turkish unless user asks otherwise.
- If no specialist agent is recommended, explain why in 2-3 bullets.

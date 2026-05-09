<!-- Context: agent-system/guides | Priority: high | Version: 1.0 | Updated: 2026-05-09 -->

# Use Skill Workflow

**Core Idea**: Load a skill only when the current task needs that reusable behavior. Do not load skills by default.

## Steps

1. Check available skills from the runtime's skill list.
2. Match the task to a skill name and description.
3. If permission is `ask`, request user approval before loading.
4. Load the skill with the native `skill` tool.
5. Apply the loaded instructions only to the relevant task.

## Minimal Example

```text
Available: git-release — Create consistent releases
Task: Prepare release notes
Action: skill({ name: "git-release" })
```

## When Not To Use

- Do not use a skill for one-off project facts.
- Do not use a skill when context already contains the needed standard.
- Do not use denied or hidden skills.

## Source

- https://opencode.ai/docs/skills/ — Updated 2026-05-09

## Related

- ../concepts/skills.md
- ../lookup/skill-structure.md

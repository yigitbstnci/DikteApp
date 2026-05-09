<!-- Context: agent-system/guides | Priority: high | Version: 1.0 | Updated: 2026-05-09 -->

# Create Skill Workflow

**Core Idea**: Create skills for reusable optional behavior that agents can load on-demand. Keep each skill focused and discoverable.

## Steps

1. Confirm a skill is better than context, command, workflow, or agent.
2. Choose a valid lowercase hyphenated name.
3. Create one folder per skill name.
4. Add `SKILL.md` with required frontmatter.
5. Write a specific `description` so agents know when to load it.
6. Configure permissions if needed.
7. Test whether the skill appears in available skills.

## Minimal Example

```text
.opencode/skills/git-release/SKILL.md
name: git-release
description: Create consistent releases and changelogs
```

## Validation

- `SKILL.md` is all caps.
- `name` matches folder name.
- `name` matches `^[a-z0-9]+(-[a-z0-9]+)*$`.
- `description` is specific and 1-1024 characters.

## Source

- https://opencode.ai/docs/skills/ — Updated 2026-05-09

## Related

- ../concepts/skills.md
- ../lookup/skill-structure.md

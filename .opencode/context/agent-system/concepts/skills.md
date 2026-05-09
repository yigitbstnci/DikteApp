<!-- Context: agent-system/concepts | Priority: high | Version: 1.0 | Updated: 2026-05-09 -->

# OpenCode Agent Skills

**Core Idea**: Skills are reusable instruction packages loaded on-demand through OpenCode's native `skill` tool. They are useful when an agent needs optional, task-specific behavior without permanently expanding the agent prompt.

## Key Points

- A skill is a folder with `SKILL.md` inside.
- Agents see available skills and load them only when needed.
- Skills are not agents, commands, or long-term project context.
- Use skills for reusable behavior; use context for durable knowledge.
- Skill permissions can allow, deny, or ask before loading.

## Decision Table

| Need | Use |
|---|---|
| Reusable optional behavior | Skill |
| Persistent project knowledge | Context |
| User-triggered operation | Command |
| Specialist reasoning/execution | Agent |

## Source

- https://opencode.ai/docs/skills/ — Updated 2026-05-09

## Related

- ../guides/use-skill.md
- ../guides/create-skill.md
- ../lookup/skill-structure.md

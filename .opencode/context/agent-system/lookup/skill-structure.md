<!-- Context: agent-system/lookup | Priority: high | Version: 1.0 | Updated: 2026-05-09 -->

# Skill Structure Lookup

**Purpose**: Quick reference for OpenCode Agent Skills structure, discovery, frontmatter, permissions, and troubleshooting.

## Discovery Paths

| Scope | Path |
|---|---|
| Project OpenCode | `.opencode/skills/<name>/SKILL.md` |
| Global OpenCode | `~/.config/opencode/skills/<name>/SKILL.md` |
| Project Claude-compatible | `.claude/skills/<name>/SKILL.md` |
| Global Claude-compatible | `~/.claude/skills/<name>/SKILL.md` |
| Project agent-compatible | `.agents/skills/<name>/SKILL.md` |
| Global agent-compatible | `~/.agents/skills/<name>/SKILL.md` |

## Frontmatter

| Field | Required | Notes |
|---|---|---|
| `name` | yes | Must match folder name |
| `description` | yes | 1-1024 chars |
| `license` | no | Optional |
| `compatibility` | no | Optional |
| `metadata` | no | String-to-string map |

## Name Rule

```text
^[a-z0-9]+(-[a-z0-9]+)*$
```

## Permission Values

| Value | Behavior |
|---|---|
| `allow` | Loads immediately |
| `deny` | Hidden/rejected |
| `ask` | User approval required |

## Troubleshooting

- Verify file is exactly `SKILL.md`.
- Check `name` and `description` frontmatter.
- Ensure skill name is unique.
- Check skill permissions.

## Source

- https://opencode.ai/docs/skills/ — Updated 2026-05-09

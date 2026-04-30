---
name: git-commit-standard
description: Standardize git commit messages for this repo. Use when Codex writes, reviews, edits, or suggests commit messages; when the user asks to commit or push; or when a change set needs a concise commit summary.
---

# Git Commit Standard

Use lightweight Conventional Commits plus a structured body for non-trivial work. The goal is that another AI can read the last three commits and understand what changed, why it changed, where it happened, how it was verified, and which session/agent/model/tooling produced it.

## Format

```text
type(scope): summary

Structured body when needed.
```

- Use lowercase `type`.
- Use optional lowercase `scope` only when it adds clarity.
- Keep the summary imperative, present tense, and under 72 characters.
- Do not end the summary with a period.
- Write commit messages in English unless the user explicitly requests another language.

## Types

- `feat`: user-facing feature or capability
- `fix`: bug fix or broken behavior
- `docs`: documentation, context, or instruction-only change
- `test`: tests only
- `refactor`: behavior-preserving code change
- `perf`: performance improvement
- `build`: project, dependency, or tooling change
- `chore`: maintenance that does not fit above

## Body Rules

Small docs/test/chore commits may use only the subject when the diff is obvious.

Use the rich handoff body when a commit:

- changes behavior
- fixes a bug
- adds or changes tests for behavior
- touches multiple subsystems
- creates, removes, or changes a durable interface/model/service
- needs context for a future agent to understand it from commit history alone

## Rich Handoff Body

Use these sections in this order. Omit `Open Questions` only when there are none.

```text
Context:
- Why this change exists.

Before:
- Previous behavior or structure.

After:
- New behavior or structure.

Changed:
- Main files, models, services, or workflows affected.

Verification:
- Commands, tests, builds, or checks run.

Open Questions:
- Remaining uncertainty or follow-up, if any.

Metadata:
- Session: <session id or context summary id>
- Agent: Codex | Claude | Cursor | Manual | Not recorded
- Model: <model name or Not recorded>
- Tooling: <main tools used, e.g. shell, apply_patch, xcodebuild>
```

Keep bullets concise. Prefer facts over narration. Do not paste raw logs, private content, transcript text, clipboard text, or unrelated implementation detail.

If exact session/model/tool data is unavailable, write `Not recorded`; do not invent metadata.

## Commit Workflow

1. Inspect `git status --short --branch`.
2. Inspect the staged or intended diff before writing the message.
3. Commit only files that belong to the requested change.
4. If unrelated work exists, leave it unstaged and mention it in the final response.
5. For docs/context-only commits, prefer `docs: ...`.
6. For non-trivial commits, include the rich handoff body.

## Examples

```text
fix(audio): reject empty recorder output
docs: batch context updates at commit boundaries
test(settings): cover persisted output format
feat(settings): add app settings model
build: add faster-whisper helper resources
```

```text
fix(settings): remove main actor isolation from app settings

Context:
- AppSettings tests failed with MainActor isolation errors.
- The settings model stores plain app preferences and does not call UI APIs.

Before:
- AppSettings was MainActor-isolated.
- Tests needed main actor access for simple settings reads and writes.

After:
- AppSettings remains Observable but is no longer MainActor-isolated.
- Settings tests can instantiate and mutate it without UI actor coupling.

Changed:
- Updated AppSettings isolation.
- Adjusted settings tests around the nonisolated model.

Verification:
- make test

Metadata:
- Session: 2026-04-30-app-settings-mainactor
- Agent: Codex
- Model: GPT-5
- Tooling: shell, apply_patch, xcodebuild
```

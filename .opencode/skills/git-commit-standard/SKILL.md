---
name: git-commit-standard
description: Standardize git commit messages for this repo. Use when Codex writes, reviews, edits, or suggests commit messages; when the user asks to commit or push; or when a change set needs a concise commit summary.
---

# Git Commit Standard

Use lightweight Conventional Commits plus a compact structured body for non-trivial work. The goal is that another AI can read the last three commits and understand what changed, why it changed, where it happened, how it was verified, and which session/agent/model/tooling produced it.

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

Use the compact handoff body when a commit:

- changes behavior
- fixes a bug
- adds or changes tests for behavior
- touches multiple subsystems
- creates, removes, or changes a durable interface/model/service
- needs context for a future agent to understand it from commit history alone

## Compact Handoff Body

Use one line per section. Do not use bullets. Do not add blank lines between body sections. Omit `Open` when there is no follow-up.

```text
Context: why this change exists.
Before: previous behavior or structure.
After: new behavior or structure.
Changed: main files, models, services, or workflows affected.
Verification: commands, tests, builds, or checks run.
Open: remaining uncertainty or follow-up, if any.
Metadata: session=<id>; agent=<Codex|Claude|Cursor|Manual|Not recorded>; model=<name|Not recorded>; tooling=<tools>
```

Pack each line aggressively. Prefer semicolons over extra lines. Keep details factual and short. Do not paste raw logs, private content, transcript text, clipboard text, or unrelated implementation detail.

If exact session/model/tool data is unavailable, write `Not recorded`; do not invent metadata.

## Commit Workflow

1. Inspect `git status --short --branch`.
2. Inspect the staged or intended diff before writing the message.
3. Commit only files that belong to the requested change.
4. If unrelated work exists, leave it unstaged and mention it in the final response.
5. For docs/context-only commits, prefer `docs: ...`.
6. For non-trivial commits, include the compact handoff body.

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

Context: AppSettings tests failed with MainActor isolation; settings stores plain preferences and does not call UI APIs.
Before: AppSettings was MainActor-isolated; tests needed main actor access for simple reads and writes.
After: AppSettings remains Observable but is nonisolated; tests can mutate it without UI actor coupling.
Changed: AppSettings isolation and settings tests.
Verification: make test.
Metadata: session=2026-04-30-app-settings-mainactor; agent=Codex; model=GPT-5; tooling=shell, apply_patch, xcodebuild
```

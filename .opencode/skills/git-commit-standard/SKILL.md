---
name: git-commit-standard
description: Standardize git commit messages for this repo. Use when Codex writes, reviews, edits, or suggests commit messages; when the user asks to commit or push; or when a change set needs a concise commit summary.
---

# Git Commit Standard

Use lightweight Conventional Commits plus a short structured body for non-trivial work. The goal is that another AI can read the last three commits and understand the user's request, what changed, the before/after state, and which repo session document plus runtime agent session produced it.

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

Use the handoff body when a commit:

- changes behavior
- fixes a bug
- adds or changes tests for behavior
- touches multiple subsystems
- creates, removes, or changes a durable interface/model/service
- needs context for a future agent to understand it from commit history alone

## Handoff Body

Use bullet lists, but keep spacing tight. Do not add blank lines between body sections. Use as many bullets as the section genuinely needs, and keep them short.

```text
Request:
- User's core request or problem.
Summary:
- Concise description of what changed.
Before:
- Previous behavior or structure.
After:
- New behavior or structure.
Metadata:
- session_doc=<repo session summary path or Not recorded>; agent_session_id=<actual OpenCode/Codex runtime session id or Not recorded>; agent=<OpenCode|Codex|Claude|Cursor|Manual|Not recorded>; model=<name|Not recorded>; tooling=<tools>
```

Keep each bullet short and avoid filler. Do not include `Verification` in the commit body unless the user explicitly asks for it. Do not paste raw logs, private content, transcript text, clipboard text, or unrelated implementation detail.

`agent_session_id` must be the actual OpenCode/Codex runtime session id, not a docs session slug. `session_doc` may be a repo path such as `docs/context/sessions/<id>.md`. If the exact session document, runtime session id, model, or tooling is unavailable, write `Not recorded`; do not invent metadata.

## Commit Workflow

1. Inspect `git status --short --branch`.
2. Inspect the staged or intended diff before writing the message.
3. Commit only files that belong to the requested change.
4. If unrelated work exists, leave it unstaged and mention it in the final response.
5. For docs/context-only commits, prefer `docs: ...`.
6. For non-trivial commits, include the handoff body.

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

Request:
- Fix AppSettings test failures caused by MainActor isolation.
Summary:
- AppSettings remains Observable but no longer requires main actor access for plain settings reads and writes.
Before:
- AppSettings was MainActor-isolated; tests needed main actor access for simple mutations.
After:
- AppSettings is nonisolated; settings tests can instantiate and mutate it without UI actor coupling.
Metadata:
- session_doc=docs/context/sessions/2026-04-30-app-settings-mainactor.md; agent_session_id=Not recorded; agent=Codex; model=GPT-5; tooling=shell, apply_patch, xcodebuild
```

# Session: Project-Native Context Priority

**Date:** 2026-05-10
**Title:** project-native context priority
**ID:** 2026-05-10-project-native-context-priority

## Goal

Clarify how the portable MYB `.opencode` agent system should interact with project-specific context and memory protocols without making MYB Orchestrator Dikte-specific.

## Completed

1. Added general project-native context priority rules to MYB Orchestrator.
2. Added matching implementation-time rules to MYB Implementation Builder.
3. Clarified in Dikte `AGENTS.md` that Dikte project state, tasks, decisions, and handoff memory come from `make context-load` and the committed `docs/` context protocol, not from `.opencode/context`.

## Verification

- `make context-check` passed.
- `git diff --check` passed.

## Follow-ups

- None.

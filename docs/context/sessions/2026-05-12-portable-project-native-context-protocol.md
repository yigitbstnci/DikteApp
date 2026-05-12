# Session: Portable Project-Native Context Protocol

**Date:** 2026-05-12
**Title:** portable project-native context protocol
**ID:** 2026-05-12-portable-project-native-context-protocol

## Goal

Turn Dikte's repo-resident context model into reusable MYB `.opencode` guidance and templates without moving Dikte project state into `.opencode/context`.

## Completed

1. Added a reusable project-native context protocol guide under MYB agent-system context.
2. Added a portable setup template covering parameters, starter docs, index shape, runner mappings, and sentinel checks.
3. Updated root and agent-system navigation so agents can discover the new protocol and template.
4. Updated `/init-project` and `/manage-context` commands/workflows to preserve the authority split between project-native state and reusable MYB context.
5. Updated the system manifest with the new context dependencies.

## Verification

- `make context-check` passed.
- `git diff --check` passed.

## Follow-ups

- Consider extracting reusable starter scripts from Dikte's `scripts/context/` only after the template is used in at least one second project.

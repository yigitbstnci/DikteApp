# Review Fix Context Index Terminal Tests

Date: 2026-04-29

## Goal

Address review findings from the test coverage branch before merge.

## Completed

- Synced `docs/context/index.yml` with `DKT-ADR-0007` and current task IDs/status.
- Added a context summary for the review-fix work.
- Replaced duplicated terminal pending test helpers with production testable helpers.
- Added `context-check` validation so decision and task IDs in docs and index cannot drift silently.
- Strengthened `AGENTS.md` so agents must load context before meaningful work and treat context/index drift as a correctness bug.
- Added `make verify` to run context validation and the Swift test suite together.
- Corrected the completed test coverage count in `docs/tasks.md`.

## Verification

- `make context-check` passes with decision/task index drift validation.
- `make verify` passes.

## Follow-ups

- Keep terminal clipboard behavior tests pointed at production helpers instead of copied logic.

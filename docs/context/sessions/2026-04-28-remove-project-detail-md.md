# Remove Project Detail Markdown

Date: 2026-04-28

## Goal

Remove the root-level `PROJECT_DETAIL.md` file now that the repo-resident context system keeps canonical architecture documentation under `docs/`.

## Completed

- Moved the useful architecture details into `docs/architecture.md`.
- Corrected stale architecture details while moving them, including clipboard polling interval and clipboard asset storage path.
- Updated `README.md` to link to `docs/architecture.md`.
- Added `DKT-ADR-0004` to record the canonical architecture-doc decision.
- Deleted `PROJECT_DETAIL.md`.

## Verification

- `make context-check` passes.
- `README.md` no longer links to `PROJECT_DETAIL.md`.
- Remaining `PROJECT_DETAIL.md` mentions are historical notes explaining the deletion decision.

## Follow-ups

- Keep future architecture updates in `docs/architecture.md`.

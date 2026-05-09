# Workflow: Check Context Dependencies

## Purpose

Detect broken, missing, unused, or inconsistent dependencies.

## Checks

1. Scan agents and commands for dependency declarations.
2. Verify referenced context/workflow/agent files exist.
3. Compare registry entries with filesystem paths.
4. Identify orphaned context files.
5. Verify navigation references important context.
6. Report issues with severity.

## Rule

Report only by default. Any fix requires a proposed plan and approval.

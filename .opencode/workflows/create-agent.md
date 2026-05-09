# Workflow: Create Agent

## Purpose

Create a new specialist only when the system needs a durable capability.

## Steps

1. Capture requested capability.
2. Run agent necessity check.
3. Identify role, boundaries, inputs, outputs, and workflows.
4. Run context intake.
5. Propose agent file, context files, command/workflow changes, and registry updates.
6. Ask approval before generation.
7. Generate approved files.
8. Recommend `/check-context-deps`.

## Stop Conditions

- User cannot define reusable need.
- Existing orchestrator or workflow is enough.
- Required context is missing and user chooses to stop.

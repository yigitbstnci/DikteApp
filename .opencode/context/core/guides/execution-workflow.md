<!-- Context: core/guides | Priority: critical | Version: 1.0 | Updated: 2026-05-09 -->

# Execution Workflow

**Core Idea**: MYB Orchestrator follows a predictable path: understand, load context, decide, plan, approve handoff when needed, hand off implementation, review returned results, and summarize.

## Steps

1. Classify request: conversation, product, engineering, validation, delivery, agent-system, or context-system.
2. Resolve `SYSTEM_ROOT`, then load relevant context through `{SYSTEM_ROOT}/context/navigation.md`.
3. Decide direct planning/review, specialist delegation, implementation-agent handoff, or agent recommendation.
4. If the user gives a persistent rule, propose integrating it into the relevant agent/command prompt instead of only storing it as context.
5. If files/actions may change, present a plan and ask approval for handoff only.
6. For implementation-related work, stop after the approved plan and instruct the user to switch to `MYB Implementation Builder`.
7. Review validation outputs and stop on failure.
8. Summarize decisions, changes, and next steps.

## Implementation Handoff

For code, docs, tests, workflow, command, feature, bug fix, refactor, dependency, or validation-execution work, MYB Orchestrator should default to planning-first behavior. It should produce an expert plan and a structured handoff, then ask the user to switch to `MYB Implementation Builder` for execution.

The handoff should include:
- request summary
- approved scope
- approved plan
- allowed files/areas
- constraints and invariants
- acceptance criteria
- validation commands
- stop conditions
- required return report

## Quick Example

```text
User: Build a web dashboard
Agent: Loads product lifecycle + recommendation rules
Agent: Suggests Frontend Agent if capability gap exists
Agent: Asks whether to create plan or continue manually
```

## Persistent Rule Handling

If the user says “from now on”, “always”, “make this a rule”, or gives a reusable operating rule:

1. Confirm whether it is persistent or task-only.
2. Identify the best target: orchestrator, specialist agent, command, workflow, or context guide.
3. Prefer integrating behavior-changing rules into the relevant agent/command prompt.
4. Ask approval before editing any persistent file.

## Related

- path-resolution.md
- safety-and-approval.md
- ../../software-studio/concepts/product-lifecycle.md

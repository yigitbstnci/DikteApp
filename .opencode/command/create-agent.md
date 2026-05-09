---
description: Create a new specialist agent through interview, context intake, preview, and approval
dependencies:
  - agent:agent-system-designer
  - workflow:create-agent
  - context:agent-system/guides/create-agent
  - context:agent-system/guides/context-intake-rules
---

# /create-agent

**Purpose**: Safely add a new specialist agent only when the system needs a durable capability.

**Arguments**: `$ARGUMENTS`

## Usage

```text
/create-agent frontend-agent
/create-agent "agent for SaaS product research"
```

## Workflow

1. Parse `$ARGUMENTS` for agent name, domain, or capability.
2. If unclear, ask what specialist capability the user wants.
3. Run agent necessity check.
4. Run context intake interview.
5. Route architecture decisions to `agent-system-designer`.
6. Propose files, dependencies, responsibilities, and registry changes.
7. Ask approval before writing.
8. Recommend `/check-context-deps` after creation.

## Necessity Questions

Ask these before creating the agent:

1. What repeated capability should this agent own?
2. What should this agent explicitly not do?
3. Which product/workflow phases will use it?
4. What quality criteria are unique to this role?
5. Could this be solved by context or workflow instead?

## Context Intake Questions

Ask based on domain:

| Domain | Questions |
|---|---|
| Frontend | Framework, UI library, styling, component pattern, accessibility level |
| Backend | API style, database, auth, integrations, error handling |
| Product | User persona, problem space, success metrics, roadmap style |
| QA/Test | Test framework, coverage expectations, risk areas, validation gates |
| DevOps | Hosting, CI/CD, secrets, environments, rollback strategy |
| Data | Sources, schema, metrics, privacy, reporting format |

## Intake Options

```text
Context is missing. How should we proceed?
A) Ask me the intake questions now
B) Extract context from existing files
C) Create minimum draft and refine later
D) Cancel
```

## Output

```text
Recommended Agent: <name>
Why Needed: <reason>
Context Required: <list>
Files Proposed: <list>
Proceed? A) Create B) Revise C) Cancel
```

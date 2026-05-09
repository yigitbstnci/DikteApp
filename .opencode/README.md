# MYB Software Studio Agent System

Independent context-aware agent system for managing software products from idea to delivery.

## Purpose

This system is designed as a small but expandable software studio operating system. It starts with one universal orchestrator and one specialist agent for growing the system safely.

## Core Components

- `agent/myb-Orchestrator.md` — main universal orchestrator inspired by OpenAgent patterns.
- `agent/subagents/agent-system-designer.md` — specialist for agent, context, command, and dependency design.
- `command/create-agent.md` — create new agents through interview, context intake, preview, and approval.
- `command/init-project.md` — onboard the system into existing or fresh projects.
- `command/update-agent.md` — update existing agents using user requests plus structural analysis.
- `command/manage-context.md` — create, update, map, and organize context files.
- `command/check-context-deps.md` — validate agent/command/context/workflow dependency health.

## Operating Principles

1. Keep the core simple.
2. Add agents only when a real capability gap exists.
3. Create context before expecting specialist behavior.
4. Preview changes before writing.
5. Validate dependencies after create/update operations.

## Recommended First Flow

```text
Ask MYB Orchestrator for a product task
→ It classifies the request
→ It loads relevant context
→ It executes or recommends a specialist
→ If a new agent is needed, use /create-agent
→ After changes, run /check-context-deps
```

## Using Another Runtime

Use this folder as a portable system package:

1. Copy `agent/`, `command/`, `context/`, `workflows/`, and `system-manifest.json` into the target runtime.
2. Define `SYSTEM_ROOT` as the folder containing `system-manifest.json`.
3. Map the target runtime's agent/command discovery paths to these folders.
4. If the target project already has `AGENTS.md`, do not overwrite it; merge the MYB integration block from `AGENTS_TEMPLATE.md`.
5. Keep `system-manifest.json` as the system index for dependency checks.
6. Run `/init-project` to analyze or initialize the target project.
7. Run or manually apply `/check-context-deps` after moving.
8. If the runtime has stricter frontmatter rules, move unsupported metadata into `system-manifest.json`.

## Project Initialization

Use `/init-project` after moving the system into a project:

- Existing project: analyzes files, docs, configs, commands, and existing `AGENTS.md`; then proposes a safe merge.
- Fresh project: asks start questions and creates a base project `AGENTS.md` after approval.
- Dry run: reports findings and proposed setup without writing.

## Path Resolution

`SYSTEM_ROOT` is the folder that contains `system-manifest.json`.

Use this pattern when adapting the system:

```text
{SYSTEM_ROOT}/context/navigation.md
{SYSTEM_ROOT}/agent/myb-Orchestrator.md
{SYSTEM_ROOT}/command/create-agent.md
{SYSTEM_ROOT}/workflows/create-agent.md
```

If an agent cannot find `navigation.md`, verify `SYSTEM_ROOT` first.

## System Manifest

`system-manifest.json` is not an OpenCode runtime config. It is this portable system's inventory and dependency map.

It lists:

- agents
- commands
- context files
- workflows
- dependency relationships

Use it to validate the system, move it into another runtime, or adapt it into that runtime's native config format.

## V1.1 Notes

- `/create-agent` owns the user interview and context intake flow.
- `agent-system-designer` owns architecture quality and dependency hygiene.
- MYB Orchestrator owns routing, safety gates, and capability-gap detection.
- Dependency references use `type:path`, e.g. `context:root/navigation`.

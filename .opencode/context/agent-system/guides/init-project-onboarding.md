<!-- Context: agent-system/guides | Priority: critical | Version: 1.0 | Updated: 2026-05-09 -->

# Init Project Onboarding

**Core Idea**: `/init-project` teaches the system a project before real work begins. It supports both existing project onboarding and fresh project initialization.

## Key Rules

- Analyze read-only first; write only after approval.
- Never overwrite an existing `AGENTS.md`.
- Existing project rules have higher priority than MYB template guidance.
- Use `SYSTEM_ROOT` for MYB system paths.
- Report confidence and missing information instead of guessing.
- Default user-facing output should be Turkish unless the user requests another language.
- Include a short project understanding summary after reading project docs.

## Existing Project Output

```text
Tespit Edilen Mod: Existing Project
Kanıtlar: package.json, README, AGENTS.md
SYSTEM_ROOT: ./.opencode

Proje Anlama Özeti:
- Ne yapıyor: ...
- Nasıl çalışıyor: ...
- Komutlar: ...
- Kurallar: ...

Confidence: stack=high, tests=medium, deploy=unknown
Missing Information: deploy flow, roadmap
Next: AGENTS block merge + optional project context
```

## Required Existing Project Sections

- Tespit Edilen Mod
- Kanıtlar
- Tespit Edilen SYSTEM_ROOT
- Proje Anlama Özeti
- Confidence
- Missing Information
- Önerilen AGENTS Integration Block
- Önerilen Kurulum
- Specialist Agent Kararı
- Seçenekler

## Specialist Decision

If no specialist agent is recommended, explain why:

```text
Yeni specialist agent önerilmiyor çünkü:
- Mevcut docs/context yeterince güçlü.
- Tekrarlayan uzman iş yükü henüz net değil.
- MYB Orchestrator şimdilik işi yönetebilir.
```

## Fresh Project Output

```text
Mode: Fresh Project
Ask: purpose, users, stack, MVP, privacy, deployment
Next: create base AGENTS.md + project context
```

## Related

- ../../core/guides/path-resolution.md
- create-agent.md
- manage-context.md

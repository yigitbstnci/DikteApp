---
description: Initialize MYB Software Studio in an existing or fresh project
dependencies:
  - workflow:init-project
  - context:agent-system/guides/init-project-onboarding
  - context:agent-system/guides/project-native-context-protocol
  - context:agent-system/lookup/project-native-context-template
  - context:core/guides/path-resolution
---

# /init-project

**Purpose**: Onboard the MYB Software Studio system into a project safely.

**Arguments**: `$ARGUMENTS`

## Usage

```text
/init-project
/init-project --existing
/init-project --fresh
/init-project --dry-run
```

## Modes

| Mode | Use When |
|---|---|
| `--existing` | Project already has files, docs, configs, or AGENTS.md |
| `--fresh` | New project with no meaningful structure yet |
| `--dry-run` | Analyze and preview only; do not write |

## Workflow

1. Resolve `SYSTEM_ROOT`.
2. Detect project mode: existing, fresh, or unclear.
3. Analyze read-only first: files, docs, configs, commands, existing `AGENTS.md`.
4. Read available docs enough to summarize how the project works and which rules it contains.
5. Report findings in Turkish with confidence scores and missing information.
6. Ask approval before writing.
7. For existing projects, merge the MYB block from `AGENTS_TEMPLATE.md`; never overwrite existing `AGENTS.md`.
8. For fresh projects, ask start questions and create a base project `AGENTS.md`.
9. If no project-native context protocol exists, recommend the portable protocol and preview the template before writing.
10. Create/update project context only after approval.

## Output Language

Default output language is Turkish. Keep technical identifiers, commands, file paths, and dependency references unchanged.

## Start Questions For Fresh Projects

1. Project name and purpose?
2. Target users?
3. Product type: web, backend, mobile, data, agentic, docs/business?
4. Preferred tech stack, if known?
5. UI/content language?
6. MVP scope and non-goals?
7. Security/privacy sensitivity?
8. Deployment target, if known?
9. Success criteria?

## Existing Project Report Format

```text
Tespit Edilen Mod: Existing Project

Kanıtlar:
- package/config/docs bulundu
- AGENTS.md: var/yok

Tespit Edilen SYSTEM_ROOT:
- SYSTEM_ROOT: ./newsystem veya ./.opencode
- Manifest: {SYSTEM_ROOT}/system-manifest.json
- Context navigation: {SYSTEM_ROOT}/context/navigation.md

Proje Anlama Özeti:
- Proje ne yapıyor: ...
- Nasıl çalışıyor: ...
- Önemli komutlar: ...
- Ana kurallar: ...
- Privacy/safety notları: ...

Confidence:
- Tech stack: high|medium|low|unknown
- Test command: high|medium|low|unknown
- Deploy process: high|medium|low|unknown

Missing Information:
1. ...

Önerilen AGENTS Integration Block:
```md
## MYB Software Studio Integration

- SYSTEM_ROOT: ./.opencode
- Primary agent: ./.opencode/agents/myb-Orchestrator.md
- Context navigation: ./.opencode/context/navigation.md
- System manifest: ./.opencode/system-manifest.json

Project AGENTS.md rules remain higher priority.
```

Önerilen Kurulum:
- AGENTS integration block merge et
- Gerekirse project-native context protocol oluştur/güncelle
- Gerekirse specialist agent öner

Specialist Agent Kararı:
- Şimdilik yeni agent önerilmiyor/öneriliyor
- Neden: ...

Project-Native Context Kararı:
- Mevcut protokol: var/yok
- Öneri: ...

Seçenekler:
A) Sadece AGENTS integration block ekle
B) AGENTS block + project-native context protocol oluştur
C) Hiçbir değişiklik yapma
```

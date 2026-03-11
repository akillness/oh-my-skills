# bmad-orchestrator — Claude Code Harness

> **bmad-orchestrator** is a structured AI-driven development harness for Claude Code. It routes work across four phases — Analysis → Planning → Solutioning → Implementation — keeping your project on track from idea to shipped code.

[![GitHub Releases](https://img.shields.io/badge/GitHub-Releases-blue)](https://github.com/supercent-io/skills-template/releases)
[![Release Notes](https://img.shields.io/badge/release-notes-blue)](https://github.com/supercent-io/skills-template/releases)
[![BMAD Deploy Version](https://img.shields.io/badge/BMAD-1.0.0-brightgreen)](../../.agent-skills/bmad-orchestrator/SKILL.md)

![Agent Skills Installer](../../AgentSkills.png)

---

## What is BMAD?

BMAD (Business-Method-Agile-Development) is a phase-based workflow that brings discipline to AI-assisted development. Instead of jumping straight to code, BMAD guides you through structured phases so nothing is missed.

```
Phase 1: Analysis       → Understand the problem space
Phase 2: Planning       → Define requirements & tech specs  
Phase 3: Solutioning    → Design the architecture
Phase 4: Implementation → Build, test, ship
```

---

## Quick Start (3 Commands)

Deploy target: use GitHub Releases for stable rollout tracking, then run the commands below.

**Step 1: Install the skill**

```bash
npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator
```

**Step 2: Activate in Claude Code**

```text
bmad 스킬을 설정하고 사용해줘. 기억해.
```

**Step 3: Initialize your project**

```text
/workflow-init
```

That's it. BMAD will ask you about your project, pick the right level, and guide you through the appropriate phases.

## Codex 사용성

`bmad-orchestrator`는 기본적으로 Claude Code에서 안정적으로 동작하는 설계입니다.  
Codex에서 동일한 `bmad` 명령을 그대로 쓰려면 `omx`/`ohmg` 같은 상위 오케스트레이션 계층을 함께 사용해야 합니다.

권장 흐름:

```text
1) Codex: /prompts: architect/executor/... (or omx mode)
2) 필요한 단계별 산출물 생성 -> Codex가 파일만 제안
3) Claude-based BMAD 프레임으로 최종 검증
```

## 플랫폼 적용 체크

| 플랫폼 | 현재 지원 상태 | 운영 방법 |
|---|---|---|
| Gemini CLI | 직접 지원 | `bmad` 명령어 기반 |
| Claude Code | 직접 지원 | 스킬 설치 + `기억해` |
| OpenCode | 오케스트레이션 연동 | `omx`/`ohmg`류 브릿지 |
| Codex | 오케스트레이션 연동 | `omx`/`ohmg`류 브릿지 |

### 현재 스킬만으로 가능한가

- Gemini CLI/Claude Code: **가능**
- OpenCode/Codex: **가능(오케스트레이션 경유)**

---

## Detailed Documentation

| Document | Description |
|----------|-------------|
| [Installation & Setup](./installation.md) | Full install guide, skill activation, `기억해` pattern |
| [Workflow Guide](./workflow.md) | All 4 phases, commands, project levels (0–4) |
| [Configuration Reference](./configuration.md) | Config files, status tracking, variable substitution |
| [Practical Examples](./examples.md) | Real workflows for bug fix → enterprise project |

---

## Phase Overview

| Phase | Purpose | Required? |
|-------|---------|-----------|
| **1: Analysis** | Market research, product vision, brainstorming | Optional (recommended for Level 2+) |
| **2: Planning** | PRD or Tech Spec — defines what to build | **Always required** |
| **3: Solutioning** | Architecture design | Required for Level 2+ |
| **4: Implementation** | Sprint planning, stories, dev, code review | **Always required** |

---

## Project Levels

BMAD automatically adapts to your project scope:

| Level | Size | Examples | Duration |
|-------|------|---------|----------|
| 0 | Single change | Bug fix, config tweak | Hours |
| 1 | Small feature | New API endpoint, profile page | 1–5 days |
| 2 | Feature set | Auth system, payment flow | 1–3 weeks |
| 3 | Integration | Multi-tenant, analytics platform | 3–8 weeks |
| 4 | Enterprise | Platform migration, major overhaul | 2+ months |

---

## Key Commands

```text
/workflow-init      # Initialize BMAD in current project
/workflow-status    # Check current phase and progress
/product-brief      # Phase 1: Create product vision
/prd                # Phase 2: Product Requirements Document
/tech-spec          # Phase 2: Technical Specification
/architecture       # Phase 3: System architecture design
/sprint-planning    # Phase 4: Break into sprints & stories
/dev-story          # Phase 4: Implement a specific story
```

---

## With Other Harnesses

bmad works alongside other harnesses. Activate with `기억해` to persist the config:

```text
bmad 스킬을 설정하고 사용해줘. 기억해.   # Claude Code
omx 스킬을 설정하고 사용해줘. 기억해.    # Codex CLI
ohmg 스킬을 설정하고 사용해줘. 기억해.   # Gemini-CLI
```

---

## plannotator Integration

Review each phase's key deliverable with **plannotator** before transitioning to the next phase. Approved documents auto-save to your enabled destination (Obsidian or Bear).

### Phase Gate Workflow

```
Phase document created (PRD, Architecture, etc.)
       ↓
bash scripts/phase-gate-review.sh <doc-file> "<title>"
       ↓
plannotator UI opens → Annotate → Approve or Request Changes
       ↓
[Approved] → Saved (Obsidian/Bear) + proceed to next phase
[Changes]  → Agent revises → re-review
```

### Usage

```bash
# Review PRD before moving to Solutioning (Phase 3)
bash scripts/phase-gate-review.sh docs/prd-myapp-2026-02-22.md "PRD Review: myapp"

# Review Architecture before starting Implementation (Phase 4)
bash scripts/phase-gate-review.sh docs/architecture-myapp-2026-02-22.md "Architecture Review: myapp"
```

Or trigger from within your AI session after any phase document is created:

```text
plan — review the PRD before we proceed to Phase 3
```

### Save Destination (Obsidian or Bear)

Approved plans are saved with BMAD-specific tags:

```yaml
tags: [bmad, phase-2, prd, myapp]
```

Set the destination in plannotator UI (Settings → Saving):
- Obsidian Integration
- Bear Notes

See [plannotator docs](../plannotator/README.md) for setup and callback troubleshooting.

---

→ [Back to skills-template README](../../README.md)

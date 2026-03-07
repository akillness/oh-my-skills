# Agent Skills

> 🌐 Language / 언어: **[English](README.md)** | **한국어**

> v2026-03-08 · **71 Skills** · **TOON Format** · **Flat Skill Layout**

[![GitHub Releases](https://img.shields.io/badge/GitHub-Releases-blue)](https://github.com/akillness/skills-template/releases)
[![Skills](https://img.shields.io/badge/Skills-71-brightgreen)](#skills-list-71-total)
[![BMAD Deploy Version](https://img.shields.io/badge/BMAD-1.0.0-orange)](docs/bmad/README.md)

> 스킬 구성 및 상세 목록: [.agent-skills/README.md](.agent-skills/README.md)

---

## Contents

- [Quick Start](#quick-start)
- [What's New](#whats-new-in-v2026-03-08)
- [설치 (Install)](#설치-install)
- [실행 가이드](#실행-가이드)
- [Skills List (71)](#skills-list-71-total)
- [Featured Tools](#featured-tools)
- [TOON Format Injection](#toon-format-injection)
- [Structure](#structure)
- [Related docs](#related-docs)
- [Changelog](#changelog)

---

## Quick Start (For LLM Agents)

> **사전 준비**: `npx skills add` 명령을 실행하려면 먼저 `skills` CLI가 필요합니다.
>
> ```bash
> npm install -g skills
> ```

```bash
# LLM에게 전달: 아래 가이드를 읽고 설치를 진행하세요
curl -s https://raw.githubusercontent.com/akillness/skills-template/main/setup-all-skills-prompt.md
```

> 더 많은 스킬 설치 → [설치](#설치-install) | 플랫폼별 상세 실행 → [실행 가이드](#실행-가이드)

---

## What's New in v2026-03-08

| 변경 | 내용 |
|------|------|
| **jeo: plannotator Claude Code 동작 방식 수정 (P0)** | `plannotator`는 hook-only 바이너리 — MCP 툴이나 CLI 직접 호출 시 항상 실패. `jeo/SKILL.md`에서 존재하지 않는 `submit_plan` MCP 툴 호출 지시 제거. `EnterPlanMode` → plan 작성 → `ExitPlanMode` 훅 방식으로 교체. pre-flight bash 블록에 Claude Code 스킵 주석 추가 (Codex/Gemini/OpenCode 전용 명시). `bmad-orchestrator/SKILL.md` Claude Code vs OpenCode 호출 방식 명확화. 트러블슈팅 항목 추가 |
| **jeo: Gemini CLI plannotator 피드백 대기 수정** | Gemini CLI AfterAgent 훅에 `timeout: 1800` (30분) 추가하여 plannotator 브라우저 UI가 사용자 승인/피드백까지 대기. `matcher`/`hooks` 래퍼 없는 구형 훅 자동 마이그레이션. Gemini 설정에서 무효한 `PermissionRequest.ExitPlanMode` (Claude Code 전용 이벤트) 제거 |
| **jeo: Claude Code 훅 포맷 오류 수정** | `UserPromptSubmit` 훅을 새 matcher 포맷(`{"matcher": "*", "hooks": [...]}`)으로 변환. `setup-claude.sh` 재실행 시 구형 포맷 자동 마이그레이션하여 `hooks: Expected array, but received undefined` 오류 방지 |

> 이전 변경 내역: [Changelog](#changelog)

---

## 설치 (Install)

### 0단계: `skills` CLI 설치

모든 `npx skills add` 명령은 `skills` CLI가 필요합니다. 먼저 설치하세요:

```bash
npm install -g skills
```

설치 확인:

```bash
skills --version
```

---

### LLM 에이전트용 (For LLM Agents)

LLM 에이전트가 설치를 도울 경우, 다음 단계를 따르세요.

```bash
# LLM에게 전달: 아래 가이드를 읽고 설치를 진행하세요
curl -s https://raw.githubusercontent.com/akillness/skills-template/main/setup-all-skills-prompt.md
```

---

## 실행 가이드

### jeo만으로 시작하기 (권장)

`jeo`는 아래 전체 워크플로우를 자동으로 연결합니다:

| 단계 | 도구 | 역할 |
|------|------|------|
| 계획 | ralph + plannotator | AI가 계획을 세우고, 당신이 승인/피드백 |
| 실행 | omc team / bmad | 병렬 에이전트가 코드를 작성 |
| 검증 | agent-browser | 브라우저 동작 검증 (기본) |
| 정리 | worktree-cleanup | 완료 후 자동 정리 |

```bash
# Claude Code에서 실행
jeo "원하는 작업을 여기에 설명하세요"
```

---

### 원하는 기능에 따라 선택하기

#### Claude Code 멀티에이전트 조율 → `omc`

```bash
npx skills add https://github.com/akillness/skills-template --skill omc
# 사용: /omc:team "작업 내용"
```

> 상세: [docs/omc/README.md](docs/omc/README.md)

#### OpenAI Codex CLI 멀티에이전트 → `oh-my-codex` (omx)

```bash
npx skills add https://github.com/akillness/skills-template --skill oh-my-codex
```

> 상세: [.agent-skills/oh-my-codex/SKILL.md](.agent-skills/oh-my-codex/SKILL.md)

#### Gemini / Antigravity 워크플로우 → `ohmg`

```bash
npx skills add https://github.com/akillness/skills-template --skill ohmg
```

> 상세: [.agent-skills/ohmg/SKILL.md](.agent-skills/ohmg/SKILL.md)

#### 단계별 구조화 개발 (분석→계획→설계→구현) → `bmad-orchestrator`

```bash
npx skills add https://github.com/akillness/skills-template --skill bmad-orchestrator
# 사용: bmad 스킬을 설정하고 사용해줘. /workflow-init
```

> 상세: [docs/bmad/README.md](docs/bmad/README.md)

#### 작업이 완료될 때까지 반복 실행 → `ralph`

```bash
npx skills add https://github.com/akillness/skills-template --skill ralph
# 사용: /ralph "모든 TypeScript 오류 수정" --max-iterations=100
```

> 상세: [docs/ralph/README.md](docs/ralph/README.md)

#### Ralph 자동화 권한 프로파일 → `ralphmode`

```bash
npx skills add https://github.com/akillness/skills-template --skill ralphmode
# 사용: Claude Code / Codex CLI / Gemini CLI에서 ralph 자동화용 permission profile 적용
```

> 상세: [.agent-skills/ralphmode/SKILL.md](.agent-skills/ralphmode/SKILL.md)

#### 계획 시각 검토 + Feedback loop → `plannotator`

```bash
npx skills add https://github.com/akillness/skills-template --skill plannotator
# 사용: 계획을 세울 때 자동으로 브라우저 UI 오픈 → Approve 또는 피드백 전송
```

> 상세: [docs/plannotator/README.md](docs/plannotator/README.md)

#### 브라우저 자동화 (헤드리스) → `agent-browser`

```bash
npx skills add https://github.com/akillness/skills-template --skill agent-browser
```

> 상세: [.agent-skills/agent-browser/SKILL.md](.agent-skills/agent-browser/SKILL.md)

#### Playwright 기반 브라우저 제어 → `playwriter`

```bash
npx skills add https://github.com/akillness/skills-template --skill playwriter
```

> 상세: [.agent-skills/playwriter/SKILL.md](.agent-skills/playwriter/SKILL.md)

---

## Skills List (71 total)

> Full manifest + descriptions: `.agent-skills/skills.json` · each folder's `SKILL.md`

### Agent Development (7)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `agent-configuration` | AI agent configuration & security policies | All platforms |
| `agent-evaluation` | AI agent evaluation systems | All platforms |
| `agentic-development-principles` | Universal agentic development principles | All platforms |
| `agentic-principles` | Core AI agent collaboration principles | All platforms |
| `agentic-workflow` | Practical AI agent workflows & productivity | All platforms |
| `bmad-orchestrator` | BMAD workflow orchestration *(in development)* | Claude |
| `prompt-repetition` | Prompt repetition for LLM accuracy | All platforms |

### Backend (5)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `api-design` | REST/GraphQL API design | All platforms |
| `api-documentation` | API documentation generation | All platforms |
| `authentication-setup` | Authentication & authorization setup | All platforms |
| `backend-testing` | Backend testing strategies | All platforms |
| `database-schema-design` | Database schema design | All platforms |

### Frontend (7)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `design-system` | Design system implementation *(in development)* | All platforms |
| `react-best-practices` | React & Next.js best practices | All platforms |
| `responsive-design` | Responsive web design | All platforms |
| `state-management` | State management patterns | All platforms |
| `ui-component-patterns` | UI component patterns | All platforms |
| `web-accessibility` | Web accessibility (a11y) | All platforms |
| `web-design-guidelines` | Web design guidelines | All platforms |

### Code Quality (5)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `code-refactoring` | Code refactoring strategies | All platforms |
| `code-review` | Code review practices | All platforms |
| `debugging` | Systematic debugging | All platforms |
| `performance-optimization` | Performance optimization | All platforms |
| `testing-strategies` | Testing strategies | All platforms |

### Infrastructure (10)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `ai-tool-compliance` | 내부 AI 툴 P0/P1 컴플라이언스 자동 검증 — 4도메인 이진 점수(보안/권한/비용/로그), 배포 게이트, 이력 추적 | All platforms |
| `deployment-automation` | CI/CD & deployment automation | All platforms |
| `firebase-ai-logic` | Firebase AI Logic integration | Claude · Gemini |
| `genkit` | Firebase Genkit AI workflows | Claude · Gemini |
| `looker-studio-bigquery` | Looker Studio + BigQuery | All platforms |
| `monitoring-observability` | Monitoring & observability | All platforms |
| `security-best-practices` | Security best practices | All platforms |
| `system-environment-setup` | Environment configuration | All platforms |
| `vercel-deploy` | Vercel deployment | All platforms |
| `llm-monitoring-dashboard` | LLM 사용 모니터링 대시보드 (Tokuin CLI 기반 비용·토큰·레이턴시 추적 + PM 인사이트 + 사용자 랭킹) | All platforms |

### Documentation (4)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `changelog-maintenance` | Changelog management | All platforms |
| `presentation-builder` | Presentation builder *(in development)* | All platforms |
| `technical-writing` | Technical documentation | All platforms |
| `user-guide-writing` | User guides & tutorials | All platforms |

### Project Management (4)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `sprint-retrospective` | Sprint retrospective facilitation | All platforms |
| `standup-meeting` | Daily standup management | All platforms |
| `task-estimation` | Task estimation techniques | All platforms |
| `task-planning` | Task planning & organization | All platforms |

### Search & Analysis (4)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `codebase-search` | Codebase search & navigation | All platforms |
| `data-analysis` | Data analysis & insights | All platforms |
| `log-analysis` | Log analysis & debugging | All platforms |
| `pattern-detection` | Pattern detection | All platforms |

### Creative Media (3)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `image-generation` | AI image generation *(in development)* | Claude · Gemini |
| `pollinations-ai` | Free image generation via Pollinations.ai *(in development)* | All platforms |
| `video-production` | Video production workflows *(in development)* | All platforms |

### Marketing (1)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `marketing-automation` | Marketing automation *(in development)* | All platforms |

### Utilities (20)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `agent-browser` | Fast headless browser CLI for AI agents | All platforms |
| `agentation` | Visual UI annotation tool — `npx skills add benjitaylor/agentation` → `/agentation` (Claude Code Official Skill) · `npx add-mcp` (9+ 에이전트 자동 감지) · Local-first 디자인(오프라인 동작·세션 연속성) | Claude · Gemini · Codex · Cursor · Windsurf · OpenCode |
| `bmad-gds` | BMAD Game Development Studio — Pre-production through production with 6 specialized agents (Unity · Unreal · Godot) | Claude · Gemini · Codex · OpenCode |
| `bmad-idea` | BMAD Creative Intelligence Suite — brainstorming, design thinking, innovation strategy, problem-solving, storytelling | Claude · Gemini · Codex · OpenCode |
| `copilot-coding-agent` | GitHub Copilot Coding Agent — Issue → Draft PR automation | Claude · Codex |
| `environment-setup` | Environment setup | All platforms |
| `file-organization` | File & folder organization | All platforms |
| `git-submodule` | Git submodule management | All platforms |
| `git-workflow` | Git workflow management | All platforms |
| `jeo` | Integrated AI orchestration: ralph+plannotator → team/bmad → agent-browser verify → agentation(annotate) UI피드백 → worktree cleanup | Claude · Codex · Gemini · OpenCode |
| `npm-git-install` | Install npm from GitHub | All platforms |
| `ohmg` | Multi-agent orchestration for Antigravity workflows | Claude · Gemini |
| `oh-my-codex` | Multi-agent orchestration for OpenAI Codex CLI *(in development)* | Codex |
| `omc` | oh-my-claudecode — Teams-first multi-agent orchestration | Claude |
| `opencontext` | AI agent persistent memory | All platforms |
| `plannotator` | Visual plan and diff review — annotate, approve, or request changes | Claude |
| `ralph` | Self-referential completion loop for multi-turn agents | Claude |
| `ralphmode` | Cross-platform Ralph automation permission profiles for Claude Code, Codex CLI, and Gemini CLI | Claude · Codex · Gemini |
| `skill-standardization` | SKILL.md standardization | All platforms |
| `vibe-kanban` | Kanban board for AI coding agents with git worktree automation | All platforms |
| `workflow-automation` | Workflow automation | All platforms |

---

## Featured Tools

These tools have full documentation in `docs/` and dedicated skills in `.agent-skills/`.

### plannotator — Interactive Plan & Diff Review
> **용도**: 실행 전 계획 시각 검토 및 피드백 루프 | **플랫폼**: Claude · Codex · Gemini · OpenCode | **상태**: v0.9.0
> Keyword: `plan`, `계획` (alias: `planno`) | [Docs](docs/plannotator/README.md) | [GitHub](https://github.com/backnotprop/plannotator)

Visual browser UI for annotating AI agent plans before coding. Works with **Claude Code**, **OpenCode**, **Gemini CLI**, and **Codex CLI**. Approve plans or send structured feedback in one click.

Validated in-session with Playwright: Approve + feedback loops confirmed across all four platforms. See `docs/plannotator/README.md` for the verified python3 stdin pattern (avoid raw `echo`/heredoc for plan submission).

```bash
bash scripts/install.sh --all   # Install + configure all AI tools at once
```

Path resolution behavior for skill loading:
- Absolute skill paths are used directly (for example, `/Users/me/.agent-skills/plannotator`)
- Relative skill paths are resolved in this order: configured skills directory -> global `~/.agent-skills`

| Feature | Description |
|---------|-------------|
| Plan Review | Opens browser UI when agent exits plan mode — annotate, approve, or send feedback |
| Diff Review | `/plannotator-review` for inline line annotations on git diffs |
| **Obsidian Integration** | Auto-save approved plans to Obsidian vault with YAML frontmatter, tags, and backlinks |
| Bear Notes | Alternative auto-save to Bear Notes (macOS) |
| Share | Share plan review sessions with teammates via link |

#### Obsidian Setup (3 steps)
1. Install Obsidian → https://obsidian.md/download
2. Create/open a vault in Obsidian
3. In plannotator UI: Settings (⚙️) → Saving → Enable "Obsidian Integration" → Select vault

> **Note**: Configure settings in the **system browser** that plannotator auto-opens. Settings configured in automated/Playwright browser sessions are isolated and will not persist. See [Pattern 9: Obsidian Integration Setup](.agent-skills/plannotator/SKILL.md#pattern-9-obsidian-integration-setup) for detailed instructions and folder organization.

#### Obsidian Folder Organization
Plans can be organized into subfolders within the vault:
```
vault/plannotator/
├── approved/    ← approved plans
├── denied/      ← rejected plans
└── 2026-02/     ← monthly archive
```

#### Bear Quick Check (macOS)
```bash
open "bear://x-callback-url/create?title=Plannotator%20Check&text=Bear%20callback%20OK"
```

#### Known Issues

| 증상 | 원인 | 해결 |
|------|------|------|
| 브라우저가 두 번 열림 | `plannotator-launch.sh`의 중복 `open` 호출 | 훅 스크립트에서 포트 감지 루프의 `open` 제거 — plannotator가 브라우저를 자체 오픈 |
| 피드백 미수신 (Codex/Gemini/OpenCode) | `&` 백그라운드 실행으로 에이전트가 결과를 대기하지 않음 | `&` 없이 블로킹 실행 후 `/tmp/plannotator_feedback.txt` 읽기 |
| Codex 시작 실패 (`invalid type: map, expected a string`) | `~/.codex/config.toml`에서 `developer_instructions`를 테이블(`[developer_instructions]`)로 잘못 선언 | `bash .agent-skills/jeo/scripts/setup-codex.sh` 재실행 후 `developer_instructions = "..."` top-level 문자열 형식 확인 |

---

### vibe-kanban — AI Agent Kanban Board
> **용도**: 병렬 에이전트 진행 상황 시각적 추적 | **플랫폼**: All | **상태**: stable
> Keyword: `kanbanview` | [Docs](docs/vibe-kanban/README.md) | [GitHub](https://github.com/BloopAI/vibe-kanban)

Visual Kanban board (To Do → In Progress → Review → Done) with parallel AI agents (Claude, Codex, OpenCode, Gemini) isolated per card via git worktrees. Auto-creates PRs on completion.

Codex integration is supported via `pluggable` MCP/tooling setup (see `docs/vibe-kanban/README.md`).

```bash
npx vibe-kanban          # Launch board at http://localhost:3000
```

| Feature | Description |
|---------|-------------|
| Parallel agents | Multiple agents run concurrently on different cards without file conflicts |
| Git worktree isolation | Each card gets its own `vk/<hash>-<slug>` branch and worktree |
| MCP support | Agents control the board programmatically via `vk_*` tools |
| Docker deploy | `docker run -p 3000:3000 vibekanban/vibe-kanban` for remote teams |

---

### ralph — Ouroboros Specification-First AI Development
> **용도**: 코드 작성 전 요구사항 명확화 → 검증 통과까지 영구 루프 실행 | **플랫폼**: Claude · Gemini · Codex · OpenCode | **상태**: stable v3.0.0
> Keyword: `ralph`, `ooo` | [GitHub](https://github.com/Q00/ouroboros)

> *Stop prompting. Start specifying. The boulder never stops.*

Ouroboros 기반 specification-first 워크플로우. 소크라테스식 인터뷰로 숨겨진 가정을 노출한 뒤 불변 스펙으로 결정화 → Double Diamond 실행 → 3단계 검증 → 온톨로지 수렴까지 진화 루프.

```bash
# 요구사항 명확화
ooo interview "I want to build a task management CLI"
ooo seed                     # YAML 스펙 생성 (Ambiguity ≤ 0.2 게이트)
ooo run                      # Double Diamond 실행
ooo evaluate <session_id>    # 3단계 검증

# 검증 통과까지 영구 루프
ooo ralph "fix all failing tests"
```

| 커맨드 | 역할 |
|--------|------|
| `ooo interview` | 소크라테스식 질문 → Ambiguity ≤ 0.2 |
| `ooo seed` | YAML 스펙 결정화 |
| `ooo run` | Double Diamond 실행 |
| `ooo evaluate` | Mechanical → Semantic → Consensus 3단계 검증 |
| `ooo evolve` | 진화 루프 (Similarity ≥ 0.95 수렴) |
| `ooo ralph` | 검증 통과까지 영구 루프 |
| `ooo unstuck` | 막혔을 때 — 5 페르소나 lateral thinking |

Codex 설정:

```bash
bash <your-agent-skills>/ralph/scripts/setup-codex-hook.sh
```
---

### omc — oh-my-claudecode
> **용도**: Claude Code 멀티에이전트 팀 오케스트레이션 | **플랫폼**: Claude | **상태**: stable
> Keyword: `omc` / `autopilot` / `ralph` / `ulw` | [Docs](docs/omc/README.md) | [GitHub](https://github.com/Yeachan-Heo/oh-my-claudecode)

Teams-first multi-agent orchestration layer for Claude Code. 32 specialized agents, smart model routing, and a staged pipeline (`team-plan → team-prd → team-exec → team-verify → team-fix`).

```bash
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/omc:omc-setup
```

| Mode | Use For |
|------|---------|
| **Team** (canonical) | Coordinated agents on shared task list |
| **Autopilot** | End-to-end feature work |
| **Ralph** | Tasks that must fully complete |
| **Ultrawork** | Burst parallel fixes/refactors |

---

### bmad-orchestrator — AI-Driven Development Harness
> **용도**: 분석→계획→설계→구현 단계별 AI 개발 | **플랫폼**: Claude | **상태**: in development
> Keyword: `bmad` | [Docs](docs/bmad/README.md)

Phase-based workflow (Analysis → Planning → Solutioning → Implementation) for disciplined AI-assisted development. Automatically adapts to project scope (Level 0–4).

> Note: This is primarily a Claude Code native workflow. For Codex/OpenCode-based use, combine with `omx`/`ohmg` orchestration.

```bash
npx skills add https://github.com/akillness/skills-template --skill bmad-orchestrator
# Then in Claude Code:
# bmad 스킬을 설정하고 사용해줘. 기억해.
# /workflow-init
```

| Phase | Purpose |
|-------|---------|
| 1 Analysis | Market research, product vision |
| 2 Planning | PRD or Tech Spec |
| 3 Solutioning | Architecture design |
| 4 Implementation | Sprint planning, dev, code review |

| Feature | Description |
|---------|-------------|
| Phase Gate Review | plannotator review UI at each phase transition |
| Obsidian Archive | Auto-save approved docs with YAML frontmatter |
| Team Visibility | Share review link for stakeholder annotation |
| **TOON Format Injection** | 전 플랫폼 스킬 컨텍스트 자동 주입 — Claude Code 훅 / Gemini includeDirectories / Codex 정적 카탈로그 |

---

### jeo — Integrated Agent Orchestration
> **용도**: 전체 워크플로우 통합 자동화 | **플랫폼**: Claude · Codex · Gemini · OpenCode | **상태**: stable
> Keyword: `jeo` · `annotate` · `UI검토` | Platforms: Claude Code · Codex CLI · Gemini CLI · OpenCode

계획(ralph+plannotator) → 실행(team/bmad) → 브라우저검증(agent-browser) → UI피드백(agentation/annotate) → 정리(worktree cleanup)의 완전 자동화 오케스트레이션 플로우.

```bash
bash scripts/install.sh --all   # 전체 설치
```

| Phase | Tool | Description |
|-------|------|-------------|
| Plan | ralph + plannotator | 시각적 계획 검토 → Approve/Feedback |
| Execute | omc team / bmad | 병렬 에이전트 실행 |
| Verify | agent-browser | 브라우저 동작 검증 (기본) |
| Verify UI | agentation (**annotate**) | UI 어노테이션 watch loop — pre-flight → ack→fix→resolve→re-snapshot |
| Cleanup | worktree-cleanup.sh | 완료 후 worktree 자동 정리 |

---

## TOON Format Injection

> **용도**: 모든 프롬프트에 스킬 컨텍스트 자동 주입 | **플랫폼**: Claude Code · Codex CLI · Gemini CLI | **상태**: stable v1.0.0

TOON(Token-Oriented Object Notation) 포맷으로 스킬 카탈로그를 압축하여 AI 도구의 모든 프롬프트에 자동 주입합니다. JSON/Markdown 대비 40-50% 토큰 절감. ultrateam 6명(QA·LLM전문가·Skill전문가·ClaudeCode·Codex·Gemini-CLI)이 설계·구현했습니다.

### Two-Tier Architecture

- **Tier 1 (항상 주입)**: 스킬 카탈로그 인덱스 (~875-3,500 tokens) — 프롬프트마다 스킬 이름+설명+태그 자동 주입
- **Tier 2 (온디맨드)**: 개별 SKILL.toon 전체 내용 (~292 tokens/skill, max 3) — 스킬 이름/태그 감지 시 자동 로드

> 전체 71개 동시 주입 (~20,700 tokens)은 금지. Tier 1 + 온디맨드 max 3개 원칙으로 5% 이하 컨텍스트 비용 유지.

### 플랫폼별 구현

| 플랫폼 | 파일 | 메커니즘 | 성능 |
|--------|------|---------|------|
| **Claude Code** | `~/.claude/hooks/toon-inject.mjs` | `UserPromptSubmit` 훅 — Node.js, 3단계 키워드 매칭, 심링크 투명 추적 | 26-37ms |
| **Gemini CLI** | `~/.gemini/hooks/toon-skill-inject.sh` | `includeDirectories` 세션 시작 로드 + `AfterAgent` 갱신 훅 | ~0.1s |
| **Codex CLI** | `~/.codex/skills-toon-catalog.toon` | 정적 카탈로그 + `notify-dispatch.py` + 2-턴 사이드카 패턴 | 0ms (정적) |

> **왜 Node.js인가**: `~/.claude/skills/`는 `~/.agents/skills/`로의 심링크 구조. Python `Path.rglob()`은 심링크를 따르지 않아 0개를 반환. Node.js `readdirSync`는 투명하게 추적합니다.

### TOON 포맷 기본 구조

```
N:skill-name  D:description  G:tag1 tag2 tag3
U[n]: use cases · S[n]{n,action,details}: steps · R[n]: rules · E[n]{desc,in,out}: examples
```

상세 설정: [bmad-orchestrator SKILL.md — TOON Format Integration](.agent-skills/bmad-orchestrator/SKILL.md)

---

## Structure

```text
.
├── .agent-skills/
│   ├── README.md
│   ├── skill_loader.py
│   ├── skill-query-handler.py
│   ├── skills.json
│   ├── skills.toon
│   └── [70 skill folders]
├── docs/
│   ├── bmad/           ← bmad-orchestrator harness guide
│   ├── omc/            ← oh-my-claudecode guide
│   ├── plannotator/    ← plan & diff review (v0.9.0, multi-tool)
│   ├── ralph/          ← completion loop guide
│   └── vibe-kanban/    ← AI Kanban board guide
├── install.sh / flatten_skills.py
└── README.md
```

---

## Related docs

| Tool | Keyword | Doc |
|------|---------|-----|
| plannotator | `plan`, `계획` | [docs/plannotator/README.md](docs/plannotator/README.md) |
| vibe-kanban | `kanbanview` | [docs/vibe-kanban/README.md](docs/vibe-kanban/README.md) |
| ralph | `ralph` | [docs/ralph/README.md](docs/ralph/README.md) |
| omc | `omc` | [docs/omc/README.md](docs/omc/README.md) |
| bmad-orchestrator | `bmad` | [docs/bmad/README.md](docs/bmad/README.md) |
| jeo | `jeo` · `annotate` · `UI검토` | [.agent-skills/jeo/SKILL.md](.agent-skills/jeo/SKILL.md) |

---

## Changelog

**v2026-03-08 (latest)**:
- **jeo: plannotator Claude Code 호출 방식 수정 (P0)**: `plannotator`는 hook-only 바이너리로 Claude Code의 `ExitPlanMode` PermissionRequest 훅으로만 동작. `jeo/SKILL.md`(배포 및 소스)에서 존재하지 않는 `submit_plan` MCP 툴 호출 지시 제거 → `EnterPlanMode` → plan 작성 → `ExitPlanMode` 훅 플로우로 교체. pre-flight bash 블록에 Claude Code 스킵 주석 추가. `bmad-orchestrator/SKILL.md` Claude Code / OpenCode 플랫폼별 호출 방식 명확화. 트러블슈팅 항목 추가
- **jeo: Gemini CLI plannotator 피드백 대기 수정**: AfterAgent 훅에 `timeout: 1800` (30분) 추가. 구형 훅 엔트리(`matcher`/`hooks` 래퍼 없는 평탄 형식)를 setup 재실행 시 자동 마이그레이션. Gemini 설정에서 무효한 `PermissionRequest.ExitPlanMode` 제거 (Claude Code 전용 이벤트)
- **jeo: Claude Code 훅 포맷 오류 수정**: `setup-claude.sh`가 `UserPromptSubmit` 훅을 새 matcher 포맷으로 생성하고 구형 포맷을 자동 마이그레이션하여 설치 후 `hooks: Expected array, but received undefined` 설정 오류 해결

**v2026-03-06**:
- **TOON Format 전 플랫폼 훅 통합**: ultrateam(QA·LLM전문가·Skill전문가·ClaudeCode·Codex·Gemini-CLI) 6명 설계·구현. Claude Code: `~/.claude/hooks/toon-inject.mjs` Node.js hook (심링크 추적, 3단계 키워드 매칭, 26-37ms). Gemini CLI: `~/.gemini/hooks/toon-skill-inject.sh` + `includeDirectories` + `AfterAgent` 훅. Codex CLI: 정적 카탈로그(`skills-toon-catalog.toon`, 62 skills) + `notify-dispatch.py` + 2-턴 사이드카 패턴
- **bmad-orchestrator SKILL.md TOON Integration 섹션**: Two-tier 아키텍처 전체 문서화 (Tier 1 카탈로그 ~875-3,500 tokens 항상 주입 / Tier 2 SKILL.toon 온디맨드 max 3개)
- **71개 SKILL.toon 전수 검증**: 모든 스킬 TOON 포맷 준수 여부 검증 및 수정 완료

**v2026-03-05**:
- **jeo: state file guard 버그 수정 (P0)**: AfterAgent 훅이 `jeo-state.json` 부재 시 plannotator를 잘못 실행하던 버그 수정
- **jeo: 에이전트 실행 프로토콜 추가 (P1)**: `SKILL.md`에 `## 0. 에이전트 실행 프로토콜` 섹션 삽입. STEP 0~4 명령형 pseudocode
- **skills-lock.json: 의존성 명세 추가 (P1)**: `plannotator` + `agentation` required_by jeo 등록
- **agentation v1.1.0 설치 개선**: Claude Code Official Skill + Universal `npx add-mcp` + Local-first 아키텍처 문서화

**v2026-03-04**:
- **jeo annotate 통합 (v2)**: VERIFY_UI 키워드 `agentui` → `annotate`. Phase guard로 plannotator-agentation 훅 충돌 해결. Pre-flight 3단계 체크, RE-SNAPSHOT 검증
- **ralph v3.0.0**: [Q00/ouroboros](https://github.com/Q00/ouroboros) 기반 전면 재작성. Interview→Seed→Execute→Evaluate→Evolve, 9 에이전트, Ambiguity ≤ 0.2 게이트, Similarity ≥ 0.95 수렴
- **setup-all-skills-prompt 클린 재설치**: 설치 전 기존 디렉터리 자동 제거 후 재생성

**v2026-03-03 (update)**:
- **bmad-gds**: New skill — BMAD Game Development Studio. 5단계 파이프라인, 6 전문 에이전트 (Unity/Unreal/Godot)
- **bmad-idea**: New skill — BMAD Creative Intelligence Suite. 5개 워크플로우, 5 named 에이전트
- **ai-tool-compliance P1 확장**: `--include-p1` 옵션 추가, `p1_maturity_score` 출력, CI 토글 추가

**v2026-03-03**:
- **ai-tool-compliance**: New skill — P0/P1 컴플라이언스 자동 검증. 4도메인 이진 점수(보안 40/권한 25/비용 20/로그 15), GitHub Actions 게이트, 이력 추적

# Agent Skills

> 🌐 Language / 언어: **[English](README.md)** | **한국어**

> v2026-03-11 · **79 Skills** · **TOON Format** · **Flat Skill Layout**

[![GitHub Releases](https://img.shields.io/badge/GitHub-Releases-blue)](https://github.com/supercent-io/skills-template/releases)
[![Skills](https://img.shields.io/badge/Skills-79-brightgreen)](#skills-list-79-total)
[![BMAD Deploy Version](https://img.shields.io/badge/BMAD-1.1.0-orange)](docs/bmad/README.md)

---

## Contents

- [Quick Start](#quick-start)
- [What's New](#whats-new-in-v2026-03-11)
- [설치 (Install)](#설치-install)
- [실행 가이드](#실행-가이드)
- [Skills List (79)](#skills-list-79-total)
- [Featured Tools](#featured-tools)
- [TOON Format Injection](#toon-format-injection)
- [Structure](#structure)
- [추천 Harness OSS](#추천-harness-oss)
- [Related docs](#related-docs)

---

## Quick Start (For LLM Agents)

> **사전 준비**: `npx skills add` 명령을 실행하려면 먼저 `skills` CLI가 필요합니다.
>
> ```bash
> npm install -g skills
> ```

```bash
# LLM에게 전달: 아래 가이드를 읽고 설치를 진행하세요
curl -s https://raw.githubusercontent.com/supercent-io/skills-template/main/setup-all-skills-prompt.md
```

> 더 많은 스킬 설치 → [설치](#설치-install) | 플랫폼별 상세 실행 → [실행 가이드](#실행-가이드)

---

## What's New in v2026-03-11

| 변경 | 내용 |
|------|------|
| **jeo v1.3.0: Claude Code plan gate + agentation submit hook 추가** | `setup-claude.sh`가 설치하는 두 개의 새 Python 훅. `claude-plan-gate.py`: `ExitPlanMode` 시 plan 내용을 SHA-256 해시하여 동일 plan이 이미 terminal 상태로 검토된 경우 plannotator를 건너뜀. 수정된 plan이 감지되면 게이트를 초기화. `claude-agentation-submit-hook.py`: `UserPromptSubmit` 훅 — `VERIFY_UI` 단계에서 submit-style 프롬프트가 도착할 때만 pending agentation 어노테이션을 노출(`localhost:4747/pending` 폴링). `setup-claude.sh`가 두 훅, agentation MCP 서버, `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`을 자동 등록. |
| **skill-standardization v2.0: evals + validate_skill.sh 추가** | agentskills.io 스펙을 참조하도록 업데이트. `evals/evals.json` 지원 추가(스킬당 2–5개 테스트 케이스)와 `scripts/validate_skill.sh`로 스펙 자동 검증(name, description 길이, allowed-tools 형식, 파일 길이 검사). 트리거에 `"add evals to skill"` 추가. |
| **jeo v1.2.3: plannotator-plan-loop.sh 전 플랫폼 강화** | 크로스 플랫폼 임시 디렉토리(`TMPDIR`/`TMP`/`TEMP` 폴백), 전용 포트 `PLANNOTATOR_PORT=47291`(IANA 미배정), `probe_plannotator_port()`(rc=0 여유/rc=1 포트 충돌/rc=2 sandbox 차단) + `wait_for_listen()`(`/dev/tcp` 우선 + Python3 폴백), 백그라운드 PID 추적 및 2단계 모니터링(STARTING → LISTENING), 브라우저 강제종료 시 최대 3회 자동 재시작, 비TTY 환경에서 `jeo-blocked.json` 구조화 출력. |
| **survey: 전 플랫폼 문제공간 스캔 스킬 추가** | `groundwork`에서 영감을 받은 `survey` 스킬을 추가했습니다. 4개 병렬 조사 레인을 유지하면서 결과물을 `.survey/{slug}/`에 저장하고, Claude/Codex/Gemini 차이를 `settings` / `rules` / `hooks` 추상 레이어로 정리합니다. 전체 스킬 수는 76개에서 **77개**가 되었습니다. |
| **presentation-builder: slides-grab 워크플로우 채택** | `presentation-builder`가 이제 `slides-grab` 기반 HTML 슬라이드 작성, 시각 편집, 검증, PPTX/PDF export를 사용합니다. 중복 스킬 `pptx-presentation-builder`는 제거되어 전체 스킬 수는 77개에서 **76개**가 되었습니다. |
| **jeo v1.2.2: Codex plannotator 블로킹 대기 버그 수정** | `plannotator-plan-loop.sh`가 모든 종료 경로(approved/feedback_required/infrastructure_blocked)에서 `plan_gate_status`를 `jeo-state.json`에 기록. `jeo-notify.py`에 `write_plan_gate_result()` 추가로 게이트 결과를 상태 파일에 반영. **Conversation Approval Mode** 추가: exit 32 발생 시 에이전트가 plan.md를 대화에 출력하고 사용자의 명시적 승인을 기다림 — sandbox 환경에서 PLAN 게이트를 건너뛰는 문제 해결. |
| **jeo v1.2.1: Gemini/Antigravity plannotator 반복 호출 버그 수정** | PLAN 블록에 GUARD 추가 — `jeo-state.json`에서 `plan_approved=true` 감지 시 plannotator 재호출 방지. hook 기반 환경에서의 무한 재호출 문제 해결. |
| **jeo v1.2.1: Claude Code team 모드 필수화** | Claude Code에서 단일 에이전트 실행 폴백 제거. EXECUTE는 반드시 `/omc:team` 사용. |
| **jeo v1.2.1: plannotator Claude Code 동작 방식 수정 (P0)** | `plannotator`는 hook-only 바이너리. 존재하지 않는 `submit_plan` MCP 툴 호출 제거. `EnterPlanMode` → plan 작성 → `ExitPlanMode` 훅 방식으로 교체. `bmad-orchestrator/SKILL.md`도 플랫폼별 방식 명확화. |
| **jeo v1.2.1: plannotator 자동 설치** | plannotator 미설치 시 `bash scripts/ensure-plannotator.sh` 자동 실행. PLAN pre-flight에 동적 스크립트 경로 탐색 블록 추가. |
| **ralphmode v0.2.0: 실행 중 승인 체크포인트 추가** | Step 6 추가 — 플랫폼별 위험 작업 차단 메커니즘. Claude Code `PreToolUse` 훅(exit 2) + Gemini CLI `BeforeTool` 훅 + Codex CLI `approval_policy` + OpenCode prompt contract. Tier 1/2/3 분류표 포함. |
| **jeo v1.2.1: Codex config.toml 따옴표 버그 수정** | 재실행 시 `developer_instructions` 블록의 닫는 `"""` 소비 방지. |
| **jeo v1.2.1: Gemini CLI plannotator 피드백 대기 수정** | AfterAgent 훅에 `timeout: 1800` 추가. 구식 훅 형식 자동 마이그레이션. |
| **jeo v1.2.1: Claude Code 훅 형식 수정** | `UserPromptSubmit` 훅을 새 matcher 형식으로 변경. `setup-claude.sh`에서 구식 형식 자동 마이그레이션. |
| **bmad-orchestrator: 영문 로컬라이제이션** | 한국어 섹션 영어로 통일. |

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
curl -s https://raw.githubusercontent.com/supercent-io/skills-template/main/setup-all-skills-prompt.md
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

#### 계획 전에 문제공간을 빠르게 조사 → `survey`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill survey
# 사용: survey "조사할 문제, 아이디어, 기능"
```

> 상세: [.agent-skills/survey/SKILL.md](.agent-skills/survey/SKILL.md)

#### Claude Code 멀티에이전트 조율 → `omc`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill omc
# 사용: /omc:team "작업 내용"
```

> 상세: [docs/omc/README.md](docs/omc/README.md)

#### OpenAI Codex CLI 멀티에이전트 → `omx`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill omx
```

> 상세: [.agent-skills/omx/SKILL.md](.agent-skills/omx/SKILL.md)

#### Gemini / Antigravity 워크플로우 → `ohmg`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill ohmg
```

> 상세: [.agent-skills/ohmg/SKILL.md](.agent-skills/ohmg/SKILL.md)

#### 단계별 구조화 개발 (분석→계획→설계→구현) → `bmad-orchestrator`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator
# 사용: bmad 스킬을 설정하고 사용해줘. /workflow-init
```

> 상세: [docs/bmad/README.md](docs/bmad/README.md)

#### 작업이 완료될 때까지 반복 실행 → `ralph`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill ralph
# 사용: /ralph "모든 TypeScript 오류 수정" --max-iterations=100
```

> 상세: [docs/ralph/README.md](docs/ralph/README.md)

#### Ralph 자동화 권한 프로파일 → `ralphmode`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill ralphmode
# 사용: Claude Code / Codex CLI / Gemini CLI에서 ralph 자동화용 permission profile 적용
```

> 상세: [.agent-skills/ralphmode/SKILL.md](.agent-skills/ralphmode/SKILL.md)

#### 계획 시각 검토 + Feedback loop → `plannotator`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill plannotator
# 사용: 계획을 세울 때 자동으로 브라우저 UI 오픈 → Approve 또는 피드백 전송
```

> 상세: [docs/plannotator/README.md](docs/plannotator/README.md)

#### 브라우저 자동화 (헤드리스) → `agent-browser`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill agent-browser
```

> 상세: [.agent-skills/agent-browser/SKILL.md](.agent-skills/agent-browser/SKILL.md)

#### Playwright 기반 브라우저 제어 → `playwriter`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill playwriter
```

> 상세: [.agent-skills/playwriter/SKILL.md](.agent-skills/playwriter/SKILL.md)

---

## Skills List (79 total)

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

### Frontend (9)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `design-system` | Design system implementation *(in development)* | All platforms |
| `frontend-design-system` | 디자인 토큰·레이아웃·모션·접근성 기반 프로덕션 UI 설계 | All platforms |
| `react-best-practices` | React & Next.js best practices | All platforms |
| `responsive-design` | Responsive web design | All platforms |
| `state-management` | State management patterns | All platforms |
| `ui-component-patterns` | UI component patterns | All platforms |
| `vercel-react-best-practices` | Vercel Engineering 기반 React & Next.js 성능 최적화 가이드 | Claude · Gemini · Codex |
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
| `presentation-builder` | slides-grab 기반으로 시각 검토와 PPTX/PDF export까지 처리하는 프레젠테이션 빌더 | All platforms |
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

### Creative Media (5)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `image-generation` | AI image generation *(in development)* | Claude · Gemini |
| `image-generation-mcp` | MCP를 통한 이미지 생성 (Gemini 등) — 구조화 프롬프트, 비율, 검증 지원 | All platforms |
| `pollinations-ai` | Free image generation via Pollinations.ai *(in development)* | All platforms |
| `remotion-video-production` | Remotion 기반 프로그래머블 비디오 — 씬 플래닝, 에셋 오케스트레이션, 검증 게이트 | All platforms |
| `video-production` | Video production workflows *(in development)* | All platforms |

### Marketing (2)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `marketing-automation` | Marketing automation *(in development)* | All platforms |
| `marketing-skills-collection` | CRO·카피라이팅·SEO·애널리틱스·그로스 마케팅 산출물 생성 (23개 서브스킬) | All platforms |

### Utilities (24)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `agent-browser` | Fast headless browser CLI for AI agents | All platforms |
| `agentation` | Visual UI annotation tool — `npx skills add benjitaylor/agentation` → `/agentation` (Claude Code Official Skill) · `npx add-mcp` (9+ 에이전트 자동 감지) · Local-first 디자인(오프라인 동작·세션 연속성) | Claude · Gemini · Codex · Cursor · Windsurf · OpenCode |
| `bmad-gds` | BMAD Game Development Studio — Pre-production through production with 6 specialized agents (Unity · Unreal · Godot) | Claude · Gemini · Codex · OpenCode |
| `bmad-idea` | BMAD Creative Intelligence Suite — brainstorming, design thinking, innovation strategy, problem-solving, storytelling | Claude · Gemini · Codex · OpenCode |
| `copilot-coding-agent` | GitHub Copilot Coding Agent — Issue → Draft PR automation | Claude · Codex |
| `environment-setup` | Environment setup | All platforms |
| `fabric` | AI prompt orchestration CLI using reusable Patterns — YouTube summarization, document analysis, content extraction via 200+ Patterns and 15+ AI providers | All platforms |
| `file-organization` | File & folder organization | All platforms |
| `git-submodule` | Git submodule management | All platforms |
| `git-workflow` | Git workflow management | All platforms |
| `jeo` | Integrated AI orchestration: ralph+plannotator → team/bmad → agent-browser verify → agentation(annotate) UI피드백 → worktree cleanup | Claude · Codex · Gemini · OpenCode |
| `npm-git-install` | Install npm from GitHub | All platforms |
| `ohmg` | Multi-agent orchestration for Antigravity workflows | Claude · Gemini |
| `omx` | Multi-agent orchestration for OpenAI Codex CLI *(in development)* | Codex |
| `omc` | oh-my-claudecode — Teams-first multi-agent orchestration | Claude |
| `opencontext` | AI agent persistent memory | All platforms |
| `plannotator` | Visual plan and diff review — annotate, approve, or request changes | Claude |
| `playwriter` | Playwright 기반 브라우저 자동화 — Chrome 확장 + MCP/CLI, 기존 로그인/쿠키 유지, 실인증 자동화 | All platforms |
| `ralph` | Self-referential completion loop for multi-turn agents | Claude |
| `ralphmode` | Cross-platform Ralph automation permission profiles for Claude Code, Codex CLI, and Gemini CLI | Claude · Codex · Gemini |
| `skill-standardization` | SKILL.md standardization | All platforms |
| `survey` | 계획이나 구현 전에 문제공간을 조사하는 전 플랫폼 리서치 스킬. 공용 산출물을 저장하고 에이전트 플랫폼 차이를 settings/rules/hooks로 정규화 | Claude · Codex · Gemini · OpenCode |
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
npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator
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

> 전체 76개 동시 주입 (~22,100 tokens)은 금지. Tier 1 + 온디맨드 max 3개 원칙으로 5% 이하 컨텍스트 비용 유지.

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
│   └── [79 skill folders]
├── docs/
│   ├── bmad/           ← bmad-orchestrator harness guide
│   ├── bmad-gds/       ← BMAD Game Development Studio guide
│   ├── bmad-idea/      ← BMAD Creative Intelligence Suite guide
│   ├── harness/        ← 추천 harness OSS 가이드 (EN + KO)
│   ├── omc/            ← oh-my-claudecode guide
│   ├── plannotator/    ← plan & diff review (v0.9.0, multi-tool)
│   ├── ralph/          ← completion loop guide
│   └── vibe-kanban/    ← AI Kanban board guide
├── install.sh / flatten_skills.py
└── README.md
```

---

## 추천 Harness OSS

Agent Skills와 함께 사용하기 좋은 오픈소스 에이전트 하네스 및 오케스트레이션 프레임워크 모음입니다. GitHub 스타 순으로 정렬되어 있습니다 (2026-03-10 기준). → **[설치 방법 및 연동 가이드 전체 보기](docs/harness/README.ko.md)**

| 레포지토리 | 스타 | 포크 | 설명 |
|-----------|-----:|-----:|------|
| [AutoGPT](https://github.com/Significant-Gravitas/AutoGPT) | 182k | 46.2k | 지속적 에이전트 구축·실행을 위한 접근성 높은 AI 플랫폼 |
| [superpowers](https://github.com/obra/superpowers) | 75.7k | 5.9k | 코딩 에이전트를 위한 컴포저블 스킬 프레임워크 & 개발 방법론 |
| [AutoGen](https://github.com/microsoft/autogen) | 55.4k | 8.3k | Microsoft의 멀티 에이전트 대화 및 에이전트 AI 프레임워크 |
| [CrewAI](https://github.com/crewAIInc/crewAI) | 45.7k | 6.1k | 역할극 기반 자율 AI 에이전트 오케스트레이션 프레임워크 |
| [smolagents](https://github.com/huggingface/smolagents) | 25.9k | 2.4k | HuggingFace의 코드 사고 경량 에이전트 라이브러리 |
| [agency-agents](https://github.com/msitarzewski/agency-agents) | 21.2k | 3.3k | 9개 부서로 구성된 61개 특화 AI 에이전트 |
| [bkit-claude-code](https://github.com/popup-studio-ai/bkit-claude-code) | 366 | 94 | Claude Code용 PDCA 방법론 + CTO 주도 에이전트 팀 |

> 주요 특장점, 설치 명령, Agent Skills 연동 방법 → [docs/harness/README.ko.md](docs/harness/README.ko.md)

---

## Related docs

| Tool | Keyword | Doc |
|------|---------|-----|
| plannotator | `plan`, `계획` | [docs/plannotator/README.md](docs/plannotator/README.md) |
| vibe-kanban | `kanbanview` | [docs/vibe-kanban/README.md](docs/vibe-kanban/README.md) |
| ralph | `ralph` | [docs/ralph/README.md](docs/ralph/README.md) |
| omc | `omc` | [docs/omc/README.md](docs/omc/README.md) |
| bmad-orchestrator | `bmad` | [docs/bmad/README.md](docs/bmad/README.md) |
| bmad-gds | `bmad-gds` | [docs/bmad-gds/README.md](docs/bmad-gds/README.md) |
| bmad-idea | `bmad-idea` | [docs/bmad-idea/README.md](docs/bmad-idea/README.md) |
| jeo | `jeo` · `annotate` · `UI검토` | [.agent-skills/jeo/SKILL.md](.agent-skills/jeo/SKILL.md) |
| 추천 Harness OSS | — | [docs/harness/README.ko.md](docs/harness/README.ko.md) |


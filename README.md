# Agent Skills

> v2026-03-03 · **69 Skills** · **TOON Format** · **Flat Skill Layout** · [GitHub Releases](https://github.com/akillness/skills-template/releases/tag/v2026-03-03)

> 스킬 구성 및 상세 목록: [.agent-skills/README.md](.agent-skills/README.md)

---

## Contents

- [Quick Start](#quick-start)
- [What's New](#whats-new-in-v2026-03-03)
- [설치 (Install)](#설치-install)
- [실행 가이드](#실행-가이드)
- [Skills List (69)](#skills-list-69-total)
- [Featured Tools](#featured-tools)
- [Structure](#structure)
- [Related docs](#related-docs)
- [Changelog](#changelog)

---

## Quick Start (For LLM Agents)

```bash
# LLM에게 전달: 아래 가이드를 읽고 설치를 진행하세요
curl -s https://raw.githubusercontent.com/akillness/skills-template/main/setup-all-skills-prompt.md
```

> 더 많은 스킬 설치 → [설치](#설치-install) | 플랫폼별 상세 실행 → [실행 가이드](#실행-가이드)

---

## What's New in v2026-03-03

| 변경 | 내용 |
|------|------|
| **신규 `ai-tool-compliance` 스킬** | 내부 AI 툴 필수 구현 가이드(P0/P1) 기반 컴플라이언스 자동 검증. 4도메인 이진 점수(40/25/20/15), 배포 게이트, 이력 추적 |
| **`ai-tool-compliance` P1 확장** | 기본 P0 검증 경로는 유지하고(`verify.sh` 기본 동작 변경 없음), 선택적 P1 확장 모드(`--include-p1`)와 P1 성숙도 점수(`p1_maturity_score`)를 추가. 리포트/문서는 append-only로 확장 |
| **신규 `bmad-gds` 스킬** | BMAD Game Development Studio — Pre-production·Design·Architecture·Production·GameTest 5단계, 6 전문 에이전트 (Unity · Unreal Engine · Godot 지원) |
| **신규 `bmad-idea` 스킬** | BMAD Creative Intelligence Suite — 브레인스토밍·디자인 씽킹·혁신 전략·문제 해결·스토리텔링 5개 즉시 실행 워크플로우, 5 전문 에이전트 (Carson · Maya · Victor · Dr. Quinn · Sophia) |

---

## 설치 (Install)

### LLM 에이전트용 (For LLM Agents)

LLM 에이전트가 설치를 도울 경우, 다음 단계를 따르세요.

```bash
# LLM에게 전달: 아래 가이드를 읽고 설치를 진행하세요
curl -s https://raw.githubusercontent.com/akillness/skills-template/main/setup-all-skills-prompt.md
```
---

### 사람용 (For Humans)

#### 1단계: jeo 설치 (권장 — 핵심 기능 전부 포함)

`jeo` 하나로 계획·실행·추적·정리 워크플로우가 모두 활성화됩니다.

```bash
npx skills add https://github.com/akillness/skills-template --skill jeo
```

#### Gemini CLI 사용 시

```bash
gemini extensions install https://github.com/akillness/skills-template
```

> [Hooks 공식 가이드](https://developers.googleblog.com/tailor-gemini-cli-to-your-workflow-with-hooks/)

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

## Skills List (69 total)

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

### Utilities (19)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `agent-browser` | Fast headless browser CLI for AI agents | All platforms |
| `bmad-gds` | BMAD Game Development Studio — Pre-production through production with 6 specialized agents (Unity · Unreal · Godot) | Claude · Gemini · Codex · OpenCode |
| `bmad-idea` | BMAD Creative Intelligence Suite — brainstorming, design thinking, innovation strategy, problem-solving, storytelling | Claude · Gemini · Codex · OpenCode |
| `copilot-coding-agent` | GitHub Copilot Coding Agent — Issue → Draft PR automation | Claude · Codex |
| `environment-setup` | Environment setup | All platforms |
| `file-organization` | File & folder organization | All platforms |
| `git-submodule` | Git submodule management | All platforms |
| `git-workflow` | Git workflow management | All platforms |
| `jeo` | Integrated AI orchestration: ralph+plannotator → team/bmad → agent-browser verify → worktree cleanup | Claude · Codex · Gemini · OpenCode |
| `npm-git-install` | Install npm from GitHub | All platforms |
| `ohmg` | Multi-agent orchestration for Antigravity workflows | Claude · Gemini |
| `oh-my-codex` | Multi-agent orchestration for OpenAI Codex CLI *(in development)* | Codex |
| `omc` | oh-my-claudecode — Teams-first multi-agent orchestration | Claude |
| `opencontext` | AI agent persistent memory | All platforms |
| `plannotator` | Visual plan and diff review — annotate, approve, or request changes | Claude |
| `ralph` | Self-referential completion loop for multi-turn agents | Claude |
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

### ralph — Completion Loop
> **용도**: 작업 완료까지 자동 반복 실행 | **플랫폼**: Claude · Gemini · Codex · OpenCode | **상태**: stable
> Keyword: `ralph` | [Docs](docs/ralph/README.md) | [GitHub](https://github.com/gemini-cli-extensions/ralph)

Self-referential loop that re-runs the agent on the same task across turns (with fresh context each iteration) until a `<promise>DONE</promise>` tag is detected or max iterations is reached.

```bash
/ralph "Fix all TypeScript errors" --completion-promise="0 errors" --max-iterations=100
```

Available in: Gemini CLI, OpenCode, Claude Code, Codex.

For Codex, use the local setup script first when you want loop continuity hints:

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

---

### jeo — Integrated Agent Orchestration
> **용도**: 전체 워크플로우 통합 자동화 | **플랫폼**: Claude · Codex · Gemini · OpenCode | **상태**: stable
> Keyword: `jeo` | Platforms: Claude Code · Codex CLI · Gemini CLI · OpenCode

계획(ralph+plannotator) → 실행(team/bmad) → 검증(agent-browser) → 정리(worktree cleanup)의 완전 자동화 오케스트레이션 플로우.

```bash
bash scripts/install.sh --all   # 전체 설치
```

| Phase | Tool | Description |
|-------|------|-------------|
| Plan | ralph + plannotator | 시각적 계획 검토 → Approve/Feedback |
| Execute | omc team / bmad | 병렬 에이전트 실행 |
| Verify | agent-browser | 브라우저 동작 검증 (기본) |
| Cleanup | worktree-cleanup.sh | 완료 후 worktree 자동 정리 |

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
│   └── [65 skill folders]
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
| jeo | `jeo` | [.agent-skills/jeo/SKILL.md](.agent-skills/jeo/SKILL.md) |

---

## Changelog

**v2026-03-03 (latest, update)**:
- **bmad-gds**: New skill — BMAD Game Development Studio. Pre-production → Design → Technical → Production → GameTest 5단계 파이프라인, 24개 커맨드, 6 전문 에이전트 (Unity/Unreal/Godot 지원), SKILL.toon + REFERENCE.md 포함
- **bmad-idea**: New skill — BMAD Creative Intelligence Suite (CIS). 브레인스토밍·디자인 씽킹·혁신 전략·문제 해결·스토리텔링 5개 즉시 실행 워크플로우, 5 named 에이전트 (Carson/Maya/Victor/Dr. Quinn/Sophia), SKILL.toon + REFERENCE.md 포함
- **ai-tool-compliance P1 확장**: `verify.sh --include-p1` 옵션 추가(기본 P0 유지), `catalog-p1.json`/`catalog-all.json` 카탈로그 추가, `score.sh`에 `p1_maturity_score`/`p0_gate_score` 출력 확장, `gate.sh`에 P1 성숙도 표시 추가
- **ai-tool-compliance P1 확장**: `verify.sh --include-p1` 옵션 추가(기본 P0 유지), `catalog-p1.json`/`catalog-all.json` 카탈로그 추가, `score.sh`에 `p1_maturity_score`/`p0_gate_score` 출력 확장, `gate.sh`에 P1 성숙도 표시 추가
- **Workflow Toggle**: `templates/ai-tool-compliance.yml`에 `COMPLIANCE_INCLUDE_P1` 환경변수 추가(기본 `false`), 켜면 CI에서 P0+P1 동시 검증
- **문서/리포트 확장**: `SKILL.md`와 `risk-score-report.md`에 Notion 표 정렬용 P1 v1.1 섹션을 append-only 방식으로 추가

**v2026-03-03 (latest)**:
- **ai-tool-compliance**: New skill — 내부 AI 툴 필수 구현 가이드 v1.1 기반 P0/P1 컴플라이언스 자동 검증. 4도메인 이진 점수 체계(보안 40/권한 25/비용 20/로그 15), GitHub Actions 배포 게이트, `.compliance/runs/` 이력 추적, `verify.sh` + `score.sh` 파이프라인

**v2026-02-26**:
- **agent-browser**: SKILL.md를 운영형 구조로 확장 (core workflow, verification, safeguards, troubleshooting)
- **agent-browser**: SKILL.toon 동기화 (snapshot-interact-resnapshot + verify 단계 반영)
- **agent-browser**: references 4종 및 templates 2종 추가

**v2026-02-26**:
- **jeo (codex setup)**: `setup-codex.sh`가 `developer_instructions`를 Codex 스키마에 맞는 top-level 문자열로 강제 동기화하도록 수정
- **jeo (status check)**: Codex 설정 검증을 강화해 잘못된 `developer_instructions` 형식을 정확히 감지하고 안내

**v2026-02-25 (latest)**:
- **jeo**: New skill added — Integrated Agent Orchestration (ralph+plannotator → team/bmad → agent-browser verify → worktree cleanup); registered in skills.json under utilities
- Skills list 표 형식 개편 (카테고리 재구성, 65개 전체)

**v2026-02-23**:
- **plannotator/Obsidian**: Verified Obsidian integration (2026-02-23); added automated browser limitation note (Playwright/Puppeteer cannot open obsidian:// URI); added folder organization guide (approved/, denied/, YYYY-MM/); added direct filesystem fallback pattern (SKILL.md, docs/plannotator/README.md, README.md)

**v2026-02-23**:
- **ralph**: Default `--max-iterations` changed from `5` → `100` (SKILL.md, SKILL.toon, docs/ralph/README.md)
- **plannotator**: Primary keyword changed from `planno` → `plan`, `계획` for natural design-phase activation; `planno` retained as backward-compatible alias in tags
- **vibe-kanban**: OpenCode MCP 설정 섹션 추가 (SKILL.md, docs/vibe-kanban/README.md); OpenCode + ulw 병렬 위임 사용 케이스 추가 (SKILL.toon v1.2.0)

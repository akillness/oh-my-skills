# Agent Skills

> v2026-03-03 (GitHub Release) · **69 Skills** · **TOON Format** · **Flat Skill Layout**

 GitHub Releases: https://github.com/akillness/skills-template/releases/tag/v2026-03-03
 Skills: 69 (release 기준)
 BMAD Deploy Version: 1.0.0

> 스킬 구성 및 상세 목록: [.agent-skills/README.md](.agent-skills/README.md)

---

## Contents

- [Quick Start](#quick-start)
- [What's New](#whats-new)
- [설치 (Install)](#설치-install)
- [실행 가이드](#실행-가이드)
- [Skills List (70)](#skills-list-70-total)
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

## What's New

최신 기능은 중복 없이 `Changelog`에서만 최신 5개만 확인하세요.
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

## Skills List (70 total)

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

최근 5개 항목만 표시합니다.

**v2026-03-05 (latest)**:
- **jeo: state file guard 버그 수정 (P0)**: `setup-gemini.sh`의 `jeo-plannotator.sh` 생성 블록에서 state file(`jeo-state.json`) 부재 시 즉시 `exit 0` 처리 추가. 이전에는 JEO가 비활성 상태여도 AfterAgent 훅이 `plan.md` 존재만으로 plannotator를 잘못 실행하던 버그 수정
- **jeo: 에이전트 실행 프로토콜 추가 (P1)**: `SKILL.md`에 `## 0. 에이전트 실행 프로토콜` 섹션 삽입. jeo 키워드 감지 즉시 따를 수 있는 명령형 pseudocode 5단계(STEP 0: state 부트스트랩 → STEP 1: PLAN/plannotator → STEP 2: EXECUTE → STEP 3: VERIFY → STEP 3.1: VERIFY_UI/agentation → STEP 4: CLEANUP). ralph 스킬 패턴과 동일한 형식
- **skills-lock.json: 의존성 명세 추가 (P1)**: `"dependencies"` 키 신규 추가 — `plannotator`(required_by: jeo, installCommand: `--with-plannotator`)와 `agentation`(required_by: jeo, installCommand: `--with-agentation`) 등록
- **agentation v1.1.0 설치 개선**: `agentation.dev/install` 공식 페이지 기반 SKILL.md 전면 개선. Claude Code Official Skill(`npx skills add benjitaylor/agentation` → `/agentation`), Universal `npx add-mcp` 우선 노출, Local-first 아키텍첸 문서화(오프라인 동작·세션 연속성·중복 없음), 오타 수정(`jeo 실치` → `설치`), 비전 v1.1.0 뱤프

**v2026-03-04**:
- **jeo annotate 통합 (v2)**: `agentation` `VERIFY_UI`를 `annotate`로 통합. `annotate` 키워드 watch loop( pre-flight → ack → fix → resolve )와 RE-SNAPSHOT 검증 추가로 훅 충돌/중복 실행을 방지.
- **ralph v3.0.0**: [Q00/ouroboros](https://github.com/Q00/ouroboros) 기반으로 전면 재작성. Specification-first 워크플로우(Interview→Seed→Execute→Evaluate→Evolve), 9개 에이전트, Ambiguity ≤ 0.2 게이트, Ontology Similarity ≥ 0.95 수렴 조건, 3플랫폼 병렬 지원
- **setup-all-skills-prompt 클린 재설치**: 설치 전 기존 `~/.agent-skills` 디렉터리를 자동 제거 후 재생성해서 재설치 충돌 방지

**v2026-03-03 (latest)**:
- **ai-tool-compliance**: P0/P1 컴플라이언스 자동 검증 스킬 추가. 4도메인 점수 체계(보안 40/권한 25/비용 20/로그 15), 배포 게이트, `.compliance/runs/` 이력 추적
- **bmad-gds**: BMAD Game Development Studio — Pre-production → Design → Architecture → Production → GameTest 파이프라인, 6 전문 에이전트(Unity/Unreal/Godot)
- **bmad-idea**: BMAD Creative Intelligence Suite (CIS) 추가. 브레인스토밍·디자인 씽킹·혁신 전략·문제 해결·스토리텔링 워크플로우
- **ai-tool-compliance P1 확장**: `verify.sh --include-p1` 추가와 P1 성숙도 점수(`p1_maturity_score`) 출력 확장
- **문서/리포트 확장**: SKILL 문서·리포트에 P1 정렬 섹션(append-only) 추가

**v2026-02-26**:
- **agent-browser**: SKILL.md 운영형 구조 확장(verification/보안/트러블슈팅), SKILL.toon 동기화, references/templates 추가
- **jeo codex setup**: `setup-codex.sh`에서 `developer_instructions`를 Codex 스키마와 정합되도록 top-level 문자열로 강제 동기화
- **setup-codex 상태 검증 강화**: 잘못된 `developer_instructions` 형식 감지 및 안내 로직 강화

**v2026-02-25**:
- **jeo 스킬 정식 통합**: ralph+plannotator + team/bmad 실행, agent-browser 검증, worktree 정리까지 포함한 BMAD 통합 오케스트레이션 스킬 추가
- **Skill 목록 리뉴얼**: 표 형식/카테고리 재구성으로 69개 → 70개 확장

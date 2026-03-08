# Agent Skills

> 🌐 Language / 언어: **English** | **[한국어](README.ko.md)**

> v2026-03-09 · **71 Skills** · **TOON Format** · **Flat Skill Layout**

[![GitHub Releases](https://img.shields.io/badge/GitHub-Releases-blue)](https://github.com/akillness/skills-template/releases)
[![Skills](https://img.shields.io/badge/Skills-71-brightgreen)](#skills-list-71-total)
[![BMAD Deploy Version](https://img.shields.io/badge/BMAD-1.1.0-orange)](docs/bmad/README.md)

> Skill configuration and full list: [.agent-skills/README.md](.agent-skills/README.md)

---

## Contents

- [Quick Start](#quick-start)
- [What's New](#whats-new-in-v2026-03-09)
- [Installation](#installation)
- [Getting Started Guide](#getting-started-guide)
- [Skills List (71)](#skills-list-71-total)
- [Featured Tools](#featured-tools)
- [TOON Format Injection](#toon-format-injection)
- [Structure](#structure)
- [Related Docs](#related-docs)
- [Changelog](#changelog)

---

## Quick Start (For LLM Agents)

> **Prerequisite**: Install `skills` CLI before running any `npx skills add` commands.
>
> ```bash
> npm install -g skills
> ```

```bash
# Send to your LLM agent: read this guide and proceed with installation
curl -s https://raw.githubusercontent.com/akillness/skills-template/main/setup-all-skills-prompt.md
```

> More skill installs → [Installation](#installation) | Platform-specific guides → [Getting Started](#getting-started-guide)

---

## What's New in v2026-03-09

| Change | Details |
|--------|---------|
| **jeo: Gemini/Antigravity repeated plannotator call fix** | `plannotator-plan-loop.sh` now writes `plan_approved` + `phase` to `jeo-state.json` on approval or feedback. `SKILL.md` PLAN block now has a GUARD that reads `jeo-state.json` and skips plannotator if already approved in a previous turn. AfterAgent hook logs result clearly. Prevents infinite re-invocation in environments without direct hook feedback injection. |
| **jeo: Codex config.toml stray quote fix** | `setup-codex.sh` now guards the legacy JEO strip regex — only runs when no `developer_instructions = """` block exists, preventing the closing `"""` from being consumed on re-runs. Post-write TOML validation added: auto-strips standalone `"` lines if parse fails. |
| **setup guides: jeo team mode + plannotator auto-install sync** | `setup-all-skills-prompt.md` and `setup-all-skills-prompt.ko.md` updated to document Claude Code team mode requirement (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) and plannotator auto-install behavior. |
| **ralphmode v0.2.0: Mid-Execution Approval Checkpoints** | 플랫폼별 실행 중 위험 작업 차단 메커니즘 추가. Claude Code `PreToolUse` 훅(exit 2 차단) + Gemini CLI `BeforeTool` 훅(non-zero exit 차단) + Codex CLI `approval_policy="unless-allow-listed"` + prompt contract + OpenCode prompt contract. Tier 1/2/3 위험 작업 분류표 및 훅 스크립트 템플릿 수록 |
| **jeo: plannotator auto-install before PLAN** | `jeo` now auto-runs `bash scripts/ensure-plannotator.sh` when `plannotator` is missing, so the PLAN gate installs the CLI first and only proceeds after the binary is available. `plannotator-plan-loop.sh` and `install.sh` now also fail fast if installation does not actually leave a runnable `plannotator` in `PATH` |
| **jeo: Claude Code now requires team mode** | In Claude Code, `jeo` no longer falls back to single-agent execution. EXECUTE must use `/omc:team`, and `check-status.sh` now fails when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is not configured |
| **jeo: plannotator Claude Code 동작 방식 수정 (P0)** | `plannotator`는 hook-only 바이너리로 Claude Code의 `ExitPlanMode` PermissionRequest 훅으로만 실행 가능. SKILL.md에서 존재하지 않는 `submit_plan` MCP 툴 호출 지시를 제거하고, 올바른 `EnterPlanMode` → write plan → `ExitPlanMode` hook 방식으로 교체. `bmad-orchestrator/SKILL.md`도 플랫폼별(Claude Code / OpenCode) 방식 명확화 |
| **jeo: Gemini CLI plannotator feedback wait fix** | Gemini CLI AfterAgent hooks now include `timeout: 1800` (30 min) for plannotator, ensuring the blocking review UI stays open until user approves or sends feedback. Old-format hooks without `matcher`/`hooks` wrapper are auto-migrated. Removed invalid `PermissionRequest.ExitPlanMode` (Claude Code-only event) from Gemini settings |
| **jeo: Claude Code hooks format fix** | Fixed `UserPromptSubmit` hooks to use the new matcher format (`{"matcher": "*", "hooks": [...]}`) instead of flat format. `setup-claude.sh` now auto-migrates old-format entries on re-run, preventing the `hooks: Expected array, but received undefined` error |

> Previous changes: [Changelog](#changelog)

---

## Installation

### Step 0: Install `skills` CLI

All `npx skills add` commands require the `skills` CLI. Install it first:

```bash
npm install -g skills
```

Verify installation:

```bash
skills --version
```

---

### For LLM Agents

If an LLM agent is helping with installation, follow these steps:

```bash
# Send to your LLM agent: read this guide and proceed with installation
curl -s https://raw.githubusercontent.com/akillness/skills-template/main/setup-all-skills-prompt.md
```

---

## Getting Started Guide

### Start with jeo (Recommended)

`jeo` automatically connects the entire workflow below:

| Phase | Tool | Role |
|-------|------|------|
| Plan | ralph + plannotator | AI creates plan, auto-installs `plannotator` if needed, then waits for approve/feedback |
| Execute | omc team / bmad | Claude Code requires `/omc:team`; other platforms use BMAD fallback |
| Verify | agent-browser | Browser behavior verification (default) |
| Cleanup | worktree-cleanup | Auto-cleanup after completion |

```bash
# Run in Claude Code
jeo "describe your task here"
```

---

### Choose by What You Need

#### Claude Code multi-agent orchestration → `omc`

```bash
npx skills add https://github.com/akillness/skills-template --skill omc
# Usage: /omc:team "task description"
```

> Details: [docs/omc/README.md](docs/omc/README.md)

#### OpenAI Codex CLI multi-agent → `oh-my-codex` (omx)

```bash
npx skills add https://github.com/akillness/skills-template --skill oh-my-codex
```

> Details: [.agent-skills/oh-my-codex/SKILL.md](.agent-skills/oh-my-codex/SKILL.md)

#### Gemini / Antigravity workflows → `ohmg`

```bash
npx skills add https://github.com/akillness/skills-template --skill ohmg
```

> Details: [.agent-skills/ohmg/SKILL.md](.agent-skills/ohmg/SKILL.md)

#### Structured phase-based development (Analysis→Planning→Design→Implementation) → `bmad-orchestrator`

```bash
npx skills add https://github.com/akillness/skills-template --skill bmad-orchestrator
# Usage: configure and use the bmad skill. /workflow-init
```

> Details: [docs/bmad/README.md](docs/bmad/README.md)

#### Loop until task is complete → `ralph`

```bash
npx skills add https://github.com/akillness/skills-template --skill ralph
# Usage: /ralph "fix all TypeScript errors" --max-iterations=100
```

> Details: [docs/ralph/README.md](docs/ralph/README.md)

#### Ralph automation permission profiles → `ralphmode`

```bash
npx skills add https://github.com/akillness/skills-template --skill ralphmode
# Usage: apply permission profiles for ralph automation in Claude Code / Codex CLI / Gemini CLI
```

> Details: [.agent-skills/ralphmode/SKILL.md](.agent-skills/ralphmode/SKILL.md)

#### Visual plan review + feedback loop → `plannotator`

```bash
npx skills add https://github.com/akillness/skills-template --skill plannotator
# Usage: auto-opens browser UI when planning — Approve or send feedback
```

> Details: [docs/plannotator/README.md](docs/plannotator/README.md)

#### Headless browser automation → `agent-browser`

```bash
npx skills add https://github.com/akillness/skills-template --skill agent-browser
```

> Details: [.agent-skills/agent-browser/SKILL.md](.agent-skills/agent-browser/SKILL.md)

#### Playwright-based browser control → `playwriter`

```bash
npx skills add https://github.com/akillness/skills-template --skill playwriter
```

> Details: [.agent-skills/playwriter/SKILL.md](.agent-skills/playwriter/SKILL.md)

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
| `ai-tool-compliance` | Automated P0/P1 compliance validation across 4 domains (security/permissions/cost/logging), binary scoring, deployment gates, history tracking | All platforms |
| `deployment-automation` | CI/CD & deployment automation | All platforms |
| `firebase-ai-logic` | Firebase AI Logic integration | Claude · Gemini |
| `genkit` | Firebase Genkit AI workflows | Claude · Gemini |
| `looker-studio-bigquery` | Looker Studio + BigQuery | All platforms |
| `monitoring-observability` | Monitoring & observability | All platforms |
| `security-best-practices` | Security best practices | All platforms |
| `system-environment-setup` | Environment configuration | All platforms |
| `vercel-deploy` | Vercel deployment | All platforms |
| `llm-monitoring-dashboard` | LLM usage monitoring dashboard — cost, token, latency tracking via Tokuin CLI + PM insights + user rankings | All platforms |

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
| `agentation` | Visual UI annotation — `npx skills add benjitaylor/agentation` → `/agentation` (Claude Code Official Skill) · `npx add-mcp` (auto-detects 9+ agents) · Local-first design (offline operation · session continuity) | Claude · Gemini · Codex · Cursor · Windsurf · OpenCode |
| `bmad-gds` | BMAD Game Development Studio — Pre-production through production with 6 specialized agents (Unity · Unreal · Godot) | Claude · Gemini · Codex · OpenCode |
| `bmad-idea` | BMAD Creative Intelligence Suite — brainstorming, design thinking, innovation strategy, problem-solving, storytelling | Claude · Gemini · Codex · OpenCode |
| `copilot-coding-agent` | GitHub Copilot Coding Agent — Issue → Draft PR automation | Claude · Codex |
| `environment-setup` | Environment setup | All platforms |
| `file-organization` | File & folder organization | All platforms |
| `git-submodule` | Git submodule management | All platforms |
| `git-workflow` | Git workflow management | All platforms |
| `jeo` | Integrated AI orchestration: ralph+plannotator → team/bmad → agent-browser verify → agentation(annotate) UI feedback → worktree cleanup | Claude · Codex · Gemini · OpenCode |
| `npm-git-install` | Install npm from GitHub | All platforms |
| `ohmg` | Multi-agent orchestration for Antigravity workflows | Claude · Gemini |
| `oh-my-codex` | Multi-agent orchestration for OpenAI Codex CLI *(in development)* | Codex |
| `omc` | oh-my-claudecode — Teams-first multi-agent orchestration | Claude |
| `opencontext` | AI agent persistent memory | All platforms |
| `plannotator` | Visual plan and diff review — annotate, approve, or request changes | Claude |
| `ralph` | Self-referential completion loop for multi-turn agents | Claude |
| `ralphmode` | Cross-platform Ralph automation permission profiles with mid-execution approval checkpoints (PreToolUse/BeforeTool hooks + prompt contracts) | Claude · Codex · Gemini · OpenCode |
| `skill-standardization` | SKILL.md standardization | All platforms |
| `vibe-kanban` | Kanban board for AI coding agents with git worktree automation | All platforms |
| `workflow-automation` | Workflow automation | All platforms |

---

## Featured Tools

These tools have full documentation in `docs/` and dedicated skills in `.agent-skills/`.

### plannotator — Interactive Plan & Diff Review
> **Purpose**: Visual plan review and feedback loop before execution | **Platforms**: Claude · Codex · Gemini · OpenCode | **Status**: v0.9.0
> Keyword: `plan` (alias: `planno`) | [Docs](docs/plannotator/README.md) | [GitHub](https://github.com/backnotprop/plannotator)

Visual browser UI for annotating AI agent plans before coding. Works with **Claude Code**, **OpenCode**, **Gemini CLI**, and **Codex CLI**. Approve plans or send structured feedback in one click.

Validated in-session with Playwright: Approve + feedback loops confirmed across all four platforms. See `docs/plannotator/README.md` for the verified python3 stdin pattern (avoid raw `echo`/heredoc for plan submission).

```bash
bash scripts/install.sh --all   # Install + configure all AI tools at once
```

Path resolution behavior for skill loading:
- Absolute skill paths are used directly (e.g., `/Users/me/.agent-skills/plannotator`)
- Relative skill paths are resolved: configured skills directory → global `~/.agent-skills`

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

| Symptom | Cause | Fix |
|---------|-------|-----|
| Browser opens twice | Duplicate `open` call in `plannotator-launch.sh` | Remove `open` from port-detection loop in hook script — plannotator self-opens browser |
| Feedback not received (Codex/Gemini/OpenCode) | Running with `&` background — agent doesn't wait for result | Run blocking (no `&`), then read `/tmp/plannotator_feedback.txt` |
| Codex startup failure (`invalid type: map, expected a string`) | `developer_instructions` declared as table (`[developer_instructions]`) in `~/.codex/config.toml` | Re-run `bash .agent-skills/jeo/scripts/setup-codex.sh` and verify `developer_instructions = "..."` top-level string format |

---

### vibe-kanban — AI Agent Kanban Board
> **Purpose**: Visual progress tracking for parallel agents | **Platforms**: All | **Status**: stable
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
> **Purpose**: Clarify requirements before coding → persistent loop until verification passes | **Platforms**: Claude · Gemini · Codex · OpenCode | **Status**: stable v3.0.0
> Keyword: `ralph`, `ooo` | [GitHub](https://github.com/Q00/ouroboros)

> *Stop prompting. Start specifying. The boulder never stops.*

Ouroboros-based specification-first workflow. Expose hidden assumptions via Socratic interview, crystallize into an immutable spec → Double Diamond execution → 3-stage verification → evolutionary loop until ontology converges.

```bash
# Clarify requirements
ooo interview "I want to build a task management CLI"
ooo seed                     # Generate YAML spec (Ambiguity ≤ 0.2 gate)
ooo run                      # Execute via Double Diamond
ooo evaluate <session_id>    # 3-stage verification

# Persistent loop until verification passes
ooo ralph "fix all failing tests"
```

| Command | Role |
|---------|------|
| `ooo interview` | Socratic questioning → Ambiguity ≤ 0.2 |
| `ooo seed` | Crystallize YAML spec |
| `ooo run` | Double Diamond execution |
| `ooo evaluate` | Mechanical → Semantic → Consensus 3-stage verification |
| `ooo evolve` | Evolutionary loop (Similarity ≥ 0.95 convergence) |
| `ooo ralph` | Persistent loop until verification passes |
| `ooo unstuck` | When blocked — 5-persona lateral thinking |

Codex setup:

```bash
bash <your-agent-skills>/ralph/scripts/setup-codex-hook.sh
```

---

### omc — oh-my-claudecode
> **Purpose**: Claude Code multi-agent team orchestration | **Platforms**: Claude | **Status**: stable
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
> **Purpose**: Phase-based AI development: Analysis → Planning → Design → Implementation | **Platforms**: Claude | **Status**: in development v1.1.0
> Keyword: `bmad` | [Docs](docs/bmad/README.md)

Phase-based workflow (Analysis → Planning → Solutioning → Implementation) for disciplined AI-assisted development. Automatically adapts to project scope (Level 0–4).

> Note: This is primarily a Claude Code native workflow. For Codex/OpenCode-based use, combine with `omx`/`ohmg` orchestration.

```bash
npx skills add https://github.com/akillness/skills-template --skill bmad-orchestrator
# Then in Claude Code:
# configure and use the bmad skill. remember it.
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
| **TOON Format Injection** | Auto-inject skill context across all platforms — Claude Code hooks / Gemini includeDirectories / Codex static catalog |

---

### jeo — Integrated Agent Orchestration
> **Purpose**: Full workflow automation integration | **Platforms**: Claude · Codex · Gemini · OpenCode | **Status**: stable
> Keyword: `jeo` · `annotate` · `UI검토` | Platforms: Claude Code · Codex CLI · Gemini CLI · OpenCode

Complete automated orchestration flow: Plan (ralph+plannotator) → Execute (team/bmad) → Browser verify (agent-browser) → UI feedback (agentation/annotate) → Cleanup (worktree cleanup).

If `plannotator` is missing at PLAN time, `jeo` now auto-runs `bash scripts/ensure-plannotator.sh` and proceeds only after the CLI is installed and visible in `PATH`.
In Claude Code, `jeo` requires team mode and must execute through `/omc:team`; it does not degrade to a single-agent `/ralph` path anymore.

```bash
bash scripts/install.sh --all   # Full installation
```

| Phase | Tool | Description |
|-------|------|-------------|
| Plan | ralph + plannotator | Visual plan review → Approve/Feedback |
| Execute | omc team / bmad | Claude Code requires `/omc:team`; other platforms use BMAD fallback |
| Verify | agent-browser | Browser behavior verification (default) |
| Verify UI | agentation (**annotate**) | UI annotation watch loop — pre-flight → ack→fix→resolve→re-snapshot |
| Cleanup | worktree-cleanup.sh | Auto worktree cleanup after completion |

---

## TOON Format Injection

> **Purpose**: Auto-inject skill context into every prompt | **Platforms**: Claude Code · Codex CLI · Gemini CLI | **Status**: stable v1.0.0

TOON (Token-Oriented Object Notation) compresses the skill catalog and auto-injects it into every AI tool prompt. 40-50% token savings vs JSON/Markdown. Designed and implemented by a 6-person ultrateam (QA · LLM Expert · Skill Expert · ClaudeCode · Codex · Gemini-CLI).

### Two-Tier Architecture

- **Tier 1 (always injected)**: Skill catalog index (~875-3,500 tokens) — skill names + descriptions + tags injected every prompt
- **Tier 2 (on-demand)**: Individual SKILL.toon full content (~292 tokens/skill, max 3) — auto-loaded on skill name/tag detection

> Injecting all 71 skills simultaneously (~20,700 tokens) is prohibited. Tier 1 + on-demand max 3 keeps context cost below 5%.

### Platform Implementations

| Platform | File | Mechanism | Performance |
|----------|------|-----------|-------------|
| **Claude Code** | `~/.claude/hooks/toon-inject.mjs` | `UserPromptSubmit` hook — Node.js, 3-tier keyword matching, symlink traversal | 26-37ms |
| **Gemini CLI** | `~/.gemini/hooks/toon-skill-inject.sh` | `includeDirectories` session-start load + `AfterAgent` refresh hook | ~0.1s |
| **Codex CLI** | `~/.codex/skills-toon-catalog.toon` | Static catalog + `notify-dispatch.py` + 2-turn sidecar pattern | 0ms (static) |

> **Why Node.js**: `~/.claude/skills/` is a symlink to `~/.agents/skills/`. Python `Path.rglob()` does not follow symlinks and returns 0 results. Node.js `readdirSync` traverses transparently.

### TOON Format Basics

```
N:skill-name  D:description  G:tag1 tag2 tag3
U[n]: use cases · S[n]{n,action,details}: steps · R[n]: rules · E[n]{desc,in,out}: examples
```

Full configuration: [bmad-orchestrator SKILL.md — TOON Format Integration](.agent-skills/bmad-orchestrator/SKILL.md)

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
├── README.md           ← English (default)
└── README.ko.md        ← 한국어
```

---

## Related Docs

| Tool | Keyword | Doc |
|------|---------|-----|
| plannotator | `plan` | [docs/plannotator/README.md](docs/plannotator/README.md) |
| vibe-kanban | `kanbanview` | [docs/vibe-kanban/README.md](docs/vibe-kanban/README.md) |
| ralph | `ralph` | [docs/ralph/README.md](docs/ralph/README.md) |
| omc | `omc` | [docs/omc/README.md](docs/omc/README.md) |
| bmad-orchestrator | `bmad` | [docs/bmad/README.md](docs/bmad/README.md) |
| jeo | `jeo` · `annotate` | [.agent-skills/jeo/SKILL.md](.agent-skills/jeo/SKILL.md) |

---

## Changelog

**v2026-03-09 (latest)**:
- **jeo: Gemini/Antigravity repeated plannotator call fix**: `plannotator-plan-loop.sh` now writes `plan_approved=true/false` and `phase=execute` to `jeo-state.json` after approval or feedback. `SKILL.md` PLAN bash block now has a GUARD that reads `jeo-state.json` and exits immediately if `plan_approved=true`, preventing re-invocation across turns in hook-based environments (Gemini CLI / Antigravity). `setup-gemini.sh` AfterAgent hook logs result (approved/feedback/bind-blocked) explicitly after the loop script completes.
- **jeo: Codex config.toml stray quote fix on re-run**: `setup-codex.sh` now guards the legacy JEO content strip regex so it only fires when no `developer_instructions = """` block exists, preventing the closing `"""` from being consumed on subsequent runs. Post-write TOML validation added via `tomllib`; on parse failure, auto-strips standalone `"` lines before saving.
- **setup guides sync**: `setup-all-skills-prompt.md` and `setup-all-skills-prompt.ko.md` updated with Claude Code team mode requirement note and plannotator auto-install behavior in Step 1 and keyword reference table.

**v2026-03-08**:
- **ralphmode v0.2.0: Mid-Execution Approval Checkpoints**: Added per-platform dynamic checkpoint patterns for blocking dangerous operations during ralph/jeo runs. Claude Code: `PreToolUse` hook with `ralph-safety-check.sh` (exit 2 block). Gemini CLI: `BeforeTool` hook with `ralph-tier1-check.sh` (non-zero exit block; stderr forwarded to agent's next turn). Codex CLI: `approval_policy="unless-allow-listed"` + `CHECKPOINT_NEEDED` prompt contract. OpenCode: prompt contract in `opencode.json` instructions. Tier 1/2/3 dangerous operation classification table and full hook script templates added to `permission-profiles.md`. Platform summary table updated with mid-execution blocking column and OpenCode row.
- **jeo: plannotator auto-install before PLAN**: `jeo` now auto-runs `bash scripts/ensure-plannotator.sh` when `plannotator` is missing, so the PLAN gate installs the CLI first and only proceeds after the binary is available. `plannotator-plan-loop.sh` and `install.sh` now also fail fast if installation does not actually leave a runnable `plannotator` in `PATH`
- **jeo: Claude Code now requires team mode**: In Claude Code, `jeo` no longer falls back to single-agent execution. EXECUTE must use `/omc:team`, and `check-status.sh` now fails when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is not configured
- **jeo: plannotator Claude Code invocation fix (P0)**: `plannotator` is a hook-only binary — calling it via MCP tool or CLI always fails. Removed incorrect `submit_plan` MCP tool instruction from `jeo/SKILL.md` (both deployed and source). Replaced with correct `EnterPlanMode` → write plan → `ExitPlanMode` hook flow. Added pre-flight bash block platform note (Codex/Gemini/OpenCode only). Updated `bmad-orchestrator/SKILL.md` to clarify Claude Code vs OpenCode invocation methods. Added troubleshooting entry for Claude Code plannotator
- **jeo: Gemini CLI plannotator feedback wait fix**: AfterAgent hooks now include `timeout: 1800` (30 min) for plannotator blocking review. Old-format hook entries (flat `{"type":"command",...}` without `matcher`/`hooks` wrapper) are auto-migrated to new format on setup re-run. Removed invalid `PermissionRequest.ExitPlanMode` from Gemini settings (Claude Code-only event)
- **jeo: Claude Code hooks format fix**: `setup-claude.sh` now creates `UserPromptSubmit` hooks in the new matcher format and auto-migrates old-format entries, fixing the `hooks: Expected array, but received undefined` settings error after installation

**v2026-03-06**:
- **TOON Format Cross-Platform Hook Integration**: Designed and implemented by a 6-person ultrateam (QA · LLM Expert · Skill Expert · ClaudeCode · Codex · Gemini-CLI). Claude Code: `~/.claude/hooks/toon-inject.mjs` Node.js hook (symlink traversal, 3-tier keyword matching, 26-37ms). Gemini CLI: `~/.gemini/hooks/toon-skill-inject.sh` + `includeDirectories` + `AfterAgent` hook. Codex CLI: static catalog (`skills-toon-catalog.toon`, 62 skills) + `notify-dispatch.py` + 2-turn sidecar pattern
- **bmad-orchestrator SKILL.md TOON Integration section**: Full two-tier architecture documentation (Tier 1 catalog ~875-3,500 tokens always injected / Tier 2 SKILL.toon on-demand max 3)
- **71 SKILL.toon full validation**: All skills verified and corrected for TOON format compliance

**v2026-03-06 (bug fixes)**:
- **jeo + bmad-orchestrator comprehensive fixes**: Schema alignment, graceful degradation, session-isolated paths
  - Removed zombie `worktrees` field from jeo state schema; added `retry_count`, `last_error`, `checkpoint` error recovery fields
  - Fixed `TEAM_AVAILABLE_BOOL` export for python3 subshell inheritance
  - Session-isolated plannotator feedback path via `hashlib.md5`
  - Replaced `exit 1` with graceful skip → CLEANUP on agentation failure
  - bmad-orchestrator v1.0.0 → v1.1.0; removed unrelated TOON section (~232 lines)
  - `phase-gate-review.sh`: multi-tier `find_workflow_name()` for hyphenated workflow names
  - `check-status.sh`: fixed nested while-loop stdin consumption via python3 subprocess

**v2026-03-05**:
- **jeo: state file guard bug fix (P0)**: Fixed bug where AfterAgent hook incorrectly ran plannotator when `jeo-state.json` was missing
- **jeo: agent execution protocol added (P1)**: Inserted `## 0. Agent Execution Protocol` section in `SKILL.md`. STEP 0–4 imperative pseudocode
- **skills-lock.json: dependency spec added (P1)**: Registered `plannotator` + `agentation` as required_by jeo
- **agentation v1.1.0 installation improvements**: Claude Code Official Skill + Universal `npx add-mcp` + Local-first architecture documentation

**v2026-03-04**:
- **jeo annotate integration (v2)**: VERIFY_UI keyword `agentui` → `annotate`. Phase guard resolves plannotator-agentation hook conflicts. Pre-flight 3-step check, RE-SNAPSHOT verification
- **ralph v3.0.0**: Full rewrite based on [Q00/ouroboros](https://github.com/Q00/ouroboros). Interview→Seed→Execute→Evaluate→Evolve, 9 agents, Ambiguity ≤ 0.2 gate, Similarity ≥ 0.95 convergence
- **setup-all-skills-prompt clean reinstall**: Auto-remove existing directories before recreating

**v2026-03-03 (update)**:
- **bmad-gds**: New skill — BMAD Game Development Studio. 5-stage pipeline, 6 specialist agents (Unity/Unreal/Godot)
- **bmad-idea**: New skill — BMAD Creative Intelligence Suite. 5 workflows, 5 named agents
- **ai-tool-compliance P1 expansion**: Added `--include-p1` option, `p1_maturity_score` output, CI toggle

**v2026-03-03**:
- **ai-tool-compliance**: New skill — Automated P0/P1 compliance validation. 4-domain binary scoring (security 40/permissions 25/cost 20/logging 15), GitHub Actions gate, history tracking

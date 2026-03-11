# Agent Skills

> 🌐 Language / 언어: **English** | **[한국어](README.ko.md)**

> v2026-03-11 · **79 Skills** · **TOON Format** · **Flat Skill Layout**

[![GitHub Releases](https://img.shields.io/badge/GitHub-Releases-blue)](https://github.com/supercent-io/skills-template/releases)
[![Skills](https://img.shields.io/badge/Skills-79-brightgreen)](#skills-list-79-total)
[![BMAD Deploy Version](https://img.shields.io/badge/BMAD-1.1.0-orange)](docs/bmad/README.md)

---

## Contents

- [Quick Start](#quick-start)
- [What's New](#whats-new-in-v2026-03-11)
- [Installation](#installation)
- [Getting Started Guide](#getting-started-guide)
- [Skills List (79)](#skills-list-79-total)
- [Featured Tools](#featured-tools)
- [TOON Format Injection](#toon-format-injection)
- [Structure](#structure)
- [Recommended Harness OSS](#recommended-harness-oss)
- [Related Docs](#related-docs)

---

## Quick Start (For LLM Agents)

> **Prerequisite**: Install `skills` CLI before running any `npx skills add` commands.
>
> ```bash
> npm install -g skills
> ```

```bash
# Send to your LLM agent: read this guide and proceed with installation
curl -s https://raw.githubusercontent.com/supercent-io/skills-template/main/setup-all-skills-prompt.md
```

> More skill installs → [Installation](#installation) | Platform-specific guides → [Getting Started](#getting-started-guide)

---

## What's New in v2026-03-11

| Change | Details |
|--------|---------|
| **jeo v1.3.0: Claude Code plan gate + agentation submit hook** | Two new Python hooks installed by `setup-claude.sh`. `claude-plan-gate.py`: SHA-256 hashes plan content at `ExitPlanMode`; skips plannotator if the same plan was already reviewed (terminal status match), resets the gate when a revised plan is detected. `claude-agentation-submit-hook.py`: `UserPromptSubmit` hook that only surfaces pending agentation annotations when a submit-style prompt arrives during `VERIFY_UI` phase (polls `localhost:4747/pending`). `setup-claude.sh` now registers both hooks, the agentation MCP server, and `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. |
| **skill-standardization v2.0: evals + validate_skill.sh** | Updated to reference the agentskills.io specification. Added `evals/evals.json` support (2–5 test cases per skill) and `scripts/validate_skill.sh` for automated spec validation (checks name, description length, allowed-tools format, file length). Trigger updated to include `"add evals to skill"`. |
| **jeo v1.2.3: plannotator-plan-loop.sh all-platform hardening** | Cross-platform temp dir (`TMPDIR`/`TMP`/`TEMP` fallback), dedicated port `PLANNOTATOR_PORT=47291` (IANA unassigned), `probe_plannotator_port()` (rc=0 free / rc=1 EADDRINUSE / rc=2 sandbox) + `wait_for_listen()` with `/dev/tcp` primary + Python3 fallback, background PID tracking with 2-phase monitoring (STARTING → LISTENING), browser-crash retry up to 3 times, structured `jeo-blocked.json` on exhaustion in non-TTY environments. |
| **survey: cross-platform landscape scan added** | Added `survey`, a platform-neutral research skill inspired by `groundwork`. It keeps the 4-lane discovery flow, writes shared artifacts to `.survey/{slug}/`, and adds a Claude/Codex/Gemini abstraction layer for `settings`, `rules`, and `hooks`, bringing the repository from 76 to **77 skills**. |
| **presentation-builder: slides-grab workflow adopted** | `presentation-builder` now uses `slides-grab` for HTML-first deck creation, visual editing, validation, and PPTX/PDF export. Removed duplicate `pptx-presentation-builder`, bringing the repository from 77 to **76 skills**. |
| **jeo v1.2.2: Codex plannotator blocking wait fix** | `plannotator-plan-loop.sh` now writes `plan_gate_status` (`approved`/`feedback_required`/`infrastructure_blocked`) to `jeo-state.json` on every exit. `jeo-notify.py` gains `write_plan_gate_result()` that persists gate results back to state. `jeo.md` prompt and `SKILL.md` gain **Conversation Approval Mode** for exit 32: agent outputs plan.md inline and waits for explicit user approval rather than skipping the gate. |
| **jeo v1.2.1: Gemini/Antigravity repeated plannotator call fix** | `plannotator-plan-loop.sh` now writes `plan_approved` + `phase` to `jeo-state.json` on approval. SKILL.md PLAN block now has a GUARD that reads `jeo-state.json` and skips plannotator if already approved in a previous turn. Prevents infinite re-invocation in hook-based environments. |
| **jeo v1.2.1: Claude Code now requires team mode** | In Claude Code, `jeo` no longer falls back to single-agent execution. EXECUTE must use `/omc:team`. |
| **jeo v1.2.1: plannotator Claude Code fix (P0)** | `plannotator` is hook-only in Claude Code. Removed non-existent `submit_plan` MCP tool call; replaced with correct `EnterPlanMode` → write plan → `ExitPlanMode` hook flow. `bmad-orchestrator/SKILL.md` updated with platform-specific clarifications. |
| **jeo v1.2.1: plannotator auto-install before PLAN** | `jeo` now auto-runs `bash scripts/ensure-plannotator.sh` when `plannotator` is missing. Dynamic script path discovery block added to PLAN pre-flight. |
| **ralphmode v0.2.0: Mid-Execution Approval Checkpoints** | Added Step 6 with platform-specific dangerous operation blocking. Claude Code `PreToolUse` hook (exit 2 block) + Gemini CLI `BeforeTool` hook (non-zero exit block) + Codex CLI `approval_policy="unless-allow-listed"` + OpenCode prompt contract. Tier 1/2/3 classification table included. |
| **jeo v1.2.1: Codex config.toml stray quote fix** | `setup-codex.sh` guards the legacy JEO strip regex — only runs when no `developer_instructions = """` block exists, preventing the closing `"""` from being consumed on re-runs. |
| **jeo v1.2.1: Gemini CLI plannotator feedback wait fix** | AfterAgent hooks now include `timeout: 1800` for plannotator. Old-format hooks without `matcher`/`hooks` wrapper are auto-migrated. |
| **jeo v1.2.1: Claude Code hooks format fix** | Fixed `UserPromptSubmit` hooks to use new matcher format (`{"matcher": "*", "hooks": [...]}`). `setup-claude.sh` now auto-migrates old-format entries on re-run. |
| **bmad-orchestrator: English localization** | Korean sections translated to English for consistency across all skill files. |

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
curl -s https://raw.githubusercontent.com/supercent-io/skills-template/main/setup-all-skills-prompt.md
```

---

## Getting Started Guide

### Start with jeo (Recommended)

`jeo` automatically connects the entire workflow below:

| Phase | Tool | Role |
|-------|------|------|
| Plan | ralph + plannotator | AI creates plan, you approve or give feedback |
| Execute | omc team / bmad | Parallel agents write code |
| Verify | agent-browser | Browser behavior verification (default) |
| Cleanup | worktree-cleanup | Auto-cleanup after completion |

```bash
# Run in Claude Code
jeo "describe your task here"
```

---

### Choose by What You Need

#### Cross-platform problem-space scan before planning → `survey`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill survey
# Usage: survey "problem, idea, or capability to research"
```

> Details: [.agent-skills/survey/SKILL.md](.agent-skills/survey/SKILL.md)

#### Claude Code multi-agent orchestration → `omc`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill omc
# Usage: /omc:team "task description"
```

> Details: [docs/omc/README.md](docs/omc/README.md)

#### OpenAI Codex CLI multi-agent → `omx`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill omx
```

> Details: [.agent-skills/omx/SKILL.md](.agent-skills/omx/SKILL.md)

#### Gemini / Antigravity workflows → `ohmg`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill ohmg
```

> Details: [.agent-skills/ohmg/SKILL.md](.agent-skills/ohmg/SKILL.md)

#### Structured phase-based development (Analysis→Planning→Design→Implementation) → `bmad-orchestrator`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator
# Usage: configure and use the bmad skill. /workflow-init
```

> Details: [docs/bmad/README.md](docs/bmad/README.md)

#### Loop until task is complete → `ralph`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill ralph
# Usage: /ralph "fix all TypeScript errors" --max-iterations=100
```

> Details: [docs/ralph/README.md](docs/ralph/README.md)

#### Ralph automation permission profiles → `ralphmode`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill ralphmode
# Usage: apply permission profiles for ralph automation in Claude Code / Codex CLI / Gemini CLI
```

> Details: [.agent-skills/ralphmode/SKILL.md](.agent-skills/ralphmode/SKILL.md)

#### Visual plan review + feedback loop → `plannotator`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill plannotator
# Usage: auto-opens browser UI when planning — Approve or send feedback
```

> Details: [docs/plannotator/README.md](docs/plannotator/README.md)

#### Headless browser automation → `agent-browser`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill agent-browser
```

> Details: [.agent-skills/agent-browser/SKILL.md](.agent-skills/agent-browser/SKILL.md)

#### Playwright-based browser control → `playwriter`

```bash
npx skills add https://github.com/supercent-io/skills-template --skill playwriter
```

> Details: [.agent-skills/playwriter/SKILL.md](.agent-skills/playwriter/SKILL.md)

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
| `frontend-design-system` | Production-grade UI design with design tokens, layout rules, motion guidance, and accessibility | All platforms |
| `react-best-practices` | React & Next.js best practices | All platforms |
| `responsive-design` | Responsive web design | All platforms |
| `state-management` | State management patterns | All platforms |
| `ui-component-patterns` | UI component patterns | All platforms |
| `vercel-react-best-practices` | React & Next.js performance optimization from Vercel Engineering | Claude · Gemini · Codex |
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
| `presentation-builder` | Build editable presentations with slides-grab, including visual review and PPTX/PDF export | All platforms |
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
| `image-generation-mcp` | Image generation via MCP (Gemini/compatible) with structured prompts, ratios, and validation | All platforms |
| `pollinations-ai` | Free image generation via Pollinations.ai *(in development)* | All platforms |
| `remotion-video-production` | Programmable video production with Remotion — scene planning, asset orchestration, validation gates | All platforms |
| `video-production` | Video production workflows *(in development)* | All platforms |

### Marketing (2)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `marketing-automation` | Marketing automation *(in development)* | All platforms |
| `marketing-skills-collection` | Marketing deliverables across CRO, copywriting, SEO, analytics, and growth (23 sub-skills) | All platforms |

### Utilities (24)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `agent-browser` | Fast headless browser CLI for AI agents | All platforms |
| `agentation` | Visual UI annotation — `npx skills add benjitaylor/agentation` → `/agentation` (Claude Code Official Skill) · `npx add-mcp` (auto-detects 9+ agents) · Local-first design (offline operation · session continuity) | Claude · Gemini · Codex · Cursor · Windsurf · OpenCode |
| `bmad-gds` | BMAD Game Development Studio — Pre-production through production with 6 specialized agents (Unity · Unreal · Godot) | Claude · Gemini · Codex · OpenCode |
| `bmad-idea` | BMAD Creative Intelligence Suite — brainstorming, design thinking, innovation strategy, problem-solving, storytelling | Claude · Gemini · Codex · OpenCode |
| `copilot-coding-agent` | GitHub Copilot Coding Agent — Issue → Draft PR automation | Claude · Codex |
| `environment-setup` | Environment setup | All platforms |
| `fabric` | AI prompt orchestration CLI using reusable Patterns — YouTube summarization, document analysis, content extraction via 200+ Patterns and 15+ AI providers | All platforms |
| `file-organization` | File & folder organization | All platforms |
| `git-submodule` | Git submodule management | All platforms |
| `git-workflow` | Git workflow management | All platforms |
| `jeo` | Integrated AI orchestration: ralph+plannotator → team/bmad → agent-browser verify → agentation(annotate) UI feedback → worktree cleanup | Claude · Codex · Gemini · OpenCode |
| `npm-git-install` | Install npm from GitHub | All platforms |
| `ohmg` | Multi-agent orchestration for Antigravity workflows | Claude · Gemini |
| `omx` | Multi-agent orchestration for OpenAI Codex CLI *(in development)* | Codex |
| `omc` | oh-my-claudecode — Teams-first multi-agent orchestration | Claude |
| `opencontext` | AI agent persistent memory | All platforms |
| `plannotator` | Visual plan and diff review — annotate, approve, or request changes | Claude |
| `playwriter` | Playwright-based browser automation via Chrome extension + MCP/CLI — connects to your running browser with existing logins/cookies for authenticated, stateful web automation | All platforms |
| `ralph` | Self-referential completion loop for multi-turn agents | Claude |
| `ralphmode` | Cross-platform Ralph automation permission profiles for Claude Code, Codex CLI, and Gemini CLI | Claude · Codex · Gemini |
| `skill-standardization` | SKILL.md standardization | All platforms |
| `survey` | Cross-platform landscape scan before planning or implementation; saves shared discovery artifacts and normalizes agent-platform differences into settings/rules/hooks | Claude · Codex · Gemini · OpenCode |
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
npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator
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

```bash
bash scripts/install.sh --all   # Full installation
```

| Phase | Tool | Description |
|-------|------|-------------|
| Plan | ralph + plannotator | Visual plan review → Approve/Feedback |
| Execute | omc team / bmad | Parallel agent execution |
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

> Injecting all 76 skills simultaneously (~22,100 tokens) is prohibited. Tier 1 + on-demand max 3 keeps context cost below 5%.

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
│   └── [79 skill folders]
├── docs/
│   ├── bmad/           ← bmad-orchestrator harness guide
│   ├── bmad-gds/       ← BMAD Game Development Studio guide
│   ├── bmad-idea/      ← BMAD Creative Intelligence Suite guide
│   ├── harness/        ← recommended harness OSS guide (EN + KO)
│   ├── omc/            ← oh-my-claudecode guide
│   ├── plannotator/    ← plan & diff review (v0.9.0, multi-tool)
│   ├── ralph/          ← completion loop guide
│   └── vibe-kanban/    ← AI Kanban board guide
├── install.sh / flatten_skills.py
├── README.md           ← English (default)
└── README.ko.md        ← 한국어
```

---

## Recommended Harness OSS

Open-source agent harnesses and orchestration frameworks that pair well with Agent Skills. Sorted by GitHub stars (2026-03-10). → **[Full guide with install & integration notes](docs/harness/README.md)**

| Repository | Stars | Forks | Description |
|-----------|------:|------:|-------------|
| [AutoGPT](https://github.com/Significant-Gravitas/AutoGPT) | 182k | 46.2k | Accessible AI platform for building and running continuous agents |
| [superpowers](https://github.com/obra/superpowers) | 75.7k | 5.9k | Agentic skills framework & software development methodology |
| [AutoGen](https://github.com/microsoft/autogen) | 55.4k | 8.3k | Microsoft's multi-agent conversation & agentic AI programming framework |
| [CrewAI](https://github.com/crewAIInc/crewAI) | 45.7k | 6.1k | Framework for orchestrating role-playing autonomous AI agents |
| [smolagents](https://github.com/huggingface/smolagents) | 25.9k | 2.4k | HuggingFace's barebones code-thinking agent library |
| [agency-agents](https://github.com/msitarzewski/agency-agents) | 21.2k | 3.3k | 61 specialized AI agents organized across 9 divisions |
| [bkit-claude-code](https://github.com/popup-studio-ai/bkit-claude-code) | 366 | 94 | PDCA methodology + CTO-led agent teams for Claude Code |

> Key strengths, install commands, and Agent Skills integration notes → [docs/harness/README.md](docs/harness/README.md)

---

## Related Docs

| Tool | Keyword | Doc |
|------|---------|-----|
| plannotator | `plan` | [docs/plannotator/README.md](docs/plannotator/README.md) |
| vibe-kanban | `kanbanview` | [docs/vibe-kanban/README.md](docs/vibe-kanban/README.md) |
| ralph | `ralph` | [docs/ralph/README.md](docs/ralph/README.md) |
| omc | `omc` | [docs/omc/README.md](docs/omc/README.md) |
| bmad-orchestrator | `bmad` | [docs/bmad/README.md](docs/bmad/README.md) |
| bmad-gds | `bmad-gds` | [docs/bmad-gds/README.md](docs/bmad-gds/README.md) |
| bmad-idea | `bmad-idea` | [docs/bmad-idea/README.md](docs/bmad-idea/README.md) |
| jeo | `jeo` · `annotate` | [.agent-skills/jeo/SKILL.md](.agent-skills/jeo/SKILL.md) |
| Recommended Harness OSS | — | [docs/harness/README.md](docs/harness/README.md) |


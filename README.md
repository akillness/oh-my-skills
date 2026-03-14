# Agent Skills

<div align="center">

[![Skills](https://img.shields.io/badge/Skills-71-blue?style=for-the-badge)](https://github.com/akillness/oh-my-skills)
[![Platform](https://img.shields.io/badge/Platform-Claude%20%7C%20Gemini%20%7C%20Codex%20%7C%20OpenCode-orange?style=for-the-badge)](https://github.com/akillness/oh-my-skills)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![BMAD](https://img.shields.io/badge/BMAD-1.1.0-purple?style=for-the-badge)](docs/bmad/README.md)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-orange?style=for-the-badge&logo=buy-me-a-coffee)](https://www.buymeacoffee.com/akillness3q)

**71 AI agent skills · TOON Format · Cross-platform**

[Quick Start](#-quick-start) · [Skills List](#-skills-list-71-total) · [Installation](#-installation) · [한국어](README.ko.md)

</div>

---

## 💡 What is Agent Skills?

**71 AI agent skills · TOON Format · Cross-platform**

Agent Skills is a curated collection of 71 AI agent skills for LLM-based development workflows. Built around the `jeo` orchestration protocol, it provides:
- Unified orchestration across Claude Code, Gemini CLI, OpenAI Codex, and OpenCode
- Plan → Execute → Verify → Cleanup automated pipelines
- Multi-agent team coordination with parallel execution

---

## 🚀 Quick Start

> **Prerequisite**: Install `skills` CLI before running `npx skills add`.
>
> ```bash
> npm install -g skills
> ```

```bash
# Send to your LLM agent — it will read and install automatically
curl -s https://raw.githubusercontent.com/akillness/oh-my-skills/main/setup-all-skills-prompt.md
```

| Platform | First Command |
|----------|--------------|
| Claude Code | `jeo "task description"` or `/omc:team "task"` |
| Gemini CLI | `/jeo "task description"` |
| Codex CLI | `/jeo "task description"` |
| OpenCode | `/jeo "task description"` |

---

## 🏗 Architecture

```mermaid
graph TD
    JEO["🎯 JEO\nCore Orchestration"] --> PLAN["📋 PLAN\nralph + plannotator"]
    JEO --> EXEC["⚡ EXECUTE\nteam / bmad"]
    JEO --> VERIFY["🔍 VERIFY\nagent-browser"]
    JEO --> UI["🎨 VERIFY_UI\nagentation"]
    JEO --> CLEAN["🧹 CLEANUP\nworktree"]

    PLAN --> OMC["omc\nClaude Code"]
    PLAN --> OHMG["ohmg\nGemini CLI"]
    PLAN --> OMX["omx\nCodex CLI"]

    SURVEY["🔭 survey"] -.-> JEO
    RALPH["🔄 ralph"] -.-> EXEC
    AUTORESEARCH["🔬 autoresearch"] -.-> EXEC
```

---

## 🆕 What's New in v2026-03-14

| Change | Details |
|--------|---------|
| **research-paper-writing: ML/CV/NLP paper writing skill** | Academic paper composition for Abstract, Introduction, Method, Experiments, Conclusion. Paragraph flow, claim-evidence alignment, pre-submission review. From Prof. Peng Sida's notes. 70 → **71 skills**. |
| **Removed ai-tool-compliance and llm-monitoring-dashboard** | Removed `ai-tool-compliance` (internal compliance automation) and `llm-monitoring-dashboard`. 72 → **70 skills**. |
| **Removed deprecated agent-development skills** | Removed `agent-configuration`, `agent-evaluation`, `agentic-development-principles`, `agentic-principles`, `agentic-workflow`. 80 → **72 skills**. |
| **Removed deprecated image/media skills** | Removed `image-generation`, `image-generation-mcp`, `pollinations-ai`. Use `remotion-video-production` / `video-production` for media. |
| **autoresearch: Karpathy autonomous ML experiment skill** | AI agent modifies `train.py`, runs 5-min GPU experiments, evaluates with `val_bpb`, ratchets improvements via git. Includes `scripts/` and `references/`. |
| **jeo v1.2.3: plannotator-plan-loop.sh all-platform hardening** | Cross-platform temp dir fallback, dedicated port `PLANNOTATOR_PORT=47291`, `probe_plannotator_port()` + `wait_for_listen()`, browser-crash retry up to 3 times, structured `jeo-blocked.json` output. |
| **survey: cross-platform landscape scan** | 4-lane discovery flow, artifacts to `.survey/{slug}/`, Claude/Codex/Gemini abstraction as `settings/rules/hooks`. |
| **presentation-builder: slides-grab workflow** | HTML-first deck creation, visual editing, PPTX/PDF export. Removed duplicate `pptx-presentation-builder`. |

---

## 📦 Installation

### Step 0: Install `skills` CLI

```bash
npm install -g skills
skills --version
```

### For LLM Agents

```bash
curl -s https://raw.githubusercontent.com/akillness/oh-my-skills/main/setup-all-skills-prompt.md
```

### Choose by Platform

#### Claude Code

```bash
npx skills add https://github.com/akillness/oh-my-skills \
  --skill jeo --skill omc --skill plannotator --skill agentation \
  --skill ralph --skill ralphmode --skill vibe-kanban
```

#### Gemini CLI

```bash
npx skills add https://github.com/akillness/oh-my-skills \
  --skill jeo --skill ohmg --skill ralph --skill ralphmode --skill vibe-kanban
gemini extensions install https://github.com/akillness/oh-my-skills
```

#### Codex CLI

```bash
npx skills add https://github.com/akillness/oh-my-skills \
  --skill jeo --skill omx --skill ralph --skill ralphmode
```

#### Platform-Specific Setup

```bash
# Claude Code — jeo hook setup
bash ~/.agent-skills/jeo/scripts/setup-claude.sh

# Gemini CLI — jeo hook setup
bash ~/.agent-skills/jeo/scripts/setup-gemini.sh

# oh-my-claudecode
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/omc:omc-setup
```

---

## 📚 Skills List (71 total)

> Full manifest: `.agent-skills/skills.json` · each folder's `SKILL.md`

### 🎯 Core Orchestration (10)

| Skill | Keyword | Platform | Description |
|-------|---------|----------|-------------|
| `jeo` | `jeo`, `annotate` | All | Integrated orchestration: PLAN→EXECUTE→VERIFY→CLEANUP |
| `omc` | `omc`, `autopilot` | Claude | 32-agent orchestration layer with model routing |
| `omx` | `omx` | Codex | Multi-agent orchestration for Codex CLI |
| `ohmg` | `ohmg` | Gemini | Antigravity multi-agent framework |
| `ralph` | `ralph`, `ooo` | All | Ouroboros specification-first + persistent completion loop |
| `ralphmode` | `ralphmode` | All | Automation permission profiles (sandbox-first, repo boundary) |
| `bmad-orchestrator` | `bmad` | Claude | Structured phase-based AI development |
| `bmad-gds` | `bmad-gds` | All | BMAD Game Development Studio (Unity · Unreal · Godot) |
| `bmad-idea` | `bmad-idea` | All | Creative intelligence — 5 specialist ideation agents |
| `survey` | `survey` | All | Pre-implementation landscape scan |

### 📋 Planning & Review (5)

| Skill | Keyword | Description |
|-------|---------|-------------|
| `plannotator` | `plan` | Visual browser plan/diff review — approve or send feedback |
| `agentation` | `annotate` | UI annotation → targeted agent code fixes |
| `agent-browser` | `agent-browser` | Headless browser verification for AI agents |
| `playwriter` | `playwriter` | Playwright automation connecting to live browser |
| `vibe-kanban` | `kanbanview` | Visual Kanban board with git worktree isolation |

### 🤖 Agent Development (2)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `prompt-repetition` | LLM accuracy via prompt repetition technique | All |
| `skill-standardization` | SKILL.md validation against Agent Skills spec | All |

### ⚙️ Backend (5)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `api-design` | REST/GraphQL API design | All |
| `api-documentation` | OpenAPI/Swagger docs generation | All |
| `authentication-setup` | JWT, OAuth, session management | All |
| `backend-testing` | Unit/integration/API test strategies | All |
| `database-schema-design` | SQL/NoSQL schema design | All |

### 🎨 Frontend (9)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `design-system` | Design tokens, layout rules, motion, accessibility | All |
| `frontend-design-system` | Production-grade UI with design tokens and accessibility | All |
| `react-best-practices` | React & Next.js performance optimization | All |
| `vercel-react-best-practices` | Vercel Engineering React & Next.js guidelines | Claude · Gemini · Codex |
| `responsive-design` | Mobile-first layouts and breakpoints | All |
| `state-management` | Redux, Context, Zustand patterns | All |
| `ui-component-patterns` | Reusable component libraries | All |
| `web-accessibility` | WCAG 2.1 compliance | All |
| `web-design-guidelines` | Web Interface Guidelines compliance review | All |

### 🔍 Code Quality (5)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `code-refactoring` | Code simplification and refactoring | All |
| `code-review` | Comprehensive code review with API contracts | All |
| `debugging` | Root cause analysis, regression isolation | All |
| `performance-optimization` | Speed, efficiency, scalability optimization | All |
| `testing-strategies` | Test pyramid, coverage, flaky-test hardening | All |

### 🏗 Infrastructure (10)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `deployment-automation` | CI/CD, Docker/Kubernetes, cloud infrastructure | All |
| `environment-setup` | Dev/staging/production environment config | All |
| `firebase-ai-logic` | Firebase AI Logic (Gemini) integration | Claude · Gemini |
| `genkit` | Firebase Genkit AI flows and RAG pipelines | Claude · Gemini |
| `looker-studio-bigquery` | Looker Studio + BigQuery dashboards | All |
| `monitoring-observability` | Health checks, metrics, log aggregation | All |
| `security-best-practices` | OWASP Top 10, RBAC, API security | All |
| `system-environment-setup` | Reproducible environment configuration | All |
| `vercel-deploy` | Vercel deployment automation | All |

### 📝 Documentation (5)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `changelog-maintenance` | Changelog management and versioning | All |
| `presentation-builder` | HTML slides with slides-grab, PPTX/PDF export | All |
| `research-paper-writing` | ML/CV/NLP academic paper writing — Abstract, Introduction, Method, Experiments, Conclusion; claim-evidence alignment, pre-submission review | All |
| `technical-writing` | Technical documentation and specs | All |
| `user-guide-writing` | User guides and tutorials | All |

### 📊 Project Management (4)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `sprint-retrospective` | Sprint retrospective facilitation | All |
| `standup-meeting` | Daily standup management | All |
| `task-estimation` | Story points, t-shirt sizing, planning poker | All |
| `task-planning` | Task breakdown and user stories | All |

### 🔭 Search & Analysis (5)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `autoresearch` | Autonomous ML experiments (Karpathy) — AI agent runs overnight GPU experiments, ratchets improvements via git | All |
| `codebase-search` | Codebase search & navigation | All |
| `data-analysis` | Dataset analysis, visualizations, statistics | All |
| `log-analysis` | Log analysis and incident debugging | All |
| `pattern-detection` | Pattern and anomaly detection | All |

### 🎬 Creative Media (2)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `remotion-video-production` | Programmable video production with Remotion | All |
| `video-production` | Produce programmable videos with Remotion — scene planning, asset orchestration | All |

### 📢 Marketing (2)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `marketing-automation` | 23 sub-skills: CRO, copywriting, SEO, analytics, growth | All |
| `marketing-skills-collection` | 23 sub-skills: CRO, copywriting, SEO, analytics, growth | All |

### 🔧 Utilities (9)

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `copilot-coding-agent` | GitHub Copilot Coding Agent — issue → Draft PR automation | Claude · Codex |
| `fabric` | AI prompt patterns — YouTube summaries, document analysis via 200+ Patterns | All |
| `file-organization` | File and folder organization | All |
| `git-submodule` | Git submodule management | All |
| `git-workflow` | Commit, branch, merge, PR workflows | All |
| `npm-git-install` | Install npm packages from GitHub | All |
| `opencontext` | Persistent memory and context management for AI agents | All |
| `workflow-automation` | Automate repetitive development workflows | All |

---

## 🧬 TOON Format Injection

TOON (Token-Oriented Object Notation) compresses the skill catalog and auto-injects it into every prompt. **40-50% token savings** vs JSON/Markdown.

| Platform | File | Mechanism |
|----------|------|-----------|
| Claude Code | `~/.claude/hooks/toon-inject.mjs` | `UserPromptSubmit` hook — 26-37ms |
| Gemini CLI | `~/.gemini/hooks/toon-skill-inject.sh` | `includeDirectories` session load |
| Codex CLI | `~/.codex/skills-toon-catalog.toon` | Static catalog |

- **Tier 1** (always): Skill catalog index (~875-3,500 tokens) — names + descriptions + tags
- **Tier 2** (on-demand): Individual SKILL.toon content (~292 tokens/skill, max 3)

---

## 🔮 Featured Tools

### jeo — Integrated Agent Orchestration
> Keyword: `jeo` · `annotate` | Platforms: Claude · Codex · Gemini · OpenCode

Complete automated pipeline: Plan (ralph+plannotator) → Execute (team/bmad) → Verify (agent-browser) → UI Feedback (agentation) → Cleanup.

| Phase | Tool | Description |
|-------|------|-------------|
| Plan | ralph + plannotator | Visual plan review → Approve/Feedback |
| Execute | omc team / bmad | Parallel agent execution |
| Verify | agent-browser | Browser behavior verification |
| Verify UI | agentation (`annotate`) | UI annotation → fix loop |
| Cleanup | worktree-cleanup.sh | Auto worktree cleanup |

### plannotator — Visual Plan Review
> Keyword: `plan` | [Docs](docs/plannotator/README.md) | [GitHub](https://github.com/backnotprop/plannotator)

Browser UI for annotating AI plans. Approve or send structured feedback in one click. Works with Claude Code, OpenCode, Gemini CLI, and Codex CLI.

```bash
bash scripts/install.sh --all
```

### ralph — Specification-First Development
> Keyword: `ralph`, `ooo` | [Docs](docs/ralph/README.md) | [GitHub](https://github.com/Q00/ouroboros)

Socratic interview → immutable spec → Double Diamond execution → 3-stage verification → loop until passed.

```bash
ooo interview "I want to build a task management CLI"
ooo seed && ooo run && ooo evaluate <session_id>
ooo ralph "fix all failing tests"
```

### vibe-kanban — AI Agent Kanban Board
> Keyword: `kanbanview` | [Docs](docs/vibe-kanban/README.md) | [GitHub](https://github.com/BloopAI/vibe-kanban)

Visual Kanban (To Do → In Progress → Review → Done) with parallel AI agents isolated via git worktrees.

```bash
npx vibe-kanban
```

---

## 🌐 Recommended Harness OSS

| Repository | Stars | Description |
|-----------|------:|-------------|
| [AutoGPT](https://github.com/Significant-Gravitas/AutoGPT) | 182k | Accessible AI platform for continuous agents |
| [AutoGen](https://github.com/microsoft/autogen) | 55.4k | Microsoft multi-agent conversation framework |
| [CrewAI](https://github.com/crewAIInc/crewAI) | 45.7k | Role-playing autonomous AI agent orchestration |
| [smolagents](https://github.com/huggingface/smolagents) | 25.9k | HuggingFace code-thinking agent library |
| [agency-agents](https://github.com/msitarzewski/agency-agents) | 21.2k | 61 specialized AI agents across 9 divisions |

> Install & integration notes → [docs/harness/README.md](docs/harness/README.md)

---

## 📁 Structure

```text
.
├── .agent-skills/          ← 71 skill folders (each with SKILL.md + SKILL.toon)
├── docs/                   ← detailed guides (bmad, omc, plannotator, ralph, ...)
├── install.sh
├── setup-all-skills-prompt.md
├── README.md               ← English (this file)
└── README.ko.md            ← 한국어
```

---

## 📖 Related Docs

| Tool | Keyword | Doc |
|------|---------|-----|
| `jeo` | `jeo`, `annotate` | [.agent-skills/jeo/SKILL.md](.agent-skills/jeo/SKILL.md) |
| `plannotator` | `plan` | [docs/plannotator/README.md](docs/plannotator/README.md) |
| `vibe-kanban` | `kanbanview` | [docs/vibe-kanban/README.md](docs/vibe-kanban/README.md) |
| `ralph` | `ralph` | [docs/ralph/README.md](docs/ralph/README.md) |
| `omc` | `omc` | [docs/omc/README.md](docs/omc/README.md) |
| `bmad-orchestrator` | `bmad` | [docs/bmad/README.md](docs/bmad/README.md) |
| Harness OSS | — | [docs/harness/README.md](docs/harness/README.md) |

---

## 📎 References

| Component | Source | License |
|-----------|--------|---------|
| `jeo` | Internal | MIT |
| `omc` | [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) | MIT |
| `ralph` | [Q00/ouroboros](https://github.com/Q00/ouroboros) | MIT |
| `plannotator` | [plannotator.ai](https://plannotator.ai) | MIT |
| `bmad` | [bmad-dev/BMAD-METHOD](https://github.com/bmad-dev/BMAD-METHOD) | MIT |
| `agentation` | [benjitaylor/agentation](https://github.com/benjitaylor/agentation) | MIT |
| `fabric` | [danielmiessler/fabric](https://github.com/danielmiessler/fabric) | MIT |
| `autoresearch` | Andrej Karpathy methodology | — |
| `research-paper-writing` | [Master-cai/Research-Paper-Writing-Skills](https://github.com/Master-cai/Research-Paper-Writing-Skills) | — |
| Agent Skills Spec | [agentskills.io](https://agentskills.io/specification) | — |

---

<div align="center">

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/akillness3q)

⭐ If this helps you, star the repository!

```bash
gh api --silent --method PUT /user/starred/akillness/oh-my-skills >/dev/null 2>&1 || true
```

</div>

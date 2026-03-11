# Recommended Harness OSS

> 🌐 Language: **English** | [한국어](README.ko.md)

A curated guide to open-source agent harnesses and orchestration frameworks that pair well with Agent Skills.
Sorted by GitHub stars (as of 2026-03-10).

---

## Comparison Table

| Repository | Stars | Forks | Description | Key Strengths |
|-----------|------:|------:|-------------|---------------|
| [AutoGPT](https://github.com/Significant-Gravitas/AutoGPT) | 182k | 46.2k | Accessible AI platform for building and running continuous agents | Platform-level agent management, Forge toolkit, no-code UI, benchmark system |
| [superpowers](https://github.com/obra/superpowers) | 75.7k | 5.9k | Agentic skills framework & software development methodology | Composable skill definitions, TDD-first, systematic workflow contracts, multi-agent compatibility |
| [AutoGen](https://github.com/microsoft/autogen) | 55.4k | 8.3k | Microsoft's multi-agent conversation & agentic AI programming framework | Layered API (Core/AgentChat/Extensions), AutoGen Studio no-code UI, MCP support, Magentic-One |
| [CrewAI](https://github.com/crewAIInc/crewAI) | 45.7k | 6.1k | Framework for orchestrating role-playing autonomous AI agents | Role-based orchestration, collaborative intelligence, independent Python framework |
| [smolagents](https://github.com/huggingface/smolagents) | 25.9k | 2.4k | HuggingFace's barebones code-thinking agent library | ~1,000 LOC core, model-agnostic, E2B/Docker sandbox, MCP + LangChain compatible |
| [agency-agents](https://github.com/msitarzewski/agency-agents) | 21.2k | 3.3k | 61 specialized AI agents organized across 9 divisions | Broad specialist roster, division-based organization, plug-and-play role definitions |
| [bkit-claude-code](https://github.com/popup-studio-ai/bkit-claude-code) | 366 | 94 | PDCA methodology + CTO-led agent teams for Claude Code | PDCA quality cycle, structured phase gates, auto documentation, Claude Code native |

---

## superpowers — Composable Skills Framework

> **GitHub**: [obra/superpowers](https://github.com/obra/superpowers) · ⭐ 75.7k · 🍴 5.9k

The closest in philosophy to Agent Skills. Built around composable, declarative skill definitions with emphasis on TDD and systematic development workflow contracts. Works across multiple coding agents including Claude Code and Codex CLI.

### Key Strengths

| Feature | Description |
|---------|-------------|
| Composable skills | Declarative skill definitions — conceptually similar to `SKILL.md` format |
| TDD-first | Test writing is enforced by the harness before any implementation |
| Multi-agent | Compatible with Claude Code, Codex CLI, and other coding agents |
| Workflow contracts | Systematic contracts prevent scope creep and agent drift |
| Minimal config | Convention over configuration — works out of the box |

### Install

```bash
git clone https://github.com/obra/superpowers ~/.superpowers
# Then follow setup instructions in the repo README
```

### Integration with Agent Skills

`superpowers` composable skill definitions can be loaded alongside Agent Skills. Use `jeo` for the orchestration layer and `superpowers` skills as composable primitives:

```bash
# Load superpowers skill context alongside Agent Skills
jeo "build a REST API using superpowers skill contracts"
```

---

## agency-agents — 61 Specialized Agent Roles

> **GitHub**: [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) · ⭐ 21.2k · 🍴 3.3k

A complete AI agency at your fingertips. 61 specialized AI agents organized across 9 divisions — from Frontend Wizards and Backend Engineers to Community Managers and QA Specialists. Each agent has a defined role, personality, and scope.

### Division Map

| Division | Example Agents |
|----------|---------------|
| Frontend | UI Wizard, Component Architect, CSS Specialist |
| Backend | API Engineer, Database Specialist, Security Auditor |
| DevOps | CI/CD Engineer, Infrastructure Architect, Cloud Specialist |
| QA | Test Engineer, Performance Analyst, Bug Hunter |
| Community | Reddit Ninja, Discord Manager, Content Strategist |
| Product | Product Manager, UX Researcher, Analytics Specialist |
| Data | Data Engineer, ML Specialist, Analytics Expert |
| Creative | Whimsy Injector, Design Thinker, Brand Voice |
| Meta | Reality Checker, Devil's Advocate, Synthesizer |

### Key Strengths

| Feature | Description |
|---------|-------------|
| 61 agents | Distinct personalities with clear role boundaries |
| 9 divisions | Structured organizational hierarchy |
| Platform-agnostic | Drop-in agent definitions for any LLM platform |
| Modular | Use any subset independently — no monolithic dependency |
| Ready to use | Pre-defined roles require no additional configuration |

### Install

```bash
git clone https://github.com/msitarzewski/agency-agents
# Copy agent definitions into your preferred agent platform's skill/prompt directory
```

### Integration with Agent Skills

Use `agency-agents` role definitions as persona overlays for `omc` team members:

```bash
# Assign specialized agency-agents roles to omc team agents
/omc:team "implement the checkout flow" --persona=frontend-wizard
```

---

## bkit-claude-code — PDCA for Claude Code

> **GitHub**: [popup-studio-ai/bkit-claude-code](https://github.com/popup-studio-ai/bkit-claude-code) · ⭐ 366 · 🍴 94

A Claude Code plugin implementing the Plan-Do-Check-Act (PDCA) quality cycle with CTO-led agent teams. Designed for AI-native development with structured phase gates, automatic documentation, and structured team hierarchy.

### PDCA Cycle

```
┌─────────────────────────────────────────────┐
│  PLAN   → Define objectives, assess risks    │
│  DO     → Execute with CTO-led agent teams   │
│  CHECK  → Validate against acceptance criteria│
│  ACT    → Document, retrospective, iterate   │
└─────────────────────────────────────────────┘
```

### Key Strengths

| Feature | Description |
|---------|-------------|
| PDCA harness | Quality gates at each phase prevent moving forward with unvalidated work |
| CTO-led teams | Hierarchical agent coordination with a CTO agent as orchestrator |
| Auto documentation | Generates structured documentation at each PDCA phase |
| Claude Code native | Built specifically for Claude Code's plugin system |
| Phase tracking | Persistent state tracks which PDCA phase the project is in |

### Install

```bash
# In Claude Code conversation
/plugin marketplace add https://github.com/popup-studio-ai/bkit-claude-code
/plugin install bkit-claude-code
```

### Integration with Agent Skills

`bkit-claude-code` and Agent Skills are complementary — use `bmad-orchestrator` for high-level phase gating and `bkit` for PDCA quality cycles:

```bash
# Example: bmad for structure + bkit PDCA for quality loop
jeo "implement user authentication" --harness=pdca
```

---

## AutoGPT — Continuous Agent Platform

> **GitHub**: [Significant-Gravitas/AutoGPT](https://github.com/Significant-Gravitas/AutoGPT) · ⭐ 182k · 🍴 46.2k

The most starred AI agent project. An accessible platform for building, deploying, and monitoring continuous AI agents. The modern version includes Forge (agent builder toolkit), Benchmark (evaluation system), and an Agent Management UI.

### Key Strengths

| Feature | Description |
|---------|-------------|
| Forge toolkit | Build custom agents with a standardized SDK |
| Benchmark | Built-in evaluation framework for agent performance |
| No-code UI | Visual agent management and monitoring dashboard |
| Plugin system | Extensible through a rich plugin ecosystem |
| Long-running | Designed for continuous, autonomous multi-step task execution |

### Install

```bash
git clone https://github.com/Significant-Gravitas/AutoGPT
cd AutoGPT
./run setup
```

---

## AutoGen — Microsoft Multi-Agent Framework

> **GitHub**: [microsoft/autogen](https://github.com/microsoft/autogen) · ⭐ 55.4k · 🍴 8.3k

Microsoft's production-grade multi-agent conversation framework. Features a layered architecture that supports everything from simple two-agent conversations to complex multi-agent pipelines with human oversight.

### Key Strengths

| Feature | Description |
|---------|-------------|
| Layered API | Core API (low-level) → AgentChat API → Extensions API |
| AutoGen Studio | No-code GUI for building and testing multi-agent workflows |
| MCP support | Native Model Context Protocol integration |
| Magentic-One | Pre-built multi-agent team for complex web/code tasks |
| Human-in-the-loop | First-class support for human oversight checkpoints |

### Install

```bash
pip install pyautogen
# or for latest features:
pip install "pyautogen[all]"
```

---

## CrewAI — Role-Based Agent Orchestration

> **GitHub**: [crewAIInc/crewAI](https://github.com/crewAIInc/crewAI) · ⭐ 45.7k · 🍴 6.1k

Framework for orchestrating role-playing autonomous AI agents that foster collaborative intelligence. Each agent has a role, goal, and backstory — they collaborate sequentially or in parallel to complete complex tasks.

### Key Strengths

| Feature | Description |
|---------|-------------|
| Role-based design | Each agent has a defined role, goal, and backstory |
| Collaborative | Agents share outputs and build on each other's work |
| Independent | Not tied to LangChain — standalone Python framework |
| High-level API | Simple crew + agent + task definition to get started |
| Flexible | Sequential, parallel, or hierarchical process execution |

### Install

```bash
pip install crewai
# with tools support:
pip install crewai crewai-tools
```

---

## smolagents — Code-Thinking Lightweight Agents

> **GitHub**: [huggingface/smolagents](https://github.com/huggingface/smolagents) · ⭐ 25.9k · 🍴 2.4k

HuggingFace's barebones agent library where agents "think in code". The entire core logic is ~1,000 lines, making it auditable and easy to understand. Supports any model from HuggingFace Hub or via API.

### Key Strengths

| Feature | Description |
|---------|-------------|
| Code-thinking | Agents reason and act through Python code, not JSON |
| Minimal footprint | ~1,000 LOC core — fully auditable |
| Model-agnostic | Any HuggingFace Hub model, OpenAI, Anthropic, etc. |
| Sandboxed execution | E2B and Docker sandboxing for safe code execution |
| MCP compatible | Native MCP server and LangChain tool integration |

### Install

```bash
pip install smolagents
# with all optional dependencies:
pip install "smolagents[all]"
```

---

## Related

| Resource | Link |
|----------|------|
| Agent Skills main docs | [../../README.md](../../README.md) |
| omc — Claude Code multi-agent orchestration | [../omc/README.md](../omc/README.md) |
| ralph — specification-first development loop | [../ralph/README.md](../ralph/README.md) |
| jeo — integrated orchestration skill | [../../.agent-skills/jeo/SKILL.md](../../.agent-skills/jeo/SKILL.md) |
| bmad-orchestrator — phase-based development | [../bmad/README.md](../bmad/README.md) |

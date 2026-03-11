# Agent Skills — LLM Installation Delegation Guide

> 🌐 Language / 언어: **English**

> Pass this file to an AI agent and it will automatically proceed with installation.
>
> ```bash
> curl -s https://raw.githubusercontent.com/supercent-io/skills-template/main/setup-all-skills-prompt.md
> ```

---

## Agent Instructions

AI agents receiving this file should execute the following steps **in order**.

### UltraTeam Consensus Principles (Systems Engineer · New User · Guideline Author)

- **Systems Engineer perspective**: Lock defaults explicitly so execution results are always the same (Full install). Detect and synchronize installation paths to eliminate platform-specific path differences.
- **New User perspective**: Remove ambiguous conditional language. Automatically perform full installation unless otherwise requested.
- **Guideline Author perspective**: "Skip" conditions are explicitly limited. Only skip Step 2 if the user explicitly requests `core only`, `minimal install`, or `quick install`.

### Execution Policy (Required)

- **Default execution**: Run `Step 1`, then continue to `Step 2` (default is full installation)
- **Exception**: Only skip `Step 2` if the user explicitly requests `core only` or `minimal install`
- **Prohibited**: Stopping to ask additional confirmation questions before executing `Step 2`

---

### Step 0: Assess User Environment

Before installation, confirm:

1. **Which AI platform are you using?**
   - Claude Code → recommend `omc`, `plannotator`, `ralph`, `ralphmode`, `bmad-orchestrator`
   - Gemini CLI → recommend `ohmg`, `ralph`, `ralphmode`, `jeo`
   - OpenAI Codex CLI → recommend `omx`, `ralph`, `ralphmode`, `jeo`
   - OpenCode → requires oh-my-opencode installation (see Step 3)
   - All / Unsure → install `jeo` + `survey` (`survey` for discovery, `jeo` for delivery)

2. **Is the `skills` CLI installed?**

```bash
if command -v skills &> /dev/null; then
    echo "skills CLI available"
else
    echo "Will install via npx"
fi
```

3. **Declare installation path standardization variables and wipe existing paths**

```bash
# Canonical path (recommended default)
export SKILLS_CANONICAL="${HOME}/.agent-skills"

SKILL_DESTS=(
  "${HOME}/.claude/skills" "${PWD}/.claude/skills"
  "${HOME}/.codex/skills" "${PWD}/.codex/skills"
  "${HOME}/.gemini/skills" "${PWD}/.gemini/skills"
  "${HOME}/.opencode/skills" "${PWD}/.opencode/skills"
  "${HOME}/.config/opencode/skills" "${PWD}/.config/opencode/skills"
)

# Always wipe existing skill paths to guarantee a clean install
echo "Wiping existing skill paths for clean install..."
rm -rf "${SKILLS_CANONICAL}"
for dest in "${SKILL_DESTS[@]}"; do
  rm -rf "${dest}"
done

mkdir -p "${SKILLS_CANONICAL}"
echo "✅ Skill paths cleared"
```

---

### Step 1: Core Skill Installation (Platform-Specific Minimum)

Execute based on Step 0 results:

**All platforms (recommended starting point):**
```bash
# research-first survey skill
npx skills add https://github.com/supercent-io/skills-template --skill survey

# jeo core skill
npx skills add https://github.com/supercent-io/skills-template --skill jeo

# jeo dependency skills (recommended to install together)
npx skills add https://github.com/supercent-io/skills-template --skill plannotator --skill agentation
```

> **jeo Agent Protocol**: When jeo runs, it automatically creates `jeo-state.json` and proceeds sequentially through PLAN → EXECUTE → VERIFY → CLEANUP phases.
> The PLAN phase uses `plannotator`, and the VERIFY_UI phase (`annotate` keyword) uses `agentation`, so both skills are required.
>
> **agentation MCP install (recommended)**: `npx add-mcp "npx -y agentation-mcp server"` — auto-detects 9+ agents including Claude/Gemini/Codex/OpenCode.
> **agentation Claude Code Official Skill**: Install with `npx skills add benjitaylor/agentation` then run `/agentation` in conversation to auto-launch browser UI.

**Claude Code only:**
```bash
npx skills add https://github.com/supercent-io/skills-template \
  --skill omc --skill plannotator --skill ralph --skill ralphmode --skill vibe-kanban
```

> **Claude Code + jeo**: jeo EXECUTE phase requires `/omc:team` and will **not** fall back to single-agent execution. Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` before running jeo.

**Gemini CLI only:**
```bash
npx skills add https://github.com/supercent-io/skills-template \
  --skill ohmg --skill ralph --skill ralphmode --skill vibe-kanban
```

**Codex CLI only:**
```bash
npx skills add https://github.com/supercent-io/skills-template \
  --skill omx --skill ralph --skill ralphmode
```

**Gemini CLI (extension install):**
```bash
gemini extensions install https://github.com/supercent-io/skills-template
```

---

### Step 2: Full 79-Skill Installation (Default Execution Step)

> **Always wipe existing skill directories before running — ensures no stale skills from previous installs or Step 1 partial install remain.**

```bash
# Wipe all skill paths before full install (unconditional — always required)
_SKILLS_CANONICAL="${HOME}/.agent-skills"
for _dest in \
  "${_SKILLS_CANONICAL}" \
  "${HOME}/.claude/skills"  "${PWD}/.claude/skills" \
  "${HOME}/.codex/skills"   "${PWD}/.codex/skills" \
  "${HOME}/.gemini/skills"  "${PWD}/.gemini/skills" \
  "${HOME}/.opencode/skills" "${PWD}/.opencode/skills" \
  "${HOME}/.config/opencode/skills" "${PWD}/.config/opencode/skills"; do
  rm -rf "${_dest}"
done
mkdir -p "${_SKILLS_CANONICAL}"
echo "✅ All skill directories wiped — ready for clean install"
```

```bash
npx skills add https://github.com/supercent-io/skills-template \
  --skill agent-configuration --skill agent-evaluation \
  --skill agentic-development-principles --skill agentic-principles \
  --skill agentic-workflow --skill bmad-orchestrator \
  --skill bmad-gds --skill bmad-idea \
  --skill prompt-repetition --skill api-design \
  --skill api-documentation --skill authentication-setup \
  --skill backend-testing --skill database-schema-design \
  --skill design-system --skill frontend-design-system \
  --skill react-best-practices --skill vercel-react-best-practices \
  --skill responsive-design --skill state-management \
  --skill ui-component-patterns --skill web-accessibility \
  --skill web-design-guidelines --skill code-refactoring \
  --skill code-review --skill debugging \
  --skill performance-optimization --skill testing-strategies \
  --skill deployment-automation --skill firebase-ai-logic \
  --skill genkit --skill looker-studio-bigquery \
  --skill monitoring-observability --skill security-best-practices \
  --skill system-environment-setup --skill vercel-deploy \
  --skill changelog-maintenance --skill presentation-builder \
  --skill technical-writing --skill user-guide-writing \
  --skill sprint-retrospective --skill standup-meeting \
  --skill task-estimation --skill task-planning \
  --skill codebase-search --skill data-analysis \
  --skill log-analysis --skill pattern-detection \
  --skill llm-monitoring-dashboard \
  --skill image-generation --skill image-generation-mcp --skill pollinations-ai \
  --skill remotion-video-production --skill video-production \
  --skill marketing-automation --skill marketing-skills-collection \
  --skill agent-browser --skill agentation --skill copilot-coding-agent \
  --skill ai-tool-compliance \
  --skill environment-setup --skill file-organization \
  --skill git-submodule --skill git-workflow --skill jeo \
  --skill npm-git-install --skill ohmg --skill omx \
  --skill omc --skill opencontext --skill plannotator --skill playwriter \
  --skill ralph --skill ralphmode --skill skill-standardization --skill survey \
  --skill vibe-kanban --skill workflow-automation \
  --skill fabric
```

> Skip condition is only allowed when the user explicitly requests (`core only`, `minimal install`, `quick install`).

> `presentation-builder` note: this skill now assumes a `slides-grab` workflow. Before first real use, install Node.js 18+, run `npx playwright install chromium`, and ensure `slides-grab --help` succeeds in the working environment.

---

### Step 3: Platform-Specific Additional Tool Installation

#### Claude Code — oh-my-claudecode

```bash
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/omc:omc-setup
```

Or in Claude Code conversation:
```
configure and use the jeo skill. remember it.
```

```bash
# jeo v1.3.0 hook setup: plan gate (ExitPlanMode) + agentation submit hook (UserPromptSubmit) + agentation MCP + agent teams
bash ~/.agent-skills/jeo/scripts/setup-claude.sh

# agentation Claude Code Official Skill install (recommended)
npx skills add benjitaylor/agentation
# After installation, run in conversation:
# /agentation  ← auto-launches browser UI, starts annotate watch loop
```

> **TOON Format Hook**: If `~/.claude/hooks/toon-inject.mjs` is installed, the skill catalog is automatically injected into every prompt. Configuration details: [bmad-orchestrator SKILL.md — TOON Format Integration](.agent-skills/bmad-orchestrator/SKILL.md)

#### OpenCode — oh-my-opencode

Fetch the latest installation guide and install for your subscription environment:

```bash
# Fetch oh-my-opencode latest installation guide — check flags for your subscription then run
curl -s https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/refs/heads/master/docs/guide/installation.md
```

Check the guide for installation flags matching your subscription (Claude Pro/Max, Gemini, Copilot, etc.) and proceed.

After installation, add skills:
```bash
npx skills add https://github.com/supercent-io/skills-template
```

#### Gemini CLI — jeo hook setup

```bash
# jeo AfterAgent hook auto-setup (plannotator + agentation integration)
bash ~/.agent-skills/jeo/scripts/setup-gemini.sh
```

> **TOON Format Hook**: If `~/.gemini/hooks/toon-skill-inject.sh` is installed, the skill catalog is auto-loaded at session start via `includeDirectories`. Codex CLI references `~/.codex/skills-toon-catalog.toon` in `developer_instructions`.

> [Official Hooks Guide](https://developers.googleblog.com/tailor-gemini-cli-to-your-workflow-with-hooks/)

---

### Step 4: Verify Installation and Activation

```bash
# Auto-detect installation directory (must be non-empty)
is_non_empty_dir() { [ -d "$1" ] && [ -n "$(ls -A "$1" 2>/dev/null)" ]; }

if is_non_empty_dir "${HOME}/.agent-skills"; then
  SKILL_SRC="${HOME}/.agent-skills"
elif is_non_empty_dir "${PWD}/.agent-skills"; then
  SKILL_SRC="${PWD}/.agent-skills"
elif is_non_empty_dir "${PWD}/.agents/skills"; then
  SKILL_SRC="${PWD}/.agents/skills"
else
  echo "non-empty skills directory not found"; exit 1
fi

echo "Detected skills dir: ${SKILL_SRC}"

# Sync to canonical path (force mirror)
mkdir -p "${HOME}/.agent-skills"
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "${SKILL_SRC}/" "${HOME}/.agent-skills/"
else
  rm -rf "${HOME}/.agent-skills"
  mkdir -p "${HOME}/.agent-skills"
  cp -R "${SKILL_SRC}/." "${HOME}/.agent-skills/"
fi

# Remove existing platform-specific skill directories and force copy
for dest in \
    "${HOME}/.claude/skills" "${PWD}/.claude/skills" \
    "${HOME}/.codex/skills" "${PWD}/.codex/skills" \
    "${HOME}/.gemini/skills" "${PWD}/.gemini/skills" \
    "${HOME}/.opencode/skills" "${PWD}/.opencode/skills" \
    "${HOME}/.config/opencode/skills" "${PWD}/.config/opencode/skills"; do
  rm -rf "${dest}"
  mkdir -p "${dest}"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "${HOME}/.agent-skills/" "${dest}/"
  else
    cp -R "${HOME}/.agent-skills"/. "${dest}/"
  fi
done

# Check installed skill list
ls "${HOME}/.agent-skills" 2>/dev/null
ls "${HOME}/.claude/skills" 2>/dev/null
ls "${HOME}/.codex/skills" 2>/dev/null
ls "${HOME}/.gemini/skills" 2>/dev/null
ls "${HOME}/.opencode/skills" 2>/dev/null
ls "${HOME}/.config/opencode/skills" 2>/dev/null

# Verify individual skill
npx skills info jeo
```

First run after installation by platform:

| Platform | Command |
|----------|---------|
| Claude Code | `jeo "task description"` or `/omc:team "task"` |
| Gemini CLI | `/jeo "task description"` |
| Codex CLI | `/jeo "task description"` |
| OpenCode | `/jeo "task description"` |

---

### Step 5: Ask for a Star ⭐

After everything is set up and working, ask the user:

> "If you found this helpful, would you like to star the repository? It helps the project grow! ⭐"

If the user agrees, run:

```bash
gh api --silent --method PUT /user/starred/supercent-io/skills-template >/dev/null 2>&1 || true
```

> **Important:** Only run the command if the user explicitly says yes. Never run it automatically without consent.

---

## Core Skill Keyword Reference

| Skill | Activation Keyword | Description |
|-------|-------------------|-------------|
| `jeo` | `jeo` | Integrated orchestration (recommended starting point) — built-in agent execution protocol (STEP 0: state bootstrap → PLAN/plannotator → EXECUTE → VERIFY → CLEANUP). PLAN auto-installs `plannotator` if missing. **Claude Code**: requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`; EXECUTE must use `/omc:team`. Requires: plannotator, agentation |
| `omc` | `omc`, `autopilot` | Claude Code multi-agent orchestration |
| `ralph` | `ralph`, `ooo`, `ooo ralph`, `ooo interview` | Ouroboros specification-first development (Interview→Seed→Execute→Evaluate→Evolve) + persistent completion loop |
| `ralphmode` | `ralphmode` | Ralph automation permission profiles for Claude Code, Codex CLI, Gemini CLI. Repo boundary enforcement, sandbox-first, secret denylist focused |
| `plannotator` | `plan` | Plan review + feedback loop |
| `vibe-kanban` | `kanbanview` | Kanban board |
| `bmad-orchestrator` | `bmad` | Structured phase-based development |
| `bmad-gds` | `bmad-gds` | Game Development Studio (Unity/Unreal/Godot) |
| `bmad-idea` | `bmad-idea` | Creative ideas · design thinking · innovation strategy |
| `ai-tool-compliance` | `ai-tool-compliance` | Internal AI tool compliance automation (P0/P1) |
| `agent-browser` | `agent-browser` | Headless browser automation |
| `survey` | `survey` | Cross-platform landscape scan before planning or implementation |
| `llm-monitoring-dashboard` | `llm-monitoring-dashboard` | LLM usage monitoring dashboard generation |
| `agentation` | `annotate`, `UI검토`, `agentui` | UI annotation → agent code modification. Install: `npx add-mcp "npx -y agentation-mcp server"` (Universal) or `npx skills add benjitaylor/agentation` → `/agentation` (Claude Code Official Skill). Local-first architecture, offline operation, session continuity. |
| `omx` | `omx` | Codex CLI multi-agent orchestration |
| `ohmg` | `ohmg` | Gemini / Antigravity workflows |

---

> Full skill list and detailed descriptions: [README.md](README.md)

# Agent Skills — LLM Installation Delegation Guide

> 🌐 Language / 언어: **English**

> Pass this file to an AI agent and it will automatically proceed with installation.
>
> ```bash
> curl -s https://raw.githubusercontent.com/akillness/oh-my-skills/main/setup-all-skills-prompt.md
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

3. **Declare installation path standardization variables and ensure directories exist**

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

# Ensure skill directories exist (preserves existing skills — update/overwrite only)
mkdir -p "${SKILLS_CANONICAL}"
for dest in "${SKILL_DESTS[@]}"; do
  mkdir -p "${dest}"
done

echo "✅ Skill paths ready"
```

---

### Step 1: Core Skill Installation (Platform-Specific Minimum)

Execute based on Step 0 results:

**All platforms (common core — installed once, shared by all):**
```bash
npx skills add https://github.com/akillness/oh-my-skills \
  --skill jeo --skill survey --skill plannotator --skill agentation \
  --skill ralph --skill ralphmode --skill vibe-kanban \
  -g
```

> **jeo Agent Protocol**: When jeo runs, it automatically creates `jeo-state.json` and proceeds sequentially through PLAN → EXECUTE → VERIFY → CLEANUP phases.
> The PLAN phase uses `plannotator`, and the VERIFY_UI phase (`annotate` keyword) uses `agentation`, so both skills are required.
>
> **agentation MCP install (recommended)**: `npx add-mcp "npx -y agentation-mcp server"` — auto-detects 9+ agents including Claude/Gemini/Codex/OpenCode.
> **agentation Claude Code Official Skill**: Install with `npx skills add benjitaylor/agentation -g` then run `/agentation` in conversation to auto-launch browser UI.

**Claude Code only (platform-specific — excludes common core above):**
```bash
npx skills add https://github.com/akillness/oh-my-skills \
  --skill omc --skill bmad-orchestrator \
  -g
```

> **Claude Code + jeo**: jeo EXECUTE phase requires `/omc:team` and will **not** fall back to single-agent execution. Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` before running jeo.

**Gemini CLI only (platform-specific):**
```bash
npx skills add https://github.com/akillness/oh-my-skills \
  --skill ohmg \
  -g
```

**Codex CLI only (platform-specific):**
```bash
npx skills add https://github.com/akillness/oh-my-skills \
  --skill omx \
  -g
```

**Gemini CLI (extension install — alternative):**
```bash
gemini extensions install https://github.com/akillness/oh-my-skills
```

---

### Step 2: Full Installation (78 in-repo skills)

> **Installs or overwrites all 78 in-repo skills. Existing skills are updated to the latest version. Skills not in this list are preserved. Step 0 already created directories — no duplicate mkdir needed.**

```bash
npx skills add https://github.com/akillness/oh-my-skills \
  --skill agent-browser --skill agentation --skill api-design \
  --skill api-documentation --skill authentication-setup \
  --skill autoresearch --skill backend-testing \
  --skill bmad-gds --skill bmad-idea --skill bmad-orchestrator \
  --skill changelog-maintenance --skill clawteam \
  --skill code-refactoring --skill code-review --skill codebase-search \
  --skill copilot-coding-agent --skill data-analysis \
  --skill database-schema-design --skill debugging \
  --skill deployment-automation --skill design-system \
  --skill environment-setup --skill fabric \
  --skill file-organization --skill firebase-ai-logic --skill firebase-cli \
  --skill frontend-design-system --skill genkit \
  --skill git-submodule --skill git-workflow \
  --skill google-workspace --skill jeo \
  --skill langsmith --skill log-analysis \
  --skill looker-studio-bigquery \
  --skill marketing-automation --skill marketing-skills-collection \
  --skill monitoring-observability --skill npm-git-install \
  --skill obsidian-plugin --skill ohmg --skill omc --skill omx \
  --skill opencontext --skill pattern-detection \
  --skill performance-optimization --skill plannotator --skill playwriter \
  --skill presentation-builder --skill prompt-repetition \
  --skill ralph --skill ralphmode --skill react-best-practices \
  --skill react-grab --skill remotion-video-production \
  --skill research-paper-writing --skill responsive-design \
  --skill security-best-practices --skill skill-autoresearch \
  --skill skill-standardization --skill sprint-retrospective \
  --skill standup-meeting --skill state-management \
  --skill survey --skill system-environment-setup \
  --skill task-estimation --skill task-planning \
  --skill technical-writing --skill testing-strategies \
  --skill ui-component-patterns --skill user-guide-writing \
  --skill vercel-deploy --skill vercel-react-best-practices \
  --skill vibe-kanban --skill video-production \
  --skill web-accessibility --skill web-design-guidelines \
  --skill workflow-automation \
  -g
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
# jeo ExitPlanMode hook setup (plannotator auto-integration)
bash ~/.agent-skills/jeo/scripts/setup-claude.sh

# agentation Claude Code Official Skill install (recommended)
npx skills add benjitaylor/agentation -g
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
npx skills add https://github.com/akillness/oh-my-skills -g
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
# Auto-detect canonical installation directory
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

# Sync to canonical path if not already there
if [ "${SKILL_SRC}" != "${HOME}/.agent-skills" ]; then
  mkdir -p "${HOME}/.agent-skills"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "${SKILL_SRC}/" "${HOME}/.agent-skills/"
  else
    cp -R "${SKILL_SRC}/." "${HOME}/.agent-skills/"
  fi
fi

# Symlink platform directories to canonical path (no duplication on disk)
# Each platform reads from the same source — updates propagate instantly
for dest in \
    "${HOME}/.claude/skills" "${HOME}/.codex/skills" \
    "${HOME}/.gemini/skills" "${HOME}/.opencode/skills" \
    "${HOME}/.config/opencode/skills"; do
  parent="$(dirname "${dest}")"
  mkdir -p "${parent}"
  if [ -L "${dest}" ]; then
    : # Already a symlink — skip
  elif [ -d "${dest}" ]; then
    echo "Replacing ${dest} (directory) with symlink to canonical path"
    rm -rf "${dest}"
    ln -s "${HOME}/.agent-skills" "${dest}"
  else
    ln -s "${HOME}/.agent-skills" "${dest}"
  fi
done

# Also symlink PWD-local paths if they exist as directories
for dest in \
    "${PWD}/.claude/skills" "${PWD}/.codex/skills" \
    "${PWD}/.gemini/skills" "${PWD}/.opencode/skills" \
    "${PWD}/.config/opencode/skills"; do
  parent="$(dirname "${dest}")"
  [ -d "${parent}" ] || continue
  if [ -L "${dest}" ]; then
    :
  elif [ -d "${dest}" ]; then
    rm -rf "${dest}"
    ln -s "${HOME}/.agent-skills" "${dest}"
  else
    ln -s "${HOME}/.agent-skills" "${dest}"
  fi
done

# Verify
echo "=== Installed skills (canonical) ==="
ls "${HOME}/.agent-skills" 2>/dev/null | head -20
SKILL_COUNT=$(ls -d "${HOME}/.agent-skills"/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
echo "Total: ${SKILL_COUNT} skills"

echo "=== Symlink status ==="
for dest in "${HOME}/.claude/skills" "${HOME}/.codex/skills" \
            "${HOME}/.gemini/skills" "${HOME}/.opencode/skills"; do
  if [ -L "${dest}" ]; then
    echo "  ${dest} -> $(readlink "${dest}")"
  elif [ -d "${dest}" ]; then
    echo "  ${dest} (directory — not symlinked)"
  else
    echo "  ${dest} (not found)"
  fi
done

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

If the user agrees, execute the following steps **in order**:

**1. Check gh CLI auth status:**
```bash
gh auth status 2>&1
```

**2a. If already authenticated** — star immediately:
```bash
gh api --silent --method PUT /user/starred/akillness/oh-my-skills && echo "⭐ Starred! Thank you!"
```

**2b. If NOT authenticated** — log in first, then star:
```bash
gh auth login
```
After login completes:
```bash
gh api --silent --method PUT /user/starred/akillness/oh-my-skills && echo "⭐ Starred! Thank you!"
```

> **Important:** Only proceed if the user explicitly says yes. Never run it automatically without consent.
> A successful star produces no output (HTTP 204). The `echo` confirms completion.

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
| `obsidian-plugin` | `obsidian plugin`, `create obsidian plugin` | Build, validate, and publish Obsidian plugins — 27 eslint-plugin-obsidianmd rules, interactive boilerplate generator, memory management, accessibility (MANDATORY), CSS variables, community submission validation |
| `bmad-orchestrator` | `bmad` | Structured phase-based development with SSD — TEA cycles (Task→Execute→Architect) per phase, `/ssd-cycle` command, multi-agent execution via `/team`, automated `fabric -p bmad_ssd_phase_review` validation before plannotator human review |
| `bmad-gds` | `bmad-gds` | Game Development Studio (Unity/Unreal/Godot) |
| `bmad-idea` | `bmad-idea` | Creative ideas · design thinking · innovation strategy |
| `agent-browser` | `agent-browser` | Headless browser automation |
| `survey` | `survey` | Cross-platform landscape scan before planning or implementation |
| `autoresearch` | `autoresearch`, `autonomous ml experiments`, `val_bpb` | Karpathy autonomous ML experimentation — AI agent runs overnight GPU experiments, ratchets improvements via git |
| `skill-autoresearch` | `skill-autoresearch`, `optimize this skill`, `eval my skill` | Eval-driven SKILL.md optimization loop — benchmark a skill, mutate one instruction at a time, keep only score-improving changes |
| `agentation` | `annotate`, `UI검토`, `agentui` | UI annotation → agent code modification. Install: `npx add-mcp "npx -y agentation-mcp server"` (Universal) or `npx skills add benjitaylor/agentation -g` → `/agentation` (Claude Code Official Skill). Local-first architecture, offline operation, session continuity. |
| `clawteam` | `clawteam`, `agent swarm`, `spawn agents` | Framework-agnostic multi-agent coordination CLI — file-based state, task queues, inboxes, kanban board |
| `research-paper-writing` | `research paper`, `academic paper` | ML/CV/NLP academic paper writing — section structure, paragraph flow, reviewer-facing presentation |
| `omx` | `omx` | Codex CLI multi-agent orchestration |
| `ohmg` | `ohmg` | Gemini / Antigravity workflows |

---

> Full skill list and detailed descriptions: [README.md](README.md)

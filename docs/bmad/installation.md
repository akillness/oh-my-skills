# bmad-orchestrator — Installation & Setup

→ [Overview](./README.md) · [Workflow Guide](./workflow.md) · [Configuration](./configuration.md) · [Examples](./examples.md)

---

## Prerequisites

- **Claude Code CLI** — [Installation guide](https://docs.anthropic.com/en/docs/claude-code/getting-started)
- **Claude Max/Pro subscription** or Anthropic API key
- **Node.js 18+** (for `npx skills`)
- **plannotator** (optional) — Required for phase gate reviews & Obsidian auto-save. Install from oh-my-claudecode.

---

## Step 1: Install the Skill

```bash
# Install bmad-orchestrator only
npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator

# Or install all 60 core skills at once
npx skills add https://github.com/supercent-io/skills-template
```

This installs the skill to `~/.agents/skills/bmad-orchestrator/`.

---

## Step 2: Activate in Claude Code

> **Critical**: bmad requires **explicit activation** before first use. The `기억해` suffix tells Claude Code to persist the configuration across sessions.

Open Claude Code in your terminal and run:

```text
bmad 스킬을 설정하고 사용해줘. 기억해.
```

**What `기억해` does:**
- Without `기억해` → bmad is active for current session only
- With `기억해` → bmad is persisted in `CLAUDE.md` for all future sessions

Claude will confirm setup with something like:
```
✓ bmad-orchestrator skill loaded
✓ Configuration saved to CLAUDE.md
Ready to use BMAD workflows
```

---

## Step 3: Initialize Your Project

Navigate to your project directory in Claude Code, then run:

```text
/workflow-init
```

Claude will ask you:
1. **Project name** — Name of your project
2. **Project type** — `web-app | mobile-app | api | game | library | other`
3. **Project level** — 0 (bug fix) through 4 (enterprise) — see [Project Levels](./workflow.md#project-levels)
4. **Communication language** — Language for AI interaction
5. **Output language** — Language for generated documents

BMAD then creates:

```
your-project/
├── bmad/
│   └── config.yaml          # Project-level BMAD config
└── docs/
    └── bmm-workflow-status.yaml  # Phase tracking file
```

---

## Verifying Installation

Run `/workflow-status` to see the initialized state:

```
Project: MyApp (web-app, Level 2)

✓ Phase 1: Analysis
  - product-brief (recommended)
  - research (optional)

→ Phase 2: Planning [CURRENT]
  ⚠ prd (required - NOT STARTED)
  - tech-spec (optional)

Phase 3: Solutioning
  - architecture (required)

Phase 4: Implementation
  - sprint-planning (required)
```

---

## Updating the Skill

```bash
# Reinstall to get latest version
npx skills add https://github.com/supercent-io/skills-template --skill bmad-orchestrator

# Then re-activate in Claude Code
bmad 스킬을 설정하고 사용해줘. 기억해.
```

---

## Uninstalling

```bash
# Remove the skill
rm -rf ~/.agents/skills/bmad-orchestrator
```

Then remove any `bmad-orchestrator` references from your project's `CLAUDE.md`.

---

## Troubleshooting

### "BMAD not detected in this project"
Run `/workflow-init` to initialize BMAD in the current directory.

### "bmad/config.yaml not found"
You're in a different directory than where you ran `/workflow-init`. Navigate to your project root.

### Config file has YAML errors
BMAD will offer to fix the YAML or reinitialize. You can also manually edit `bmad/config.yaml`.

### Session loses bmad context
You may have activated without `기억해`. Re-run:
```text
bmad 스킬을 설정하고 사용해줘. 기억해.
```

---

→ Next: [Workflow Guide](./workflow.md)

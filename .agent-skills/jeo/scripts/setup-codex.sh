#!/usr/bin/env bash
# JEO Skill — Codex CLI Setup
# Configures: developer_instructions in ~/.codex/config.toml + /prompts:jeo
# Usage: bash setup-codex.sh [--dry-run]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

CODEX_CONFIG="${HOME}/.codex/config.toml"
CODEX_PROMPTS_DIR="${HOME}/.codex/prompts"
JEO_PROMPT_FILE="${CODEX_PROMPTS_DIR}/jeo.md"

echo ""
echo "JEO — Codex CLI Setup"
echo "======================"

# ── 1. Check Codex CLI ────────────────────────────────────────────────────────
if ! command -v codex >/dev/null 2>&1; then
  warn "codex CLI not found. Install via: npm install -g @openai/codex"
fi

# ── 2. Configure ~/.codex/config.toml ────────────────────────────────────────
info "Configuring ~/.codex/config.toml..."

if $DRY_RUN; then
  echo -e "${YELLOW}[DRY-RUN]${NC} Would create/update $CODEX_CONFIG"
  echo -e "${YELLOW}[DRY-RUN]${NC} Would create $JEO_PROMPT_FILE"
else
  mkdir -p "$(dirname "$CODEX_CONFIG")" "$CODEX_PROMPTS_DIR"

  # Backup existing config
  [[ -f "$CODEX_CONFIG" ]] && cp "$CODEX_CONFIG" "${CODEX_CONFIG}.jeo.bak"

  JEO_INSTRUCTION='# JEO Orchestration Workflow
# Keyword: jeo | Platforms: Codex, Claude, Gemini, OpenCode
#
# JEO provides integrated AI orchestration:
#   1. PLAN: ralph+plannotator for visual plan review
#   2. EXECUTE: team (if available) or bmad workflow
#   3. VERIFY: agent-browser snapshot for UI verification
#   4. CLEANUP: auto worktree cleanup after completion
#
# Trigger with: jeo "<task description>"
# Use /prompts:jeo for full workflow activation
#
# BMAD commands (fallback when team unavailable):
#   /workflow-init   — initialize BMAD workflow
#   /workflow-status — check current BMAD phase
#
# Tools: agent-browser, playwriter, plannotator'

  # Add developer_instructions — section-aware to avoid duplicate [developer_instructions] tables
  if [[ -f "$CODEX_CONFIG" ]] && grep -q "^jeo\s*=" "$CODEX_CONFIG"; then
    ok "JEO developer_instructions already in config.toml"
  else
    python3 - <<PYEOF
import re, os

config_path = os.path.expanduser("~/.codex/config.toml")
jeo_value = '''"""
${JEO_INSTRUCTION}
"""'''

try:
    content = open(config_path).read() if os.path.exists(config_path) else ""
except Exception:
    content = ""

# If [developer_instructions] section already exists, insert jeo key inside it
if "[developer_instructions]" in content:
    # Insert before the next section header or at end of file
    content = re.sub(
        r'(\[developer_instructions\][^\[]*)',
        lambda m: m.group(1).rstrip() + f'\njeo = {jeo_value}\n',
        content, count=1
    )
    # Avoid double-insertion if already present
    if content.count("jeo =") > 1:
        pass  # already inserted, skip
else:
    content += f'\n[developer_instructions]\njeo = {jeo_value}\n'

with open(config_path, "w") as f:
    f.write(content)
print("✓ JEO developer_instructions added (section-aware merge)")
PYEOF
    ok "JEO developer_instructions added to ~/.codex/config.toml"
  fi

  # ── 3. Create /prompts:jeo prompt file ──────────────────────────────────────
  cat > "$JEO_PROMPT_FILE" <<'PROMPTEOF'
# JEO — Integrated Agent Orchestration Prompt

You are now operating in **JEO mode** — Integrated AI Agent Orchestration.

## Your Workflow

### Step 1: PLAN (ralph + plannotator)
Before writing any code, create a structured plan:
1. Write a detailed implementation plan in `plan.md`
2. Include: objectives, steps, risks, acceptance criteria
3. Submit for visual review via plannotator (if available)
4. Only proceed after plan is approved

### Step 2: EXECUTE (BMAD workflow for Codex)
Use BMAD structured phases:
- `/workflow-init` — Initialize BMAD for this project
- Analysis phase: understand requirements fully
- Planning phase: detailed technical plan
- Solutioning phase: architecture decisions
- Implementation phase: write code

### Step 3: VERIFY (agent-browser)
If the task has browser UI:
- Run: `agent-browser snapshot http://localhost:3000`
- Check UI elements via accessibility tree (-i flag)
- Save screenshot: `agent-browser screenshot <url> -o verify.png`

### Step 4: CLEANUP (worktree)
After all tasks complete:
- Run: git worktree prune
- Run: bash .agent-skills/jeo/scripts/worktree-cleanup.sh

## Key Commands
- Plan review: `plannotator plan -` (pipe plan.md content)
- Browser verify: `agent-browser snapshot http://localhost:3000`
- BMAD init: `/workflow-init`
- Worktree cleanup: `bash .agent-skills/jeo/scripts/worktree-cleanup.sh`

## State File
Save progress to: `.omc/state/jeo-state.json`
```json
{
  "phase": "plan|execute|verify|cleanup",
  "task": "current task description",
  "plan_approved": false,
  "worktrees": []
}
```

Always check state file on resume to continue from last phase.
PROMPTEOF

  ok "JEO prompt file created: $JEO_PROMPT_FILE"
fi

echo ""
echo "Codex CLI usage after setup:"
echo "  /prompts:jeo    ← Activate JEO orchestration workflow"
echo ""
ok "Codex CLI setup complete"
echo ""

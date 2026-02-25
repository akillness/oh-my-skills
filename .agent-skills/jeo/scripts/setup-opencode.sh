#!/usr/bin/env bash
# JEO Skill — OpenCode Plugin Registration
# Configures: opencode.json plugin entry + slash commands
# Usage: bash setup-opencode.sh [--dry-run]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# Look for opencode.json in cwd, then home
OPENCODE_JSON=""
for candidate in "./opencode.json" "${HOME}/opencode.json" "${HOME}/.config/opencode/opencode.json"; do
  [[ -f "$candidate" ]] && OPENCODE_JSON="$candidate" && break
done

echo ""
echo "JEO — OpenCode Plugin Setup"
echo "==========================="

# ── 1. Check OpenCode ────────────────────────────────────────────────────────
if ! command -v opencode >/dev/null 2>&1; then
  warn "opencode CLI not found. Install via: npm install -g opencode-ai"
fi

# ── 2. Configure opencode.json ────────────────────────────────────────────────
info "Configuring opencode.json..."

if [[ -z "$OPENCODE_JSON" ]]; then
  OPENCODE_JSON="./opencode.json"
  warn "No opencode.json found — will create at $OPENCODE_JSON"
fi

if $DRY_RUN; then
  echo -e "${YELLOW}[DRY-RUN]${NC} Would configure $OPENCODE_JSON with JEO plugin"
else
  # Backup
  [[ -f "$OPENCODE_JSON" ]] && cp "$OPENCODE_JSON" "${OPENCODE_JSON}.jeo.bak"

  python3 - <<PYEOF
import json, os

config_path = "$OPENCODE_JSON"
try:
    with open(config_path) as f:
        config = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    config = {}

# Set schema
config.setdefault("\$schema", "https://opencode.ai/config.json")

# Add plugins
plugins = config.setdefault("plugin", [])

# Add plannotator if not present
if "@plannotator/opencode@latest" not in plugins:
    plugins.append("@plannotator/opencode@latest")
    print("✓ plannotator plugin added")

# Add omx if not present
if "@oh-my-opencode/opencode@latest" not in plugins:
    plugins.append("@oh-my-opencode/opencode@latest")
    print("✓ omx (oh-my-opencode) plugin added")

# Add JEO slash commands
instructions = config.setdefault("instructions", "")
jeo_instructions = """
## JEO Orchestration Commands

/jeo-plan    — Start ralph+plannotator planning workflow
/jeo-exec    — Execute with team or BMAD orchestration
/jeo-verify  — Verify UI with agent-browser snapshot
/jeo-cleanup — Clean up worktrees after completion

## JEO Workflow
1. PLAN: Use ralph for task planning + plannotator for visual review
2. EXECUTE: Use omx team agents or BMAD structured phases
3. VERIFY: agent-browser snapshot <url> for UI verification
4. CLEANUP: bash .agent-skills/jeo/scripts/worktree-cleanup.sh

## Available Orchestration
- omx: /omx:team <n>:executor "<task>"
- BMAD: /workflow-init then follow phases
- plannotator: /plannotator-review (code review after implementation)
"""

if "JEO Orchestration Commands" not in instructions:
    config["instructions"] = instructions + jeo_instructions
    print("✓ JEO instructions added to opencode.json")

with open(config_path, "w") as f:
    json.dump(config, f, indent=2)
print(f"✓ opencode.json saved: {config_path}")
PYEOF

  ok "OpenCode configuration updated"
fi

echo ""
echo "OpenCode slash commands after setup:"
echo "  /jeo-plan      ← Start planning workflow"
echo "  /jeo-exec      ← Execute task"
echo "  /jeo-verify    ← Verify UI with agent-browser"
echo "  /jeo-cleanup   ← Clean worktrees"
echo "  /plannotator-review ← Code review UI"
echo ""
echo "  Restart OpenCode to activate plugins."
echo ""
ok "OpenCode setup complete"
echo ""

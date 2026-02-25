#!/usr/bin/env bash
# JEO Skill — Claude Code Plugin & Hook Setup
# Configures: omc plugin, plannotator hook, jeo workflow in ~/.claude/settings.json
# Usage: bash setup-claude.sh [--dry-run]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
err()  { echo -e "${RED}✗${NC} $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

CLAUDE_SETTINGS="${HOME}/.claude/settings.json"

echo ""
echo "JEO — Claude Code Setup"
echo "========================"

# ── 1. Check Claude Code ──────────────────────────────────────────────────────
if ! command -v claude >/dev/null 2>&1; then
  warn "claude CLI not found. Install Claude Code first."
  echo ""
  echo "Plugin installation (run inside Claude Code session):"
  echo "  /plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode"
  echo "  /plugin install oh-my-claudecode"
  echo "  /omc:omc-setup"
  echo ""
  echo "plannotator plugin:"
  echo "  /plugin marketplace add backnotprop/plannotator"
  echo "  /plugin install plannotator@plannotator"
else
  ok "claude CLI found"
fi

# ── 2. Configure ~/.claude/settings.json ─────────────────────────────────────
info "Configuring ~/.claude/settings.json..."

mkdir -p "$(dirname "$CLAUDE_SETTINGS")"

# Read existing settings or create empty
if [[ -f "$CLAUDE_SETTINGS" ]]; then
  # Backup
  if ! $DRY_RUN; then
    cp "$CLAUDE_SETTINGS" "${CLAUDE_SETTINGS}.jeo.bak"
    ok "Backup created: ${CLAUDE_SETTINGS}.jeo.bak"
  fi
  EXISTING=$(cat "$CLAUDE_SETTINGS")
else
  EXISTING="{}"
fi

# Check if plannotator hook already configured
if echo "$EXISTING" | grep -q "plannotator"; then
  ok "plannotator hook already configured in settings.json"
else
  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} Would add plannotator ExitPlanMode hook to $CLAUDE_SETTINGS"
  else
    # Use python3 to safely merge JSON
    python3 - <<'PYEOF'
import json, sys, os

settings_path = os.path.expanduser("~/.claude/settings.json")
try:
    with open(settings_path) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

# Add ExitPlanMode hook for plannotator
hooks = settings.setdefault("hooks", {})
exit_plan = hooks.setdefault("ExitPlanMode", [])

# Check if plannotator hook already exists
planno_exists = any(
    any(h.get("command", "").startswith("plannotator") for h in entry.get("hooks", []))
    for entry in exit_plan
)

if not planno_exists:
    exit_plan.append({
        "matcher": "",
        "hooks": [{
            "type": "command",
            "command": "plannotator plan -"
        }]
    })
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
    print("✓ plannotator ExitPlanMode hook added")
else:
    print("✓ plannotator hook already present")

# Enable experimental agent teams (check inside env dict, not top-level)
if not settings.get("env", {}).get("CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS"):
    env = settings.setdefault("env", {})
    env["CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS"] = "1"
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
    print("✓ Experimental agent teams enabled")
else:
    print("✓ Experimental agent teams already enabled")
PYEOF
    ok "Claude Code settings updated"
  fi
fi

# ── 3. Instructions ───────────────────────────────────────────────────────────
echo ""
echo "Manual plugin installation (run inside Claude Code):"
echo ""
echo "  # Install oh-my-claudecode (omc)"
echo "  /plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode"
echo "  /plugin install oh-my-claudecode"
echo "  /omc:omc-setup"
echo ""
echo "  # Install plannotator"
echo "  /plugin marketplace add backnotprop/plannotator"
echo "  /plugin install plannotator@plannotator"
echo ""
echo "  # Then restart Claude Code"
echo ""
ok "Claude Code setup complete"
echo "  IMPORTANT: Restart Claude Code to activate all hooks and plugins"
echo ""

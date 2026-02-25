#!/usr/bin/env bash
# JEO Skill — Gemini CLI Hook & GEMINI.md Setup
# Configures: ExitPlanMode hook in ~/.gemini/settings.json + JEO instructions in GEMINI.md
# Usage: bash setup-gemini.sh [--dry-run] [--hook-only] [--md-only]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false; HOOK_ONLY=false; MD_ONLY=false
for arg in "$@"; do
  case $arg in --dry-run) DRY_RUN=true ;; --hook-only) HOOK_ONLY=true ;; --md-only) MD_ONLY=true ;; esac
done

GEMINI_SETTINGS="${HOME}/.gemini/settings.json"
GEMINI_MD="${HOME}/.gemini/GEMINI.md"

echo ""
echo "JEO — Gemini CLI Setup"
echo "======================"

# ── 1. Check Gemini CLI ───────────────────────────────────────────────────────
if ! command -v gemini >/dev/null 2>&1; then
  warn "gemini CLI not found. Install via: npm install -g @google/gemini-cli"
fi

# NOTE: ExitPlanMode hook support in Gemini CLI depends on the installed version.
# If plannotator does not auto-open on plan exit, use the manual fallback:
#   python3 -c "import json; plan=open('plan.md').read(); \
#     print(json.dumps({'tool_input':{'plan':plan,'permission_mode':'acceptEdits'}}))" \
#     | plannotator > /tmp/plannotator_feedback.txt 2>&1 &

# ── 2. Configure ~/.gemini/settings.json ─────────────────────────────────────
if ! $MD_ONLY; then
  info "Configuring ~/.gemini/settings.json..."

  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} Would add ExitPlanMode hook to $GEMINI_SETTINGS"
  else
    mkdir -p "$(dirname "$GEMINI_SETTINGS")"
    [[ -f "$GEMINI_SETTINGS" ]] && cp "$GEMINI_SETTINGS" "${GEMINI_SETTINGS}.jeo.bak"

    python3 - <<'PYEOF'
import json, os

settings_path = os.path.expanduser("~/.gemini/settings.json")
try:
    with open(settings_path) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

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
    print("✓ plannotator ExitPlanMode hook added to ~/.gemini/settings.json")
else:
    print("✓ plannotator hook already present")
PYEOF
    ok "Gemini CLI settings updated"
  fi
fi

# ── 3. Update GEMINI.md ───────────────────────────────────────────────────────
if ! $HOOK_ONLY; then
  info "Updating ~/.gemini/GEMINI.md..."

  JEO_SECTION='
## JEO Orchestration Workflow

Keyword: `jeo` | Tool: Gemini CLI

JEO provides integrated AI agent orchestration across all AI tools.

### Workflow Phases

**PLAN** (ralph + plannotator):
- Enter plan mode: `gemini --approval-mode plan`
- plannotator UI opens automatically when exiting plan mode
- Review and approve or request changes

**EXECUTE** (BMAD for Gemini):
- BMAD is the primary orchestration fallback when omc team is unavailable
- `/workflow-init` — Initialize BMAD structured workflow
- `/workflow-status` — Check current phase
- Phases: Analysis → Planning → Solutioning → Implementation

**VERIFY** (agent-browser):
- `agent-browser snapshot http://localhost:3000`
- UI/기능 정상 여부 확인

**CLEANUP** (worktree):
- After all work: `bash .agent-skills/jeo/scripts/worktree-cleanup.sh`

### ohmg Integration
For Gemini multi-agent orchestration:
```bash
bunx oh-my-ag           # Initialize ohmg
/coordinate "<task>"    # Coordinate multi-agent task
```

### Manual Plan Review
```bash
python3 -c "
import json
plan = open('"'"'plan.md'"'"').read()
print(json.dumps({'"'"'tool_input'"'"': {'"'"'plan'"'"': plan, '"'"'permission_mode'"'"': '"'"'acceptEdits'"'"'}}))
" | plannotator > /tmp/plannotator_feedback.txt 2>&1 &
```
'

  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} Would append JEO section to $GEMINI_MD"
  else
    mkdir -p "$(dirname "$GEMINI_MD")"
    [[ -f "$GEMINI_MD" ]] && cp "$GEMINI_MD" "${GEMINI_MD}.jeo.bak"

    # Check if JEO section already present
    if [[ -f "$GEMINI_MD" ]] && grep -q "JEO Orchestration" "$GEMINI_MD"; then
      ok "JEO section already in GEMINI.md"
    else
      echo "$JEO_SECTION" >> "$GEMINI_MD"
      ok "JEO instructions added to ~/.gemini/GEMINI.md"
    fi
  fi
fi

echo ""
echo "Gemini CLI usage after setup:"
echo "  gemini --approval-mode plan    ← Plan mode (plannotator fires on exit)"
echo "  /workflow-init                 ← BMAD orchestration"
echo "  bunx oh-my-ag                  ← ohmg multi-agent (Gemini)"
echo ""
ok "Gemini CLI setup complete"
echo ""

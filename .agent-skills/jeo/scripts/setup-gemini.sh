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

# NOTE: Gemini CLI uses AfterAgent hook (not ExitPlanMode, which is Claude Code-only).
# The primary method is agent direct blocking call — do NOT use & (background).
# Manual blocking call (same-turn feedback):
#   python3 -c "import json,sys; plan=open('plan.md').read(); \
#     sys.stdout.write(json.dumps({'tool_input':{'plan':plan,'permission_mode':'acceptEdits'}}))" \
#     | plannotator > /tmp/plannotator_feedback.txt 2>&1

# ── 2. Configure ~/.gemini/settings.json ─────────────────────────────────────
if ! $MD_ONLY; then
  info "Configuring ~/.gemini/settings.json..."

  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} Would add AfterAgent hook to $GEMINI_SETTINGS"
  else
    mkdir -p "$(dirname "$GEMINI_SETTINGS")"
    [[ -f "$GEMINI_SETTINGS" ]] && cp "$GEMINI_SETTINGS" "${GEMINI_SETTINGS}.jeo.bak"

    # Create hook helper script (avoids plannotator plan - hanging on empty stdin)
    GEMINI_HOOK_DIR="${HOME}/.gemini/hooks"
    mkdir -p "$GEMINI_HOOK_DIR"
    cat > "${GEMINI_HOOK_DIR}/jeo-plannotator.sh" << 'HOOKEOF'
#!/usr/bin/env bash
# JEO AfterAgent backup hook — runs plannotator if plan.md exists in cwd
PLAN_FILE="$(pwd)/plan.md"
test -f "$PLAN_FILE" || exit 0
python3 -c "
import json, sys
plan = open(sys.argv[1]).read()
sys.stdout.write(json.dumps({'tool_input': {'plan': plan, 'permission_mode': 'acceptEdits'}}))
" "$PLAN_FILE" | plannotator > /tmp/plannotator_feedback.txt 2>&1 || true
HOOKEOF
    chmod +x "${GEMINI_HOOK_DIR}/jeo-plannotator.sh"

    python3 - <<PYEOF
import json, os

settings_path = os.path.expanduser("~/.gemini/settings.json")
hook_path = os.path.expanduser("~/.gemini/hooks/jeo-plannotator.sh")
try:
    with open(settings_path) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

hooks = settings.setdefault("hooks", {})
# AfterAgent is the correct Gemini CLI hook (ExitPlanMode is Claude Code-only)
after_agent = hooks.setdefault("AfterAgent", [])

# Check if jeo plannotator hook already exists (old or new form)
planno_exists = any(
    any(
        h.get("command", "").startswith("plannotator") or "jeo-plannotator" in h.get("command", "")
        for h in entry.get("hooks", [])
    )
    for entry in after_agent
)

if not planno_exists:
    after_agent.append({
        "matcher": "",
        "hooks": [{
            "name": "plannotator-review",
            "type": "command",
            "command": f"bash {hook_path}",
            "description": "plan.md 감지 시 plannotator 실행 (AfterAgent backup)"
        }]
    })
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
    print("✓ plannotator AfterAgent hook added to ~/.gemini/settings.json")
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

**PLAN** (plannotator — 직접 blocking 호출 필수):
1. `plan.md` 작성 (목표, 단계, 리스크, 완료 기준 포함)
2. plannotator 블로킹 실행 (& 절대 금지):
   python3 -c "import json,sys; plan=open('"'"'plan.md'"'"').read(); sys.stdout.write(json.dumps({'"'"'tool_input'"'"':{'"'"'plan'"'"':plan,'"'"'permission_mode'"'"':'"'"'acceptEdits'"'"'}}))" | plannotator > /tmp/plannotator_feedback.txt 2>&1
3. /tmp/plannotator_feedback.txt 읽기
4. "approved":true → EXECUTE 진입 / 미승인 → 피드백 반영 후 plan.md 수정 후 2번 반복
NEVER skip plannotator. NEVER proceed to EXECUTE without approved=true.

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

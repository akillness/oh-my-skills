#!/usr/bin/env bash
# JEO Skill — Status Check
# Verifies all JEO components and integrations
# Usage: bash check-status.sh [--resume]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✓${NC} $*"; }
warn() { echo -e "  ${YELLOW}⚠${NC}  $*"; }
err()  { echo -e "  ${RED}✗${NC} $*"; }
info() { echo -e "${BLUE}${BOLD}$*${NC}"; }

RESUME=false
[[ "${1:-}" == "--resume" ]] && RESUME=true

PASS=0; WARN=0; FAIL=0

check() {
  local label="$1"; local cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    ok "$label"; ((PASS++)) || true
  else
    err "$label (not found)"; ((FAIL++)) || true
  fi
}

check_opt() {
  local label="$1"; local cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    ok "$label"; ((PASS++)) || true
  else
    warn "$label (optional — not configured)"; ((WARN++)) || true
  fi
}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   JEO Skill — Status Check               ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Prerequisites ─────────────────────────────────────────────────────────────
info "Prerequisites"
check     "node >=18"        "node --version | grep -E 'v(1[89]|[2-9][0-9])'"
check     "npm"              "command -v npm"
check     "git"              "command -v git"
check_opt "bun"              "command -v bun"
check_opt "python3"          "command -v python3"
echo ""

# ── Core Tools ────────────────────────────────────────────────────────────────
info "Core Tools"
check_opt "plannotator CLI"  "command -v plannotator"
check_opt "agent-browser"    "command -v agent-browser || npx agent-browser --version"
check_opt "playwriter"       "command -v playwriter"
echo ""

# ── AI Tool Integrations ──────────────────────────────────────────────────────
info "AI Tool Integrations"

# Claude Code
if [[ -f "${HOME}/.claude/settings.json" ]]; then
  if grep -q "plannotator" "${HOME}/.claude/settings.json" 2>/dev/null; then
    ok "Claude Code — plannotator hook configured"; ((PASS++)) || true
  else
    warn "Claude Code — plannotator hook not found in settings.json"; ((WARN++)) || true
  fi
  if grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" "${HOME}/.claude/settings.json" 2>/dev/null; then
    ok "Claude Code — experimental agent teams enabled"; ((PASS++)) || true
  else
    warn "Claude Code — experimental agent teams not enabled"; ((WARN++)) || true
  fi
else
  warn "Claude Code — ~/.claude/settings.json not found"; ((WARN++)) || true
fi

# Codex CLI
if [[ -f "${HOME}/.codex/config.toml" ]]; then
  if python3 - <<'PYEOF' >/dev/null 2>&1
import pathlib, re
p = pathlib.Path.home() / '.codex' / 'config.toml'
text = p.read_text(encoding='utf-8')
m1 = re.search(r'(?ms)^developer_instructions\s*=\s*"""\n?(.*?)\n?"""\s*$', text)
if m1 and 'Keyword: jeo | Platforms: Codex, Claude, Gemini, OpenCode' in m1.group(1):
    raise SystemExit(0)
m2 = re.search(r'(?m)^developer_instructions\s*=\s*"(.*)"\s*$', text)
if m2 and 'Keyword: jeo | Platforms: Codex, Claude, Gemini, OpenCode' in bytes(m2.group(1), 'utf-8').decode('unicode_escape'):
    raise SystemExit(0)
raise SystemExit(1)
PYEOF
  then
    ok "Codex CLI — JEO developer_instructions configured"; ((PASS++)) || true
  else
    warn "Codex CLI — JEO developer_instructions missing/invalid in config.toml"; ((WARN++)) || true
  fi
  if [[ -f "${HOME}/.codex/prompts/jeo.md" ]]; then
    ok "Codex CLI — /prompts:jeo available"; ((PASS++)) || true
  else
    warn "Codex CLI — /prompts:jeo not found"; ((WARN++)) || true
  fi
else
  warn "Codex CLI — ~/.codex/config.toml not found"; ((WARN++)) || true
fi

# Gemini CLI
if [[ -f "${HOME}/.gemini/settings.json" ]]; then
  if grep -q "plannotator" "${HOME}/.gemini/settings.json" 2>/dev/null; then
    ok "Gemini CLI — plannotator hook configured"; ((PASS++)) || true
  else
    warn "Gemini CLI — plannotator hook not found"; ((WARN++)) || true
  fi
else
  warn "Gemini CLI — ~/.gemini/settings.json not found"; ((WARN++)) || true
fi
if [[ -f "${HOME}/.gemini/GEMINI.md" ]]; then
  if grep -q "JEO Orchestration" "${HOME}/.gemini/GEMINI.md" 2>/dev/null; then
    ok "Gemini CLI — JEO instructions in GEMINI.md"; ((PASS++)) || true
  else
    warn "Gemini CLI — JEO not in GEMINI.md"; ((WARN++)) || true
  fi
fi

# OpenCode
for candidate in "./opencode.json" "${HOME}/opencode.json"; do
  if [[ -f "$candidate" ]]; then
    if grep -q "plannotator" "$candidate" 2>/dev/null; then
      ok "OpenCode — plannotator plugin configured ($candidate)"; ((PASS++)) || true
    else
      warn "OpenCode — plannotator not in $candidate"; ((WARN++)) || true
    fi
    break
  fi
done
echo ""

# ── JEO State ─────────────────────────────────────────────────────────────────
info "JEO State"
STATE_FILE=".omc/state/jeo-state.json"
if [[ -f "$STATE_FILE" ]]; then
  ok "State file found: $STATE_FILE"
  if command -v python3 >/dev/null 2>&1; then
    PHASE=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(d.get('phase','unknown'))" 2>/dev/null || echo "unknown")
    TASK=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(d.get('task','(none)'))" 2>/dev/null || echo "(none)")
    echo "     Current phase: $PHASE"
    echo "     Task: $TASK"
  fi
  if $RESUME; then
    echo ""
    echo "  Resume instructions:"
    echo "  The JEO workflow was in phase: $PHASE"
    echo "  Check .omc/plans/jeo-plan.md for the approved plan"
  fi
else
  warn "No active JEO state (no workflow in progress)"
  if $RESUME && command -v python3 >/dev/null 2>&1; then
    info "Initializing fresh JEO state file for new session..."
    mkdir -p ".omc/state"
    python3 - <<'PYEOF'
import json, datetime, os
now = datetime.datetime.utcnow().isoformat() + "Z"
state = {
    "phase": "plan",
    "task": "",
    "plan_approved": False,
    "plan_path": ".omc/plans/jeo-plan.md",
    "team_available": False,
    "worktrees": [],
    "bmad_phase": None,
    "created_at": now,
    "updated_at": now,
    "cleanup_completed": False
}
os.makedirs(".omc/state", exist_ok=True)
os.makedirs(".omc/plans", exist_ok=True)
with open(".omc/state/jeo-state.json", "w") as f:
    json.dump(state, f, indent=2)
print("✓ Fresh JEO state initialized at .omc/state/jeo-state.json (phase: plan)")
PYEOF
  elif [[ -z "${1:-}" ]]; then
    echo "     Tip: Run with --resume to initialize state for a new session"
  fi
fi

# Worktrees
WORKTREE_COUNT=$(git worktree list 2>/dev/null | wc -l | tr -d ' ') || WORKTREE_COUNT=0
if [[ "$WORKTREE_COUNT" -gt 1 ]]; then
  warn "Active worktrees: $WORKTREE_COUNT (run worktree-cleanup.sh when done)"
else
  ok "No extra worktrees active"
fi
echo ""

# ── Summary ────────────────────────────────────────────────────────────────────
echo "══════════════════════════════════════════"
echo -e "  ${GREEN}✓${NC} Passed: $PASS  ${YELLOW}⚠${NC}  Warnings: $WARN  ${RED}✗${NC} Failed: $FAIL"
echo "══════════════════════════════════════════"
echo ""

if [[ $FAIL -gt 0 ]]; then
  echo "Fix failures by running: bash scripts/install.sh --all"
elif [[ $WARN -gt 0 ]]; then
  echo "Run platform setup scripts to resolve warnings:"
  echo "  bash scripts/setup-claude.sh"
  echo "  bash scripts/setup-codex.sh"
  echo "  bash scripts/setup-gemini.sh"
  echo "  bash scripts/setup-opencode.sh"
else
  echo -e "${GREEN}All checks passed! JEO is fully configured.${NC}"
fi
echo ""

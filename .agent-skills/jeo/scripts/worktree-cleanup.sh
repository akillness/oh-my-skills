#!/usr/bin/env bash
# JEO Skill — Worktree Cleanup Script
# Removes stale git worktrees after task completion
# Usage: bash worktree-cleanup.sh [--force] [--dry-run] [--list]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
err()  { echo -e "${RED}✗${NC} $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false; FORCE=false; LIST_ONLY=false
for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
    --force)
      FORCE=true
      warn "WARNING: --force removes ALL non-main worktrees."
      warn "         Active feature branches in separate worktrees will also be removed."
      warn "         Press Ctrl+C within 5 seconds to cancel..."
      sleep 5
      ;;
    --list)    LIST_ONLY=true ;;
  esac
done

echo ""
echo "JEO — Worktree Cleanup"
echo "====================="

# ── Check git repo ─────────────────────────────────────────────────────────────
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  err "Not a git repository. Run from project root."
  exit 1
fi

# ── List all worktrees ─────────────────────────────────────────────────────────
info "Current worktrees:"
git worktree list
echo ""

# ── Identify stale worktrees ──────────────────────────────────────────────────
MAIN_WORKTREE=$(git worktree list | head -1 | awk '{print $1}')
WORKTREES_TO_REMOVE=()

while IFS= read -r line; do
  WORKTREE_PATH=$(echo "$line" | awk '{print $1}')

  # Skip main worktree
  [[ "$WORKTREE_PATH" == "$MAIN_WORKTREE" ]] && continue

  if $FORCE; then
    WORKTREES_TO_REMOVE+=("$WORKTREE_PATH")
  fi
done < <(git worktree list | tail -n +2)

# ── List mode ─────────────────────────────────────────────────────────────────
if $LIST_ONLY; then
  if [[ ${#WORKTREES_TO_REMOVE[@]} -eq 0 ]]; then
    ok "No extra worktrees found"
  else
    echo "Worktrees to remove:"
    for wt in "${WORKTREES_TO_REMOVE[@]}"; do
      echo "  - $wt"
    done
  fi
  exit 0
fi

# ── Remove identified worktrees ───────────────────────────────────────────────
if [[ ${#WORKTREES_TO_REMOVE[@]} -eq 0 ]]; then
  ok "No extra worktrees to remove"
else
  info "Removing ${#WORKTREES_TO_REMOVE[@]} worktree(s)..."
  for WORKTREE_PATH in "${WORKTREES_TO_REMOVE[@]}"; do
    if $DRY_RUN; then
      echo -e "${YELLOW}[DRY-RUN]${NC} Would remove: $WORKTREE_PATH"
    else
      info "Removing: $WORKTREE_PATH"
      git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || \
        git worktree remove "$WORKTREE_PATH" 2>/dev/null || \
        warn "Could not remove $WORKTREE_PATH (may already be gone)"
      # Also remove the directory if it still exists
      [[ -d "$WORKTREE_PATH" ]] && rm -rf "$WORKTREE_PATH" || true
      ok "Removed: $WORKTREE_PATH"
    fi
  done
fi

# ── Prune stale worktree entries ──────────────────────────────────────────────
info "Pruning stale worktree references..."
if $DRY_RUN; then
  echo -e "${YELLOW}[DRY-RUN]${NC} Would run: git worktree prune"
else
  git worktree prune
  ok "Stale worktree references pruned"
fi

# ── Update JEO state ──────────────────────────────────────────────────────────
STATE_FILE=".omc/state/jeo-state.json"
if [[ -f "$STATE_FILE" ]] && command -v python3 >/dev/null 2>&1; then
  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY-RUN]${NC} Would update JEO state: phase=cleanup, worktrees=[]"
  else
    python3 - <<'PYEOF'
import json, os
state_path = ".omc/state/jeo-state.json"
try:
    with open(state_path) as f:
        state = json.load(f)
    state["phase"] = "cleanup"
    state["worktrees"] = []
    state["cleanup_completed"] = True
    with open(state_path, "w") as f:
        json.dump(state, f, indent=2)
    print("✓ JEO state updated: cleanup complete")
except Exception as e:
    print(f"⚠  Could not update state: {e}")
PYEOF
  fi
fi

# ── Final summary ─────────────────────────────────────────────────────────────
echo ""
echo "Final worktree list:"
git worktree list
echo ""
ok "Worktree cleanup complete"
echo ""

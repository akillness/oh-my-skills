#!/bin/bash
# plannotator - Shell Integration Setup Script
# Adds a `plan` shell function to ~/.zshrc or ~/.bashrc
# so you can run `plan <file.md>` directly from the terminal.
#
# Usage:
#   ./setup-shell.sh              # Auto-detect shell profile
#   ./setup-shell.sh --dry-run    # Preview without writing
#   ./setup-shell.sh --remove     # Remove the function

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m'

DRY_RUN=false
REMOVE=false

for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
    --remove)  REMOVE=true ;;
    -h|--help)
      echo "Usage: $0 [--dry-run] [--remove]"
      echo ""
      echo "Adds a 'plan' shell function to your shell profile."
      echo ""
      echo "After setup, use from any terminal:"
      echo "  plan <file.md>          # Submit plan for visual review (blocking)"
      echo "  plan --review           # Review uncommitted git diff"
      echo "  plan --review HEAD~1    # Review specific commit"
      echo ""
      echo "Options:"
      echo "  --dry-run   Show what would be changed without writing"
      echo "  --remove    Remove the plannotator shell function"
      echo "  -h, --help  Show this help"
      exit 0
      ;;
  esac
done

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  plannotator Shell Integration Setup       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# ── Check plannotator CLI ─────────────────────────────────
if ! command -v plannotator &>/dev/null; then
  echo -e "${RED}✗ plannotator CLI not found${NC}"
  echo -e "${YELLOW}  Run ./install.sh first${NC}"
  exit 1
fi
echo -e "${GREEN}✓ plannotator CLI is installed${NC}"
echo ""

# ── Detect shell profile ──────────────────────────────────
SHELL_PROFILE=""
if [ -n "$SHELL" ]; then
  case "$SHELL" in
    */zsh)  SHELL_PROFILE="$HOME/.zshrc" ;;
    */bash) SHELL_PROFILE="$HOME/.bashrc" ;;
    */fish) SHELL_PROFILE="$HOME/.config/fish/config.fish" ;;
  esac
fi

if [ -z "$SHELL_PROFILE" ]; then
  # fallback: prefer zshrc if exists, else bashrc
  if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
  else
    SHELL_PROFILE="$HOME/.bashrc"
  fi
fi

echo -e "${BLUE}Shell profile:${NC} ${SHELL_PROFILE}"
echo ""

# ── Remove mode ───────────────────────────────────────────
if [ "$REMOVE" = true ]; then
  if [ ! -f "$SHELL_PROFILE" ] || ! grep -q "# plannotator shell integration" "$SHELL_PROFILE" 2>/dev/null; then
    echo -e "${YELLOW}⚠ plannotator shell function not found in ${SHELL_PROFILE}${NC}"
    exit 0
  fi
  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN] Would remove plannotator block from ${SHELL_PROFILE}${NC}"
    exit 0
  fi
  BACKUP="${SHELL_PROFILE}.bak.$(date +%Y%m%d%H%M%S)"
  cp "$SHELL_PROFILE" "$BACKUP"
  echo -e "${GRAY}  Backup saved: ${BACKUP}${NC}"
  python3 - "$SHELL_PROFILE" <<'PYEOF'
import sys, re
path = sys.argv[1]
content = open(path).read()
content = re.sub(
    r'\n# plannotator shell integration.*?# end plannotator shell integration\n',
    '\n',
    content,
    flags=re.DOTALL
)
open(path, 'w').write(content)
print("Removed plannotator shell integration.")
PYEOF
  echo -e "${GREEN}✓ plannotator shell function removed from ${SHELL_PROFILE}${NC}"
  echo -e "${GRAY}  Reload: source ${SHELL_PROFILE}${NC}"
  exit 0
fi

# ── Already installed? ────────────────────────────────────
if [ -f "$SHELL_PROFILE" ] && grep -q "# plannotator shell integration" "$SHELL_PROFILE" 2>/dev/null; then
  echo -e "${YELLOW}⚠ plannotator shell function already in ${SHELL_PROFILE}${NC}"
  echo -e "${GRAY}  No changes made. Use --remove to uninstall.${NC}"
  exit 0
fi

# ── Shell function block ──────────────────────────────────
PLAN_FUNCTION='
# plannotator shell integration
# Usage: plan <file.md> | plan --review [commit]
plan() {
  if [ -z "$1" ]; then
    echo "Usage:"
    echo "  plan <file.md>          Submit plan for visual review (blocking)"
    echo "  plan --review           Review uncommitted git diff"
    echo "  plan --review HEAD~1    Review specific commit"
    return 1
  fi
  case "$1" in
    --review|-r)
      shift
      plannotator review "$@"
      ;;
    *)
      local plan_file="$1"
      if [ ! -f "$plan_file" ]; then
        echo "Error: file not found: $plan_file"
        return 1
      fi
      echo "Submitting plan for review: $plan_file"
      python3 -c "
import json
plan = open(\"$plan_file\").read()
print(json.dumps({\"tool_input\": {\"plan\": plan, \"permission_mode\": \"acceptEdits\"}}))
" | plannotator > /tmp/plannotator_feedback.txt 2>&1
      echo ""
      if grep -q '"approved":true' /tmp/plannotator_feedback.txt 2>/dev/null; then
        echo "✓ Plan APPROVED"
      elif grep -q '"approved":false' /tmp/plannotator_feedback.txt 2>/dev/null; then
        echo "✗ Plan REJECTED — feedback saved to /tmp/plannotator_feedback.txt"
        cat /tmp/plannotator_feedback.txt
      else
        echo "? Review complete — see /tmp/plannotator_feedback.txt"
        cat /tmp/plannotator_feedback.txt
      fi
      ;;
  esac
}
# end plannotator shell integration
'

echo -e "${BLUE}Function to be added:${NC}"
echo ""
echo -e "${GRAY}plan <file.md>          — submit plan, blocking until Approve/Feedback${NC}"
echo -e "${GRAY}plan --review           — review uncommitted git diff${NC}"
echo -e "${GRAY}plan --review HEAD~1    — review specific commit${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}[DRY RUN] Would append to ${SHELL_PROFILE}:${NC}"
  echo "$PLAN_FUNCTION"
  exit 0
fi

# ── Write to profile ──────────────────────────────────────
if [ -f "$SHELL_PROFILE" ]; then
  BACKUP="${SHELL_PROFILE}.bak.$(date +%Y%m%d%H%M%S)"
  cp "$SHELL_PROFILE" "$BACKUP"
  echo -e "${GRAY}  Backup saved: ${BACKUP}${NC}"
fi

printf "%s\n" "$PLAN_FUNCTION" >> "$SHELL_PROFILE"
echo -e "${GREEN}✓ plannotator shell function added to ${SHELL_PROFILE}${NC}"

echo ""
echo -e "${GREEN}Shell integration complete!${NC}"
echo ""
echo -e "${BLUE}Reload your shell:${NC}"
echo -e "  source ${SHELL_PROFILE}"
echo ""
echo -e "${BLUE}Usage:${NC}"
echo -e "  ${GREEN}plan plan.md${NC}              # Submit plan — browser opens, blocks until you Approve/Reject"
echo -e "  ${GREEN}plan --review${NC}             # Review uncommitted diff"
echo -e "  ${GREEN}plan --review HEAD~1${NC}      # Review specific commit"
echo ""

#!/usr/bin/env bash
# setup-agentation-mcp.sh — Register agentation MCP server for all AI agent platforms
#
# Usage:
#   bash setup-agentation-mcp.sh           # all platforms
#   bash setup-agentation-mcp.sh --claude  # Claude Code only
#   bash setup-agentation-mcp.sh --codex   # Codex CLI only
#   bash setup-agentation-mcp.sh --gemini  # Gemini CLI only
#   bash setup-agentation-mcp.sh --opencode # OpenCode only
#   bash setup-agentation-mcp.sh --all     # all platforms (explicit)

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${BLUE}ℹ  $*${NC}"; }
ok()    { echo -e "${GREEN}✅ $*${NC}"; }
warn()  { echo -e "${YELLOW}⚠  $*${NC}"; }
err()   { echo -e "${RED}✗  $*${NC}" >&2; }

# ─── Argument parsing ────────────────────────────────────────────────────────
SETUP_CLAUDE=false
SETUP_CODEX=false
SETUP_GEMINI=false
SETUP_OPENCODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --claude)   SETUP_CLAUDE=true ;;
    --codex)    SETUP_CODEX=true ;;
    --gemini)   SETUP_GEMINI=true ;;
    --opencode) SETUP_OPENCODE=true ;;
    --all)      SETUP_CLAUDE=true; SETUP_CODEX=true; SETUP_GEMINI=true; SETUP_OPENCODE=true ;;
    *) warn "Unknown flag: $1" ;;
  esac
  shift
done

# Default: all platforms
if [[ "$SETUP_CLAUDE$SETUP_CODEX$SETUP_GEMINI$SETUP_OPENCODE" == "falsefalsefalsefalse" ]]; then
  SETUP_CLAUDE=true; SETUP_CODEX=true; SETUP_GEMINI=true; SETUP_OPENCODE=true
fi

echo "╔══════════════════════════════════════════╗"
echo "║  agentation MCP Setup                    ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ─── Claude Code (~/.claude/claude_desktop_config.json) ───────────────────
if [[ "$SETUP_CLAUDE" == "true" ]]; then
  info "Setting up Claude Code..."
  CLAUDE_DIR="$HOME/.claude"
  CLAUDE_CFG="$CLAUDE_DIR/claude_desktop_config.json"
  mkdir -p "$CLAUDE_DIR"

  MCP_JSON='{"command":"npx","args":["-y","agentation-mcp","server"]}'

  if [[ -f "$CLAUDE_CFG" ]]; then
    if command -v jq &>/dev/null; then
      MERGED=$(jq --argjson entry "$MCP_JSON" '.mcpServers.agentation = $entry' "$CLAUDE_CFG" 2>/dev/null)
      if [[ -n "$MERGED" ]]; then
        echo "$MERGED" > "$CLAUDE_CFG"
        ok "Claude Code: merged into $CLAUDE_CFG"
      else
        warn "Claude Code: jq merge failed — add manually"
      fi
    else
      warn "Claude Code: jq not found — add manually to $CLAUDE_CFG:"
      echo '  "mcpServers": { "agentation": { "command": "npx", "args": ["-y", "agentation-mcp", "server"] } }'
    fi
  else
    cat > "$CLAUDE_CFG" <<'EOF'
{
  "mcpServers": {
    "agentation": {
      "command": "npx",
      "args": ["-y", "agentation-mcp", "server"]
    }
  }
}
EOF
    ok "Claude Code: created $CLAUDE_CFG"
  fi
  echo ""
fi

# ─── Codex CLI (~/.codex/config.toml) ─────────────────────────────────────
if [[ "$SETUP_CODEX" == "true" ]]; then
  info "Setting up Codex CLI..."
  CODEX_DIR="$HOME/.codex"
  CODEX_CFG="$CODEX_DIR/config.toml"
  mkdir -p "$CODEX_DIR"

  CODEX_ENTRY=$'\n# agentation MCP Server\n[[mcp_servers]]\nname = "agentation"\ncommand = "npx"\nargs = ["-y", "agentation-mcp", "server"]\n'

  if [[ -f "$CODEX_CFG" ]]; then
    if grep -q '"agentation"\|name = "agentation"' "$CODEX_CFG" 2>/dev/null; then
      warn "Codex CLI: agentation already in $CODEX_CFG — skipping"
    else
      printf '%s' "$CODEX_ENTRY" >> "$CODEX_CFG"
      ok "Codex CLI: appended to $CODEX_CFG"
    fi
  else
    printf '%s' "$CODEX_ENTRY" > "$CODEX_CFG"
    ok "Codex CLI: created $CODEX_CFG"
  fi
  echo ""
fi

# ─── Gemini CLI (~/.gemini/settings.json) ─────────────────────────────────
if [[ "$SETUP_GEMINI" == "true" ]]; then
  info "Setting up Gemini CLI..."
  GEMINI_DIR="$HOME/.gemini"
  GEMINI_CFG="$GEMINI_DIR/settings.json"
  mkdir -p "$GEMINI_DIR"

  MCP_JSON='{"command":"npx","args":["-y","agentation-mcp","server"]}'

  if [[ -f "$GEMINI_CFG" ]]; then
    if command -v jq &>/dev/null; then
      MERGED=$(jq --argjson entry "$MCP_JSON" '.mcpServers.agentation = $entry' "$GEMINI_CFG" 2>/dev/null)
      if [[ -n "$MERGED" ]]; then
        echo "$MERGED" > "$GEMINI_CFG"
        ok "Gemini CLI: merged into $GEMINI_CFG"
      else
        warn "Gemini CLI: jq merge failed — add manually"
      fi
    else
      warn "Gemini CLI: jq not found — add manually to $GEMINI_CFG:"
      echo '  "mcpServers": { "agentation": { "command": "npx", "args": ["-y", "agentation-mcp", "server"] } }'
    fi
  else
    cat > "$GEMINI_CFG" <<'EOF'
{
  "mcpServers": {
    "agentation": {
      "command": "npx",
      "args": ["-y", "agentation-mcp", "server"]
    }
  }
}
EOF
    ok "Gemini CLI: created $GEMINI_CFG"
  fi
  echo ""
fi

# ─── OpenCode (~/.config/opencode/opencode.json) ──────────────────────────
if [[ "$SETUP_OPENCODE" == "true" ]]; then
  info "Setting up OpenCode..."
  OC_DIR="$HOME/.config/opencode"
  OC_CFG="$OC_DIR/opencode.json"
  mkdir -p "$OC_DIR"

  MCP_ENTRY='{"type":"local","command":["npx","-y","agentation-mcp","server"]}'

  if [[ -f "$OC_CFG" ]]; then
    if command -v jq &>/dev/null; then
      MERGED=$(jq --argjson entry "$MCP_ENTRY" '.mcp.agentation = $entry' "$OC_CFG" 2>/dev/null)
      if [[ -n "$MERGED" ]]; then
        echo "$MERGED" > "$OC_CFG"
        ok "OpenCode: merged into $OC_CFG"
      else
        warn "OpenCode: jq merge failed — add manually"
      fi
    else
      warn "OpenCode: jq not found — add manually to $OC_CFG:"
      echo '  "mcp": { "agentation": { "type": "local", "command": ["npx", "-y", "agentation-mcp", "server"] } }'
    fi
  else
    cat > "$OC_CFG" <<'EOF'
{
  "mcp": {
    "agentation": {
      "type": "local",
      "command": ["npx", "-y", "agentation-mcp", "server"]
    }
  }
}
EOF
    ok "OpenCode: created $OC_CFG"
  fi
  echo ""
fi

# ─── Done ─────────────────────────────────────────────────────────────────
echo "╔══════════════════════════════════════════╗"
echo "║  Setup Complete                          ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Restart your agent(s)"
echo "  2. Start agentation MCP server:  npx agentation-mcp server"
echo "  3. Add to your app:              import { Agentation } from 'agentation'"
echo "     <Agentation endpoint=\"http://localhost:4747\" />"
echo ""
echo "Available MCP tools: agentation_watch_annotations, agentation_resolve, agentation_acknowledge, ..."
echo "Run 'npx agentation-mcp doctor' to verify."

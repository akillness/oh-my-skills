#!/usr/bin/env bash
# react-grab add-agent script
# Connects react-grab to a specific AI coding agent
#
# Usage:
#   bash scripts/add-agent.sh <agent>
#   bash scripts/add-agent.sh mcp
#   bash scripts/add-agent.sh claude-code
#   bash scripts/add-agent.sh cursor
#
# Supported agents:
#   claude-code, cursor, copilot, codex, gemini, opencode, amp, droid, mcp

set -euo pipefail

SUPPORTED_AGENTS=(
  "claude-code"
  "cursor"
  "copilot"
  "codex"
  "gemini"
  "opencode"
  "amp"
  "droid"
  "mcp"
)

show_help() {
  echo "Usage: bash scripts/add-agent.sh <agent>"
  echo ""
  echo "Supported agents:"
  for agent in "${SUPPORTED_AGENTS[@]}"; do
    echo "  $agent"
  done
  echo ""
  echo "Examples:"
  echo "  bash scripts/add-agent.sh claude-code"
  echo "  bash scripts/add-agent.sh cursor"
  echo "  bash scripts/add-agent.sh mcp"
  echo ""
  echo "Remove an integration:"
  echo "  npx -y grab@latest remove <agent>"
}

if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
  show_help
  exit 0
fi

AGENT="$1"

# Validate agent name
VALID=false
for a in "${SUPPORTED_AGENTS[@]}"; do
  if [[ "$AGENT" == "$a" ]]; then
    VALID=true
    break
  fi
done

if [[ "$VALID" == "false" ]]; then
  echo "❌ Unknown agent: $AGENT"
  echo ""
  show_help
  exit 1
fi

# Check Node.js
if ! command -v node &>/dev/null; then
  echo "❌ Node.js is required. Install from https://nodejs.org/ (>=18 required)"
  exit 1
fi

# Check npx
if ! command -v npx &>/dev/null; then
  echo "❌ npx not found. Run: npm install -g npx"
  exit 1
fi

echo "🔗 Connecting react-grab to: $AGENT"
echo ""

# Run grab add
npx -y grab@latest add "$AGENT"

echo ""
echo "✅ react-grab connected to $AGENT!"
echo ""

case "$AGENT" in
  claude-code)
    echo "📋 Usage with Claude Code:"
    echo "  1. Start your dev server"
    echo "  2. Hover over an element and press Cmd+C"
    echo "  3. Paste the clipboard content into your Claude Code prompt"
    echo "  4. Claude now has exact file path + component + HTML context"
    ;;
  mcp)
    echo "📋 Usage with MCP:"
    echo "  1. The react-grab MCP server runs locally"
    echo "  2. Your AI agent can call get_element_context tool"
    echo "  3. Select an element in browser first, then call the tool"
    ;;
  cursor)
    echo "📋 Usage with Cursor:"
    echo "  1. Select element in browser with react-grab"
    echo "  2. Paste clipboard into Cursor chat"
    ;;
  *)
    echo "📋 Select an element in the browser, then paste the clipboard into $AGENT."
    ;;
esac

echo ""
echo "To remove this integration: npx -y grab@latest remove $AGENT"

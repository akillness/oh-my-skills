#!/usr/bin/env bash
# LangSmith Setup Script
# Configures environment variables and installs dependencies for LangSmith tracing.
# Usage: bash setup.sh [--python | --typescript | --both]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }
err()  { echo -e "${RED}✗${NC} $*"; }

MODE="${1:-both}"

echo ""
echo "LangSmith Setup"
echo "==============="

# ── 1. Check API key ─────────────────────────────────────────────────────────
if [[ -z "${LANGSMITH_API_KEY:-}" ]]; then
  warn "LANGSMITH_API_KEY not set."
  echo "  Get your key at: https://smith.langchain.com → Settings → API Keys"
  echo ""
  read -rp "Enter LANGSMITH_API_KEY (or press Enter to skip): " api_key
  if [[ -n "$api_key" ]]; then
    export LANGSMITH_API_KEY="$api_key"
    ok "LANGSMITH_API_KEY set for this session"

    # Persist to shell profile
    PROFILE_FILE="${HOME}/.zshrc"
    [[ "$SHELL" == *"bash"* ]] && PROFILE_FILE="${HOME}/.bashrc"
    if ! grep -q "LANGSMITH_API_KEY" "$PROFILE_FILE" 2>/dev/null; then
      echo "" >> "$PROFILE_FILE"
      echo "# LangSmith" >> "$PROFILE_FILE"
      echo "export LANGSMITH_API_KEY=\"$api_key\"" >> "$PROFILE_FILE"
      echo "export LANGSMITH_TRACING=true" >> "$PROFILE_FILE"
      ok "Added to $PROFILE_FILE"
    else
      warn "LANGSMITH_API_KEY already in $PROFILE_FILE — skipped"
    fi
  fi
else
  ok "LANGSMITH_API_KEY already set"
fi

# ── 2. Set LANGSMITH_TRACING ─────────────────────────────────────────────────
if [[ -z "${LANGSMITH_TRACING:-}" ]]; then
  export LANGSMITH_TRACING=true
  info "Set LANGSMITH_TRACING=true"
else
  ok "LANGSMITH_TRACING=${LANGSMITH_TRACING}"
fi

# ── 3. Install Python SDK ─────────────────────────────────────────────────────
if [[ "$MODE" == "--python" || "$MODE" == "--both" || "$MODE" == "both" ]]; then
  info "Installing LangSmith Python SDK..."
  if command -v pip >/dev/null 2>&1; then
    pip install -U langsmith openai 2>&1 | tail -3
    ok "langsmith + openai installed"

    # Optional: openevals for prebuilt LLM evaluators
    read -rp "Install openevals for LLM-as-judge evaluators? [y/N]: " install_evals
    if [[ "$install_evals" =~ ^[Yy]$ ]]; then
      pip install -U openevals 2>&1 | tail -2
      ok "openevals installed"
    fi
  else
    warn "pip not found — install Python 3.8+ and pip first"
  fi
fi

# ── 4. Install TypeScript/JS SDK ─────────────────────────────────────────────
if [[ "$MODE" == "--typescript" || "$MODE" == "--both" || "$MODE" == "both" ]]; then
  info "Installing LangSmith TypeScript SDK..."
  if command -v npm >/dev/null 2>&1; then
    npm install langsmith openai 2>&1 | tail -3
    ok "langsmith + openai (npm) installed"
  elif command -v yarn >/dev/null 2>&1; then
    yarn add langsmith openai 2>&1 | tail -3
    ok "langsmith + openai (yarn) installed"
  else
    warn "npm/yarn not found — install Node.js first"
  fi
fi

# ── 5. Install LangSmith CLI ─────────────────────────────────────────────────
info "Checking LangSmith CLI..."
if ! command -v langsmith >/dev/null 2>&1; then
  read -rp "Install LangSmith CLI? [y/N]: " install_cli
  if [[ "$install_cli" =~ ^[Yy]$ ]]; then
    curl -sSL https://raw.githubusercontent.com/langchain-ai/langsmith-cli/main/scripts/install.sh | sh
    ok "LangSmith CLI installed"
  fi
else
  ok "LangSmith CLI already installed: $(langsmith --version 2>/dev/null || echo 'version unknown')"
fi

# ── 6. Verify connection ─────────────────────────────────────────────────────
echo ""
info "Verifying LangSmith connection..."
if [[ -n "${LANGSMITH_API_KEY:-}" ]]; then
  if python3 -c "
from langsmith import Client
try:
    c = Client()
    list(c.list_projects())
    print('Connection: OK')
except Exception as e:
    print(f'Connection error: {e}')
    exit(1)
" 2>/dev/null; then
    ok "LangSmith connection verified"
  else
    warn "Could not verify connection — check API key and network"
  fi
fi

echo ""
echo "LangSmith Setup Complete"
echo "========================"
echo "  Environment:"
echo "    LANGSMITH_API_KEY  = ${LANGSMITH_API_KEY:-<not set>}"
echo "    LANGSMITH_TRACING  = ${LANGSMITH_TRACING:-false}"
echo "    LANGSMITH_PROJECT  = ${LANGSMITH_PROJECT:-<default>}"
echo ""
echo "  Quick test:"
echo "    python3 scripts/quickstart.py"
echo ""
echo "  Docs: https://docs.langchain.com/langsmith"

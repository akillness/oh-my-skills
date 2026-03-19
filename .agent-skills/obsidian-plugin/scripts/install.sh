#!/usr/bin/env bash
# obsidian-plugin skill — development environment setup
# Sets up ESLint, TypeScript, and build toolchain for Obsidian plugin development

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Obsidian Plugin Development Setup ==="
echo ""

# Check Node.js
if ! command -v node &>/dev/null; then
  echo "ERROR: Node.js is required. Install from https://nodejs.org (v18+)"
  exit 1
fi

NODE_VERSION=$(node -e "process.stdout.write(process.versions.node)")
echo "✓ Node.js: $NODE_VERSION"

# Check npm
if ! command -v npm &>/dev/null; then
  echo "ERROR: npm is required."
  exit 1
fi
echo "✓ npm: $(npm --version)"

# Detect if we're in an Obsidian plugin project
if [[ -f "manifest.json" ]]; then
  echo ""
  echo "Detected existing plugin project: $(pwd)"
  PLUGIN_ID=$(node -e "try{const m=require('./manifest.json');process.stdout.write(m.id||'unknown')}catch(e){process.stdout.write('unknown')}")
  echo "Plugin ID: $PLUGIN_ID"

  # Install dependencies if package.json exists
  if [[ -f "package.json" ]]; then
    echo ""
    echo "Installing project dependencies..."
    npm install

    # Add eslint-plugin-obsidianmd if not present
    if ! node -e "require('eslint-plugin-obsidianmd')" &>/dev/null 2>&1; then
      echo "Installing eslint-plugin-obsidianmd..."
      npm install --save-dev eslint eslint-plugin-obsidianmd
    else
      echo "✓ eslint-plugin-obsidianmd already installed"
    fi
  fi

  # Check for ESLint config
  if [[ ! -f "eslint.config.mjs" ]] && [[ ! -f ".eslintrc.js" ]] && [[ ! -f ".eslintrc.json" ]]; then
    echo ""
    echo "Creating eslint.config.mjs..."
    cat > eslint.config.mjs << 'ESLINT_EOF'
import pluginObsidianmd from "eslint-plugin-obsidianmd";

export default [
  pluginObsidianmd.configs.recommended,
  {
    rules: {
      // Override specific rules here if needed
    }
  }
];
ESLINT_EOF
    echo "✓ Created eslint.config.mjs"
  fi

  echo ""
  echo "=== Setup Complete ==="
  echo ""
  echo "Next steps:"
  echo "  npm run dev        — start development watch mode"
  echo "  npm run build      — build production bundle"
  echo "  npx eslint src/    — run ESLint checks"
  echo "  npx eslint src/ --fix  — auto-fix ESLint issues"
else
  echo ""
  echo "No manifest.json found — starting new plugin setup..."
  echo ""
  echo "Running plugin boilerplate generator..."
  node "${SKILL_DIR}/scripts/create-plugin.js"
fi

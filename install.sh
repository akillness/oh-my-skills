#!/bin/bash

# Agent Skills One-Liner Installer v1.3.1
# Usage: curl -fsSL https://raw.githubusercontent.com/akillness/oh-my-skills/main/install.sh | bash
#
# Options (via environment variables):
#   INSTALL_GLOBAL=true   - Install to ~/.agent-skills (global) instead of current directory
#   INSTALL_MCP=true      - Auto-install MCP servers (opencontext required, gemini/codex optional)
#   SKIP_BACKUP=true      - Skip backup of existing .agent-skills
#   INSTALL_MODE=silent   - silent, auto, quick, interactive (default: silent)
#
# IMPORTANT: Shell RC Configuration
#   The Shell RC (.zshrc/.bashrc) modification is for DEVELOPER CONVENIENCE only.
#   AI agents access MCP tools through registered configs, NOT shell environment.
#   Default mode (silent) automatically skips Shell RC modification.
#
# Security Note:
#   For security-conscious users, download and inspect the script first:
#     curl -fsSLO https://raw.githubusercontent.com/akillness/oh-my-skills/main/install.sh
#     cat install.sh  # Review the script
#     bash install.sh

set -euo pipefail

# --- Configuration ---
REPO_URL="https://github.com/akillness/oh-my-skills.git"
TEMP_DIR="/tmp/_skills_setup_temp_$$"
AGENT_SKILLS_DIR_NAME=".agent-skills"
VERSION="1.3.1"

# Environment variable defaults
INSTALL_GLOBAL="${INSTALL_GLOBAL:-true}"  # Default: global installation to ~/.agent-skills
INSTALL_MCP="${INSTALL_MCP:-true}"
SKIP_BACKUP="${SKIP_BACKUP:-false}"
INSTALL_MODE="${INSTALL_MODE:-silent}"

# Determine installation path
if [ "$INSTALL_GLOBAL" = "true" ]; then
    AGENT_SKILLS_DIR="$HOME/$AGENT_SKILLS_DIR_NAME"
else
    AGENT_SKILLS_DIR="./$AGENT_SKILLS_DIR_NAME"
fi

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# --- Helper Functions ---
print_banner() {
    echo -e "${BLUE}"
    cat << 'BANNER'
    _                    _     ____  _    _ _ _
   / \   __ _  ___ _ __ | |_  / ___|| | _(_) | |___
  / _ \ / _` |/ _ \ '_ \| __| \___ \| |/ / | | / __|
 / ___ \ (_| |  __/ | | | |_   ___) |   <| | | \__ \
/_/   \_\__, |\___|_| |_|\__| |____/|_|\_\_|_|_|___/
        |___/
BANNER
    echo -e "${NC}"
    echo -e "${BOLD}One-Liner Installer v${VERSION}${NC}"
    echo ""
}

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_fatal() { echo -e "${RED}[FATAL]${NC} $1"; exit 1; }

check_dependencies() {
    print_info "Checking dependencies..."
    local missing_required=false

    # Check required: git
    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed."
        echo "  Install: https://git-scm.com/downloads"
        missing_required=true
    else
        print_success "Git installed ($(git --version | cut -d' ' -f3))"
    fi

    # Check required: curl or wget (for potential downloads)
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        print_warning "Neither curl nor wget found. Some features may be limited."
    fi

    # Exit if required dependencies missing
    if [ "$missing_required" = true ]; then
        echo ""
        print_error "Required dependencies missing. Please install them and try again."
        exit 1
    fi

    # Check optional: Claude CLI
    if command -v claude &> /dev/null; then
        print_success "Claude CLI installed ($(claude --version 2>/dev/null | head -n1 || echo 'version unknown'))"
        HAS_CLAUDE=true
    else
        print_warning "Claude CLI not installed. Some features may be limited."
        print_info "  Install: npm install -g @anthropic-ai/claude-code"
        HAS_CLAUDE=false
    fi

    # Check optional: Python3 (for token optimization)
    if command -v python3 &> /dev/null; then
        print_success "Python3 installed ($(python3 --version | cut -d' ' -f2))"
    else
        print_warning "Python3 not installed. Token optimization disabled."
    fi

    # Check optional: Node.js (for MCP servers)
    if command -v node &> /dev/null; then
        print_success "Node.js installed ($(node --version))"
    else
        print_warning "Node.js not installed. MCP server installation may fail."
        print_info "  Install: https://nodejs.org/"
    fi
}

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Set trap for cleanup on exit
trap cleanup EXIT

# --- Main Logic ---
main() {
    print_banner

    # Check dependencies
    check_dependencies
    echo ""

    # 1. Clone repository to a temporary directory
    print_info "Cloning skills-template repository..."
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    if ! git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR"; then
        print_fatal "Failed to clone repository. Check your network connection."
    fi
    print_success "Repository cloned"

    # 2. Backup existing .agent-skills if exists
    if [ -d "$AGENT_SKILLS_DIR" ]; then
        if [ "$SKIP_BACKUP" = "true" ]; then
            print_info "Removing existing $AGENT_SKILLS_DIR (backup skipped)..."
            rm -rf "$AGENT_SKILLS_DIR"
        else
            BACKUP_NAME="${AGENT_SKILLS_DIR}.bak.$(date +%Y%m%d_%H%M%S)"
            print_info "Backing up existing $AGENT_SKILLS_DIR to $BACKUP_NAME..."
            mv "$AGENT_SKILLS_DIR" "$BACKUP_NAME"
            print_success "Backup created: $BACKUP_NAME"
        fi
    fi

    # 3. Copy .agent-skills directory
    if [ "$INSTALL_GLOBAL" = "true" ]; then
        print_info "Installing agent skills to $AGENT_SKILLS_DIR (global)..."
    else
        print_info "Installing agent skills to current directory..."
    fi
    if ! cp -r "$TEMP_DIR/$AGENT_SKILLS_DIR_NAME" "$AGENT_SKILLS_DIR"; then
        print_fatal "Failed to copy agent skills. Check directory permissions."
    fi
    chmod +x "$AGENT_SKILLS_DIR/setup.sh"
    print_success "Agent skills installed at $AGENT_SKILLS_DIR"

    # 4. Run setup.sh with appropriate flags
    echo ""
    print_info "Running setup ($INSTALL_MODE mode)..."
    echo ""

    SETUP_FLAGS="--$INSTALL_MODE"
    if [ "$INSTALL_MCP" = "true" ]; then
        SETUP_FLAGS="$SETUP_FLAGS --install-mcp"
    fi

    if ! (cd "$AGENT_SKILLS_DIR" && ./setup.sh $SETUP_FLAGS); then
        print_error "setup.sh encountered issues. Running diagnostics..."
        (cd "$AGENT_SKILLS_DIR" && ./setup.sh --diagnose) || true
        print_warning "Setup completed with warnings. Check the output above."
    fi

    # 5. Final message (skip in silent mode for AI agents)
    if [ "$INSTALL_MODE" = "silent" ]; then
        # Silent mode: minimal output for AI agents
        echo ""
        print_success "Installation complete. Agent Skills ready at $AGENT_SKILLS_DIR"
        if [ "$INSTALL_GLOBAL" = "true" ]; then
            print_info "For shell convenience, add to ~/.zshrc or ~/.bashrc:"
            echo "  source $AGENT_SKILLS_DIR/mcp-shell-config.sh"
        fi
    else
        # Interactive/auto/quick mode: show full guide for developers
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}${GREEN}Installation Complete!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${BOLD}For AI Agents:${NC}"
        echo "  Installation is complete. No additional steps needed."
        echo "  AI agents access MCP tools through registered configs (not shell environment)."
        echo ""
        echo -e "${BOLD}For Developers (optional):${NC}"
        if [ "$INSTALL_GLOBAL" = "true" ]; then
            echo "  Global installation at: $AGENT_SKILLS_DIR"
            echo "  To enable shell aliases, add to ~/.zshrc or ~/.bashrc:"
            echo "    source $AGENT_SKILLS_DIR/mcp-shell-config.sh"
        else
            echo "  To enable shell aliases (gemini-skill, mcp-status, etc.):"
            echo "    source ~/.zshrc   # or ~/.bashrc"
        fi
        echo "  Note: This is for terminal convenience only, not required for agent workflows."
        echo ""
        echo -e "${BOLD}Verification:${NC}"
        if [ "$HAS_CLAUDE" = "true" ]; then
            echo "  claude mcp list                          # Check MCP servers"
        fi
        echo "  ./$AGENT_SKILLS_DIR/setup.sh --diagnose  # System diagnostics"
        echo ""
        echo -e "${BOLD}Documentation:${NC}"
        echo "  README.md                # Full documentation"
        echo "  CLAUDE.md                # Agent configuration"
        echo ""
    fi
}

main "$@"

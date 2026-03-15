#!/usr/bin/env bash
# firebase-cli/scripts/install.sh
# Install and configure the Firebase CLI (firebase-tools)
#
# Usage:
#   bash scripts/install.sh                      # Auto-detect and install
#   bash scripts/install.sh --method npm         # Force npm install
#   bash scripts/install.sh --method standalone  # Standalone binary (no Node required)
#   bash scripts/install.sh --method ci          # CI setup with service account
#   bash scripts/install.sh --version 13.5.0     # Install specific version
#   bash scripts/install.sh --init hosting       # Install + init a Firebase feature

set -euo pipefail

# ─── Color helpers ───────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_info()    { echo -e "${BLUE}[firebase-cli]${NC} $*"; }
log_success() { echo -e "${GREEN}[firebase-cli] ✅${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[firebase-cli] ⚠️${NC} $*"; }
log_error()   { echo -e "${RED}[firebase-cli] ❌${NC} $*" >&2; }

# ─── Defaults ────────────────────────────────────────────────────────────────
METHOD="auto"
FIREBASE_VERSION=""
INIT_FEATURE=""
CI_MODE=false

# ─── Parse arguments ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --method)       METHOD="$2";         shift 2 ;;
    --version)      FIREBASE_VERSION="$2"; shift 2 ;;
    --init)         INIT_FEATURE="$2";   shift 2 ;;
    --ci)           CI_MODE=true;         shift ;;
    -h|--help)
      echo "Usage: bash install.sh [--method npm|standalone|ci] [--version X.Y.Z] [--init <feature>] [--ci]"
      echo ""
      echo "Options:"
      echo "  --method npm         Install via npm install -g firebase-tools (default if Node.js found)"
      echo "  --method standalone  Install via standalone binary (no Node.js required)"
      echo "  --method ci          Configure CI/CD with service account credentials"
      echo "  --version X.Y.Z      Install a specific firebase-tools version"
      echo "  --init <feature>     Run firebase init <feature> after installing"
      echo "                       Features: hosting, functions, firestore, database, storage,"
      echo "                                emulators, remoteconfig, apphosting, genkit"
      echo "  --ci                 CI mode: non-interactive, no browser auth"
      exit 0
      ;;
    *)
      log_error "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# ─── Auto-detect method ──────────────────────────────────────────────────────
if [[ "$METHOD" == "auto" ]]; then
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    METHOD="npm"
    log_info "Detected Node.js + npm → using npm install method"
  else
    METHOD="standalone"
    log_warn "Node.js not found → using standalone binary install"
  fi
fi

# ─── Check existing installation ─────────────────────────────────────────────
if command -v firebase &>/dev/null; then
  CURRENT_VERSION=$(firebase --version 2>/dev/null || echo "unknown")
  log_info "Firebase CLI already installed: v${CURRENT_VERSION}"
  if [[ -z "$FIREBASE_VERSION" ]]; then
    log_info "Upgrading to latest..."
  fi
fi

# ─── Install ─────────────────────────────────────────────────────────────────
case "$METHOD" in
  npm)
    # Check Node.js version
    NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1 || echo "0")
    if [[ "$NODE_VERSION" -lt 18 ]]; then
      log_warn "Node.js v${NODE_VERSION} detected. Firebase CLI requires Node.js 18+."
      log_warn "Consider upgrading: https://nodejs.org"
    fi

    PACKAGE="firebase-tools"
    if [[ -n "$FIREBASE_VERSION" ]]; then
      PACKAGE="firebase-tools@${FIREBASE_VERSION}"
    fi

    log_info "Installing ${PACKAGE} via npm..."
    npm install -g "$PACKAGE"
    log_success "firebase-tools installed via npm"
    ;;

  standalone)
    if [[ "$(uname -s)" != "Darwin" && "$(uname -s)" != "Linux" ]]; then
      log_error "Standalone binary is only supported on macOS and Linux."
      log_info "On Windows, use: npm install -g firebase-tools"
      exit 1
    fi

    log_info "Installing Firebase CLI via standalone binary (no Node.js required)..."
    curl -sL https://firebase.tools | bash
    log_success "Firebase CLI standalone binary installed"
    ;;

  ci)
    log_info "Setting up Firebase CLI for CI/CD environment..."
    log_info ""
    log_info "Recommended: Use service account credentials (not --token / FIREBASE_TOKEN)"
    log_info ""
    log_info "Steps:"
    log_info "  1. Create a service account in Firebase console → Project Settings → Service accounts"
    log_info "  2. Grant required IAM roles:"
    log_info "     - Firebase Admin SDK Service Agent"
    log_info "     - Cloud Functions Admin (if deploying functions)"
    log_info "     - Cloud Build Service Account (if using Cloud Build)"
    log_info "  3. Download the JSON key file"
    log_info "  4. Set environment variable:"
    log_info "     export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json"
    log_info ""
    log_info "In CI (GitHub Actions example):"
    log_info "  - name: Deploy to Firebase"
    log_info "    env:"
    log_info "      GOOGLE_APPLICATION_CREDENTIALS: \${{ secrets.FIREBASE_SERVICE_ACCOUNT }}"
    log_info "    run: |"
    log_info "      npm install -g firebase-tools"
    log_info "      firebase deploy --only hosting --non-interactive"

    # Still install the CLI
    if command -v node &>/dev/null; then
      PACKAGE="firebase-tools"
      [[ -n "$FIREBASE_VERSION" ]] && PACKAGE="firebase-tools@${FIREBASE_VERSION}"
      npm install -g "$PACKAGE"
      log_success "firebase-tools installed for CI"
    fi
    exit 0
    ;;

  *)
    log_error "Unknown method: $METHOD. Use: npm, standalone, or ci"
    exit 1
    ;;
esac

# ─── Verify installation ─────────────────────────────────────────────────────
if ! command -v firebase &>/dev/null; then
  log_error "Installation failed: 'firebase' command not found in PATH"
  log_info "Try adding npm global bin to PATH: export PATH=\"\$(npm bin -g):\$PATH\""
  exit 1
fi

INSTALLED_VERSION=$(firebase --version 2>/dev/null || echo "unknown")
log_success "Firebase CLI installed: v${INSTALLED_VERSION}"

# ─── Authentication ───────────────────────────────────────────────────────────
if [[ "$CI_MODE" == "false" ]]; then
  if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]] && [[ -z "${FIREBASE_TOKEN:-}" ]]; then
    log_info ""
    log_info "Authenticating with Firebase..."
    log_info "(If you're in CI, set GOOGLE_APPLICATION_CREDENTIALS instead)"
    firebase login
  else
    log_info "Using existing credentials (GOOGLE_APPLICATION_CREDENTIALS or FIREBASE_TOKEN)"
  fi
fi

# ─── Optional: firebase init ──────────────────────────────────────────────────
if [[ -n "$INIT_FEATURE" ]]; then
  log_info ""
  log_info "Initializing Firebase feature: ${INIT_FEATURE}"
  firebase init "$INIT_FEATURE"
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
log_success ""
log_success "Firebase CLI setup complete!"
log_success ""
log_success "Quick reference:"
log_success "  firebase init         # Set up Firebase in current directory"
log_success "  firebase deploy       # Deploy everything"
log_success "  firebase emulators:start  # Run local emulators"
log_success "  firebase --help       # Full command list"
log_success ""
log_success "Full command reference: .agent-skills/firebase-cli/references/commands.md"

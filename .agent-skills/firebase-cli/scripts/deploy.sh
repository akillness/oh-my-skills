#!/usr/bin/env bash
# firebase-cli/scripts/deploy.sh
# Smart Firebase deployment helper with target detection and validation
#
# Usage:
#   bash scripts/deploy.sh                          # Deploy all configured targets
#   bash scripts/deploy.sh --only hosting           # Deploy specific target
#   bash scripts/deploy.sh --only hosting,functions # Multiple targets
#   bash scripts/deploy.sh --channel staging        # Deploy to preview channel
#   bash scripts/deploy.sh --except functions       # Skip a target
#   bash scripts/deploy.sh --dry-run                # Preview without deploying
#   bash scripts/deploy.sh --message "v2.3.1"       # Add deploy message

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_info()    { echo -e "${BLUE}[deploy]${NC} $*"; }
log_success() { echo -e "${GREEN}[deploy] ✅${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[deploy] ⚠️${NC} $*"; }
log_error()   { echo -e "${RED}[deploy] ❌${NC} $*" >&2; }

# ─── Defaults ────────────────────────────────────────────────────────────────
ONLY_TARGET=""
EXCEPT_TARGET=""
CHANNEL=""
CHANNEL_EXPIRES="7d"
MESSAGE=""
DRY_RUN=false
FORCE=false
DEBUG=false
NON_INTERACTIVE=false
PROJECT=""

# ─── Parse arguments ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)           ONLY_TARGET="$2";      shift 2 ;;
    --except)         EXCEPT_TARGET="$2";    shift 2 ;;
    --channel)        CHANNEL="$2";          shift 2 ;;
    --expires)        CHANNEL_EXPIRES="$2";  shift 2 ;;
    --message|-m)     MESSAGE="$2";          shift 2 ;;
    --project|-P)     PROJECT="$2";          shift 2 ;;
    --dry-run)        DRY_RUN=true;          shift ;;
    --force)          FORCE=true;            shift ;;
    --debug)          DEBUG=true;            shift ;;
    --non-interactive) NON_INTERACTIVE=true; shift ;;
    -h|--help)
      echo "Usage: bash deploy.sh [options]"
      echo ""
      echo "Options:"
      echo "  --only <targets>      Comma-separated deploy targets"
      echo "                        Values: hosting, functions, firestore, database, storage,"
      echo "                                remoteconfig, extensions, apphosting"
      echo "                        Sub-targets: hosting:site, functions:name, firestore:rules"
      echo "  --except <targets>    Comma-separated targets to skip"
      echo "  --channel <id>        Deploy to a Hosting preview channel"
      echo "  --expires <duration>  Channel expiry: 1h, 7d, 30d (default: 7d)"
      echo "  --message <msg>       Deploy message"
      echo "  --project <id>        Firebase project ID"
      echo "  --dry-run             Preview deployment without executing"
      echo "  --force               Skip confirmation prompts"
      echo "  --debug               Verbose debug output"
      echo "  --non-interactive     Disable interactive prompts (for CI)"
      exit 0
      ;;
    *)
      log_error "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# ─── Pre-flight checks ────────────────────────────────────────────────────────
if ! command -v firebase &>/dev/null; then
  log_error "Firebase CLI not found. Run: bash scripts/install.sh"
  exit 1
fi

if [[ ! -f "firebase.json" ]]; then
  log_warn "firebase.json not found in current directory: $(pwd)"
  log_warn "Run 'firebase init' to set up Firebase in this project."
  exit 1
fi

# ─── Build deploy command ─────────────────────────────────────────────────────
DEPLOY_CMD="firebase deploy"

[[ -n "$PROJECT" ]]         && DEPLOY_CMD+=" --project ${PROJECT}"
[[ -n "$ONLY_TARGET" ]]     && DEPLOY_CMD+=" --only ${ONLY_TARGET}"
[[ -n "$EXCEPT_TARGET" ]]   && DEPLOY_CMD+=" --except ${EXCEPT_TARGET}"
[[ -n "$MESSAGE" ]]         && DEPLOY_CMD+=" --message \"${MESSAGE}\""
[[ "$FORCE" == "true" ]]    && DEPLOY_CMD+=" --force"
[[ "$DEBUG" == "true" ]]    && DEPLOY_CMD+=" --debug"
[[ "$NON_INTERACTIVE" == "true" ]] && DEPLOY_CMD+=" --non-interactive"

# ─── Preview channel deploy ───────────────────────────────────────────────────
if [[ -n "$CHANNEL" ]]; then
  log_info "Deploying to preview channel: ${CHANNEL}"
  log_info "Channel expires: ${CHANNEL_EXPIRES}"

  CHANNEL_CMD="firebase hosting:channel:deploy ${CHANNEL} --expires ${CHANNEL_EXPIRES}"
  [[ -n "$PROJECT" ]] && CHANNEL_CMD+=" --project ${PROJECT}"
  [[ "$DEBUG" == "true" ]] && CHANNEL_CMD+=" --debug"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would execute: ${CHANNEL_CMD}"
    exit 0
  fi

  # Create channel if it doesn't exist
  log_info "Ensuring preview channel exists..."
  firebase hosting:channel:create "${CHANNEL}" --expires "${CHANNEL_EXPIRES}" 2>/dev/null || true

  log_info "Deploying to channel..."
  eval "$CHANNEL_CMD"

  CHANNEL_URL=$(firebase hosting:channel:open "${CHANNEL}" --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('url',''))" 2>/dev/null || echo "")
  log_success "Channel deploy complete!"
  [[ -n "$CHANNEL_URL" ]] && log_success "Preview URL: ${CHANNEL_URL}"
  exit 0
fi

# ─── Dry run ─────────────────────────────────────────────────────────────────
if [[ "$DRY_RUN" == "true" ]]; then
  log_info "[DRY RUN] Would execute: ${DEPLOY_CMD}"
  log_info ""
  log_info "firebase.json targets configured:"
  python3 -c "
import json, os
try:
    cfg = json.load(open('firebase.json'))
    targets = [k for k in cfg.keys() if k not in ('emulators',)]
    for t in targets:
        print(f'  - {t}')
except Exception as e:
    print(f'  (could not parse firebase.json: {e})')
" 2>/dev/null || true
  exit 0
fi

# ─── Deploy ───────────────────────────────────────────────────────────────────
log_info "Starting Firebase deploy..."
log_info "Command: ${DEPLOY_CMD}"

START_TIME=$(date +%s)
eval "$DEPLOY_CMD"
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

log_success "Deploy complete in ${DURATION}s"

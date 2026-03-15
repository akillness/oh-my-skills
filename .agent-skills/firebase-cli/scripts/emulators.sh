#!/usr/bin/env bash
# firebase-cli/scripts/emulators.sh
# Firebase Emulator Suite management helper
#
# Usage:
#   bash scripts/emulators.sh                              # Start all configured emulators
#   bash scripts/emulators.sh --only auth,firestore        # Start specific emulators
#   bash scripts/emulators.sh --import ./emulator-data     # Import data on start
#   bash scripts/emulators.sh --persistent                 # Import + export-on-exit
#   bash scripts/emulators.sh --test "npm test"            # Run script with emulators
#   bash scripts/emulators.sh --export ./data              # Export from running emulators
#   bash scripts/emulators.sh --inspect                    # Enable Functions debugger

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_info()    { echo -e "${BLUE}[emulators]${NC} $*"; }
log_success() { echo -e "${GREEN}[emulators] ✅${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[emulators] ⚠️${NC} $*"; }
log_error()   { echo -e "${RED}[emulators] ❌${NC} $*" >&2; }

# ─── Defaults ────────────────────────────────────────────────────────────────
ONLY=""
IMPORT_DIR=""
EXPORT_DIR=""
PERSISTENT=false
TEST_SCRIPT=""
EXPORT_ONLY=false
INSPECT=false
INSPECT_PORT=9229
NO_UI=false
LOG_VERBOSITY=""
PROJECT=""

# ─── Parse arguments ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)           ONLY="$2";           shift 2 ;;
    --import)         IMPORT_DIR="$2";     shift 2 ;;
    --export)         EXPORT_DIR="$2"; EXPORT_ONLY=true; shift 2 ;;
    --persistent)     PERSISTENT=true;     shift ;;
    --test)           TEST_SCRIPT="$2";    shift 2 ;;
    --inspect)        INSPECT=true;        shift ;;
    --inspect-port)   INSPECT_PORT="$2";   shift 2 ;;
    --no-ui)          NO_UI=true;          shift ;;
    --log-verbosity)  LOG_VERBOSITY="$2";  shift 2 ;;
    --project|-P)     PROJECT="$2";        shift 2 ;;
    -h|--help)
      echo "Usage: bash emulators.sh [options]"
      echo ""
      echo "Options:"
      echo "  --only <list>         Comma-separated emulators to start"
      echo "                        Values: auth, functions, firestore, database,"
      echo "                                hosting, pubsub, storage, apphosting, eventarc"
      echo "  --import <dir>        Import data from directory on start"
      echo "  --export <dir>        Export data from running emulators (requires --export-only)"
      echo "  --persistent          Import from ./emulator-data and export on exit"
      echo "  --test <script>       Run script against emulators then shut down"
      echo "  --inspect             Enable Node.js debugger for Cloud Functions (port 9229)"
      echo "  --inspect-port <port> Custom debugger port (default: 9229)"
      echo "  --no-ui               Disable Emulator Suite UI"
      echo "  --log-verbosity <lv>  DEBUG | INFO | QUIET | SILENT"
      echo "  --project <id>        Firebase project ID"
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

# Check if emulators are configured in firebase.json
if [[ ! -f "firebase.json" ]]; then
  log_warn "firebase.json not found. Run 'firebase init emulators' first."
  exit 1
fi

# ─── Export mode ─────────────────────────────────────────────────────────────
if [[ "$EXPORT_ONLY" == "true" ]]; then
  EXPORT_TARGET="${EXPORT_DIR:-./emulator-data}"
  log_info "Exporting emulator data to: ${EXPORT_TARGET}"
  CMD="firebase emulators:export ${EXPORT_TARGET} --force"
  [[ -n "$PROJECT" ]] && CMD+=" --project ${PROJECT}"
  eval "$CMD"
  log_success "Data exported to ${EXPORT_TARGET}"
  exit 0
fi

# ─── Persistent mode setup ───────────────────────────────────────────────────
if [[ "$PERSISTENT" == "true" ]]; then
  IMPORT_DIR="${IMPORT_DIR:-./emulator-data}"
  EXPORT_DIR="${EXPORT_DIR:-./emulator-data}"
  mkdir -p "$IMPORT_DIR"
  log_info "Persistent mode: import from ${IMPORT_DIR}, export on exit to ${EXPORT_DIR}"
fi

# ─── Build command ────────────────────────────────────────────────────────────
if [[ -n "$TEST_SCRIPT" ]]; then
  CMD="firebase emulators:exec"
else
  CMD="firebase emulators:start"
fi

[[ -n "$PROJECT" ]]          && CMD+=" --project ${PROJECT}"
[[ -n "$ONLY" ]]             && CMD+=" --only ${ONLY}"
[[ -n "$IMPORT_DIR" ]]       && CMD+=" --import ${IMPORT_DIR}"
[[ -n "$EXPORT_DIR" ]]       && [[ -z "$TEST_SCRIPT" ]] && CMD+=" --export-on-exit ${EXPORT_DIR}"
[[ -n "$EXPORT_DIR" ]]       && [[ -n "$TEST_SCRIPT" ]] && CMD+=" --export-on-exit ${EXPORT_DIR}"
[[ "$INSPECT" == "true" ]]   && CMD+=" --inspect-functions ${INSPECT_PORT}"
[[ "$NO_UI" == "true" ]]     && CMD+=" --no-ui"
[[ -n "$LOG_VERBOSITY" ]]    && CMD+=" --log-verbosity ${LOG_VERBOSITY}"
[[ -n "$TEST_SCRIPT" ]]      && CMD+=" \"${TEST_SCRIPT}\""

# ─── Default ports info ───────────────────────────────────────────────────────
log_info "Starting Firebase Emulator Suite..."
log_info ""
log_info "Default ports:"
log_info "  Auth:        http://localhost:9099"
log_info "  Functions:   http://localhost:5001"
log_info "  Firestore:   http://localhost:8080"
log_info "  Database:    http://localhost:9000"
log_info "  Hosting:     http://localhost:5000"
log_info "  Storage:     http://localhost:9199"
log_info "  Pub/Sub:     http://localhost:8085"
log_info "  Emulator UI: http://localhost:4000"
log_info ""
log_info "Command: ${CMD}"
log_info ""

# ─── Execute ──────────────────────────────────────────────────────────────────
eval "$CMD"

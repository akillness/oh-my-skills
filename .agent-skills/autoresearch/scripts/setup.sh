#!/usr/bin/env bash
# setup.sh — One-time autoresearch environment setup
# Installs uv, clones karpathy/autoresearch, syncs dependencies, prepares dataset
#
# Usage:
#   bash setup.sh [--dir <target-dir>] [--skip-data] [--seq-len <N>]
#
# Options:
#   --dir <path>    Clone into this directory (default: ./autoresearch)
#   --skip-data     Skip uv run prepare.py (dataset download, ~2 min)
#   --seq-len <N>   Override MAX_SEQ_LEN in prepare.py before running it
#                   (useful for low-VRAM GPUs: try 256 or 512)

set -euo pipefail

TARGET_DIR="./autoresearch"
SKIP_DATA=0
SEQ_LEN=""

# ── Argument parsing ────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)     TARGET_DIR="$2"; shift 2 ;;
    --skip-data) SKIP_DATA=1; shift ;;
    --seq-len) SEQ_LEN="$2"; shift 2 ;;
    --help)
      sed -n '2,12p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

log()  { echo "[setup] $*"; }
err()  { echo "[setup] ERROR: $*" >&2; }
warn() { echo "[setup] WARN:  $*" >&2; }

# ── Step 1: Install uv if missing ───────────────────────────────────────────
if ! command -v uv &>/dev/null; then
  log "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.local/bin:${PATH}"
  if ! command -v uv &>/dev/null; then
    err "uv install succeeded but binary not found. Restart shell and retry."
    exit 1
  fi
  log "uv installed: $(uv --version)"
else
  log "uv already installed: $(uv --version)"
fi

# ── Step 2: Clone repo ──────────────────────────────────────────────────────
if [[ -d "${TARGET_DIR}/.git" ]]; then
  log "Repository already exists at ${TARGET_DIR} — skipping clone"
else
  log "Cloning karpathy/autoresearch into ${TARGET_DIR}..."
  git clone https://github.com/karpathy/autoresearch "${TARGET_DIR}"
fi

cd "${TARGET_DIR}"

# ── Step 3: Sync dependencies ───────────────────────────────────────────────
log "Syncing dependencies (uv sync)..."
uv sync
log "Dependencies installed"

# ── Step 4: Optional MAX_SEQ_LEN override ───────────────────────────────────
if [[ -n "${SEQ_LEN}" ]]; then
  warn "Overriding MAX_SEQ_LEN → ${SEQ_LEN} in prepare.py"
  # Backup original
  cp prepare.py prepare.py.bak
  sed -i "s/MAX_SEQ_LEN\s*=\s*[0-9]*/MAX_SEQ_LEN = ${SEQ_LEN}/" prepare.py
  log "MAX_SEQ_LEN set to ${SEQ_LEN} (backup: prepare.py.bak)"
fi

# ── Step 5: Prepare dataset ─────────────────────────────────────────────────
if [[ "${SKIP_DATA}" -eq 1 ]]; then
  warn "Skipping data preparation (--skip-data). Run 'uv run prepare.py' manually before training."
else
  log "Preparing dataset (FineWeb-Edu shards + BPE tokenizer). This takes ~2 minutes..."
  uv run prepare.py
  log "Dataset ready"
fi

# ── Done ────────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  autoresearch setup complete"
echo "  Directory : ${TARGET_DIR}"
echo "  Next step : bash scripts/run-experiment.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

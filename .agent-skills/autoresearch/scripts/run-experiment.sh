#!/usr/bin/env bash
# run-experiment.sh — Run a single 5-minute autoresearch experiment
# Executes uv run train.py, captures output, extracts val_bpb and peak_vram_mb
#
# Usage:
#   bash scripts/run-experiment.sh [--repo <path>] [--log <logfile>]
#
# Options:
#   --repo <path>   Path to autoresearch repo (default: .)
#   --log  <file>   Log file path (default: run.log in repo root)
#
# Output (stdout, tab-separated):
#   val_bpb  peak_vram_mb  duration_s  log_path
# Exit codes:
#   0  Experiment completed, metrics extracted
#   1  Missing val_bpb in output (likely crash/OOM)
#   2  Experiment timed out (> 360s)

set -uo pipefail

REPO_DIR="."
LOG_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO_DIR="$2"; shift 2 ;;
    --log)  LOG_FILE="$2";  shift 2 ;;
    --help)
      sed -n '2,16p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

cd "${REPO_DIR}"

LOG_FILE="${LOG_FILE:-run.log}"
TIMEOUT=360   # 60s grace over the 300s TIME_BUDGET

log()  { echo "[run-experiment] $*" >&2; }
err()  { echo "[run-experiment] ERROR: $*" >&2; }

# ── Sanity checks ────────────────────────────────────────────────────────────
if [[ ! -f "train.py" ]]; then
  err "train.py not found. Are you in the autoresearch repo? Use --repo <path>"
  exit 1
fi

if ! command -v uv &>/dev/null; then
  err "uv not found. Run setup.sh first."
  exit 1
fi

# ── Run experiment ───────────────────────────────────────────────────────────
log "Starting experiment (TIME_BUDGET=300s)..."
START_TS=$(date +%s)

if ! timeout "${TIMEOUT}" uv run train.py > "${LOG_FILE}" 2>&1; then
  EXIT_CODE=$?
  END_TS=$(date +%s)
  DURATION=$(( END_TS - START_TS ))

  if [[ "${EXIT_CODE}" -eq 124 ]]; then
    err "Experiment timed out after ${DURATION}s (timeout=${TIMEOUT}s)"
    exit 2
  fi

  # Non-zero but not timeout — might still have written metrics before crash
  log "train.py exited with code ${EXIT_CODE} after ${DURATION}s — checking for partial metrics..."
fi

END_TS=$(date +%s)
DURATION=$(( END_TS - START_TS ))

# ── Extract metrics ───────────────────────────────────────────────────────────
VAL_BPB=$(grep "^val_bpb:" "${LOG_FILE}" | tail -1 | awk '{print $2}')
PEAK_VRAM=$(grep "^peak_vram_mb:" "${LOG_FILE}" | tail -1 | awk '{print $2}')

if [[ -z "${VAL_BPB}" ]]; then
  err "val_bpb not found in ${LOG_FILE} — experiment likely crashed (OOM or syntax error)"
  err "Last 10 lines of log:"
  tail -10 "${LOG_FILE}" >&2
  exit 1
fi

PEAK_VRAM="${PEAK_VRAM:-N/A}"

log "Experiment complete in ${DURATION}s"
log "val_bpb=${VAL_BPB}  peak_vram_mb=${PEAK_VRAM}"

# ── Structured output (stdout) ────────────────────────────────────────────────
printf "%s\t%s\t%s\t%s\n" "${VAL_BPB}" "${PEAK_VRAM}" "${DURATION}" "$(realpath "${LOG_FILE}")"

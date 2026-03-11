#!/usr/bin/env bash
# run-loop.sh — Autonomous autoresearch experiment loop
# Runs experiments, evaluates val_bpb, keeps improvements, reverts failures.
# Appends every run (keep/discard/crash) to results.tsv.
#
# Usage:
#   bash scripts/run-loop.sh [--repo <path>] [--max <N>] [--desc "<text>"]
#
# Options:
#   --repo  <path>   Path to autoresearch repo (default: .)
#   --max   <N>      Max experiments to run (default: 20, 0 = unlimited)
#   --desc  <text>   Experiment description prefix for results.tsv
#
# The loop:
#   1. Run train.py for 300 seconds
#   2. Extract val_bpb from output
#   3. Compare against current best
#   4. Keep commit if improved, git-reset if not
#   5. Append to results.tsv
#   6. Repeat

set -uo pipefail

REPO_DIR="."
MAX_EXPERIMENTS=20
DESC_PREFIX="auto"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)  REPO_DIR="$2";       shift 2 ;;
    --max)   MAX_EXPERIMENTS="$2"; shift 2 ;;
    --desc)  DESC_PREFIX="$2";     shift 2 ;;
    --help)
      sed -n '2,17p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

cd "${REPO_DIR}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { echo "[run-loop] $*"; }
err()  { echo "[run-loop] ERROR: $*" >&2; }
warn() { echo "[run-loop] WARN:  $*" >&2; }

# ── Sanity checks ─────────────────────────────────────────────────────────────
for f in train.py results.tsv; do
  if [[ ! -f "${f}" ]]; then
    if [[ "${f}" == "results.tsv" ]]; then
      log "Creating results.tsv..."
      printf "commit\tval_bpb\tpeak_vram_mb\tstatus\tdescription\n" > results.tsv
    else
      err "${f} not found. Are you in the autoresearch repo? Use --repo <path>"
      exit 1
    fi
  fi
done

if ! command -v uv &>/dev/null; then
  err "uv not found. Run setup.sh first."
  exit 1
fi

# ── Baseline ──────────────────────────────────────────────────────────────────
# Read best val_bpb from results.tsv (kept experiments only)
get_best_bpb() {
  awk -F'\t' 'NR>1 && $4=="keep" {print $2}' results.tsv \
    | sort -n | head -1
}

BEST_BPB=$(get_best_bpb)
if [[ -z "${BEST_BPB}" ]]; then
  log "No kept experiments found in results.tsv — running baseline first..."
  BEST_BPB="99.0"  # sentinel: accept first experiment unconditionally
fi
log "Current best val_bpb: ${BEST_BPB}"

# ── Loop ──────────────────────────────────────────────────────────────────────
EXPERIMENT=0

while true; do
  EXPERIMENT=$(( EXPERIMENT + 1 ))
  if [[ "${MAX_EXPERIMENTS}" -gt 0 && "${EXPERIMENT}" -gt "${MAX_EXPERIMENTS}" ]]; then
    log "Reached max experiments (${MAX_EXPERIMENTS}). Stopping."
    break
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "Experiment ${EXPERIMENT}/${MAX_EXPERIMENTS} | best_so_far=${BEST_BPB}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  LOG_FILE="run_${EXPERIMENT}.log"

  # ── Run experiment ────────────────────────────────────────────────────────
  RESULT=$(bash "${SCRIPT_DIR}/run-experiment.sh" \
    --repo "." \
    --log "${LOG_FILE}" 2>/dev/null) || RUN_EXIT=$?

  RUN_EXIT="${RUN_EXIT:-0}"

  # ── Handle crash / timeout ────────────────────────────────────────────────
  if [[ "${RUN_EXIT}" -ne 0 ]]; then
    COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    STATUS="crash"
    BPB="crash"
    VRAM="N/A"
    DESCRIPTION="${DESC_PREFIX}: experiment ${EXPERIMENT} — crashed (exit ${RUN_EXIT})"
    warn "Experiment crashed (exit ${RUN_EXIT}). Reverting commit..."
    git reset HEAD~1 2>/dev/null || true
  else
    BPB=$(echo "${RESULT}"   | cut -f1)
    VRAM=$(echo "${RESULT}"  | cut -f2)

    # ── Compare and decide ────────────────────────────────────────────────
    COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

    if awk "BEGIN { exit !(${BPB} < ${BEST_BPB}) }"; then
      STATUS="keep"
      IMPROVEMENT=$(awk "BEGIN { printf \"%.4f\", ${BEST_BPB} - ${BPB} }")
      BEST_BPB="${BPB}"
      DESCRIPTION="${DESC_PREFIX}: experiment ${EXPERIMENT} — improved by ${IMPROVEMENT}"
      log "IMPROVED  val_bpb=${BPB}  (delta=-${IMPROVEMENT})  KEEPING commit ${COMMIT}"
    else
      STATUS="discard"
      DESCRIPTION="${DESC_PREFIX}: experiment ${EXPERIMENT} — no improvement (val_bpb=${BPB} >= ${BEST_BPB})"
      log "NO IMPROVEMENT  val_bpb=${BPB} >= best=${BEST_BPB}  REVERTING..."
      git reset HEAD~1 2>/dev/null || warn "git reset failed — may be at initial commit"
    fi
  fi

  # ── Append to results.tsv ─────────────────────────────────────────────────
  printf "%s\t%s\t%s\t%s\t%s\n" \
    "${COMMIT}" "${BPB}" "${VRAM}" "${STATUS}" "${DESCRIPTION}" \
    >> results.tsv

  log "Logged: ${STATUS} | ${DESCRIPTION}"
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Run loop complete"
KEPT=$(awk -F'\t' 'NR>1 && $4=="keep" {c++} END {print c+0}' results.tsv)
TOTAL=$(awk -F'\t' 'NR>1 {c++} END {print c+0}' results.tsv)
echo "  Experiments run  : ${EXPERIMENT}"
echo "  Improvements kept: ${KEPT} / ${TOTAL} total"
echo "  Best val_bpb     : ${BEST_BPB}"
echo "  Results          : results.tsv"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

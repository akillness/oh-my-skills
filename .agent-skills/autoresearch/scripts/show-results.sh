#!/usr/bin/env bash
# show-results.sh — Parse and display autoresearch results.tsv
# Shows statistics, best experiments, and improvement history.
#
# Usage:
#   bash scripts/show-results.sh [--repo <path>] [--top <N>] [--kept-only]
#
# Options:
#   --repo      <path>  Path to autoresearch repo (default: .)
#   --top       <N>     Show top N experiments by val_bpb (default: 10)
#   --kept-only         Show only experiments that were kept

set -uo pipefail

REPO_DIR="."
TOP_N=10
KEPT_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)      REPO_DIR="$2"; shift 2 ;;
    --top)       TOP_N="$2";    shift 2 ;;
    --kept-only) KEPT_ONLY=1;   shift ;;
    --help)
      sed -n '2,13p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

cd "${REPO_DIR}"

if [[ ! -f "results.tsv" ]]; then
  echo "results.tsv not found. Have you run any experiments yet?" >&2
  exit 1
fi

# ── Overall statistics ────────────────────────────────────────────────────────
TOTAL=$(awk  -F'\t' 'NR>1 {c++} END {print c+0}' results.tsv)
KEPT=$(awk   -F'\t' 'NR>1 && $4=="keep"    {c++} END {print c+0}' results.tsv)
DISCARD=$(awk -F'\t' 'NR>1 && $4=="discard" {c++} END {print c+0}' results.tsv)
CRASHED=$(awk -F'\t' 'NR>1 && $4=="crash"   {c++} END {print c+0}' results.tsv)

BEST_BPB=$(awk -F'\t' 'NR>1 && $4=="keep" && $2~/^[0-9]/ {print $2}' results.tsv \
  | sort -n | head -1)
FIRST_BPB=$(awk -F'\t' 'NR>1 && $2~/^[0-9]/ {print $2; exit}' results.tsv)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  autoresearch — Results Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  Total experiments : %s\n" "${TOTAL}"
printf "  Kept (improved)   : %s\n" "${KEPT}"
printf "  Discarded         : %s\n" "${DISCARD}"
printf "  Crashed           : %s\n" "${CRASHED}"
echo ""
if [[ -n "${FIRST_BPB}" && -n "${BEST_BPB}" ]]; then
  DELTA=$(awk "BEGIN { printf \"%.4f\", ${FIRST_BPB} - ${BEST_BPB} }")
  printf "  Starting val_bpb  : %s\n" "${FIRST_BPB}"
  printf "  Best val_bpb      : %s  (delta: -%s)\n" "${BEST_BPB}" "${DELTA}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Top experiments ───────────────────────────────────────────────────────────
echo ""
echo "Top ${TOP_N} experiments by val_bpb:"
echo ""
printf "  %-10s  %-8s  %-14s  %-8s  %s\n" "COMMIT" "VAL_BPB" "PEAK_VRAM_MB" "STATUS" "DESCRIPTION"
echo "  ─────────────────────────────────────────────────────────────────"

AWK_FILTER='NR>1 && $2~/^[0-9]/'
if [[ "${KEPT_ONLY}" -eq 1 ]]; then
  AWK_FILTER='NR>1 && $4=="keep" && $2~/^[0-9]/'
fi

awk -F'\t' "${AWK_FILTER} {print}" results.tsv \
  | sort -t$'\t' -k2 -n \
  | head -"${TOP_N}" \
  | while IFS=$'\t' read -r commit bpb vram status desc; do
      # Truncate description to 40 chars
      short_desc="${desc:0:40}"
      [[ "${#desc}" -gt 40 ]] && short_desc="${short_desc}..."
      printf "  %-10s  %-8s  %-14s  %-8s  %s\n" \
        "${commit}" "${bpb}" "${vram}" "${status}" "${short_desc}"
    done

# ── Improvement timeline ──────────────────────────────────────────────────────
echo ""
echo "Improvement timeline (kept only):"
echo ""
printf "  %-10s  %-8s  %-14s  %s\n" "COMMIT" "VAL_BPB" "DELTA" "DESCRIPTION"
echo "  ─────────────────────────────────────────────────────────────────"

PREV_BPB=""
awk -F'\t' 'NR>1 && $4=="keep" && $2~/^[0-9]/ {print}' results.tsv \
  | while IFS=$'\t' read -r commit bpb vram status desc; do
      if [[ -z "${PREV_BPB}" ]]; then
        delta="baseline"
      else
        delta=$(awk "BEGIN { printf \"%.4f\", ${PREV_BPB} - ${bpb} }")
        delta="-${delta}"
      fi
      PREV_BPB="${bpb}"
      short_desc="${desc:0:35}"
      [[ "${#desc}" -gt 35 ]] && short_desc="${short_desc}..."
      printf "  %-10s  %-8s  %-14s  %s\n" \
        "${commit}" "${bpb}" "${delta}" "${short_desc}"
    done

echo ""

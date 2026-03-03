#!/bin/bash
# AI Tool Compliance - 배포 게이트 판단
#
# Exit codes:
#   0 = APPROVE  (총점 90+ AND P0=0)
#   1 = WARNING  (P0>0 warn모드, 또는 총점 80-89, 또는 P1>=3)
#   2 = BLOCK    (P0>0 block모드, 또는 총점 <80 block모드)
#
# 모드 우선순위:
#   1. --mode 인수
#   2. COMPLIANCE_MODE 환경변수
#   3. .ai-tool-compliance.yaml mode 필드
#   4. warn_until 날짜 자동 전환 (auto_transition: true)
#   5. 기본값: warn
#
# Usage: bash scripts/gate.sh [--score-file FILE] [--mode warn|block]

set -euo pipefail

SCORE_FILE="/tmp/compliance-score.json"
MODE_ARG=""
CONFIG=".ai-tool-compliance.yaml"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

while [[ $# -gt 0 ]]; do
  case $1 in
    --score-file) SCORE_FILE="$2"; shift 2 ;;
    --mode)       MODE_ARG="$2";   shift 2 ;;
    --help|-h)
      echo "Usage: bash scripts/gate.sh [--score-file FILE] [--mode warn|block]"
      echo ""
      echo "Exit codes: 0=APPROVE, 1=WARNING, 2=BLOCK"
      exit 0
      ;;
    *) shift ;;
  esac
done

if [ ! -f "$SCORE_FILE" ]; then
  echo -e "${RED}[gate] 점수 파일 없음: $SCORE_FILE${NC}"
  exit 2
fi

# ── 모드 결정 ──────────────────────────────────────────────────
determine_mode() {
  # 1순위: 직접 인수
  if [ -n "$MODE_ARG" ]; then
    echo "$MODE_ARG"; return
  fi

  # 2순위: 환경변수
  if [ -n "${COMPLIANCE_MODE:-}" ]; then
    echo "$COMPLIANCE_MODE"; return
  fi

  # 3순위: config 파일
  if [ -f "$CONFIG" ]; then
    local config_mode auto warn_until today

    config_mode=$(grep '^mode:' "$CONFIG" 2>/dev/null \
      | awk '{print $2}' | tr -d '"' || echo "warn")

    # auto_transition 날짜 체크
    auto=$(grep 'auto_transition:' "$CONFIG" 2>/dev/null \
      | awk '{print $2}' || echo "false")
    warn_until=$(grep 'warn_until:' "$CONFIG" 2>/dev/null \
      | awk '{print $2}' | tr -d '"' || echo "")

    if [ "$auto" = "true" ] && [ -n "$warn_until" ]; then
      today=$(date -u +"%Y-%m-%d")
      if [[ "$today" > "$warn_until" ]]; then
        echo "block"; return
      fi
    fi

    echo "$config_mode"; return
  fi

  # 기본값
  echo "warn"
}

EFFECTIVE_MODE=$(determine_mode)

# ── 점수 데이터 읽기 ───────────────────────────────────────────
TOTAL=$(jq '.p0_gate_score // .total_score' "$SCORE_FILE")
P0_FAILS=$(jq '.p0_fail_total' "$SCORE_FILE")
P1_FAILS=$(jq '.p1_fail_total' "$SCORE_FILE")
GRADE=$(jq -r '.grade' "$SCORE_FILE")
P1_MATURITY=$(jq '.p1_maturity_score // .p1.maturity_score // 0' "$SCORE_FILE")

# ── 판정 출력 ──────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  AI Tool Compliance Gate${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "  Mode:  $EFFECTIVE_MODE"
echo "  Score: $TOTAL/100 ($GRADE)"
echo "  P0:    $P0_FAILS fails"
echo "  P1:    $P1_FAILS fails"
echo "  P1 Maturity: $P1_MATURITY/100"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ── 게이트 판정 로직 ───────────────────────────────────────────

# P0 위반 존재 시
if [ "$P0_FAILS" -gt 0 ]; then
  if [ "$EFFECTIVE_MODE" = "block" ]; then
    echo -e "${RED}[BLOCK] P0 위반 ${P0_FAILS}건 → 배포 차단${NC}"
    exit 2
  else
    echo -e "${YELLOW}[WARNING] P0 위반 ${P0_FAILS}건 탐지 (warn 모드: 차단 없음)${NC}"
    echo "  P0 위반을 수정하세요. block 모드 전환 후 재실행 시 차단됩니다."
    exit 1
  fi
fi

# 총점 기준 판정 (P0=0 확인됨)
if [ "$(echo "$TOTAL >= 90" | bc -l 2>/dev/null || awk "BEGIN{print ($TOTAL >= 90)}")" = "1" ]; then
  echo -e "${GREEN}[APPROVE] 총점 ${TOTAL}/100 (${GRADE}), P0 위반 없음${NC}"
  exit 0

elif [ "$(echo "$TOTAL >= 80" | bc -l 2>/dev/null || awk "BEGIN{print ($TOTAL >= 80)}")" = "1" ]; then
  echo -e "${YELLOW}[WARNING] 총점 ${TOTAL}/100 (${GRADE}), P1 ${P1_FAILS}건${NC}"
  echo "  P1 위반 항목을 검토하고 개선하세요."
  exit 1

else
  if [ "$EFFECTIVE_MODE" = "block" ]; then
    echo -e "${RED}[BLOCK] 총점 ${TOTAL}/100 (${GRADE}) — 기준 80점 미달 → 배포 차단${NC}"
    exit 2
  else
    echo -e "${YELLOW}[WARNING] 총점 ${TOTAL}/100 (${GRADE}) — 기준 80점 미달 (warn 모드: 차단 없음)${NC}"
    exit 1
  fi
fi

#!/bin/bash
# AI Tool Compliance - Slack Block Kit 알림
# P0 위반 즉시 알림, 위반 상세 포함
#
# 웹훅 URL 우선순위:
#   1. SLACK_WEBHOOK_URL 환경변수
#   2. .ai-tool-compliance.yaml notifications.slack_webhook
#   3. 미설정 시 스킵 (exit 0)
#
# Usage: bash scripts/notify.sh \
#   [--score-file FILE] [--verify-file FILE] \
#   [--project PROJECT_ID] [--pr-url URL]

set -euo pipefail

SCORE_FILE="/tmp/compliance-score.json"
VERIFY_FILE="/tmp/compliance-verify.json"
PROJECT_ID="unknown"
PR_URL=""
CONFIG=".ai-tool-compliance.yaml"

while [[ $# -gt 0 ]]; do
  case $1 in
    --score-file)  SCORE_FILE="$2";  shift 2 ;;
    --verify-file) VERIFY_FILE="$2"; shift 2 ;;
    --project)     PROJECT_ID="$2";  shift 2 ;;
    --pr-url)      PR_URL="$2";      shift 2 ;;
    --help|-h)
      echo "Usage: bash scripts/notify.sh [--score-file FILE] [--verify-file FILE] [--project ID] [--pr-url URL]"
      exit 0
      ;;
    *) shift ;;
  esac
done

# ── 웹훅 URL 결정 ──────────────────────────────────────────────
WEBHOOK="${SLACK_WEBHOOK_URL:-}"

if [ -z "$WEBHOOK" ] && [ -f "$CONFIG" ]; then
  WEBHOOK=$(grep 'slack_webhook:' "$CONFIG" 2>/dev/null \
    | awk '{print $2}' | tr -d '"' || echo "")
fi

if [ -z "$WEBHOOK" ] || [ "$WEBHOOK" = "null" ]; then
  echo "[notify] Slack webhook 미설정. 알림 스킵."
  exit 0
fi

# ── 데이터 읽기 ────────────────────────────────────────────────
if [ ! -f "$SCORE_FILE" ]; then
  echo "[notify] 점수 파일 없음: $SCORE_FILE"
  exit 1
fi

TOTAL=$(jq '.total_score' "$SCORE_FILE")
P0_FAILS=$(jq '.p0_fail_total' "$SCORE_FILE")
P1_FAILS=$(jq '.p1_fail_total' "$SCORE_FILE")
GRADE=$(jq -r '.grade' "$SCORE_FILE")

# P0 위반 상세 (최대 5건)
P0_DETAIL=""
if [ -f "$VERIFY_FILE" ]; then
  P0_DETAIL=$(jq -r '
    .p0_violations[:5][]
    | "• [" + .rule_id + "] `" + .file + ":" + .line + "`\n  " + .message
  ' "$VERIFY_FILE" 2>/dev/null || echo "")
fi

# 도메인별 점수 요약
DOMAIN_SUMMARY=$(jq -r '
  .domains
  | to_entries[]
  | "• " + .key + ": " + (.value.score | tostring) + "/" + (.value.base | tostring) +
    (if .value.p0_fails > 0 then " ❌ P0:" + (.value.p0_fails | tostring) else "" end)
' "$SCORE_FILE" 2>/dev/null || echo "")

# ── Slack Block Kit 페이로드 생성 ─────────────────────────────
# Gate 결과 아이콘
if [ "$P0_FAILS" -gt 0 ]; then
  STATUS_TEXT="BLOCK"
  STATUS_EMOJI=":no_entry:"
elif [ "$(awk "BEGIN{print ($TOTAL >= 90)}")" = "1" ]; then
  STATUS_TEXT="APPROVE"
  STATUS_EMOJI=":white_check_mark:"
else
  STATUS_TEXT="WARNING"
  STATUS_EMOJI=":warning:"
fi

# PR 링크 텍스트
if [ -n "$PR_URL" ]; then
  PR_LINK="<$PR_URL|PR 보기>"
else
  PR_LINK="N/A"
fi

PAYLOAD=$(jq -n \
  --arg project   "$PROJECT_ID" \
  --arg total     "$TOTAL" \
  --arg grade     "$GRADE" \
  --arg p0_fails  "$P0_FAILS" \
  --arg p1_fails  "$P1_FAILS" \
  --arg pr_link   "$PR_LINK" \
  --arg p0_detail "$P0_DETAIL" \
  --arg domain_summary "$DOMAIN_SUMMARY" \
  --arg status_text  "$STATUS_TEXT" \
  --arg status_emoji "$STATUS_EMOJI" \
  '{
    text: ($status_emoji + " [AI Tool Compliance " + $status_text + "] " + $project),
    blocks: [
      {
        type: "header",
        text: {
          type: "plain_text",
          text: ($status_emoji + " AI Tool Compliance: " + $status_text)
        }
      },
      {
        type: "section",
        fields: [
          { type: "mrkdwn", text: ("*프로젝트*\n" + $project) },
          { type: "mrkdwn", text: ("*총점*\n" + $total + "/100 (" + $grade + ")") },
          { type: "mrkdwn", text: ("*P0 위반*\n" + $p0_fails + "건") },
          { type: "mrkdwn", text: ("*P1 위반*\n" + $p1_fails + "건") }
        ]
      },
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: ("*도메인별 점수*\n" + $domain_summary)
        }
      },
      (if $p0_detail != "" then {
        type: "section",
        text: {
          type: "mrkdwn",
          text: ("*P0 위반 상세*\n```" + $p0_detail + "```")
        }
      } else empty end),
      {
        type: "actions",
        elements: [
          (if $pr_link != "N/A" then {
            type: "button",
            text: { type: "plain_text", text: "PR 보기" },
            url: $pr_link,
            style: (if $status_text == "BLOCK" then "danger" else "primary" end)
          } else empty end)
        ]
      },
      {
        type: "context",
        elements: [
          {
            type: "mrkdwn",
            text: (if $status_text == "BLOCK"
              then ":rotating_light: 배포가 차단되었습니다. P0 위반을 즉시 수정하세요."
              elif $status_text == "WARNING"
              then ":warning: 위반 항목을 검토하고 개선하세요."
              else ":white_check_mark: 모든 컴플라이언스 검사를 통과했습니다."
              end)
          }
        ]
      }
    ]
  }')

# ── Slack 전송 ────────────────────────────────────────────────
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST \
  -H 'Content-type: application/json' \
  --data "$PAYLOAD" \
  "$WEBHOOK")

if [ "$HTTP_STATUS" = "200" ]; then
  echo "[notify] Slack 알림 전송 완료 (Project: $PROJECT_ID, Status: $STATUS_TEXT)"
else
  echo "[notify] Slack 전송 실패 (HTTP $HTTP_STATUS)"
  exit 1
fi

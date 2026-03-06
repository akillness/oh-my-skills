#!/usr/bin/env bash
# verify-loop.sh — Integration test for agentation watch loop
# Tests: server health, annotation CRUD, ACK-RESOLVE cycle, error cases
# Usage: bash verify-loop.sh [--quick]   (--quick skips phase 4 error tests)
set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
pass() { echo -e "${GREEN}PASS${NC} $*"; }
fail() { echo -e "${RED}FAIL${NC} $*"; FAILURES=$((FAILURES + 1)); }
info() { echo -e "${YELLOW}....${NC} $*"; }

FAILURES=0
BASE_URL="http://localhost:4747"
QUICK=false
[[ "${1:-}" == "--quick" ]] && QUICK=true

echo ""
echo "agentation Watch Loop — Integration Test"
echo "========================================="
echo ""

# ── Phase 1: Server Health ──────────────────────────────────────────────────

echo "Phase 1: Server Health"
echo "──────────────────────"

info "1a. Health check"
if curl -sf --connect-timeout 3 "${BASE_URL}/health" >/dev/null 2>&1; then
  pass "GET /health — server reachable"
else
  fail "GET /health — server not reachable. Start with: npx agentation-mcp server"
  echo ""
  echo "Cannot continue without server. Exiting."
  exit 1
fi

info "1b. Status check"
STATUS=$(curl -sf "${BASE_URL}/status" 2>/dev/null || echo "")
if [[ -n "$STATUS" ]]; then
  pass "GET /status — returns server metadata"
else
  fail "GET /status — empty response"
fi

info "1c. Baseline pending check"
PENDING=$(curl -sf "${BASE_URL}/pending" 2>/dev/null || echo '{"count":-1}')
BASELINE_COUNT=$(echo "$PENDING" | python3 -c "import sys,json; print(json.load(sys.stdin).get('count',-1))" 2>/dev/null || echo -1)
if [[ "$BASELINE_COUNT" -ge 0 ]]; then
  pass "GET /pending — baseline count: ${BASELINE_COUNT}"
else
  fail "GET /pending — invalid response"
fi

echo ""

# ── Phase 2: Session & Annotation CRUD ──────────────────────────────────────

echo "Phase 2: Annotation CRUD"
echo "────────────────────────"

info "2a. Create session"
SESSION_RESP=$(curl -sf -X POST "${BASE_URL}/sessions" -H "Content-Type: application/json" -d '{}' 2>/dev/null || echo "")
SESSION_ID=$(echo "$SESSION_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null || echo "")
if [[ -n "$SESSION_ID" ]]; then
  pass "POST /sessions — created session: ${SESSION_ID:0:12}..."
else
  fail "POST /sessions — failed to create session"
  echo "Cannot continue without session. Exiting."
  exit 1
fi

info "2b. Create annotation"
ANN_RESP=$(curl -sf -X POST "${BASE_URL}/sessions/${SESSION_ID}/annotations" \
  -H "Content-Type: application/json" \
  -d "{\"comment\":\"Test: change button color\",\"element\":\"button\",\"elementPath\":\"body > main > button.cta\",\"x\":50,\"y\":100}" 2>/dev/null || echo "")
ANN_ID=$(echo "$ANN_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null || echo "")
if [[ -n "$ANN_ID" ]]; then
  pass "POST annotation — created: ${ANN_ID:0:12}..."
else
  fail "POST annotation — failed"
fi

info "2c. Verify pending count = 1"
P_COUNT=$(curl -sf "${BASE_URL}/sessions/${SESSION_ID}/pending" 2>/dev/null \
  | python3 -c "import sys,json; print(json.load(sys.stdin).get('count',0))" 2>/dev/null || echo 0)
if [[ "$P_COUNT" -eq 1 ]]; then
  pass "GET /sessions/:id/pending — count: 1"
else
  fail "GET /sessions/:id/pending — expected 1, got ${P_COUNT}"
fi

echo ""

# ── Phase 3: ACK-RESOLVE Cycle ──────────────────────────────────────────────

echo "Phase 3: ACK-RESOLVE Cycle"
echo "──────────────────────────"

info "3a. Acknowledge annotation"
ACK_RESP=$(curl -sf -X PATCH "${BASE_URL}/annotations/${ANN_ID}" \
  -H "Content-Type: application/json" \
  -d '{"status":"acknowledged"}' 2>/dev/null || echo "")
ACK_STATUS=$(echo "$ACK_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',''))" 2>/dev/null || echo "")
if [[ "$ACK_STATUS" == "acknowledged" ]]; then
  pass "PATCH acknowledged — status: acknowledged"
else
  fail "PATCH acknowledged — expected 'acknowledged', got '${ACK_STATUS}'"
fi

info "3b. Resolve annotation"
RES_RESP=$(curl -sf -X PATCH "${BASE_URL}/annotations/${ANN_ID}" \
  -H "Content-Type: application/json" \
  -d '{"status":"resolved","resolution":"Changed button color to #3b82f6"}' 2>/dev/null || echo "")
RES_STATUS=$(echo "$RES_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',''))" 2>/dev/null || echo "")
if [[ "$RES_STATUS" == "resolved" ]]; then
  pass "PATCH resolved — status: resolved"
else
  fail "PATCH resolved — expected 'resolved', got '${RES_STATUS}'"
fi

info "3c. Verify pending count = 0"
FINAL_COUNT=$(curl -sf "${BASE_URL}/sessions/${SESSION_ID}/pending" 2>/dev/null \
  | python3 -c "import sys,json; print(json.load(sys.stdin).get('count',0))" 2>/dev/null || echo -1)
if [[ "$FINAL_COUNT" -eq 0 ]]; then
  pass "GET pending after resolve — count: 0 (all resolved)"
else
  fail "GET pending after resolve — expected 0, got ${FINAL_COUNT}"
fi

echo ""

# ── Phase 4: Error Cases ────────────────────────────────────────────────────

if ! $QUICK; then
  echo "Phase 4: Error Cases"
  echo "────────────────────"

  info "4a. Invalid annotation ID"
  HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" -X PATCH "${BASE_URL}/annotations/nonexistent-id-12345" \
    -H "Content-Type: application/json" -d '{"status":"acknowledged"}' 2>/dev/null || echo "000")
  if [[ "$HTTP_CODE" == "404" || "$HTTP_CODE" == "400" ]]; then
    pass "Invalid ID — HTTP ${HTTP_CODE} (expected 4xx)"
  else
    fail "Invalid ID — expected 4xx, got HTTP ${HTTP_CODE}"
  fi

  info "4b. GET non-existent session"
  HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" "${BASE_URL}/sessions/nonexistent-session-12345" 2>/dev/null || echo "000")
  if [[ "$HTTP_CODE" == "404" || "$HTTP_CODE" == "400" ]]; then
    pass "Non-existent session — HTTP ${HTTP_CODE} (expected 4xx)"
  else
    fail "Non-existent session — expected 4xx, got HTTP ${HTTP_CODE}"
  fi

  echo ""
fi

# ── Summary ─────────────────────────────────────────────────────────────────

echo "========================================="
if [[ "$FAILURES" -eq 0 ]]; then
  echo -e "${GREEN}ALL TESTS PASSED${NC}"
  echo ""
  echo "agentation watch loop is working correctly."
  echo "MCP tool agentation_watch_annotations should function end-to-end."
else
  echo -e "${RED}${FAILURES} TEST(S) FAILED${NC}"
  echo ""
  echo "Fix the issues above and re-run: bash verify-loop.sh"
fi
echo ""
exit $FAILURES

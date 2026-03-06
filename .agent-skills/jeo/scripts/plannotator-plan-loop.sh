#!/usr/bin/env bash
# JEO PLAN gate for plannotator.
# Guarantees blocking review, retries dead sessions, and requires explicit stop decision.

set -euo pipefail

PLAN_FILE="${1:-plan.md}"
FEEDBACK_FILE="${2:-}"
MAX_RESTARTS="${3:-3}"
PORT_ERROR_REGEX='Failed to start server\. Is port .* in use|EADDRINUSE|EPERM|operation not permitted|Failed to listen'

if ! command -v plannotator >/dev/null 2>&1; then
  echo "[JEO][PLAN] plannotator is required in PLAN phase." >&2
  exit 127
fi

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "[JEO][PLAN] plan file not found: $PLAN_FILE" >&2
  exit 2
fi

if ! [[ "$MAX_RESTARTS" =~ ^[0-9]+$ ]] || [[ "$MAX_RESTARTS" -lt 1 ]]; then
  echo "[JEO][PLAN] invalid MAX_RESTARTS: $MAX_RESTARTS" >&2
  exit 2
fi

SESSION_KEY="$(python3 -c "import hashlib,os; print(hashlib.md5(os.getcwd().encode()).hexdigest()[:8])" 2>/dev/null || echo "default")"
FEEDBACK_DIR="/tmp/jeo-${SESSION_KEY}"
RUNTIME_HOME="${FEEDBACK_DIR}/.plannotator"
mkdir -p "$FEEDBACK_DIR" "$RUNTIME_HOME"

if [[ -z "$FEEDBACK_FILE" ]]; then
  FEEDBACK_FILE="${FEEDBACK_DIR}/plannotator_feedback.txt"
else
  mkdir -p "$(dirname "$FEEDBACK_FILE")"
fi

write_manual_feedback_json() {
  local approved="$1"
  local note="${2:-}"
  python3 - "$FEEDBACK_FILE" "$approved" "$note" <<'PYEOF'
import json, sys
path, approved_raw, note = sys.argv[1], sys.argv[2], sys.argv[3]
approved = approved_raw.lower() == "true"
payload = {
    "approved": approved,
    "source": "jeo-manual-fallback",
    "note": note,
}
with open(path, "w", encoding="utf-8") as f:
    json.dump(payload, f, ensure_ascii=False, indent=2)
PYEOF
}

manual_fallback_gate() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    return 32
  fi

  echo "[JEO][PLAN] plannotator UI를 열 수 없는 환경입니다. 수동 PLAN gate로 전환합니다." >&2
  echo "[JEO][PLAN] 선택: [a]pprove / [f]eedback / [s]top" >&2
  read -r -p "선택하세요 [a/f/s]: " choice

  case "${choice,,}" in
    a|approve)
      write_manual_feedback_json "true" "manual-approve (fallback gate)"
      echo "[JEO][PLAN] manual approved=true" >&2
      return 0
      ;;
    f|feedback)
      read -r -p "피드백 내용을 입력하세요: " fb
      write_manual_feedback_json "false" "${fb:-manual-feedback (fallback gate)}"
      echo "[JEO][PLAN] manual approved=false (feedback)" >&2
      return 10
      ;;
    s|stop|n|no)
      echo "[JEO][PLAN] user requested PLAN stop." >&2
      return 30
      ;;
    *)
      echo "[JEO][PLAN] invalid choice. stopping PLAN." >&2
      return 31
      ;;
  esac
}

probe_local_listen() {
  if command -v node >/dev/null 2>&1; then
    node -e "const http=require('http');const s=http.createServer(()=>{});s.on('error',()=>process.exit(1));s.listen({host:'127.0.0.1',port:0},()=>s.close(()=>process.exit(0)));" >/dev/null 2>&1
    return $?
  fi
  return 0
}

# Some sandboxes disallow localhost bind(). In that environment plannotator hook mode cannot run.
if [[ "${JEO_SKIP_LISTEN_PROBE:-0}" != "1" ]]; then
  if ! probe_local_listen; then
    echo "[JEO][PLAN] localhost bind probe failed (listen not permitted)." >&2
    set +e
    manual_fallback_gate
    probe_rc=$?
    set -e
    exit "$probe_rc"
  fi
fi

attempt=1
while (( attempt <= MAX_RESTARTS )); do
  : > "$FEEDBACK_FILE"
  touch /tmp/jeo-plannotator-direct.lock

  python3 -c "
import json, sys
plan = open(sys.argv[1]).read()
sys.stdout.write(json.dumps({'tool_input': {'plan': plan, 'permission_mode': 'acceptEdits'}}))
" "$PLAN_FILE" | env HOME="$RUNTIME_HOME" PLANNOTATOR_HOME="$RUNTIME_HOME" plannotator > "$FEEDBACK_FILE" 2>&1 || true

  set +e
  python3 - "$FEEDBACK_FILE" <<'PYEOF'
import json, sys
path = sys.argv[1]
try:
    payload = json.load(open(path))
except Exception:
    sys.exit(20)
approved = payload.get("approved")
if approved is True:
    sys.exit(0)
if approved is False:
    sys.exit(10)
sys.exit(20)
PYEOF
  rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    echo "[JEO][PLAN] approved=true"
    exit 0
  fi

  if [[ "$rc" -eq 10 ]]; then
    echo "[JEO][PLAN] approved=false (feedback)"
    exit 10
  fi

  if grep -Eiq "$PORT_ERROR_REGEX" "$FEEDBACK_FILE"; then
    echo "[JEO][PLAN] plannotator server bind failure detected (EADDRINUSE/EPERM)." >&2
    set +e
    manual_fallback_gate
    fallback_rc=$?
    set -e
    exit "$fallback_rc"
  fi

  echo "[JEO][PLAN] session ended unexpectedly (attempt ${attempt}/${MAX_RESTARTS}). restarting..." >&2
  ((attempt++))
done

echo "[JEO][PLAN] plannotator session ended ${MAX_RESTARTS} times." >&2
set +e
manual_fallback_gate
fallback_rc=$?
set -e
if [[ "$fallback_rc" -eq 32 ]]; then
  echo "[JEO][PLAN] confirmation required. stop and ask user whether to continue PLAN." >&2
fi
exit "$fallback_rc"

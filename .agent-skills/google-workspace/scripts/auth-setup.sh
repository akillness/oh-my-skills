#!/usr/bin/env bash
# auth-setup.sh — Google Workspace authentication setup helper
# Usage:
#   bash auth-setup.sh --oauth2 credentials.json
#   bash auth-setup.sh --service-account service-account-key.json [--subject admin@yourdomain.com]
#   bash auth-setup.sh --check

set -euo pipefail

MODE=""
CREDS_FILE=""
SUBJECT=""
TOKEN_DIR="${HOME}/.config/gws-agent"

usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --oauth2 <credentials.json>       OAuth2 user auth (interactive browser flow)
  --service-account <key.json>      Service account auth
  --subject <email>                 Impersonate user (for domain-wide delegation)
  --check                           Check current auth status
  --token-dir <dir>                 Custom token storage dir (default: ~/.config/gws-agent)
  -h, --help                        Show this help

Examples:
  $0 --oauth2 ~/credentials.json
  $0 --service-account ~/sa-key.json --subject admin@company.com
  $0 --check
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --oauth2)         MODE="oauth2";   CREDS_FILE="${2:-}"; shift 2 ;;
    --service-account) MODE="sa";      CREDS_FILE="${2:-}"; shift 2 ;;
    --subject)        SUBJECT="${2:-}"; shift 2 ;;
    --token-dir)      TOKEN_DIR="${2:-}"; shift 2 ;;
    --check)          MODE="check";    shift ;;
    -h|--help)        usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# Verify Python and libraries
check_deps() {
  if ! command -v python3 &>/dev/null; then
    echo "❌ python3 not found. Install Python 3.8+"
    exit 1
  fi
  python3 -c "import googleapiclient, google_auth_oauthlib" 2>/dev/null || {
    echo "📦 Installing Google API client libraries..."
    pip install --quiet google-api-python-client google-auth-httplib2 google-auth-oauthlib
  }
}

# Check auth status
check_auth() {
  TOKEN_FILE="${TOKEN_DIR}/token.json"
  SA_FILE="${TOKEN_DIR}/service-account.json"
  echo "=== Google Workspace Auth Status ==="
  echo "Token dir: ${TOKEN_DIR}"
  if [[ -f "$TOKEN_FILE" ]]; then
    echo "✅ OAuth2 token found: $TOKEN_FILE"
    python3 - <<'PYEOF'
import json, sys
from pathlib import Path
token_file = Path.home() / '.config/gws-agent/token.json'
try:
    t = json.loads(token_file.read_text())
    print(f"   Account: {t.get('client_id','unknown')[:20]}...")
    print(f"   Scopes:  {', '.join(t.get('scopes',[]))}")
    print(f"   Expired: {t.get('expiry','unknown')}")
except Exception as e:
    print(f"   (Could not parse token: {e})")
PYEOF
  else
    echo "⚠️  No OAuth2 token at: $TOKEN_FILE"
    echo "   Run: $0 --oauth2 credentials.json"
  fi
  if [[ -f "$SA_FILE" ]]; then
    echo "✅ Service account key found: $SA_FILE"
    python3 -c "
import json
from pathlib import Path
sa = json.loads(Path.home().joinpath('.config/gws-agent/service-account.json').read_text())
print(f'   Email: {sa.get(\"client_email\",\"unknown\")}')
print(f'   Project: {sa.get(\"project_id\",\"unknown\")}')
"
  else
    echo "⚠️  No service account key at: $SA_FILE"
  fi
  echo "====================================="
}

# OAuth2 setup
setup_oauth2() {
  if [[ -z "$CREDS_FILE" || ! -f "$CREDS_FILE" ]]; then
    echo "❌ credentials.json not found: '${CREDS_FILE}'"
    echo ""
    echo "To get credentials.json:"
    echo "  1. Go to https://console.cloud.google.com/apis/credentials"
    echo "  2. Create credentials > OAuth 2.0 Client ID > Desktop app"
    echo "  3. Download JSON and provide its path"
    exit 1
  fi

  mkdir -p "$TOKEN_DIR"
  cp "$CREDS_FILE" "${TOKEN_DIR}/credentials.json"

  echo "🔐 Starting OAuth2 browser flow..."
  python3 - <<PYEOF
import os, json
from pathlib import Path
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

SCOPES = [
    'https://www.googleapis.com/auth/documents',
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/presentations',
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/gmail.modify',
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/chat.messages',
    'https://www.googleapis.com/auth/forms.body',
]

token_dir = Path(os.environ.get('TOKEN_DIR', Path.home() / '.config/gws-agent'))
creds_file = token_dir / 'credentials.json'
token_file = token_dir / 'token.json'

flow = InstalledAppFlow.from_client_secrets_file(str(creds_file), SCOPES)
creds = flow.run_local_server(port=0)

import json
token_file.write_text(json.dumps({
    'token':    creds.token,
    'refresh_token': creds.refresh_token,
    'token_uri':     creds.token_uri,
    'client_id':     creds.client_id,
    'client_secret': creds.client_secret,
    'scopes':        list(creds.scopes or []),
}))
print(f"✅ Token saved to: {token_file}")
print(f"   Authorized scopes: {len(creds.scopes or [])} scopes")
PYEOF
}

# Service account setup
setup_service_account() {
  if [[ -z "$CREDS_FILE" || ! -f "$CREDS_FILE" ]]; then
    echo "❌ Service account key file not found: '${CREDS_FILE}'"
    echo ""
    echo "To get a service account key:"
    echo "  1. Go to https://console.cloud.google.com/iam-admin/serviceaccounts"
    echo "  2. Create service account > Add key > JSON"
    echo "  3. For Admin SDK: grant domain-wide delegation in Google Admin console"
    exit 1
  fi

  mkdir -p "$TOKEN_DIR"
  cp "$CREDS_FILE" "${TOKEN_DIR}/service-account.json"

  python3 - <<PYEOF
import json, os
from pathlib import Path
sa_file = Path(os.environ.get('TOKEN_DIR', Path.home() / '.config/gws-agent')) / 'service-account.json'
sa = json.loads(sa_file.read_text())
print(f"✅ Service account key saved")
print(f"   Email:   {sa.get('client_email','?')}")
print(f"   Project: {sa.get('project_id','?')}")
subject = os.environ.get('SUBJECT','')
if subject:
    print(f"   Subject: {subject} (domain-wide delegation)")
PYEOF

  if [[ -n "$SUBJECT" ]]; then
    echo "$SUBJECT" > "${TOKEN_DIR}/.subject"
    echo "✅ Delegation subject saved: $SUBJECT"
  fi
}

# Main
check_deps
export TOKEN_DIR SUBJECT

case "$MODE" in
  oauth2)  setup_oauth2 ;;
  sa)      setup_service_account ;;
  check)   check_auth ;;
  "")      usage; exit 0 ;;
esac

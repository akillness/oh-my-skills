#!/bin/bash
# AI Tool Compliance - 스킬 설치 스크립트
# Usage: bash scripts/install.sh [--slack-webhook URL] [--mode warn|block]
#
# Steps:
#   1. 의존성 확인 (jq, curl, git)
#   2. 프로젝트 설정 파일 생성 (.ai-tool-compliance.yaml)
#   3. GitHub Actions 워크플로우 복사
#   4. 룰 카탈로그 초기화
#   5. Slack 웹훅 설정 (선택)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
COMPLIANCE_CONFIG="$PROJECT_ROOT/.ai-tool-compliance.yaml"
GITHUB_WORKFLOWS="$PROJECT_ROOT/.github/workflows"

# 색상
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# 인수 파싱
SLACK_WEBHOOK=""
INSTALL_MODE="warn"
while [[ $# -gt 0 ]]; do
  case $1 in
    --slack-webhook) SLACK_WEBHOOK="$2"; shift 2 ;;
    --mode)          INSTALL_MODE="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: bash scripts/install.sh [--slack-webhook URL] [--mode warn|block]"
      exit 0
      ;;
    *) shift ;;
  esac
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  AI Tool Compliance - Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ── Step 1: 의존성 확인 ────────────────────────────────────────
print_info "[1/5] 의존성 확인..."
MISSING_DEPS=()

for dep in jq curl git bc; do
  if ! command -v "$dep" &>/dev/null; then
    MISSING_DEPS+=("$dep")
  else
    print_success "$dep 설치됨"
  fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
  print_error "필수 의존성 없음: ${MISSING_DEPS[*]}"
  echo "  macOS:  brew install ${MISSING_DEPS[*]}"
  echo "  Ubuntu: sudo apt-get install -y ${MISSING_DEPS[*]}"
  exit 1
fi

# 선택 의존성
if command -v yq &>/dev/null; then
  print_success "yq 설치됨 (YAML 자동 업데이트 지원)"
else
  print_warning "yq 없음 (선택 사항). brew install yq 로 설치 가능"
fi

# python3 + PyYAML (YAML→JSON 컴파일용)
if command -v python3 &>/dev/null; then
  if python3 -c "import yaml" 2>/dev/null; then
    print_success "python3 + PyYAML 설치됨 (YAML→JSON 컴파일 가능)"
  else
    print_warning "python3는 있으나 PyYAML 없음. pip install pyyaml 로 설치 권장"
  fi
else
  print_warning "python3 없음. scripts/verify.sh 실행에 필요. brew install python3 로 설치"
fi
echo ""

# ── Step 2: 프로젝트 설정 파일 생성 ───────────────────────────
print_info "[2/5] 설정 파일 생성..."

PROJECT_ID=$(basename "$PROJECT_ROOT" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')
INSTALL_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
# 전환 일정: 설치일 + 14일 = block 모드 활성화
BLOCK_DATE=$(date -u -d "+14 days" +"%Y-%m-%d" 2>/dev/null || date -u -v+14d +"%Y-%m-%d")

if [ ! -f "$COMPLIANCE_CONFIG" ]; then
  cat > "$COMPLIANCE_CONFIG" << YAML
version: 1
project_id: "${PROJECT_ID}"
installed_at: "${INSTALL_DATE}"

rules:
  p0: enabled
  p1: enabled
  p2: enabled

mode: ${INSTALL_MODE}
transition:
  warn_until: "${BLOCK_DATE}"
  auto_transition: true

gate:
  threshold: 90
  p0_fail_limit: 0
  p1_fail_limit: 3
  block_below_score: 80

notifications:
  slack_webhook: "${SLACK_WEBHOOK}"
  notify_on:
    - block
    - p0_fail

report:
  weekly_snapshot: true
  monthly_audit: true
  retention_days: 90
YAML
  print_success "설정 파일 생성: $COMPLIANCE_CONFIG"
else
  print_warning "설정 파일 이미 존재 (스킵): $COMPLIANCE_CONFIG"
fi
echo ""

# ── Step 3: CI/CD 워크플로우 복사 ─────────────────────────────
print_info "[3/5] GitHub Actions 워크플로우 설치..."
mkdir -p "$GITHUB_WORKFLOWS"

WORKFLOW_TEMPLATE="$SKILL_ROOT/templates/ai-tool-compliance.yml"
WORKFLOW_DEST="$GITHUB_WORKFLOWS/ai-tool-compliance.yml"

if [ -f "$WORKFLOW_TEMPLATE" ]; then
  cp "$WORKFLOW_TEMPLATE" "$WORKFLOW_DEST"
  print_success "워크플로우 설치: $WORKFLOW_DEST"
else
  print_warning "템플릿 없음: $WORKFLOW_TEMPLATE (수동 복사 필요)"
fi
echo ""

# ── Step 4: 룰 카탈로그 초기화 + YAML→JSON 컴파일 ─────────────
print_info "[4/5] 룰 카탈로그 초기화..."

P0_CATALOG_YAML="$SKILL_ROOT/rules/p0-catalog.yaml"
P1_CATALOG_YAML="$SKILL_ROOT/rules/p1-catalog.yaml"
CATALOG_JSON="$SKILL_ROOT/rules/catalog.json"
CATALOG_P1_JSON="$SKILL_ROOT/rules/catalog-p1.json"
CATALOG_ALL_JSON="$SKILL_ROOT/rules/catalog-all.json"

if command -v python3 &>/dev/null && python3 -c "import yaml" 2>/dev/null; then
  python3 - << PYTHON
import json, yaml

with open("$P0_CATALOG_YAML") as f:
    p0 = yaml.safe_load(f) or {"rules": []}
with open("$P1_CATALOG_YAML") as f:
    p1 = yaml.safe_load(f) or {"rules": []}

with open("$CATALOG_JSON", "w") as f:
    json.dump(p0, f, ensure_ascii=False, indent=2)
with open("$CATALOG_P1_JSON", "w") as f:
    json.dump(p1, f, ensure_ascii=False, indent=2)
with open("$CATALOG_ALL_JSON", "w") as f:
    json.dump({"rules": list(p0.get("rules", [])) + list(p1.get("rules", []))}, f, ensure_ascii=False, indent=2)
PYTHON
  print_success "catalog.json 컴파일 완료: $CATALOG_JSON"
  print_success "catalog-p1.json 컴파일 완료: $CATALOG_P1_JSON"
  print_success "catalog-all.json 컴파일 완료: $CATALOG_ALL_JSON"
else
  if [ -f "$CATALOG_JSON" ] && [ -f "$CATALOG_P1_JSON" ]; then
    print_warning "PyYAML 없음. 기존 catalog.json/catalog-p1.json 사용 (YAML 변경 시 재컴파일 필요)"
  else
    print_error "PyYAML 없고 catalog JSON 파일이 부족함. pip install pyyaml 후 재실행 필요"
    exit 1
  fi
fi

if [ -f "$CATALOG_JSON" ] && [ "$P0_CATALOG_YAML" -nt "$CATALOG_JSON" ]; then
  print_warning "p0-catalog.yaml이 catalog.json보다 최신. bash scripts/install.sh 로 재컴파일 권장"
fi
if [ -f "$CATALOG_P1_JSON" ] && [ "$P1_CATALOG_YAML" -nt "$CATALOG_P1_JSON" ]; then
  print_warning "p1-catalog.yaml이 catalog-p1.json보다 최신. bash scripts/install.sh 로 재컴파일 권장"
fi

# .compliance/ 디렉토리 초기화 (이력 추적용)
COMPLIANCE_DIR="$PROJECT_ROOT/.compliance"
mkdir -p "$COMPLIANCE_DIR/runs"
mkdir -p "$COMPLIANCE_DIR/overrides"
if [ ! -f "$COMPLIANCE_DIR/history.md" ]; then
  PROJECT_NAME=$(basename "$PROJECT_ROOT")
  cat > "$COMPLIANCE_DIR/history.md" << MD
# Compliance History: ${PROJECT_NAME}

## 실행 이력

| 날짜 | 커밋 | 총점 | 등급 | P0 Fail | P1 Fail | 변화 |
|------|------|------|------|---------|---------|------|

## 미결 항목 (수정 가능)

<!-- 이 섹션을 직접 편집하여 조치 상황을 업데이트하세요 -->

## 예외 처리 이력

| Rule ID | 예외 사유 | 승인자 | 승인일 | 만료일 |
|---------|---------|--------|--------|--------|
| (없음) | | | | |
MD
  print_success ".compliance/ 디렉토리 초기화 완료"
fi
echo ""

# ── Step 5: Slack 웹훅 설정 ───────────────────────────────────
print_info "[5/5] Slack 알림 설정..."

if [ -n "$SLACK_WEBHOOK" ]; then
  if command -v yq &>/dev/null; then
    yq eval ".notifications.slack_webhook = \"$SLACK_WEBHOOK\"" -i "$COMPLIANCE_CONFIG"
    print_success "Slack 웹훅 설정 완료"
  else
    print_warning "yq 없음. 수동으로 $COMPLIANCE_CONFIG 의 notifications.slack_webhook 항목에 URL 입력 필요"
  fi
else
  print_warning "Slack 웹훅 미설정 (선택 사항)"
  echo "  나중에 설정: bash scripts/install.sh --slack-webhook <WEBHOOK_URL>"
fi
echo ""

# ── 완료 ──────────────────────────────────────────────────────
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  AI Tool Compliance 설치 완료!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  설정 파일:   $COMPLIANCE_CONFIG"
echo "  워크플로우:  $WORKFLOW_DEST"
echo "  카탈로그(P0): $CATALOG_JSON"
echo "  카탈로그(P1): $CATALOG_P1_JSON"
echo "  카탈로그(All): $CATALOG_ALL_JSON"
echo "  이력 추적:   $COMPLIANCE_DIR/history.md"
echo ""
echo "  현재 모드: ${INSTALL_MODE} → ${BLOCK_DATE} 이후 자동 block 전환"
echo ""
echo "다음 단계:"
echo "  git add .ai-tool-compliance.yaml .github/workflows/ai-tool-compliance.yml"
echo "  git commit -m 'chore: add AI tool compliance'"
echo "  git push"
echo ""

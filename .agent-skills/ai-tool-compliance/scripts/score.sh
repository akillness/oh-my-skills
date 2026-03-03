#!/bin/bash
# AI Tool Compliance - 4도메인 이진 점수 산출
# Usage: bash scripts/score.sh [--input FILE] [--output FILE] [--project-dir DIR] [--help]
#
# 점수 체계: PASS=배점 100% / FAIL=0점 / MANUAL_REVIEW=0점 (N/A는 분모 제외 후 정규화)
# 도메인 만점: Security=40 / Auth=25 / Cost=20 / Logging=15 = 합계 100
# 등급: Green(90+, 모든 P0 PASS) / Yellow(75-89, 모든 P0 PASS) / Red(P0 FAIL 1건 이상 or <75)
#
# Output (stdout): JSON with total_score, grade, domains, delta
# Diagnostics (stderr): progress messages
# Exit: 0=Green, 1=Yellow, 2=Red/Block

set -euo pipefail

INPUT_FILE="/tmp/compliance-verify.json"
OUTPUT_FILE="/tmp/compliance-score.json"
PROJECT_DIR="."

while [[ $# -gt 0 ]]; do
  case $1 in
    --input)  INPUT_FILE="$2";  shift 2 ;;
    --output) OUTPUT_FILE="$2"; shift 2 ;;
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --help|-h)
      cat << 'EOF'
Usage: bash scripts/score.sh [--input FILE] [--output FILE] [--project-dir DIR] [--help]

  --input       verify.sh output JSON (default: /tmp/compliance-verify.json)
  --output      Write score JSON to FILE (default: /tmp/compliance-score.json)
  --project-dir Project root for .compliance/ history (default: current directory)
  --help        Show this help

Output (stdout): JSON with total_score, grade, domains, p0_failed_rules, delta
Diagnostics (stderr): progress messages

Exit codes:
  0  Green (score >= 90, all P0 pass)
  1  Yellow (score 75-89, all P0 pass)
  2  Red (P0 fail exists or score < 75)

Example:
  bash scripts/score.sh --input /tmp/compliance-verify.json
  bash scripts/verify.sh . | bash scripts/score.sh
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

if [ ! -f "$INPUT_FILE" ]; then
  echo "[score] ERROR: Input file not found: $INPUT_FILE" >&2
  echo "[score] Run: bash scripts/verify.sh . --output $INPUT_FILE" >&2
  exit 2
fi

echo "[score] Calculating compliance score from: $INPUT_FILE" >&2

python3 - "$INPUT_FILE" "$OUTPUT_FILE" "$PROJECT_DIR" << 'PYTHON'
import json, os, sys, datetime

input_file = sys.argv[1]
output_file = sys.argv[2]
project_dir = sys.argv[3]

with open(input_file) as f:
    verify = json.load(f)

# Domain configuration
DOMAIN_TOTALS = {"security": 40, "auth": 25, "cost": 20, "logging": 15}
DOMAIN_MAP = {"SEC": "security", "AUTH": "auth", "COST": "cost", "LOG": "logging"}

domain_scores = {k: 0 for k in DOMAIN_TOTALS}
domain_max_applicable = {k: 0 for k in DOMAIN_TOTALS}
domain_p0_fails = {k: 0 for k in DOMAIN_TOTALS}
domain_p1_fails = {k: 0 for k in DOMAIN_TOTALS}
p0_fails = []
p1_fails = []
manual_reviews = []
p1_manual_reviews = []
p1_applicable_max = 0
p1_pass_score = 0

for r in verify.get("results", []):
    rule_id = r["rule_id"]
    prefix = rule_id.split("-")[0]
    domain = DOMAIN_MAP.get(prefix, "unknown")
    severity = r.get("severity", "P0")
    status = r["status"]
    score_impact = r.get("score_impact", 0)

    # N/A rules excluded from denominator
    if status == "NA":
        continue

    if domain in DOMAIN_TOTALS:
        domain_max_applicable[domain] = domain_max_applicable.get(domain, 0) + score_impact

    if severity == "P1":
        p1_applicable_max += score_impact

    if status == "PASS":
        if domain in domain_scores:
            domain_scores[domain] += score_impact
        if severity == "P1":
            p1_pass_score += score_impact
    elif status == "FAIL":
        if severity == "P0":
            p0_fails.append(rule_id)
            if domain in domain_p0_fails:
                domain_p0_fails[domain] += 1
        elif severity == "P1":
            p1_fails.append(rule_id)
            if domain in domain_p1_fails:
                domain_p1_fails[domain] += 1
    elif status == "MANUAL_REVIEW":
        manual_reviews.append(rule_id)
        if severity == "P1":
            p1_manual_reviews.append(rule_id)

# Calculate total with N/A normalization
raw_score = sum(domain_scores.values())
applicable_max = sum(domain_max_applicable.values())

if applicable_max > 0 and applicable_max < 100:
    # Normalize: scale to 100
    normalized_score = round((raw_score / applicable_max) * 100)
else:
    normalized_score = raw_score

p0_fail_count = len(p0_fails)
p1_fail_count = len(p1_fails)
p1_maturity_score = round((p1_pass_score / p1_applicable_max) * 100) if p1_applicable_max > 0 else 0

# Grade determination (P0 takes precedence)
if p0_fail_count > 0:
    grade = "Red"
    exit_code = 2
elif normalized_score >= 90:
    grade = "Green"
    exit_code = 0
elif normalized_score >= 75:
    grade = "Yellow"
    exit_code = 1
else:
    grade = "Red"
    exit_code = 2

# Delta calculation (compare with previous run)
compliance_dir = os.path.join(project_dir, ".compliance", "runs")
latest_run_file = os.path.join(compliance_dir, "latest.json")
delta = {"score_change": 0, "newly_passed": [], "newly_failed": []}

if os.path.exists(latest_run_file):
    try:
        with open(latest_run_file) as f:
            prev = json.load(f)
        prev_score = prev.get("total_score", normalized_score)
        prev_failed = set(prev.get("p0_failed_rules", []) + prev.get("p1_failed_rules", []))
        curr_failed = set(p0_fails + p1_fails)

        delta = {
            "score_change": normalized_score - prev_score,
            "newly_passed": list(prev_failed - curr_failed),
            "newly_failed": list(curr_failed - prev_failed)
        }
    except Exception as e:
        print(f"[score] Warning: Could not read previous run: {e}", file=sys.stderr)

# Build output
output = {
    "timestamp": datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
    "include_p1": verify.get("include_p1", False),
    "total_score": normalized_score,
    "p0_gate_score": normalized_score,
    "p1_maturity_score": p1_maturity_score,
    "raw_score": raw_score,
    "applicable_max": applicable_max,
    "p0_fail_total": p0_fail_count,
    "p1_fail_total": p1_fail_count,
    "manual_review_count": len(manual_reviews),
    "grade": grade,
    "domains": {
        k: {
            "score": domain_scores[k],
            "base": DOMAIN_TOTALS[k],
            "max": DOMAIN_TOTALS[k],
            "applicable_max": domain_max_applicable[k],
            "p0_fails": domain_p0_fails[k],
            "p1_fails": domain_p1_fails[k]
        }
        for k in DOMAIN_TOTALS
    },
    "p0_failed_rules": p0_fails,
    "p1_failed_rules": p1_fails,
    "p1_manual_review_rules": p1_manual_reviews,
    "manual_review_rules": manual_reviews,
    "p1": {
        "score": p1_pass_score,
        "applicable_max": p1_applicable_max,
        "maturity_score": p1_maturity_score,
        "fail_count": p1_fail_count,
        "manual_review_count": len(p1_manual_reviews)
    },
    "delta": delta
}

# Write output
with open(output_file, "w") as f:
    json.dump(output, f, indent=2, ensure_ascii=False)

print(json.dumps(output, indent=2, ensure_ascii=False))

# Save run history
try:
    if not os.path.exists(compliance_dir):
        os.makedirs(compliance_dir, exist_ok=True)

    # Generate run ID with timestamp
    run_ts = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H-%M-%S")
    run_file = os.path.join(compliance_dir, f"{run_ts}.json")

    # Full run record
    run_record = {
        **output,
        "verify_results": verify.get("results", [])
    }
    with open(run_file, "w") as f:
        json.dump(run_record, f, indent=2, ensure_ascii=False)

    # Update latest.json
    with open(latest_run_file, "w") as f:
        json.dump(run_record, f, indent=2, ensure_ascii=False)

    print(f"[score] Run saved: {run_file}", file=sys.stderr)

    # Append to history.md (create if absent)
    history_file = os.path.join(project_dir, ".compliance", "history.md")
    if not os.path.exists(history_file):
        project_name = os.path.basename(os.path.abspath(project_dir))
        with open(history_file, "w") as f:
            f.write(f"# Compliance History: {project_name}\n\n")
            f.write("## 실행 이력\n\n")
            f.write("| 날짜 | 커밋 | 총점 | 등급 | P0 Fail | P1 Fail | 변화 |\n")
            f.write("|------|------|------|------|---------|---------|------|\n")
            f.write("\n## 미결 항목 (수정 가능)\n\n")
            f.write("<!-- 이 섹션을 직접 편집하여 조치 상황을 업데이트하세요 -->\n\n")
            f.write("## 예외 처리 이력\n\n")
            f.write("| Rule ID | 예외 사유 | 승인자 | 승인일 | 만료일 |\n")
            f.write("|---------|---------|--------|--------|--------|\n")
            f.write("| (없음) | | | | |\n")
        print(f"[score] Created {history_file}", file=sys.stderr)
    if os.path.exists(history_file):
        import subprocess
        try:
            commit_sha = subprocess.run(
                ["git", "rev-parse", "--short", "HEAD"],
                capture_output=True, text=True, cwd=project_dir
            ).stdout.strip() or "unknown"
        except Exception:
            commit_sha = "unknown"

        date_str = datetime.datetime.utcnow().strftime("%Y-%m-%d")
        delta_str = f"{delta['score_change']:+d}점" if delta["score_change"] != 0 else "초기"
        if delta["newly_passed"]:
            delta_str += f" ({', '.join(delta['newly_passed'][:2])} 수정)"

        new_row = f"| {date_str} | {commit_sha} | {normalized_score} | {grade} | {p0_fail_count} | {p1_fail_count} | {delta_str} |\n"

        with open(history_file) as f:
            content = f.read()

        # Insert row after the table header
        header_marker = "| 날짜 | 커밋 | 총점 | 등급 | P0 Fail | P1 Fail | 변화 |\n|------|------|------|------|---------|---------|------|\n"
        alt_header = "|------|------|------|------|---------|---------|------|\n"
        if alt_header in content:
            content = content.replace(alt_header, alt_header + new_row)
            with open(history_file, "w") as f:
                f.write(content)

except Exception as e:
    print(f"[score] Warning: Could not save run history: {e}", file=sys.stderr)

print(f"[score] Score: {normalized_score}/100 ({grade}) | P0: {p0_fail_count} | P1: {p1_fail_count} | MANUAL: {len(manual_reviews)}", file=sys.stderr)

sys.exit(exit_code)
PYTHON

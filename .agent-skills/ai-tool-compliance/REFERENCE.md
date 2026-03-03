# ai-tool-compliance Reference

Detailed reference for the AI Tool Compliance Verifier skill. Covers judgment algorithms, scoring formulas, domain weights, OWASP mapping, and customization.

## Table of Contents

- [Judgment Algorithm](#judgment-algorithm)
- [Scoring Formula](#scoring-formula)
- [Domain Weights](#domain-weights)
- [Custom Weight Configuration](#custom-weight-configuration)
- [Rule Schema Reference](#rule-schema-reference)
- [Verdict Definitions](#verdict-definitions)
- [OWASP Mapping](#owasp-mapping)
- [Evidence Collection](#evidence-collection)
- [Error Handling](#error-handling)
- [Data Model](#data-model)

---

## Judgment Algorithm

### Overview

The verification engine processes each rule from `rules/p0-catalog.yaml` sequentially. For each rule, it determines whether the project's code complies, violates, or does not use the feature being checked.

### Pseudocode

```
function verify(project_root, catalog):
    results = []

    for each rule in catalog.rules:
        # Step 1: Collect target files
        target_files = []
        for pattern in rule.check_targets:
            target_files += Glob(project_root, pattern)

        # Step 1b: Exclude paths
        if rule.check_pattern.exclude_paths:
            for exclude in rule.check_pattern.exclude_paths:
                target_files -= Glob(project_root, exclude)

        if target_files is empty:
            results.append(rule.id, "N/A", "No matching files found")
            continue

        # Step 2: Feature detection (grep_patterns)
        if rule.check_pattern.grep_patterns:
            feature_files = []
            for pattern in rule.check_pattern.grep_patterns:
                feature_files += Grep(pattern, target_files)

            if feature_files is empty:
                results.append(rule.id, "N/A", "Feature not used in project")
                continue
        else:
            feature_files = target_files

        # Step 3: Violation detection (must_not_contain)
        violations = []
        if rule.check_pattern.must_not_contain:
            for pattern in rule.check_pattern.must_not_contain:
                hits = Grep(pattern, target_files)  # Note: checks ALL target files
                for hit in hits:
                    # Apply exclude_paths filter
                    if not matches_any(hit.file, rule.check_pattern.exclude_paths):
                        violations.append(hit)

        # Step 4: Compliance detection (must_contain)
        compliant_files = set()
        if rule.check_pattern.must_contain:
            for pattern in rule.check_pattern.must_contain:
                hits = Grep(pattern, feature_files)
                for hit in hits:
                    compliant_files.add(hit.file)

        # Step 5: Verdict
        if violations is not empty:
            verdict = "Fail"
            evidence = violations
        elif compliant_files covers feature_files:
            verdict = "Pass"
            evidence = first matching line per file
        elif compliant_files is partially covering:
            verdict = "Warning"
            evidence = uncovered files
        else:
            verdict = "Fail"
            evidence = feature_files without compliance

        results.append(rule.id, verdict, evidence)

    return results
```

### Verdict Decision Tree

```
Start
  |
  v
Target files exist?
  |-- No --> N/A ("No matching files")
  |-- Yes
      |
      v
  grep_patterns defined?
  |-- Yes --> Feature files found?
  |   |-- No --> N/A ("Feature not used")
  |   |-- Yes --> continue
  |-- No --> feature_files = target_files
      |
      v
  must_not_contain violations found?
  |-- Yes --> FAIL (with violation evidence)
  |-- No
      |
      v
  must_contain patterns satisfied?
  |-- All files covered --> PASS
  |-- Some files covered --> WARNING
  |-- No files covered --> FAIL
```

---

## Scoring Formula

### Point-Based Scoring (100점 만점)

각 P0 룰은 고정 배점을 가진다. 영역별 만점의 합계가 100점이다.

| 영역 | 만점 | 포함 룰 및 개별 배점 |
|------|------|---------------------|
| 보안 | 35 | SEC-P0-004(10) + SEC-P0-005(15) + SEC-P0-009(10) |
| 권한 | 30 | AUTH-P0-001(10) + AUTH-P0-002(10) + AUTH-P0-003(10) |
| 비용 | 20 | COST-P0-006(10) + COST-P0-007(5) + COST-P0-011(5) |
| 로그 | 15 | LOG-P0-008(10) + LOG-P0-010(5) |
| **합계** | **100** | **11개 P0 룰** |

### Per-Rule Score

```
rule_score =
  Pass    → 배점 * 1.0 (전액 획득)
  Warning → 배점 * 0.5 (절반 획득)
  Fail    → 0 (미획득)
  N/A     → 분모에서 제외 (배점을 만점에서도 차감)
```

### Per-Domain Score

```
domain_score = SUM(applicable_rule_scores) / domain_max_points
```

N/A 룰이 있으면 해당 룰의 배점이 domain_max_points에서도 차감된다.

### Total Score

```
total_score = SUM(all_domain_actual_scores)

(N/A 조정 시: adjusted_total = SUM(actual) / SUM(applicable_max) * 100)
```

### Gate Decision

```
if any P0 rule == Fail:
    gate = Red (배포 차단)
elif total_score >= 90:
    gate = Green (자동 승인)
elif total_score >= 75:
    gate = Yellow (PM 확인 필요)
else:
    gate = Red (배포 차단)
```

### Example Calculation

Given these verdicts:

| Rule | Domain | Verdict | 배점 | 획득 |
|------|--------|---------|------|------|
| AUTH-P0-001 | auth | Pass | 10 | 10 |
| AUTH-P0-002 | auth | Pass | 10 | 10 |
| AUTH-P0-003 | auth | Fail | 10 | 0 |
| SEC-P0-004 | security | Fail | 10 | 0 |
| SEC-P0-005 | security | Pass | 15 | 15 |
| SEC-P0-009 | security | Warning | 10 | 5 |
| COST-P0-006 | cost | Pass | 10 | 10 |
| COST-P0-007 | cost | N/A | 5 | -- |
| COST-P0-011 | cost | Pass | 5 | 5 |
| LOG-P0-008 | logging | Pass | 10 | 10 |
| LOG-P0-010 | logging | Fail | 5 | 0 |

Domain scores:

```
권한: 10 + 10 + 0 = 20 / 30 만점
보안: 0 + 15 + 5 = 20 / 35 만점
비용: 10 + 5 = 15 / 15 만점 (COST-P0-007 N/A → 만점에서 5점 차감, 15로 조정)
로그: 10 + 0 = 10 / 15 만점
```

Total score:

```
actual = 20 + 20 + 15 + 10 = 65
applicable_max = 30 + 35 + 15 + 15 = 95  (COST-P0-007의 5점 제외)
adjusted_total = 65 / 95 * 100 = 68.4

Score = 68.4 / 100
Gate = Red (P0 FAIL 2건: AUTH-P0-003, SEC-P0-004)
  → 점수와 무관하게 P0 FAIL이 있으므로 Red
```

---

## Domain Points (고정 배점 체계)

### Default Point Allocation

| Domain | 만점 | 룰별 배점 | Rationale |
|--------|------|----------|-----------|
| 보안 (Security) | 35 | SEC-P0-004(10), SEC-P0-005(15), SEC-P0-009(10) | 보안 위반은 데이터 유출, 규제 제재, 평판 손실 등 가장 큰 비즈니스 임팩트. Gateway 강제(SEC-P0-005)는 모든 외부 통신의 관문이므로 15점 최고 배점 |
| 권한 (Auth) | 30 | AUTH-P0-001(10), AUTH-P0-002(10), AUTH-P0-003(10) | OWASP #1 취약점. Guest 격리와 서버 검증은 동등하게 중요하므로 균등 10점 배분 |
| 비용 (Cost) | 20 | COST-P0-006(10), COST-P0-007(5), COST-P0-011(5) | AI 모델/BQ 비용 미추적은 대규모 재정 손실 가능. 모델 비용 로그가 핵심이므로 10점, BQ/캐시는 보조 5점 |
| 로그 (Logging) | 15 | LOG-P0-008(10), LOG-P0-010(5) | 로그 부재는 장애 대응과 감사 준수를 방해하지만 직접적 사용자 임팩트는 낮음. 실패 로그가 더 긴급하므로 10점 |

### Point Validation

모든 영역 만점의 합은 반드시 100이어야 한다:

```
보안(35) + 권한(30) + 비용(20) + 로그(15) = 100
```

---

## Custom Point Configuration

프로젝트 특성에 따라 영역별 배점을 조정하려면 `compliance-config.yaml`에서 설정한다:

```yaml
# compliance-config.yaml
scoring:
  domain_weights:
    security: 30      # 보안 비중을 낮추고
    auth: 25
    cost: 30          # 비용 비중을 높임 (AI 비용이 핵심인 프로젝트)
    logging: 15
    # 합계는 반드시 100이어야 함

gate:
  green_threshold: 90
  yellow_threshold: 75
  p0_fail_override: true   # P0 FAIL 시 점수 무관 Red (기본값: true)

# Optional: 특정 룰 건너뛰기 (N/A 처리)
skip_rules:
  - COST-P0-007   # BigQuery 미사용 프로젝트
```

**Rules for custom points:**
1. All four domains must be present
2. Points must sum to 100
3. No domain can be 0 (minimum 5점)
4. P0 Fail still blocks gate regardless of weights (weights only affect the score number)

**Loading priority:**
1. `compliance-config.yaml` in project root (highest)
2. `resources/score-weights.md` default values (fallback)

---

## Rule Schema Reference

Each rule in `rules/p0-catalog.yaml` follows this schema:

```yaml
- id: string              # Unique identifier (e.g., AUTH-P0-001)
  domain: string          # One of: auth, security, cost, logging
  severity: string        # P0 (mandatory) or P1 (recommended)
  title: string           # Short human-readable title
  description: string     # Detailed explanation of what the rule checks
  check_type: string      # static_analysis | config_check | api_test | log_check
  check_targets:          # Glob patterns for files to scan
    - string
  check_pattern:
    grep_patterns:        # (Optional) Patterns to detect if feature is used
      - string
    must_contain:         # Patterns that MUST be present for compliance
      - string
    must_not_contain:     # (Optional) Patterns that must NOT be present
      - string
    exclude_paths:        # (Optional) Paths to exclude from must_not_contain
      - string
  evidence_type: string   # code_snippet | config_value | log_sample
  remediation: string     # How to fix violations
```

### Field Details

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Format: `{DOMAIN}-P{0\|1}-{NNN}` |
| `domain` | Yes | Determines which weight group this rule belongs to |
| `severity` | Yes | `P0` = deployment blocker, `P1` = advisory warning |
| `check_type` | Yes | Primary check mechanism |
| `check_targets` | Yes | At least one glob pattern |
| `grep_patterns` | No | If absent, all target files are checked (no N/A possible) |
| `must_contain` | Yes* | Required unless only `must_not_contain` is used |
| `must_not_contain` | No | Presence of these patterns causes immediate Fail |
| `exclude_paths` | No | Applied to `must_not_contain` checks (e.g., server code is allowed) |

---

## Verdict Definitions

| Verdict | Meaning | Score Impact | Gate Impact |
|---------|---------|-------------|-------------|
| **Pass** | Rule fully satisfied. Compliance pattern found in all feature files. | 100 points | None |
| **Fail** | Rule violated. Must_not_contain found, or must_contain absent in feature files. | 0 points | **Blocks deployment** (P0) |
| **Warning** | Partial compliance. Must_contain found in some but not all feature files. | 50 points | Advisory only |
| **N/A** | Feature not used. No target files found, or grep_patterns matched nothing. | Excluded | None |

---

## OWASP Mapping

P0 rules map to OWASP Top 10 (2021) categories:

| P0 Rule | OWASP Category | OWASP ID |
|---------|---------------|----------|
| AUTH-P0-001 | Broken Access Control | A01:2021 |
| AUTH-P0-002 | Broken Access Control | A01:2021 |
| AUTH-P0-003 | Broken Access Control | A01:2021 |
| SEC-P0-004 | Security Misconfiguration | A05:2021 |
| SEC-P0-005 | Security Misconfiguration | A05:2021 |
| SEC-P0-009 | Cryptographic Failures / Sensitive Data Exposure | A02:2021 |
| COST-P0-006 | (No direct OWASP mapping) | -- |
| COST-P0-007 | (No direct OWASP mapping) | -- |
| COST-P0-011 | (No direct OWASP mapping) | -- |
| LOG-P0-008 | Security Logging and Monitoring Failures | A09:2021 |
| LOG-P0-010 | Security Logging and Monitoring Failures | A09:2021 |

### Coverage Summary

| OWASP Category | Coverage |
|---------------|----------|
| A01: Broken Access Control | 3 rules (AUTH-P0-001, 002, 003) |
| A02: Cryptographic Failures | 1 rule (SEC-P0-009) |
| A05: Security Misconfiguration | 2 rules (SEC-P0-004, 005) |
| A09: Logging Failures | 2 rules (LOG-P0-008, 010) |
| A03, A04, A06-A08, A10 | Not directly covered (see security-best-practices skill) |

---

## Evidence Collection

### Evidence Types

| Type | Description | Example |
|------|-------------|---------|
| `code_snippet` | Source code line with file path and line number | `src/auth/signup.ts:42 — user.role = Role.Guest` |
| `config_value` | Configuration file value | `firebase.json:rules — "allow read, write: if true"` |
| `log_sample` | Log output showing compliance/violation | `[2026-03-03] audit: role changed admin->guest` |

### Evidence Format

```json
{
  "rule_id": "SEC-P0-004",
  "verdict": "Fail",
  "evidence": [
    {
      "file": "src/components/UserList.tsx",
      "line": 23,
      "content": "const snapshot = await getDocs(collection(db, 'users'));",
      "type": "code_snippet"
    }
  ]
}
```

---

## Error Handling

### Missing Rule Catalog

```
Error: rules/p0-catalog.yaml not found

Response:
  1. Check if ai-tool-compliance skill is properly installed
  2. Run: bash scripts/install.sh
  3. Verify: ls rules/p0-catalog.yaml
```

### Invalid YAML in Rule Catalog

```
Error: YAML parsing failed in rules/p0-catalog.yaml

Response:
  1. Validate YAML syntax: yq eval '.' rules/p0-catalog.yaml
  2. Check for unescaped special characters in regex patterns
  3. Ensure all strings with regex are properly quoted
```

### No Target Files Found

```
Warning: No files matching check_targets for rule {rule_id}

Response:
  1. This is normal for projects that don't use certain features
  2. Rule will be marked N/A
  3. No action required unless the feature IS expected to be present
```

### Grep Pattern Error

```
Error: Invalid regex pattern in rule {rule_id}

Response:
  1. Check the pattern syntax in p0-catalog.yaml
  2. Ensure regex special characters are properly escaped
  3. Test pattern manually: grep -rE "pattern" src/
```

---

## Data Model

### verification_run

```json
{
  "run_id": "uuid-v4",
  "project_id": "project-name",
  "commit_sha": "abc1234",
  "environment": "development",
  "catalog_version": "1.0.0",
  "started_at": "2026-03-03T10:00:00Z",
  "finished_at": "2026-03-03T10:00:15Z",
  "results": [],
  "score": {}
}
```

### verification_result

```json
{
  "run_id": "uuid-v4",
  "rule_id": "AUTH-P0-001",
  "verdict": "Pass",
  "score_delta": 100,
  "evidence": [
    {
      "file": "src/auth/signup.ts",
      "line": 42,
      "content": "user.role = Role.Guest",
      "type": "code_snippet"
    }
  ],
  "message": "Guest role enforced in signup handler"
}
```

### risk_score_snapshot

```json
{
  "run_id": "uuid-v4",
  "total_score": 72.5,
  "security_score": 50.0,
  "auth_score": 66.7,
  "cost_score": 100.0,
  "logging_score": 50.0,
  "applicable_rules": 10,
  "na_rules": 1,
  "pass_count": 7,
  "fail_count": 2,
  "warning_count": 1
}
```

### remediation_task

```json
{
  "task_id": "uuid-v4",
  "run_id": "uuid-v4",
  "rule_id": "SEC-P0-004",
  "severity": "P0",
  "title": "Fix: Client-side Firestore direct access",
  "description": "Remove getDocs/getDoc calls from client components and route through server API",
  "evidence_file": "src/components/UserList.tsx",
  "evidence_line": 23,
  "owner": "",
  "due_date": "",
  "status": "open",
  "remediation": "Remove Firestore direct calls from client code and access data through server API endpoints."
}
```

---

## Display Formatting

### Console Output Symbols

| Symbol | Meaning |
|--------|---------|
| `Pass` | Rule fully satisfied |
| `Fail` | Rule violated (P0 = blocks deployment) |
| `Warning` | Partial compliance |
| `N/A` | Feature not used in project |

### Score Display

```
Compliance Score: 72.5 / 100

  Security  [====------]  50.0%  (weight: 40%)
  Auth      [======----]  66.7%  (weight: 25%)
  Cost      [==========] 100.0%  (weight: 20%)
  Logging   [=====-----]  50.0%  (weight: 15%)

Gate: BLOCKED (2 P0 Fail)
```

---

## Best Practices for Rule Authors

### Writing grep_patterns

- Use alternation (`|`) for multiple function names: `signup|register|createUser`
- Keep patterns as specific as possible to reduce false positives
- Test patterns against known-good and known-bad code samples

### Writing must_contain

- Combine related terms with `|`: `audit|auditLog|audit_log`
- Consider framework-specific variations (Express, Nest, Fastify)
- Case sensitivity matters: use `[Cc]ache` for mixed case

### Writing must_not_contain

- Be precise to avoid false positives: `firebase/firestore` is better than just `firebase`
- Always pair with `exclude_paths` when server-side usage is legitimate
- Test against your actual project structure

### Adding New Rules

1. Choose the correct domain (auth, security, cost, logging)
2. Assign the next available ID: `{DOMAIN}-P{severity}-{NNN}`
3. Write clear grep_patterns that detect feature usage
4. Define must_contain patterns that prove compliance
5. Add exclude_paths if server-side code should be exempt
6. Write actionable remediation guidance
7. Test with `/compliance-check {rule_id}` on a known project

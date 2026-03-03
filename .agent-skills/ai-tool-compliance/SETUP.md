# ai-tool-compliance — Setup Guide

> **Internal AI Tool Compliance Verifier**
> Verify P0/P1 mandatory rules against your codebase with automated scoring and deployment gating.

---

## What You Get

```
Your AI Agent
     |
     v
 /compliance-verify      <-- scan project against 11 P0 rules
     |
     v
 Pass / Fail / Warning   <-- per-rule verdict with file:line evidence
     |
     v
 /compliance-score        <-- weighted risk score (0-100)
     |
     v
 /compliance-gate         <-- deployment gate (exit 0 = approved, exit 1 = blocked)
     |
     v
 risk-score-report.md     <-- shareable compliance report
```

---

## Quick Start (3 steps)

### Step 1 -- Install

```bash
bash scripts/install.sh
```

This will:
- Check for required dependencies (yq, jq)
- Set executable permissions on all scripts
- Validate the rule catalog

Options:

```bash
bash scripts/install.sh --dry-run        # Preview without making changes
bash scripts/install.sh --skip-checks    # Skip dependency verification
bash scripts/install.sh -h               # Show help
```

### Step 2 -- Verify your project

Run this inside your AI session (Claude Code, Gemini CLI, etc.):

```text
/compliance-verify
```

The agent will:
1. Load `rules/p0-catalog.yaml` (11 P0 rules)
2. Scan your project files using Glob/Grep
3. Apply Pass/Fail/Warning/N/A verdicts per rule
4. Display results with file:line evidence

Output example:

```
AI Tool Compliance Verification
Project: my-ai-app | Commit: abc1234

AUTH-P0-001  Pass      src/auth/signup.ts:42
AUTH-P0-002  Pass      src/middleware/roleGuard.ts:15
AUTH-P0-003  Pass      src/routes/api.ts:8
SEC-P0-004   Fail      src/components/UserList.tsx:23
SEC-P0-005   Pass      (no external API calls detected)
SEC-P0-009   Warning   src/api/users.ts:67
COST-P0-006  Pass      functions/ai/generate.ts:34
COST-P0-007  N/A       (no BigQuery usage detected)
COST-P0-011  Pass      functions/ai/generate.ts:28
LOG-P0-008   Pass      src/middleware/errorHandler.ts:12
LOG-P0-010   Fail      src/admin/roles.ts:45

Score: 72.5 / 100
Status: BLOCKED (2 Fail, 1 Warning)
```

### Step 3 -- Review and remediate

For each Fail:
1. Check the `evidence` (file:line) in the verification output
2. Read the `remediation` guidance from the rule catalog
3. Fix the code (or delegate to an executor agent)
4. Re-run `/compliance-verify` to confirm

For deployment gating:

```bash
bash scripts/gate.sh
# Exit 0 = all P0 rules pass, deployment approved
# Exit 1 = P0 violations exist, deployment blocked
```

---

## Domain Scoring Guide

The compliance score uses a fixed-point system (100 points total):

| Domain | 만점 | Rules | What it checks |
|--------|------|-------|---------------|
| 보안 (Security) | 35 | SEC-P0-004(10), 005(15), 009(10) | Firestore access, API gateway, sensitive data |
| 권한 (Auth) | 30 | AUTH-P0-001(10), 002(10), 003(10) | Guest role, access control, middleware |
| 비용 (Cost) | 20 | COST-P0-006(10), 007(5), 011(5) | Model cost logs, BigQuery logs, caching |
| 로그 (Logging) | 15 | LOG-P0-008(10), 010(5) | Error logs, audit logs |

**Score formula:**

```
Rule score: Pass=배점*100%, Warning=배점*50%, Fail=0, N/A=excluded
Total score = SUM(all rule scores) / 100
```

**Gate decision:**

| Grade | Score | Condition | Decision |
|-------|-------|-----------|----------|
| Green | 90-100 | All P0 PASS + score >= 90 | Auto-approve |
| Yellow | 75-89 | All P0 PASS + score 75-89 | PM review required |
| Red | 0-74 | Score < 75 OR any P0 FAIL | Deployment blocked |

Rules marked N/A (feature not used) are excluded from both numerator and denominator.

---

## CI/CD Integration

### GitHub Actions

```yaml
- name: Compliance Gate
  run: bash .agent-skills/ai-tool-compliance/scripts/gate.sh
```

### Pre-deploy Hook

Add `gate.sh` to your deployment pipeline's pre-deploy stage. It runs `verify.sh` + `score.sh` internally and returns:
- `exit 0` -- all P0 rules pass
- `exit 1` -- one or more P0 Fail exists

---

## Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `install.sh` | Setup: dependency check + permissions | `bash scripts/install.sh` |
| `verify.sh` | Run verification against P0 rules | `bash scripts/verify.sh` |
| `score.sh` | Calculate weighted compliance score | `bash scripts/score.sh` |
| `gate.sh` | Deployment gate (exit code decision) | `bash scripts/gate.sh` |

---

## Troubleshooting

**Rules not loading:**

```bash
# Check if rule catalog exists and is valid YAML
cat rules/p0-catalog.yaml | head -5

# If using yq, validate syntax
yq eval '.' rules/p0-catalog.yaml
```

**False positives (Fail on compliant code):**

The static analysis uses pattern matching, which may not capture all valid implementations. If you get a false positive:
1. Check if your implementation uses a different naming convention
2. The `check_pattern.must_contain` patterns may need to be extended
3. Report the false positive so the rule catalog can be updated

**N/A when feature IS used:**

If a rule is marked N/A but the feature is actually present:
1. Check `check_pattern.grep_patterns` -- your code may use a different import or function name
2. Check `check_targets` -- your files may be in a non-standard directory
3. Extend the patterns in `rules/p0-catalog.yaml`

**Score seems incorrect:**

```bash
# Run score.sh with verbose output
bash scripts/score.sh --verbose

# Check the generated report
cat templates/risk-score-report.md
```

---

## Related Skills

| Skill | Purpose | Install |
|-------|---------|---------|
| `security-best-practices` | How to implement security controls | `npx skills add ... --skill security-best-practices` |
| `monitoring-observability` | Logging and metrics setup | `npx skills add ... --skill monitoring-observability` |
| `bmad-orchestrator` | Workflow with phase gates | `npx skills add ... --skill bmad-orchestrator` |
| `deployment-automation` | CI/CD pipeline setup | `npx skills add ... --skill deployment-automation` |

---

> **Source:** [skills-template](https://github.com/supercent-io/skills-template) | Internal AI Tool Implementation Guide

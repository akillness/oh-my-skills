---
name: jeo
description: >
  Integrated AI agent orchestration skill that combines plannotator, ralphmode,
  team or bmad execution, agent-browser verification, and agentation feedback
  loops. Use when the user wants an end-to-end multi-agent workflow with plan
  approval, implementation, UI review, and cleanup. Triggers on: jeo,
  annotate, ui-review, multi-agent orchestration.
compatibility: "Requires git, node>=18, bash. Optional: bun, docker."
allowed-tools: Read Write Bash Grep Glob Task
metadata:
  tags: jeo, orchestration, ralph, plannotator, agentation, annotate, agentui, UI-review, team, bmad, omc, omx, ohmg, agent-browser, multi-agent, workflow, worktree-cleanup, browser-verification, ui-feedback
  platforms: Claude, Codex, Gemini, OpenCode
  keyword: jeo
  version: 1.5.0
  source: akillness/oh-my-skills
---


# JEO — Integrated Agent Orchestration

> Keyword: `jeo` · `annotate` · `UI-review` · `agentui (deprecated)` | Platforms: Claude Code · Codex CLI · Gemini CLI · OpenCode
>
> Plan (plannotator) → Execute (team/bmad) → Verify (agent-browser + agentation) → Cleanup (worktree)

## When to use this skill

- Run an end-to-end multi-agent workflow with an explicit planning gate
- Add a browser-backed UI feedback loop with `annotate` or `ui-review`
- Coordinate plan approval, execution, verification, and cleanup in one skill

## Rules (always enforced)

1. Do not reopen the PLAN gate when the current plan hash already has a terminal result
2. Only a revised plan resets `plan_gate_status` to `pending`
3. Do not process agentation annotations before explicit submit/onSubmit opens the submit gate
4. **NEVER** enter EXECUTE without `plan_approved: true`
5. **NEVER** run plannotator or agentation with `&` (background)
6. **NEVER** reopen an unchanged plan after `approved`, `manual_approved`, `feedback_required`, or `infrastructure_blocked`

Authoritative state: `.omc/state/jeo-state.json`

---

## State Management

All state operations use one script: `scripts/jeo-state-update.py`

```bash
# Initialize (or resume if state exists)
python3 scripts/jeo-state-update.py init "<task>"

# Record checkpoint at each step
python3 scripts/jeo-state-update.py checkpoint <plan|execute|verify|verify_ui|cleanup>

# Record error (auto-increments retry_count; warns at >= 3)
python3 scripts/jeo-state-update.py error "<message>"

# Check resume point
python3 scripts/jeo-state-update.py resume

# Set any field (supports dot notation for nested keys)
python3 scripts/jeo-state-update.py set phase execute
python3 scripts/jeo-state-update.py set agentation.active true
```

---

## Execution Protocol

> Execute steps in order. Each step only proceeds after the previous one completes.

### STEP 0: Bootstrap

```bash
mkdir -p .omc/state .omc/plans .omc/logs
python3 scripts/jeo-state-update.py init "<detected task>"
```

Notify the user:
> "JEO activated. Phase: PLAN. Add the `annotate` keyword if a UI feedback loop is needed."

---

### STEP 1: PLAN (never skip)

```bash
python3 scripts/jeo-state-update.py checkpoint plan
```

1. Write `plan.md` (include goal, steps, risks, and completion criteria)

2. **Invoke plannotator** (per platform):

   **Claude Code (hook mode — only supported method):**
   - Call `EnterPlanMode` → write plan content → call `ExitPlanMode`
   - The `ExitPlanMode` PermissionRequest hook fires plannotator automatically
   - Wait for the hook result before proceeding
   - **NEVER** call plannotator via MCP tool or CLI directly in Claude Code

   **Codex / Gemini / OpenCode (blocking CLI):**
   ```bash
   # Skip if same plan hash already has terminal gate status
   # (check plan_gate_status and last_reviewed_plan_hash in jeo-state.json)

   # Resolve JEO scripts directory
   _JEO_SCRIPTS=""
   for _candidate in \
     "${JEO_SKILL_DIR:-}/scripts" \
     "$HOME/.agent-skills/jeo/scripts" \
     "$HOME/.codex/skills/jeo/scripts" \
     "$(pwd)/.agent-skills/jeo/scripts" \
     "scripts"; do
     [ -f "${_candidate}/plannotator-plan-loop.sh" ] && _JEO_SCRIPTS="$_candidate" && break
   done

   # Auto-install plannotator if missing
   bash "${_JEO_SCRIPTS}/ensure-plannotator.sh" || exit 1

   # Run blocking plan gate (no &)
   FEEDBACK_DIR=$(python3 -c "import hashlib,os; h=hashlib.md5(os.getcwd().encode()).hexdigest()[:8]; d=f'/tmp/jeo-{h}'; os.makedirs(d,exist_ok=True); print(d)")
   bash "${_JEO_SCRIPTS}/plannotator-plan-loop.sh" plan.md "${FEEDBACK_DIR}/plannotator_feedback.txt" 3
   ```

3. **Check result:**
   - `approved` (exit 0) → set `phase=execute`, `plan_approved=true` → **STEP 2**
   - Feedback (exit 10) → read feedback, revise `plan.md`, repeat step 2
   - Infrastructure blocked (exit 32) → **Conversation Approval Mode**: output plan.md to user, ask "approve" or provide feedback. **WAIT** for user response
   - Session exited 3 times (exit 30/31) → ask user whether to abort

**NEVER:** enter EXECUTE without `approved: true`. **NEVER:** run with `&` background.

---

### STEP 2: EXECUTE

```bash
python3 scripts/jeo-state-update.py checkpoint execute
python3 scripts/jeo-state-update.py set phase execute
```

**Auto-detect team availability:**
```bash
TEAM_AVAILABLE=false
if [[ "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-}" =~ ^(1|true|yes)$ ]]; then
  TEAM_AVAILABLE=true
fi
python3 scripts/jeo-state-update.py set team_available $TEAM_AVAILABLE
```

**Check `next_mode` in state** (set by `claude-plan-gate.py` on approval):

| Condition | Action |
|-----------|--------|
| `next_mode == "ralphmode"` | `/omc:ralphmode "<task>"` |
| Claude Code + omc + team | `/omc:team 3:executor "<task>"` |
| Claude Code without team | **Error** — run `bash scripts/setup-claude.sh`, enable `AGENT_TEAMS=1`, restart |
| Codex / Gemini / OpenCode | BMAD fallback: `/workflow-init` then `/workflow-status` |

**NEVER** fall back to single-agent execution in Claude Code.

---

### STEP 3: VERIFY

```bash
python3 scripts/jeo-state-update.py checkpoint verify
python3 scripts/jeo-state-update.py set phase verify
```

1. **Browser verification with agent-browser** (when browser UI is present):
   ```bash
   agent-browser snapshot http://localhost:3000
   ```

2. `annotate` keyword detected → **enter STEP 3.1**
3. Otherwise → **enter STEP 4**

---

### STEP 3.1: VERIFY_UI (only when `annotate` keyword is detected)

**Pre-flight check (all platforms):**
```bash
if ! curl -sf --connect-timeout 2 http://localhost:4747/health >/dev/null 2>&1; then
  echo "agentation-mcp not running — skipping VERIFY_UI, proceeding to CLEANUP"
  python3 scripts/jeo-state-update.py error "agentation-mcp not running; VERIFY_UI skipped"
  # Proceed to STEP 4 (graceful skip, no exit 1)
fi
```

**If server is running:**

1. Set state: `phase=verify_ui`, `agentation.active=true`, `agentation.submit_gate_status=waiting_for_submit`

2. **Wait for explicit human submit** — do NOT read `/pending` before submit
   - Claude Code: wait for `UserPromptSubmit` hook
   - Others: wait until `ANNOTATE_READY` (or `AGENTUI_READY` alias)

3. After submit → set `agentation.submit_gate_status=submitted`

4. **Process annotations:**
   - **Claude Code (MCP):** `agentation_watch_annotations` (blocking, `batchWindowSeconds:10`, `timeoutSeconds:120`)
   - **Others (HTTP):** poll `GET http://localhost:4747/pending` with timeout

5. **Per-annotation loop:**
   - `acknowledge` → navigate code via `elementPath` (CSS selector) → apply fix → `resolve`
   - Dismissed annotations: skip code changes, increment `annotations.dismissed`

6. `count=0` or timeout → proceed to **STEP 4**

**NEVER:** process draft annotations before submit/onSubmit.

---

### STEP 4: CLEANUP

```bash
python3 scripts/jeo-state-update.py checkpoint cleanup
python3 scripts/jeo-state-update.py set phase cleanup
```

1. Check for uncommitted changes (warn if present)
2. Run worktree cleanup:
   ```bash
   bash scripts/worktree-cleanup.sh || git worktree prune
   ```
3. Set `phase=done`

---

## Quick Start

```bash
# Install JEO
npx skills add https://github.com/akillness/oh-my-skills --skill jeo

# Full install (all tools + components)
bash scripts/install.sh --all

# Check status
bash scripts/check-status.sh

# Per-platform setup
bash scripts/setup-claude.sh      # Claude Code hooks
bash scripts/setup-codex.sh       # Codex CLI config
bash scripts/setup-gemini.sh      # Gemini CLI hooks
bash scripts/setup-opencode.sh    # OpenCode plugin
```

---

## Platform Configuration

### Claude Code

Hook config (`~/.claude/settings.json`):
```json
{
  "hooks": {
    "PermissionRequest": [{
      "matcher": "ExitPlanMode",
      "hooks": [{"type": "command", "command": "python3 ~/.claude/skills/jeo/scripts/claude-plan-gate.py", "timeout": 1800}]
    }],
    "UserPromptSubmit": [{
      "matcher": "*",
      "hooks": [{"type": "command", "command": "python3 ~/.claude/skills/jeo/scripts/claude-agentation-submit-hook.py", "timeout": 300}]
    }]
  },
  "mcpServers": {
    "agentation": {"command": "npx", "args": ["-y", "agentation-mcp", "server"]}
  }
}
```

### Codex CLI

Config (`~/.codex/config.toml`):
```toml
notify = ["python3", "~/.codex/hooks/jeo-notify.py"]
[tui]
notifications = ["agent-turn-complete"]
```
> `developer_instructions` must be a top-level string (not a `[table]`), or Codex fails with `invalid type: map, expected a string`.

### Gemini CLI

Instructions in `~/.gemini/GEMINI.md`. AfterAgent hook as safety net in `~/.gemini/settings.json`.
Agent must call plannotator **directly in blocking mode** to receive feedback in the same turn.

### OpenCode

Plugins in `opencode.json`. Slash commands: `/jeo-plan`, `/jeo-exec`, `/jeo-annotate`, `/jeo-cleanup`.

---

## State File Reference

Path: `{worktree}/.omc/state/jeo-state.json`

| Field | Values | Description |
|-------|--------|-------------|
| `phase` | `plan\|execute\|verify\|verify_ui\|cleanup\|done` | Current workflow phase |
| `plan_approved` | bool | Whether plan was approved |
| `plan_gate_status` | `pending\|approved\|feedback_required\|infrastructure_blocked\|manual_approved` | Plan gate result |
| `plan_current_hash` | sha256 or null | Current plan.md hash |
| `last_reviewed_plan_hash` | sha256 or null | Hash of last reviewed plan |
| `plan_review_method` | `plannotator\|manual\|null` | How plan was approved |
| `team_available` | bool | Whether team mode is available |
| `retry_count` | int | Error retry count (ask user at >= 3) |
| `last_error` | string or null | Most recent error |
| `checkpoint` | string or null | Last entered phase (for resume) |
| `agentation.active` | bool | Whether VERIFY_UI watch loop is running |
| `agentation.submit_gate_status` | `idle\|waiting_for_submit\|submitted` | Submit gate state |
| `agentation.exit_reason` | `all_resolved\|timeout\|user_cancelled\|error\|null` | How watch loop ended |

---

## Best practices

1. **Plan first**: always review the plan with ralph+plannotator before executing (catches wrong approaches early)
2. **Team first**: omc team mode is most efficient in Claude Code
3. **bmad fallback**: use BMAD in environments without team (Codex, Gemini)
4. **Worktree cleanup**: run `worktree-cleanup.sh` immediately after work completes (prevents branch pollution)
5. **State persistence**: use `.omc/state/jeo-state.json` to maintain state across sessions
6. **annotate**: use the `annotate` keyword to run the agentation watch loop for complex UI changes (precise code changes via CSS selector). `agentui` is a backward-compatible alias.

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| plannotator not running | JEO auto-runs `ensure-plannotator.sh`; if it fails: `bash scripts/check-status.sh` |
| plannotator not opening (Claude Code) | It's hook-only. Use `EnterPlanMode` → `ExitPlanMode`. Check: `cat ~/.claude/settings.json` |
| Same plan re-reviewed (Codex) | Compare `last_reviewed_plan_hash` with current plan.md hash — skip if match + terminal status |
| Codex startup failure | Re-run `bash scripts/setup-codex.sh` — `developer_instructions` must be a top-level string |
| team mode not working | Run `bash scripts/setup-claude.sh`, restart Claude Code, verify `AGENT_TEAMS=1` |
| agentation not opening | Check `curl http://localhost:4747/health` and `/sessions` |
| annotation not in code | Include `summary` field when calling `agentation_resolve_annotation` |
| worktree conflict | `git worktree prune && git worktree list` |

---

## References

- [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — Claude Code multi-agent
- [plannotator](https://plannotator.ai) — visual plan/diff review
- [BMAD Method](https://github.com/bmad-dev/BMAD-METHOD) — structured AI development workflow
- [Agent Skills Spec](https://agentskills.io/specification) — skill format specification
- [agentation](https://github.com/benjitaylor/agentation) — UI annotation → agent code fix (`annotate`; `agentui` backward compatible)

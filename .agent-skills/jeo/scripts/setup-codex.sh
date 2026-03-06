#!/usr/bin/env bash
# JEO Skill — Codex CLI Setup
# Configures: developer_instructions + agentation MCP in ~/.codex/config.toml + /prompts:jeo
# Usage: bash setup-codex.sh [--dry-run]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

JEO_SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CODEX_CONFIG="${HOME}/.codex/config.toml"
CODEX_PROMPTS_DIR="${HOME}/.codex/prompts"
JEO_PROMPT_FILE="${CODEX_PROMPTS_DIR}/jeo.md"

echo ""
echo "JEO — Codex CLI Setup"
echo "======================"

# ── 1. Check Codex CLI ────────────────────────────────────────────────────────
if ! command -v codex >/dev/null 2>&1; then
  warn "codex CLI not found. Install via: npm install -g @openai/codex"
fi

# ── 2. Configure ~/.codex/config.toml ────────────────────────────────────────
info "Configuring ~/.codex/config.toml..."

HOOK_DIR="${HOME}/.codex/hooks"
HOOK_FILE="${HOOK_DIR}/jeo-notify.py"

if $DRY_RUN; then
  echo -e "${YELLOW}[DRY-RUN]${NC} Would create/update $CODEX_CONFIG"
  echo -e "${YELLOW}[DRY-RUN]${NC} Would create $JEO_PROMPT_FILE"
else
  mkdir -p "$(dirname "$CODEX_CONFIG")" "$CODEX_PROMPTS_DIR"

  # Backup existing config
  [[ -f "$CODEX_CONFIG" ]] && cp "$CODEX_CONFIG" "${CODEX_CONFIG}.jeo.bak"

  JEO_INSTRUCTION='# JEO Orchestration Workflow
# Keyword: jeo | Platforms: Codex, Claude, Gemini, OpenCode
#
# JEO provides integrated AI orchestration:
#   1. PLAN: ralph+plannotator for visual plan review
#   2. EXECUTE: team (if available) or bmad workflow
#   3. VERIFY: agent-browser snapshot for UI verification
#   4. CLEANUP: auto worktree cleanup after completion
#
# Trigger with: jeo "<task description>"
# Use /prompts:jeo for full workflow activation
#
# PLAN phase protocol (Codex):
#   1. Write plan to plan.md
#   2. Run mandatory PLAN gate (blocks for feedback/approve, retries dead sessions up to 3):
#      bash .agent-skills/jeo/scripts/plannotator-plan-loop.sh plan.md /tmp/plannotator_feedback.txt 3
#   3. Output "PLAN_READY" to trigger notify hook as backup signal
#   4. Check result:
#      - approved=true -> EXECUTE
#      - approved=false -> re-plan
#      - exit 32 -> localhost bind blocked (sandbox/CI). run PLAN gate in local TTY
#
# BMAD commands (fallback when team unavailable):
#   /workflow-init   — initialize BMAD workflow
#   /workflow-status — check current BMAD phase
#
# Tools: agent-browser, playwriter, plannotator'

  python3 - <<PYEOF
import re, os

config_path = os.path.expanduser("~/.codex/config.toml")
jeo_instruction = """${JEO_INSTRUCTION}"""

try:
    content = open(config_path).read() if os.path.exists(config_path) else ""
except Exception:
    content = ""

content = re.sub(r'(?ms)^\[developer_instructions\]\s*\n.*?(?=^\[|\Z)', '', content).strip() + "\n"
content = re.sub(r'(?ms)^# JEO Orchestration Workflow\n.*?^"""\s*\n', '', content)

def parse_existing_instructions(text: str) -> str:
    m = re.search(r'(?ms)^developer_instructions\s*=\s*"""\n?(.*?)\n?"""\s*$', text)
    if m:
        return m.group(1)

    m = re.search(r'(?m)^developer_instructions\s*=\s*"(.*)"\s*$', text)
    if m:
        return bytes(m.group(1), "utf-8").decode("unicode_escape")

    return ""

existing = parse_existing_instructions(content)
if "Keyword: jeo | Platforms: Codex, Claude, Gemini, OpenCode" in existing:
    merged = existing
else:
    merged = (existing.rstrip() + "\n\n" if existing.strip() else "") + jeo_instruction.strip()

new_assignment = 'developer_instructions = """\n' + merged + '\n"""\n'

if re.search(r'(?m)^developer_instructions\s*=', content):
    content = re.sub(r'(?ms)^developer_instructions\s*=\s*(""".*?"""|".*?")\s*$', new_assignment, content, count=1)
else:
    first_table = re.search(r'(?m)^\[', content)
    if first_table:
        content = content[:first_table.start()] + new_assignment + "\n" + content[first_table.start():]
    else:
        content = new_assignment + "\n" + content

with open(config_path, "w") as f:
    f.write(content)
print("✓ JEO developer_instructions synced (top-level string)")
PYEOF
  ok "JEO developer_instructions synced in ~/.codex/config.toml"

  # ── 3. Create /prompts:jeo prompt file ──────────────────────────────────────
  cat > "$JEO_PROMPT_FILE" <<'PROMPTEOF'
# JEO — Integrated Agent Orchestration Prompt

You are now operating in **JEO mode** — Integrated AI Agent Orchestration.

## Your Workflow

### Step 1: PLAN (plannotator — blocking loop)
Before writing any code, create and review a plan:
1. Write a detailed implementation plan in \`plan.md\` (objectives, steps, risks, acceptance criteria)
2. Run plannotator PLAN gate (blocking, mandatory):
   \`\`\`bash
   bash .agent-skills/jeo/scripts/plannotator-plan-loop.sh plan.md /tmp/plannotator_feedback.txt 3
   echo "PLAN_READY"
   \`\`\`
3. Read /tmp/plannotator_feedback.txt
4. If \`"approved":true\` → proceed to EXECUTE
5. If NOT approved → read annotations, revise plan.md, repeat from step 2
6. If PLAN gate exits with 32 → localhost bind blocked. run PLAN gate in local TTY (manual fallback)
NEVER skip plannotator. NEVER proceed to EXECUTE without approved=true.

### Step 2: EXECUTE (BMAD workflow for Codex)
Use BMAD structured phases:
- \`/workflow-init\` — Initialize BMAD for this project
- Analysis phase: understand requirements fully
- Planning phase: detailed technical plan
- Solutioning phase: architecture decisions
- Implementation phase: write code

### Step 3: VERIFY (agent-browser)
If the task has browser UI:
- Run: \`agent-browser snapshot http://localhost:3000\`
- Check UI elements via accessibility tree (-i flag)
- Save screenshot: \`agent-browser screenshot <url> -o verify.png\`

### Step 4: CLEANUP (worktree)
After all tasks complete:
- Run: git worktree prune
- Run: bash ${JEO_SKILL_DIR}/scripts/worktree-cleanup.sh

## Key Commands
- Plan review — run plannotator BLOCKING (no &), then output PLAN_READY:
  Mandatory behavior:
  - Wait for approve/feedback every time
  - If session dies, restart up to 3 times
  - After 3 dead sessions, stop and ask whether PLAN should be terminated
  - If loop exits 32: localhost bind blocked. use local TTY/manual PLAN gate
  \`\`\`bash
  bash .agent-skills/jeo/scripts/plannotator-plan-loop.sh plan.md /tmp/plannotator_feedback.txt 3
  # Output PLAN_READY to trigger notify hook as backup signal
  echo "PLAN_READY"
  # Check result
  python3 -c "
import json, sys
try:
    d = json.load(open('/tmp/plannotator_feedback.txt'))
    sys.exit(0 if d.get('approved') is True else 1)
except Exception:
    sys.exit(1)
" && echo "PLAN_APPROVED — proceed to EXECUTE" || cat /tmp/plannotator_feedback.txt
  \`\`\`
- Browser verify: \`agent-browser snapshot http://localhost:3000\`
- BMAD init: \`/workflow-init\`
- Worktree cleanup: \`bash ${JEO_SKILL_DIR}/scripts/worktree-cleanup.sh\`

## State File
Save progress to: \`.omc/state/jeo-state.json\`
\`\`\`json
{
  "phase": "plan|execute|verify|verify_ui|cleanup|done",
  "task": "current task description",
  "plan_approved": false,
  "team_available": false,
  "retry_count": 0,
  "last_error": null,
  "checkpoint": null
}
\`\`\`

Always check state file on resume to continue from last phase.
PROMPTEOF

  ok "JEO prompt file created: $JEO_PROMPT_FILE"

  # ── 4. Create plannotator notify hook ────────────────────────────────────────
  info "Setting up plannotator notify hook..."
  mkdir -p "$HOOK_DIR"

  cat > "$HOOK_FILE" << 'HOOKEOF'
#!/usr/bin/env python3
"""JEO Codex notify hook — detects PLAN_READY / ANNOTATE_READY and triggers plannotator / agentation."""
import hashlib, json, os, re, subprocess, sys, urllib.request, urllib.error, time

# Exact signal strings (matched as standalone lines, allowing surrounding whitespace)
PLAN_SIGNALS = ["PLAN_READY"]
ANNOTATE_SIGNALS = ["ANNOTATE_READY", "AGENTUI_READY"]

def get_jeo_phase(cwd: str) -> str:
    """Read current JEO phase from state file. Returns empty string if not available."""
    state_path = os.path.join(cwd, ".omc", "state", "jeo-state.json")
    try:
        with open(state_path) as f:
            return json.load(f).get("phase", "")
    except (FileNotFoundError, json.JSONDecodeError, KeyError):
        return ""

def get_feedback_file(cwd: str) -> str:
    """Return session-isolated feedback file path based on cwd MD5."""
    _session_key = hashlib.md5(cwd.encode()).hexdigest()[:8]
    feedback_dir = f"/tmp/jeo-{_session_key}"
    os.makedirs(feedback_dir, exist_ok=True)
    return os.path.join(feedback_dir, "plannotator_feedback.txt")


def get_plannotator_env(cwd: str) -> dict:
    _session_key = hashlib.md5(cwd.encode()).hexdigest()[:8]
    runtime_home = f"/tmp/jeo-{_session_key}/.plannotator"
    os.makedirs(runtime_home, exist_ok=True)
    env = os.environ.copy()
    env["HOME"] = runtime_home
    env["PLANNOTATOR_HOME"] = runtime_home
    return env


def get_plan_loop_script(cwd: str):
    candidates = [
        os.path.join(cwd, ".agent-skills", "jeo", "scripts", "plannotator-plan-loop.sh"),
        os.path.expanduser("~/.codex/skills/jeo/scripts/plannotator-plan-loop.sh"),
        os.path.expanduser("~/.agent-skills/jeo/scripts/plannotator-plan-loop.sh"),
    ]
    for p in candidates:
        if os.path.exists(p):
            return p
    return None

def main() -> int:
    try:
        notification = json.loads(sys.argv[1])
    except (IndexError, json.JSONDecodeError):
        return 0

    if notification.get("type") != "agent-turn-complete":
        return 0

    msg = notification.get("last-assistant-message", "").strip()
    cwd = notification.get("cwd", os.getcwd())
    phase = get_jeo_phase(cwd)

    # PLAN_READY: trigger plannotator (only during plan phase)
    if phase in ("plan",):
        if any(re.search(rf'(?m)^{re.escape(sig)}\s*$', msg or '') for sig in PLAN_SIGNALS):
            plan_candidates = ["plan.md", ".omc/plans/jeo-plan.md", "docs/plan.md"]
            plan_path = None
            for candidate in plan_candidates:
                p = os.path.join(cwd, candidate)
                if os.path.exists(p):
                    plan_path = p
                    break
            if plan_path is None:
                print("[JEO] plan.md not found in known locations")
                return 0
            feedback_file = get_feedback_file(cwd)
            loop_script = get_plan_loop_script(cwd)
            if loop_script:
                result = subprocess.run(
                    ["bash", loop_script, plan_path, feedback_file, "3"],
                    cwd=cwd,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    env=get_plannotator_env(cwd),
                )
                if result.stdout:
                    print(result.stdout.strip())
                if result.returncode == 32:
                    print("[JEO] plannotator unavailable: localhost bind blocked (sandbox/CI).")
                    print("[JEO] run PLAN gate in local TTY to use manual fallback approve/feedback.")
                print(f"[JEO] plannotator loop result code={result.returncode} feedback={feedback_file}")
            else:
                plan_content = open(plan_path).read()
                payload = json.dumps({"tool_input": {"plan": plan_content, "permission_mode": "acceptEdits"}})
                try:
                    with open(feedback_file, "w") as f:
                        subprocess.run(["plannotator"], input=payload, stdout=f, stderr=f, text=True, env=get_plannotator_env(cwd))
                    print(f"[JEO] plannotator feedback \u2192 {feedback_file}")
                except FileNotFoundError:
                    print("[JEO] plannotator not found \u2014 skipping")
            return 0

    # ANNOTATE_READY: poll agentation HTTP API (only during verify/verify_ui phase)
    if phase in ("verify", "verify_ui"):
        if any(re.search(rf'(?m)^{re.escape(sig)}\s*$', msg or '') for sig in ANNOTATE_SIGNALS):
            base_url = "http://localhost:4747"
            try:
                with urllib.request.urlopen(f"{base_url}/pending", timeout=2) as r:
                    data = json.loads(r.read())
                count = data.get("count", 0)
                annotations = data.get("annotations", [])
                if count == 0:
                    print("[JEO] agentation: no pending annotations")
                else:
                    print(f"[JEO] agentation: {count} pending annotations")
                    for ann in annotations:
                        sev = ann.get("severity", "suggestion")
                        print(f"  [{sev}] {ann.get('element','?')} | {ann.get('comment','')[:80]}")
                        print(f"    elementPath: {ann.get('elementPath','?')}")
            except (urllib.error.URLError, Exception) as e:
                print(f"[JEO] agentation server not reachable ({base_url}): {e}")
            return 0

    return 0
if __name__ == "__main__":
    sys.exit(main())
HOOKEOF

  chmod +x "$HOOK_FILE"
  ok "JEO notify hook created: $HOOK_FILE"

  # Add notify + tui to config.toml
  python3 - <<PYEOF
import re, os

config_path = os.path.expanduser("~/.codex/config.toml")
hook_path = os.path.expanduser("~/.codex/hooks/jeo-notify.py")

try:
    content = open(config_path).read() if os.path.exists(config_path) else ""
except Exception:
    content = ""

notify_line = f'notify = ["python3", "{hook_path}"]\n'
if re.search(r'(?m)^notify\s*=', content):
    content = re.sub(r'(?m)^notify\s*=.*$', notify_line.rstrip(), content, count=1)
    print("✓ notify hook synced in config.toml")
else:
    first_table = re.search(r'^\[', content, re.MULTILINE)
    if first_table:
        content = content[:first_table.start()] + notify_line + "\n" + content[first_table.start():]
    else:
        content = notify_line + content
    print("✓ notify hook registered in config.toml")

# Add agentation [[mcp_servers]] if missing
if not re.search(r'(?ms)^\[\[mcp_servers\]\]\s*\nname\s*=\s*"agentation"\s*\n', content):
    agentation_block = '\n[[mcp_servers]]\nname = "agentation"\ncommand = "npx"\nargs = ["-y", "agentation-mcp", "server"]\n'
    content = content.rstrip() + agentation_block
    print("\u2713 agentation MCP server added to config.toml")
else:
    print("\u2713 agentation MCP already in config.toml")

# Add or sync [tui] section
tui_match = re.search(r'(?ms)^\[tui\]\s*\n(.*?)(?=^\[|\Z)', content)
if not tui_match:
    content = content.rstrip() + '\n\n[tui]\nnotifications = ["agent-turn-complete"]\nnotification_method = "osc9"\n'
    print("✓ [tui] section added")
else:
    tui_body = tui_match.group(1)
    notif_match = re.search(r'(?m)^notifications\s*=\s*\[(.*?)\]\s*$', tui_body)
    notifications = []
    if notif_match:
        notifications = re.findall(r'"([^"]+)"', notif_match.group(1))
    if "agent-turn-complete" not in notifications:
        notifications.append("agent-turn-complete")
    notifications_line = 'notifications = [' + ', '.join(f'"{item}"' for item in notifications) + ']'
    if notif_match:
        tui_body = re.sub(r'(?m)^notifications\s*=\s*\[(.*?)\]\s*$', notifications_line, tui_body, count=1)
    else:
        tui_body = notifications_line + '\n' + tui_body

    if re.search(r'(?m)^notification_method\s*=', tui_body):
        tui_body = re.sub(r'(?m)^notification_method\s*=.*$', 'notification_method = "osc9"', tui_body, count=1)
    else:
        tui_body = tui_body.rstrip() + '\nnotification_method = "osc9"\n'

    content = content[:tui_match.start(1)] + tui_body + content[tui_match.end(1):]
    print("✓ [tui] notifications synced")

with open(config_path, "w") as f:
    f.write(content)
PYEOF

  ok "Codex config.toml updated (notify hook + agentation MCP + tui)"
fi

echo ""
echo "Codex CLI usage after setup:"
echo "  /prompts:jeo             ← Activate JEO orchestration workflow"
echo "  notify hook: ~/.codex/hooks/jeo-notify.py"
echo "    fires on: PLAN_READY / ANNOTATE_READY signals in agent output (AGENTUI_READY also accepted)"
echo "    writes to: /tmp/plannotator_feedback.txt"
echo ""
ok "Codex CLI setup complete"
echo ""

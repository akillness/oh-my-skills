#!/usr/bin/env bash
# JEO Skill — Codex CLI Setup
# Configures: developer_instructions in ~/.codex/config.toml + /prompts:jeo
# Usage: bash setup-codex.sh [--dry-run]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC}  $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

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
#   2. Run plannotator blocking (no &):
#      python3 -c "import json; print(json.dumps({\"tool_input\": {\"plan\": open(\"plan.md\").read(), \"permission_mode\": \"acceptEdits\"}}))" | plannotator > /tmp/plannotator_feedback.txt 2>&1
#   3. Output "PLAN_READY" to trigger notify hook as backup signal
#   4. Check /tmp/plannotator_feedback.txt: approved=true -> EXECUTE, else re-plan
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
1. Write a detailed implementation plan in `plan.md` (objectives, steps, risks, acceptance criteria)
2. Run plannotator BLOCKING (no & — wait for user review):
   ```bash
   python3 -c "import json,sys; plan=open('plan.md').read(); sys.stdout.write(json.dumps({'tool_input':{'plan':plan,'permission_mode':'acceptEdits'}}))" | plannotator > /tmp/plannotator_feedback.txt 2>&1
   echo "PLAN_READY"
   ```
3. Read /tmp/plannotator_feedback.txt
4. If `"approved":true` → proceed to EXECUTE
5. If NOT approved → read annotations, revise plan.md, repeat from step 2
NEVER skip plannotator. NEVER proceed to EXECUTE without approved=true.

### Step 2: EXECUTE (BMAD workflow for Codex)
Use BMAD structured phases:
- `/workflow-init` — Initialize BMAD for this project
- Analysis phase: understand requirements fully
- Planning phase: detailed technical plan
- Solutioning phase: architecture decisions
- Implementation phase: write code

### Step 3: VERIFY (agent-browser)
If the task has browser UI:
- Run: `agent-browser snapshot http://localhost:3000`
- Check UI elements via accessibility tree (-i flag)
- Save screenshot: `agent-browser screenshot <url> -o verify.png`

### Step 4: CLEANUP (worktree)
After all tasks complete:
- Run: git worktree prune
- Run: bash .agent-skills/jeo/scripts/worktree-cleanup.sh

## Key Commands
- Plan review — run plannotator BLOCKING (no &), then output PLAN_READY:
  ```bash
  python3 -c "import json; print(json.dumps({'tool_input': {'plan': open('plan.md').read(), 'permission_mode': 'acceptEdits'}}))" | plannotator > /tmp/plannotator_feedback.txt 2>&1
  # Output PLAN_READY to trigger notify hook as backup signal
  echo "PLAN_READY"
  # Check result
  grep -q '"approved":true' /tmp/plannotator_feedback.txt && echo "PLAN_APPROVED — proceed to EXECUTE" || cat /tmp/plannotator_feedback.txt
  ```
- Browser verify: `agent-browser snapshot http://localhost:3000`
- BMAD init: `/workflow-init`
- Worktree cleanup: `bash .agent-skills/jeo/scripts/worktree-cleanup.sh`

## State File
Save progress to: `.omc/state/jeo-state.json`
```json
{
  "phase": "plan|execute|verify|cleanup",
  "task": "current task description",
  "plan_approved": false,
  "worktrees": []
}
```

Always check state file on resume to continue from last phase.
PROMPTEOF

  ok "JEO prompt file created: $JEO_PROMPT_FILE"

  # ── 4. Create plannotator notify hook ────────────────────────────────────────
  info "Setting up plannotator notify hook..."
  HOOK_DIR="${HOME}/.codex/hooks"
  HOOK_FILE="${HOOK_DIR}/jeo-notify.py"
  mkdir -p "$HOOK_DIR"

  cat > "$HOOK_FILE" << 'HOOKEOF'
#!/usr/bin/env python3
"""JEO Codex notify hook — detects PLAN_READY signal and triggers plannotator."""
import json, os, subprocess, sys

# Signals that indicate the agent finished writing a plan
PLAN_SIGNALS = ["PLAN_READY", "plan.md created", "계획 작성 완료", "plan complete"]

def main() -> int:
    try:
        notification = json.loads(sys.argv[1])
    except (IndexError, json.JSONDecodeError):
        return 0

    if notification.get("type") != "agent-turn-complete":
        return 0

    msg = notification.get("last-assistant-message", "")
    cwd = notification.get("cwd", os.getcwd())

    # Only trigger on plan completion signals
    if not any(sig.lower() in msg.lower() for sig in PLAN_SIGNALS):
        return 0

    plan_path = os.path.join(cwd, "plan.md")
    if not os.path.exists(plan_path):
        return 0

    plan_content = open(plan_path).read()
    payload = json.dumps({"tool_input": {"plan": plan_content, "permission_mode": "acceptEdits"}})

    feedback_file = "/tmp/plannotator_feedback.txt"
    try:
        with open(feedback_file, "w") as f:
            subprocess.run(["plannotator"], input=payload, stdout=f, stderr=f, text=True)
        print(f"[JEO] plannotator feedback → {feedback_file}")
    except FileNotFoundError:
        print("[JEO] plannotator not found — skipping")

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

if not re.search(r'(?m)^notify\s*=', content):
    first_table = re.search(r'^\[', content, re.MULTILINE)
    notify_line = f'notify = ["python3", "{hook_path}"]\n'
    if first_table:
        content = content[:first_table.start()] + notify_line + "\n" + content[first_table.start():]
    else:
        content = notify_line + content
    print("✓ notify hook registered in config.toml")
else:
    print("✓ notify already configured")

# Add [tui] section if missing
if "[tui]" not in content:
    content += '\n[tui]\nnotifications = ["agent-turn-complete"]\nnotification_method = "osc9"\n'
    print("✓ [tui] notifications added")
else:
    print("✓ [tui] already configured")

with open(config_path, "w") as f:
    f.write(content)
PYEOF

  ok "Codex config.toml updated with notify hook"
fi

echo ""
echo "Codex CLI usage after setup:"
echo "  /prompts:jeo             ← Activate JEO orchestration workflow"
echo "  notify hook: ~/.codex/hooks/jeo-notify.py"
echo "    fires on: PLAN_READY signal in agent output"
echo "    writes to: /tmp/plannotator_feedback.txt"
echo ""
ok "Codex CLI setup complete"
echo ""

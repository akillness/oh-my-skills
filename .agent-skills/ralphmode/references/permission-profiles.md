# Ralphmode Permission Profiles

This file contains the concrete presets referenced by `ralphmode/SKILL.md`.
Read only the section for the platform you are configuring.

## Shared safety baseline

Apply these rules regardless of platform:

- Scope automation to one repo or disposable sandbox.
- Block secrets by default: `.env*`, `secrets/**`, credential exports, production config.
- Block destructive shell by default: `rm -rf`, `sudo`, blind remote scripts.
- Keep verification outside the permission shortcut itself.

## Claude Code

Official Claude Code docs currently expose these permission modes: `default`, `acceptEdits`, `plan`, `dontAsk`, and `bypassPermissions`.
Use them like this:

### Repo preset

Use this for normal development work:

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Bash(npm *)",
      "Bash(pnpm *)",
      "Bash(git status)",
      "Bash(git diff)",
      "Read(*)",
      "Edit(./src/**)",
      "Write(./src/**)"
    ],
    "deny": [
      "Read(.env*)",
      "Read(./secrets/**)",
      "Bash(rm -rf *)",
      "Bash(sudo *)"
    ]
  }
}
```

Recommended location:

- Project: `<repo>/.claude/settings.json`
- Personal sandbox only: `~/.claude/settings.json`

### Sandbox YOLO preset

Use only for disposable environments:

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  }
}
```

CLI equivalent:

```bash
claude --dangerously-skip-permissions
```

Keep a repo boundary and denylist even when using this mode.

### Mid-Execution Checkpoints — Claude Code

Claude Code fires `PreToolUse` before every tool call. Exit 2 blocks the tool and surfaces the message to the user.

Add to `.claude/settings.json` (project-local) or `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "bash ~/.claude/hooks/ralph-safety-check.sh",
        "timeout": 30
      }]
    }]
  }
}
```

Create `~/.claude/hooks/ralph-safety-check.sh`:

```bash
#!/usr/bin/env bash
# Blocks Tier 1 dangerous commands during ralph/jeo runs.
# Reads tool input from CLAUDE_TOOL_INPUT env var (JSON).
CMD=$(echo "$CLAUDE_TOOL_INPUT" | python3 -c \
  "import sys,json; print(json.load(sys.stdin).get('command',''))" 2>/dev/null)
TIER1='(rm[[:space:]]+-rf|git[[:space:]]+reset[[:space:]]+--hard|git[[:space:]]+push.*--force|DROP[[:space:]]+TABLE|[[:space:]]sudo[[:space:]]|chmod[[:space:]]+777|\.env|secrets/)'
if echo "$CMD" | grep -qE "$TIER1"; then
  echo "BLOCKED: Tier 1 dangerous command detected." >&2
  echo "Command: $CMD" >&2
  echo "Approve manually or remove the dangerous flag before retrying." >&2
  exit 2
fi
```

Make executable: `chmod +x ~/.claude/hooks/ralph-safety-check.sh`

> **Note**: `bypassPermissions` mode may skip `PreToolUse` hooks. Use `bypassPermissions` only in disposable sandboxes — never in repos with production credentials or sensitive data.

---

## Codex CLI

As of 2026-03-06, the primary official Codex docs focus on:

- config files and project overrides
- `approval_policy`
- `sandbox_mode`
- repo instructions such as `AGENTS.md` and `*.rules`

That is the current-first model and should be your default.

### Current repo preset

Use a repo-scoped configuration that removes approval popups without leaving the workspace boundary:

```toml
approval_policy = "never"
sandbox_mode = "workspace-write"
```

Then keep your repo policy in `AGENTS.md` or project rules:

- allow normal build, test, and repo-local write workflows
- deny destructive shell and secret access in instructions or org policy
- keep anything broader than workspace scope out of the shared default

### Current sandbox preset

Only for disposable sandboxes:

```toml
approval_policy = "never"
sandbox_mode = "danger-full-access"
```

This is the closest current equivalent to "permission skip" in Codex via config file.

### CLI flag preset (sandbox YOLO)

For a quick sandbox ralph run without touching config files, pass flags directly:

```bash
codex -c model_reasoning_effort="high" --dangerously-bypass-approvals-and-sandbox -c model_reasoning_summary="detailed" -c model_supports_reasoning_summaries=true
```

Flags explained:

- `--dangerously-bypass-approvals-and-sandbox`: bypasses all approval prompts and sandbox restrictions
- `-c model_reasoning_effort="high"`: enables high reasoning effort for complex tasks
- `-c model_reasoning_summary="detailed"`: produces detailed reasoning summaries
- `-c model_supports_reasoning_summaries=true`: enables reasoning summary output

Use only in disposable sandbox environments. This is the CLI equivalent of `approval_policy = "never"` + `sandbox_mode = "danger-full-access"`.

### Compatibility note for older Codex builds

Some community guides use a legacy-looking `permissions.allow` and `permissions.deny` schema.
If your installed Codex build still supports that shape, keep it project-local and pair it with a denylist:

```json
{
  "permissions": {
    "allow": [
      "Read(src/**)",
      "Edit(src/**)",
      "Write(*.md)",
      "Bash(npm run:*)",
      "Bash(git:*)"
    ],
    "deny": [
      "Read(.env*)",
      "Write(package.json)",
      "Bash(rm:*)",
      "Bash(sudo:*)"
    ]
  }
}
```

Treat this as a compatibility shim, not the canonical current model.

### Mid-Execution Checkpoints — Codex CLI

Codex `notify` fires after a turn completes, not before a command runs. True mid-execution blocking is not possible. Use two layers instead:

**Layer 1 — approval_policy with allow-list** (prevents auto-approval of Tier 1 commands):

```toml
# ~/.codex/config.toml or project-local override
approval_policy = "unless-allow-listed"

[[allow_list]]
# List only commands you are confident are safe.
# Tier 1 patterns must NOT appear here.
command = "npm test"
command = "npm run build"
command = "git status"
command = "git diff"
command = "cat"
command = "ls"
```

**Layer 2 — prompt contract** (add to `developer_instructions` in config.toml):

```toml
developer_instructions = """
...existing instructions...

CHECKPOINT RULE — Before executing any Tier 1 operation, you MUST stop and output:
  CHECKPOINT_NEEDED: <reason>
Then wait for the user to respond with explicit approval before proceeding.

Tier 1 operations (always require checkpoint):
- rm -rf or any recursive deletion
- git reset --hard
- git push --force or --force-with-lease
- DROP TABLE or destructive DB migrations
- sudo commands
- Reading or writing .env*, secrets/**, credential files
- Any command targeting a production environment
"""
```

> **Limitation**: Codex cannot block a command mid-turn if the agent decides to proceed without outputting `CHECKPOINT_NEEDED`. The `approval_policy` is the last line of defense — keep it as `unless-allow-listed` rather than `never` for Tier 1 risk scenarios.

---

## Gemini CLI

Gemini CLI supports both a Trusted Folders model for normal repo automation and a `--yolo` flag for full sandbox bypass.

### YOLO mode (sandbox preset)

For disposable sandbox ralph runs, use the `--yolo` flag:

```bash
gemini --yolo
```

This combines sandbox mode and auto-approve into a single flag (equivalent to the older `-s -y` combination). Use only in disposable environments — never for repos with production credentials or sensitive data.

### Trusted Folders preset (repo automation)

The safe pattern for normal repo work:

1. Trust the current project root.
2. Avoid trusting broad parent folders.
3. Keep file exposure explicit when the repo contains mixed-sensitivity areas.

### Recommended workflow

- Start Gemini in the repo you want to automate.
- Choose `Trust this folder`, not a broad parent directory.
- Use `/permissions` later if the trust level needs to be changed.

The trust state is persisted in `~/.gemini/trustedFolders.json` (as of Gemini CLI 0.x; verify against the linked official docs if your version differs). Review or reset it there if the repo layout changes or sensitive files are added later.

### Mid-Execution Checkpoints — Gemini CLI

Gemini `BeforeTool` fires before each tool call. A non-zero exit blocks the tool and the stderr output is forwarded to the agent's next turn, creating a natural confirmation loop.

Add to `~/.gemini/settings.json`:

```json
{
  "hooks": {
    "BeforeTool": [{
      "matcher": "run_shell_command",
      "hooks": [{
        "type": "command",
        "command": "bash ~/.gemini/hooks/ralph-tier1-check.sh",
        "timeout": 15
      }]
    }]
  }
}
```

Create `~/.gemini/hooks/ralph-tier1-check.sh`:

```bash
#!/usr/bin/env bash
# Gemini BeforeTool: receives tool call JSON on stdin.
# Blocks Tier 1 commands and passes the reason to the agent's next turn.
CMD=$(cat - | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d.get('args',{}).get('command',''))" 2>/dev/null)
TIER1='(rm[[:space:]]+-rf|git[[:space:]]+reset[[:space:]]+--hard|git[[:space:]]+push.*--force|DROP[[:space:]]+TABLE|[[:space:]]sudo[[:space:]]|chmod[[:space:]]+777|\.env|secrets/)'
if echo "$CMD" | grep -qE "$TIER1"; then
  echo "[RALPH-SAFETY] Tier 1 command blocked: $CMD" >&2
  echo "Reason: matches dangerous pattern. Ask the user for explicit approval before retrying." >&2
  exit 1
fi
```

Make executable: `chmod +x ~/.gemini/hooks/ralph-tier1-check.sh`

The blocked stderr is injected into the agent's context on the next turn. The agent will naturally surface the block reason to the user and wait for a response before retrying.

---

## OpenCode

OpenCode does not expose BeforeTool or PermissionRequest hooks. Use a prompt contract in `opencode.json`.

### Prompt contract

Add to the `instructions` field in `opencode.json`:

```json
{
  "instructions": "...existing instructions...\n\nCHECKPOINT RULE: Before any Tier 1 operation, output CHECKPOINT_NEEDED: <reason> and wait for explicit user approval before proceeding.\n\nTier 1 operations: rm -rf, git reset --hard, git push --force, DROP TABLE, sudo commands, reading/writing .env* or secrets/**, any production environment change."
}
```

> **Limitation**: OpenCode has no hook-based blocking. The prompt contract relies entirely on the agent following instructions. For higher-risk workflows, prefer Claude Code or Gemini CLI which support true pre-execution blocking.

---

## Platform selection summary

Use this table to decide quickly:

| Platform | Normal repo automation | Full skip equivalent | Mid-execution blocking | Notes |
| --- | --- | --- | --- | --- |
| Claude Code | `acceptEdits` or `dontAsk` with allow and deny rules | `bypassPermissions` or `claude --dangerously-skip-permissions` | `PreToolUse` hook (exit 2) | Use full bypass only in disposable sandboxes; `bypassPermissions` may skip hooks |
| Codex CLI | `approval_policy = "never"` + `sandbox_mode = "workspace-write"` | `codex -c model_reasoning_effort="high" --dangerously-bypass-approvals-and-sandbox -c model_reasoning_summary="detailed" -c model_supports_reasoning_summaries=true` | `approval_policy = "unless-allow-listed"` + prompt contract | `notify` hook is post-turn; no true pre-execution block |
| Gemini CLI | Trusted project folder | `gemini --yolo` | `BeforeTool` hook (non-zero exit) | Strongest mid-execution blocking; stderr forwarded to agent's next turn |
| OpenCode | Slash commands + `opencode.json` instructions | None | Prompt contract only | No hook-based blocking; rely on agent following instructions |

## Source notes

- Agent Skills format references are from `agentskills.io`.
- Claude permission mode names are from Anthropic's Claude Code docs.
- Codex guidance reflects OpenAI's official Codex config and ChatGPT Codex sandbox and approval docs current on 2026-03-06.
- Gemini guidance reflects the official `gemini-cli` Trusted Folders documentation.

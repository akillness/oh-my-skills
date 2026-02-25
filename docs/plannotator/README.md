# plannotator — Interactive Plan & Diff Review

> Keyword: `plan`, `계획` (alias: `planno`) | [GitHub](https://github.com/backnotprop/plannotator) | [plannotator.ai](https://plannotator.ai)
>
> Annotate and review AI coding agent plans visually, share with your team, send feedback with one click.
> Works with **Claude Code**, **OpenCode**, **Gemini CLI**, and **Codex CLI**.

## What is plannotator?

plannotator opens a **visual browser UI** when your AI coding agent finishes planning. You can annotate the plan, then either approve it (agent proceeds) or send feedback (annotations sent back as structured feedback).

**Part of AI Review Tools family** (independent tools, each with its own keyword):
| Tool | Keyword | Purpose |
|------|---------|---------|
| **plannotator** | `plan`, `계획` | Visual plan/diff review |
| **vibe-kanban** | `kanbanview` | Kanban board for AI agents |
| **copilot-coding-agent** | `copilotview` | GitHub Copilot issue→PR |

---

## Installation

### Scripts (Recommended — Automated)

All installation steps have corresponding scripts in `scripts/`. Run them directly or let the agent call them.

| Script | Purpose |
|--------|---------|
| `scripts/install.sh` | Install plannotator CLI (supports `--all`, `--with-plugin`, `--with-gemini`, `--with-codex`, `--with-opencode`) |
| `scripts/setup-hook.sh` | Configure Claude Code `ExitPlanMode` hook |
| `scripts/setup-gemini-hook.sh` | Configure Gemini CLI hook + update `GEMINI.md` |
| `scripts/setup-codex-hook.sh` | Configure Codex CLI `developer_instructions` + prompt |
| `scripts/setup-opencode-plugin.sh` | Register OpenCode plugin + slash commands |
| `scripts/check-status.sh` | Verify all integrations (Claude, Gemini, Codex, OpenCode, Obsidian) |
| `scripts/configure-remote.sh` | SSH / devcontainer / WSL setup |
| `scripts/review.sh` | Launch diff review UI |

### 1. Install the CLI

```bash
# macOS / Linux / WSL — install only
bash scripts/install.sh

# Install CLI + set up ALL AI tool integrations at once
bash scripts/install.sh --all

# Or selectively:
bash scripts/install.sh --with-plugin      # Claude Code plugin commands
bash scripts/install.sh --with-gemini      # Gemini CLI hook
bash scripts/install.sh --with-codex       # Codex CLI setup
bash scripts/install.sh --with-opencode    # OpenCode plugin

# Direct install
curl -fsSL https://plannotator.ai/install.sh | bash
```

### 2. Connect to Claude Code

**Option A — Plugin (recommended, no manual hook needed):**
```bash
/plugin marketplace add backnotprop/plannotator
/plugin install plannotator@plannotator
# IMPORTANT: Restart Claude Code after plugin install
```

**Option B — Manual hook:**
```bash
bash scripts/setup-hook.sh
# Restart Claude Code after running
```

### 3. Connect to Gemini CLI

```bash
bash scripts/setup-gemini-hook.sh
# Adds ExitPlanMode hook to ~/.gemini/settings.json
# Appends plannotator instructions to GEMINI.md
# Restart Gemini CLI after running
```

Or use `--with-gemini` during install:
```bash
bash scripts/install.sh --with-gemini
```

### 4. Connect to Codex CLI

```bash
bash scripts/setup-codex-hook.sh
# Updates ~/.codex/config.toml developer_instructions
# Creates ~/.codex/prompts/plannotator.md
# Restart Codex CLI after running
```

Or use `--with-codex` during install:
```bash
bash scripts/install.sh --with-codex
```

### 5. Connect to OpenCode

**Option A — Automated script:**
```bash
bash scripts/setup-opencode-plugin.sh
# Registers plugin, adds slash commands, restarts OpenCode
```

**Option B — Manual:**

Add to `opencode.json`:
```json
{
  "plugin": ["@plannotator/opencode@latest"]
}
```

Then restart OpenCode.

### 6. Verify installation

```bash
bash scripts/check-status.sh
```

Checks CLI version, hook configuration for all tools (Claude, Gemini, Codex, OpenCode), env vars, Obsidian integration, and git repo state.

### Skill path resolution (absolute/global)

When plannotator is loaded via skill tooling:
- Absolute skill paths are honored as-is (for example, `/Users/me/.agent-skills/plannotator`)
- Relative skill paths resolve with fallback order: configured skills directory -> global `~/.agent-skills`

### Recommended Setup Flow

```
1. bash scripts/install.sh --all
   └─ Installs CLI + configures every AI tool integration

2. bash scripts/check-status.sh
   └─ Confirm everything is ready
```

---

## Feature 1: Plan Review (Before Coding)

When your agent finishes planning, Plannotator **automatically opens a browser UI**:

### How it works
```
[Agent produces plan]
        ↓
[Plannotator UI opens in browser]
        ↓
[You annotate the plan]
        ↓
    ┌───┴───┐
    │       │
 Approve  Request Changes
    │       │
    ↓       ↓
[Agent   [Annotations sent
 codes]   back → Agent replans]
```

### Annotation types
| Type | Use |
|------|-----|
| `delete` | Remove risky or unnecessary step |
| `insert` | Add missing step |
| `replace` | Revise incorrect approach |
| `comment` | Clarify constraints or acceptance criteria |

### Claude Code usage
1. Enter plan mode: `Shift+Tab×2`
2. Agent generates the plan
3. Plannotator UI opens automatically via hook
4. Annotate → Approve or Request Changes

### Gemini CLI usage
1. Gemini CLI enters plan mode
2. Hook triggers plannotator automatically via `~/.gemini/settings.json`
3. Annotate → Approve or Request Changes

### Codex CLI usage
1. Codex CLI generates a plan (via `developer_instructions`)
2. Codex runs plannotator command from instructions (no ExitPlanMode hook in Codex)
3. Annotate → Approve or Send Feedback

### Manual plan submission (validated format)

`echo`/heredoc with `plannotator plan -` can fail with `Failed to parse hook event from stdin`.
Use python3 JSON generation:

```bash
cat > /tmp/plan.md << 'PLAN'
# Implementation Plan
## Steps
1. ...
PLAN

python3 -c "
import json
print(json.dumps({'tool_input': {'plan': open('/tmp/plan.md').read(), 'permission_mode': 'acceptEdits'}}))
" | plannotator > /tmp/plannotator_feedback.txt 2>&1 &
```

---

## Feature 2: Code Review with /plannotator-review

```bash
/plannotator-review
```

Review git diffs with **inline annotations** (New: Jan 2026):
- Select specific line numbers to annotate
- Switch between unified and split diff views
- Attach and annotate images (pen, arrow, circle tools)
- Send feedback to the active hook/session when integration path supports it

OpenCode plugin path (`/plannotator-review`) is validated and returns approval result in CLI.

---

## Feature 3: Auto-save & Sharing

### Auto-save on Approve

When you click **Approve**, plans are automatically saved if configured:
- **Obsidian integration**: Approved plans save to your vault with YAML frontmatter and tags. Configure via Settings (⚙️) → Saving → Obsidian Integration.
- **Bear Notes integration**: Approved plans save to Bear Notes. Configure via Settings (⚙️) → Saving → Bear Notes.
- **Share links**: Share plan review sessions with teammates for collaboration.

### Manual Save via Export → Notes Tab

Save the current plan at any time — **without approving or denying**:

1. Click **Export** in the toolbar
2. Click the **Notes** tab
3. Each row shows a green dot if configured, with a **Save** button
4. Click **Save** (Obsidian or Bear) or **Save All**
5. Button changes to **Saved** on success

> Requires plannotator running in hook mode (normal Claude Code ExitPlanMode hook invocation). Settings stored in **cookies** (not localStorage).

### Bear Setup (macOS)

1. Install Bear app and run it once.
2. In plannotator UI: Settings (⚙️) → Saving → Enable "Bear Notes".
3. Verify callback works from terminal:

```bash
open "bear://x-callback-url/create?title=Plannotator%20Check&text=Bear%20callback%20OK"
```

If this command does not open Bear and create a note, fix OS/browser callback handling first.

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PLANNOTATOR_REMOTE` | No auto browser open (for SSH/devcontainer) | false |
| `PLANNOTATOR_PORT` | Fixed port for the local server | auto |
| `PLANNOTATOR_BROWSER` | Custom browser executable path | system default |
| `PLANNOTATOR_SHARE_URL` | Custom share portal URL | plannotator.ai |

```bash
export PLANNOTATOR_REMOTE=1
export PLANNOTATOR_PORT=9999
```

---

## Keyword Activation

```text
plan으로 이번 구현 계획을 검토하고 수정 코멘트를 만들어줘.
계획 검토하고 수정 코멘트 만들어줘.
```

> 이전 키워드 `planno`도 하위 호환으로 계속 동작합니다.

---

## Best Practices

1. **Review plans before coding** — catch wrong approaches before they become wrong code
2. **One annotation per concern** — multiple issues in one annotation confuse agents
3. **Include acceptance criteria** — "Request Changes" should specify testable conditions
4. **Use image annotations** for UI/UX feedback where text descriptions fall short
5. **Specific line annotations** for diff review — don't annotate whole files when one line is the issue
6. **Kill stale instances first** — run `pkill plannotator 2>/dev/null; sleep 1` before a new session
7. **Reload once in automation** — Playwright flow should include `page.reload()` before clicking Approve/Send Feedback

---

## Known Limitations (validated 2026-02-23)

1. `plannotator plan -` with heredoc/echo can fail to parse stdin; use python3 JSON format.
2. Keeping stdin open (for example with `sleep`) blocks server start; stdin EOF must be immediate.
3. First browser load can show demo plan; call `page.reload()` in automated tests.
4. Send Feedback requires at least one annotation first.
5. `plannotator review` requires a git repository.
6. Export → Notes tab Save requires plannotator in **hook mode** (stdin JSON). CLI `review`/`annotate` modes do not expose `/api/save-notes`. Normal Claude Code hook invocation always uses hook mode.
7. Obsidian Integration settings must be configured in the system browser that plannotator auto-opens (not in Playwright or other isolated browser profiles).
8. Bear export also depends on custom URI handling (`bear://x-callback-url/create`) and must be configured/tested in the system browser session.

---

## References

- [GitHub: backnotprop/plannotator](https://github.com/backnotprop/plannotator)
- [plannotator.ai](https://plannotator.ai)
- [Installation details](https://github.com/backnotprop/plannotator/blob/main/apps/hook/README.md)
- [Latest release: v0.9.2](https://github.com/backnotprop/plannotator/releases/tag/v0.9.2)

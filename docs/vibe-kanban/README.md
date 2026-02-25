# Vibe Kanban

A visual Kanban board for managing AI coding agents. Tasks move through stages — To Do → In Progress → Review → Done — with AI agents automatically assigned to and executing tasks.

---

## Overview

Vibe Kanban provides a browser-based board that coordinates one or more AI agents (Claude, Codex, Gemini) across a set of task cards. Each card represents a discrete unit of work. When an agent is assigned to a card, it picks up the task, executes it in an isolated environment, and advances the card through the pipeline on completion.

Key capabilities:

- Visual progress tracking across a sprint or feature set
- Parallel agent execution on independent tasks
- Git worktree isolation per task card
- Automatic PR creation on task completion
- plannotator integration for epic-level plan review before card creation (keyword: `plan` / `계획`, optional, independent)

---

## Installation

No global install is required. Run directly with `npx`:

```bash
# Run directly (no install needed) - default port 3000
npx vibe-kanban

# Port conflict (e.g. Next.js dev server on 3000)
PORT=3001 npx vibe-kanban --port 3001

# Or use the wrapper script
bash scripts/vibe-kanban-start.sh

# With custom port
bash scripts/vibe-kanban-start.sh --port 3001
```

After starting, the board is available at `http://localhost:3000` (or your configured port).

Startup log (verified v0.1.17):
```
Starting vibe-kanban v0.1.17...
No user profiles.json found, using defaults only
Starting PR monitoring service with interval 60s
Remote client initialized with URL: https://api.vibekanban.com
Main server on :3000, Preview proxy on :XXXXX
Opening browser...
```

**Supported agents** (verified v0.1.17): Opencode, Claude Code, Codex, Gemini, Amp, Qwen Code, Copilot, Droid, Cursor Agent

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `HOST` | Server host | `127.0.0.1` |
| `VIBE_KANBAN_REMOTE` | Allow remote connections | `false` |
| `VK_ALLOWED_ORIGINS` | CORS allowed origins | — |
| `DISABLE_WORKTREE_CLEANUP` | Disable worktree cleanup | — |
| `ANTHROPIC_API_KEY` | For Claude Code-powered tasks | — |
| `OPENAI_API_KEY` | For Codex-powered tasks | — |
| `GOOGLE_API_KEY` | For Gemini-powered tasks | — |

> **Port collision warning**: Default port is `3000`. If Next.js or other dev servers use 3000, run `PORT=3001 npx vibe-kanban --port 3001`.

Set variables in your shell or in a `.env` file at the project root before starting the server.

---

## MCP Integration

Vibe Kanban can run as an MCP (Model Context Protocol) server, allowing AI agents to directly control the board programmatically.

### Platform Compatibility Matrix

| Platform | 지원 방식 | 필요 설정 |
|---|---|---|
| Claude | Native MCP server registration | `~/.claude/settings.json` or `.mcp.json` |
| Codex | MCP script-assisted setup | `bash <your-agent-skills>/vibe-kanban/scripts/mcp-setup.sh --codex` |
| Gemini | MCP registration | 동일 패턴 설정 |
| OpenCode | MCP/브릿지 연동 | `omx`/`ohmg`류 또는 동일 토폴로지 |

`현재 스킬만`으로 가능한지:
- Claude/Gemini: **가능**
- Codex: **가능(스크립트 기반)** 
- OpenCode: **가능(오케스트레이션 경유)**

### Claude Code MCP Configuration

Add to `~/.claude/settings.json` or project `.mcp.json`:

```json
{
  "mcpServers": {
    "vibe-kanban": {
      "command": "npx",
      "args": ["vibe-kanban", "--mcp"],
      "env": {
        "MCP_HOST": "127.0.0.1",
        "MCP_PORT": "3001"
      }
    }
  }
}
```

### Available MCP Tools

| Tool | Description |
|------|-------------|
| `vk_list_cards` | List all cards (workspaces) |
| `vk_create_card` | Create a new card |
| `vk_move_card` | Change card status |
| `vk_get_diff` | Get card diff |
| `vk_retry_card` | Retry card execution |

> ⚠️ **Tool name change**: `vk_list_tasks` → `vk_list_cards`, `vk_create_task` → `vk_create_card` (verified v0.1.17)

### Codex MCP setup

When using Codex, set up MCP via the script included in this skill:

```bash
bash <your-agent-skills>/vibe-kanban/scripts/mcp-setup.sh --codex
```

It appends MCP server config under `~/.codex/config.toml` and writes a `vibe-kanban` MCP entry.

> Note: This skill is not an Auto-hook loop system. For autonomous repeat behavior, combine with the skill or workflow that your Codex orchestration layer already provides.

### OpenCode MCP Configuration

Add to `~/.config/opencode/opencode.json`:

```json
{
  "mcp": {
    "vibe-kanban": {
      "command": "npx",
      "args": ["vibe-kanban", "--mcp"],
      "env": {
        "MCP_HOST": "127.0.0.1",
        "MCP_PORT": "3001"
      }
    }
  }
}
```

After restarting OpenCode, `vk_*` tools are available directly in your session.

---

## Remote Deployment

### Docker

```bash
# Official image
docker run -p 3000:3000 vibekanban/vibe-kanban

# With environment variables
docker run -p 3000:3000 \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  -e VK_ALLOWED_ORIGINS=https://vk.example.com \
  vibekanban/vibe-kanban
```

### Reverse Proxy (Nginx/Caddy)

```bash
# CORS configuration required
VK_ALLOWED_ORIGINS=https://vk.example.com

# Multiple origins
VK_ALLOWED_ORIGINS=https://a.example.com,https://b.example.com
```

### SSH Remote Access

Integrate with VSCode Remote-SSH:
```
vscode://vscode-remote/ssh-remote+user@host/path/to/.vibe-kanban-workspaces/<workspace-uuid>
```

---

## Troubleshooting

### Worktree Conflicts / Orphaned Worktrees

```bash
# Clean orphaned worktrees
git worktree prune

# List current worktrees
git worktree list

    # Force remove a specific worktree
    git worktree remove ~/.vibe-kanban-workspaces/<workspace-uuid> --force
```

### 403 Forbidden (CORS Error)

```bash
# Set CORS when accessing remotely
VK_ALLOWED_ORIGINS=https://your-domain.com npx vibe-kanban
```

### Agent Won't Start

```bash
# Test CLI directly
claude --version
codex --version

# Check API keys
echo $ANTHROPIC_API_KEY
echo $OPENAI_API_KEY
```

### Port Conflict

```bash
# Use a different port
npx vibe-kanban --port 3001

# Or via environment variable
PORT=3001 npx vibe-kanban
```

### SQLite Lock Error

```bash
# Disable worktree cleanup and restart
DISABLE_WORKTREE_CLEANUP=1 npx vibe-kanban
```

---

## Workflow — Task → Parallel Agents → PR

### 1. Start the Server

```bash
npx vibe-kanban
# → http://localhost:3000
```

### 2. (Optional) Review Epic Plan with plannotator

Before creating cards, review the feature breakdown visually:

```text
plan으로 이 기능의 구현 계획을 검토해줘
```

plannotator is an independent skill — usable without Vibe Kanban.

### 3. Create Task Cards

- Add cards to the **To Do** column
- Set title, description, priority (High / Medium / Low)
- Select agent: Claude / Codex / Gemini

### 4. In Progress → Agent Auto-Start

Drag a card to **In Progress**:
- `vk/<hash>-<slug>` branch auto-created
- git worktree auto-created (fully isolated per agent)
- Agent CLI launched with log streaming

### 5. Review Column

- Inspect the branch diff in the web UI
- View agent logs and "thinking process"
- **Retry** with same agent or reassign to a different agent

### 6. PR Creation & Done

- Approve → GitHub PR auto-created
- PR merge → card moves to **Done**
- Worktree auto-cleaned up

---

## Use Cases

### 1. Parallel Epic Decomposition

```
"Payment Flow v2" epic
  ├── Card 1: Frontend UI    → Claude
  ├── Card 2: Backend API    → Codex
  └── Card 3: Integration Tests → Claude
→ 3 cards simultaneously In Progress → parallel implementation
```

### 2. Role-Based Agent Assignment

```
Claude  → Design/domain-heavy features
Codex   → Types/tests/refactoring
Gemini  → Docs/Storybook writing
```

### 3. GitHub PR Team Collaboration

```
VIBE_KANBAN_REMOTE=true
→ Team views board status
→ Review/approve only in GitHub PR
→ Parallel agents + traditional PR process combined
```

### 4. Implementation Comparison

```
Same task, two cards:
  Card A → Claude (UI structure focus)
  Card B → Codex (performance focus)
→ Compare PRs → pick best-of-both
```

### 5. OpenCode + ulw Parallel Delegation

Combine Vibe Kanban with OpenCode's ulw (ultrawork) mode to run agents in parallel at the epic level:

```python
# ulw keyword → ultrawork parallel execution layer activated
# Run Vibe Kanban board: npx vibe-kanban (in a separate terminal)

task(category="visual-engineering", run_in_background=True,
     load_skills=["frontend-ui-ux", "vibe-kanban"],
     description="[Kanban WS1] Frontend UI",
     prompt="Implement payment flow UI — card input, order confirmation, completion screens in src/components/payment/")

task(category="unspecified-high", run_in_background=True,
     load_skills=["vibe-kanban"],
     description="[Kanban WS2] Backend API",
     prompt="Implement payment API — POST /charge, POST /refund, GET /status/:id")

task(category="unspecified-low", run_in_background=True,
     load_skills=["vibe-kanban"],
     description="[Kanban WS3] Integration Tests",
     prompt="Write payment E2E tests — success, failure, and refund scenarios")

# → 3 workspaces appear simultaneously in Running state on the Kanban board
# → Each completion: Needs Attention → PR created → Archive
```

---

## Conductor Pattern (CLI Mode)

Vibe Kanban uses the Conductor Pattern internally — each card moved to **In Progress** creates a git worktree and launches an agent in that isolated directory. The same mechanism is available as a pure CLI pipeline without the Kanban UI.

### When to use CLI vs UI

| Scenario | Mode |
|----------|------|
| Team shared board, visual progress tracking | UI mode (`npx vibe-kanban`) |
| CI/CD pipelines, scripted automation | CLI mode (`scripts/pipeline.sh`) |
| Quick local experiments, no UI needed | CLI mode (`scripts/conductor.sh`) |
| Browser-based diff and log review | UI mode |

### Running conductor.sh directly

`scripts/conductor.sh` reads a task list and creates one git worktree per task, then launches agents in parallel:

```bash
# Run conductor for a feature branch
bash scripts/conductor.sh <feature-name>
```

Each task gets its own worktree under `.vk/trees/`, the same structure Vibe Kanban UI creates when you drag a card to In Progress.

### Running the full pipeline

`scripts/pipeline.sh` chains multiple stages together: pre-checks, parallel agent execution via conductor, and automatic PR creation:

```bash
# Full pipeline: check → parallel agents → PR
bash scripts/pipeline.sh <feature-name> --stages check,conductor,pr

# Skip checks, run conductor and PR only
bash scripts/pipeline.sh <feature-name> --stages conductor,pr
```

### Underlying mechanism

Whether you use the Kanban UI or the CLI scripts, the git worktree mechanism is identical:

```
git worktree add .vk/trees/<task-slug> -b vk/<hash>-<task-slug> main
<agent-cli> -p "<task-description>" --cwd .vk/trees/<task-slug>
```

Worktrees are isolated — multiple agents run concurrently without conflicting file edits. After the PR is merged, the worktree is cleaned up automatically.

---

### 2. Plan Review with plannotator (Optional, Independent)

Before creating individual task cards, you can optionally review the epic breakdown using plannotator — a separate, independent skill:

```text
plan으로 이 기능의 구현 계획을 검토해줘
```

plannotator breaks the feature spec into an ordered set of sub-tasks. Review and adjust the plan, then approve it. Approved specs become the source of truth for card creation. plannotator operates independently — you can use Vibe Kanban without it.

### 3. Create Tasks

Add task cards to the **To Do** column. Each card should represent a single, atomic unit of work derived from the approved plannotator spec (or your own task breakdown if not using plannotator).

### 4. Assign Agents

Click a task card and select an AI agent from the assignment panel:

- **Claude** — via `ANTHROPIC_API_KEY`
- **Codex** — via `OPENAI_API_KEY`
- **Gemini** — via Google credentials

### 5. Auto-execution

The assigned agent picks up the task and the card moves to **In Progress** automatically. The agent works inside an isolated git worktree (see below) and reports progress back to the board.

### 6. Review

When the agent completes work, a PR is created and the card moves to **Review**. Open the PR link from the card detail view to inspect the diff.

### 7. Merge

Approve and merge the PR. The card advances to **Done**.

---

## plannotator Integration — Optional, Independent

plannotator is an independent skill for epic-level plan review. It is not required by Vibe Kanban — each tool operates on its own. Use plannotator when you want visual annotation and approval of the implementation plan before breaking it into cards.

Typical flow (when using plannotator alongside Vibe Kanban):

1. Describe the feature or epic in natural language.
2. Ask plannotator to decompose it: `plan으로 이 기능의 구현 계획을 검토해줘`
3. Review the generated breakdown — adjust ordering, scope, or dependencies.
4. Approve the plan.
5. Create one card per approved sub-task in Vibe Kanban.

Skipping plannotator is perfectly fine for small, self-contained tasks. For larger features with many moving parts, plannotator helps prevent scope creep before card creation.

---

## Git Worktree Integration

Each task card can optionally operate in an isolated git worktree:

- **Card created** — a worktree is auto-generated from the current branch at `worktrees/<card-id>/`.
- **Agent works in isolation** — changes do not affect the main working tree or other cards.
- **PR created on completion** — the agent commits work, pushes to a feature branch, and opens a PR.
- **Worktree cleaned up** — after the PR is merged, the worktree is removed automatically.

This isolation means multiple agents can work on different cards simultaneously without conflicting file edits.

---

## Use Cases

- **Parallel feature development** — assign different agents to independent feature cards and let them run concurrently.
- **Sprint tracking** — visualize all in-flight AI tasks across a team in one board.
- **Implementation comparison** — create two cards for the same problem, assign different agents, and compare the resulting PRs.
- **Team coordination** — multiple developers each manage their own agent assignments from a shared board view when `VIBE_KANBAN_REMOTE=true`.

---

## Tips

- Keep card scope narrow. One card = one commit-worthy change. Broad cards lead to large, hard-to-review PRs.
- Use plannotator (independent skill, keyword: `plan` / `계획`) for any feature touching more than two files.
- Set `VIBE_KANBAN_REMOTE=true` only on trusted networks — it exposes the board and agent controls to all connections on the port.
- If an agent stalls on a card, reassign to a different agent or break the card into smaller pieces.

---

## Quick Reference

```
=== Start Server ===
npx vibe-kanban                    Instant launch
bash scripts/vibe-kanban-start.sh  Wrapper script
http://localhost:3000              Board UI

=== Environment Variables ===
VIBE_KANBAN_PORT=3001              Change port
VIBE_KANBAN_REMOTE=true            Allow remote access
ANTHROPIC_API_KEY=...              Claude auth
OPENAI_API_KEY=...                 Codex/GPT auth

=== Card Flow ===
To Do → In Progress → Review → Done
In Progress: worktree created + agent started
Review: diff/logs visible + Retry available
Done: PR merged

=== Worktree Cleanup ===
git worktree prune                 Remove orphans
git worktree list                  List all worktrees
```

---

## References

- [GitHub: BloopAI/vibe-kanban](https://github.com/BloopAI/vibe-kanban)
- [Official site: vibekanban.com](https://vibekanban.online)
- [Demo: Run Multiple Claude Code Agents Without Git Conflicts](https://www.youtube.com/watch?v=W45XJWZiwPM)

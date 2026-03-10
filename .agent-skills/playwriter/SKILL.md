---
name: playwriter
description: Playwright-based browser automation via Chrome extension + MCP/CLI. Connects to your RUNNING browser (existing logins, cookies, extensions preserved). Use for authenticated flows, stateful web automation, and AI agent browser control without re-logging in.
license: MIT
compatibility: Requires Chrome browser + Playwriter Chrome extension (Web Store) + npm install -g playwriter. MCP integration works with Claude Desktop, Codex CLI, Gemini CLI. localhost:19988 WebSocket relay server.
metadata:
  version: 1.0.0
  source: remorses/playwriter
  tags: playwright, browser-automation, chrome-extension, mcp, authenticated, stateful, session
allowed-tools: Read Write Bash Grep Glob
---

# playwriter - Playwright Browser Automation for AI Agents

Playwriter connects AI agents to your **running Chrome browser** instead of spawning a new headless instance. Your existing logins, cookies, extensions, and tab state are all preserved.

## When to use this skill

- Automate sites that require login (Gmail, GitHub, internal tools) without re-authenticating
- Control your real browser tab with full Playwright API access
- Run stateful automation that spans multiple steps (shopping carts, multi-step forms)
- Use MCP integration for Claude Desktop / AI agent browser control
- Record browser sessions or debug with CDP inspection
- Remote browser automation via tunnels

**vs. agent-browser**: agent-browser spawns a fresh headless browser (isolated, CI-friendly). playwriter connects to your existing Chrome session (authenticated, stateful, with your extensions).

## Installation

### Step 1: Install Chrome Extension

Install the **Playwriter** Chrome extension from the Web Store (search "Playwriter MCP" or use extension ID `jfeammnjpkecdekppnclgkkffahnhfhe`).

After installing, click the extension icon on any tab you want to allow automation on. The icon turns **green** when a tab is enabled for control.

### Step 2: Install CLI

```bash
npm install -g playwriter
# or run without installing:
npx playwriter@latest --help
```

The extension auto-starts a WebSocket relay server at `localhost:19988`.

## Core workflow

Always follow the Observe → Act → Observe pattern:

```bash
# 1. Create a session
playwriter session new

# 2. Navigate and observe
playwriter -s 1 -e 'await page.goto("https://example.com")'
playwriter -s 1 -e 'await snapshot({ page })'

# 3. Interact based on snapshot output
playwriter -s 1 -e 'await page.locator("aria-ref=e5").click()'

# 4. Re-observe after action
playwriter -s 1 -e 'await snapshot({ page })'
```

## Session management

```bash
# Create a new isolated stateful session
playwriter session new

# List all active sessions (shows browser, profile, state info)
playwriter session list

# Delete a session and clear its state
playwriter session delete <sessionId>

# Reset the CDP connection and clear execution environment
playwriter session reset <sessionId>
```

## The -e / --eval flag

Execute arbitrary Playwright code in a session:

```bash
# Navigate to a URL
playwriter -s 1 -e 'await page.goto("https://github.com")'

# Fill a form field
playwriter -s 1 -e 'await page.fill("#search", "playwriter"); await page.keyboard.press("Enter")'

# Get accessibility snapshot (preferred over screenshots for text content)
playwriter -s 1 -e 'await snapshot({ page })'

# Take screenshot with visual accessibility labels (color-coded by element type)
playwriter -s 1 -e 'await screenshotWithAccessibilityLabels({ page })'

# Store state between calls (state object persists within session)
playwriter -s 1 -e 'state.url = page.url(); state.title = await page.title()'
playwriter -s 1 -e 'console.log(state.url, state.title)'
```

**Quoting rules**: Wrap code in single quotes. For multiline code, use heredoc:

```bash
playwriter -s 1 -e "$(cat <<'EOF'
const text = await page.textContent('h1');
state.heading = text;
await snapshot({ page });
EOF
)"
```

## MCP Integration

### Claude Desktop config (`~/.claude/settings.json` or Claude Desktop MCP settings)

```json
{
  "mcpServers": {
    "playwriter": {
      "command": "npx",
      "args": ["-y", "playwriter@latest"]
    }
  }
}
```

### Remote relay server

```json
{
  "mcpServers": {
    "playwriter": {
      "command": "npx",
      "args": ["-y", "playwriter@latest"],
      "env": {
        "PLAYWRITER_HOST": "your-relay-host",
        "PLAYWRITER_TOKEN": "your-secret-token",
        "PLAYWRITER_SESSION": "1"
      }
    }
  }
}
```

### MCP tools exposed

| Tool | Description |
|------|-------------|
| `execute` | Run arbitrary JavaScript Playwright code (`code`, `timeout` params) |
| `reset` | Recreate CDP connection, clear state — use after connection failures |

## Built-in globals (in execute sandbox)

| Global | Description |
|--------|-------------|
| `page` | Current Playwright page |
| `context` | Browser context |
| `state` | Persistent object — survives multiple `-e` calls in same session |
| `snapshot({ page })` | Accessibility tree as text (token-efficient) |
| `screenshotWithAccessibilityLabels({ page })` | Screenshot with color-coded element markers |
| `getPageMarkdown()` | Article text via Mozilla Readability |
| `waitForPageLoad()` | Smart load detection |
| `getLatestLogs()` | Browser console errors/logs |
| `getCleanHTML()` | Cleaned DOM HTML |
| `getLocatorStringForElement()` | Get selector for a DOM element |
| `getReactSource()` | React component source tree |

## Accessibility labeling

`screenshotWithAccessibilityLabels({ page })` overlays color-coded markers on interactive elements:

| Color | Element type |
|-------|-------------|
| Yellow | Links |
| Orange | Buttons |
| Coral | Inputs |
| Pink | Checkboxes |
| Peach | Sliders |

Click a labeled element using `aria-ref`:
```bash
playwriter -s 1 -e 'await page.locator("aria-ref=e5").click()'
```

## Network interception and state persistence

```bash
# Intercept network requests
playwriter -s 1 -e 'state.requests = []; page.on("request", r => state.requests.push(r.url()))'

# Check collected requests later
playwriter -s 1 -e 'console.log(state.requests.slice(-5).join("\n"))'

# Screen recording
playwriter -s 1 -e 'await recording.start()'
# ... do actions ...
playwriter -s 1 -e 'const video = await recording.stop(); state.video = video'
```

## Remote access

Control Chrome on a remote machine via tunnel:

```bash
# On the machine with Chrome:
playwriter serve --token my-secret --replace

# From agent machine:
playwriter --host <ip-or-hostname> --token my-secret -s 1 -e 'await page.goto("https://example.com")'
```

## Best practices

- **Observe → Act → Observe**: always call `snapshot({ page })` before and after each action
- **Prefer `snapshot()` over screenshots** for text inspection (fewer tokens, faster)
- **Never chain actions blindly** — verify state between steps
- **Use stable selectors**: prefer `aria-ref`, `data-testid`, or accessible roles
- **Store context in `state`**: avoid repeated navigation by persisting page references
- **Use `reset` on failures**: CDP disconnects recover cleanly with `playwriter session reset`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Extension not connecting | Click extension icon on the tab; icon must be green |
| `connection refused :19988` | Extension auto-starts server; check Chrome is running with extension installed |
| Code execution timeout | Increase with `--timeout 30000` flag |
| Click fails silently | Use `snapshot({ page })` — a modal likely intercepts the click |
| Stale session | Run `playwriter session reset <id>` to restore CDP connection |
| Remote access failing | Confirm `playwriter serve` is running and token matches |

## References

- [GitHub: remorses/playwriter](https://github.com/remorses/playwriter)
- [Chrome Extension Web Store](https://chromewebstore.google.com/detail/playwriter-mcp/jfeammnjpkecdekppnclgkkffahnhfhe)
- `playwriter skill` — print full usage guide from CLI
- `playwriter logfile` — view relay server + CDP log paths

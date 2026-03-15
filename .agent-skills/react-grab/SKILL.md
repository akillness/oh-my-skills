---
name: react-grab
description: >
  Install and configure react-grab to capture React component context (file path, component name,
  HTML markup) from any browser UI element for AI coding agents. Use when you want to point at a
  UI element in the browser and instantly copy its React component name, source file path, and HTML
  to clipboard for Claude Code, Cursor, Copilot, Gemini, or Codex. Triggers on: react-grab, grab,
  grab element context, copy component to ai, point and copy to claude, ui context clipboard,
  element to ai agent, click component copy, grab ui component, react component inspector,
  browser element context, component source file, copy element context, feed element to ai,
  element picker, grab react component, inspect element ai, component to clipboard, react devtools ai.
allowed-tools: Bash Read Write Edit Glob Grep WebFetch
metadata:
  tags: react-grab, grab, element-context, ai-agent, clipboard, component-inspector, dev-tools, react, browser, mcp
  version: "1.0"
  source: https://github.com/aidenybai/react-grab
  license: MIT
---

# react-grab — Browser Element Context for AI Agents

> **Keyword**: `react-grab` · `grab` · `element context` · `copy component to ai`
>
> Point at any UI element in your browser, press Cmd/Ctrl+C, and instantly copy its React
> component name, source file path, and HTML markup to clipboard — ready for your AI coding agent.

## When to use this skill

- Set up react-grab in a React project (Next.js, Vite, Webpack) for AI-assisted development
- Point at UI elements and copy precise component context to Claude Code / Cursor / Copilot / Gemini
- Add react-grab MCP server so your AI agent can receive element context programmatically
- Configure react-grab with a custom plugin for project-specific workflows (Jira, Figma, etc.)
- Use the programmatic API (`getElementContext`, `freeze`) for automation or test tooling
- Remove react-grab from a project or a specific agent integration

## Instructions

1. Run `bash scripts/install.sh` (or `npx -y grab@latest init`) to install react-grab in your project
2. Start your dev server — react-grab is dev-only and never ships to production
3. Open your app in a browser, hover over any element, and press **Cmd+C** (Mac) / **Ctrl+C** (Win)
4. Paste the clipboard content into your AI coding agent (Claude Code / Cursor / Copilot / Gemini)
5. Optionally run `bash scripts/add-agent.sh mcp` to enable MCP tool access for programmatic use

> For detailed API and framework-specific setup, see [references/api.md](references/api.md).

---

## Examples

### Copy element context to Claude Code

```
# 1. Start your app
npm run dev

# 2. Hover over a button in the browser
# 3. Press Cmd+C (Mac) or Ctrl+C (Win/Linux)
# Clipboard now contains:
#
# in LoginForm at components/login-form.tsx:46:19
#
# <button class="btn-primary" type="submit">
#   Log in
# </button>

# 4. Paste into Claude Code — it knows exactly where the component lives
```

### Set up MCP integration

```bash
# Install react-grab MCP server
npx -y grab@latest add mcp

# Your AI agent can now call the get_element_context MCP tool
# to receive element context after you select it in the browser
```

### Add custom plugin action

```ts
import { registerPlugin } from "react-grab";

registerPlugin({
  name: "open-in-figma",
  actions: [{
    id: "figma",
    label: "Find in Figma",
    shortcut: "F",
    onAction: (ctx) => {
      window.open(`figma://search?q=${ctx.componentName}`);
    },
  }],
});
```

---

## Quick Start

```bash
# One command — auto-detects your framework and installs everything
npx -y grab@latest init

# Add MCP server for programmatic AI agent access
npx -y grab@latest add mcp

# Add to a specific AI agent
npx -y grab@latest add claude-code
```

After installation, hover over any element in your browser during development and press:
- **Mac**: `Cmd+C`
- **Windows/Linux**: `Ctrl+C`

Output copied to clipboard:
```
in LoginForm at components/login-form.tsx:46:19

<a class="ml-auto text-sm underline-offset-4 hover:underline">
  Forgot your password?
</a>
```

Paste directly into your AI coding agent prompt — no file searching needed.

---

## Installation

### Auto-detect (Recommended)

```bash
npx -y grab@latest init
```

Detects your framework (Next.js App Router / Pages Router / Vite / TanStack Start / Webpack)
and package manager (npm / yarn / pnpm / bun) automatically.

### Manual installation by framework

**Next.js App Router** (`app/layout.tsx`):
```tsx
import Script from 'next/script'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        {process.env.NODE_ENV === "development" && (
          <Script
            src="//unpkg.com/react-grab/dist/index.global.js"
            crossOrigin="anonymous"
            strategy="beforeInteractive"
          />
        )}
      </body>
    </html>
  )
}
```

**Next.js Pages Router** (`pages/_document.tsx`):
```tsx
import Script from 'next/script'

// Inside _document component:
{process.env.NODE_ENV === "development" && (
  <Script
    src="//unpkg.com/react-grab/dist/index.global.js"
    crossOrigin="anonymous"
    strategy="beforeInteractive"
  />
)}
```

**Vite** (`index.html`):
```html
<script type="module">
  if (import.meta.env.DEV) {
    await import('//unpkg.com/react-grab/dist/index.global.js');
  }
</script>
```

**Webpack** (entry file):
```js
if (process.env.NODE_ENV === 'development') {
  import('react-grab');
}
```

**Package install** (for programmatic use):
```bash
npm install react-grab
# or: pnpm add react-grab | yarn add react-grab | bun add react-grab
```

### Install react-grab via skill scripts

```bash
# Auto-detect framework and install
bash scripts/install.sh

# Install for a specific framework
bash scripts/install.sh --framework next-app

# Add to a specific AI agent
bash scripts/add-agent.sh claude-code
bash scripts/add-agent.sh cursor
bash scripts/add-agent.sh mcp
```

---

## Core Usage

### Keyboard shortcut

In development mode:
1. Hover over any React element in the browser
2. Press **Cmd+C** (Mac) or **Ctrl+C** (Windows/Linux)
3. The context is copied to clipboard

Output format:
```
in <ComponentName> at <file-path>:<line>:<col>

<element-html>
```

### Floating toolbar

A draggable toolbar appears in the corner of your browser when react-grab is active:
- Click to toggle activation on/off
- Drag to any screen edge
- Collapse when not needed

### Multi-element selection (drag)

Click and drag across multiple elements to capture all their contexts at once. Each element's
component stack and HTML is included in the clipboard output.

### Programmatic API

```ts
import { getGlobalApi } from "react-grab";

const api = getGlobalApi();

// Activate the overlay
api.activate();   // show overlay
api.deactivate(); // hide overlay
api.toggle();     // toggle

// Copy an element's context to clipboard
await api.copyElement(document.querySelector('.my-button'));

// Get source info without copying
const source = await api.getSource(element);
console.log(source.filePath);     // "src/components/Button.tsx"
console.log(source.lineNumber);   // 42
console.log(source.componentName); // "Button"

// Get the full stack context string
const stack = await api.getStackContext(element);
// "in Button (at Button.tsx:42:5)\n  in Card (at Card.tsx:10:3)"

// Check current state
const state = api.getState();
// { isActive, isDragging, isCopying, targetElement, ... }
```

---

## Primitives API (standalone usage)

Use without the default overlay UI — for automation, test tooling, or custom integrations:

```ts
import { getElementContext, freeze, unfreeze, openFile } from "react-grab/primitives";
// or: import { getElementContext } from "react-grab/core";

const button = document.querySelector('.submit-btn');

// Freeze page state (pause React updates, CSS animations, preserve :hover/:focus)
freeze();

// Get all context for an element
const context = await getElementContext(button);
console.log(context.componentName); // "SubmitButton"
console.log(context.selector);      // "button.submit-btn"
console.log(context.stackString);   // "in SubmitButton (at Button.tsx:12:5)"
console.log(context.htmlPreview);   // "<button class=\"submit-btn\">Submit</button>"
console.log(context.styles);        // Relevant computed CSS

unfreeze(); // Restore normal page behavior

// Open the source file in editor
await openFile("/src/components/Button.tsx", 12);
```

---

## MCP Integration

react-grab ships an MCP server (`@react-grab/mcp`) for programmatic AI agent access:

```bash
# Add MCP server
npx -y grab@latest add mcp
```

The MCP server exposes a `get_element_context` tool that returns the most recent element
selection from the browser overlay. Your AI agent calls this tool to receive the context
that you selected in the browser.

**Flow:**
1. You hover over element in browser → react-grab captures context
2. AI agent calls `get_element_context` MCP tool
3. Agent receives: component name, file path, line number, HTML markup
4. Agent makes precise code changes without file searching

---

## AI Agent Integration

Add react-grab to your specific AI coding agent:

```bash
npx -y grab@latest add claude-code    # Claude Code
npx -y grab@latest add cursor         # Cursor
npx -y grab@latest add copilot        # GitHub Copilot
npx -y grab@latest add codex          # OpenAI Codex
npx -y grab@latest add gemini         # Google Gemini CLI
npx -y grab@latest add opencode       # OpenCode
npx -y grab@latest add amp            # Amp
npx -y grab@latest add droid          # Droid
```

Remove an integration:
```bash
npx -y grab@latest remove cursor
```

---

## Plugin System

Extend react-grab with custom context menu actions, toolbar buttons, and lifecycle hooks:

```ts
import { registerPlugin } from "react-grab";

registerPlugin({
  name: "send-to-jira",
  hooks: {
    // Add annotation to clipboard content
    transformCopyContent: async (content, elements) => {
      return content + "\n// Sent from react-grab";
    },
    // Custom file-open behavior
    onOpenFile: (filePath, lineNumber) => {
      // Return true if handled; false to use default behavior
      return false;
    },
  },
  actions: [
    {
      id: "jira-action",
      label: "Create Jira Ticket",
      shortcut: "J",
      onAction: async (context) => {
        await createJiraTicket({
          filePath: context.filePath,
          componentName: context.componentName,
          html: context.element.outerHTML,
        });
        context.hideContextMenu();
      },
    },
    {
      id: "toolbar-inspect",
      label: "Inspect",
      target: "toolbar",   // Places in toolbar instead of context menu
      onAction: () => {
        console.log("Inspect triggered");
      },
    },
  ],
  theme: {
    hue: 200,                          // Change overlay color (0-360 HSL)
    crosshair: { enabled: false },     // Disable crosshair overlay
  },
});
```

### Available plugin hooks

```ts
hooks: {
  onActivate?: () => void
  onDeactivate?: () => void
  onElementHover?: (element: Element) => void
  onElementSelect?: (element: Element) => boolean | void  // return true to cancel default
  onBeforeCopy?: (elements: Element[]) => void
  transformCopyContent?: (content: string, elements: Element[]) => string | Promise<string>
  onAfterCopy?: (elements: Element[], success: boolean) => void
  onOpenFile?: (filePath: string, lineNumber?: number) => boolean | void
  transformHtmlContent?: (html: string, elements: Element[]) => string | Promise<string>
  transformAgentContext?: (ctx: AgentContext, elements: Element[]) => AgentContext
  transformSnippet?: (snippet: string, element: Element) => string | Promise<string>
}
```

---

## CLI Reference

```bash
grab [command] [options]

Commands:
  init        Auto-detect project and install react-grab
  add         Connect react-grab to an AI coding agent (alias: install)
  remove      Disconnect from an AI coding agent
  configure   Configure options (activation key, context lines, etc.)

Options:
  -y, --yes       Skip confirmation prompts
  -c, --cwd       Working directory (default: process.cwd())
  -v, --version   Display version
  -h, --help      Display help
```

---

## Configuration

Pass options to `init()` for programmatic control (when not using the CDN script):

```ts
import { init } from "react-grab";

init({
  enabled: true,                     // Enable/disable entirely
  activationMode: "toggle",          // "toggle" | "hold"
  activationKey: "c",                // Key to press (with Cmd/Ctrl)
  maxContextLines: 10,               // Limit React component stack depth
  freezeReactUpdates: true,          // Pause React state while active
  getContent: async (elements) => {  // Custom clipboard content formatter
    const contexts = await generateSnippet(elements);
    return contexts.join("\n---\n");
  },
});
```

Disable entirely (before script loads):
```js
window.__REACT_GRAB_DISABLED__ = true;
```

---

## Best practices

1. **Dev-only**: react-grab is designed for development only. Always wrap in `NODE_ENV === "development"` or `import.meta.env.DEV`.
2. **Use `init` command**: `npx -y grab@latest init` handles framework detection — don't manually add script tags unless needed.
3. **MCP for agents**: For AI-driven workflows, add the MCP server with `grab add mcp` so agents can pull context without clipboard dependencies.
4. **Plugin for teams**: Create a shared plugin to standardize element context format across your team (e.g., always include JIRA project prefix).
5. **Freeze for inspection**: Use `freeze()` from the primitives API when you need to inspect dynamic elements that disappear on hover.

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| Overlay not appearing | Check `NODE_ENV === "development"` wrapping; check `window.__REACT_GRAB_DISABLED__` is not set |
| Component name shows as `null` | Ensure `react-grab` script loads **before** React renders (use `strategy="beforeInteractive"` in Next.js) |
| File path missing | Requires React source maps enabled (dev mode only; not minified builds) |
| MCP tool returns empty | You need to select an element in the browser first before calling `get_element_context` |
| `grab init` fails | Check Node.js >=18 and package manager (npm/pnpm/yarn/bun) is installed |

---

## References

- [react-grab GitHub](https://github.com/aidenybai/react-grab) — source code and issues
- [react-grab.com](https://react-grab.com) — official documentation
- [Full API Reference](references/api.md) — complete TypeScript API docs
- [Install Scripts](scripts/) — `install.sh` (project setup) · `add-agent.sh` (agent integration)

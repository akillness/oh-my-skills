# react-grab API Reference

> Full TypeScript API for react-grab v0.1.x
> Source: https://github.com/aidenybai/react-grab

---

## ReactGrabAPI

The primary API object — stored as `window.__REACT_GRAB__` and returned by `init()`.

```ts
interface ReactGrabAPI {
  // Activation control
  activate(): void;               // Show the overlay
  deactivate(): void;             // Hide the overlay
  toggle(): void;                 // Toggle visibility
  comment(): void;                // Enter prompt/comment mode
  isActive(): boolean;            // Is overlay currently shown?
  isEnabled(): boolean;           // Is react-grab enabled at all?
  setEnabled(enabled: boolean): void;

  // Toolbar state
  getToolbarState(): ToolbarState | null;
  setToolbarState(state: Partial<ToolbarState>): void;
  onToolbarStateChange(callback: (state: ToolbarState) => void): () => void;

  // Element operations
  copyElement(elements: Element | Element[]): Promise<boolean>;
  getSource(element: Element): Promise<SourceInfo | null>;
  getStackContext(element: Element): Promise<string>;
  getDisplayName(element: Element): string | null;

  // State
  getState(): ReactGrabState;
  setOptions(options: SettableOptions): void;

  // Plugin system
  registerPlugin(plugin: Plugin): void;
  unregisterPlugin(name: string): void;
  getPlugins(): string[];

  // Lifecycle
  dispose(): void;
}
```

### Access the API

```ts
import { getGlobalApi } from "react-grab";
const api = getGlobalApi();  // Returns null if not initialized
```

---

## `init()` — Configuration

```ts
import { init } from "react-grab";

init(options?: Options);
```

```ts
interface Options {
  enabled?: boolean;                   // Enable/disable entirely (default: true)
  activationMode?: ActivationMode;     // "toggle" | "hold" (default: "toggle")
  keyHoldDuration?: number;            // Duration in ms for "hold" mode
  allowActivationInsideInput?: boolean;
  maxContextLines?: number;            // Limit React component stack depth
  activationKey?: ActivationKey;       // string or (event: KeyboardEvent) => boolean
  getContent?: (elements: Element[]) => Promise<string> | string;
  freezeReactUpdates?: boolean;        // Pause React state while active (default: true)
}

type ActivationMode = "toggle" | "hold";
type ActivationKey = string | ((event: KeyboardEvent) => boolean);
```

**Examples:**

```ts
// Custom activation key
init({ activationKey: "g" }); // Cmd+G / Ctrl+G

// Hold mode (show while key is held)
init({ activationMode: "hold", keyHoldDuration: 500 });

// Custom content formatter
init({
  getContent: async (elements) => {
    const { generateSnippet } = await import("react-grab");
    const snippets = await generateSnippet(elements);
    return snippets.join("\n---\n");
  },
});

// Disable initially, enable later
init({ enabled: false });
getGlobalApi()?.setEnabled(true);
```

---

## Primitives API

Standalone utilities available without the default overlay UI.

```ts
import { getElementContext, freeze, unfreeze, isFreezeActive, openFile }
  from "react-grab/primitives";
// or: from "react-grab/core"
```

### `getElementContext(element)`

```ts
getElementContext(element: Element): Promise<ReactGrabElementContext>
```

Returns comprehensive context for any DOM element:

```ts
interface ReactGrabElementContext {
  element: Element;          // The DOM element itself
  htmlPreview: string;       // Compact HTML snippet
  stackString: string;       // React component stack as formatted string
  stack: StackFrame[];       // Parsed stack frames
  componentName: string | null;  // Nearest React component display name
  fiber: Fiber | null;       // React internal fiber
  selector: string | null;   // CSS selector for the element
  styles: string;            // Relevant computed CSS properties
}

interface StackFrame {
  functionName: string;
  fileName: string;
  lineNumber: number;
  columnNumber: number;
}
```

**Example:**

```ts
const button = document.querySelector('.submit-btn');
const context = await getElementContext(button);

console.log(context.componentName); // "SubmitButton"
console.log(context.selector);      // "button.submit-btn"
console.log(context.stackString);
// "  in SubmitButton (at Button.tsx:12:5)
//    in Form (at Form.tsx:30:3)"
console.log(context.stack[0]);
// { functionName: "SubmitButton", fileName: "Button.tsx", lineNumber: 12, columnNumber: 5 }
```

### `freeze()` / `unfreeze()`

```ts
freeze(elements?: Element[]): void   // Halt React updates, pause animations
unfreeze(): void                      // Restore normal behavior
isFreezeActive(): boolean             // Check if freeze is active
```

Freeze pauses:
- React state updates (prevents re-renders)
- CSS transitions and animations
- Preserves `:hover`/`:focus` pseudo-states

### `openFile(filePath, lineNumber?)`

```ts
openFile(filePath: string, lineNumber?: number): Promise<void>
```

Opens the file in your editor. Tries Vite/Next.js dev server endpoints first,
falls back to `vscode://` protocol URL.

### `generateSnippet(elements, options?)`

```ts
generateSnippet(
  elements: Element[],
  options?: { maxLines?: number }
): Promise<string[]>
```

Takes an array of Elements and returns an array of formatted context strings.

---

## Plugin API

### Plugin interface

```ts
interface Plugin {
  name: string;
  theme?: DeepPartial<Theme>;
  options?: SettableOptions;
  actions?: PluginAction[];    // ContextMenuAction[] | ToolbarMenuAction[]
  hooks?: PluginHooks;
  setup?: (api: ReactGrabAPI, hooks: ActionContextHooks) => PluginConfig | void;
}
```

### Register / unregister

```ts
import { registerPlugin, unregisterPlugin } from "react-grab";

registerPlugin(plugin: Plugin): void
unregisterPlugin(name: string): void
```

### PluginHooks — all lifecycle hooks

```ts
interface PluginHooks {
  onActivate?: () => void;
  onDeactivate?: () => void;
  onElementHover?: (element: Element) => void;
  onElementSelect?: (element: Element) => boolean | void | Promise<boolean>;
  // return true from onElementSelect to cancel default copy behavior

  onDragStart?: (startX: number, startY: number) => void;
  onDragEnd?: (elements: Element[], bounds: DragRect) => void;

  onBeforeCopy?: (elements: Element[]) => void | Promise<void>;
  transformCopyContent?: (content: string, elements: Element[]) => string | Promise<string>;
  onAfterCopy?: (elements: Element[], success: boolean) => void;
  onCopySuccess?: (elements: Element[], content: string) => void;
  onCopyError?: (error: Error) => void;

  onStateChange?: (state: ReactGrabState) => void;
  onPromptModeChange?: (isPromptMode: boolean, context: PromptModeContext) => void;

  // Visual hooks
  onSelectionBox?: (visible: boolean, bounds: OverlayBounds | null, element: Element | null) => void;
  onDragBox?: (visible: boolean, bounds: OverlayBounds | null) => void;
  onGrabbedBox?: (bounds: OverlayBounds, element: Element) => void;
  onElementLabel?: (visible: boolean, variant: ElementLabelVariant, context: ElementLabelContext) => void;
  onCrosshair?: (visible: boolean, context: CrosshairContext) => void;
  onContextMenu?: (element: Element, position: { x: number; y: number }) => void;

  // Transform hooks
  onOpenFile?: (filePath: string, lineNumber?: number) => boolean | void;
  transformHtmlContent?: (html: string, elements: Element[]) => string | Promise<string>;
  transformAgentContext?: (context: AgentContext, elements: Element[]) => AgentContext | Promise<AgentContext>;
  transformActionContext?: (context: ActionContext) => ActionContext;
  transformOpenFileUrl?: (url: string, filePath: string, lineNumber?: number) => string;
  transformSnippet?: (snippet: string, element: Element) => string | Promise<string>;
}
```

### Context Menu Action

```ts
interface ContextMenuAction {
  id: string;
  label: string;
  shortcut?: string;         // Keyboard shortcut label shown in UI
  target?: "context-menu";   // Omit to place in context menu (default)
  enabled?: boolean | ((context: ActionContext) => boolean);
  onAction: (context: ContextMenuActionContext) => void | Promise<void>;
  agent?: AgentOptions;
}

interface ContextMenuActionContext extends ActionContext {
  element: Element;
  elements: Element[];
  filePath?: string;
  lineNumber?: number;
  componentName?: string;
  tagName?: string;
  enterPromptMode?: (agent?: AgentOptions) => void;
  hideContextMenu: () => void;
  cleanup: () => void;
}
```

### Toolbar Action

```ts
interface ToolbarMenuAction {
  id: string;
  label: string;
  shortcut?: string;
  target: "toolbar";         // Required — places in the floating toolbar
  enabled?: boolean | (() => boolean);
  isActive?: () => boolean;
  onAction: () => void | Promise<void>;
}
```

---

## Theme API

```ts
interface Theme {
  enabled?: boolean;            // Toggle entire overlay (default: true)
  hue?: number;                 // Base color 0-360 HSL (default: 0 = red)
  selectionBox?: { enabled?: boolean };   // Hover highlight box
  dragBox?: { enabled?: boolean };        // Click-drag selection area
  grabbedBoxes?: { enabled?: boolean };   // Success flash on copy
  elementLabel?: { enabled?: boolean };   // Floating cursor label
  crosshair?: { enabled?: boolean };      // Crosshair overlay
  toolbar?: { enabled?: boolean };        // Floating activation toolbar
}

// Default values
const DEFAULT_THEME: Required<Theme> = {
  enabled: true,
  hue: 0,
  selectionBox: { enabled: true },
  dragBox: { enabled: true },
  grabbedBoxes: { enabled: true },
  elementLabel: { enabled: true },
  crosshair: { enabled: true },
  toolbar: { enabled: true },
};
```

---

## ReactGrabState

Runtime state of the overlay:

```ts
interface ReactGrabState {
  isActive: boolean;                  // Overlay is showing
  isDragging: boolean;                // User is drag-selecting
  isCopying: boolean;                 // Copy in progress
  isPromptMode: boolean;              // AI prompt mode active
  isCrosshairVisible: boolean;
  isSelectionBoxVisible: boolean;
  isDragBoxVisible: boolean;
  targetElement: Element | null;      // Currently hovered element
  dragBounds: DragRect | null;
  grabbedBoxes: Array<{
    id: string;
    bounds: OverlayBounds;
    createdAt: number;
  }>;
  labelInstances: Array<{
    id: string;
    status: SelectionLabelStatus;
    tagName: string;
    componentName?: string;
    createdAt: number;
  }>;
  selectionFilePath: string | null;
  toolbarState: ToolbarState | null;
}
```

---

## ToolbarState

```ts
interface ToolbarState {
  edge: "top" | "bottom" | "left" | "right";  // Which screen edge
  ratio: number;        // Position along edge (0-1)
  collapsed: boolean;   // Toolbar minimized
  enabled: boolean;     // Toolbar visible
}
```

---

## SourceInfo

```ts
interface SourceInfo {
  filePath: string;
  lineNumber: number | null;
  componentName: string | null;
}
```

---

## AgentProvider (custom AI backend)

Connect any AI service to react-grab's prompt mode:

```ts
interface AgentProvider<T = unknown> {
  send(context: AgentContext<T>, signal: AbortSignal): AsyncIterable<string>;
  resume?(sessionId: string, signal: AbortSignal, storage: AgentSessionStorage): AsyncIterable<string>;
  abort?(sessionId: string): Promise<void>;
  supportsResume?: boolean;
  supportsFollowUp?: boolean;
  dismissButtonText?: string;
  checkConnection?(): Promise<boolean>;
  getCompletionMessage?(): string | undefined;
  undo?(): Promise<void>;
  canUndo?(): boolean;
  redo?(): Promise<void>;
  canRedo?(): boolean;
}

interface AgentContext<T = unknown> {
  content: string[];    // Array of context strings (HTML + component stacks)
  prompt: string;       // User instruction
  options?: T;
  sessionId?: string;
}
```

**Custom provider example:**

```ts
const myProvider: AgentProvider = {
  send: async function*(context, signal) {
    const response = await fetch("/api/ai", {
      method: "POST",
      body: JSON.stringify({ context: context.content, prompt: context.prompt }),
      signal,
    });
    const reader = response.body!.getReader();
    const decoder = new TextDecoder();
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      yield decoder.decode(value);
    }
  },
  supportsFollowUp: true,
};

registerPlugin({
  name: "my-ai",
  actions: [{
    id: "ask-ai",
    label: "Ask My AI",
    onAction: (ctx) => {
      ctx.enterPromptMode?.({ provider: myProvider });
    },
  }],
});
```

---

## TypeScript Types — Full Export List

```ts
export type {
  Options,
  SettableOptions,
  ReactGrabAPI,
  SourceInfo,
  Theme,
  ReactGrabState,
  ToolbarState,
  OverlayBounds,
  GrabbedBox,
  DragRect,
  Rect,
  DeepPartial,
  ElementLabelVariant,
  PromptModeContext,
  CrosshairContext,
  ElementLabelContext,
  AgentContext,
  AgentSession,
  AgentProvider,
  AgentSessionStorage,
  AgentOptions,
  AgentCompleteResult,
  ActivationMode,
  ContextMenuAction,
  ContextMenuActionContext,
  ToolbarMenuAction,
  PluginAction,
  ActionContext,
  ActionContextHooks,
  Plugin,
  PluginConfig,
  PluginHooks,
}
```

---

## Package Structure

| Import path | Contents |
|-------------|----------|
| `react-grab` | Main entry — `init`, `getGlobalApi`, `registerPlugin`, `unregisterPlugin`, `generateSnippet`, built-in plugins |
| `react-grab/core` | Core primitives + API — same as `react-grab/primitives` |
| `react-grab/primitives` | Standalone: `getElementContext`, `freeze`, `unfreeze`, `isFreezeActive`, `openFile` |
| `react-grab/styles.css` | Stylesheet (if needed) |

---

## Built-in Plugins

```ts
import { commentPlugin, openPlugin } from "react-grab";

// commentPlugin — adds "Comment" action to context menu
// openPlugin — adds "Open in editor" action to context menu
registerPlugin(commentPlugin);
registerPlugin(openPlugin);
```

---

## MCP Server (`@react-grab/mcp`)

The MCP server exposes one tool:

**`get_element_context`**
- Returns the most recently selected element's context from the browser overlay
- Context is consumed once then cleared (one-shot)
- Returns: `{ componentName, filePath, lineNumber, htmlPreview, stackString, selector }`

Setup: `npx -y grab@latest add mcp`

Transport: Supports both **stdio** (for editor MCP clients) and **HTTP** (Streamable HTTP, default port configurable).

---

*Source: https://github.com/aidenybai/react-grab · License: MIT*

---
name: obsidian-plugin
description: >
  Build, validate, and publish Obsidian plugins following official community submission standards.
  Use when developing an Obsidian plugin from scratch, reviewing existing plugin code, fixing ESLint
  violations from eslint-plugin-obsidianmd, preparing a plugin for community directory submission,
  or applying Obsidian-specific best practices (memory management, type safety, accessibility, CSS
  variables, vault API). Triggers on: obsidian plugin, obsidian development, obsidian-plugin, create
  obsidian plugin, obsidian eslint, obsidian submission, obsidian community plugin, obsidian API,
  plugin boilerplate, obsidian typescript, obsidian vault, obsidian settings, obsidian commands.
allowed-tools: Bash Read Write Edit Glob Grep WebFetch
license: MIT
metadata:
  tags: obsidian, plugin-development, eslint, typescript, boilerplate, submission, accessibility
  version: "1.0"
  source: https://github.com/gapmiss/obsidian-plugin-skill
---

# obsidian-plugin — Obsidian Plugin Development Skill

> **Keyword**: `obsidian plugin` · `create obsidian plugin` · `obsidian eslint` · `obsidian submission`
>
> Build high-quality Obsidian plugins that pass community review on first attempt.
> Covers all 27 rules from `eslint-plugin-obsidianmd` v0.1.9, boilerplate generation,
> vault API patterns, accessibility requirements, and submission validation.

## When to use this skill

- Generate a new Obsidian plugin project with clean boilerplate (no sample code bloat)
- Review and fix ESLint violations from `eslint-plugin-obsidianmd`
- Prepare a plugin for Obsidian community directory submission
- Apply memory-safe lifecycle patterns (`registerEvent`, no view reference storage)
- Implement proper type safety (no unsafe `as TFile` casts, no `any`)
- Enforce accessibility requirements (keyboard navigation, ARIA labels, focus management)
- Apply Obsidian CSS variables for theme-compatible styling
- Validate plugin metadata (manifest.json, plugin ID/name/description rules)

---

## Instructions

### Step 1: Generate a new plugin project

```bash
# Interactive boilerplate generator — validates metadata against submission rules
node scripts/create-plugin.js

# Or use npx directly from the source repo
npx github:gapmiss/obsidian-plugin-skill create-plugin
```

The generator produces:
- `src/main.ts` — Plugin class with settings integration
- `src/settings.ts` — Settings interface and PluginSettingTab
- `manifest.json` — Validated plugin metadata
- `styles.css` — CSS scaffold with Obsidian variables comment
- `tsconfig.json`, `package.json`, `esbuild.config.mjs` — Build toolchain
- `version-bump.mjs`, `versions.json` — Version management
- `LICENSE` — MIT with auto-populated year/author

### Step 2: Install ESLint validation

```bash
npm install --save-dev eslint eslint-plugin-obsidianmd
```

```json
// eslint.config.mjs
import pluginObsidianmd from "eslint-plugin-obsidianmd";
export default [
  pluginObsidianmd.configs.recommended,
  // For locale string checking:
  // pluginObsidianmd.configs.recommendedWithLocalesEn,
];
```

Run validation:
```bash
npx eslint src/
npx eslint src/ --fix   # auto-fix where possible
```

### Step 3: Follow the submission validation workflow

1. Run `bash scripts/install.sh` to set up the development environment
2. Validate plugin ID and name against naming rules (see below)
3. Run ESLint — all 27 rules must pass
4. Complete the Code Review Checklist (see References)
5. Submit PR to [obsidianmd/obsidian-releases](https://github.com/obsidianmd/obsidian-releases)

---

## Plugin Naming Rules

| Field | Rule |
|-------|------|
| Plugin ID | Lowercase, alphanumeric + dashes/underscores; no "obsidian"; no "plugin" suffix |
| Plugin Name | No "Obsidian" word; no "Plugin" suffix; no "Obsi" prefix or "dian" suffix |
| Description | No "Obsidian" word; no "This plugin"; must end with `.`, `?`, `!`, or `)` |

```bash
# Validate your manifest.json
node scripts/create-plugin.js --validate-only
```

---

## ESLint Rules Summary (27 rules)

### Submission & Naming
| Rule | Auto-fix | Description |
|------|----------|-------------|
| `no-obsidian-in-id` | No | Plugin ID must not contain "obsidian" |
| `no-plugin-suffix-in-id` | No | Plugin ID must not end with "-plugin" |
| `no-obsidian-in-name` | No | Plugin name must not contain "Obsidian" |
| `no-plugin-suffix-in-name` | No | Plugin name must not end with "Plugin" |
| `valid-description` | No | Description format validation |

### Memory & Lifecycle
| Rule | Auto-fix | Description |
|------|----------|-------------|
| `prefer-register-event` | No | Use `this.registerEvent()` for automatic cleanup |
| `no-view-reference` | No | Never store direct view references (causes memory leaks) |

### Type Safety
| Rule | Auto-fix | Description |
|------|----------|-------------|
| `no-tfile-cast` | No | Avoid `as TFile` / `as TFolder` (use `instanceof`) |

### UI/UX (sentence-case rules — mostly auto-fixable)
| Rule | Auto-fix | Description |
|------|----------|-------------|
| `sentence-case` | Yes | All UI text in sentence case |
| `no-plugin-name-in-command` | No | Commands must not repeat plugin name |
| `no-command-in-command` | No | Commands must not include the word "command" |
| `no-default-hotkey` | No | Do not define default hotkeys |
| `no-manual-headings` | No | Settings UI: use `setHeading()`, not manual HTML |

### API Best Practices
| Rule | Auto-fix | Description |
|------|----------|-------------|
| `no-global-app` | No | Use `this.app`, not global `app` |
| `prefer-request-url` | No | Use `requestUrl()`, not `fetch()` |
| `no-console-log` | No | Remove `console.log` before submission |
| `prefer-abstract-input-suggest` | No | Use `AbstractInputSuggest` for suggestions |

### Styling
| Rule | Auto-fix | Description |
|------|----------|-------------|
| `no-inline-styles` | No | Use CSS classes; no inline `style` attributes |
| `prefer-css-variables` | No | Use Obsidian CSS variables, not hardcoded colors |
| `scope-plugin-styles` | No | Scope all CSS to plugin ID selector |

### Accessibility (MANDATORY)
| Rule | Auto-fix | Description |
|------|----------|-------------|
| `require-aria-label` | No | Icon buttons must have `aria-label` |
| `require-keyboard-nav` | No | All interactions must be keyboard accessible |
| `require-focus-visible` | No | Use `:focus-visible` CSS for focus indicators |

---

## Key Code Patterns

### Memory-safe event registration
```typescript
// ✅ Correct — auto-cleaned on plugin unload
this.registerEvent(
  this.app.vault.on('create', (file) => this.handleCreate(file))
);

// ❌ Wrong — leaks memory
this.app.vault.on('create', (file) => this.handleCreate(file));
```

### Type-safe file access
```typescript
// ✅ Correct — instanceof narrowing
const file = this.app.workspace.getActiveFile();
if (file instanceof TFile) {
  await this.app.vault.read(file);
}

// ❌ Wrong — unsafe cast
const file = this.app.workspace.getActiveFile() as TFile;
```

### Accessibility — ARIA on icon buttons
```typescript
// ✅ Correct
const btn = containerEl.createEl('button', { cls: 'clickable-icon' });
btn.setAttribute('aria-label', 'Delete note');
setIcon(btn, 'trash');

// ❌ Wrong — no aria-label
const btn = containerEl.createEl('button', { cls: 'clickable-icon' });
setIcon(btn, 'trash');
```

### CSS with Obsidian variables
```css
/* ✅ Correct — theme-compatible */
.my-plugin-button {
  background-color: var(--interactive-accent);
  color: var(--text-on-accent);
  border-radius: var(--radius-m);
}

/* ❌ Wrong — hardcoded colors */
.my-plugin-button {
  background-color: #7c3aed;
  color: white;
}
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Generate boilerplate | `node scripts/create-plugin.js` |
| Install ESLint | `npm install --save-dev eslint eslint-plugin-obsidianmd` |
| Run ESLint | `npx eslint src/` |
| Auto-fix ESLint | `npx eslint src/ --fix` |
| Build plugin | `npm run build` |
| Dev watch mode | `npm run dev` |
| Bump version | `npm run version` |

---

## References

- [Accessibility Guide](references/accessibility.md) — Keyboard nav, ARIA, focus management (MANDATORY)
- [Code Quality Guide](references/code-quality.md) — Security, platform compat, API usage
- [CSS Styling Guide](references/css-styling.md) — Obsidian variables, scoped styles, dark/light mode
- [File Operations Guide](references/file-operations.md) — Vault API, editor vs vault, atomic ops
- [Memory Management Guide](references/memory-management.md) — registerEvent, lifecycle patterns
- [Submission Guide](references/submission.md) — Repository structure, naming, submission process
- [Type Safety Guide](references/type-safety.md) — instanceof narrowing, no `any`, const/let
- [UI/UX Guide](references/ui-ux.md) — Sentence case, commands, settings structure
- [eslint-plugin-obsidianmd](https://github.com/obsidianmd/eslint-plugin-obsidianmd) — Official ESLint rules
- [Obsidian Plugin Developer Docs](https://docs.obsidian.md/Plugins/Getting+started/Build+a+plugin)
- [Source Skill Repository](https://github.com/gapmiss/obsidian-plugin-skill) — MIT License

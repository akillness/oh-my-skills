# CSS Styling

## Use Obsidian CSS Variables

Never use hardcoded colors, sizes, or fonts. Always use Obsidian's CSS variables
for theme compatibility (dark/light mode, user theme overrides).

```css
/* ✅ Correct */
.my-plugin-container {
  background-color: var(--background-secondary);
  color: var(--text-normal);
  border: 1px solid var(--background-modifier-border);
  border-radius: var(--radius-m);
  padding: var(--size-4-2);
  font-size: var(--font-ui-medium);
}

/* ❌ Wrong — hardcoded values */
.my-plugin-container {
  background-color: #2d2d2d;
  color: #ffffff;
  border: 1px solid #444;
  border-radius: 4px;
}
```

### Common Obsidian CSS Variables

| Variable | Purpose |
|----------|---------|
| `--background-primary` | Main background |
| `--background-secondary` | Secondary background (sidebars) |
| `--text-normal` | Primary text color |
| `--text-muted` | Muted/secondary text |
| `--interactive-accent` | Accent color (buttons, links) |
| `--text-on-accent` | Text on accent-colored backgrounds |
| `--background-modifier-border` | Border color |
| `--radius-s`, `--radius-m`, `--radius-l` | Border radius sizes |
| `--font-ui-small`, `--font-ui-medium` | UI font sizes |
| `--size-4-1` through `--size-4-8` | Spacing (4px grid) |

## Scope Plugin Styles

All CSS selectors must be scoped to your plugin's container class.

```css
/* ✅ Correct — scoped to plugin */
.my-plugin-view .toolbar { display: flex; }
.my-plugin-view .item { padding: var(--size-4-2); }

/* ❌ Wrong — affects all of Obsidian */
.toolbar { display: flex; }
.item { padding: 8px; }
```

## No Inline Styles

```typescript
// ✅ Correct — CSS class
const el = containerEl.createEl('div', { cls: 'my-plugin-header' });

// ❌ Wrong — inline style
const el = containerEl.createEl('div');
el.style.backgroundColor = 'var(--background-secondary)';
```

## Theme Support (Light/Dark)

CSS variables handle light/dark mode automatically. Do not use `prefers-color-scheme`
media queries — Obsidian manages the theme class on `document.body`.

```css
/* ✅ Correct — works in all themes automatically */
.my-plugin-alert {
  color: var(--text-error);
  background-color: var(--background-modifier-error);
}
```

## Spacing (4px Grid)

Use Obsidian's 4px grid spacing variables:
- `--size-4-1` = 4px
- `--size-4-2` = 8px
- `--size-4-3` = 12px
- `--size-4-4` = 16px
- `--size-4-6` = 24px
- `--size-4-8` = 32px

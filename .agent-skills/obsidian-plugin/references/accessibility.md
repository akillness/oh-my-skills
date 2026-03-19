# Accessibility (MANDATORY)

All interactive elements must be accessible. These rules are **mandatory** for
community plugin submission.

## Keyboard Navigation (MANDATORY)

Every interactive element must be reachable and operable via keyboard alone.

```typescript
// ✅ Correct — keyboard event handler
const item = containerEl.createEl('div', { cls: 'my-item' });
item.setAttribute('tabindex', '0');
item.addEventListener('click', handler);
item.addEventListener('keydown', (e) => {
  if (e.key === 'Enter' || e.key === ' ') {
    e.preventDefault();
    handler();
  }
});

// ❌ Wrong — click-only, not keyboard accessible
const item = containerEl.createEl('div', { cls: 'my-item' });
item.addEventListener('click', handler);
```

## ARIA Labels (MANDATORY)

All icon-only buttons must have `aria-label`.

```typescript
// ✅ Correct
const btn = containerEl.createEl('button', { cls: 'clickable-icon' });
btn.setAttribute('aria-label', 'Delete note');
setIcon(btn, 'trash');

// ❌ Wrong — screen readers can't describe this button
const btn = containerEl.createEl('button', { cls: 'clickable-icon' });
setIcon(btn, 'trash');
```

## Focus Management (MANDATORY)

When opening modals or dialogs, move focus to the first interactive element.
When closing, return focus to the trigger element.

```typescript
// ✅ Correct
class MyModal extends Modal {
  onOpen() {
    const input = this.contentEl.createEl('input');
    input.focus(); // move focus on open
  }
}
```

## Focus Visible Styles (MANDATORY)

Use `:focus-visible` to show focus indicators for keyboard users without
showing them for mouse users.

```css
/* ✅ Correct */
.my-plugin-button:focus-visible {
  outline: 2px solid var(--interactive-accent);
  outline-offset: 2px;
}

/* ❌ Wrong — removes focus for keyboard users */
.my-plugin-button:focus {
  outline: none;
}
```

## Screen Reader Support (MANDATORY)

Use semantic HTML and ARIA roles where native semantics are unavailable.

```typescript
// ✅ Correct — semantic button
containerEl.createEl('button', { text: 'Save', cls: 'mod-cta' });

// ✅ Correct — custom role when div must be used
const el = containerEl.createEl('div', { cls: 'my-button' });
el.setAttribute('role', 'button');
el.setAttribute('aria-label', 'Save changes');
el.setAttribute('tabindex', '0');
```

## Mobile and Touch Accessibility (MANDATORY)

All touch targets must be at least **44×44px**.

```css
/* ✅ Correct */
.my-plugin-button {
  min-width: 44px;
  min-height: 44px;
}
```

## Accessibility Checklist

- [ ] All icon buttons have `aria-label`
- [ ] All interactive elements are keyboard accessible
- [ ] Focus is managed on modal open/close
- [ ] `:focus-visible` styles are implemented
- [ ] Touch targets are ≥ 44×44px
- [ ] Semantic HTML is used throughout
- [ ] No color-only information (colorblind users)

# UI/UX Standards

## Sentence Case for All UI Text

All UI strings must use sentence case (capitalize only the first word and proper nouns).
The `sentence-case` ESLint rule is auto-fixable.

```typescript
// ✅ Correct
this.addCommand({
  name: 'Open note in new tab',
  // ...
});
new Setting(containerEl).setName('Enable auto-save').setDesc('Saves notes automatically.');

// ❌ Wrong
this.addCommand({ name: 'Open Note In New Tab' });
new Setting(containerEl).setName('Enable Auto-Save');
```

## Command Naming Conventions

```typescript
// ✅ Correct
this.addCommand({
  id: 'open-note',
  name: 'Open note in new tab',
  // ...
});

// ❌ Wrong — includes plugin name (redundant, Obsidian adds it)
this.addCommand({ id: 'open-note', name: 'My Plugin: Open note' });

// ❌ Wrong — includes "command"
this.addCommand({ id: 'run', name: 'Run command' });

// ❌ Wrong — has default hotkey (conflicts with user assignments)
this.addCommand({
  id: 'open-note',
  hotkeys: [{ modifiers: ['Mod'], key: 'O' }],
});
```

## Settings & Configuration

```typescript
// ✅ Correct — use setHeading() for section headers
containerEl.empty();
containerEl.createEl('h2', { text: 'My plugin settings' }); // top-level only
new Setting(containerEl).setHeading().setName('General');
new Setting(containerEl).setName('Auto-save').setDesc('Save notes automatically.');

// ❌ Wrong — manual HTML headings inside settings
new Setting(containerEl)
  .setName('')
  .then(s => s.nameEl.createEl('h3', { text: 'General' }));
```

## No Redundant Naming in Settings

```typescript
// ✅ Correct
new Setting(containerEl).setName('Enable').setDesc('Turn the feature on or off.');

// ❌ Wrong — name repeats the setting group context
new Setting(containerEl).setName('Enable feature').setDesc('Enable the feature.');
```

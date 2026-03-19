# File Operations & Vault API

## View Access

```typescript
// ✅ Correct — safe view access
const view = this.app.workspace.getActiveViewOfType(MarkdownView);
if (view) {
  const editor = view.editor;
  // use editor
}
```

## Editor vs Vault API

Use the **Editor API** for operations on the currently open document (respects
undo history, cursor position, selections). Use the **Vault API** for
background file operations.

```typescript
// Editor API — for user-initiated edits
const view = this.app.workspace.getActiveViewOfType(MarkdownView);
if (view) {
  view.editor.replaceSelection('new text');
}

// Vault API — for background operations
const content = await this.app.vault.read(file);
await this.app.vault.modify(file, newContent);
```

## Atomic File Operations

For concurrent-safe modifications, use `Vault.process()` or `processFrontMatter()`:

```typescript
// ✅ Atomic modify — safe for concurrent access
await this.app.vault.process(file, (content) => {
  return content.replace(/old/g, 'new');
});

// ✅ Atomic frontmatter update
await this.app.fileManager.processFrontMatter(file, (fm) => {
  fm.tags = [...(fm.tags ?? []), 'new-tag'];
});
```

## File Management Best Practices

```typescript
// ✅ Use Vault (not Adapter) for file operations
await this.app.vault.create('path/to/file.md', 'content');
const content = await this.app.vault.read(file);

// ❌ Don't use Adapter directly (bypasses Obsidian's file tracking)
await this.app.vault.adapter.write('path/to/file.md', 'content');
```

## Path Handling

```typescript
import { normalizePath } from 'obsidian';

// ✅ Always normalize paths
const path = normalizePath('folder/subfolder/note.md');
const file = this.app.vault.getAbstractFileByPath(path);

// ❌ Don't hardcode paths with config dir
const configPath = '.obsidian/my-plugin/data.json'; // use this.app.vault.configDir
```

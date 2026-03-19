# Type Safety

## Avoid type casting to TFile/TFolder

Use `instanceof` narrowing instead of `as TFile` or `as TFolder` assertions.
The vault's `getAbstractFileByPath()` returns `TAbstractFile | null`.

```typescript
// ✅ Correct
const abstract = this.app.vault.getAbstractFileByPath(path);
if (abstract instanceof TFile) {
  await this.app.vault.read(abstract); // TypeScript knows it's TFile
}

// ❌ Wrong — crashes if path is a folder or doesn't exist
const file = this.app.vault.getAbstractFileByPath(path) as TFile;
await this.app.vault.read(file);
```

## Avoid TypeScript `any`

Using `any` disables type checking entirely. Use `unknown` and narrow it explicitly.

```typescript
// ✅ Correct
function process(value: unknown) {
  if (typeof value === 'string') {
    return value.toUpperCase();
  }
}

// ❌ Wrong
function process(value: any) {
  return value.toUpperCase(); // runtime error if value is not a string
}
```

## Prefer const and let over var

```typescript
// ✅ Correct
const config = loadConfig();
let count = 0;

// ❌ Wrong
var config = loadConfig();
var count = 0;
```

## Narrowing union types before use

```typescript
// ✅ Correct
const file = this.app.workspace.getActiveFile();
if (!file) return;
// file is TFile here

// ❌ Wrong — non-null assertion bypasses safety
const file = this.app.workspace.getActiveFile()!;
```

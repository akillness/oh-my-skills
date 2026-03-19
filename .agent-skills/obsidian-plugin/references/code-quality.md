# Code Quality & Best Practices

## Security: Avoid innerHTML/outerHTML

Using `innerHTML` or `outerHTML` with user-provided content is an XSS vulnerability.
Use Obsidian's DOM helpers or `textContent` instead.

```typescript
// ✅ Correct — safe DOM methods
const el = containerEl.createEl('div');
el.textContent = userInput; // safe

// ✅ Correct — Obsidian's createEl
containerEl.createEl('p', { text: userInput }); // safe

// ❌ Wrong — XSS vulnerability
containerEl.innerHTML = `<p>${userInput}</p>`;
```

## Platform Compatibility (iOS)

Obsidian runs on iOS (mobile). Avoid APIs unavailable on iOS:

```typescript
// ❌ Wrong — lookbehind regex not supported on older iOS
const match = text.match(/(?<=prefix)\w+/);

// ✅ Correct — use alternative approach
const match = text.match(/prefix(\w+)/);
const result = match?.[1];
```

Use `Platform.isMobile` / `Platform.isIos` for conditional behavior:
```typescript
import { Platform } from 'obsidian';
if (!Platform.isMobile) {
  // desktop-only feature
}
```

## Use requestUrl Instead of fetch

Obsidian provides `requestUrl()` which handles CORS and works on all platforms:

```typescript
// ✅ Correct
import { requestUrl } from 'obsidian';
const response = await requestUrl({ url: 'https://api.example.com/data' });
const data = response.json;

// ❌ Wrong — may fail on mobile or with CORS
const response = await fetch('https://api.example.com/data');
```

## No console.log in Production

Remove all `console.log` statements before submission. Use `console.debug` for
development logs and strip them in the build process.

```typescript
// ✅ Correct — debug logging with conditional
if (process.env.NODE_ENV === 'development') {
  console.debug('Plugin state:', this.settings);
}

// ❌ Wrong — leaves noise in production
console.log('Plugin loaded', this.settings);
```

## Use this.app, Not Global app

```typescript
// ✅ Correct
class MyPlugin extends Plugin {
  doSomething() {
    const files = this.app.vault.getFiles();
  }
}

// ❌ Wrong — relies on global variable
const files = app.vault.getFiles();
```

## AbstractInputSuggest for Suggestions

```typescript
// ✅ Correct — use Obsidian's built-in suggest component
class FileSuggest extends AbstractInputSuggest<TFile> {
  getSuggestions(query: string): TFile[] {
    return this.app.vault.getFiles().filter(f => f.name.includes(query));
  }
  renderSuggestion(file: TFile, el: HTMLElement): void {
    el.setText(file.name);
  }
  selectSuggestion(file: TFile): void {
    this.inputEl.value = file.path;
    this.close();
  }
}
```

## Remove Sample Code

Delete all sample code from the boilerplate before submission:
- Sample ribbon icon
- Sample status bar item
- Sample modal
- Sample command with editor callback
- Sample setting

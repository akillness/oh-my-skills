# Plugin Submission Guide

## Repository Structure

Required files for submission:

```
my-plugin/
├── main.js          # Compiled output (committed to repo)
├── manifest.json    # Plugin metadata
├── styles.css       # Optional: CSS styles
└── README.md        # Documentation
```

## Naming and Description Rules

### Plugin ID
- Must be lowercase alphanumeric with dashes/underscores
- Must NOT contain "obsidian"
- Must NOT end with "-plugin" or "_plugin"
- Must be unique in the community plugins list

```json
// ✅ Correct
{ "id": "my-note-enhancer" }

// ❌ Wrong
{ "id": "obsidian-my-plugin" }
{ "id": "my-obsidian-plugin" }
```

### Plugin Name
- Must NOT contain the word "Obsidian"
- Must NOT end with "Plugin"
- Must NOT start with "Obsi" or end with "dian"

```json
// ✅ Correct
{ "name": "Note Enhancer" }

// ❌ Wrong
{ "name": "Obsidian Note Enhancer" }
{ "name": "Note Enhancer Plugin" }
```

### Description
- Must NOT mention "Obsidian" (it's implied by context)
- Must NOT start with "This plugin"
- Must end with `.`, `?`, `!`, or `)`
- Character limits enforced by submission bot

```json
// ✅ Correct
{ "description": "Enhances note-taking with advanced linking and tagging." }

// ❌ Wrong
{ "description": "This Obsidian plugin enhances note-taking" }
```

### Author and Repository
- `author` must match GitHub profile name
- `authorUrl` must be a valid GitHub profile URL
- `fundingUrl` is optional

## Submission Process

1. **Test locally**: Install via BRAT or manual install in a test vault
2. **Build production**: `npm run build` → verify `main.js` is up to date
3. **Submit PR**: Add your plugin to `community-plugins.json` in [obsidianmd/obsidian-releases](https://github.com/obsidianmd/obsidian-releases)
4. **Pass bot review**: Automated checks validate manifest format and naming rules
5. **Pass human review**: Community review for code quality and security

## Semantic Versioning

```bash
# Bump version (updates manifest.json, package.json, versions.json)
npm run version

# Push tags for release
git tag -a 1.0.0 -m "1.0.0"
git push origin 1.0.0
```

## Testing Before Submission

- Test in both light and dark theme
- Test on mobile (iOS) — no `lookbehind` regex, no non-standard APIs
- Run `npx eslint src/ --max-warnings=0`
- Verify all keyboard interactions work without mouse
- Check 44×44px minimum touch targets on mobile

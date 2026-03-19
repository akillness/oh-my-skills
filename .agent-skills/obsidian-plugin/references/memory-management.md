# Memory Management & Lifecycle

## registerEvent() for automatic cleanup

Always use `this.registerEvent()` to wrap Obsidian event subscriptions. This ensures
listeners are automatically removed when the plugin unloads.

```typescript
// ✅ Correct
this.registerEvent(
  this.app.vault.on('create', (file) => { /* ... */ })
);
this.registerEvent(
  this.app.workspace.on('active-leaf-change', (leaf) => { /* ... */ })
);

// ❌ Wrong — listener is never removed
this.app.vault.on('create', (file) => { /* ... */ });
```

## addCommand() registers automatically

Commands registered via `this.addCommand()` are automatically removed on unload.
No manual cleanup needed.

## Don't store view references

Storing direct references to views/leaves causes memory leaks. Views are destroyed
and recreated by Obsidian; stale references prevent garbage collection.

```typescript
// ✅ Correct — resolve the view when needed
getActiveView(): MyView | null {
  return this.app.workspace.getActiveViewOfType(MyView);
}

// ❌ Wrong — stored reference becomes stale
private myView: MyView; // leaks memory
```

## Don't use Plugin as a Component

Don't pass `this` (the plugin) as a `Component` parameter. Pass `this.app` or
create a dedicated component instead.

## Don't detach leaves in onunload()

Obsidian handles leaf cleanup automatically. Detaching leaves in `onunload()` can
cause errors and is unnecessary.

```typescript
// ✅ Correct — let Obsidian clean up leaves
async onunload() {
  // Only clean up non-leaf resources
}

// ❌ Wrong
async onunload() {
  this.app.workspace.detachLeavesOfType(VIEW_TYPE);
}
```

## Use getActiveLeavesOfType() for multiple leaves

```typescript
const leaves = this.app.workspace.getLeavesOfType(VIEW_TYPE);
for (const leaf of leaves) {
  // safe iteration
}
```

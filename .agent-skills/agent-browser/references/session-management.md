# Session management patterns

## Isolate concurrent tasks

Use named sessions to prevent cookie/storage collisions.

```bash
agent-browser --session research open https://example.com
agent-browser --session checkout open https://shop.example.com
```

## Verify active sessions

```bash
agent-browser session list
```

## Cleanup discipline

Always close sessions at end of task:

```bash
agent-browser --session research close
agent-browser --session checkout close
```

## State persistence

Use explicit save/load when a flow requires auth reuse:

```bash
agent-browser state save auth.json
agent-browser state load auth.json
```

## Operational guardrails

- Assign one session per autonomous worker.
- Do not share a session between unrelated workflows.
- Close sessions even on failure paths.

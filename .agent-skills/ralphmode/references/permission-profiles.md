# Ralphmode Permission Profiles

This file contains the concrete presets referenced by `ralphmode/SKILL.md`.
Read only the section for the platform you are configuring.

## Shared safety baseline

Apply these rules regardless of platform:

- Scope automation to one repo or disposable sandbox.
- Block secrets by default: `.env*`, `secrets/**`, credential exports, production config.
- Block destructive shell by default: `rm -rf`, `sudo`, blind remote scripts.
- Keep verification outside the permission shortcut itself.

## Claude Code

Official Claude Code docs currently expose these permission modes: `default`, `acceptEdits`, `plan`, `dontAsk`, and `bypassPermissions`.
Use them like this:

### Repo preset

Use this for normal development work:

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Bash(npm *)",
      "Bash(pnpm *)",
      "Bash(git status)",
      "Bash(git diff)",
      "Read(*)",
      "Edit(./src/**)",
      "Write(./src/**)"
    ],
    "deny": [
      "Read(.env*)",
      "Read(./secrets/**)",
      "Bash(rm -rf *)",
      "Bash(sudo *)"
    ]
  }
}
```

Recommended location:

- Project: `<repo>/.claude/settings.json`
- Personal sandbox only: `~/.claude/settings.json`

### Sandbox YOLO preset

Use only for disposable environments:

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  }
}
```

CLI equivalent:

```bash
claude --dangerously-skip-permissions
```

Keep a repo boundary and denylist even when using this mode.

## Codex CLI

As of 2026-03-06, the primary official Codex docs focus on:

- config files and project overrides
- `approval_policy`
- `sandbox_mode`
- repo instructions such as `AGENTS.md` and `*.rules`

That is the current-first model and should be your default.

### Current repo preset

Use a repo-scoped configuration that removes approval popups without leaving the workspace boundary:

```toml
approval_policy = "never"
sandbox_mode = "workspace-write"
```

Then keep your repo policy in `AGENTS.md` or project rules:

- allow normal build, test, and repo-local write workflows
- deny destructive shell and secret access in instructions or org policy
- keep anything broader than workspace scope out of the shared default

### Current sandbox preset

Only for disposable sandboxes:

```toml
approval_policy = "never"
sandbox_mode = "danger-full-access"
```

This is the closest current equivalent to "permission skip" in Codex.

### Compatibility note for older Codex builds

Some community guides use a legacy-looking `permissions.allow` and `permissions.deny` schema.
If your installed Codex build still supports that shape, keep it project-local and pair it with a denylist:

```json
{
  "permissions": {
    "allow": [
      "Read(src/**)",
      "Edit(src/**)",
      "Write(*.md)",
      "Bash(npm run:*)",
      "Bash(git:*)"
    ],
    "deny": [
      "Read(.env*)",
      "Write(package.json)",
      "Bash(rm:*)",
      "Bash(sudo:*)"
    ]
  }
}
```

Treat this as a compatibility shim, not the canonical current model.

## Gemini CLI

Gemini CLI is designed around explicit consent and Trusted Folders, not a true global bypass mode.
The safe pattern is:

1. Trust the current project root.
2. Avoid trusting broad parent folders.
3. Keep file exposure explicit when the repo contains mixed-sensitivity areas.

### Recommended workflow

- Start Gemini in the repo you want to automate.
- Choose `Trust this folder`, not a broad parent directory.
- Use `/permissions` later if the trust level needs to be changed.

The trust state is persisted in `~/.gemini/trustedFolders.json` (as of Gemini CLI 0.x; verify against the linked official docs if your version differs). Review or reset it there if the repo layout changes or sensitive files are added later.

## Platform selection summary

Use this table to decide quickly:

| Platform | Normal repo automation | Full skip equivalent | Notes |
| --- | --- | --- | --- |
| Claude Code | `acceptEdits` or `dontAsk` with allow and deny rules | `bypassPermissions` or `--dangerously-skip-permissions` | Use full bypass only in disposable sandboxes |
| Codex CLI | `approval_policy = "never"` + `sandbox_mode = "workspace-write"` | `approval_policy = "never"` + `sandbox_mode = "danger-full-access"` | Current official model is approvals plus sandbox, not tool-pattern ACLs |
| Gemini CLI | Trusted project folder | None | Trusted Folders reduce prompts but do not create YOLO mode |

## Source notes

- Agent Skills format references are from `agentskills.io`.
- Claude permission mode names are from Anthropic's Claude Code docs.
- Codex guidance reflects OpenAI's official Codex config and ChatGPT Codex sandbox and approval docs current on 2026-03-06.
- Gemini guidance reflects the official `gemini-cli` Trusted Folders documentation.

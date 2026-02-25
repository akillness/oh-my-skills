# bmad-orchestrator — Configuration Reference

→ [Overview](./README.md) · [Installation](./installation.md) · [Workflow Guide](./workflow.md) · [Examples](./examples.md)

---

## Config File Hierarchy

BMAD uses two config files with a priority-based merge:

```
1. Project config: {project-root}/bmad/config.yaml       ← highest priority
2. Global config:  ~/.claude/config/bmad/config.yaml      ← user defaults
3. Built-in defaults                                       ← fallback
```

Project settings always override global settings.

---

## Project Config (`bmad/config.yaml`)

Created automatically by `/workflow-init`. Edit to customize project-level settings.

```yaml
# Project identification
project_name: "MyApp"
project_type: "web-app"        # web-app | mobile-app | api | game | library | other
project_level: 2               # 0-4 (see Project Levels)

# Output settings
output_folder: "docs"          # relative to project root
stories_folder: "docs/stories"

# Language settings
communication_language: "Korean"           # Language for AI interaction
document_output_language: "English"        # Language for generated documents

# BMAD version
bmad_version: "6.0.0"

# Optional: Custom template overrides
agent_overrides_folder: "bmad/agent-overrides"
```

### Project Type Values

| Value | Description |
|-------|-------------|
| `web-app` | Web application (React, Next.js, Vue, etc.) |
| `mobile-app` | Mobile app (React Native, Flutter, etc.) |
| `api` | Backend API service |
| `game` | Game project |
| `library` | npm/pip/cargo package |
| `other` | Any other type |

### Project Level Values

| Level | Size | Stories |
|-------|------|---------|
| `0` | Single atomic change | 1 |
| `1` | Small feature | 1–10 |
| `2` | Medium feature set | 5–15 |
| `3` | Complex integration | 12–40 |
| `4` | Enterprise expansion | 40+ |

---

## Global Config (`~/.claude/config/bmad/config.yaml`)

User-level defaults. Applied when no project config exists.

```yaml
version: "6.0.0"
ide: "claude-code"

# User defaults
user_name: "YourName"
user_skill_level: "intermediate"  # beginner | intermediate | expert

# Communication defaults
communication_language: "Korean"
document_output_language: "English"

# Default paths
default_output_folder: "docs"

# Enabled modules
modules_enabled:
  - core
  - bmm
  # - bmb (optional)
  # - cis (optional)

# Advanced settings
auto_update_status: true
verbose_mode: false
```

---

## Workflow Status File (`docs/bmm-workflow-status.yaml`)
Tracks progress across all phases. Updated automatically as you complete workflows.

### Schema

```yaml
project_name: "MyApp"
project_type: "web-app"
project_level: 2
communication_language: "Korean"
output_language: "English"
last_updated: "2026-02-20T10:00:00Z"
  - name: "product-brief"
    phase: 1
    status: "docs/product-brief-myapp-2026-02-20.md"  # ← completed
    description: "Product vision and high-level requirements"
    plannotator_review: "approved"      # optional: pending | approved | skipped
    reviewed_at: "2026-02-20T11:00:00Z" # optional: ISO timestamp of approval
  - name: "prd"
    phase: 2
    status: "required"  # ← not started yet
    description: "Product Requirements Document"
    plannotator_review: null
    reviewed_at: null
  - name: "architecture"
    phase: 3
    status: "required"
    description: "System architecture design"
    plannotator_review: null
    reviewed_at: null
  - name: "sprint-planning"
    phase: 4
    status: "required"
    description: "Sprint planning and story breakdown"
    plannotator_review: null
    reviewed_at: null
```

### Status Values
| Status | Meaning |
|--------|---------|
| `"optional"` | Can be skipped without impact |
| `"recommended"` | Strongly suggested but not blocking |
| `"required"` | Must complete to proceed |
| `"{file-path}"` | Completed — shows output file path |
| `"skipped"` | User explicitly chose to skip |
### plannotator Review Fields

| Field | Values | Meaning |
|-------|--------|---------|
| `plannotator_review` | `null` / `"pending"` / `"approved"` / `"skipped"` | Phase gate review status |
| `reviewed_at` | `null` / ISO timestamp | Time of plannotator approval |

Set automatically when running `bash scripts/phase-gate-review.sh` and approving in the plannotator UI.

### When Status Updates

Status is updated automatically when a workflow completes. Example transition:

```yaml
# Before completing PRD
- name: prd
  phase: 2
  status: "required"
  plannotator_review: null

# After completing PRD + plannotator approval
- name: prd
  phase: 2
  status: "docs/prd-myapp-2026-02-20.md"
  plannotator_review: "approved"
  reviewed_at: "2026-02-20T14:30:00Z"
```

---

## Project Directory Structure

After `/workflow-init`, your project gets:

```
your-project/
├── bmad/
│   ├── config.yaml              # Project BMAD config
│   └── agent-overrides/         # Optional custom templates
├── docs/
│   ├── bmm-workflow-status.yaml # Phase tracking
│   ├── stories/                 # Story files (Phase 4)
│   │   ├── story-E001-S001.md
│   │   └── story-E001-S002.md
│   ├── product-brief-myapp-2026-02-20.md  # Phase 1 output
│   ├── prd-myapp-2026-02-20.md            # Phase 2 output
│   └── architecture-myapp-2026-02-20.md  # Phase 3 output
└── .claude/
    └── commands/bmad/           # BMAD Claude commands
```

---

## Output File Naming Convention

BMAD uses consistent naming: `{workflow}-{project-name}-{date}.md`

```
docs/product-brief-myapp-2026-02-20.md
docs/prd-myapp-2026-02-20.md
docs/architecture-myapp-2026-02-20.md
docs/tech-spec-myapp-2026-02-20.md
```

Story files: `story-{epic-id}-{story-id}.md`

```
docs/stories/story-E001-S001.md
docs/stories/story-E001-S002.md
docs/stories/story-E002-S001.md
```

---

## Variable Substitution

Templates use `{{VARIABLE}}` syntax. BMAD replaces these automatically during init:

| Variable | Source | Example |
|----------|--------|---------|
| `{{PROJECT_NAME}}` | Project config | `MyApp` |
| `{{PROJECT_TYPE}}` | Project config | `web-app` |
| `{{PROJECT_LEVEL}}` | Project config | `2` |
| `{{USER_NAME}}` | Global config | `YourName` |
| `{{DATE}}` | Current date | `2026-02-20` |
| `{{TIMESTAMP}}` | Current time | `2026-02-20T10:00:00Z` |
| `{{OUTPUT_FOLDER}}` | Project config | `docs` |

### Conditional Variables (by project level)

```
{{PRD_STATUS}}
  → "required"    if level >= 2
  → "recommended" if level == 1
  → "optional"    if level == 0

{{TECH_SPEC_STATUS}}
  → "required"    if level <= 1
  → "optional"    if level >= 2

{{ARCHITECTURE_STATUS}}
  → "required"    if level >= 2
  → "optional"    if level <= 1
```

---

## Custom Agent Overrides

Place custom template files in `bmad/agent-overrides/` to override default BMAD behavior:

```
bmad/agent-overrides/
├── product-brief-template.md   # Custom product brief template
├── prd-template.md             # Custom PRD template
└── architecture-template.md    # Custom architecture template
```

BMAD will use your templates instead of the built-in ones when found in this folder.

---

→ Next: [Practical Examples](./examples.md)

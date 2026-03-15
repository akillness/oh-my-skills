---
name: bmad-orchestrator
description: Orchestrates BMAD workflows for structured AI-driven development. Routes work across Analysis, Planning, Solutioning, and Implementation phases with TEA (Task-Execute-Architect) cycles for structured execution.
allowed-tools: Read Write Bash Grep Glob
metadata:
  tags: bmad, orchestrator, workflow, planning, implementation, tea, ssd
  platforms: Claude, Gemini, Codex, OpenCode
  keyword: bmad
  version: 1.3.0
  source: user-installed skill
---


# bmad-orchestrator — BMAD Workflow Orchestration with SSD

## When to use this skill

- Initializing BMAD in a new project (with or without SSD)
- Running structured TEA cycles within each BMAD phase
- Checking and resuming BMAD/SSD workflow status
- Routing work across Analysis, Planning, Solutioning, and Implementation
- Managing structured handoff and cross-phase traceability between phases

---

## What is SSD (Structured System Design)?

SSD is a meta-framework that embeds **TEA cycles** within each BMAD phase, transforming phase execution from "produce a document" into a structured loop:

```
T → Task:     Decompose the phase into concrete tasks with assigned agents
E → Execute:  Run tasks in parallel via multi-agent team execution
A → Architect: Validate outputs for coherence, completeness, and cross-phase traceability
```

Each BMAD phase becomes an independent TEA cycle. The architect validation step produces a `PASS`, `PASS_WITH_WARNINGS`, `REVISE`, or `FAIL` verdict. Only after `PASS` (or `PASS_WITH_WARNINGS`) does the human review gate (plannotator) open. This ensures automated structural correctness before human review.

### SSD vs. Standard BMAD

| Aspect | Standard BMAD | BMAD + SSD |
|--------|--------------|------------|
| Phase execution | Document production (opaque) | TEA cycle: Decompose → Execute → Validate |
| Task decomposition | None | Explicit per-phase task lists with agent assignments |
| Execution surface | Manual / single-agent | Multi-agent Team execution (`/team`) |
| Validation | Human plannotator review | Automated architect review → then plannotator |
| Cross-phase traceability | None | Requirement coverage matrix per phase transition |
| State tracking | `bmm-workflow-status.yaml` | + `.omc/state/ssd-state.json` with task-level granularity |

---

## Installation

```bash
npx skills add https://github.com/akillness/oh-my-skills --skill bmad-orchestrator
```

## Notes for Codex Usage

`bmad-orchestrator`'s default execution path is Claude Code.
To run the same flow directly in Codex, we recommend operating BMAD stages via a higher-level orchestration path such as `omx`/`ohmg`.

---

## Control Model

BMAD phase routing uses the same three-layer abstraction as JEO:

- `settings`: platform-specific runtime configuration such as Claude hooks, Codex/Gemini instructions, and MCP setup
- `rules`: phase constraints such as "do not advance before the current phase document is approved" and "do not reopen the same unchanged phase document for review"
- `hooks`: platform callbacks such as Claude `ExitPlanMode`, Codex `notify`, or Gemini `AfterAgent`

For BMAD phase gates, the intended rule is strict:

- Review the current phase document before moving forward
- If the document hash has not changed since the last terminal review result, do not relaunch plannotator
- Only a revised document resets the gate and permits another review cycle
- **With SSD**: plannotator gate requires `architect_verdict: "PASS"` or `"PASS_WITH_WARNINGS"` in `ssd-state.json` before opening

---

## Platform Support Status

| Platform | Current support mode | Requirements |
|---|---|---|
| Gemini CLI | Native (recommended) | Register the `bmad` keyword, then run `/workflow-init` |
| Claude Code | Native (recommended) | Install skill + `remember` pattern |
| OpenCode | Orchestration integration | Use an `omx`/`ohmg`-style bridge |
| Codex | Orchestration integration | Use an `omx`/`ohmg`-style bridge |

---

## Standard BMAD Commands

```text
/workflow-init [--ssd]
/workflow-status
```

Typical flow:

1. Run `/workflow-init` to bootstrap BMAD config (add `--ssd` to also initialize SSD state).
2. Move through phases: Analysis → Planning → Solutioning → Implementation.
3. Run `/workflow-status` any time to inspect current phase and progress.

| Action | Command |
|--------|---------|
| Initialize BMAD | `/workflow-init` |
| Initialize BMAD + SSD | `/workflow-init --ssd` |
| Check BMAD/SSD status | `/workflow-status` |

---

## SSD Commands (TEA Integration)

Use these commands to run structured TEA cycles within each BMAD phase:

| Command | TEA Step | Purpose |
|---------|----------|---------|
| `/ssd-init` | Setup | Initialize `.omc/state/ssd-state.json` alongside BMAD (called automatically by `/workflow-init --ssd`) |
| `/ssd-decompose` | **T**ask | Decompose current phase into concrete tasks with agent assignments |
| `/ssd-execute` | **E**xecute | Dispatch decomposed tasks to agents via `/team` (multi-agent parallel execution) |
| `/ssd-validate` | **A**rchitect | Validate phase outputs for coherence, completeness, and cross-phase traceability |
| `/ssd-cycle` | T+E+A | Run the full TEA cycle for the current phase (decompose → execute → validate) |
| `/ssd-advance` | Transition | Advance to next phase after TEA cycle passes architect validation |
| `/ssd-status` | Status | Show SSD-enriched status: phase + TEA step + task progress + validation verdict |

### SSD Full Flow

```
/workflow-init --ssd
       |
       v
  ┌─────────────────────────────────────────────────────┐
  │              PHASE N TEA CYCLE                      │
  │                                                     │
  │  /ssd-decompose  (or /ssd-cycle for full auto)      │
  │       |                                             │
  │       v                                             │
  │  [T] Task decomposition                             │
  │       planner/analyst produces task list            │
  │       → ssd-state.json phases[N].tasks updated      │
  │       |                                             │
  │       v                                             │
  │  /ssd-execute                                       │
  │       |                                             │
  │       v                                             │
  │  [E] Multi-agent execution via /team                │
  │       TeamCreate → TaskCreate per subtask           │
  │       Agents: executor, analyst, designer,          │
  │               test-engineer, security-reviewer…     │
  │       → docs/ssd/phase-N/ artifacts produced        │
  │       → Phase document assembled from artifacts     │
  │       |                                             │
  │       v                                             │
  │  /ssd-validate                                      │
  │       |                                             │
  │       v                                             │
  │  [A] Architect validation                           │
  │       fabric -p bmad_ssd_phase_review               │
  │       (fallback: architect agent via TaskCreate)    │
  │       |                                             │
  │       ├── PASS ──────────→ plannotator review       │
  │       │                         |                   │
  │       │                    ┌────┴────┐              │
  │       │                    │ Approve │ Req Changes  │
  │       │                    └────┬────┘     |        │
  │       │                         |     Loop to [E]   │
  │       │                         v     with feedback │
  │       │                    /ssd-advance              │
  │       │                    → phase N+1               │
  │       │                                             │
  │       ├── PASS_WITH_WARNINGS → plannotator (warned) │
  │       │                                             │
  │       ├── REVISE → targeted re-execute specific     │
  │       │             tasks, then re-validate         │
  │       │                                             │
  │       └── FAIL → full re-execute with changes,      │
  │                   then re-validate                  │
  │                   (max 3 cycles, then escalate)     │
  └─────────────────────────────────────────────────────┘
```

---

## TEA Per-Phase Mapping

### Phase 1: Analysis

| TEA Step | Action | Agents | Output |
|----------|--------|--------|--------|
| **Task** | Decompose into: market research, user persona definition, competitive landscape, value proposition, constraint identification | `explore` (haiku) + `analyst` (opus) | Task list in `ssd-state.json` |
| **Execute** | Run tasks in parallel: research, persona, competitive data | `document-specialist`, `analyst`, `scientist` via Team | `docs/ssd/phase-1/*.md` |
| **Architect** | Validate: personas match value prop? Constraints conflict? Competitive gap real? | `architect` (opus) + fabric `bmad_ssd_phase_review` | Coherence report + PASS/FAIL/REVISE |

### Phase 2: Planning

| TEA Step | Action | Agents | Output |
|----------|--------|--------|--------|
| **Task** | Decompose into: functional requirements, non-functional requirements, user stories, acceptance criteria, UX specification | `planner` (opus) | Task list |
| **Execute** | Write functional/non-functional reqs from product brief; produce UX flows; draft acceptance criteria | `analyst`, `designer`, `test-engineer` via Team | PRD sections |
| **Architect** | Validate: requirements trace to product brief? Acceptance criteria testable? UX covers all user stories? | `architect` (opus) + fabric `bmad_ssd_phase_review` | Traceability matrix + verdict |

### Phase 3: Solutioning

| TEA Step | Action | Agents | Output |
|----------|--------|--------|--------|
| **Task** | Decompose into: component design, API contracts, data model, integration design, security design, performance design, technology selection | `architect` (opus) | Task list |
| **Execute** | Component/integration design; security design; performance design; technology evaluation | `architect`, `security-reviewer`, `quality-reviewer`, `document-specialist` via Team | Architecture sections |
| **Architect** | Validate: architecture fulfills PRD? API contracts consistent with user stories? Security design matches threat model? Run cross-phase traceability. | `architect` (opus) + `critic` (opus) + fabric `bmad_ssd_phase_review` | Architecture review + requirement coverage matrix |

### Phase 4: Implementation

| TEA Step | Action | Agents | Output |
|----------|--------|--------|--------|
| **Task** | Decompose sprint: epics → stories → implementation tasks (code, test, docs) | `planner` (opus) | Sprint plan with task breakdown |
| **Execute** | Implement code; write tests; update docs; resolve build issues | `executor`, `test-engineer`, `writer`, `build-fixer` via Team | Code, tests, docs per story |
| **Architect** | Validate: implementation matches architecture? Tests cover acceptance criteria? API contract honored? | `verifier` (sonnet) + `code-reviewer` (opus) + fabric `bmad_ssd_phase_review` | Implementation coherence report |

---

## Fabric Pattern: `bmad_ssd_phase_review`

Install this custom pattern for automated architect validation:

```bash
mkdir -p ~/.config/fabric/patterns/bmad_ssd_phase_review
cat > ~/.config/fabric/patterns/bmad_ssd_phase_review/system.md << 'EOF'
# IDENTITY AND PURPOSE

You are an expert system architect performing a structured phase review for the BMAD Structured System Design (SSD) framework. Your job is to validate that a phase document is internally coherent, externally consistent with prior phase artifacts, and complete enough to advance to the next phase.

Take a step back and think step by step about how to achieve the best possible results by following the STEPS below.

# STEPS

1. IDENTIFY the current BMAD phase (Analysis, Planning, Solutioning, Implementation) from the input metadata.

2. PARSE the phase document and extract all claims, requirements, design decisions, and deliverables.

3. INTERNAL COHERENCE CHECK:
   - Are there contradictory statements within the document?
   - Are all sections complete (no TODOs, placeholders, or TBDs)?
   - Do quantitative claims have justification?

4. CROSS-PHASE TRACEABILITY CHECK (if prior phase artifacts are provided):
   - Phase 2 (Planning): Does every PRD requirement trace to a product brief goal?
   - Phase 3 (Solutioning): Does the architecture address every PRD functional requirement?
   - Phase 4 (Implementation): Does every story map to an architecture component?
   - Flag any orphaned items.

5. COMPLETENESS CHECK against BMAD level expectations:
   - Level 0-1: Minimal viable coverage
   - Level 2: Full requirement coverage with acceptance criteria
   - Level 3: Comprehensive with integration points and risk analysis
   - Level 4: Enterprise-grade with security, performance, and infrastructure coverage

6. RISK ASSESSMENT:
   - Identify assumptions that could invalidate the phase output
   - Flag unresolved dependencies
   - Note scope creep relative to prior phase boundaries

7. PRODUCE a structured verdict.

# OUTPUT INSTRUCTIONS

- Output valid Markdown only.
- Begin with a `## Verdict` section: one of `PASS`, `PASS_WITH_WARNINGS`, `FAIL`, or `REVISE`.
- Follow with `## Internal Coherence` (findings with line references).
- Follow with `## Cross-Phase Traceability` (coverage matrix if applicable).
- Follow with `## Completeness` (missing sections or underspecified areas).
- Follow with `## Risks` (ranked by severity: critical, high, medium, low).
- Follow with `## Required Changes` (concrete, actionable items if verdict is FAIL or REVISE).
- Do not include warnings, disclaimers, or caveats outside the structured sections.

# INPUT

INPUT:
EOF
```

Usage in `/ssd-validate`:

```bash
# Pipe current phase doc + prior artifacts for cross-phase validation
{
  echo "--- CURRENT PHASE DOCUMENT ---"
  cat "$CURRENT_DOC"
  echo "--- PRIOR PHASE ARTIFACTS ---"
  for prior in "${PRIOR_DOCS[@]}"; do
    echo "--- $(basename "$prior") ---"
    cat "$prior"
  done
} | fabric -p bmad_ssd_phase_review --stream > docs/ssd/phase-N/architect-review.md

# Phase 3 example: validate architecture against PRD
cat docs/architecture-myapp-2026-03-16.md | \
  fabric -p bmad_ssd_phase_review \
  --context "$(cat docs/prd-myapp-2026-03-16.md)" \
  --stream
```

If `fabric` is not installed, `/ssd-validate` falls back to an `architect` agent:

```text
# In Claude Code session:
ssd validate — run architect review on the current phase document before advancing
```

---

## SSD State File Schema

Location: `.omc/state/ssd-state.json`

```json
{
  "version": "1.0.0",
  "project_name": "myapp",
  "project_level": 2,
  "active": true,
  "current_phase": 2,
  "created_at": "2026-03-16T10:00:00Z",
  "updated_at": "2026-03-16T14:30:00Z",
  "phases": {
    "1": {
      "name": "analysis",
      "tea_step": "complete",
      "tasks": {
        "decomposed_at": "2026-03-16T10:05:00Z",
        "items": [
          {
            "id": "p1-t1",
            "name": "Market research",
            "agent": "document-specialist",
            "model": "sonnet",
            "status": "completed",
            "output_path": "docs/ssd/phase-1/market-research.md"
          }
        ]
      },
      "architect_review": {
        "verdict": "PASS",
        "method": "fabric",
        "pattern": "bmad_ssd_phase_review",
        "report_path": "docs/ssd/phase-1/architect-review.md",
        "reviewed_at": "2026-03-16T11:00:00Z"
      },
      "plannotator_review": {
        "status": "approved",
        "reviewed_at": "2026-03-16T11:30:00Z",
        "document_hash": "abc123"
      }
    },
    "2": {
      "name": "planning",
      "tea_step": "execute",
      "tasks": {
        "items": [
          {
            "id": "p2-t1",
            "name": "Functional requirements extraction",
            "agent": "analyst",
            "model": "opus",
            "status": "in_progress"
          }
        ]
      },
      "architect_review": null,
      "plannotator_review": null
    }
  },
  "cross_phase_traceability": {
    "phase_1_to_2": { "validated": true, "coverage": 1.0, "orphaned_items": [] },
    "phase_2_to_3": { "validated": false },
    "phase_3_to_4": { "validated": false }
  }
}
```

**`tea_step` values**: `null` → `decompose` → `execute` → `validate` → `complete`

---

## plannotator Integration (Phase Review Gate)

Each BMAD phase produces a key document (PRD, Tech Spec, Architecture). Before transitioning to the next phase, review that document with **plannotator**.

**With SSD enabled**, plannotator only opens after `/ssd-validate` produces `architect_verdict: "PASS"` or `"PASS_WITH_WARNINGS"`. This ensures automated structural correctness before human review.

### Phase Review Pattern

```bash
# After /prd → docs/prd-myapp-2026-03-16.md is created
# With SSD: run /ssd-validate first, then phase-gate-review.sh
bash scripts/phase-gate-review.sh docs/prd-myapp-2026-03-16.md "PRD Review: myapp"

# After /architecture → docs/architecture-myapp-2026-03-16.md is created
bash scripts/phase-gate-review.sh docs/architecture-myapp-2026-03-16.md "Architecture Review: myapp"
```

Or submit the plan directly from your AI session:

```text
# In Claude Code after /prd completes:
planno — review the PRD before we proceed to Phase 3
```

### Phase Gate Flow (with SSD)

```
/prd completes → docs/prd-myapp.md created
       ↓
 /ssd-validate runs (automated architect review)
       ↓ fabric -p bmad_ssd_phase_review
       ↓
  PASS/PASS_WITH_WARNINGS?
       ↓ yes
 phase-gate-review.sh opens plannotator UI
       ↓
  [Approve]              [Request Changes]
       ↓                        ↓
 Obsidian saved          Agent revises doc
 ssd-state updated       /ssd-execute (targeted)
                         then /ssd-validate again
       ↓
 /ssd-advance → Phase 3
```

### Quick Reference

| Phase | Document | Gate |
|-------|----------|------|
| Phase 1 → 2 | Product Brief | `bash scripts/phase-gate-review.sh docs/product-brief-*.md` |
| Phase 2 → 3 | PRD / Tech Spec | `bash scripts/phase-gate-review.sh docs/prd-*.md` |
| Phase 3 → 4 | Architecture | `bash scripts/phase-gate-review.sh docs/architecture-*.md` |
| Phase 4 done | Sprint Plan | `bash scripts/phase-gate-review.sh docs/sprint-status.yaml` |

---

## Integration with `/team` (OMC)

`/ssd-execute` maps directly to OMC's Team staged pipeline. When you run `/ssd-execute`:

1. Reads `ssd-state.json` for the current phase's task list
2. Calls `TeamCreate` with team name `ssd-phase-{N}-{project}`
3. Creates tasks via `TaskCreate` with agent routing from the TEA per-phase table
4. Monitors via `TaskList` until all tasks reach terminal state
5. Writes outputs to `docs/ssd/phase-{N}/`
6. Updates `ssd-state.json` with execution results

```text
# Trigger SSD execution for current phase (Claude Code)
ssd execute — run phase 2 planning tasks with multi-agent team
```

Or use directly with Team:

```text
/team 4:analyst "Execute BMAD Phase 2 planning: functional requirements, non-functional requirements, user stories, acceptance criteria based on product brief at docs/product-brief-myapp.md"
```

---

## Quick Start with SSD

```bash
# 1. Initialize BMAD with SSD enabled
/workflow-init --ssd

# 2. Run full TEA cycle for Phase 1 (Analysis)
/ssd-cycle

# 3. Check status after cycle
/ssd-status

# 4. When architect validates PASS, human review opens automatically
# (plannotator UI launches)

# 5. After approval, advance to Phase 2
/ssd-advance

# 6. Repeat for each phase
/ssd-cycle  # Phase 2: Planning
/ssd-cycle  # Phase 3: Solutioning
/ssd-cycle  # Phase 4: Implementation
```

---

## Obsidian Save Format

Approved phase documents are saved to your Obsidian vault:

```yaml
---
created: 2026-03-16T10:00:00Z
source: plannotator
tags: [bmad, ssd, phase-2, prd, myapp]
ssd_architect_verdict: PASS
ssd_tea_cycle: 1
---

[[BMAD Plans]]

# PRD: myapp
...
```

---

## TOON Format Hook

If `~/.claude/hooks/toon-inject.mjs` is installed, the skill catalog is automatically injected into every prompt. See [bmad-orchestrator SKILL.md — TOON Format Integration] for details.

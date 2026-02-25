# bmad-orchestrator — Workflow Guide

→ [Overview](./README.md) · [Installation](./installation.md) · [Configuration](./configuration.md) · [Examples](./examples.md)

---

## The 4 BMAD Phases

BMAD routes your work through four structured phases. Each phase has specific commands and deliverables. BMAD automatically recommends the next step based on your project level.

```
Phase 1: Analysis       (Optional)
Phase 2: Planning       (Required)
Phase 3: Solutioning    (Required for Level 2+)
Phase 4: Implementation (Required)
```

---

## Phase 1: Analysis (Optional)

**Purpose:** Understand the problem space before building. Research market fit, define product vision, explore solutions.

**When to use:** Starting new products, major features, or when requirements are unclear.  
**When to skip:** Bug fixes, well-defined features, or urgent implementations.

### Phase 1 Commands

| Command | Purpose | Output | Duration |
|---------|---------|--------|----------|
| `/product-brief` | Define product vision & goals | Product brief doc | 1–2 hours |
| `/brainstorm` | Structured ideation session | Brainstorm notes | 30–60 min |
| `/research` | Market/competitive/technical analysis | Research report | 2–4 hours |

### When Required

- **Level 0–1:** Optional
- **Level 2:** Recommended
- **Level 3+:** Product brief **required**

---

## Phase 2: Planning (Required)

**Purpose:** Define detailed requirements and technical specifications. Every project must complete at least one planning workflow.

### Phase 2 Commands

| Command | Purpose | Output | Duration |
|---------|---------|--------|----------|
| `/prd` | Product Requirements Document | PRD with user stories, acceptance criteria | 2–4 hours |
| `/tech-spec` | Technical specification | Tech spec with API contracts, data models | 1–2 hours |
| `/create-ux-design` | UX/UI design | User flows, wireframes, interaction patterns | 2–6 hours |

### PRD vs Tech Spec: When to Choose

| Use **PRD** when... | Use **Tech Spec** when... |
|--------------------|--------------------------|
| Multiple features involved | Single feature or component |
| Stakeholder alignment needed | Technical-focused work |
| Business requirements are complex | Limited, well-defined scope |
| Product perspective important | Developer-centric work |

### When Required by Level

| Level | PRD | Tech Spec |
|-------|-----|-----------|
| 0 | Optional | **Required** |
| 1 | Recommended | **Required** |
| 2 | **Required** | Optional |
| 3+ | **Required** (detailed) | Optional |

---

## Phase 3: Solutioning (Conditional)

**Purpose:** Design system architecture for medium+ complexity projects.

**Required for:** Level 2+ projects  
**Skip for:** Level 0–1 (unless significant architectural changes)

### Phase 3 Commands

| Command | Purpose | Output | Duration |
|---------|---------|--------|----------|
| `/architecture` | System design | Architecture doc (components, data flow, APIs) | 2–6 hours |
| `/solutioning-gate-check` | Validate architecture | Gate check report + readiness score | 30–60 min |

### Architecture Content by Level

| Level | Architecture Scope |
|-------|-------------------|
| 2 | Component architecture, basic integrations |
| 3 | Comprehensive system design, multiple integrations |
| 4 | Enterprise architecture, platform design, infrastructure |

---

## Phase 4: Implementation (Required)

**Purpose:** Execute development through sprints and stories. Every project completes this phase.

### Phase 4 Commands

| Command | Purpose | Output | Duration |
|---------|---------|--------|----------|
| `/sprint-planning` | Break into epics & stories | Sprint plan + `sprint-status.yaml` | 1–3 hours |
| `/create-story` | Create individual story | `story-{epic}-{id}.md` | 15–30 min |
| `/dev-story` | Implement a story | Code + tests + story marked done | 30 min – hours |
| `/code-review` | Review implemented code | Review findings & recommendations | 30–60 min |

---

## Project Levels

BMAD adapts based on project complexity. When you run `/workflow-init`, you select a level (0–4).

### Level 0: Single Atomic Change (1 story)

| Phase | Required Workflows |
|-------|-------------------|
| 1 Analysis | — (skip) |
| 2 Planning | Tech Spec |
| 3 Solutioning | — (skip) |
| 4 Implementation | Story → Dev Story |

**Examples:** Bug fix, config change, single function addition  
**Duration:** Hours to 1 day  
**Typical flow:** `Tech Spec → Story → Implementation → Done`

---

### Level 1: Small Feature (1–10 stories)

| Phase | Required Workflows |
|-------|-------------------|
| 1 Analysis | Product Brief (recommended) |
| 2 Planning | Tech Spec (required), PRD (recommended) |
| 3 Solutioning | Architecture (optional) |
| 4 Implementation | Sprint Planning → Stories → Dev Stories |

**Examples:** New API endpoint, user profile page, email notifications  
**Duration:** 1–5 days  
**Typical flow:** `Product Brief → Tech Spec → Sprint Planning → Stories → Done`

---

### Level 2: Medium Feature Set (5–15 stories)

| Phase | Required Workflows |
|-------|-------------------|
| 1 Analysis | Product Brief (recommended) |
| 2 Planning | PRD (required), UX Design (recommended) |
| 3 Solutioning | Architecture (required) |
| 4 Implementation | Sprint Planning → Stories → Dev Stories → Code Review |

**Examples:** Authentication system, payment integration, dashboard  
**Duration:** 1–3 weeks  
**Typical flow:** `Product Brief → PRD → Architecture → Sprint Planning → Stories → Done`

---

### Level 3: Complex Integration (12–40 stories)

| Phase | Required Workflows |
|-------|-------------------|
| 1 Analysis | Product Brief (required) |
| 2 Planning | PRD (required, detailed) |
| 3 Solutioning | Architecture (required), Gate Check (recommended) |
| 4 Implementation | Multiple Sprints → Stories → Dev Stories → Code Review |

**Examples:** Third-party API integration, multi-tenant system, analytics platform  
**Duration:** 3–8 weeks  
**Typical flow:** `Product Brief → Research → PRD → Architecture → Gate Check → Sprints → Done`

---

### Level 4: Enterprise Expansion (40+ stories)

| Phase | Required Workflows |
|-------|-------------------|
| 1 Analysis | Product Brief + Research (both required) |
| 2 Planning | PRD (extensive) + UX Design (required) |
| 3 Solutioning | Architecture + Gate Check (both required) |
| 4 Implementation | Many Sprints → Stories → Dev Stories → Code Review |

**Examples:** Platform migration, microservices architecture, enterprise SaaS  
**Duration:** 2+ months  
**Typical flow:** `Product Brief → Research → PRD → UX Design → Architecture → Gate Check → Many Sprints → Done`

---

## Status Tracking

Run `/workflow-status` anytime to see current state:

```
Project: MyApp (web-app, Level 2)

✓ Phase 1: Analysis
  ✓ product-brief (docs/product-brief-myapp-2026-02-20.md)
  - research (optional)

→ Phase 2: Planning [CURRENT]
  ⚠ prd (required - NOT STARTED)
  - tech-spec (optional)

Phase 3: Solutioning
  - architecture (required)

Phase 4: Implementation
  - sprint-planning (required)
```

### Status Symbols
| Symbol | Meaning |
|--------|---------|
| `✓` | Completed |
| `⚠` | Required but not started |
| `→` | Current phase |
| `-` | Optional or not applicable |
| `📋` | Pending plannotator review before proceeding |
| `✅` | plannotator review approved & saved to Obsidian |

---

## Phase Transition Rules

| From → To | Can transition when | plannotator Gate |
|-----------|-------------------|-----------------|
| Phase 1 → 2 | Product brief complete, OR user skips Phase 1 | Optional — review product-brief |
| Phase 2 → 3 | PRD complete (Level 2+) OR Tech Spec complete (Level 0–1) | **Recommended** — review PRD/Tech Spec |
| Phase 3 → 4 | Architecture complete (Level 2+) OR project is Level 0–1 | **Required (Level 2+)** — review Architecture |
| Phase 4 → Done | All stories marked "done", tests passing | Optional — review Sprint Plan |

> Run `bash scripts/phase-gate-review.sh <doc> "<title>"` at each transition to open the plannotator review UI and auto-save approved docs to Obsidian.

---

→ Next: [Configuration Reference](./configuration.md)

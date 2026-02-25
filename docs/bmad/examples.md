# bmad-orchestrator — Practical Examples

→ [Overview](./README.md) · [Installation](./installation.md) · [Workflow Guide](./workflow.md) · [Configuration](./configuration.md)

---

## Example 1: Bug Fix (Level 0)

**Scenario:** Fix a login form validation bug.

```text
# 1. Initialize BMAD
/workflow-init
# → Project: AuthFix, Level: 0, Type: web-app

# 2. Check current status
/workflow-status
# → Phase 2: Planning [CURRENT] — Tech Spec required

# 3. Create tech spec for the fix
/tech-spec
# → Claude interviews you: What's the bug? What's the expected behavior?
# → Output: docs/tech-spec-authfix-2026-02-20.md

# 4. Create the single story
/create-story
# → Output: docs/stories/story-E001-S001.md

# 5. Implement it
/dev-story
# → Claude reads the story and implements the fix

# 6. Done ✓
```

**Total time:** 30–90 minutes  
**Documents created:** 1 tech spec, 1 story

---

## Example 2: New API Feature (Level 1)

**Scenario:** Add a "forgot password" email flow.

```text
# 1. Initialize
/workflow-init
# → Project: UserAPI, Level: 1, Type: api

# 2. Create product brief (optional but recommended)
/product-brief
# → Clarifies user flows, edge cases, and success criteria

# 3. Create tech spec (required for Level 1)
/tech-spec
# → Defines API endpoints, email template, token expiry

# 4. Sprint planning
/sprint-planning
# → Creates sprint with 3 stories:
#    - story-E001-S001: Forgot password API endpoint
#    - story-E001-S002: Email sending integration
#    - story-E001-S003: Token validation & password reset

# 5. Implement each story
/dev-story  # implements story-E001-S001
/dev-story  # implements story-E001-S002
/dev-story  # implements story-E001-S003

# 6. Check final status
/workflow-status
# ✓ All stories done
```

**Total time:** 1–3 days  
**Documents created:** 1 product brief, 1 tech spec, 1 sprint plan, 3 stories

---

## Example 3: Authentication System (Level 2)

**Scenario:** Build a full JWT authentication system (signup, login, refresh, logout).

```text
# 1. Initialize
/workflow-init
# → Project: AuthSystem, Level: 2, Type: api
# Phase 1: Analysis
/product-brief
# → Defines: target users, security requirements, OAuth support needed?
# Phase 2: Planning
/prd
# → Comprehensive requirements:
#    - User registration with email verification
#    - JWT access + refresh tokens
#    - OAuth (Google, GitHub)
#    - Rate limiting
#    - Account lockout
bash scripts/phase-gate-review.sh docs/prd-authsystem-2026-02-22.md "PRD Review: AuthSystem"
# → plannotator UI opens → Approve → saved to Obsidian → proceed to Phase 3
# → User flows for login, registration, password reset
# Phase 3: Solutioning
/architecture
# → System design:
#    - Token storage strategy
#    - Database schema (users, sessions, oauth_providers)
#    - API contract
#    - Security considerations
bash scripts/phase-gate-review.sh docs/architecture-authsystem-2026-02-22.md "Architecture Review: AuthSystem"
# → plannotator UI opens → Approve → saved to Obsidian → proceed to Phase 4
/sprint-planning
# → Sprint 1: Core auth (7 stories)
#    - story-E001-S001: User model & DB schema
#    - story-E001-S002: Registration endpoint
#    - story-E001-S003: Email verification
#    - story-E001-S004: Login endpoint
#    - story-E001-S005: JWT generation & refresh
#    - story-E001-S006: Logout & token revocation
#    - story-E001-S007: Rate limiting middleware
# → Sprint 2: OAuth (4 stories)
#    ...
# Implement sprint 1
/dev-story  # × 7 stories
# Code review
/code-review
# → Review findings, security audit
# Sprint 2
/dev-story  # × 4 stories
```
**Total time:** 1–3 weeks  
**Documents created:** 1 product brief, 1 PRD, 1 UX design, 1 architecture, 11+ stories  
**plannotator reviews:** PRD (Phase 2→3) + Architecture (Phase 3→4) both approved & Obsidian-archived

---

## Example 4: Checking Status Mid-Project

```text
# After some work, check where you are
/workflow-status

# Output:
# Project: AuthSystem (api, Level 2)
#
# ✓ Phase 1: Analysis
#   ✓ product-brief (docs/product-brief-authsystem-2026-02-20.md)
#   - research (optional)
#
# ✓ Phase 2: Planning
#   ✓ prd (docs/prd-authsystem-2026-02-20.md)
#   ✓ ux-design (docs/ux-design-authsystem-2026-02-20.md)
#
# ✓ Phase 3: Solutioning
#   ✓ architecture (docs/architecture-authsystem-2026-02-20.md)
#   - gate-check (optional)
#
# → Phase 4: Implementation [CURRENT]
#   ⚠ sprint-planning (required - NOT STARTED)
#
# Recommended next step: /sprint-planning

# Resume work
/sprint-planning
```

---

## Example 5: Enterprise SaaS Platform (Level 4)

**Scenario:** Build a multi-tenant B2B SaaS with billing, teams, and analytics.

```text
# 1. Initialize
/workflow-init
# → Project: SaasPlatform, Level: 4, Type: web-app

# Phase 1: Analysis (all required at Level 4)
/product-brief     # Comprehensive product vision
/research          # Competitor analysis, market research
/brainstorm        # Feature ideation session

# Phase 2: Planning
/prd               # Extensive PRD (20+ pages)
                   # → Multi-tenancy model
                   # → Billing & subscription management
                   # → Team collaboration features
                   # → Analytics & reporting
                   # → Admin console

/create-ux-design  # Complete UX for all major flows

# Phase 3: Solutioning
/architecture      # System-wide architecture
                   # → Microservices vs monolith decision
                   # → Database design (per-tenant isolation)
                   # → Infrastructure (Kubernetes, CDN)
                   # → Security model (RBAC, audit logs)
                   # → Payment integration (Stripe)

/solutioning-gate-check  # Validate architecture meets requirements

# Phase 4: Implementation (multiple sprints)
/sprint-planning   # Breaks into 6+ sprints, 40+ stories

# Sprint 1: Foundation
/dev-story  # × 8 stories (core infrastructure, auth, DB)

# Sprint 2: Multi-tenancy
/dev-story  # × 7 stories

# ... continue through all sprints

/code-review       # Required at Level 4
```

**Total time:** 2–6 months  
**Documents created:** 3+ analysis docs, PRD, UX design, architecture, gate check, 40+ stories

---

## Workflow Paths at a Glance

```
Level 0 (Fast Track):
  Tech Spec → Story → Implementation

Level 1 (Small Feature):
  Product Brief → Tech Spec → Sprint → Stories → Implementation

Level 2 (Feature Set):
  Product Brief → PRD → Architecture → Sprint → Stories → Implementation → Review

Level 3 (Integration):
  Product Brief → Research → PRD → Architecture → Gate Check → Sprints → Implementation → Review

Level 4 (Enterprise):
  Product Brief → Research → PRD → UX Design → Architecture → Gate Check → Many Sprints → Implementation → Review
```

---

## Tips

1. **Use `/workflow-status` frequently** — It always tells you the recommended next step
2. **Don't skip required workflows** — BMAD will warn you if you try to jump ahead
3. **Level up if scope grows** — You can re-run `/workflow-init` if a Level 1 feature becomes Level 2
4. **Parallel work in Phase 4** — Multiple dev stories from different epics can run in parallel
5. **`기억해` is essential** — Always activate with `기억해` to persist across sessions

---

→ [Back to Overview](./README.md) · [Back to skills-template README](../../README.md)

# bmad-gds — BMAD Game Development Studio

> **bmad-gds** is an AI-driven Game Development Studio built on the BMAD methodology. It routes game projects through structured phases — Pre-production, Design, Technical Architecture, Production, and Game Testing — using 6 specialized agents. Supports Unity, Unreal Engine, Godot, and custom engines.

[![Skills](https://img.shields.io/badge/Skills-bmad--gds-brightgreen)](../../.agent-skills/bmad-gds/SKILL.md)
[![Version](https://img.shields.io/badge/version-0.1.4-blue)](../../.agent-skills/bmad-gds/SKILL.md)

---

## Installation

```bash
npx skills add https://github.com/akillness/oh-my-skills --skill bmad-gds
```

Activate in conversation:

```text
bmad-gds 스킬을 설정하고 사용해줘. 기억해.
```

---

## Supported Engines

Unity · Unreal Engine · Godot · Custom/Other

---

## Workflow Phases

### Phase 1 — Pre-production

| Command | Description |
|---------|-------------|
| `bmad-gds-brainstorm-game` | Facilitate a game brainstorming session with game-specific ideation techniques |
| `bmad-gds-game-brief` | Create an interactive game brief defining concept and core mechanics |

### Phase 2 — Design

| Command | Description |
|---------|-------------|
| `bmad-gds-gdd` | Generate a Game Design Document: mechanics, systems, progression, implementation guidance |
| `bmad-gds-narrative` | Create narrative documentation: story structure, character arcs, world-building |

### Phase 3 — Technical Architecture

| Command | Description |
|---------|-------------|
| `bmad-gds-project-context` | Generate project-context.md for consistent AI agent coordination |
| `bmad-gds-game-architecture` | Produce scale-adaptive game architecture: engine, systems, networking, technical design |
| `bmad-gds-test-framework` | Initialize test framework architecture for Unity, Unreal, or Godot |
| `bmad-gds-test-design` | Create comprehensive test scenarios covering gameplay, progression, and quality |

### Phase 4 — Production

| Command | Description |
|---------|-------------|
| `bmad-gds-sprint-planning` | Generate or update sprint-status.yaml from epic files |
| `bmad-gds-sprint-status` | View sprint progress, surface risks, get next action recommendation |
| `bmad-gds-create-story` | Create a dev-ready implementation story |
| `bmad-gds-dev-story` | Execute a dev story: implement tasks and tests |
| `bmad-gds-code-review` | QA code review for stories flagged Ready for Review |
| `bmad-gds-correct-course` | Navigate major in-sprint course corrections |
| `bmad-gds-retrospective` | Facilitate retrospective after epic completion |

### Game Testing

| Command | Description |
|---------|-------------|
| `bmad-gds-test-automate` | Generate automated game tests for gameplay systems |
| `bmad-gds-e2e-scaffold` | Scaffold end-to-end testing infrastructure |
| `bmad-gds-playtest-plan` | Create a structured playtesting plan for user testing sessions |
| `bmad-gds-performance-test` | Design a performance testing strategy for profiling and optimization |
| `bmad-gds-test-review` | Review test quality and coverage gaps |

### Quick / Anytime

| Command | Description |
|---------|-------------|
| `bmad-gds-quick-prototype` | Rapid prototyping to validate mechanics without full planning overhead |
| `bmad-gds-quick-spec` | Quick tech spec for simple, well-defined features or tasks |
| `bmad-gds-quick-dev` | Flexible rapid implementation for game features |
| `bmad-gds-document-project` | Analyze and document an existing game project |

---

## Specialized Agents

| Agent | Role |
|-------|------|
| `game-designer` | Game concept, mechanics, GDD, narrative design, brainstorming |
| `game-architect` | Technical architecture, system design, project context |
| `game-dev` | Implementation, dev stories, code review |
| `game-scrum-master` | Sprint planning, story management, course corrections, retrospectives |
| `game-qa` | Test framework, test design, automation, E2E, playtest, performance |
| `game-solo-dev` | Full-scope solo mode: quick prototype, quick spec, quick dev |

---

## Typical Workflow

1. `bmad-gds-brainstorm-game` → ideate game concept
2. `bmad-gds-game-brief` → lock in concept and core mechanics
3. `bmad-gds-gdd` → produce full Game Design Document
4. `bmad-gds-game-architecture` → define technical architecture
5. `bmad-gds-sprint-planning` → break work into sprints and stories
6. `bmad-gds-dev-story` per story → implement features
7. `bmad-gds-code-review` → quality gate before merge
8. `bmad-gds-retrospective` → continuous improvement after each epic

---

## Quick Reference

| Action | Command |
|--------|---------|
| Brainstorm game concept | `bmad-gds-brainstorm-game` |
| Create game brief | `bmad-gds-game-brief` |
| Generate GDD | `bmad-gds-gdd` |
| Define architecture | `bmad-gds-game-architecture` |
| Plan sprint | `bmad-gds-sprint-planning` |
| Check sprint status | `bmad-gds-sprint-status` |
| Create story | `bmad-gds-create-story` |
| Develop story | `bmad-gds-dev-story` |
| Quick prototype | `bmad-gds-quick-prototype` |

---

## Related

- [SKILL.md](../../.agent-skills/bmad-gds/SKILL.md) — full skill specification
- [bmad-orchestrator docs](../bmad/README.md) — base BMAD workflow
- [bmad-idea docs](../bmad-idea/README.md) — creative ideation before development

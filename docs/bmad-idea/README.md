# bmad-idea — BMAD Creative Intelligence Suite

> **bmad-idea** is a Creative Intelligence Suite for AI-driven ideation, design thinking, innovation strategy, problem-solving, and storytelling. 5 named specialist agents with distinct methodologies — no setup required, all workflows available immediately.

[![Skills](https://img.shields.io/badge/Skills-bmad--idea-brightgreen)](../../.agent-skills/bmad-idea/SKILL.md)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](../../.agent-skills/bmad-idea/SKILL.md)

---

## Installation

```bash
npx skills add https://github.com/akillness/oh-my-skills --skill bmad-idea
```

Activate in conversation:

```text
bmad-idea 스킬을 설정하고 사용해줘. 기억해.
```

---

## When to Use

- Brainstorming ideas using structured creative techniques (36 methods across 7 categories)
- Running a human-centered design thinking process
- Identifying market disruption opportunities or designing new business models
- Diagnosing complex problems using systematic root cause analysis
- Crafting compelling narratives, product stories, or pitches
- Any creative front-end work before structured development begins

---

## Creative Workflows

All workflows are available immediately — no sequential phases required.

| Command | Code | Description |
|---------|------|-------------|
| `bmad-cis-brainstorming` | BS | Facilitate a brainstorming session using 36 proven techniques across 7 categories |
| `bmad-cis-design-thinking` | DT | Guide human-centered design through empathy, ideation, and prototyping (5-phase) |
| `bmad-cis-innovation-strategy` | IS | Identify disruption opportunities and design business model innovation |
| `bmad-cis-problem-solving` | PS | Systematic problem diagnosis: root cause analysis and solution planning |
| `bmad-cis-storytelling` | ST | Craft compelling narratives using 25 proven story frameworks |

---

## Slash Commands

| Command | Agent | Shorthand |
|---------|-------|-----------|
| `/cis-brainstorm` | Carson — Brainstorming Coach | `BS` |
| `/cis-design-thinking` | Maya — Design Thinking Coach | `DT` |
| `/cis-innovation-strategy` | Victor — Innovation Strategist | `IS` |
| `/cis-problem-solving` | Dr. Quinn — Creative Problem Solver | `PS` |
| `/cis-storytelling` | Sophia — Storyteller | `ST` |

---

## Specialized Agents

| Agent | Persona | Specialty |
|-------|---------|-----------|
| **Carson** 🧠 | Brainstorming Coach | "Yes, and!" energy — 36 ideation techniques, psychological safety |
| **Maya** 🎨 | Design Thinking Coach | Jazz improviser style — empathy mapping, 5-phase facilitation |
| **Victor** ⚡ | Innovation Strategist | Chess grandmaster mindset — JTBD, Blue Ocean Strategy, Disruptive Innovation, BMC |
| **Dr. Quinn** 🔬 | Creative Problem Solver | Sherlock meets scientist — TRIZ, Theory of Constraints, Five Whys, Systems Thinking |
| **Sophia** 📖 | Storyteller | Master bard style — 25 story frameworks, emotional arc crafting |

---

## Load an Agent Directly

Start a conversation with a specific agent without triggering a full workflow:

| Command | Agent |
|---------|-------|
| `/cis-agent-brainstorming-coach` | Carson |
| `/cis-agent-design-thinking-coach` | Maya |
| `/cis-agent-innovation-strategist` | Victor |
| `/cis-agent-creative-problem-solver` | Dr. Quinn |
| `/cis-agent-storyteller` | Sophia |

---

## Creative Squad (Team Mode)

Run a full cross-functional creative session with all agents:

```text
creative squad
```

Combines all CIS agents for comprehensive creative development: ideation → design → innovation → problem-solving → narrative.

---

## Quick Reference

| Goal | Command |
|------|---------|
| Generate ideas | `bmad-cis-brainstorming` or `/cis-brainstorm` |
| Design for users | `bmad-cis-design-thinking` or `/cis-design-thinking` |
| Find market gaps | `bmad-cis-innovation-strategy` or `/cis-innovation-strategy` |
| Solve a hard problem | `bmad-cis-problem-solving` or `/cis-problem-solving` |
| Tell a compelling story | `bmad-cis-storytelling` or `/cis-storytelling` |
| Full creative session | `creative squad` |

---

## Related

- [SKILL.md](../../.agent-skills/bmad-idea/SKILL.md) — full skill specification
- [bmad-orchestrator docs](../bmad/README.md) — structured BMAD development workflow
- [bmad-gds docs](../bmad-gds/README.md) — game development with BMAD

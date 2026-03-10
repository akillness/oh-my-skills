---
name: survey
description: "Cross-platform landscape scan before planning or implementation. Researches context, workarounds, existing solutions, and structural gaps, then writes reusable survey artifacts for OMC, OMX, OHMG, and general agent workflows."
allowed-tools: Read Write Bash Grep Glob WebFetch
metadata:
  tags: survey, landscape-scan, research, discovery, groundwork, omc, omx, ohmg, claude, codex, gemini, hooks, rules, settings
  platforms: Claude Code, Codex, Gemini-CLI, OpenCode
  keyword: survey
  version: 1.0.0
  source: supercent-io/skills-template
---


# survey - Cross-Platform Problem-Space Scan

> Keyword: `survey` | Platforms: OMC / OMX / OHMG / Claude Code / Codex CLI / Gemini CLI / OpenCode
>
> Survey the landscape before planning, coding, or committing to a direction.

---

## When to use this skill

- Before building a new feature, tool, workflow, or agent capability
- When the user asks "what exists?", "scan the landscape", "research this space", or "survey solutions"
- When you need problem context, current workarounds, and solution gaps before `/plan`, `jeo`, `ralph`, or implementation
- When the topic spans multiple agent platforms and you need a single vendor-neutral picture

## Do not use this skill when

- The user already knows the solution and wants implementation now
- The task is a small bug fix or narrow code change
- The user needs a feasibility study, architecture plan, or execution roadmap rather than discovery

---

## Output Package

Save research in a platform-neutral directory so Claude / Codex / Gemini can all reuse it:

```text
.survey/{slug}/
├── triage.md
├── context.md
├── solutions.md
└── platform-map.md    # optional; required for agent/tooling/platform topics
```

- `triage.md`: problem / audience / why now
- `context.md`: workflows, affected users, workarounds, adjacent problems, user voices
- `solutions.md`: solution inventory, categories, frequency, gaps, contradictions, key insight
- `platform-map.md`: normalize platform-specific findings into `settings`, `rules`, `hooks`

---

## Core Abstraction Layer

When the topic involves agent tooling, model orchestration, hooks, permissions, or vendor APIs, normalize findings into three layers:

- `settings`: model, safety, temperature, max tokens, system prompt, provider parameters
- `rules`: allow/deny/modify policy, guardrails, action constraints, approval logic
- `hooks`: pre/post/error callbacks, notify handlers, lifecycle automation, event triggers

Use this abstraction when comparing Claude, Codex, Gemini, OMC, OMX, or OHMG. Do not describe vendor features as unrelated one-off concepts if they map cleanly into one of these three layers.

Recommended internal profile:

```yaml
survey_profile:
  settings:
    search_language: English
    output_language: user-language
    max_searches_per_lane: 8-10
    save_root: .survey
  rules:
    - facts_only
    - no_code_generation
    - ask_max_2_triage_questions
    - dedupe_solution_names
    - include_source_links
  hooks:
    pre_research:
      - normalize_topic
      - choose_platform_adapter
    post_lane:
      - merge_notes
      - record_sources
    post_run:
      - write_summary
      - suggest_next_skill
```

---

## Platform Adapter

Select the closest available orchestration surface, but keep the output format identical.

| Platform | Preferred execution shape | Notes |
|----------|---------------------------|-------|
| **OMC / Claude Code** | 4 parallel research agents. Prefer research-oriented specialist agents when available; otherwise use general-purpose agents with web search. | Keep artifacts in `.survey/`, not `.omc/`, so other platforms can reuse them. |
| **OMX / Codex CLI** | Use `$research`, explorer/planner-style agents, or parallel workers with web access. | Translate vendor config into `settings/rules/hooks` in `platform-map.md` when relevant. |
| **OHMG / Gemini / Antigravity** | Use Workflow Guide + PM/research-capable agents or equivalent parallel lanes. | Preserve the same 4-lane structure and shared artifact names. |
| **OpenCode / fallback** | Use generic web-capable agents in parallel. | Do not block on missing specialized agent names. |

If a platform-specific specialist does not exist, fall back to a general-purpose web-enabled agent and keep going.

---

## Execution Policy

- Never write product code in this skill. This is a research-only skill.
- Search broadly in **English** for coverage, unless the user explicitly requires another search language.
- Save files in the **user's language** unless the repository has a stronger convention.
- Ask at most **2 triage questions**, one at a time, only if `what`, `who`, or `why` is unclear.
- Run all 4 research lanes in parallel whenever possible.
- Keep claims source-backed. Include links for quotes, rankings, and non-obvious claims.
- Deduplicate tools that appear under multiple names or product tiers.
- Do not recommend build/kill/adopt by default. Present the landscape and gaps.

---

## Workflow

### Step 0: Triage

Parse the request into:

- `what`: the pain point, idea, or capability to survey
- `who`: who feels the pain or uses the workflow
- `why`: why it matters now

Before proceeding, check whether `.survey/{slug}/triage.md` already exists.

- If it exists, ask whether to reuse or overwrite.
- If the user keeps the existing survey, skip to Step 3 and summarize the saved files.

Save:

```markdown
# Triage
- Problem: {what}
- Audience: {who}
- Why now: {why}
```

### Step 1: Run 4 Parallel Lanes

Launch all lanes together.

#### Lane A: Context

Research:

- where the problem appears in real workflows
- who is affected
- how people currently work around it
- adjacent problems and downstream consequences
- direct user voices from communities

Return sections:

- `## Workflow Context`
- `## Affected Users`
- `## Current Workarounds`
- `## Adjacent Problems`
- `## User Voices`

#### Lane B: Solutions

Research:

- products, plugins, libraries, SaaS, GitHub projects, services
- curated lists and comparison pages
- common pricing and packaging
- limitations and repeated complaints

Return sections:

- `## Solutions`
- `## Frequency Ranking`
- `## Categories`
- `## Curated Sources`

#### Lane C: Actual Behavior

Research:

- what people actually use in practice
- which manual workflows persist despite vendor claims
- common frustration patterns
- where users drop back to spreadsheets, scripts, copy-paste, or multi-tool workflows

Return sections:

- `## What People Actually Use`
- `## Common Workarounds`
- `## Pain Points With Current Solutions`
- `## Sources`

#### Lane D: Alternatives / Platform Map

Default mode:

- JTBD alternatives
- cross-industry substitutes
- indirect competitors

For agent / model / orchestration topics, this lane must instead normalize the space into:

- `## Settings`
- `## Rules`
- `## Hooks`
- `## Platform Gaps`

Use a comparison table for Claude / Codex / Gemini when applicable.

### Step 2: Synthesize and Save

Write `context.md`:

```markdown
# Context: {project name}

## Workflow Context
{when and where the problem shows up}

## Affected Users
| Role | Responsibility | Skill Level |
|------|----------------|-------------|
{rows}

## Current Workarounds
{numbered list with limitations}

## Adjacent Problems
{lettered or bulleted list}

## User Voices
{quotes with source links}
```

Write `solutions.md`:

```markdown
# Solution Landscape: {project name}

## Solution List
| Name | Approach | Strengths | Weaknesses | Notes |
|------|----------|-----------|------------|-------|
{deduplicated list}

## Categories
{grouped by category}

## What People Actually Use
{behavior summary}

## Frequency Ranking
{most mentioned solutions}

## Key Gaps
{structural gaps not covered today}

## Contradictions
{marketed claims vs user reality}

## Key Insight
{1 paragraph}
```

When the topic is platform or agent related, write `platform-map.md`:

```markdown
# Platform Map: {project name}

## Settings
| Concern | Claude | Codex | Gemini | Common Layer |
|---------|--------|-------|--------|--------------|
{rows}

## Rules
| Concern | Claude / OMC | Codex / OMX | Gemini / OHMG | Common Layer |
|---------|---------------|-------------|---------------|--------------|
{rows}

## Hooks
| Lifecycle | Claude | Codex | Gemini | Common Layer |
|-----------|--------|-------|--------|--------------|
{rows}

## Platform Gaps
{where abstractions do not align cleanly}
```

### Step 3: Summarize for the User

Return a short summary:

```markdown
## Survey complete: {slug}

### Context
- {1-2 sentence summary}
- Main workaround: {most common workaround}

### Solution Landscape
- {N} solutions across {M} categories
- Key insight: {one sentence}
- Key gap: {one sentence}

### Files
- `.survey/{slug}/triage.md`
- `.survey/{slug}/context.md`
- `.survey/{slug}/solutions.md`
- `.survey/{slug}/platform-map.md`   # if created
```

Do not move into planning or implementation unless the user asks.

---

## Quick Reference

| Action | Instruction |
|--------|-------------|
| Start a survey | `survey <topic>` |
| Reuse existing results | Check `.survey/{slug}/` first |
| Search strategy | Search in English, write in the user's language |
| Parallel lanes | Context + Solutions + Behavior + Alternatives/Platform Map |
| Next step after survey | `/plan`, `jeo`, `ralph`, or implementation if the user asks |

---

## Final Checklist

- [ ] `what / who / why` are clear
- [ ] Existing survey checked before overwrite
- [ ] 4 lanes executed in parallel
- [ ] Source links included for quotes and non-obvious claims
- [ ] `context.md` saved
- [ ] `solutions.md` saved
- [ ] `platform-map.md` saved for agent/platform topics
- [ ] Final user summary is factual, short, and recommendation-free


# JEO Skill Autoresearch Changelog

## Experiment 0 — baseline

Score: 1/6
Change: None (original SKILL.md)
Reasoning: Establish baseline before mutations
Result: 1178 lines, ~14746 tokens. Massive Python checkpoint duplication (4x), steps buried in code walls, FLOW.md duplicates 80% of content
Remaining failures: Token budget, duplication, step clarity, NEVER rule placement, self-containedness

## Experiment 1 — keep

Score: 6/6
Change: Comprehensive restructure — extract checkpoint/error/resume code into `scripts/jeo-state-update.py`, remove 4x duplicated Python blocks, trim installation/config/troubleshooting to essentials, tighten step boundaries with clear entry/exit conditions, consolidate NEVER rules at top and inline at each step
Reasoning: All 5 failing evals stem from the same root cause — the skill tried to be both an execution protocol AND a reference manual. The duplication, bloat, and buried instructions are symptoms of mixing concerns. Fixing token budget requires fixing all of them simultaneously.
Result: 329 lines (~3000 tokens) — 72% line reduction, 80% token reduction. All 6 evals pass. Steps are scannable, rules are visible, state management is one script call.
Remaining failures: None — score plateau reached at 100%

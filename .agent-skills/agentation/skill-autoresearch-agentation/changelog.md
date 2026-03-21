# agentation skill-autoresearch log

## Inputs

- Target skill path: `.agent-skills/agentation/SKILL.md`
- Runs per experiment: `5`
- Experiment interval: deterministic static-doc eval
- Budget cap: stop on plateau or `100%` pass rate

## Test inputs

1. "Set up `agentation` on Codex or Claude quickly, then start watch mode."
2. "Watch mode is running, but no annotations arrive."
3. "Verify the end-to-end watch loop before starting a UI fix sprint."

## Binary evals

EVAL 1: Scripts section
Question: Does the skill surface bundled automation scripts near the top of the document?
Pass: A dedicated scripts section exists and names both `scripts/setup-agentation-mcp.sh` and `scripts/verify-loop.sh`.
Fail: The skill only embeds config snippets or mentions the scripts much later.

EVAL 2: Preflight triage
Question: Can a user diagnose a silent watch loop with explicit health/session/pending checks?
Pass: The skill includes `/health`, `/sessions`, and `/pending` checks in a watch-loop troubleshooting path.
Fail: One or more checks are missing.

EVAL 3: Verify loop command
Question: Does the skill provide an explicit end-to-end verification command for the watch loop?
Pass: It includes `bash .agent-skills/agentation/scripts/verify-loop.sh` and the `--quick` variant.
Fail: Verification is omitted or incomplete.

EVAL 4: Mode guidance
Question: Does the skill distinguish copy-paste from agent-sync behavior clearly enough to choose a path?
Pass: It names both modes and explains when passive injection means no explicit watch command is needed.
Fail: Modes are blended or unclear.

EVAL 5: Dev/desktop guard
Question: Does the skill prevent accidental production/mobile use?
Pass: It calls out both `NODE_ENV === 'development'` gating and desktop-only support.
Fail: One or both constraints are missing.

## Experiment 0 - baseline

Score: 4/5
Change: None. Baseline snapshot of the original skill.
Reasoning: Measure the untouched skill before editing it.
Result: The skill already covered triage, verification, mode choice, and development guardrails, but it buried the local helper scripts.
Remaining failures: `scripts_section`

## Experiment 1 - keep

Score: 5/5
Change: Added a dedicated `Scripts (Automated Patterns)` section directly after "When to use this skill".
Reasoning: The skill had working local helpers, but users had to wade through long setup blocks before discovering them.
Result: The new section closed the only failing eval without affecting the rest of the skill.
Remaining failures: None.

## Stop condition

Stopped after experiment 1 because the score reached `5/5` and additional mutations would only risk churn without improving the eval suite.

# plannotator skill-autoresearch log

## Inputs

- Target skill path: `.agent-skills/plannotator/SKILL.md`
- Runs per experiment: `5`
- Experiment interval: deterministic static-doc eval
- Budget cap: stop on plateau or `100%` pass rate

## Test inputs

1. "Configure plannotator in Codex CLI and submit a plan safely."
2. "Run code review manually and get the feedback back to the agent."
3. "Use plannotator over SSH or devcontainer without port confusion, and review a non-git file."

## Binary evals

EVAL 1: Validated stdin
Question: Does the skill preserve the verified python JSON stdin format and warn against the failing heredoc path?
Pass: The skill includes the python `tool_input` format and the `Failed to parse hook event from stdin` warning.
Fail: The validated stdin guidance is missing.

EVAL 2: Manual review limitation
Question: Does the skill warn that manual code review UI does not automatically deliver feedback back into the active agent session?
Pass: It says manual `plannotator review` or `scripts/review.sh` does not automatically send feedback to the active session and gives a workaround.
Fail: The limitation is omitted.

EVAL 3: Git requirement
Question: Does the skill explain that Code Review requires a git repo and provide a temp-repo workaround?
Pass: It explicitly states the repo requirement and includes a minimal `git init -q` flow.
Fail: The requirement is implicit or missing.

EVAL 4: Port conflict guidance
Question: Does the skill help recover from stale ports or multiple local instances?
Pass: It includes both `pkill plannotator` cleanup and a fixed `PLANNOTATOR_PORT=19432` example.
Fail: Port-conflict recovery is missing.

EVAL 5: Hook-mode notes
Question: Does the skill preserve the existing note that save-to-notes buttons only work in hook mode?
Pass: The hook-mode note remains present.
Fail: The note is removed or weakened.

## Experiment 0 - baseline

Score: 2/5
Change: None. Baseline snapshot of the original skill.
Reasoning: Measure the untouched skill before editing it.
Result: The skill already had the validated stdin workaround and hook-mode notes caveat, but it still left several real-world failure modes implicit.
Remaining failures: `manual_review_limit`, `git_requirement`, `port_conflict_guidance`

## Experiment 1 - keep

Score: 5/5
Change: Added `Pattern 4.1: Known Limitations & Verified Workarounds` directly after the Code Review pattern.
Reasoning: The missing instructions all belonged to the same real-world failure cluster around manual review usage.
Result: One focused section resolved every failing eval without rewriting the rest of the skill.
Remaining failures: None.

## Stop condition

Stopped after experiment 1 because the score reached `5/5` and the failure set was exhausted.

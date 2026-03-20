---
name: skill-autoresearch
description: >
  Autonomously optimize an existing AI skill by running it repeatedly against
  binary evals, mutating one instruction at a time, and keeping only changes
  that improve pass rate. Based on Karpathy-style autoresearch, but applied to
  SKILL.md iteration instead of ML training. Use when optimizing a skill,
  benchmarking prompt quality, building evals for a skill, or running
  self-improvement loops on reusable agent instructions. Triggers on:
  skill-autoresearch, optimize this skill, improve this skill, benchmark this
  skill, eval my skill, run autoresearch on this skill, self-improve skill.
allowed-tools: Bash Read Write Edit Glob Grep WebFetch
compatibility: >
  Works best when the target skill has 3-5 representative test inputs, 3-6
  binary yes/no evals, and a deterministic way to run or inspect outputs.
metadata:
  tags: skill-autoresearch, skill-optimization, evals, prompt-iteration, benchmarking, mutation-loop, karpathy
  version: "1.0"
  source: https://github.com/olelehmann100kMRR/autoresearch-skill
---

# Skill Autoresearch

Use this skill to improve another skill through measured iteration instead of gut feel.

The job is simple: run the target skill on a small test set, score outputs with binary evals, change one thing in the prompt, and keep only mutations that improve the score. Repeat until the score plateaus, the budget cap is hit, or the user stops the loop.

## When to use this skill

- A skill works inconsistently and needs a repeatable improvement loop
- You want to benchmark a SKILL.md before editing it
- You need binary evals for prompt or skill quality
- You want a mutation log instead of ad-hoc rewriting
- You want to compare baseline vs improved prompt behavior

## Required inputs

Do not start experiments until all inputs below are known:

1. Target skill path
2. Three to five representative test inputs
3. Three to six binary yes/no evals
4. Runs per experiment, default `5`
5. Experiment interval, default `2m`
6. Optional budget cap

For writing reliable evals, read [references/eval-guide.md](references/eval-guide.md).

## Instructions

### Step 1: Read the target skill

1. Read the target `SKILL.md`
2. Read any directly linked files under that skill's `references/`
3. Identify the core job, required steps, output format, and likely failure modes
4. Note buried instructions or conflicting rules before changing anything

### Step 2: Build the eval suite

Convert the user's quality criteria into binary checks only.

Use this format:

```text
EVAL 1: Short name
Question: Yes/no question about the output
Pass: Specific condition that counts as yes
Fail: Specific condition that counts as no
```

Rules:

- Use binary yes/no checks only
- Prefer observable checks over taste-based judgments
- Keep evals distinct; do not double-count the same failure
- Use three to six evals total

### Step 3: Create the experiment workspace

Inside the target skill folder, create:

```text
skill-autoresearch-[skill-name]/
  dashboard.html
  results.json
  results.tsv
  changelog.md
  SKILL.md.baseline
```

Requirements:

- `results.tsv` stores experiment summaries
- `results.json` powers the dashboard
- `dashboard.html` is a self-contained status page
- `SKILL.md.baseline` is the untouched original

### Step 4: Establish the baseline

Run the target skill as-is before editing it.

1. Back up the original skill as `SKILL.md.baseline`
2. Run the skill `N` times on the same test inputs
3. Score every run against every eval
4. Record experiment `0` as the baseline
5. If baseline is already above 90 percent, confirm whether more optimization is worth it

Use this `results.tsv` header:

```text
experiment	score	max_score	pass_rate	status	description
```

### Step 5: Run the mutation loop

This is the core loop:

1. Inspect the failing outputs
2. Form one hypothesis about the failure
3. Make one targeted change to `SKILL.md`
4. Re-run the same test set
5. Score all outputs again
6. Keep the change only if the score improves
7. Revert ties or regressions
8. Append the result to `results.tsv`, `results.json`, and `changelog.md`

Good mutations:

- Clarify an ambiguous instruction
- Move a critical rule higher
- Add one anti-pattern for a recurring failure
- Add one focused example
- Remove a noisy instruction that causes overfitting

Bad mutations:

- Rewrite the whole skill at once
- Add many rules in one experiment
- Optimize for length instead of behavior
- Use intuition instead of measured score

### Step 6: Keep the dashboard live

The dashboard should refresh from `results.json` and show:

- Experiment number
- Score and pass rate progression
- Baseline vs keep vs discard status
- Per-eval failure hotspots
- Current run state: running, idle, or complete

Use a single self-contained HTML file. Inline CSS/JS is preferred.

### Step 7: Log every experiment

Append after every run:

```markdown
## Experiment N — keep|discard

Score: X/Y
Change: one-sentence mutation summary
Reasoning: why this mutation was tried
Result: what improved or regressed
Remaining failures: what still breaks
```

Discarded experiments matter. They stop future agents from repeating dead ends.

### Step 8: Deliver results

When the loop stops, report:

1. Baseline score to final score
2. Number of experiments run
3. Keep vs discard count
4. Top changes that helped most
5. Remaining failure patterns
6. Artifact locations

## Rules

- Do not run experiments before inputs and evals are defined
- Use the same test set for baseline and mutations
- Change one thing at a time
- Keep or discard by score, not by preference
- Record every attempt
- Stop only on manual stop, budget cap, or clear score plateau

## Output format

Expected artifacts:

```text
skill-autoresearch-[skill-name]/
  dashboard.html
  results.json
  results.tsv
  changelog.md
  SKILL.md.baseline
```

The improved skill stays in place at its original path.

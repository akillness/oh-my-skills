# Eval Guide

Use this guide when turning fuzzy quality goals into binary skill evals.

## Golden rule

Every eval must be answerable with `yes` or `no`.

Avoid:

- numeric scales
- vibe checks
- overlapping checks
- checks an agent cannot verify consistently

## Good eval pattern

```text
EVAL 1: Short name
Question: Yes/no question
Pass: Specific condition for yes
Fail: Specific condition for no
```

## Good vs bad evals

### Writing skills

Bad:

- "Is the writing good?"
- "Does it feel engaging?"

Good:

- "Does the first paragraph contain a concrete claim, date, or metric?"
- "Does the output avoid banned filler phrases?"
- "Does the output end with a specific next action?"

### Visual or presentation skills

Bad:

- "Does it look professional?"
- "Is the layout good?"

Good:

- "Is all text legible with no overlap or truncation?"
- "Does the layout flow in one clear reading direction?"
- "Does the palette stay within the defined color constraints?"

### Code or technical skills

Bad:

- "Is the code clean?"
- "Does it follow best practices?"

Good:

- "Does the code run without errors?"
- "Does the output contain zero TODO or placeholder text?"
- "Does every external call have explicit error handling?"

### Document skills

Bad:

- "Is it comprehensive?"
- "Does it address the client's needs?"

Good:

- "Does it include all required sections?"
- "Is every major claim backed by a number, date, or source?"
- "Is the executive summary within the target size limit?"

## Quick quality check

Before accepting an eval, ask:

1. Would two agents likely score the same output the same way?
2. Can the skill game the eval without really improving?
3. Does the eval measure something the user actually cares about?

If any answer is bad, rewrite the eval.

# program.md Authoring Guide

> "The researcher's job shifts from writing Python to writing Markdown." — Andrej Karpathy

`program.md` is the most important file in an autoresearch session. The agent reads it at the start of every loop iteration. A vague `program.md` wastes GPU hours; a precise one focuses the search.

---

## What program.md Controls

The agent uses `program.md` to decide:
- **What to try next** — which hypotheses to form
- **What to avoid** — directions already explored or known to fail
- **What to prioritize** — VRAM efficiency vs. val_bpb vs. speed
- **What constraints to respect** — VRAM limit, MAX_SEQ_LEN, banned packages

The agent does NOT use `program.md` to determine the evaluation metric (always `val_bpb`), the time budget (always 300s), or which file to edit (always `train.py`).

---

## Minimal Template

```markdown
# Research Program

## Goal
Minimize val_bpb on the FineWeb-Edu validation set.

## Current Baseline
val_bpb: [FILL IN after first run]

## Directions to Explore
[What to try]

## Constraints
- TIME_BUDGET=300s (fixed)
- Peak VRAM must stay under [X] GB
- Do not modify prepare.py or constants.py
- No new packages (pyproject.toml is locked)
```

---

## Full Template with All Sections

```markdown
# Research Program

## Goal
Minimize val_bpb on FineWeb-Edu within the 300-second training budget.
Lower val_bpb is always better. Do not optimize for anything else.

## Current Baseline
val_bpb: 0.9979
Model: depth-12 GPT, Muon + AdamW optimizer, RoPE, SwiGLU
Hardware: H100 80GB

## Directions to Explore

### High Priority (try these first)
1. Attention variants: GQA (grouped-query), MLA (multi-head latent), sliding window
2. Layer types: MoE (mixture of experts) FFN, SwiGLU vs. GeGLU
3. Optimizer: Muon momentum values 0.90–0.98, AdamW β1/β2 grid
4. Normalization: RMSNorm vs. LayerNorm, pre-norm vs. post-norm

### Medium Priority
5. Learning rate schedule: cosine vs. linear warmup + decay ratios
6. Weight tying: tie embedding and output projection weights
7. Depth/width tradeoffs: same FLOP budget, different aspect ratios

### Low Priority / Exploratory
8. Positional encoding: ALiBi, T5-style relative, sinusoidal
9. Residual connection variants: pre-gate, scaled residuals

## What Has Been Tried (Do Not Repeat)
- Learned positional embeddings: worse than RoPE by ~0.008
- Depth-8 with wider hidden: worse than depth-12
- Pure AdamW (no Muon): worse by ~0.015

## Constraints
- Must complete in 300 seconds (TIME_BUDGET is fixed, do not change)
- Peak VRAM must stay under 39 GB
- Do not modify prepare.py, constants.py, or pyproject.toml
- Do not add new packages
- Each experiment should change ONE thing at a time (clean ablations)

## Notes
- depth-12 improvements transfer to depth-24 — focus on algorithms, not scale
- Previous session found SwiGLU activation reliably helps
```

---

## Writing Principles

### 1. Record the Current Baseline

Always include the current best `val_bpb` and what model configuration produced it. The agent needs this to decide whether a new experiment is an improvement.

```markdown
## Current Baseline
val_bpb: 0.9697
Model: depth-12, GQA (4 KV heads), SwiGLU, Muon lr=0.01
```

### 2. List What Has Been Tried

This prevents the agent from re-running experiments that already failed. Be specific.

```markdown
## What Has Been Tried
- GQA with 2 KV heads: DISCARD (val_bpb=0.981, worse than baseline)
- MoE with 8 experts: CRASH (OOM at MAX_SEQ_LEN=2048)
- cosine LR schedule: KEEP (val_bpb=0.971)
```

### 3. One Change at a Time

Instruct the agent to change ONE architectural component per experiment. Combined changes make it impossible to attribute improvements.

```markdown
## Constraints
- Each experiment must change exactly ONE component of train.py
- Do not combine architecture changes with optimizer changes
```

### 4. Specify VRAM Budget

The agent needs to know the GPU's headroom to avoid OOM crashes.

```markdown
## VRAM Constraint
Peak VRAM must stay under 38 GB.
If an experiment would exceed this, try reducing hidden_size by 20%
before abandoning the approach.
```

### 5. Prioritize Directions

An ordered list focuses the agent's first experiments on the most promising directions.

```markdown
## Exploration Priority
1. Attention: GQA (most likely to help, low risk)
2. Optimizer: Muon hyperparameters (easy, known to matter)
3. FFN: SwiGLU variants (medium risk)
4. Architecture: depth/width (expensive, do last)
```

---

## Updating program.md Between Sessions

After each session, update `program.md` with:

```markdown
## Session Log (append at bottom)

### Session 2026-03-11 (126 experiments, 18 improvements)
Best achieved: val_bpb=0.9697 (commit a3f2c91)
Top gains:
- SwiGLU activation: -0.012 (commit 8e2a1b3)
- GQA 4 KV heads: -0.009 (commit 5d7f9c2)
- Muon momentum 0.95: -0.006 (commit 2c8e4a1)

What to try next:
- MLA (multi-head latent attention) — not yet explored
- Mixture of Depths — promising from literature
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| No baseline recorded | Agent doesn't know what "improvement" means | Add `Current Baseline: val_bpb: X.XXXX` |
| Too vague ("try things") | Agent wastes experiments on random changes | List specific directions with priority order |
| No VRAM constraint | Agent causes OOM crashes | Add `Peak VRAM must stay under X GB` |
| Allowing multi-component changes | Can't attribute improvements | Add `Change exactly ONE component per experiment` |
| Never updating after sessions | Agent re-explores exhausted directions | Append session log after each run |
| Contradictory instructions | Agent gets confused | Review for internal consistency before each session |

---
name: autoresearch
description: >
  Autonomous ML experimentation framework by Andrej Karpathy. AI agent
  autonomously modifies train.py, runs 5-minute GPU experiments, evaluates with
  val_bpb, and commits only improvements via git ratcheting — so you wake up to
  100+ experiments and a better model. Use when setting up autoresearch,
  writing program.md directives, interpreting results, configuring hardware, or
  running overnight autonomous ML experiments. Triggers on: autoresearch,
  autonomous ml experiments, overnight gpu experiments, karpathy autoresearch,
  train.py experiments, val_bpb, program.md research directives, ai runs experiments.
allowed-tools: Bash Read Write Edit Glob Grep WebFetch
compatibility: >
  Requires NVIDIA GPU with 40GB+ VRAM (H100 recommended; community forks for
  GTX 1660 Ti 6GB, Apple Silicon MLX, Windows RTX). Linux with CUDA. Python 3.10+.
  uv package manager. Dataset: ~6543 FineWeb-Edu parquet shards (~2 min download).
metadata:
  tags: autoresearch, ml-experiments, autonomous-research, karpathy, gpu, train, val-bpb, overnight, ratcheting
  version: "1.0"
  source: https://github.com/karpathy/autoresearch
  license: MIT
---

# autoresearch

> *"The researcher's job shifts from writing Python to writing Markdown."* — Andrej Karpathy

Autoresearch is an autonomous ML experimentation framework. An AI agent iteratively modifies `train.py`, runs fixed 5-minute GPU experiments, evaluates with a single metric (`val_bpb`), and commits only improvements via git ratcheting. The result: wake up to 100+ experiments logged and a monotonically better model.

## When to use this skill

- Setting up autoresearch on a GPU machine for the first time
- Writing or refining `program.md` research directives for the agent
- Launching an overnight autonomous experiment loop
- Interpreting `results.tsv` to understand what the agent found
- Configuring the system for constrained hardware (limited VRAM)
- Understanding the ratcheting mechanism and git workflow
- Porting to Apple Silicon (MLX) or Windows RTX

## Core Architecture

```
Human authors program.md
       │
       ▼
Agent reads program.md + train.py
       │
       ▼
Agent modifies train.py → git commit
       │
       ▼
uv run train.py  (exactly 300 seconds)
       │
       ▼
Extract val_bpb + peak_vram_mb
       │
  ┌────┴────┐
improved?   no improvement
  │              │
keep commit   git reset HEAD~1
  │              │
  └──────┬───────┘
         │
   log to results.tsv
         │
         ▼
    repeat ∞
```

### Mutable vs. Immutable Files

| File | Agent access | Purpose |
|------|-------------|---------|
| `train.py` | **Read + Write** | Model, optimizer, training loop (~630 lines) |
| `program.md` | Read-only | Human research directives |
| `prepare.py` | Read-only | Data pipeline + `evaluate_bpb()` harness |
| `constants.py` | Read-only | `TIME_BUDGET=300`, `MAX_SEQ_LEN`, `EVAL_TOKENS` |
| `pyproject.toml` | Read-only | Locked dependencies (no new packages) |
| `results.tsv` | Append | All experiments: kept and discarded |

## Instructions

### Step 1: Install Prerequisites

```bash
# Install uv (fast Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Clone the repository
git clone https://github.com/karpathy/autoresearch
cd autoresearch

# Install locked dependencies
uv sync
```

### Step 2: Prepare Data (One-Time, ~2 Minutes)

```bash
# Downloads FineWeb-Edu parquet shards, trains BPE tokenizer
# Last shard is reserved for validation — never seen during training
uv run prepare.py
```

For constrained hardware, edit `prepare.py` before running:
```python
# Lower MAX_SEQ_LEN for GPUs with limited VRAM
MAX_SEQ_LEN = 256   # default: 2048
```

### Step 3: Run a Baseline Experiment

```bash
# Single 5-minute experiment to verify setup
uv run train.py > run.log 2>&1

# Extract key metrics
grep "^val_bpb:\|^peak_vram_mb:" run.log
```

Expected output:
```
val_bpb: 0.9979
peak_vram_mb: 38420
```

### Step 4: Author program.md

`program.md` is the human-written research charter the agent reads at the start of every loop iteration. Write it as precise Markdown instructions:

```markdown
# Research Program

## Goal
Minimize val_bpb on the FineWeb-Edu validation set within the 300-second budget.

## Current Baseline
val_bpb: 0.9979 (depth-12 GPT, Muon + AdamW optimizer)

## Directions to Explore
1. Attention variants: MLA, GQA, sliding window, local-global hybrid
2. Layer types: MoE FFN layers, SwiGLU activations
3. Optimizer tuning: Muon momentum, AdamW β values, learning rate schedule
4. Architectural depth/width tradeoffs within VRAM budget

## Constraints
- Must complete within 300 seconds
- Peak VRAM must stay under 39GB
- No new packages (use only what is in pyproject.toml)
- Do not modify prepare.py or constants.py

## Notes from Previous Runs
- Depth-12 improvements transfer to depth-24 (scale-invariant gains)
- RoPE positional encoding outperformed learned embeddings (+0.008 val_bpb)
```

**Effective program.md principles:**
- Be specific about what to explore — vague directives waste experiments
- Record what has already been tried (prevents redundant experiments)
- Note hardware constraints explicitly
- Use the current best `val_bpb` as a reference point

### Step 5: Run the Autonomous Agent Loop

Point your AI agent (Claude Code, Codex, etc.) at the repository with `program.md` as its research context. The agent will:

1. Read `program.md` + current `train.py`
2. Hypothesize an improvement
3. Modify `train.py` + commit
4. Execute `uv run train.py` (300 seconds)
5. Extract `val_bpb`; keep or revert via git
6. Append to `results.tsv`
7. Repeat

**With Claude Code (OMC):**
```bash
# From inside autoresearch/
# Give Claude the context: "Run the autoresearch loop following program.md"
```

**With Claude Code CLI directly:**
```bash
claude "Follow program.md. Run autonomous research loop on train.py.
Execute: uv run train.py, extract val_bpb, keep improvements, revert failures.
Log everything to results.tsv. Do not stop until I say so."
```

### Step 6: Monitor Results

```bash
# Live monitoring during a run
watch -n 30 "tail -20 results.tsv"

# Count kept vs. discarded
awk -F'\t' '{print $4}' results.tsv | sort | uniq -c

# Find the best experiment
sort -t$'\t' -k2 -n results.tsv | head -5

# Check current best val_bpb
git log --oneline -5
```

### Step 7: Interpret results.tsv

```
commit    val_bpb    memory_gb    status     description
a3f2c91   0.9697     37.2         keep       SwiGLU activation + depth-12
b8e1d04   0.9821     38.1         discard    MoE 4-expert: marginal gain
c1a5f30   crash      —            crash      OOM: sequence length 4096
```

| Status | Meaning |
|--------|---------|
| `keep` | `val_bpb` improved; commit retained on branch |
| `discard` | No improvement; `git reset HEAD~1` applied |
| `crash` | OOM, syntax error, or timeout; always reverted |

## Examples

### Example 1: Overnight Run Summary

```
Session summary: 126 experiments, 18 improvements
Best val_bpb: 0.9697 (started: 0.9979)
Top improvements:
- SwiGLU activation: -0.012 val_bpb
- GQA with 4 KV heads: -0.009 val_bpb
- Muon momentum 0.92→0.95: -0.006 val_bpb
```

### Example 2: Low-VRAM Configuration (6GB GPU)

```python
# In prepare.py — edit before uv run prepare.py
MAX_SEQ_LEN = 256       # was 2048
EVAL_TOKENS = 2_097_152  # was 20_971_520 (scale down proportionally)
```

### Example 3: Extract Experiments by Category

```bash
# Find all attention-related experiments
grep -i "attention\|GQA\|MLA\|MHA" results.tsv

# List only improvements sorted by gain
awk -F'\t' '$4=="keep"' results.tsv | sort -t$'\t' -k2 -n
```

## Available scripts

Run from inside the autoresearch repository directory:

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup.sh` | One-time environment setup | `bash scripts/setup.sh [--seq-len 512]` |
| `run-experiment.sh` | Single 5-min experiment + metric extraction | `bash scripts/run-experiment.sh` |
| `run-loop.sh` | Autonomous loop: run → keep/revert → repeat | `bash scripts/run-loop.sh [--max 20]` |
| `show-results.sh` | Human-readable results.tsv report | `bash scripts/show-results.sh [--top 10]` |
| `check-hardware.sh` | GPU/CUDA/uv availability check (JSON output) | `bash scripts/check-hardware.sh` |

```bash
# Typical overnight session
bash scripts/check-hardware.sh
bash scripts/setup.sh --seq-len 512     # adjust for your VRAM
# Edit program.md with your research directives
bash scripts/run-loop.sh --max 100 --desc "session-1"
bash scripts/show-results.sh --kept-only
```

## References

Detailed documentation in `references/`:

| File | Contents |
|------|---------|
| `references/architecture.md` | System design, immutability contract, git ratcheting, key design decisions |
| `references/program-md-guide.md` | How to write effective `program.md` directives; full template + principles |
| `references/hardware-config.md` | VRAM settings by GPU, memory optimization techniques, troubleshooting |

## Best practices

1. **Write program.md before running** — the agent is only as good as its directives; vague programs waste compute
2. **Start with the baseline first** — always `uv run train.py` manually before launching the loop to confirm the setup works
3. **Keep `MAX_SEQ_LEN` in `prepare.py` consistent** — changing it mid-run invalidates val_bpb comparisons
4. **Never modify `prepare.py` or `constants.py`** — the evaluation harness must stay fixed for results to be meaningful
5. **Scale improvements before committing** — test that a depth-12 improvement also holds at depth-24 before treating it as a fundamental gain
6. **Commit `program.md` updates** — version-control your research directives alongside `results.tsv` for reproducibility
7. **Monitor VRAM** — add `peak_vram_mb` constraints in `program.md` for your GPU's headroom
8. **No new dependencies** — the agent cannot `pip install`; it can only use what is in `pyproject.toml`

## Hardware Requirements

| Hardware | Status | Notes |
|----------|--------|-------|
| H100 80GB | Recommended | Default config, full MAX_SEQ_LEN=2048 |
| A100 40GB | Supported | Lower MAX_SEQ_LEN if needed |
| RTX 4090 24GB | Community | Reduce MAX_SEQ_LEN to 512 |
| GTX 1660 Ti 6GB | Community fork | MAX_SEQ_LEN=256, reduced EVAL_TOKENS |
| Apple Silicon (M-series) | MLX port | Community fork; different optimizer API |
| Windows RTX | Community | WSL2 + CUDA recommended |

## Key Metrics Reference

| Metric | Direction | Description |
|--------|-----------|-------------|
| `val_bpb` | Lower = better | Validation bits-per-byte; vocabulary-size-independent |
| `peak_vram_mb` | Lower = more headroom | Peak GPU memory during the training run |
| Experiments/hour | Higher = faster search | ~12 at TIME_BUDGET=300 |

## References

- [GitHub — karpathy/autoresearch](https://github.com/karpathy/autoresearch)
- [nanochat — the underlying LLM training framework](https://github.com/karpathy/nanochat)
- [Karpathy's original announcement (X/Twitter)](https://x.com/karpathy)
- [DeepWiki — autoresearch architecture](https://deepwiki.com/karpathy/autoresearch)
- [MIT License](https://github.com/karpathy/autoresearch/blob/master/LICENSE)

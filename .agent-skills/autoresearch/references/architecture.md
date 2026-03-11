# autoresearch Architecture Reference

Source: [karpathy/autoresearch](https://github.com/karpathy/autoresearch) · MIT License

---

## Overview

autoresearch is a closed-loop ML experimentation system. A human authors `program.md`; an AI agent reads it and autonomously modifies `train.py`, executes experiments, and commits only improvements — creating a monotonically improving research branch overnight.

---

## File Map

```
autoresearch/
├── train.py        ← Agent's ONLY editable file (~630 lines)
├── prepare.py      ← Immutable: data pipeline + evaluate_bpb()
├── constants.py    ← Immutable: TIME_BUDGET=300, MAX_SEQ_LEN, EVAL_TOKENS
├── program.md      ← Human-written research directives (agent reads this)
├── pyproject.toml  ← Locked dependencies (no new packages allowed)
└── results.tsv     ← Persistent experiment log (all runs)
```

### Immutability Contract

| File | Agent Access | Rationale |
|------|-------------|-----------|
| `train.py` | Read + Write | The search space — architecture, optimizer, hyperparameters |
| `prepare.py` | Read-only | Contains `evaluate_bpb()` — must never change for fair comparison |
| `constants.py` | Read-only | Hard budget constraints — changing them invalidates all comparisons |
| `program.md` | Read-only | Human's intent — agent follows, never modifies |
| `pyproject.toml` | Read-only | Locked deps — no `pip install` during search |
| `results.tsv` | Append-only | Monotonic experiment log — never delete rows |

---

## The Experiment Loop

```
┌─────────────────────────────────────────────────────────┐
│                    AGENT LOOP                           │
│                                                         │
│  1. Read program.md + current train.py                  │
│  2. Formulate hypothesis (architecture / optimizer)     │
│  3. Edit train.py → git commit                          │
│  4. uv run train.py      (exactly 300 seconds)          │
│  5. grep "^val_bpb:" run.log → extract metric           │
│                                                         │
│  ┌─── improved? ──────┐   ┌─── not improved? ──────┐   │
│  │  git commit stays  │   │  git reset HEAD~1       │   │
│  │  update baseline   │   │  baseline unchanged     │   │
│  └────────────────────┘   └─────────────────────────┘   │
│                                                         │
│  6. Append row to results.tsv                           │
│  7. Repeat from step 1                                  │
└─────────────────────────────────────────────────────────┘
```

---

## Key Design Decisions

### 1. Fixed 300-Second Budget

`TIME_BUDGET = 300` in `constants.py`. Every experiment runs for exactly 300 seconds wall-clock time regardless of GPU or model size.

**Why**: Ensures every row in `results.tsv` is directly comparable. A `val_bpb` of 0.97 in experiment 3 means the same thing as 0.97 in experiment 97.

**Throughput**: ~12 experiments/hour → ~100 experiments in an overnight session.

### 2. Immutable Evaluation Harness

`evaluate_bpb()` in `prepare.py` is never modified. It always evaluates on the same validation shard (the last FineWeb-Edu parquet file), with the same tokenizer, for `EVAL_TOKENS = 20,971,520` tokens.

**Why**: Without a fixed harness, a clever agent could modify the evaluation to make its model appear better — "metric hacking." The immutable harness prevents this.

### 3. Single Metric: val_bpb

Validation bits-per-byte (val_bpb) measures how many bits on average the model uses to predict each byte of validation text. Lower = better.

**Why val_bpb over perplexity**: val_bpb is vocabulary-size-independent. If the agent experiments with different tokenizers (different vocabulary sizes), perplexity scores would be incomparable; val_bpb remains a fair metric across all configurations.

### 4. Git Ratcheting

Every experiment is a git commit. On improvement: keep. On regression: `git reset HEAD~1`.

**Result**: The main branch is a clean, monotonically improving history of algorithmic discoveries.

**Side effect**: `results.tsv` retains the full record including all discarded experiments, providing a complete picture of the search.

### 5. Fits in Context Window

At ~630 lines, `train.py` fits within a modern LLM's context window. The agent always has the complete file in view — no partial reads, no retrieval augmentation needed.

---

## train.py Structure

The default `train.py` contains:

```
1. Imports and device setup
2. Hyperparameters (model, training, eval)
3. GPT model definition
   - Transformer blocks
   - Attention (default: multi-head)
   - FFN layers
   - Layer normalization
4. Optimizer setup (Muon + AdamW)
5. Training loop
   - Forward pass
   - Loss computation
   - Backward pass
   - Optimizer step
6. Evaluation call
7. Metric output: val_bpb, peak_vram_mb
```

**Agent's search space** (everything in `train.py` is fair game):
- Model architecture: depth, width, attention variants, FFN type
- Positional encoding: learned, RoPE, ALiBi, none
- Normalization: LayerNorm, RMSNorm, position
- Optimizer: learning rate, schedules, momentum values, weight decay
- Training: batch size, gradient accumulation, mixed precision

---

## results.tsv Format

```tsv
commit    val_bpb    peak_vram_mb    status     description
```

| Column | Type | Values |
|--------|------|--------|
| `commit` | string | 7-char git hash |
| `val_bpb` | float | Lower = better; `crash` if OOM/error |
| `peak_vram_mb` | integer | Peak GPU memory in MB |
| `status` | enum | `keep`, `discard`, `crash` |
| `description` | string | Free text summary of the change |

---

## Karpathy's Documented Results

From the original repo and public statements:

| Session | Experiments | Improvements | Start val_bpb | Best val_bpb |
|---------|-------------|--------------|---------------|--------------|
| Session 1 | 126 | 18 | 0.9979 | 0.9697 |
| Tobi Lütke (Shopify CEO) | 37 | ~19% gain | — | — |

**Key observation**: Improvements found on depth-12 transferred cleanly to depth-24, suggesting genuine algorithmic discoveries rather than overfitting to a particular scale.

---

## Platform Notes

autoresearch is designed for a **single NVIDIA GPU on Linux**. Community forks extend this:

| Platform | Status | Notes |
|----------|--------|-------|
| H100 80GB + Linux | Official | Default config |
| A100 40GB | Supported | May need MAX_SEQ_LEN reduction |
| RTX 4090 24GB | Community | MAX_SEQ_LEN ≤ 512 |
| GTX 1660 Ti 6GB | Community | MAX_SEQ_LEN=256, reduced EVAL_TOKENS |
| Apple Silicon (M-series) | MLX fork | Different optimizer API required |
| Windows | Community | WSL2 + CUDA recommended |

---

## What the Agent Should Never Do

1. Modify `prepare.py` or `constants.py` — breaks evaluation fairness
2. Change `TIME_BUDGET` — makes comparisons invalid
3. Add new packages via pip — `pyproject.toml` is locked
4. Delete rows from `results.tsv` — permanent record
5. Push to main before human review — results branch only

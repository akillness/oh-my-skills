# Hardware Configuration Reference

Configure autoresearch for your GPU. The key levers are `MAX_SEQ_LEN` in `prepare.py` and `EVAL_TOKENS` in `constants.py`.

> **Rule**: Never change these values mid-session. A session's `results.tsv` is only internally comparable if all rows use the same `MAX_SEQ_LEN` and `EVAL_TOKENS`.

---

## Recommended Settings by GPU

| GPU | VRAM | MAX_SEQ_LEN | EVAL_TOKENS | ~Experiments/hr | Notes |
|-----|------|-------------|-------------|-----------------|-------|
| H100 80GB | 80 GB | 2048 | 20,971,520 | ~12 | Default config |
| A100 80GB | 80 GB | 2048 | 20,971,520 | ~12 | Same as H100 |
| A100 40GB | 40 GB | 1024 | 10,485,760 | ~12 | Halve both |
| RTX 4090 | 24 GB | 512 | 5,242,880 | ~12 | Quarter both |
| RTX 3090 | 24 GB | 512 | 5,242,880 | ~12 | Same as 4090 |
| RTX 3080 Ti | 12 GB | 256 | 2,097,152 | ~12 | Eighth both |
| GTX 1660 Ti | 6 GB | 256 | 2,097,152 | slower | Community tested |
| Apple M-series | unified | — | — | — | MLX fork required |

> `EVAL_TOKENS` should scale proportionally with `MAX_SEQ_LEN` to maintain evaluation quality.

---

## How to Apply Settings

Edit `prepare.py` before running `uv run prepare.py` (one-time setup):

```python
# prepare.py — find and edit this line:
MAX_SEQ_LEN = 2048    # change to your value

# prepare.py — find and edit this line:
EVAL_TOKENS = 20_971_520    # change to your value
```

Or use the setup script with `--seq-len`:

```bash
bash scripts/setup.sh --seq-len 512
```

> The setup script automatically scales `EVAL_TOKENS` when it patches `prepare.py`.

---

## Checking Available VRAM

Before running any experiment:

```bash
# Live VRAM status
nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv

# Run the built-in check script
bash scripts/check-hardware.sh
```

---

## Memory Optimization Techniques (when at VRAM limit)

These can be added to `train.py` by the agent if VRAM is tight:

### 1. Gradient Checkpointing

Trades compute for memory — recomputes activations during backward pass instead of storing them.

```python
# In model's forward() call inside the training loop:
from torch.utils.checkpoint import checkpoint

output = checkpoint(block, x)  # instead of: output = block(x)
```

**Effect**: Reduces VRAM by ~30-40% at cost of ~20% slower training.

### 2. Mixed Precision (BF16)

Most modern GPUs support BF16 natively.

```python
# In training loop:
with torch.autocast(device_type='cuda', dtype=torch.bfloat16):
    logits = model(x)
```

**Effect**: ~40-50% VRAM reduction for activations.

### 3. Reduce Batch Size + Gradient Accumulation

```python
# Instead of batch_size=64:
batch_size = 16
accumulation_steps = 4  # equivalent effective batch size = 64
```

**Effect**: Linear VRAM reduction. Training unchanged if gradient accumulation compensates.

### 4. Reduce Model Depth Before Width

Depth scales VRAM more than width (intermediate activations). Try:

```python
n_layer = 8    # instead of 12
n_embd  = 768  # keep or increase slightly
```

---

## VRAM Estimation Formula

A rough estimate for transformer VRAM at training time:

```
VRAM_GB ≈ (parameters × 4 bytes)              # model weights (fp32)
         + (parameters × 4 bytes)             # gradients
         + (parameters × 8 bytes)             # optimizer state (AdamW = 2× fp32)
         + (batch × seq_len × hidden × layers × 4)  # activations (fp32)
```

For a depth-12, hidden-768, MAX_SEQ_LEN=2048, batch=32 model:
- Parameters: ~85M × 16 bytes = ~1.4 GB
- Activations: 32 × 2048 × 768 × 12 × 4 bytes ≈ ~24 GB
- **Total: ~26 GB** (fits on A100 40GB, tight on RTX 4090 24GB)

With BF16 activations: activations halved → **~14 GB total**.

---

## Apple Silicon (MLX) Setup

The official repo requires NVIDIA CUDA. Community MLX port:

```bash
# Clone MLX fork (community maintained)
git clone https://github.com/[community-fork]/autoresearch-mlx
cd autoresearch-mlx

# Install mlx
pip install mlx mlx-lm

# Setup and run
python prepare_mlx.py
python train_mlx.py
```

> Note: MLX uses different optimizer APIs and may have different architectural constraints. `results.tsv` values from MLX runs are NOT comparable to CUDA runs.

---

## Multi-GPU Notes

autoresearch is designed for **single-GPU** training. The 300-second budget and `evaluate_bpb()` assume a single device.

For multi-GPU:
- Do NOT use `DistributedDataParallel` in experiments (changes training dynamics)
- `torch.nn.DataParallel` can be used as a workaround but introduces overhead
- Results from multi-GPU runs may not be comparable to single-GPU baseline

If you have multiple GPUs, run **parallel independent autoresearch sessions** on different GPUs with different `program.md` research directions — then merge insights.

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| OOM crash immediately | MAX_SEQ_LEN too large | Halve MAX_SEQ_LEN and re-run prepare.py |
| OOM mid-training | Model too large for seq len | Reduce n_layer or n_embd |
| val_bpb = nan | Learning rate too high | Reduce max_lr by 10× |
| All experiments crash | CUDA not available to PyTorch | Check `nvidia-smi` + `uv run python -c "import torch; print(torch.cuda.is_available())"` |
| Very slow training | CPU fallback active | Confirm CUDA available; check `torch.cuda.current_device()` |
| prepare.py takes forever | Network slow / many shards | Set `MAX_SHARDS=100` in prepare.py for a smaller dataset |

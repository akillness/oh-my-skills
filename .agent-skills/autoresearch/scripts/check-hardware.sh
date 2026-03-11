#!/usr/bin/env bash
# check-hardware.sh — Verify GPU setup for autoresearch
# Checks NVIDIA GPU, CUDA, VRAM, Python, and uv availability
#
# Usage:
#   bash scripts/check-hardware.sh
#
# Output:
#   JSON to stdout with fields: gpu_name, vram_mb, cuda_version, python_ok, uv_ok, ready
#   Human-readable summary to stderr
#
# Exit codes:
#   0  All required checks pass
#   1  Missing required components (no GPU, no CUDA, no uv)

set -uo pipefail

log()  { echo "[check-hardware] $*" >&2; }
warn() { echo "[check-hardware] WARN:  $*" >&2; }
err()  { echo "[check-hardware] ERROR: $*" >&2; }

GPU_NAME="none"
VRAM_MB=0
CUDA_VERSION="none"
PYTHON_OK=0
UV_OK=0
READY=1

# ── NVIDIA GPU ────────────────────────────────────────────────────────────────
if command -v nvidia-smi &>/dev/null; then
  GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 | xargs || echo "unknown")
  VRAM_MB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1 | xargs || echo "0")
  CUDA_VERSION=$(nvidia-smi | grep "CUDA Version" | awk '{print $NF}' | head -1 || echo "unknown")
  log "GPU: ${GPU_NAME} | VRAM: ${VRAM_MB} MB | CUDA: ${CUDA_VERSION}"
else
  warn "nvidia-smi not found — no NVIDIA GPU detected"
  READY=0
fi

# VRAM check: autoresearch default requires ~38-40GB for MAX_SEQ_LEN=2048
if [[ "${VRAM_MB}" -gt 0 ]]; then
  if [[ "${VRAM_MB}" -ge 39000 ]]; then
    log "VRAM: ${VRAM_MB} MB — sufficient for default config (MAX_SEQ_LEN=2048)"
  elif [[ "${VRAM_MB}" -ge 20000 ]]; then
    warn "VRAM: ${VRAM_MB} MB — reduce MAX_SEQ_LEN to 512 or lower in prepare.py"
  elif [[ "${VRAM_MB}" -ge 6000 ]]; then
    warn "VRAM: ${VRAM_MB} MB — low-VRAM mode: set MAX_SEQ_LEN=256 in prepare.py"
  else
    err "VRAM: ${VRAM_MB} MB — insufficient (minimum ~6GB required)"
    READY=0
  fi
fi

# ── Python ────────────────────────────────────────────────────────────────────
if command -v python3 &>/dev/null; then
  PY_VER=$(python3 --version 2>&1 | awk '{print $2}')
  log "Python: ${PY_VER}"
  PYTHON_OK=1
else
  warn "python3 not found"
fi

# ── uv ────────────────────────────────────────────────────────────────────────
if command -v uv &>/dev/null; then
  UV_VER=$(uv --version 2>&1 | head -1)
  log "uv: ${UV_VER}"
  UV_OK=1
else
  warn "uv not found — run: curl -LsSf https://astral.sh/uv/install.sh | sh"
  READY=0
fi

# ── PyTorch CUDA check (if in autoresearch repo) ──────────────────────────────
if [[ -f "train.py" ]] && command -v uv &>/dev/null; then
  TORCH_CUDA=$(uv run python3 -c "import torch; print(torch.cuda.is_available())" 2>/dev/null || echo "unknown")
  log "torch.cuda.is_available(): ${TORCH_CUDA}"
  if [[ "${TORCH_CUDA}" == "False" ]]; then
    warn "PyTorch cannot see CUDA. Check CUDA drivers and pytorch install."
    READY=0
  fi
fi

# ── Structured JSON output (stdout) ──────────────────────────────────────────
cat <<JSON
{
  "gpu_name": "${GPU_NAME}",
  "vram_mb": ${VRAM_MB},
  "cuda_version": "${CUDA_VERSION}",
  "python_ok": ${PYTHON_OK},
  "uv_ok": ${UV_OK},
  "ready": ${READY}
}
JSON

# ── Exit with appropriate code ────────────────────────────────────────────────
if [[ "${READY}" -eq 1 ]]; then
  log "All checks passed — ready for autoresearch"
else
  err "One or more checks failed — fix the issues above before running experiments"
  exit 1
fi

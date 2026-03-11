#!/usr/bin/env python3
"""JEO Claude plan gate wrapper.

Wraps the Claude Code ExitPlanMode hook so JEO can skip redundant plannotator
launches when the current plan content has already been reviewed.
"""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any


SKIP_STATUSES = {"approved", "manual_approved", "feedback_required", "infrastructure_blocked"}


def git_root() -> Path:
    try:
        return Path(
            subprocess.check_output(
                ["git", "rev-parse", "--show-toplevel"],
                stderr=subprocess.DEVNULL,
                text=True,
            ).strip()
        )
    except Exception:
        return Path.cwd()


def state_path(root: Path) -> Path:
    return root / ".omc" / "state" / "jeo-state.json"


def load_state(root: Path) -> dict[str, Any]:
    path = state_path(root)
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def save_state(root: Path, state: dict[str, Any]) -> None:
    path = state_path(root)
    if not path.parent.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(state, ensure_ascii=False, indent=2), encoding="utf-8")


def find_plan_text(root: Path, payload: str) -> str:
    for candidate in (
        root / ".omc" / "plans" / "jeo-plan.md",
        root / "plan.md",
        root / "docs" / "plan.md",
    ):
        if candidate.exists():
            try:
                return candidate.read_text(encoding="utf-8")
            except Exception:
                continue

    try:
        data = json.loads(payload)
    except Exception:
        return ""

    tool_input = data.get("tool_input", {})
    if isinstance(tool_input, dict):
        plan = tool_input.get("plan")
        if isinstance(plan, str):
            return plan
    return ""


def plan_hash(plan_text: str) -> str:
    if not plan_text:
        return ""
    return hashlib.sha256(plan_text.encode("utf-8")).hexdigest()


def should_skip(state: dict[str, Any], current_hash: str) -> bool:
    if state.get("phase") != "plan":
        return False

    gate_status = state.get("plan_gate_status")
    last_hash = state.get("last_reviewed_plan_hash")
    return bool(current_hash and gate_status in SKIP_STATUSES and last_hash == current_hash)


def reset_for_revised_plan(root: Path, state: dict[str, Any], current_hash: str) -> None:
    last_hash = state.get("last_reviewed_plan_hash")
    if not current_hash or current_hash == last_hash:
        return

    if state.get("plan_gate_status") in SKIP_STATUSES:
        state["plan_gate_status"] = "pending"
        state["plan_approved"] = False
        state["plan_current_hash"] = current_hash
        state["updated_at"] = subprocess.check_output(
            ["python3", "-c", "import datetime;print(datetime.datetime.utcnow().isoformat()+\"Z\")"],
            text=True,
        ).strip()
        save_state(root, state)


def run_plannotator(payload: str) -> int:
    proc = subprocess.run(["plannotator"], input=payload, text=True)
    return proc.returncode


def main() -> int:
    payload = sys.stdin.read()
    root = git_root()
    state = load_state(root)
    current_hash = plan_hash(find_plan_text(root, payload))

    if should_skip(state, current_hash):
        status = state.get("plan_gate_status", "unknown")
        print(
            f"[JEO][PLAN] Claude hook skipped: plan gate already recorded for current hash ({status}).",
            file=sys.stderr,
        )
        return 0

    reset_for_revised_plan(root, state, current_hash)
    return run_plannotator(payload)


if __name__ == "__main__":
    raise SystemExit(main())

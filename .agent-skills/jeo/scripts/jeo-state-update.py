#!/usr/bin/env python3
"""JEO state file updater — single entry point for checkpoint, error, and resume operations.

Usage:
  python3 scripts/jeo-state-update.py checkpoint <phase>
  python3 scripts/jeo-state-update.py error "<message>"
  python3 scripts/jeo-state-update.py resume
  python3 scripts/jeo-state-update.py set <key> <value>
  python3 scripts/jeo-state-update.py init "<task>"
"""
import json, datetime, os, subprocess, sys, fcntl

def get_state_path():
    try:
        root = subprocess.check_output(
            ['git', 'rev-parse', '--show-toplevel'],
            stderr=subprocess.DEVNULL
        ).decode().strip()
    except Exception:
        root = os.getcwd()
    return os.path.join(root, '.omc/state/jeo-state.json')

def read_state(path):
    if os.path.exists(path):
        with open(path) as f:
            return json.load(f)
    return None

def write_state(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'r+' if os.path.exists(path) else 'w') as fh:
        fcntl.flock(fh, fcntl.LOCK_EX)
        try:
            fh.seek(0)
            json.dump(data, fh, ensure_ascii=False, indent=2)
            fh.truncate()
        finally:
            fcntl.flock(fh, fcntl.LOCK_UN)

def now_iso():
    return datetime.datetime.utcnow().isoformat() + 'Z'

def init_state(task):
    return {
        "phase": "plan",
        "task": task,
        "plan_approved": False,
        "plan_gate_status": "pending",
        "plan_current_hash": None,
        "last_reviewed_plan_hash": None,
        "last_reviewed_plan_at": None,
        "plan_review_method": None,
        "team_available": None,
        "retry_count": 0,
        "last_error": None,
        "checkpoint": None,
        "created_at": now_iso(),
        "updated_at": now_iso(),
        "agentation": {
            "active": False,
            "session_id": None,
            "keyword_used": None,
            "submit_gate_status": "idle",
            "submit_signal": None,
            "submit_received_at": None,
            "submitted_annotation_count": 0,
            "started_at": None,
            "timeout_seconds": 120,
            "annotations": {"total": 0, "acknowledged": 0, "resolved": 0, "dismissed": 0, "pending": 0},
            "completed_at": None,
            "exit_reason": None
        }
    }

def main():
    if len(sys.argv) < 2:
        print("Usage: jeo-state-update.py <command> [args]", file=sys.stderr)
        sys.exit(1)

    cmd = sys.argv[1]
    path = get_state_path()

    if cmd == "init":
        task = sys.argv[2] if len(sys.argv) > 2 else ""
        os.makedirs(os.path.dirname(path), exist_ok=True)
        if os.path.exists(path):
            state = read_state(path)
            cp = state.get('checkpoint')
            err = state.get('last_error')
            rc = state.get('retry_count', 0)
            if cp:
                print(f"Resuming from: {cp}")
            if err:
                print(f"Previous error ({rc} time(s)): {err}")
            if rc >= 3:
                print("WARNING: Retry count >= 3 — user confirmation required")
        else:
            write_state(path, init_state(task))
            print(f"JEO state initialized: {path}")

    elif cmd == "checkpoint":
        phase = sys.argv[2] if len(sys.argv) > 2 else "plan"
        state = read_state(path)
        if state:
            state['checkpoint'] = phase
            state['updated_at'] = now_iso()
            write_state(path, state)

    elif cmd == "error":
        msg = sys.argv[2] if len(sys.argv) > 2 else "unknown error"
        state = read_state(path)
        if state:
            state['last_error'] = msg
            state['retry_count'] = state.get('retry_count', 0) + 1
            state['updated_at'] = now_iso()
            write_state(path, state)
            if state['retry_count'] >= 3:
                print("WARNING: Retry count >= 3 — user confirmation required")

    elif cmd == "resume":
        state = read_state(path)
        if state:
            cp = state.get('checkpoint')
            err = state.get('last_error')
            rc = state.get('retry_count', 0)
            print(f"Resume from: {cp or 'beginning'}")
            if err:
                print(f"Previous error ({rc} time(s)): {err}")
            if rc >= 3:
                print("WARNING: Retry count >= 3 — user confirmation required")
        else:
            print("No state file found")

    elif cmd == "set":
        if len(sys.argv) < 4:
            print("Usage: jeo-state-update.py set <key> <value>", file=sys.stderr)
            sys.exit(1)
        key, value = sys.argv[2], sys.argv[3]
        state = read_state(path)
        if state:
            # Handle nested keys like agentation.active
            if '.' in key:
                parts = key.split('.')
                obj = state
                for p in parts[:-1]:
                    obj = obj.setdefault(p, {})
                # Auto-convert types
                if value.lower() in ('true', 'false'):
                    value = value.lower() == 'true'
                elif value.isdigit():
                    value = int(value)
                elif value == 'null':
                    value = None
                obj[parts[-1]] = value
            else:
                if value.lower() in ('true', 'false'):
                    value = value.lower() == 'true'
                elif value.isdigit():
                    value = int(value)
                elif value == 'null':
                    value = None
                state[key] = value
            state['updated_at'] = now_iso()
            write_state(path, state)

    else:
        print(f"Unknown command: {cmd}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()

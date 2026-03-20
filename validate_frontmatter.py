#!/usr/bin/env python3
"""Validate SKILL.md files against AgentSkills.io specification."""

import os
import re
import sys
from pathlib import Path


def resolve_skills_dir() -> Path:
    env_dir = os.environ.get("SKILLS_DIR")
    if env_dir:
        return Path(env_dir).expanduser()
    return Path(__file__).resolve().parent / ".agent-skills"


SKILLS_DIR = resolve_skills_dir()

ALLOWED_TOP_KEYS = {'name', 'description', 'license', 'compatibility', 'metadata', 'allowed-tools'}
NAME_RE = re.compile(r'^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$')
CONSEC_HYPHEN_RE = re.compile(r'--')

FORBIDDEN_TOP_KEYS = {
    'tags', 'platforms', 'keyword', 'version', 'source',
    'auto-apply', 'verified', 'verified-with', 'author',
}


def parse_frontmatter(content: str):
    if not content.startswith('---'):
        return None
    end = content.find('\n---', 3)
    if end == -1:
        return None
    return content[3:end].strip()


def check_skill(skill_dir: Path) -> list[str]:
    """Return list of violation strings (empty = OK)."""
    skill_file = skill_dir / 'SKILL.md'
    if not skill_file.exists():
        return ['MISSING SKILL.md']

    content = skill_file.read_text(encoding='utf-8')
    fm_str = parse_frontmatter(content)
    if fm_str is None:
        return ['No YAML frontmatter found']

    violations = []
    dir_name = skill_dir.name

    # Parse top-level keys
    top_keys = set()
    name_val = None
    desc_val = None
    allowed_tools_val = None
    compatibility_val = None

    for line in fm_str.split('\n'):
        m = re.match(r'^(\w[\w-]*)\s*:\s*(.*)', line)
        if m:
            key = m.group(1)
            val = m.group(2).strip()
            top_keys.add(key)
            if key == 'name':
                name_val = val.strip('"').strip("'")
            elif key == 'description':
                desc_val = val.strip('"').strip("'")
            elif key == 'allowed-tools':
                allowed_tools_val = val
            elif key == 'compatibility':
                compatibility_val = val.strip('"').strip("'")

    # Check for forbidden top-level keys
    bad_keys = top_keys & FORBIDDEN_TOP_KEYS
    if bad_keys:
        violations.append(f"Non-standard top-level keys: {sorted(bad_keys)}")

    # Check for unexpected keys
    extra = top_keys - ALLOWED_TOP_KEYS
    if extra:
        violations.append(f"Unknown top-level keys: {sorted(extra)}")

    # Check name
    if name_val is None:
        violations.append("Missing 'name' field")
    else:
        if name_val != dir_name:
            violations.append(f"name '{name_val}' ≠ directory '{dir_name}'")
        if not NAME_RE.match(name_val):
            violations.append(f"name '{name_val}' contains invalid chars")
        if CONSEC_HYPHEN_RE.search(name_val):
            violations.append(f"name '{name_val}' has consecutive hyphens")
        if len(name_val) > 64:
            violations.append(f"name too long ({len(name_val)} > 64)")

    # Check description
    if desc_val is None:
        violations.append("Missing 'description' field")
    elif len(desc_val) > 1024:
        violations.append(f"description too long ({len(desc_val)} > 1024 chars)")

    # Check allowed-tools (must NOT be array)
    if allowed_tools_val is not None:
        stripped = allowed_tools_val.strip()
        if stripped.startswith('['):
            violations.append(f"allowed-tools must be space-delimited, not array: {stripped!r}")

    # Check compatibility length
    if compatibility_val and len(compatibility_val) > 500:
        violations.append(f"compatibility too long ({len(compatibility_val)} > 500 chars)")

    return violations


def main():
    if not SKILLS_DIR.exists():
        print(f"ERROR: {SKILLS_DIR} not found", file=sys.stderr)
        sys.exit(1)

    skill_dirs = sorted(
        d for d in SKILLS_DIR.iterdir()
        if d.is_dir() and not d.name.startswith('.') and not d.name.startswith('__')
    )

    print(f"Validating {len(skill_dirs)} skills...\n")

    all_ok = True
    passed = 0
    failed = 0

    for skill_dir in skill_dirs:
        violations = check_skill(skill_dir)
        if violations:
            failed += 1
            all_ok = False
            print(f"❌ FAIL  {skill_dir.name}")
            for v in violations:
                print(f"        • {v}")
        else:
            passed += 1
            print(f"✅ PASS  {skill_dir.name}")

    print(f"\n{'='*60}")
    print(f"RESULT: {passed}/{len(skill_dirs)} passed")
    if not all_ok:
        print("Some skills have violations.")
        sys.exit(1)
    else:
        print("All skills comply with AgentSkills.io specification.")


if __name__ == '__main__':
    main()

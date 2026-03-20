#!/usr/bin/env python3
"""Validate or sync catalog counts across manifest, TOON catalog, and docs."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent
SKILLS_DIR = REPO_ROOT / ".agent-skills"
SKILLS_JSON = SKILLS_DIR / "skills.json"
SKILLS_TOON = SKILLS_DIR / "skills.toon"
README_MD = REPO_ROOT / "README.md"
README_KO = REPO_ROOT / "README.ko.md"
SETUP_PROMPT = REPO_ROOT / "setup-all-skills-prompt.md"


def count_local_skills() -> int:
    return sum(1 for path in SKILLS_DIR.iterdir() if path.is_dir() and (path / "SKILL.md").exists())


def load_manifest() -> dict:
    return json.loads(SKILLS_JSON.read_text(encoding="utf-8"))


def render_toon_manifest(skills: list[dict]) -> str:
    lines = [
        "# Skills Manifest (TOON Format)",
        f"# Count: {len(skills)}",
        "# Fields: N=name, D=description, T=tools, P=path, G=tags, F=platforms",
        "",
    ]

    for skill in skills:
        name = skill["name"]
        description = str(skill.get("description", "")).replace('"', "'").replace("\n", " ").strip()
        path = str(skill.get("path", "")).replace("/SKILL.md", "")
        tags = "|".join(str(tag).replace("|", "/") for tag in skill.get("tags", []))
        platforms = "|".join(str(platform).replace("|", "/") for platform in skill.get("platforms", []))
        tools = "|".join(str(tool).replace("|", "/") for tool in skill.get("allowed_tools", []))

        parts = [f"N:{name}", f'D:"{description}"']
        if tools:
            parts.append(f"T:{tools}")
        if path:
            parts.append(f"P:{path}")
        if tags:
            parts.append(f"G:{tags}")
        if platforms:
            parts.append(f"F:{platforms}")
        lines.append(" ".join(parts))

    return "\n".join(lines) + "\n"


def rewrite_readme(text: str, total: int, local: int, external: int, korean: bool) -> str:
    badge = f"Skills-{total}-blue"
    if korean:
        hero = f"**{total}개 AI 에이전트 스킬 · TOON 포맷 · 멀티플랫폼**"
        summary = f"Agent Skills는 LLM 기반 개발 워크플로우를 위한 {total}개 AI 에이전트 스킬 컬렉션입니다."
        manifest = (
            f"> 전체 매니페스트: `.agent-skills/skills.json` · 각 폴더의 `SKILL.md` · "
            f"{local}개 로컬 스킬 폴더"
        )
        tree = f"├── .agent-skills/          ← {local}개 스킬 폴더 (각각 SKILL.md + SKILL.toon)"
        if external:
            manifest += f" + 외부 {external}개 = 총 {total}개 설치 가능 스킬"
        else:
            manifest += f" = 총 {total}개 설치 가능 스킬"
    else:
        hero = f"**{total} AI agent skills · TOON Format · Cross-platform**"
        summary = f"Agent Skills is a curated collection of {total} AI agent skills for LLM-based development workflows."
        manifest = (
            f"> Full manifest: `.agent-skills/skills.json` · each folder's `SKILL.md` · "
            f"{local} local skill folders"
        )
        tree = f"├── .agent-skills/          ← {local} skill folders (each with SKILL.md + SKILL.toon)"
        if external:
            manifest += f" + {external} external = {total} total installable skills"
        else:
            manifest += f" = {total} total installable skills"

    text = re.sub(r"Skills-\d+-blue", badge, text)
    if korean:
        text = re.sub(r"\*\*\d+개 AI 에이전트 스킬 · TOON 포맷 · 멀티플랫폼\*\*", hero, text)
        text = re.sub(
            r"Agent Skills는 LLM 기반 개발 워크플로우를 위한 \d+개 AI 에이전트 스킬 컬렉션입니다\.",
            summary,
            text,
        )
        text = re.sub(r"^> 전체 매니페스트: .*$", manifest, text, flags=re.MULTILINE)
        text = re.sub(r"^├── \.agent-skills/\s+← \d+개 스킬 폴더 \(각각 SKILL\.md \+ SKILL\.toon\)$", tree, text, flags=re.MULTILINE)
    else:
        text = re.sub(r"\*\*\d+ AI agent skills · TOON Format · Cross-platform\*\*", hero, text)
        text = re.sub(
            r"Agent Skills is a curated collection of \d+ AI agent skills for LLM-based development workflows\.",
            summary,
            text,
        )
        text = re.sub(r"^> Full manifest: .*$", manifest, text, flags=re.MULTILINE)
        text = re.sub(r"^├── \.agent-skills/\s+← \d+ skill folders \(each with SKILL\.md \+ SKILL\.toon\)$", tree, text, flags=re.MULTILINE)
    return text


def rewrite_setup_prompt(text: str, total: int, local: int, external: int) -> str:
    if external:
        title = f"### Step 2: Full Installation ({local} repo skills + {external} external = {total} total)"
        note = (
            f"> **Installs or updates {local} in-repo skills plus {external} external skill"
            f"{'s' if external != 1 else ''} = {total} total. Existing skills are overwritten with the latest version. "
            "Skills not in this list are preserved.**"
        )
    else:
        title = f"### Step 2: Full Installation ({local} repo skills = {total} total)"
        note = (
            f"> **Installs or updates all {local} in-repo skills = {total} total. Existing skills are overwritten "
            "with the latest version. Skills not in this list are preserved.**"
        )

    text = re.sub(r"^### Step 2: .*$", title, text, flags=re.MULTILINE)
    text = re.sub(r"^> \*\*Installs or updates.*\*\*$", note, text, flags=re.MULTILINE)
    return text


def validate_or_sync(write: bool) -> int:
    manifest = load_manifest()
    skills = manifest.get("skills", [])
    local_count = count_local_skills()
    manifest_count = len(skills)
    external_count = max(manifest_count - local_count, 0)

    expected_toon = render_toon_manifest(skills)
    actual_toon = SKILLS_TOON.read_text(encoding="utf-8")

    readme_md_expected = rewrite_readme(
        README_MD.read_text(encoding="utf-8"), manifest_count, local_count, external_count, korean=False
    )
    readme_ko_expected = rewrite_readme(
        README_KO.read_text(encoding="utf-8"), manifest_count, local_count, external_count, korean=True
    )
    setup_expected = rewrite_setup_prompt(
        SETUP_PROMPT.read_text(encoding="utf-8"), manifest_count, local_count, external_count
    )

    mismatch_messages = []
    if manifest.get("skill_count") != manifest_count:
        mismatch_messages.append(
            f"skills.json skill_count={manifest.get('skill_count')} but actual skills array={manifest_count}"
        )
        if write:
            manifest["skill_count"] = manifest_count
            SKILLS_JSON.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    toon_entry_count = sum(1 for line in actual_toon.splitlines() if line.startswith("N:"))
    if toon_entry_count != manifest_count or actual_toon != expected_toon:
        mismatch_messages.append(
            f"skills.toon drift detected (entries={toon_entry_count}, expected={manifest_count})"
        )
        if write:
            SKILLS_TOON.write_text(expected_toon, encoding="utf-8")

    if README_MD.read_text(encoding="utf-8") != readme_md_expected:
        mismatch_messages.append("README.md count text drift detected")
        if write:
            README_MD.write_text(readme_md_expected, encoding="utf-8")

    if README_KO.read_text(encoding="utf-8") != readme_ko_expected:
        mismatch_messages.append("README.ko.md count text drift detected")
        if write:
            README_KO.write_text(readme_ko_expected, encoding="utf-8")

    if SETUP_PROMPT.read_text(encoding="utf-8") != setup_expected:
        mismatch_messages.append("setup-all-skills-prompt.md count text drift detected")
        if write:
            SETUP_PROMPT.write_text(setup_expected, encoding="utf-8")

    print("CATALOG SYNC STATUS")
    print("=" * 60)
    print(f"Local skill folders : {local_count}")
    print(f"Manifest skills     : {manifest_count}")
    print(f"External skills     : {external_count}")
    print(f"skills.toon entries : {toon_entry_count if not write else manifest_count}")

    if mismatch_messages:
        print("\nDetected drift:")
        for msg in mismatch_messages:
            print(f"  - {msg}")
        if write:
            print("\nCatalog sync updated.")
            return 0
        return 1

    print("\nCatalog sync OK.")
    return 0


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate or sync oh-my-skills catalog counts.")
    parser.add_argument("--write", action="store_true", help="Rewrite drifted generated files and count text")
    args = parser.parse_args()
    sys.exit(validate_or_sync(write=args.write))


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Skill Query Handler for MCP Integration (gemini-cli, codex-cli)

This script discovers skills from the shipped manifest/filesystem, matches user
queries to skills, and emits prompts optimized for the requested format.

Modes:
    full    - Full SKILL.md
    compact - SKILL.compact.md
    toon    - SKILL.toon

Usage:
    python skill-query-handler.py query "Design a REST API" --mode compact
    python skill-query-handler.py query "Review this code" --tool gemini --mode toon
    python skill-query-handler.py list --mode compact
    python skill-query-handler.py match "database schema"
    python skill-query-handler.py stats
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple


MODE_FILES = {
    "full": "SKILL.md",
    "compact": "SKILL.compact.md",
    "toon": "SKILL.toon",
}

MODE_FALLBACK = {
    "toon": ["SKILL.toon", "SKILL.compact.md", "SKILL.md"],
    "compact": ["SKILL.compact.md", "SKILL.md"],
    "full": ["SKILL.md"],
}

STOPWORDS = {
    "a",
    "all",
    "an",
    "and",
    "app",
    "application",
    "for",
    "from",
    "how",
    "in",
    "is",
    "it",
    "of",
    "on",
    "or",
    "the",
    "this",
    "to",
    "use",
    "when",
    "with",
}


def normalize_text(text: str) -> str:
    return re.sub(r"\s+", " ", text.lower().replace("_", " ").strip())


def tokenize(text: str) -> List[str]:
    normalized = normalize_text(text).replace("-", " ")
    return [tok for tok in re.split(r"[^a-z0-9가-힣+.#]+", normalized) if tok]


class SkillQueryHandler:
    def __init__(self, skills_dir: Optional[str] = None):
        self.skills_dir = Path(skills_dir).expanduser() if skills_dir else Path(__file__).parent
        self.global_skills_dir = Path.home() / ".agent-skills"
        self.skill_catalog = self._load_skill_catalog()

    def _resolve_skill_base_path(self, skill_path: str) -> List[Path]:
        input_path = Path(skill_path).expanduser()

        if input_path.is_absolute():
            if input_path.suffix:
                return [input_path.parent]
            return [input_path]

        return [
            self.skills_dir / input_path,
            self.global_skills_dir / input_path,
        ]

    def _candidate_manifest_paths(self) -> List[Path]:
        return [
            self.skills_dir / "skills.json",
            self.global_skills_dir / "skills.json",
        ]

    def _load_skill_catalog(self) -> Dict[str, Dict]:
        for manifest_path in self._candidate_manifest_paths():
            if not manifest_path.exists():
                continue
            try:
                data = json.loads(manifest_path.read_text(encoding="utf-8"))
            except json.JSONDecodeError:
                continue
            catalog = self._catalog_from_manifest(data)
            if catalog:
                return catalog
        return self._catalog_from_filesystem()

    def _catalog_from_manifest(self, data: Dict) -> Dict[str, Dict]:
        catalog: Dict[str, Dict] = {}
        for entry in data.get("skills", []):
            name = str(entry.get("name", "")).strip()
            if not name:
                continue
            skill_dir = self.skills_dir / name
            if not skill_dir.exists():
                continue

            description = str(entry.get("description", "")).strip()
            tags = [str(tag).strip() for tag in entry.get("tags", []) if str(tag).strip()]
            search_terms = self._build_search_terms(name, description, tags, entry)
            catalog[name] = {
                "name": name,
                "description": description,
                "tags": tags,
                "search_terms": search_terms,
                "description_tokens": set(
                    tok for tok in tokenize(description) if tok not in STOPWORDS
                ),
            }
        return catalog

    def _catalog_from_filesystem(self) -> Dict[str, Dict]:
        catalog: Dict[str, Dict] = {}
        for skill_md in sorted(self.skills_dir.glob("*/SKILL.md")):
            frontmatter = self._parse_frontmatter(skill_md.read_text(encoding="utf-8"))
            if not frontmatter:
                continue
            name = frontmatter.get("name") or skill_md.parent.name
            description = frontmatter.get("description", "")
            tags = frontmatter.get("tags", [])
            search_terms = self._build_search_terms(name, description, tags, {})
            catalog[name] = {
                "name": name,
                "description": description,
                "tags": tags,
                "search_terms": search_terms,
                "description_tokens": set(
                    tok for tok in tokenize(description) if tok not in STOPWORDS
                ),
            }
        return catalog

    def _parse_frontmatter(self, content: str) -> Dict[str, object]:
        if not content.startswith("---"):
            return {}
        parts = content.split("---", 2)
        if len(parts) < 3:
            return {}

        frontmatter: Dict[str, object] = {}
        current_key: Optional[str] = None
        for raw_line in parts[1].splitlines():
            line = raw_line.rstrip()
            match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
            if match:
                current_key = match.group(1)
                value = match.group(2).strip()
                if current_key == "description" and value in {">", "|"}:
                    frontmatter[current_key] = ""
                    continue
                if current_key == "metadata":
                    frontmatter[current_key] = {}
                    continue
                if current_key == "allowed-tools":
                    frontmatter["allowed-tools"] = value.split() if value else []
                    continue
                frontmatter[current_key] = value.strip('"').strip("'")
                continue

            if current_key == "description" and line.startswith("  "):
                existing = str(frontmatter.get("description", "")).strip()
                frontmatter["description"] = (existing + " " + line.strip()).strip()
                continue

            if current_key == "metadata" and line.startswith("  "):
                meta_match = re.match(r"^\s+([A-Za-z0-9_-]+):\s*(.*)$", line)
                if not meta_match:
                    continue
                meta = frontmatter.setdefault("metadata", {})
                if not isinstance(meta, dict):
                    continue
                raw_value = meta_match.group(2).strip()
                if meta_match.group(1) == "tags":
                    meta["tags"] = [
                        part.strip()
                        for part in raw_value.strip("[]").split(",")
                        if part.strip()
                    ]
                else:
                    meta[meta_match.group(1)] = raw_value.strip('"').strip("'")

        metadata = frontmatter.get("metadata")
        if isinstance(metadata, dict):
            frontmatter["tags"] = metadata.get("tags", [])
        return frontmatter

    def _build_search_terms(
        self,
        name: str,
        description: str,
        tags: List[str],
        entry: Dict,
    ) -> List[str]:
        candidates = {name, name.replace("-", " ")}
        candidates.update(part for part in name.split("-") if len(part) > 2)
        candidates.update(tags)

        keyword = entry.get("keyword")
        if keyword:
            candidates.add(str(keyword))

        keywords = entry.get("keywords", [])
        if isinstance(keywords, list):
            candidates.update(str(item) for item in keywords if str(item).strip())

        for command in entry.get("commands", []):
            if not isinstance(command, dict):
                continue
            for field in ("name", "command", "description"):
                value = command.get(field)
                if value:
                    candidates.add(str(value))

        # Pull a few meaningful tokens from the description to improve fallback matching.
        candidates.update(
            tok
            for tok in tokenize(description)
            if len(tok) > 3 and tok not in STOPWORDS
        )

        return sorted({normalize_text(term) for term in candidates if str(term).strip()})

    def estimate_tokens(self, text: str) -> int:
        return max(1, len(text) // 4)

    def find_skill_file(self, skill_path: str, mode: str = "compact") -> Optional[Path]:
        fallback_files = MODE_FALLBACK.get(mode, ["SKILL.md"])
        base_paths = self._resolve_skill_base_path(skill_path)

        input_path = Path(skill_path).expanduser()
        if input_path.is_absolute() and input_path.suffix:
            if input_path.exists() and input_path.name in set(fallback_files) | set(MODE_FILES.values()):
                return input_path

        for base_path in base_paths:
            for filename in fallback_files:
                full_path = base_path / filename
                if full_path.exists():
                    return full_path

        return None

    def load_skill(self, skill_path: str, mode: str = "compact") -> Optional[str]:
        skill_file = self.find_skill_file(skill_path, mode)
        if skill_file:
            return skill_file.read_text(encoding="utf-8")
        return None

    def _score_skill(self, query: str, query_tokens: set[str], skill: Dict) -> int:
        query_norm = normalize_text(query)
        score = 0
        name = skill["name"].lower()
        name_phrase = name.replace("-", " ")

        if re.search(
            rf"(?<![A-Za-z0-9_-]){re.escape(name)}(?![A-Za-z0-9_-])",
            query_norm,
        ):
            score += 120
        if name_phrase in query_norm:
            score += 100

        name_tokens = {tok for tok in tokenize(name_phrase) if tok not in STOPWORDS}
        if name_tokens and name_tokens.issubset(query_tokens):
            score += 40

        for term in skill["search_terms"]:
            if not term:
                continue
            term_tokens = {tok for tok in tokenize(term) if tok not in STOPWORDS}
            if not term_tokens:
                continue
            if len(term_tokens) == 1:
                token = next(iter(term_tokens))
                if token in query_tokens:
                    score += 5
            elif term in query_norm:
                score += 8 + len(term_tokens)
            else:
                overlap = len(term_tokens & query_tokens)
                if overlap:
                    score += overlap

        score += min(8, len(skill["description_tokens"] & query_tokens))
        return score

    def match_query_to_skills(self, query: str) -> List[Tuple[str, int]]:
        query_tokens = {tok for tok in tokenize(query) if tok not in STOPWORDS}
        matches = []

        for skill_name, skill in self.skill_catalog.items():
            score = self._score_skill(query, query_tokens, skill)
            if score > 0:
                matches.append((skill_name, score))

        matches.sort(key=lambda item: (-item[1], item[0]))
        return matches

    def get_best_skill(self, query: str) -> Optional[str]:
        matches = self.match_query_to_skills(query)
        return matches[0][0] if matches else None

    def list_all_skills(self, mode: str = "compact") -> List[Dict]:
        skills = []
        for skill_name, metadata in sorted(self.skill_catalog.items()):
            skill_file = self.find_skill_file(skill_name, mode)
            if not skill_file:
                continue
            content = skill_file.read_text(encoding="utf-8")
            skills.append(
                {
                    "path": skill_name,
                    "description": metadata["description"] or self._extract_description(content),
                    "keywords": metadata["tags"][:3] or metadata["search_terms"][:3],
                    "mode": skill_file.suffix.replace(
                        ".md", "full" if "compact" not in skill_file.name else "compact"
                    ).replace(".", ""),
                    "tokens": self.estimate_tokens(content),
                    "file": skill_file.name,
                }
            )
        return skills

    def _extract_description(self, content: str) -> str:
        lines = content.splitlines()

        for line in lines[:8]:
            if line.startswith("D:"):
                return line[2:].strip().strip('"')
            if line.startswith("@desc"):
                return line.replace("@desc", "", 1).strip()

        in_frontmatter = False
        for line in lines:
            if line.strip() == "---":
                in_frontmatter = not in_frontmatter
                continue
            if in_frontmatter and line.startswith("description:"):
                return line.replace("description:", "", 1).strip()

        for line in lines[:10]:
            if line.startswith("> "):
                return line[2:].strip()

        return ""

    def get_token_stats(self) -> Dict:
        stats = {
            "full": {"total": 0, "count": 0},
            "compact": {"total": 0, "count": 0},
            "toon": {"total": 0, "count": 0},
        }

        for skill_name in self.skill_catalog.keys():
            for mode, expected_file in MODE_FILES.items():
                skill_file = self.find_skill_file(skill_name, mode)
                if skill_file and skill_file.name == expected_file:
                    content = skill_file.read_text(encoding="utf-8")
                    stats[mode]["total"] += self.estimate_tokens(content)
                    stats[mode]["count"] += 1

        return stats


def main():
    parser = argparse.ArgumentParser(
        description="Skill Query Handler for MCP Integration with Token Optimization",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Modes:
  full    - Full SKILL.md
  compact - SKILL.compact.md
  toon    - SKILL.toon

Examples:
  python skill-query-handler.py query "Design a REST API" --mode compact
  python skill-query-handler.py query "코드 리뷰해줘" --tool gemini --mode toon
  python skill-query-handler.py list --mode compact
  python skill-query-handler.py match "database schema"
  python skill-query-handler.py stats
        """,
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    query_parser = subparsers.add_parser("query", help="Generate prompt for a query")
    query_parser.add_argument("text", help="User query text")
    query_parser.add_argument(
        "--tool",
        choices=["gemini", "codex"],
        default="gemini",
        help="MCP tool to use (default: gemini)",
    )
    query_parser.add_argument(
        "--mode",
        choices=["full", "compact", "toon"],
        default="compact",
        help="Token optimization mode (default: compact)",
    )
    query_parser.add_argument("--skill", help="Force specific skill path")
    query_parser.add_argument(
        "--show-tokens", action="store_true", help="Show token estimate"
    )

    list_parser = subparsers.add_parser("list", help="List all available skills")
    list_parser.add_argument("--json", action="store_true", help="Output as JSON")
    list_parser.add_argument(
        "--mode",
        choices=["full", "compact", "toon"],
        default="compact",
        help="Token optimization mode (default: compact)",
    )

    match_parser = subparsers.add_parser("match", help="Find matching skills for a query")
    match_parser.add_argument("text", help="Query text to match")

    prompt_parser = subparsers.add_parser("prompt", help="Generate prompt with specific skill")
    prompt_parser.add_argument("text", help="User query text")
    prompt_parser.add_argument("--skill", required=True, help="Skill path to use")
    prompt_parser.add_argument("--tool", choices=["gemini", "codex"], default="gemini")
    prompt_parser.add_argument(
        "--mode",
        choices=["full", "compact", "toon"],
        default="compact",
        help="Token optimization mode (default: compact)",
    )

    subparsers.add_parser("stats", help="Show token statistics")

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        return

    handler = SkillQueryHandler()

    if args.command == "query":
        skill_path = args.skill or handler.get_best_skill(args.text)
        if not skill_path:
            print(f"No matching skill found for: {args.text}", file=sys.stderr)
            print("\nAvailable skills:")
            for skill in handler.list_all_skills():
                print(f"  - {skill['path']}: {skill['description'][:50]}...")
            sys.exit(1)

        skill_file = handler.find_skill_file(skill_path, args.mode) or handler.find_skill_file(skill_path, "full")
        if not skill_file:
            print(f"Skill file not found: {skill_path}", file=sys.stderr)
            sys.exit(1)

        content = skill_file.read_text(encoding="utf-8")
        if args.tool == "gemini":
            prompt = f"@{skill_file}\n\n{args.text}"
        else:
            prompt = f"{content}\n\n---\n\n{args.text}"

        if args.show_tokens:
            print(
                f"# Mode: {args.mode}, Tokens: ~{handler.estimate_tokens(content + args.text)}",
                file=sys.stderr,
            )
        print(prompt)

    elif args.command == "list":
        skills = handler.list_all_skills(args.mode)
        if args.json:
            print(json.dumps(skills, indent=2, ensure_ascii=False))
        else:
            print(f"Available Skills (mode: {args.mode}):")
            print("=" * 70)
            total_tokens = 0
            for skill in skills:
                total_tokens += skill["tokens"]
                print(f"\n{skill['path']} [{skill['file']}]")
                print(f"  Description: {skill['description'][:55]}...")
                print(
                    f"  Keywords: {', '.join(skill['keywords'])} | Tokens: ~{skill['tokens']}"
                )
            print(f"\n{'=' * 70}")
            avg = total_tokens // len(skills) if skills else 0
            print(f"Total: {len(skills)} skills, ~{total_tokens} tokens (avg: {avg})")

    elif args.command == "match":
        matches = handler.match_query_to_skills(args.text)
        if matches:
            print(f"Matching skills for: '{args.text}'")
            print("-" * 40)
            for skill_path, score in matches[:5]:
                print(f"  [{score}] {skill_path}")
        else:
            print(f"No matching skills found for: {args.text}")

    elif args.command == "prompt":
        skill_file = handler.find_skill_file(args.skill, args.mode) or handler.find_skill_file(args.skill, "full")
        if not skill_file:
            print(f"Skill not found: {args.skill}", file=sys.stderr)
            sys.exit(1)

        content = skill_file.read_text(encoding="utf-8")
        print(
            f"# Mode: {args.mode}, Tokens: ~{handler.estimate_tokens(content + args.text)}",
            file=sys.stderr,
        )

        if args.tool == "gemini":
            print(f"@{skill_file}\n\n{args.text}")
        else:
            print(f"{content}\n\n---\n\n{args.text}")

    elif args.command == "stats":
        stats = handler.get_token_stats()
        print("TOKEN OPTIMIZATION STATISTICS")
        print("=" * 50)
        print(f"\n{'Mode':<12} {'Skills':<10} {'Total Tokens':<15} {'Avg/Skill':<10}")
        print("-" * 50)

        for mode in ["full", "compact", "toon"]:
            mode_stats = stats[mode]
            avg = mode_stats["total"] // mode_stats["count"] if mode_stats["count"] else 0
            print(f"{mode:<12} {mode_stats['count']:<10} {mode_stats['total']:<15,} {avg:<10,}")

        if stats["full"]["total"] > 0 and stats["compact"]["total"] > 0:
            compact_reduction = (1 - stats["compact"]["total"] / stats["full"]["total"]) * 100
            print(f"\nCompact reduction: {compact_reduction:.1f}%")

        if stats["full"]["total"] > 0 and stats["toon"]["total"] > 0:
            toon_reduction = (1 - stats["toon"]["total"] / stats["full"]["total"]) * 100
            print(f"TOON reduction: {toon_reduction:.1f}%")

        print("\nRecommendation:")
        print("  - Use 'compact' mode for most tasks (balanced)")
        print("  - Use 'toon' mode for simple queries (fastest)")
        print("  - Use 'full' mode when detailed examples needed")


if __name__ == "__main__":
    main()

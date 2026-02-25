#!/usr/bin/env python3
"""
Skill Query Handler for MCP Integration (gemini-cli, codex-cli)

This script matches user queries to appropriate skills and executes them
using gemini-cli or codex-cli MCP tools with token optimization.

Modes:
    full    - Full SKILL.md (~2000 tokens) - Maximum detail
    compact - SKILL.compact.md (~500 tokens) - 75% reduction
    toon    - SKILL.toon (~100 tokens) - 95% reduction

Usage:
    python skill-query-handler.py query "Design a REST API" --mode compact
    python skill-query-handler.py query "Review this code" --tool gemini --mode toon
    python skill-query-handler.py list --mode compact
    python skill-query-handler.py match "database schema"
    python skill-query-handler.py stats  # Show token statistics
"""

import os
import sys
import json
import argparse
import re
from pathlib import Path
from typing import Optional, List, Dict, Tuple

# Skill keywords mapping for automatic matching
SKILL_KEYWORDS = {
    "api-design": [
        "api",
        "rest",
        "restful",
        "endpoint",
        "openapi",
        "swagger",
        "api design",
        "api 설계",
        "엔드포인트",
        "rest api",
    ],
    "database-schema-design": [
        "database",
        "schema",
        "db",
        "table",
        "sql",
        "postgresql",
        "mysql",
        "데이터베이스",
        "스키마",
        "테이블",
        "db 설계",
    ],
    "authentication-setup": [
        "auth",
        "authentication",
        "login",
        "jwt",
        "oauth",
        "session",
        "인증",
        "로그인",
        "세션",
    ],
    "backend-testing": [
        "backend test",
        "unit test",
        "integration test",
        "pytest",
        "백엔드 테스트",
        "단위 테스트",
    ],
    "ui-component-patterns": ["ui", "component pattern", "design pattern", "ui 패턴"],
    "state-management": ["state", "redux", "zustand", "context", "상태 관리", "상태"],
    "responsive-design": ["responsive", "mobile", "반응형", "모바일"],
    "web-accessibility": ["accessibility", "a11y", "wcag", "접근성"],
    "code-review": ["review", "code review", "리뷰", "코드 리뷰", "코드리뷰"],
    "code-refactoring": ["refactor", "리팩토링", "리팩터링", "개선"],
    "debugging": [
        "debug",
        "error",
        "bug",
        "exception",
        "traceback",
        "디버그",
        "디버깅",
        "에러",
        "버그",
        "오류",
    ],
    "testing-strategies": ["test strategy", "testing", "tdd", "테스트 전략", "테스팅"],
    "performance-optimization": [
        "performance",
        "optimize",
        "slow",
        "memory",
        "성능",
        "최적화",
        "느림",
    ],
    "deployment-automation": ["deploy", "ci/cd", "pipeline", "배포", "파이프라인"],
    "monitoring-observability": [
        "monitor",
        "log",
        "metric",
        "alert",
        "모니터링",
        "로그",
    ],
    "security-best-practices": [
        "security",
        "vulnerability",
        "xss",
        "sql injection",
        "csrf",
        "보안",
        "취약점",
        "인젝션",
    ],
    "technical-writing": [
        "document",
        "documentation",
        "technical doc",
        "문서",
        "기술 문서",
    ],
    "api-documentation": ["api doc", "api documentation", "api 문서"],
    "changelog-maintenance": ["changelog", "release note", "변경 로그", "릴리즈 노트"],
    "task-estimation": [
        "estimate",
        "estimation",
        "story point",
        "추정",
        "스토리 포인트",
    ],
    "task-planning": ["plan", "planning", "task", "계획", "태스크"],
    "plannotator": [
        "plannotator",
        "plannotator",
        "plan review",
        "review plan",
        "diff review",
        "/plannotator-review",
        "annotate plan",
        "visual plan",
        "계획 검토",
        "플랜뷰",
    ],
    "sprint-retrospective": ["retrospective", "retro", "sprint", "회고"],
    "log-analysis": ["log analysis", "log", "로그 분석"],
    "data-analysis": ["data analysis", "analyze data", "데이터 분석"],
    "pattern-detection": ["pattern", "detect", "패턴"],
    "git-workflow": ["git", "commit", "branch", "merge", "깃", "커밋", "브랜치"],
    "skill-standardization": ["skill", "standardize", "convert skill", "스킬 변환"],
    "bmad": [
        "bmad",
        "bmad-method",
        "agile ai",
        "multi-agent orchestration",
        "vibe coding",
        "spec-driven development",
        "sdd",
        "phase based development",
    ],
    "ohmg": [
        "ohmg",
        "multi-agent",
        "orchestration",
        "antigravity",
        "spawn agent",
        "PM agent",
        "frontend agent",
        "backend agent",
        "serena",
    ],
    "jeo": [
        "jeo",
        "integrated orchestration",
        "통합 오케스트레이션",
        "jeo workflow",
        "jeo 워크플로우",
        "plan execute track cleanup",
        "계획 실행 추적 정리",
        "worktree cleanup",
        "워크트리 정리",
        "kanban orchestration",
        "칸반 오케스트레이션",
        "multi-tool orchestration",
        "전체 플로우",
    ],
    "agent-browser": [
        "browser",
        "headless browser",
        "automation",
        "playwright",
        "accessibility tree",
        "refs",
        "screenshot",
        "web automation",
    ],
}

# File extensions for each mode
MODE_FILES = {
    "full": "SKILL.md",
    "compact": "SKILL.compact.md",
    "toon": "SKILL.toon",
}

# Fallback order when preferred mode file doesn't exist
MODE_FALLBACK = {
    "toon": ["SKILL.toon", "SKILL.compact.md", "SKILL.md"],
    "compact": ["SKILL.compact.md", "SKILL.md"],
    "full": ["SKILL.md"],
}


class SkillQueryHandler:
    def __init__(self, skills_dir: Optional[str] = None):
        if skills_dir:
            self.skills_dir = Path(skills_dir).expanduser()
        else:
            self.skills_dir = Path(__file__).parent

        self.global_skills_dir = Path.home() / ".agent-skills"

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

    def estimate_tokens(self, text: str) -> int:
        """Estimate token count (~4 chars = 1 token)"""
        return max(1, len(text) // 4)

    def find_skill_file(self, skill_path: str, mode: str = "compact") -> Optional[Path]:
        """Find skill file with fallback for the given mode."""
        fallback_files = MODE_FALLBACK.get(mode, ["SKILL.md"])
        base_paths = self._resolve_skill_base_path(skill_path)

        input_path = Path(skill_path).expanduser()
        if input_path.is_absolute() and input_path.suffix:
            input_file = input_path
            if input_file.exists():
                if input_file.name in set(fallback_files) | set(MODE_FILES.values()):
                    return input_file

        for base_path in base_paths:
            for filename in fallback_files:
                full_path = base_path / filename
                if full_path.exists():
                    return full_path

        return None

    def find_skill(self, skill_path: str) -> Optional[Path]:
        """Find a skill by path (backward compatibility)."""
        return self.find_skill_file(skill_path, "full")

    def load_skill(self, skill_path: str, mode: str = "compact") -> Optional[str]:
        """Load skill content with the specified mode."""
        skill_file = self.find_skill_file(skill_path, mode)
        if skill_file:
            return skill_file.read_text(encoding="utf-8")
        return None

    def match_query_to_skills(self, query: str) -> List[Tuple[str, int]]:
        """Match a query to skills based on keywords. Returns list of (skill_path, score)."""
        query_lower = query.lower()
        matches = []

        for skill_path, keywords in SKILL_KEYWORDS.items():
            score = 0

            # Strongly prefer explicit skill-name invocation (e.g. "plannotator ...")
            if re.search(
                rf"(?<![A-Za-z0-9_-]){re.escape(skill_path.lower())}(?![A-Za-z0-9_-])",
                query_lower,
            ):
                score += 100

            for keyword in keywords:
                keyword_lower = keyword.lower()

                # Single-token keywords should match as whole words only
                if " " not in keyword_lower and "/" not in keyword_lower:
                    if re.search(
                        rf"(?<![A-Za-z0-9_-]){re.escape(keyword_lower)}(?![A-Za-z0-9_-])",
                        query_lower,
                    ):
                        score += len(keyword.split())
                else:
                    if keyword_lower in query_lower:
                        # Longer keywords get higher scores
                        score += len(keyword.split())

            if score > 0:
                matches.append((skill_path, score))

        # Sort by score descending
        matches.sort(key=lambda x: x[1], reverse=True)
        return matches

    def get_best_skill(self, query: str) -> Optional[str]:
        """Get the best matching skill for a query."""
        matches = self.match_query_to_skills(query)
        if matches:
            return matches[0][0]
        return None

    def list_all_skills(self, mode: str = "compact") -> List[Dict]:
        """List all available skills with token info."""
        skills = []
        for skill_path in SKILL_KEYWORDS.keys():
            skill_file = self.find_skill_file(skill_path, mode)
            if skill_file:
                content = skill_file.read_text(encoding="utf-8")
                description = self._extract_description(content)
                tokens = self.estimate_tokens(content)
                skills.append(
                    {
                        "path": skill_path,
                        "description": description,
                        "keywords": SKILL_KEYWORDS[skill_path][:3],
                        "mode": skill_file.suffix.replace(".", "").replace(
                            "md",
                            "full" if "compact" not in skill_file.name else "compact",
                        ),
                        "tokens": tokens,
                        "file": skill_file.name,
                    }
                )
        return skills

    def _extract_description(self, content: str) -> str:
        """Extract description from SKILL.md frontmatter or TOON format."""
        lines = content.split("\n")

        # Check for TOON format (starts with N:)
        for line in lines[:5]:
            if line.startswith("D:"):
                return line[2:].strip()

        # Check YAML frontmatter
        in_frontmatter = False
        for line in lines:
            if line.strip() == "---":
                in_frontmatter = not in_frontmatter
                continue
            if in_frontmatter and line.startswith("description:"):
                return line.replace("description:", "").strip()

        # Check for > blockquote (compact format)
        for line in lines[:10]:
            if line.startswith("> "):
                return line[2:].strip()

        return ""

    def generate_prompt(
        self, query: str, tool: str = "gemini", mode: str = "compact"
    ) -> Tuple[str, int]:
        """Generate a prompt for the given query with matched skill.
        Returns (prompt, estimated_tokens)."""
        best_skill = self.get_best_skill(query)

        if not best_skill:
            return (f"No matching skill found for: {query}", 0)

        skill_file = self.find_skill_file(best_skill, mode)
        if not skill_file:
            # Try fallback to full
            skill_file = self.find_skill_file(best_skill, "full")

        if not skill_file:
            return (f"Skill file not found: {best_skill}", 0)

        skill_content = skill_file.read_text(encoding="utf-8")
        tokens = self.estimate_tokens(skill_content + query)

        if tool == "gemini":
            prompt = f"@{skill_file}\n\n{query}"
        elif tool == "codex":
            prompt = f"{skill_content}\n\n---\n\n{query}"
        else:
            prompt = f"Unknown tool: {tool}"

        return (prompt, tokens)

    def get_token_stats(self) -> Dict:
        """Get token statistics for all skills in different modes."""
        stats = {
            "full": {"total": 0, "count": 0},
            "compact": {"total": 0, "count": 0},
            "toon": {"total": 0, "count": 0},
        }

        for skill_path in SKILL_KEYWORDS.keys():
            for mode in ["full", "compact", "toon"]:
                skill_file = self.find_skill_file(skill_path, mode)
                if skill_file and skill_file.name == MODE_FILES.get(mode):
                    content = skill_file.read_text(encoding="utf-8")
                    tokens = self.estimate_tokens(content)
                    stats[mode]["total"] += tokens
                    stats[mode]["count"] += 1

        return stats


def main():
    parser = argparse.ArgumentParser(
        description="Skill Query Handler for MCP Integration with Token Optimization",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Modes:
  full    - Full SKILL.md (~2000 tokens) - Maximum detail
  compact - SKILL.compact.md (~500 tokens) - 75% reduction
  toon    - SKILL.toon (~100 tokens) - 95% reduction

Examples:
  python skill-query-handler.py query "Design a REST API" --mode compact
  python skill-query-handler.py query "코드 리뷰해줘" --tool gemini --mode toon
  python skill-query-handler.py list --mode compact
  python skill-query-handler.py match "database schema"
  python skill-query-handler.py stats
        """,
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # query command
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

    # list command
    list_parser = subparsers.add_parser("list", help="List all available skills")
    list_parser.add_argument("--json", action="store_true", help="Output as JSON")
    list_parser.add_argument(
        "--mode",
        choices=["full", "compact", "toon"],
        default="compact",
        help="Token optimization mode (default: compact)",
    )

    # match command
    match_parser = subparsers.add_parser(
        "match", help="Find matching skills for a query"
    )
    match_parser.add_argument("text", help="Query text to match")

    # prompt command
    prompt_parser = subparsers.add_parser(
        "prompt", help="Generate prompt with specific skill"
    )
    prompt_parser.add_argument("text", help="User query text")
    prompt_parser.add_argument("--skill", required=True, help="Skill path to use")
    prompt_parser.add_argument("--tool", choices=["gemini", "codex"], default="gemini")
    prompt_parser.add_argument(
        "--mode",
        choices=["full", "compact", "toon"],
        default="compact",
        help="Token optimization mode (default: compact)",
    )

    # stats command
    stats_parser = subparsers.add_parser("stats", help="Show token statistics")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    handler = SkillQueryHandler()

    if args.command == "query":
        if args.skill:
            skill_path = args.skill
        else:
            skill_path = handler.get_best_skill(args.text)

        if not skill_path:
            print(f"No matching skill found for: {args.text}", file=sys.stderr)
            print("\nAvailable skills:")
            for skill in handler.list_all_skills():
                print(f"  - {skill['path']}: {skill['description'][:50]}...")
            sys.exit(1)

        # Generate prompt with mode
        skill_file = handler.find_skill_file(skill_path, args.mode)
        if not skill_file:
            skill_file = handler.find_skill_file(skill_path, "full")

        if not skill_file:
            print(f"Skill file not found: {skill_path}", file=sys.stderr)
            sys.exit(1)

        if args.tool == "gemini":
            prompt = f"@{skill_file}\n\n{args.text}"
        else:
            content = skill_file.read_text(encoding="utf-8")
            prompt = f"{content}\n\n---\n\n{args.text}"

        if args.show_tokens:
            content = skill_file.read_text(encoding="utf-8")
            tokens = handler.estimate_tokens(content + args.text)
            print(f"# Mode: {args.mode}, Tokens: ~{tokens}", file=sys.stderr)

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
            print(
                f"Total: {len(skills)} skills, ~{total_tokens} tokens (avg: {total_tokens // len(skills) if skills else 0})"
            )

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
        skill_file = handler.find_skill_file(args.skill, args.mode)
        if not skill_file:
            skill_file = handler.find_skill_file(args.skill, "full")

        if not skill_file:
            print(f"Skill not found: {args.skill}", file=sys.stderr)
            sys.exit(1)

        content = skill_file.read_text(encoding="utf-8")
        tokens = handler.estimate_tokens(content + args.text)

        print(f"# Mode: {args.mode}, Tokens: ~{tokens}", file=sys.stderr)

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
            s = stats[mode]
            avg = s["total"] // s["count"] if s["count"] > 0 else 0
            print(f"{mode:<12} {s['count']:<10} {s['total']:<15,} {avg:<10,}")

        if stats["full"]["total"] > 0 and stats["compact"]["total"] > 0:
            compact_reduction = (
                1 - stats["compact"]["total"] / stats["full"]["total"]
            ) * 100
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

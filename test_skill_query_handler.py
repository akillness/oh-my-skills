#!/usr/bin/env python3
import json
import tempfile
import unittest
from pathlib import Path
import importlib.util


REPO_ROOT = Path(__file__).resolve().parent
MODULE_PATH = REPO_ROOT / ".agent-skills" / "skill-query-handler.py"
SPEC = importlib.util.spec_from_file_location("skill_query_handler", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(MODULE)
SkillQueryHandler = MODULE.SkillQueryHandler


def write_skill(path: Path, name: str, description: str, toon: str | None = None) -> None:
    path.mkdir(parents=True, exist_ok=True)
    (path / "SKILL.md").write_text(
        f"""---
name: {name}
description: {description}
allowed-tools: Read Write
metadata:
  tags: api, google, react, performance
---
""",
        encoding="utf-8",
    )
    if toon is not None:
        (path / "SKILL.toon").write_text(toon, encoding="utf-8")


class SkillQueryHandlerTests(unittest.TestCase):
    def test_uses_manifest_for_matching_and_stats(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            skills_dir = root / ".agent-skills"

            write_skill(
                skills_dir / "google-workspace",
                "google-workspace",
                "Manage Google Docs, Sheets, Drive, and Gmail through Google Workspace APIs.",
                "N:google-workspace\nD:Manage Google Docs, Sheets, Drive, and Gmail through Google Workspace APIs.\n",
            )
            write_skill(
                skills_dir / "api-design",
                "api-design",
                "Design REST APIs and GraphQL schemas.",
                "N:api-design\nD:Design REST APIs and GraphQL schemas.\n",
            )
            write_skill(
                skills_dir / "vercel-react-best-practices",
                "vercel-react-best-practices",
                "React and Next.js performance guidance from Vercel.",
            )

            manifest = {
                "skill_count": 3,
                "skills": [
                    {
                        "name": "google-workspace",
                        "description": "Manage Google Docs, Sheets, Drive, and Gmail through Google Workspace APIs.",
                        "tags": ["google", "google-docs", "spreadsheet", "gmail"],
                        "allowed_tools": ["Read", "Write"],
                    },
                    {
                        "name": "api-design",
                        "description": "Design REST APIs and GraphQL schemas.",
                        "tags": ["api", "rest", "graphql"],
                        "allowed_tools": ["Read", "Write"],
                    },
                    {
                        "name": "vercel-react-best-practices",
                        "description": "React and Next.js performance guidance from Vercel.",
                        "tags": ["react", "next.js", "vercel", "optimization"],
                        "allowed_tools": ["Read", "Write"],
                    },
                ],
            }
            (skills_dir / "skills.json").write_text(json.dumps(manifest), encoding="utf-8")

            handler = SkillQueryHandler(str(skills_dir))

            self.assertEqual(handler.get_best_skill("Google Sheet spreadsheet"), "google-workspace")
            self.assertEqual(handler.get_best_skill("Design a REST API"), "api-design")
            self.assertEqual(
                handler.get_best_skill("Vercel React optimization"),
                "vercel-react-best-practices",
            )

            stats = handler.get_token_stats()
            self.assertEqual(stats["full"]["count"], 3)
            self.assertEqual(stats["toon"]["count"], 2)


if __name__ == "__main__":
    unittest.main()

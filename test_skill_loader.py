#!/usr/bin/env python3
import json
import tempfile
import unittest
from pathlib import Path
import importlib.util


REPO_ROOT = Path(__file__).resolve().parent
MODULE_PATH = REPO_ROOT / ".agent-skills" / "skill_loader.py"
SPEC = importlib.util.spec_from_file_location("skill_loader", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(MODULE)
SkillLoader = MODULE.SkillLoader


def write_skill(path: Path, name: str, description: str) -> None:
    content = f"""---
name: {name}
description: {description}
allowed-tools: Read Write
---

# {name}
"""
    path.mkdir(parents=True, exist_ok=True)
    (path / "SKILL.md").write_text(content, encoding="utf-8")


class SkillLoaderDependencyTests(unittest.TestCase):
    def test_merges_lock_relationships_and_extensions(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            skills_dir = root / ".agent-skills"
            write_skill(skills_dir / "jeo", "jeo", "Integrated orchestration")
            write_skill(skills_dir / "omc", "omc", "Claude orchestration")
            write_skill(skills_dir / "ralph", "ralph", "Persistent loop")

            lock = {
                "skills": {
                    "jeo": {
                        "installCommand": "npx skills add https://github.com/akillness/oh-my-skills --skill jeo",
                        "extensions": [
                            {
                                "skill": "agent-observability",
                                "status": "survey-candidate",
                                "reason": "trace the loop",
                            }
                        ],
                    }
                },
                "dependencies": {
                    "omc": {
                        "source": "repo/omc",
                        "installCommand": "install omc",
                        "required_by": ["jeo"],
                        "description": "Claude executor",
                    },
                    "survey": {
                        "source": "repo/survey",
                        "optional_for": ["jeo"],
                        "description": "discovery",
                    },
                },
            }
            lock_path = root / "skills-lock.json"
            lock_path.write_text(json.dumps(lock), encoding="utf-8")

            loader = SkillLoader(str(skills_dir), str(lock_path))
            jeo = loader.get_skill("jeo")

            self.assertIsNotNone(jeo)
            self.assertEqual(
                jeo["install_command"],
                "npx skills add https://github.com/akillness/oh-my-skills --skill jeo",
            )
            self.assertEqual(jeo["relationships"]["required"][0]["name"], "omc")
            self.assertEqual(jeo["relationships"]["optional"][0]["name"], "survey")
            self.assertEqual(
                jeo["relationships"]["extensions"][0]["name"],
                "agent-observability",
            )

    def test_json_prompt_includes_relationships(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            skills_dir = root / ".agent-skills"
            write_skill(skills_dir / "ralph", "ralph", "Persistent loop")
            lock_path = root / "skills-lock.json"
            lock_path.write_text(
                json.dumps(
                    {
                        "skills": {
                            "ralph": {
                                "installCommand": "install ralph",
                                "extensions": ["rag-pipeline"],
                            }
                        }
                    }
                ),
                encoding="utf-8",
            )

            loader = SkillLoader(str(skills_dir), str(lock_path))
            payload = json.loads(loader.format_for_prompt(["ralph"], "json"))

            self.assertEqual(payload["skills"][0]["install_command"], "install ralph")
            self.assertEqual(
                payload["skills"][0]["relationships"]["extensions"][0]["name"],
                "rag-pipeline",
            )


if __name__ == "__main__":
    unittest.main()

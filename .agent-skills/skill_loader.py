#!/usr/bin/env python3
"""
Agent Skills Loader

A utility for loading and managing Agent Skills across different AI platforms.
Supports Claude, ChatGPT, Gemini, and other AI agents.
Now supports TOON (Token-Oriented Object Notation) for optimized token usage.
"""

import os
import sys
import argparse
import re
import csv
import io
import json
from pathlib import Path
from typing import Dict, List, Optional, Any, Tuple

try:
    import yaml
except ModuleNotFoundError:
    yaml = None


class ToonParser:
    """Simple parser for TOON (Token-Oriented Object Notation) format."""

    # Mapping of abbreviated keys to full keys
    KEY_MAPPING = {
        "N": "name",
        "D": "description",
        "G": "tags",
        "U": "use_cases",
        "S": "steps",
        "R": "rules",
        "P": "path",
        "F": "platforms",
        "T": "tools",
    }

    @staticmethod
    def parse(text: str) -> Dict[str, Any]:
        """Parse TOON text into a dictionary."""
        result = {}
        lines = text.splitlines()

        i = 0
        while i < len(lines):
            line = lines[i].rstrip()
            if not line:
                i += 1
                continue

            # Check for array definition: key[N]{fields}:
            # Support key[N], key[N|...], etc.
            array_match = re.match(r"^\s*([^\[]+)\[([^\]]*)\]\{([^}]*)\}:\s*$", line)

            if array_match:
                key = array_match.group(1).strip()
                # length_display = array_match.group(2)
                fields = [f.strip() for f in array_match.group(3).split(",")]

                rows = []
                i += 1
                # Read rows until we hit a specific stop condition (another key or empty line?)
                # For now, let's assume rows are contiguous and effectively indented or just follow.
                # The user example implies keys are top-level.
                # We will read until we hit a line that looks like a key definition or end of block.
                # Simple heuristic: if line contains ':' and not part of a quoted string, it might be a key.
                # BUT CSV content can contain anything.
                # Let's use the 'N' in key[N] as a hint if provided and strict.
                # If not strict, read until a line matches the key patterns again.

                while i < len(lines):
                    row_line = lines[i].rstrip()
                    if not row_line:
                        i += 1
                        continue  # Skip empty lines in array block? Or ends array?
                        # Usually empty line ends block in markdown-like formats. Let's assume yes.
                        # break

                    # Check if it starts a new key
                    if re.match(
                        r"^\s*([^\[]+)\[([^\]]*)\]\{([^}]*)\}:\s*$", row_line
                    ) or re.match(r"^\s*([^:\[]+):\s*(.*)$", row_line):
                        # But wait, "key: value" pattern is very broad.
                        # "Error: Message" could be a value.
                        # Let's rely on Indentation if strictly 2 spaces?
                        # User said: "2-space indentation + key: value".
                        # Let's assume top-level keys have 0 indent, array items might have 0 or 2?
                        # The example showed:
                        # users[3]...:
                        # 1,Alice...
                        # Rows had 0 indent in one example, or it was ambiguous.
                        # Let's assume if it parses as a CSV row with correct field count, it's a row.
                        pass

                    # Parse CSV row
                    try:
                        reader = csv.reader(
                            io.StringIO(row_line), delimiter=",", quotechar='"'
                        )
                        row_values = next(reader)

                        # If row_values length matches fields, it's a row.
                        if len(row_values) == len(fields):
                            row_dict = dict(zip(fields, row_values))
                            rows.append(row_dict)
                            i += 1
                            continue
                    except:
                        pass

                    # If we are here, it didn't parse purely as a row or we are being safe.
                    # If it looks like a key definition, we break.
                    if re.match(
                        r"^\s*([^\[]+)\[([^\]]*)\]\{([^}]*)\}:\s*$", row_line
                    ) or (
                        re.match(r"^\s*([^:\[]+):\s*(.*)$", row_line)
                        and "," not in row_line
                    ):
                        break

                    # Fallback: Treat as row anyway if we can?
                    # Let's just break if we can't parse it as CSV of correct length, to be safe.
                    break

                result[key] = rows
                continue

            # Key-value pair: key: value (supports abbreviated TOON keys like N:, D:, G:)
            kv_match = re.match(r"^\s*([^:\[]+):\s*(.*)$", line)
            if kv_match:
                key = kv_match.group(1).strip()
                val = kv_match.group(2).strip()
                key = ToonParser.KEY_MAPPING.get(key, key)

                # Handle types
                if val.lower() == "true":
                    val = True
                elif val.lower() == "false":
                    val = False
                elif val.isdigit():
                    val = int(val)
                elif val.startswith('"') and val.endswith('"'):
                    val = val[1:-1]

                result[key] = val
                i += 1
                continue

            i += 1

        return result

    @staticmethod
    def generate(data: Dict[str, Any]) -> str:
        """Generate TOON text from dictionary."""
        output = []
        for key, value in data.items():
            if isinstance(value, list):
                # Check if list of dicts (table)
                if value and isinstance(value[0], dict):
                    keys = list(value[0].keys())
                    header = f"{key}[{len(value)}]{{{','.join(keys)}}}:"
                    output.append(header)
                    for item in value:
                        row = []
                        for k in keys:
                            v = item.get(k, "")
                            v_str = str(v)
                            # Simple CSV escaping
                            if "," in v_str or '"' in v_str or "\n" in v_str:
                                v_str = v_str.replace('"', '""')
                                row.append(f'"{v_str}"')
                            else:
                                row.append(v_str)
                        output.append(",".join(row))
                    output.append("")  # Empty line after array
                else:
                    # Simple list - not fully supported in this simple version, use key: [list] JSON-like or skip
                    pass
            else:
                v_str = str(value)
                if "," in v_str or ":" in v_str or "\n" in v_str:  # primitive check
                    v_str = f'"{v_str}"'
                output.append(f"{key}: {v_str}")
        return "\n".join(output)


class SkillLoader:
    """Load and manage Agent Skills."""

    def __init__(self, skills_dir: str = ".agent-skills"):
        """
        Initialize the skill loader.

        Args:
            skills_dir: Path to the agent skills directory
        """
        self.skills_dir = Path(skills_dir)
        self.skills: Dict[str, Dict] = {}

        if not self.skills_dir.exists():
            # Try to find it relative to current working directory if not absolute
            if Path(os.getcwd()).joinpath(skills_dir).exists():
                self.skills_dir = Path(os.getcwd()).joinpath(skills_dir)
            else:
                pass  # Will fail later or empty

        if self.skills_dir.exists():
            self.load_all_skills()

    def load_all_skills(self) -> None:
        """Discover and load all skills from the skills directory (MD and TOON)."""
        # Load .md skills
        for skill_file in self.skills_dir.rglob("SKILL.md"):
            self._load_skill_file(skill_file)

        # Load .toon skills
        for skill_file in self.skills_dir.rglob("SKILL.toon"):
            self._load_skill_file(skill_file)

    def _load_skill_file(self, skill_path: Path):
        try:
            skill = self.parse_skill(skill_path)
            if skill:
                self.skills[skill["name"]] = skill
        except Exception as e:
            print(f"Warning: Failed to parse {skill_path}: {e}", file=sys.stderr)

    def parse_skill(self, skill_path: Path) -> Optional[Dict]:
        """Parse a SKILL.md or SKILL.toon file."""
        if skill_path.suffix == ".toon":
            return self._parse_toon_skill(skill_path)
        else:
            return self._parse_md_skill(skill_path)

    @staticmethod
    def _normalize_scalar(value: str) -> Any:
        stripped = value.strip()
        if stripped.startswith('"') and stripped.endswith('"'):
            return stripped[1:-1]
        if stripped.startswith("'") and stripped.endswith("'"):
            return stripped[1:-1]
        if stripped.lower() == "true":
            return True
        if stripped.lower() == "false":
            return False
        if stripped.startswith("[") and stripped.endswith("]"):
            inner = stripped[1:-1].strip()
            if not inner:
                return []
            return [
                item.strip().strip('"').strip("'")
                for item in inner.split(",")
                if item.strip()
            ]
        return stripped

    def _parse_frontmatter(self, frontmatter_text: str) -> Optional[Dict[str, Any]]:
        if yaml is not None:
            try:
                return yaml.safe_load(frontmatter_text)
            except yaml.YAMLError as e:
                print(f"Error parsing YAML frontmatter: {e}", file=sys.stderr)
                return None

        frontmatter: Dict[str, Any] = {}
        lines = frontmatter_text.splitlines()
        i = 0

        while i < len(lines):
            line = lines[i]
            if not line.strip():
                i += 1
                continue

            match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
            if not match:
                i += 1
                continue

            key = match.group(1)
            raw_value = match.group(2).rstrip()

            if raw_value in {">", "|"}:
                block = []
                i += 1
                while i < len(lines):
                    nested = lines[i]
                    if nested.startswith("  "):
                        block.append(nested.strip())
                        i += 1
                        continue
                    if not nested.strip():
                        i += 1
                        continue
                    break
                frontmatter[key] = (
                    " ".join(part for part in block if part)
                    if raw_value == ">"
                    else "\n".join(block)
                )
                continue

            if raw_value == "":
                nested_map: Dict[str, Any] = {}
                i += 1
                while i < len(lines):
                    nested = lines[i]
                    if nested.startswith("  "):
                        nested_match = re.match(
                            r"^\s+([A-Za-z0-9_-]+):\s*(.*)$", nested
                        )
                        if nested_match:
                            nested_map[nested_match.group(1)] = self._normalize_scalar(
                                nested_match.group(2)
                            )
                        i += 1
                        continue
                    if not nested.strip():
                        i += 1
                        continue
                    break
                frontmatter[key] = nested_map
                continue

            frontmatter[key] = self._normalize_scalar(raw_value)
            i += 1

        return frontmatter

    def _parse_toon_skill(self, skill_path: Path) -> Optional[Dict]:
        try:
            with open(skill_path, "r", encoding="utf-8") as f:
                content = f.read()

            data = ToonParser.parse(content)

            if "name" not in data:
                print(f"Warning: {skill_path} missing name", file=sys.stderr)
                return None

            # Reconstruct 'body' or similar fields?
            # If TOON is used, the whole content IS the data.
            # We treat the whole data as the 'skill structure'.
            # For compatibility, we map it to our internal structure.

            return {
                "name": data.get("name"),
                "description": data.get("description", ""),
                "allowed_tools": data.get(
                    "allowed_tools", []
                ),  # Expecting list if supported, or parsing string
                "path": skill_path.parent,
                "body": content,  # For prompt, we might just dump the TOON content?
                "full_content": content,
                "type": "toon",
                "data": data,
            }
        except Exception as e:
            print(f"Error reading {skill_path}: {e}", file=sys.stderr)
            return None

    def _parse_md_skill(self, skill_path: Path) -> Optional[Dict]:
        """Parse standard SKILL.md file."""
        try:
            with open(skill_path, "r", encoding="utf-8") as f:
                content = f.read()
        except Exception as e:
            print(f"Error reading {skill_path}: {e}", file=sys.stderr)
            return None

        # Extract YAML frontmatter
        if not content.startswith("---"):
            print(f"Warning: {skill_path} missing frontmatter", file=sys.stderr)
            return None

        parts = content.split("---", 2)
        if len(parts) < 3:
            print(f"Warning: {skill_path} invalid frontmatter format", file=sys.stderr)
            return None

        frontmatter = self._parse_frontmatter(parts[1])
        if frontmatter is None:
            print(f"Error parsing YAML in {skill_path}", file=sys.stderr)
            return None

        if (
            not frontmatter
            or "name" not in frontmatter
            or "description" not in frontmatter
        ):
            print(
                f"Warning: {skill_path} missing required fields (name, description)",
                file=sys.stderr,
            )
            return None

        body = parts[2].strip()

        allowed_tools = frontmatter.get("allowed-tools", [])
        if isinstance(allowed_tools, str):
            allowed_tools = [tool for tool in allowed_tools.split() if tool]

        return {
            "name": frontmatter.get("name"),
            "description": frontmatter.get("description"),
            "allowed_tools": allowed_tools,
            "path": skill_path.parent,
            "body": body,
            "full_content": content,
            "type": "markdown",
            "data": frontmatter,  # Metadata
        }

    def validate_skill(self, skill: Dict) -> List[str]:
        """Perform strict validation on a skill."""
        problems = []
        name = skill.get("name", "")
        desc = skill.get("description", "")

        # 1. Name validation
        if not re.match(r"^[a-z0-9]+(-[a-z0-9]+)*$", name):
            problems.append(
                f"Invalid name '{name}': Must be lowercase, hyphen-separated, no consecutive hyphens, start/end with alphanumeric."
            )

        if len(name) > 64:
            problems.append(f"Invalid name '{name}': Too long (max 64 chars).")

        # 2. Description validation
        if not desc:
            problems.append("Missing description.")
        elif len(desc) > 1024:
            problems.append("Description too long (max 1024 chars).")

        # 3. Path validation (Directory name matches skill name)
        # skill['path'] is a Path object
        dir_name = skill["path"].name
        if dir_name != name:
            problems.append(
                f"Directory name '{dir_name}' does not match skill name '{name}'."
            )

        return problems

    def get_skill(self, name: str) -> Optional[Dict]:
        return self.skills.get(name)

    def list_skills(self) -> List[str]:
        return sorted(self.skills.keys())

    def search_skills(self, query: str) -> List[Dict]:
        results = []
        query_lower = query.lower()

        for skill in self.skills.values():
            if (
                query_lower in skill["name"].lower()
                or query_lower in skill["description"].lower()
            ):
                results.append(skill)

        return results

    def format_for_prompt(
        self, skill_names: Optional[List[str]] = None, format_type: str = "markdown"
    ) -> str:
        if skill_names is None:
            skill_names = self.list_skills()

        if format_type == "xml":
            return self._format_xml(skill_names)
        elif format_type == "json":
            return self._format_json(skill_names)
        elif format_type == "toon":
            return self._format_toon(skill_names)
        else:
            return self._format_markdown(skill_names)

    def _format_markdown(self, skill_names: List[str]) -> str:
        output = "# Available Skills\n\n"
        for name in skill_names:
            skill = self.skills.get(name)
            if not skill:
                continue

            output += f"## {skill['name']}\n\n"
            output += f"**Description**: {skill['description']}\n\n"
            if skill.get("allowed_tools"):
                output += f"**Allowed Tools**: {', '.join(skill['allowed_tools'])}\n\n"
            output += f"**Location**: `{skill['path']}`\n\n"

            if skill["type"] == "markdown":
                output += "### Instructions\n\n"
                output += skill["body"] + "\n\n"
            else:  # TOON
                output += "### TOON Data\n\n"
                output += "```toon\n"
                output += skill["full_content"] + "\n"
                output += "```\n\n"
            output += "---\n\n"
        return output

    def _format_xml(self, skill_names: List[str]) -> str:
        output = "<available_skills>\n"
        for name in skill_names:
            skill = self.skills.get(name)
            if not skill:
                continue

            output += "  <skill>\n"
            output += f"    <name>{skill['name']}</name>\n"
            output += f"    <description>{skill['description']}</description>\n"
            output += f"    <location>{skill['path']}/SKILL.{'toon' if skill['type'] == 'toon' else 'md'}</location>\n"
            if skill.get("allowed_tools"):
                output += "    <allowed_tools>\n"
                for tool in skill["allowed_tools"]:
                    output += f"      <tool>{tool}</tool>\n"
                output += "    </allowed_tools>\n"
            output += "  </skill>\n"
        output += "</available_skills>"
        return output

    def _format_json(self, skill_names: List[str]) -> str:
        skills_data = []
        for name in skill_names:
            skill = self.skills.get(name)
            if not skill:
                continue
            skills_data.append(
                {
                    "name": skill["name"],
                    "description": skill["description"],
                    "allowed_tools": skill.get("allowed_tools", []),
                    "location": str(skill["path"]),
                }
            )
        return json.dumps({"skills": skills_data}, indent=2)

    def _format_toon(self, skill_names: List[str]) -> str:
        """Format metadata of skills in TOON."""
        # This formats the LIST of skills in TOON, not the content of each.
        # skills[N]{name,description,location}:
        skills_list = []
        for name in skill_names:
            skill = self.skills.get(name)
            if not skill:
                continue
            skills_list.append(
                {
                    "name": skill["name"],
                    "description": skill["description"],
                    "location": str(skill["path"]),
                }
            )

        data = {"skills": skills_list}
        return ToonParser.generate(data)

    def get_skill_content(self, name: str) -> Optional[str]:
        skill = self.get_skill(name)
        return skill["full_content"] if skill else None


def main():
    """Command-line interface for skill loader."""
    parser = argparse.ArgumentParser(description="Agent Skills Loader & Manager")
    parser.add_argument(
        "--dir", default=".agent-skills", help="Path to skills directory"
    )

    subparsers = parser.add_subparsers(dest="command", help="Command")

    # Existing commands
    subparsers.add_parser("list", help="List all available skills")

    search_parser = subparsers.add_parser("search", help="Search for skills")
    search_parser.add_argument("query", help="Search query")

    show_parser = subparsers.add_parser("show", help="Show a specific skill")
    show_parser.add_argument("name", help="Skill name")

    prompt_parser = subparsers.add_parser("prompt", help="Generate AI prompt")
    prompt_parser.add_argument("--skills", nargs="+", help="Skill names to include")
    prompt_parser.add_argument(
        "--format",
        choices=["markdown", "xml", "json", "toon"],
        default="markdown",
        help="Output format",
    )
    prompt_parser.add_argument("--output", help="Output file")

    # New command: validate
    validate_parser = subparsers.add_parser(
        "validate", help="Validate skills against strict standards"
    )
    validate_parser.add_argument(
        "name", nargs="?", help="Specific skill name to validate"
    )

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    try:
        loader = SkillLoader(args.dir)
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    if args.command == "list":
        print("Available Skills:")
        print("=" * 50)
        for name in loader.list_skills():
            skill = loader.get_skill(name)
            if not skill:
                continue
            print(f"\n{name} ({skill['type']})")
            print(f"  {skill['description']}")

    elif args.command == "search":
        results = loader.search_skills(args.query)
        if not results:
            print(f"No skills found matching '{args.query}'")
            return
        print(f"Skills matching '{args.query}':")
        print("=" * 50)
        for skill in results:
            print(f"\n{skill['name']}")
            print(f"  {skill['description']}")

    elif args.command == "show":
        content = loader.get_skill_content(args.name)
        if not content:
            print(f"Error: Skill '{args.name}' not found", file=sys.stderr)
            sys.exit(1)
        print(content)

    elif args.command == "prompt":
        output = loader.format_for_prompt(args.skills, args.format)
        if args.output:
            with open(args.output, "w", encoding="utf-8") as f:
                f.write(output)
            print(f"Prompt written to {args.output}")
        else:
            print(output)

    elif args.command == "validate":
        skills_to_validate = []
        if args.name:
            skill = loader.get_skill(args.name)
            if not skill:
                print(f"Error: Skill '{args.name}' not found", file=sys.stderr)
                sys.exit(1)
            skills_to_validate.append(skill)
        else:
            skills_to_validate = [loader.get_skill(n) for n in loader.list_skills()]

        print(f"Validating {len(skills_to_validate)} skills...")
        print("=" * 50)

        has_errors = False
        for skill in skills_to_validate:
            if not skill:
                continue
            problems = loader.validate_skill(skill)
            if problems:
                has_errors = True
                print(f"\n[FAIL] {skill['name']}")
                for p in problems:
                    print(f"  - {p}")
            else:
                # Optional: print success for verbose
                pass

        if has_errors:
            print("\nValidation Failed.")
            sys.exit(1)
        else:
            print("\nAll skills passed validation! ✅")


if __name__ == "__main__":
    main()

# Agent Skills Repository

Modular skill collection for AI agents. Works with Claude, Gemini, ChatGPT, and all AI platforms.

---

## Installation

### Using NPX (Recommended)

```bash
# Install all skills
npx skills add https://github.com/supercent-io/skills-template

# Install specific skills
npx skills add https://github.com/supercent-io/skills-template --skill api-design
npx skills add https://github.com/supercent-io/skills-template --skill code-review
npx skills add https://github.com/supercent-io/skills-template --skill jeo
npx skills add https://github.com/supercent-io/skills-template --skill ohmg
npx skills add https://github.com/supercent-io/skills-template --skill oh-my-codex
npx skills add https://github.com/supercent-io/skills-template --skill plannotator
```

### oh-my-ag MCP Setup

- Skill folder: `ohmg/`

### 🌟 Explore More Skills

**Want additional skills?** Check out **[Awesome Claude Skills](https://github.com/ComposioHQ/awesome-claude-skills)** - 100+ community skills for automation, development, and productivity!

```bash
# Install from Awesome Claude Skills
npx skills add https://github.com/ComposioHQ/awesome-claude-skills --skill github-automation
npx skills add https://github.com/ComposioHQ/awesome-claude-skills --skill slack-automation
```

### AI Agent Prompt

```
Copy the .agent-skills folder from the https://github.com/supercent-io/skills-template
repository to the current project.
```

---

## Folder Structure (Flat - Categories Removed)

```
.agent-skills/
├── README.md                      # This file
├── skill_loader.py                # Skill loader
├── skill-query-handler.py         # Natural language query handler
├── skills.json                    # Skill manifest (auto-generated)
├── skills.toon                    # TOON summary (auto-generated)
│
├── agent-configuration/           # All 65 skill folders at root level
├── api-design/
├── ... (all skills at same level)
│
└── templates/                     # Skill templates
    ├── toon-skill-template/       # TOON format (default)
    ├── basic-skill-template/
    └── advanced-skill-template/
```

> **v4.3.0 Changes**: Category folders removed, all skills flattened to root level

---

## Skills List (57 functional)

> Skills marked *(in development)* exist on disk but do not yet have a SKILL.toon file.

### Agent Development (7)
| Skill | Description | Platforms |
|-------|-------------|-----------|
| `agent-configuration` | AI agent configuration & security policies | All platforms |
| `agent-evaluation` | AI agent evaluation systems | All platforms |
| `agentic-development-principles` | Universal agentic development principles | All platforms |
| `agentic-principles` | Core AI agent collaboration principles | All platforms |
| `agentic-workflow` | Practical AI agent workflows & productivity | All platforms |
| `bmad-orchestrator` | BMAD workflow orchestration (Analysis → Planning → Solutioning → Implementation) *(in development)* | Claude |
| `prompt-repetition` | Prompt repetition for LLM accuracy | All platforms |

### Backend (5)
| Skill | Description | Platforms |
|-------|-------------|-----------|
| `api-design` | REST/GraphQL API design | All platforms |
| `api-documentation` | API documentation generation | All platforms |
| `authentication-setup` | Authentication & authorization setup | All platforms |
| `backend-testing` | Backend testing strategies | All platforms |
| `database-schema-design` | Database schema design | All platforms |

### Frontend (7)
| Skill | Description | Platforms |
|-------|-------------|-----------|
| `design-system` | Design system implementation *(in development)* | All platforms |
| `react-best-practices` | React & Next.js best practices | All platforms |
| `responsive-design` | Responsive web design | All platforms |
| `state-management` | State management patterns | All platforms |
| `ui-component-patterns` | UI component patterns | All platforms |
| `web-accessibility` | Web accessibility (a11y) | All platforms |
| `web-design-guidelines` | Web design guidelines | All platforms |

### Code Quality (5)
| Skill | Description | Platforms |
|-------|-------------|-----------|
| `code-refactoring` | Code refactoring strategies | All platforms |
| `code-review` | Code review practices | All platforms |
| `debugging` | Systematic debugging | All platforms |
| `performance-optimization` | Performance optimization | All platforms |
| `testing-strategies` | Testing strategies | All platforms |

### Infrastructure (8)
| Skill | Description | Platforms |
|-------|-------------|-----------|
| `deployment-automation` | CI/CD & deployment automation | All platforms |
| `firebase-ai-logic` | Firebase AI Logic integration | Claude · Gemini |
| `genkit` | Firebase Genkit AI workflows (flows, agents, RAG, streaming) | Claude · Gemini |
| `looker-studio-bigquery` | Looker Studio + BigQuery | All platforms |
| `monitoring-observability` | Monitoring & observability | All platforms |
| `security-best-practices` | Security best practices | All platforms |
| `system-environment-setup` | Environment configuration | All platforms |
| `vercel-deploy` | Vercel deployment | All platforms |

### Documentation (4)
| Skill | Description | Platforms |
|-------|-------------|-----------|
| `changelog-maintenance` | Changelog management | All platforms |
| `presentation-builder` | Presentation builder *(in development)* | All platforms |
| `technical-writing` | Technical documentation | All platforms |
| `user-guide-writing` | User guides & tutorials | All platforms |

### Project Management (4)
| Skill | Description | Platforms |
|-------|-------------|-----------|
| `sprint-retrospective` | Sprint retrospective facilitation | All platforms |
| `standup-meeting` | Daily standup management | All platforms |
| `task-estimation` | Task estimation techniques | All platforms |
| `task-planning` | Task planning & organization | All platforms |

### Search & Analysis (4)
| Skill | Description | Platforms |
|-------|-------------|-----------|
| `codebase-search` | Codebase search & navigation | All platforms |
| `data-analysis` | Data analysis & insights | All platforms |
| `log-analysis` | Log analysis & debugging | All platforms |
| `pattern-detection` | Pattern detection | All platforms |

### Creative Media (3)
> All Creative Media skills are currently *in development* (no SKILL.toon).

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `image-generation` | AI image generation (Gemini via MCP) *(in development)* | Claude · Gemini |
| `pollinations-ai` | Free image generation via Pollinations.ai (no signup) *(in development)* | All platforms |
| `video-production` | Video production workflows *(in development)* | All platforms |

### Marketing (1)
> Marketing skills are currently *in development* (no SKILL.toon).

| Skill | Description | Platforms |
|-------|-------------|-----------|
| `marketing-automation` | Marketing automation *(in development)* | All platforms |

### Utilities (17)
| Skill | Description | Platforms |
|-------|-------------|-----------|
| `agent-browser` | Fast headless browser CLI for AI agents | All platforms |
| `copilot-coding-agent` | GitHub Copilot Coding Agent — Issue → Draft PR automation | Claude · Codex |
| `environment-setup` | Environment setup | All platforms |
| `file-organization` | File & folder organization | All platforms |
| `git-submodule` | Git submodule management | All platforms |
| `git-workflow` | Git workflow management | All platforms |
| `jeo` | Integrated AI orchestration: ralph+plannotator planning → team/bmad execution → vibe-kanban tracking → worktree cleanup | Claude · Codex · Gemini · OpenCode |
| `npm-git-install` | Install npm from GitHub | All platforms |
| `ohmg` | Multi-agent orchestration for Antigravity workflows | Claude · Gemini |
| `oh-my-codex` | Multi-agent orchestration for OpenAI Codex CLI *(in development)* | Codex |
| `omc` | oh-my-claudecode — Teams-first multi-agent orchestration | Claude |
| `opencontext` | AI agent persistent memory | All platforms |
| `plannotator`, `계획` *(alias: `plan`, `planno`)* | Visual plan and diff review with Plannotator — annotate, approve, or request changes | Claude |
| `ralph` | Self-referential completion loop for multi-turn agents | Claude |
| `skill-standardization` | SKILL.md standardization | All platforms |
| `vibe-kanban` | Kanban board for AI coding agents with git worktree automation | All platforms |
| `workflow-automation` | Workflow automation | All platforms |

---

## TOON Format (Default)

All skills use **TOON format** by default (95% token reduction).

| Mode | File | Avg Tokens | Reduction |
|:-----|:-----|:-----------|:----------|
| **full** | SKILL.md | ~2,118 | - |
| **toon** | SKILL.toon | ~111 | **94.7%** |

```bash
# Skill query (toon mode default)
python3 skill-query-handler.py query "API design"

# Specify full mode
python3 skill-query-handler.py query "API design" --mode full
```

---

## CLI Tools

### skill-query-handler.py

```bash
# List skills
python3 skill-query-handler.py list

# Match query
python3 skill-query-handler.py match "REST API"

# Generate prompt
python3 skill-query-handler.py query "API design"

# View statistics
python3 skill-query-handler.py stats
```

Path resolution behavior for `--skill`:
- Absolute skill paths are used directly (directory or direct `SKILL.md` path)
- Relative skill paths resolve in order: configured `skills_dir` -> global `~/.agent-skills`

### skill_loader.py

```bash
# List skills
python3 skill_loader.py list

# Search skills
python3 skill_loader.py search "api"

# Show skill details
python3 skill_loader.py show api-design
```

---

## Adding New Skills

### 1. Copy Template

```bash
cp -r templates/toon-skill-template [skill-name]
```

### 2. Edit SKILL.toon

```
N:my-new-skill
D:Skill description in 2-3 sentences
G:keyword1 keyword2

U[3]:
  Use case 1
  Use case 2
  Use case 3

S[4]{n,action,details}:
  1,Analyze,Understand user request
  2,Plan,Create approach
  3,Execute,Implement step by step
  4,Verify,Confirm results

R[2]:
  Best practice 1
  Best practice 2
```

### 3. Update Manifest

```bash
python3 scripts/generate_compact_skills.py
```

---

## Explore More Skills

Looking for more AI agent skills?

**[Awesome Claude Skills](https://github.com/ComposioHQ/awesome-claude-skills)** offers 100+ community-created skills for exploration and installation.

```bash
# Search skills
npx skills search "code review"

# Install skills
npx skills add <skill-name>

# Browse: https://github.com/ComposioHQ/awesome-claude-skills
```

---

**Version**: 4.5.0 | **Updated**: 2026-02-24 | **Skills**: 57 functional | **Format**: TOON (Default) | **Structure**: Flat

# bmad-gds Reference

Full upstream documentation: https://github.com/bmad-code-org/bmad-module-game-dev-studio

Module code: `gds` · Version: `0.1.4`

---

## Full Command Reference

| Phase | Code | Command | Agent | Output |
|-------|------|---------|-------|--------|
| Anytime | DP | `bmad-gds-document-project` | tech-writer | project documentation |
| Anytime | QP | `bmad-gds-quick-prototype` | game-solo-dev | — |
| Anytime | TS | `bmad-gds-quick-spec` | game-solo-dev | tech spec |
| Anytime | QD | `bmad-gds-quick-dev` | game-solo-dev | — |
| Pre-production | BG | `bmad-gds-brainstorm-game` | game-designer | brainstorming session |
| Pre-production | GB | `bmad-gds-game-brief` | game-designer | game brief |
| Design | GDD | `bmad-gds-gdd` | game-designer | game design document |
| Design | ND | `bmad-gds-narrative` | game-designer | narrative design |
| Technical | PC | `bmad-gds-project-context` | game-architect | — |
| Technical | GA | `bmad-gds-game-architecture` | game-architect | game architecture |
| Technical | TF | `bmad-gds-test-framework` | game-qa | — |
| Technical | TD | `bmad-gds-test-design` | game-qa | test design |
| Production | SP | `bmad-gds-sprint-planning` | game-scrum-master | sprint status |
| Production | SS | `bmad-gds-sprint-status` | game-scrum-master | — |
| Production | CS | `bmad-gds-create-story` | game-scrum-master | story |
| Production | DS | `bmad-gds-dev-story` | game-dev | — |
| Production | CR | `bmad-gds-code-review` | game-dev | — |
| Production | CC | `bmad-gds-correct-course` | game-scrum-master | change proposal |
| Production | ER | `bmad-gds-retrospective` | game-scrum-master | retrospective |
| Game Testing | TA | `bmad-gds-test-automate` | game-qa | — |
| Game Testing | ES | `bmad-gds-e2e-scaffold` | game-qa | — |
| Game Testing | PP | `bmad-gds-playtest-plan` | game-qa | playtest plan |
| Game Testing | PT | `bmad-gds-performance-test` | game-qa | performance strategy |
| Game Testing | TR | `bmad-gds-test-review` | game-qa | — |

---

## Artifact Locations

**Planning artifacts** (GDD, architecture, narrative, test design, playtest plan, performance strategy, change proposal):
- Default: `{output_folder}/planning-artifacts/`

**Implementation artifacts** (sprint status, stories, reviews, retrospectives):
- Default: `{output_folder}/implementation-artifacts/`

**Project knowledge** (docs, research, references):
- Default: `docs/`

---

## Agent Capabilities

| Agent | Handles |
|-------|---------|
| `game-designer` | Brainstorming, game brief, GDD, narrative design |
| `game-architect` | Game architecture, project context |
| `game-dev` | Dev stories, code review |
| `game-scrum-master` | Sprint planning, sprint status, story creation, course corrections, retrospectives |
| `game-qa` | Test framework setup, test design, automation, E2E, playtest plans, performance testing, test review |
| `game-solo-dev` | Quick prototype, quick spec, quick dev |

---

## Module Configuration

Configured via `module.yaml` at project init. Key settings:

| Setting | Prompt | Default |
|---------|--------|---------|
| `project_name` | Game project name | directory name |
| `game_dev_experience` | Experience level (beginner/intermediate/expert) | intermediate |
| `planning_artifacts` | Planning artifact storage path | `{output_folder}/planning-artifacts` |
| `implementation_artifacts` | Implementation artifact storage path | `{output_folder}/implementation-artifacts` |
| `project_knowledge` | Knowledge/docs path | `docs` |
| `primary_platform` | Engine(s): unity, unreal, godot, other | multi-select |

# bmad-idea Reference

Full upstream documentation: https://github.com/bmad-code-org/bmad-module-creative-intelligence-suite

Module code: `cis` · Module name: Creative Innovation Suite

---

## Command Reference

| Command | Code | Agent | Output |
|---------|------|-------|--------|
| `bmad-cis-brainstorming` | BS | brainstorming-coach (Carson) | brainstorming session results |
| `bmad-cis-design-thinking` | DT | design-thinking-coach (Maya) | design thinking report |
| `bmad-cis-innovation-strategy` | IS | innovation-strategist (Victor) | innovation strategy |
| `bmad-cis-problem-solving` | PS | creative-problem-solver (Dr. Quinn) | problem solution |
| `bmad-cis-storytelling` | ST | storyteller (Sophia) | narrative/story |

All outputs saved to `./creative-outputs/` (or `_bmad-output/` depending on config), filename format: `{workflow-name}-{YYYY-MM-DD}.md`

---

## Slash Commands

| Slash Command | Agent | Alternate |
|---------------|-------|-----------|
| `/cis-brainstorm` | Carson | `bmad-cis-brainstorming` |
| `/cis-design-thinking` | Maya | `bmad-cis-design-thinking` |
| `/cis-innovation-strategy` | Victor | `bmad-cis-innovation-strategy` |
| `/cis-problem-solving` | Dr. Quinn | `bmad-cis-problem-solving` |
| `/cis-storytelling` | Sophia | `bmad-cis-storytelling` |

---

## Agent Loading Commands

Load an agent for direct conversation without triggering the full workflow:

| Command | Agent |
|---------|-------|
| `/cis-agent-brainstorming-coach` | Carson — Brainstorming Coach |
| `/cis-agent-design-thinking-coach` | Maya — Design Thinking Coach |
| `/cis-agent-innovation-strategist` | Victor — Innovation Strategist |
| `/cis-agent-creative-problem-solver` | Dr. Quinn — Creative Problem Solver |
| `/cis-agent-storyteller` | Sophia — Storyteller |
| `/cis-agent-presentation-master` | Caravaggio — Presentation Master |

---

## Agent Capabilities

### Carson — Brainstorming Coach 🧠
- 36 ideation techniques across 7 categories (Collaborative, Structured, Creative, Deep, Theatrical, Wild, Introspective)
- "Yes, and!" methodology
- Psychological safety facilitation
- Progressive mode for comprehensive exploration

### Maya — Design Thinking Coach 🎨
- 5-phase process: Empathize → Define → Ideate → Prototype → Test
- Curated design methods library
- Empathy mapping and persona creation
- How Might We question reframing

### Victor — Innovation Strategist ⚡
- Jobs-to-be-Done analysis
- Blue Ocean Strategy (uncontested market spaces)
- Disruptive Innovation framework
- Business Model Canvas design
- Competitive moat identification

### Dr. Quinn — Creative Problem Solver 🔬
- Five Whys
- TRIZ (Theory of Inventive Problem Solving)
- Theory of Constraints
- Systems Thinking
- Root Cause Analysis with implementation planning

### Sophia — Storyteller 📖 *(sidecar memory)*
- 25 story frameworks: Hero's Journey, Story Brand, Three-Act Structure, Before-After-Bridge, Pixar Pitch, and 20 more
- Emotional arc crafting
- Platform-specific adaptation
- Persistent sidecar memory — remembers story preferences and history across sessions

### Caravaggio — Presentation Master 🎨 *(in development)*
- Planned: slide decks (SD), pitch decks (PD), conference talks (CT), infographics (IN), concept visuals (CV)

---

## Team Mode

**Creative Squad** — runs all CIS agents for a comprehensive creative session:
- Ideation (Carson) → Design (Maya) → Innovation (Victor) → Problem-Solving (Dr. Quinn) → Narrative (Sophia)

---

## Visual Tools Configuration

Set at module install via `module.yaml`:

| Option | Description |
|--------|-------------|
| `mermaid` | Diagram in markdown-standard format (easily understood by LLMs) |
| `excalidraw` | Editable diagrams, flowcharts, convertible to PNG |
| `gemini-nano` | AI image generation via Google Nano Banana |
| `other-image` | Manual configuration with external image generator |

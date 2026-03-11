---
name: presentation-builder
description: Build editable presentations with slides-grab. Use when creating slide decks as HTML slides, iterating visually in a browser, and exporting approved decks to PPTX or PDF.
metadata:
  tags: presentation, slides-grab, pptx, pdf, html-slides, slide-editor, storytelling
  platforms: Claude, ChatGPT, Gemini, Codex
---

# Presentation Builder

Use `slides-grab` when the user needs a real slide deck artifact, not just an outline. The workflow is HTML-first: plan the deck, generate slide HTML, review visually, then export to PPTX/PDF.

## When to use this skill

- Create a presentation from a topic, document, or brief
- Iterate on slide design visually instead of editing raw PPT manually
- Export approved decks to `.pptx` or `.pdf`
- Maintain multi-deck workspaces under `decks/<deck-name>/`

## Preflight

Install and verify `slides-grab` before authoring:

```bash
git clone https://github.com/vkehfdl1/slides-grab.git
cd slides-grab
npm ci
npx playwright install chromium
npm exec -- slides-grab --help
```

Minimum requirement: `Node.js >= 18`.

If `slides-grab` is already available in the current project, reuse the existing install instead of cloning again.

## Workflow

### 1. Plan the deck

Collect:

- presentation goal
- audience
- tone/style
- target slide count
- required source material

Create a concise outline, usually `slide-outline.md`, with:

- slide number
- slide title
- key message
- required visuals/data

Do not move to slide generation until the outline is approved.

### 2. Generate slide HTML

Use a dedicated workspace such as `decks/<deck-name>/`.

Create self-contained slide files:

```text
decks/<deck-name>/
  slide-01-cover.html
  slide-02-problem.html
  slide-03-solution.html
  ...
```

Rules:

- one primary idea per slide
- keep HTML/CSS easy for agents to edit
- inline only the assets/styles the deck actually needs
- keep speaker notes or rationale outside slide body when possible

### 3. Build and review

After generating or editing slides:

```bash
slides-grab build-viewer --slides-dir decks/<deck-name>
slides-grab validate --slides-dir decks/<deck-name>
```

For visual iteration:

```bash
slides-grab edit --slides-dir decks/<deck-name>
```

Use the editor to select a region, request changes, and revise the corresponding HTML until the deck is approved.

### 4. Export artifacts

Only export after the design is approved.

```bash
slides-grab convert --slides-dir decks/<deck-name> --output decks/<deck-name>.pptx
slides-grab pdf --slides-dir decks/<deck-name> --output decks/<deck-name>.pdf
```

Report:

- output file paths
- validation status
- any slides that still need manual polish

## Core commands

```bash
slides-grab edit
slides-grab build-viewer
slides-grab validate
slides-grab convert
slides-grab pdf
slides-grab list-templates
slides-grab list-themes
```

All commands support `--slides-dir <path>`.

## Guardrails

- Follow the stage order: Plan -> Design -> Review -> Export
- Do not export a deck the user has not approved
- Fix source HTML/CSS when validation or conversion fails; do not patch exported binaries
- Reuse the same deck directory through revisions to preserve stable iteration history

## Example prompts

```text
Create an 8-slide enterprise product deck in decks/acme-launch.
Audience: IT buyers.
Tone: confident, clean, technical.
Need PPTX and PDF exports after approval.
```

```text
Turn this product brief into a 10-slide investor deck.
Use slides-grab, show me the outline first, then generate the deck in decks/series-a.
```

## References

- Source repo: `https://github.com/vkehfdl1/slides-grab`
- Key workflow from upstream: plan -> design -> visual edit -> export

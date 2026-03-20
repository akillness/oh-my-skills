---
name: research-paper-writing
description: >
  Write and revise ML, CV, NLP, and systems research papers with strong claim-evidence flow.
  Use when drafting an abstract, introduction, related work, method, experiments, ablations,
  discussion, or rebuttal; structuring figures and tables; tightening reviewer-facing logic;
  or preparing a paper for submission. Triggers on: research paper, paper writing, academic
  writing, ML paper, CVPR paper, NeurIPS paper, ICLR paper, experiments section, rebuttal,
  abstract rewrite, contribution framing, reviewer response.
allowed-tools: Bash Read Write Edit Glob Grep WebFetch
license: MIT
metadata:
  tags: research-paper-writing, academic-writing, ml, cv, nlp, experiments, rebuttal
  version: "1.0"
  source: akillness/oh-my-skills
---

# research-paper-writing

Use this skill when the problem is not just "write better prose", but "turn research work into a defensible paper." The focus is contribution framing, evidence ordering, experiment coverage, and reviewer-facing clarity.

## When to use this skill

- Drafting or rewriting an abstract around concrete claims and measurable evidence
- Structuring an introduction so motivation, gap, method, and contributions land quickly
- Turning notes or code results into a method section with reproducible detail
- Designing experiment, ablation, and error-analysis sections
- Writing related work that positions the paper instead of listing references
- Tightening a rebuttal or reviewer response under strict word limits

## Instructions

### Step 1: Lock the paper contract

Before writing, define:

- the core problem in one sentence
- the single strongest contribution
- the minimum evidence required to defend that contribution
- the target venue and its format constraints

If any of those are fuzzy, fix them first. Weak framing leaks into every section.

### Step 2: Write the abstract from claims, not chronology

Use this order:

1. problem and stakes
2. gap in existing work
3. proposed method
4. strongest quantitative results
5. scope or implication

Keep numbers concrete. Replace vague phrases like "significant improvement" with metric + benchmark + margin.

### Step 3: Build the introduction as a reviewer funnel

Structure the introduction in five moves:

1. why the problem matters
2. why existing approaches fall short
3. what your method changes
4. what the evidence shows
5. bullet contributions

Contribution bullets should be specific and testable, not marketing copy.

### Step 4: Make the method reproducible

The method section should answer:

- what inputs and outputs exist
- what modules or stages the system contains
- what training or optimization objective is used
- what implementation choices materially affect results

Use equations only where they clarify behavior. If a paragraph can be replaced by a precise algorithm box or table, do that.

### Step 5: Treat experiments as the proof section

Cover at least:

- main benchmark results
- ablations for the claimed mechanism
- comparison to strong baselines
- qualitative or failure analysis when helpful
- efficiency or cost if the method claims practicality

Each subsection should map back to one contribution claim.

### Step 6: Write rebuttals with evidence first

For each reviewer concern:

1. restate the concern precisely
2. answer directly in one sentence
3. add concrete evidence
4. say what will change in the camera-ready version, if applicable

Do not become defensive. Remove throat-clearing and persuasion language that is not backed by evidence.

## Examples

### Example 1: Abstract rewrite

Input:
- notes on a diffusion model paper
- benchmark table
- target venue: CVPR

Output:
- a 150-200 word abstract with problem, gap, method, results, and impact

### Example 2: Experiment plan

Input:
- draft method section
- three claimed contributions

Output:
- experiment matrix listing datasets, baselines, ablations, metrics, and figure/table owners

## Best practices

1. Every major claim should have a matching figure, table, or ablation.
2. Do not bury the best result in the middle of a paragraph.
3. Use consistent terminology for modules, datasets, and metrics throughout the paper.
4. Prefer short, information-dense sentences over long narrative transitions.
5. If a result is mixed, state the boundary clearly instead of overselling.

## References

- Peng Sida, research paper writing notes
- NeurIPS, ICLR, CVPR author guidelines

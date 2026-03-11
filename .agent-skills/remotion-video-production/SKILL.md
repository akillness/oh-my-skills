---
name: remotion-video-production
description: Produce programmable videos with Remotion using scene planning, asset orchestration, and validation gates for automated, brand-consistent video content.
tags: [video, remotion, animation, storytelling, automation, react]
platforms: [Claude, ChatGPT, Gemini, Codex]
allowed-tools:
  - Bash
  - Write
  - Read
  - Task
---

# Remotion Video Production

A skill for producing programmable videos using Remotion. Generate automated videos from text instructions and produce brand-consistent videos at scale.

## When to use this skill

- **Automated video generation**: Create videos from text instructions
- **Brand video production**: Consistent-style videos at scale
- **Programmable content**: Integrated narration, visuals, and animation
- **Marketing content**: Product introductions, onboarding, and promotional videos

---

## Instructions

### Step 1: Define the Video Spec

```yaml
video_spec:
  audience: [target audience]
  goal: [video purpose]
  duration: [total length - 30s, 60s, 90s]
  aspect_ratio: "16:9" | "1:1" | "9:16"
  tone: "fast" | "calm" | "cinematic"
  voice:
    style: [narration style]
    language: [language]
```

### Step 2: Outline Scenes

Scene structure template:

```markdown
## Scene Plan

### Scene 1: Hook (0:00 - 0:05)
- **Visual**: Product logo fade-in
- **Audio**: Upbeat intro
- **Text**: "Transform Your Workflow"
- **Transition**: Fade → Scene 2

### Scene 2: Problem (0:05 - 0:15)
- **Visual**: Problem scenario illustration
- **Audio**: Narration begins
- **Text**: Key message overlay
- **Transition**: Slide left

### Scene 3: Solution (0:15 - 0:30)
...
```

### Step 3: Prepare Assets

```bash
# Asset checklist
assets/
├── logos/
│   ├── logo-main.svg
│   └── logo-white.svg
├── screenshots/
│   ├── dashboard.png
│   └── feature-1.png
├── audio/
│   ├── bgm.mp3
│   └── narration.mp3
└── fonts/
    └── brand-font.woff2
```

**Asset preparation rules**:
- Logos: SVG or high-resolution PNG
- Screenshots: Normalized to match aspect ratio
- Audio: MP3 or WAV, volume normalized
- Fonts: Web fonts or local font files

### Step 4: Implement Remotion Composition

```tsx
// src/Video.tsx
import { Composition } from 'remotion';
import { IntroScene } from './scenes/IntroScene';
import { ProblemScene } from './scenes/ProblemScene';
import { SolutionScene } from './scenes/SolutionScene';
import { CTAScene } from './scenes/CTAScene';

export const RemotionVideo: React.FC = () => {
  return (
    <>
      <Composition
        id="ProductIntro"
        component={ProductIntro}
        durationInFrames={1800} // 60s at 30fps
        fps={30}
        width={1920}
        height={1080}
      />
    </>
  );
};

// Scene Component Example
const IntroScene: React.FC<{ frame: number }> = ({ frame }) => {
  const opacity = interpolate(frame, [0, 30], [0, 1]);

  return (
    <AbsoluteFill style={{ opacity }}>
      <Logo />
      <Title>Transform Your Workflow</Title>
    </AbsoluteFill>
  );
};
```

### Step 5: Render and QA

```bash
# 1. Preview render (low quality)
npx remotion preview src/Video.tsx

# 2. QA checks
- [ ] Timing verification
- [ ] Audio sync
- [ ] Text readability
- [ ] Smooth transitions

# 3. Final render
npx remotion render src/Video.tsx ProductIntro out/video.mp4
```

---

## Examples

### Example 1: Product Intro Video

**Prompt**:
```
Create a 60s product intro video with 6 scenes,
upbeat tone, and 16:9 output. Include a CTA at the end.
```

**Expected output**:
```markdown
## Scene Breakdown
1. Hook (0:00-0:05): Logo + tagline
2. Problem (0:05-0:15): Pain point visualization
3. Solution (0:15-0:30): Product demo
4. Features (0:30-0:45): Key benefits (3 items)
5. Social Proof (0:45-0:55): Testimonial/stats
6. CTA (0:55-1:00): Call to action + contact

## Remotion Structure
- src/scenes/HookScene.tsx
- src/scenes/ProblemScene.tsx
- src/scenes/SolutionScene.tsx
- src/scenes/FeaturesScene.tsx
- src/scenes/SocialProofScene.tsx
- src/scenes/CTAScene.tsx
```

### Example 2: Onboarding Walkthrough

**Prompt**:
```
Generate a 45s onboarding walkthrough using screenshots,
with callouts and 9:16 format for mobile.
```

**Expected output**:
- Scene plan with 5 steps
- Asset list (screenshots, callout arrows)
- Text overlays and transitions
- Mobile-safe margins applied

---

## Best practices

1. **Short scenes**: Keep scenes clear at 5-10 seconds each
2. **Consistent typography**: Define a typography scale
3. **Audio sync**: Align narration cues with visuals
4. **Template reuse**: Save reusable compositions
5. **Safe zones**: Ensure margins for mobile aspect ratios

---

## Common pitfalls

- **Text overload**: Limit the amount of text per scene
- **Ignoring mobile safe zones**: Check edges for 9:16 aspect ratio
- **Final render before QA**: Always check preview first

---

## Troubleshooting

### Issue: Audio and visuals out of sync
**Cause**: Frame timing mismatch
**Solution**: Recalculate frames and align timestamps

### Issue: Render is slow or fails
**Cause**: Heavy assets or effects
**Solution**: Compress assets and simplify animations

### Issue: Text unreadable
**Cause**: Insufficient font size or contrast
**Solution**: Use minimum 24px font and high-contrast colors

---

## Output format

```markdown
## Video Production Report

### Spec
- Duration: 60s
- Aspect Ratio: 16:9
- FPS: 30

### Scene Plan
| Scene | Duration | Visual | Audio | Transition |
|-------|----------|--------|-------|------------|
| Hook  | 0:00-0:05 | Logo fade | BGM start | Fade |
| ...   | ...      | ...    | ...   | ...  |

### Assets
- [ ] logo.svg
- [ ] screenshots (3)
- [ ] bgm.mp3
- [ ] narration.mp3

### Render Checklist
- [ ] Preview QA passed
- [ ] Audio sync verified
- [ ] Safe zones checked
- [ ] Final render complete
```

---

## Multi-Agent Workflow

### Validation & Retrospectives

- **Round 1 (Orchestrator)**: Spec completeness, scene coverage
- **Round 2 (Analyst)**: Narrative consistency, pacing review
- **Round 3 (Executor)**: Render readiness checklist verification

### Agent Roles

| Agent | Role |
|-------|------|
| Claude | Scene planning, script writing |
| Gemini | Asset analysis, optimization suggestions |
| Codex | Remotion code generation, render execution |

---

## Metadata

### Version
- **Current Version**: 1.0.0
- **Last Updated**: 2026-01-21
- **Compatible Platforms**: Claude, ChatGPT, Gemini, Codex

### Related Skills
- [image-generation](../image-generation/SKILL.md)
- [presentation-builder](../../documentation/presentation-builder/SKILL.md)
- [frontend-design](../../frontend/design-system/SKILL.md)

### Tags
`#video` `#remotion` `#animation` `#storytelling` `#automation` `#react`

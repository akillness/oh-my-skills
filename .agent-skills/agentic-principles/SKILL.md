---
name: agentic-principles
description: Core principles for collaborative development with AI agents. Defines divide-and-conquer, context management, abstraction-level selection, automation philosophy, and verification/retrospectives. Apply optimal collaboration patterns when using any AI agent.
allowed-tools: Read Write Bash Grep Glob
metadata:
  tags: agentic-development, principles, context-management, automation, multi-agent
  platforms: Claude, Gemini, ChatGPT, Codex
  version: 2.0.0
  source: Claude Code Complete Guide: 70 Tips (ykdojo + Ado Kukic)
---


# Core Principles for AI-Agent Collaboration (Agentic Development Principles)

> **"AI is the copilot; you are the pilot."**
> AI agents amplify a developer's thinking and take over repetitive work, but final decisions and responsibility always remain with the developer.

## When to use this skill

- Confirm the baseline principles at the start of an AI-agent session
- Decide an approach before starting complex work
- Establish a context-management strategy
- Review workflows to improve productivity
- Onboard teammates on how to use AI agents

---

## Principle 1: Divide and Conquer

### Core concept
AI performs far better with **small, clear instructions** than with large, ambiguous tasks.

### How to apply

| Bad example | Good example |
|----------|----------|
| "Build me a login page" | 1. "Create the login form UI component" |
| | 2. "Implement the login API endpoint" |
| | 3. "Wire up the authentication logic" |
| | 4. "Write tests" |

### Practical pattern: staged implementation

```
Step 1: Design and validate models/schemas
Step 2: Implement core logic (minimum viable functionality)
Step 3: Connect APIs/interfaces
Step 4: Write and run tests
Step 5: Integrate and refactor
```

### Verification points
- [ ] Can each step be verified independently?
- [ ] If something fails, can you fix only that step?
- [ ] Is the scope small enough for the AI to understand clearly?

---

## Principle 2: Context is Like Milk

### Core concept
Context (the AI's working memory) should always be kept **fresh and compressed**.
- Old, irrelevant information reduces AI performance
- Context drift: mixing topics can reduce performance by 39%

### Context-management strategies

#### Strategy 1: Single-purpose conversations
```
Tab 1: Authentication system work
Tab 2: UI component work
Tab 3: Test writing
Tab 4: DevOps/deployment work
```

#### Strategy 2: HANDOFF.md technique
When the conversation gets long, document the state:
```markdown
# HANDOFF.md

## Completed work
- Implemented user authentication API
- Implemented JWT issuance logic

## Current status
- Working on token refresh logic

## Next steps
- Implement refresh tokens
- Add logout endpoint

## Notes
- Watch for conflicts with existing session-management code
```

#### Strategy 3: Check context state
- Claude: `/context`, `/clear`
- Gemini: start a new session
- ChatGPT: start a new chat

### Optimization metrics
- Active tools/plugins: keep **minimal**
- Conversation length: if it gets too long, create HANDOFF.md and start a new session

---

## Principle 3: Choose the Right Level of Abstraction

### Core concept
Choose an appropriate abstraction level for the situation.

| Mode | Description | When to use |
|------|------|----------|
| **Vibe Coding** | High-level: focus on overall structure | Rapid prototyping, idea validation, one-off projects |
| **Deep Dive** | Low-level: go line-by-line through code | Bug fixes, security reviews, performance optimization, production code |

### Practical application

```
When adding a new feature:
1. High abstraction: "Create a user profile page" → understand the overall structure
2. Mid abstraction: "Show me the validation logic for the profile edit form" → review a specific feature
3. Low abstraction: "Explain why this regex fails email validation" → detailed debugging
```

---

## Principle 4: Automation of Automation

### Core concept
```
If you've repeated the same task 3+ times → find a way to automate it
Then automate the automation process itself
```

### Automation level evolution

| Level | Approach | Example |
|-------|------|------|
| 1 | Manual copy/paste | ChatGPT → terminal |
| 2 | Terminal integration | Use Claude Code, Gemini CLI directly |
| 3 | Voice input | Speech-to-text system |
| 4 | Automate repeated instructions | Use project instruction files |
| 5 | Workflow automation | Custom commands/skills |
| 6 | Decision automation | Use AI skills |
| 7 | Enforced-rule automation | Hooks/Guard Rails |

### Identify automation targets
- [ ] Do you run the same command 3+ times?
- [ ] Do you repeat the same explanations?
- [ ] Do you often write the same code patterns?

---

## Principle 5: Plan Mode vs Execute Mode

### Plan mode (Plan First)
Analyze only; do not modify anything

**When to use:**
- Complex work you're doing for the first time
- Large refactors spanning multiple files
- Architecture changes
- Database migrations

### Execute mode (Just Do It)
**When to use:**
- Simple, clear tasks
- Experimental prototypes
- Repetitive, time-consuming work
- **Always** use in a safe environment (containers, etc.)

### Recommended ratio
- Plan mode: **90%** (use as the default)
- Execute mode: **10%** (only in a safe environment)

---

## Principle 6: Verification and Retrospectives

### How to verify outputs

1. **Write tests**
   ```
   "Write tests for this function, including edge cases."
   ```

2. **Visual review**
   - Review changed files via diff
   - Revert unwanted changes

3. **Create a draft PR**
   ```
   "Create a draft PR."
   ```

4. **Ask for self-verification**
   ```
   "Review the code you just generated again.
   Verify every claim, and end with a table summarizing verification results."
   ```

### Verification checklist
- [ ] Does the code behave as intended?
- [ ] Are edge cases handled?
- [ ] Are there any security vulnerabilities?
- [ ] Are tests sufficient?

---

## Applying a Multi-Agent Workflow

### Role split by agent

| Agent | Role | Best For |
|-------|------|----------|
| **Claude** | Orchestrator | Planning, code generation, skill interpretation |
| **Gemini** | Analyst | Large-context analysis (1M+ tokens), research |
| **Codex** | Executor | Command execution, builds, deployments |

### Orchestration pattern
```
[Planning agent] Plan → [Analysis agent] Analyze/research → [Execution agent] Write code → [Verification] Test → [Synthesis] Summarize results
```

---

## Quick Reference

### Six principles summary
```
1. Divide & conquer  → Split into small, clear steps
2. Context           → Keep it fresh; single-purpose conversations
3. Abstraction       → Vibe ↔ Deep Dive depending on context
4. Automation        → Automate after 3 repeats
5. Plan/execute      → Plan 90%, execute 10%
6. Verify/retro      → Tests, PRs, self-verification
```

### Key questions
```
- Can I break this work into smaller pieces?
- Is the context still clean?
- Am I using the right level of abstraction?
- Have I repeated this 3+ times?
- Did I plan first?
- Did I verify the result?
```

---

## References

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [ykdojo claude-code-tips](https://github.com/ykdojo/claude-code-tips)
- [Ado's Advent of Claude](https://adocomplete.com/advent-of-claude-2025/)

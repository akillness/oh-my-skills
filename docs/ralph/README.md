# ralph — Completion Loop Guide

> **ralph** is a self-referential completion loop for AI CLI tools. It runs the agent on the same task across turns with fresh context each iteration, until the completion promise is detected or max iterations is reached.

← [Back to README](../../README.md)

---

## Core Concept

The loop happens **across agent turns**, controlled by an `AfterAgent` hook.

1. **You run ONCE**: `/ralph "Your task description"`
2. **Agent works**: Performs actions (modifies files, runs tests, writes code)
3. **Hook intercepts**: When the agent finishes its turn, the `AfterAgent` hook intercepts the exit
4. **Loop continuation**: Hook evaluates state (max iterations, promise) and starts a new turn with the **original prompt**, clearing the previous turn's context
5. **Repeat**: Continues autonomously until completion or user interruption

### Why this works

- **Stable Context & No Compaction**: Prompt never changes between iterations; previous context is cleared. The agent relies on current file state, not stale chat history.
- **Persistent State**: The agent's work persists in files and git history across iterations.
- **Ghost Protection**: If you interrupt and start a new task, the hook detects the prompt mismatch and silently cleans up.

```
Iteration 1: Agent reads task → works → exits
AfterAgent hook: checks completion promise → not found → clears context, re-runs
Iteration 2: Agent reads task + sees file changes → continues → exits
... repeats until <promise>DONE</promise> detected or max-iterations reached
```

---

## Usage

```bash
/ralph "<task>" [--completion-promise="DONE"] [--max-iterations=100]
```

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `--completion-promise` | `"DONE"` | Text the agent must output inside `<promise>TEXT</promise>` to stop |
| `--max-iterations` | `100` | Maximum number of iterations before stopping |

### Completion Promise Format

The agent signals completion by outputting the promise text wrapped in XML tags:

```xml
<promise>DONE</promise>
```

---

## Examples

### Standard run

```text
/ralph "Build a Python CLI task manager with full test coverage"
```

### Custom completion promise

```text
/ralph "Build a REST API for todos. When all CRUD endpoints work and tests pass with >80% coverage, output TASK_COMPLETE" --completion-promise="TASK_COMPLETE"
```

### Bounded iteration run

```text
/ralph "Attempt to refactor the authentication module" --max-iterations=20
```

### TDD workflow with self-correction

```text
/ralph "Implement feature X by following TDD:
1. Write failing tests for the feature.
2. Implement the code to make the tests pass.
3. Run the test suite.
4. If any tests fail, analyze the errors and debug.
5. Refactor for clarity and efficiency.
6. Repeat until all tests are green.
7. When complete, output <promise>TESTS_PASSED</promise>" --completion-promise="TESTS_PASSED"
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/ralph "<task>"` | Start a ralph loop |
| `/ralph:cancel` | Cancel the active loop |
| `/ralph:help` | Show help |

---

## Prompt Best Practices

1. **Clear Completion Criteria** — Provide a verifiable definition of "done." The `--completion-promise` is crucial.
2. **Use Safety Hatches** — Always use `--max-iterations` as a safety net to prevent runaway loops.
3. **Encourage Self-Correction** — Structure the prompt to guide the agent through work → verify → debug cycles.

```text
# Good: clear task + completion signal
/ralph "Fix all TypeScript errors in src/. Run tsc and show 0 errors. Output <promise>0 errors</promise> when done." --completion-promise="0 errors"

# Good: iterative implementation with verification
/ralph "Implement all TODO items in src/api.ts. Mark each as done when complete. Output <promise>ALL TODOS COMPLETE</promise>." --completion-promise="ALL TODOS COMPLETE"
```

---

## Launch Safely

Always run in sandbox mode for safety. Enabling YOLO mode (`-y`) prevents constant tool execution prompts during the loop:

```bash
gemini -s -y
```

---

## Keyword Availability

| Keyword | Available In |
|---------|-------------|
| `ralph` | Gemini-CLI, OpenCode, oh-my-opencode, Claude Code |
| `ohmg` | Available when ralph is active |
| `omx` | Available when ralph is active |
| `bmad` | Available when ralph is active |
| `playwriter` | Available for browser verification |
| `agent-browser` | Available for headless verification |

---

## Installation

```bash
# Skill only
npx skills add https://github.com/akillness/skills-template --skill ralph

# Gemini CLI extension (AfterAgent hook)
gemini extensions install https://github.com/gemini-cli-extensions/ralph --auto-update
```

Required in `~/.gemini/settings.json` for Gemini CLI:

```json
{
  "hooksConfig": { "enabled": true },
  "context": {
    "includeDirectories": ["~/.gemini/extensions/ralph"]
  }
}
```

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start loop | `/ralph "task"` |
| Custom promise | `/ralph "task" --completion-promise=TEXT` |
| Iteration cap | `/ralph "task" --max-iterations=N` |
| Cancel | `/ralph:cancel` |
| Help | `/ralph:help` |

---

## Codex에서 사용 (보정 모드)

`ralph`는 Gemini `AfterAgent` 훅 기반으로 동작합니다. Codex에는 네이티브 종료-후크가 없어 현재는 **보정 모드**로 운영합니다.

### Codex 보정 설치

```bash
bash <your-agent-skills>/ralph/scripts/setup-codex-hook.sh
```

이 명령은 다음을 수행합니다.

- `~/.codex/config.toml`에 `developer_instructions`로 ralph 반복 규칙 반영
- `~/.codex/prompts/ralph.md` 생성

### Codex 실행 순서

1. 위 스크립트 실행
2. Codex 재시작
3. `/prompts:ralph` 확인
4. `/ralph "..." --completion-promise="DONE" --max-iterations=100`

### 현재 스킬만으로 가능한지

- `bmad-orchestrator`: 이 문서의 스킬은 `ralph` 동작 계약만 다루므로, 실사용은 각 플랫폼 오케스트레이션 정책을 따릅니다.
- `vibe-kanban`: `Codex`는 기본 종료-후크 자동 루프가 없어 `ralph`를 별도 보정 모드(`setup-codex-hook.sh`)로 운영합니다.

### 플랫폼별 적용표

| 플랫폼 | 현재 적용 가능성 | 설정 방식 |
|---|---|---|
| Gemini-CLI | 네이티브 지원 | `ralph` extension + `AfterAgent` 훅 |
| Claude Code | 네이티브 지원 | `ralph` 키워드 등록 후 `/ralph` 실행 |
| OpenCode | 네이티브 지원(동일 호출) | `ralph` 명령 등록 후 동일 사용 |
| Codex | 보정 모드 지원 | `setup-codex-hook.sh` 실행 후 `/prompts:ralph` |

### 현재 스킬만으로 가능한가?

- Gemini-CLI/Claude/OpenCode: **가능**
- Codex: **가능(보정 모드)** — native 훅 의존이 없어 자동성 보강이 필요

Source: [gemini-cli-extensions/ralph](https://github.com/gemini-cli-extensions/ralph)

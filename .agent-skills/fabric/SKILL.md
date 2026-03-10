---
name: fabric
description: AI prompt orchestration CLI using reusable Patterns. Use for YouTube summarization, document analysis, content extraction, code explanation, writing assistance, and any AI task via stdin/stdout piping across 20+ providers.
license: CC-BY-4.0
compatibility: All platforms. Requires fabric CLI installed (Go-based binary or Homebrew). Works with OpenAI, Anthropic, Google, Azure, Bedrock, Groq, Ollama, and 20+ other AI providers.
metadata:
  version: 1.1.0
  author: supercent-io
  keyword: fabric
  platforms: All platforms
  tags: fabric, patterns, ai-prompts, youtube, summarize, extract-wisdom, piping, cli, multi-provider, openai, claude, gemini, ollama
allowed-tools: Read Write Bash Grep Glob
---

# Fabric

Fabric is an open-source AI prompt orchestration framework by Daniel Miessler. It provides a library of reusable AI prompts called **Patterns** — each designed for a specific real-world task — wired into a simple Unix pipeline with stdin/stdout.

## When to use this skill

- Summarize or extract insights from YouTube videos, articles, or documents
- Apply any of 250+ pre-built AI patterns to content via Unix piping
- Route different patterns to different AI providers (OpenAI, Claude, Gemini, etc.)
- Create custom patterns for repeatable AI workflows
- Run Fabric as a REST API server for integration with other tools
- Process command output, files, or clipboard content through AI patterns
- Use as an AI agent utility — pipe any tool output through patterns for intelligent summarization

## Instructions

### Step 1: Install Fabric

```bash
# macOS/Linux (one-liner)
curl -fsSL https://raw.githubusercontent.com/danielmiessler/fabric/main/scripts/installer/install.sh | bash

# macOS via Homebrew
brew install fabric-ai

# Windows
winget install danielmiessler.Fabric

# After install — configure API keys and default model
fabric --setup
```

### Step 2: Learn the core pipeline workflow

Fabric works as a Unix pipe. Feed content through stdin and specify a pattern:

```bash
# Summarize a file
cat article.txt | fabric -p summarize

# Stream output in real time
cat document.txt | fabric -p extract_wisdom --stream

# Pipe any command output through a pattern
git log --oneline -20 | fabric -p summarize

# Process clipboard (macOS)
pbpaste | fabric -p summarize

# Pipe from curl
curl -s https://example.com/article | fabric -p summarize
```

### Step 3: Discover patterns

```bash
# List all available patterns
fabric -l

# Update patterns from the repository
fabric -u

# Search patterns by keyword
fabric -l | grep summary
fabric -l | grep code
fabric -l | grep security
```

Key patterns:

| Pattern | Purpose |
|---------|---------|
| `summarize` | Summarize any content into key points |
| `extract_wisdom` | Extract insights, quotes, habits, and lessons |
| `analyze_paper` | Break down academic papers into actionable insights |
| `explain_code` | Explain code in plain language |
| `write_essay` | Write essays from a topic or rough notes |
| `clean_text` | Remove noise and formatting from raw text |
| `analyze_claims` | Fact-check and assess credibility of claims |
| `create_summary` | Create a structured, markdown summary |
| `rate_content` | Rate and score content quality |
| `label_and_rate` | Categorize and score content |
| `improve_writing` | Polish and improve text clarity |
| `create_tags` | Generate relevant tags for content |
| `ask_secure_by_design` | Review code or systems for security issues |
| `capture_thinkers_work` | Extract the core ideas of a thinker or author |
| `create_investigation_visualization` | Create a visual map of complex investigations |

### Step 4: Process YouTube videos

```bash
# Summarize a YouTube video
fabric -y "https://youtube.com/watch?v=VIDEO_ID" -p summarize

# Extract key insights from a video
fabric -y "https://youtube.com/watch?v=VIDEO_ID" -p extract_wisdom

# Get transcript only (no pattern applied)
fabric -y "https://youtube.com/watch?v=VIDEO_ID" --transcript

# Transcript with timestamps
fabric -y "https://youtube.com/watch?v=VIDEO_ID" --transcript-with-timestamps
```

### Step 5: Create custom patterns

Each pattern is a directory with a `system.md` file inside `~/.config/fabric/patterns/`. The body should follow this structure:

```bash
mkdir -p ~/.config/fabric/patterns/my-pattern
cat > ~/.config/fabric/patterns/my-pattern/system.md << 'EOF'
# IDENTITY AND PURPOSE

You are an expert at [task]. Your job is to [specific goal].

Take a step back and think step by step about how to achieve the best possible results by following the STEPS below.

# STEPS

1. [Step 1]
2. [Step 2]

# OUTPUT INSTRUCTIONS

- Only output Markdown.
- [Format instruction 2]
- Do not give warnings or notes; only output the requested sections.

# INPUT

INPUT:
EOF
```

Use it immediately:

```bash
echo "input text" | fabric -p my-pattern
cat file.txt | fabric -p my-pattern --stream
```

### Step 6: Multi-provider routing and advanced usage

```bash
# Run as REST API server (port 8080 by default)
fabric --serve

# Use web search capability
fabric -p analyze_claims --search "claim to verify"

# Per-pattern model routing in ~/.config/fabric/.env
FABRIC_MODEL_PATTERN_SUMMARIZE=anthropic|claude-opus-4-5
FABRIC_MODEL_PATTERN_EXTRACT_WISDOM=openai|gpt-4o
FABRIC_MODEL_PATTERN_EXPLAIN_CODE=google|gemini-2.0-flash

# Create shell aliases for frequently used patterns
alias summarize="fabric -p summarize"
alias wisdom="fabric -p extract_wisdom"
alias explain="fabric -p explain_code"

# Chain patterns
cat paper.txt | fabric -p summarize | fabric -p extract_wisdom

# Save output
cat document.txt | fabric -p extract_wisdom > insights.md
```

### Step 7: Use in AI agent workflows

Fabric is a powerful utility for AI agents — pipe any tool output through patterns for intelligent analysis:

```bash
# Analyze test failures
npm test 2>&1 | fabric -p analyze_logs

# Summarize git history for a PR description
git log --oneline origin/main..HEAD | fabric -p create_summary

# Explain a code diff
git diff HEAD~1 | fabric -p explain_code

# Summarize build errors
make build 2>&1 | fabric -p summarize

# Analyze security vulnerabilities in code
cat src/auth.py | fabric -p ask_secure_by_design

# Process log files
cat /var/log/app.log | tail -100 | fabric -p analyze_logs
```

#### REST API server mode

Run Fabric as a microservice and call it from other tools:

```bash
# Start server
fabric --serve --port 8080

# Call via HTTP
curl -X POST http://localhost:8080/chat \
  -H "Content-Type: application/json" \
  -d '{"prompts":[{"userInput":"Summarize this","patternName":"summarize"}]}'
```

## Best practices

- Run `fabric -u` before first use and regularly to get the latest community patterns.
- Use `--stream` for long content to see results progressively instead of waiting.
- Create shell aliases (`alias wisdom="fabric -p extract_wisdom"`) for your most-used patterns.
- Use per-pattern model routing to optimize cost vs. quality for each task type.
- Keep custom patterns in `~/.config/fabric/patterns/` — they persist across updates.
- For YouTube, transcript extraction works best with videos that have captions enabled.
- Chain patterns with Unix pipes for multi-step processing workflows.
- Follow the IDENTITY → STEPS → OUTPUT INSTRUCTIONS structure when creating custom patterns.

## References

- [Fabric GitHub](https://github.com/danielmiessler/Fabric)
- [Pattern Library](https://github.com/danielmiessler/Fabric/tree/main/patterns)
- [Installation Guide](https://github.com/danielmiessler/Fabric#installation)
- [Custom Pattern Guide](https://github.com/danielmiessler/Fabric/blob/main/patterns/README.md)

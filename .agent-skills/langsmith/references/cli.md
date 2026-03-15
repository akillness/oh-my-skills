# LangSmith CLI Reference

> Source: https://docs.langchain.com/langsmith/langsmith-cli
> Install: `curl -sSL https://raw.githubusercontent.com/langchain-ai/langsmith-cli/main/scripts/install.sh | sh`

## Installation

```bash
# Recommended (install script)
curl -sSL https://raw.githubusercontent.com/langchain-ai/langsmith-cli/main/scripts/install.sh | sh

# Go install
go install github.com/langchain-ai/langsmith-cli/cmd/langsmith@latest
```

## Authentication

```bash
export LANGSMITH_API_KEY="lsv2_..."
export LANGSMITH_ENDPOINT="..."        # Self-hosted instances only
export LANGSMITH_PROJECT="my-project"  # Default project
```

## Project Commands

```bash
langsmith project list
langsmith project list --name-contains "staging"
langsmith project create --name "my-project"
langsmith project delete --name "old-project"
```

## Trace Commands

```bash
# List traces
langsmith trace list
langsmith trace list --limit 50 --last-n-minutes 60
langsmith trace list --error                      # Only errored traces
langsmith trace list --full --include-metadata    # With full content

# Get specific trace
langsmith trace get <trace-id>

# Export traces
langsmith trace export -o traces.json
langsmith trace export --format pretty -o traces.txt
```

## Run Commands (individual spans)

```bash
# List runs
langsmith run list
langsmith run list --run-type llm
langsmith run list --name "OpenAI Call"
langsmith run list --project "my-project"

# Get specific run
langsmith run get <run-id>

# Export
langsmith run export -o runs.json
```

## Thread Commands (conversations)

```bash
langsmith thread list
langsmith thread list --project "my-project"
langsmith thread get <thread-id>
```

## Dataset Commands

```bash
# List datasets
langsmith dataset list

# Create dataset
langsmith dataset create --name "My Dataset"

# Export dataset
langsmith dataset export --name "My Dataset" -o dataset.json

# Import dataset
langsmith dataset import --name "My Dataset" -i dataset.json
```

## Evaluator Commands

```bash
langsmith evaluator list
langsmith evaluator upload
```

## Experiment Commands

```bash
langsmith experiment list
langsmith experiment list --dataset "My Dataset"
langsmith experiment get <experiment-id>
```

## Output Formats

```bash
langsmith trace list                    # JSON (default)
langsmith trace list --format pretty    # Human-readable table
langsmith trace export -o output.json   # Write JSON to file
```

## References

- [CLI Docs](https://docs.langchain.com/langsmith/langsmith-cli)
- [langsmith-cli GitHub](https://github.com/langchain-ai/langsmith-cli)

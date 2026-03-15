---
name: langsmith
description: >
  Instrument, trace, evaluate, and monitor LLM applications and AI agents with LangSmith.
  Use when setting up observability for LLM pipelines, running offline or online evaluations,
  managing prompts in the Prompt Hub, creating datasets for regression testing, or deploying
  agent servers. Triggers on: langsmith, langchain tracing, llm tracing, llm observability,
  llm evaluation, trace llm calls, @traceable, wrap_openai, langsmith evaluate, langsmith dataset,
  langsmith feedback, langsmith prompt hub, langsmith project, llm monitoring, llm debugging,
  llm quality, openevals, langsmith cli, langsmith experiment, annotate llm, llm judge.
allowed-tools: Bash Read Write Edit Glob Grep WebFetch
metadata:
  tags: langsmith, langchain, tracing, observability, evaluation, llm-monitoring, prompt-hub, datasets, openevals
  version: "1.0"
  source: https://docs.langchain.com/langsmith/home
  license: MIT
---

# langsmith — LLM Observability, Evaluation & Prompt Management

> **Keyword**: `langsmith` · `llm tracing` · `llm evaluation` · `@traceable` · `langsmith evaluate`
>
> LangSmith is a framework-agnostic platform for developing, debugging, and deploying LLM applications.
> It provides end-to-end tracing, quality evaluation, prompt versioning, and production monitoring.

## When to use this skill

- Add tracing to any LLM pipeline (OpenAI, Anthropic, LangChain, custom models)
- Run offline evaluations with `evaluate()` against a curated dataset
- Set up production monitoring and online evaluation
- Manage and version prompts in the Prompt Hub
- Create datasets for regression testing and benchmarking
- Attach human or automated feedback to traces
- Use LLM-as-judge scoring with `openevals`
- Debug agent failures with end-to-end trace inspection

## Instructions

1. Install SDK: `pip install -U langsmith` (Python) or `npm install langsmith` (TypeScript)
2. Set environment variables: `LANGSMITH_TRACING=true`, `LANGSMITH_API_KEY=lsv2_...`
3. Instrument with `@traceable` decorator or `wrap_openai()` wrapper
4. View traces at [smith.langchain.com](https://smith.langchain.com)
5. For evaluation setup, see [references/python-sdk.md](references/python-sdk.md)
6. For CLI commands, see [references/cli.md](references/cli.md)
7. Run `bash scripts/setup.sh` to auto-configure environment

> **API Key**: Get from [smith.langchain.com → Settings → API Keys](https://smith.langchain.com)
> **Docs**: https://docs.langchain.com/langsmith

---

## Quick Start

### Python

```bash
pip install -U langsmith openai
export LANGSMITH_TRACING=true
export LANGSMITH_API_KEY="lsv2_..."
export OPENAI_API_KEY="sk-..."
```

```python
from langsmith import traceable
from langsmith.wrappers import wrap_openai
from openai import OpenAI

client = wrap_openai(OpenAI())

@traceable
def rag_pipeline(question: str) -> str:
    """Automatically traced in LangSmith"""
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": question}]
    )
    return response.choices[0].message.content

result = rag_pipeline("What is LangSmith?")
```

### TypeScript

```bash
npm install langsmith openai
export LANGSMITH_TRACING=true
export LANGSMITH_API_KEY="lsv2_..."
```

```typescript
import { traceable } from "langsmith/traceable";
import { wrapOpenAI } from "langsmith/wrappers";
import { OpenAI } from "openai";

const client = wrapOpenAI(new OpenAI());

const pipeline = traceable(async (question: string): Promise<string> => {
  const res = await client.chat.completions.create({
    model: "gpt-4o",
    messages: [{ role: "user", content: question }],
  });
  return res.choices[0].message.content ?? "";
}, { name: "RAG Pipeline" });

await pipeline("What is LangSmith?");
```

---

## Core Concepts

| Concept | Description |
|---------|-------------|
| **Run** | Individual operation (LLM call, tool call, retrieval). The fundamental unit. |
| **Trace** | All runs from a single user request, linked by `trace_id`. |
| **Thread** | Multiple traces in a conversation, linked by `session_id` or `thread_id`. |
| **Project** | Container grouping related traces (set via `LANGSMITH_PROJECT`). |
| **Dataset** | Collection of `{inputs, outputs}` examples for offline evaluation. |
| **Experiment** | Result set from running `evaluate()` against a dataset. |
| **Feedback** | Score/label attached to a run — numeric, categorical, or freeform. |

---

## Tracing

### @traceable decorator (Python)

```python
from langsmith import traceable

@traceable(
    run_type="chain",          # llm | chain | tool | retriever | embedding
    name="My Pipeline",
    tags=["production", "v2"],
    metadata={"version": "2.1", "env": "prod"},
    project_name="my-project"
)
def pipeline(question: str) -> str:
    return generate_answer(question)
```

### Selective tracing context

```python
import langsmith as ls

# Enable tracing for this block only
with ls.tracing_context(enabled=True, project_name="debug"):
    result = chain.invoke({"input": "..."})

# Disable tracing despite LANGSMITH_TRACING=true
with ls.tracing_context(enabled=False):
    result = chain.invoke({"input": "..."})
```

### Wrap provider clients

```python
from langsmith.wrappers import wrap_openai, wrap_anthropic
from openai import OpenAI
import anthropic

openai_client = wrap_openai(OpenAI())           # All calls auto-traced
anthropic_client = wrap_anthropic(anthropic.Anthropic())
```

### Distributed tracing (microservices)

```python
from langsmith.run_helpers import get_current_run_tree
import langsmith

@langsmith.traceable
def service_a(inputs):
    rt = get_current_run_tree()
    headers = rt.to_headers()     # Pass to child service
    return call_service_b(headers=headers)

@langsmith.traceable
def service_b(x, headers):
    with langsmith.tracing_context(parent=headers):
        return process(x)
```

---

## Evaluation

### Basic evaluation with evaluate()

```python
from langsmith import Client
from langsmith.wrappers import wrap_openai
from openai import OpenAI

client = Client()
oai = wrap_openai(OpenAI())

# 1. Create dataset
dataset = client.create_dataset("Geography QA")
client.create_examples(
    dataset_id=dataset.id,
    examples=[
        {"inputs": {"q": "Capital of France?"}, "outputs": {"a": "Paris"}},
        {"inputs": {"q": "Capital of Germany?"}, "outputs": {"a": "Berlin"}},
    ]
)

# 2. Target function
def target(inputs: dict) -> dict:
    res = oai.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": inputs["q"]}]
    )
    return {"a": res.choices[0].message.content}

# 3. Evaluator
def exact_match(inputs, outputs, reference_outputs):
    return outputs["a"].strip().lower() == reference_outputs["a"].strip().lower()

# 4. Run experiment
results = client.evaluate(
    target,
    data="Geography QA",
    evaluators=[exact_match],
    experiment_prefix="gpt-4o-mini-v1",
    max_concurrency=4
)
```

### LLM-as-judge with openevals

```python
pip install -U openevals
```

```python
from openevals.llm import create_llm_as_judge
from openevals.prompts import CORRECTNESS_PROMPT

judge = create_llm_as_judge(
    prompt=CORRECTNESS_PROMPT,
    model="openai:o3-mini",
    feedback_key="correctness",
)

results = client.evaluate(target, data="my-dataset", evaluators=[judge])
```

### Evaluation types

| Type | When to use |
|------|------------|
| **Code/Heuristic** | Exact match, format checks, rule-based |
| **LLM-as-judge** | Subjective quality, safety, reference-free |
| **Human** | Annotation queues, pairwise comparison |
| **Pairwise** | Compare two app versions |
| **Online** | Production traces, real traffic |

---

## Prompt Hub

```python
from langsmith import Client
from langchain_core.prompts import ChatPromptTemplate

client = Client()

# Push a prompt
prompt = ChatPromptTemplate([
    ("system", "You are a helpful assistant."),
    ("user", "{question}"),
])
client.push_prompt("my-assistant-prompt", object=prompt)

# Pull and use
prompt = client.pull_prompt("my-assistant-prompt")
# Pull specific version:
prompt = client.pull_prompt("my-assistant-prompt:abc123")
```

---

## Feedback

```python
from langsmith import Client
import uuid

client = Client()

# Custom run ID for later feedback linking
my_run_id = str(uuid.uuid4())
result = chain.invoke({"input": "..."}, {"run_id": my_run_id})

# Attach feedback
client.create_feedback(
    key="correctness",
    score=1,              # 0-1 numeric or categorical
    run_id=my_run_id,
    comment="Accurate and concise"
)
```

---

## References

- [Python SDK Reference](references/python-sdk.md) — full Client API, @traceable signature, evaluate()
- [TypeScript SDK Reference](references/typescript-sdk.md) — Client, traceable, wrappers, evaluate
- [CLI Reference](references/cli.md) — langsmith CLI commands
- [Official Docs](https://docs.langchain.com/langsmith) — langchain.com/langsmith
- [SDK GitHub](https://github.com/langchain-ai/langsmith-sdk) — MIT License, v0.7.17
- [openevals](https://github.com/langchain-ai/openevals) — Prebuilt LLM evaluators

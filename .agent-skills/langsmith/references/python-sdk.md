# LangSmith Python SDK Reference

> Source: https://docs.langchain.com/langsmith | SDK: `langsmith` v0.7.17+
> Install: `pip install -U langsmith`

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `LANGSMITH_API_KEY` | Yes | API key from smith.langchain.com |
| `LANGSMITH_TRACING` | Yes | `true` to enable tracing |
| `LANGSMITH_PROJECT` | No | Default project name (default: `"default"`) |
| `LANGSMITH_ENDPOINT` | No | API URL (self-hosted only) |
| `LANGSMITH_WORKSPACE_ID` | No | Required for org-scoped keys |

## `@traceable` Decorator

Full signature:

```python
from langsmith import traceable

@traceable(
    run_type: Literal['tool', 'chain', 'llm', 'retriever', 'embedding', 'prompt', 'parser'] = 'chain',
    name: str | None = None,            # Defaults to function name
    metadata: dict | None = None,
    tags: list[str] | None = None,
    client: Client | None = None,
    reduce_fn: Callable | None = None,  # For streaming/generator outputs
    project_name: str | None = None,
    process_inputs: Callable | None = None,   # Custom input serializer
    process_outputs: Callable | None = None,  # Custom output serializer
)
def my_function(...):
    ...
```

## `trace()` Context Manager

```python
from langsmith import trace

inputs = {"question": "What is 2+2?"}
with trace(name="My Trace", inputs=inputs) as run:
    result = my_pipeline(**inputs)
    run.outputs = {"answer": result}
    trace_id = run.id
```

## `tracing_context()` — Selective Tracing

```python
import langsmith as ls

# Enable for this block only
with ls.tracing_context(enabled=True, project_name="test"):
    result = chain.invoke(...)

# Disable despite env var
with ls.tracing_context(enabled=False):
    result = chain.invoke(...)

# Use custom client
with ls.tracing_context(client=my_client, project_name="isolated"):
    result = chain.invoke(...)
```

## `wrap_openai()` and Other Wrappers

```python
from langsmith.wrappers import wrap_openai, wrap_anthropic
from openai import OpenAI
import anthropic

openai_client = wrap_openai(OpenAI())
anthropic_client = wrap_anthropic(anthropic.Anthropic())
# wrap_gemini() also available
```

## `Client` — Full API

```python
from langsmith import Client
client = Client(api_key="...", api_url="https://api.smith.langchain.com")
```

### Datasets

```python
# Create
dataset = client.create_dataset("name", description="...")

# Add examples
client.create_examples(
    dataset_id=dataset.id,
    examples=[{"inputs": {...}, "outputs": {...}}]
)

# List, clone, delete
for ds in client.list_datasets(): ...
client.clone_public_dataset("https://smith.langchain.com/public/...")
client.delete_dataset(dataset_id=dataset.id)
```

### Evaluation

```python
# Synchronous
results = client.evaluate(
    target_fn,           # Callable: dict -> dict
    data="dataset-name", # str name, UUID, or iterator
    evaluators=[eval_fn],
    experiment_prefix="v1",
    description="...",
    max_concurrency=4
)

# Async
results = await client.aevaluate(target_fn, data="...", evaluators=[...])

# Evaluate existing experiment runs
results = client.evaluate_existing(runs, evaluators=[...])

# Pairwise comparison
results = client.evaluate_comparative("exp-name", data="...",
    candidate=fn_v2, baseline=fn_v1)
```

### Evaluator Function Signatures

```python
# With reference outputs (offline)
def evaluator(inputs: dict, outputs: dict, reference_outputs: dict) -> dict | bool:
    return {"key": "correctness", "score": 1, "comment": "..."}
    # Or: return outputs["answer"] == reference_outputs["answer"]

# Without reference outputs (online)
def online_evaluator(inputs: dict, outputs: dict) -> dict:
    return {"key": "quality", "score": 0.8}
```

### Feedback

```python
# Attach to a run
client.create_feedback(
    key="thumbs_up",
    score=1,
    run_id=run_id,
    trace_id=trace_id,
    comment="Accurate"
)

# Feedback config
client.create_feedback_config("accuracy", feedback_config={
    "type": "continuous", "min": 0, "max": 1
})
client.create_feedback_config("label", feedback_config={
    "type": "categorical",
    "categories": [{"value": 1, "label": "Pass"}, {"value": 0, "label": "Fail"}]
})
client.create_feedback_config("notes", feedback_config={"type": "freeform"})

# List, update, delete
for cfg in client.list_feedback_configs(): print(cfg.feedback_key)
client.update_feedback_config("accuracy", is_lower_score_better=True)
client.delete_feedback_config("accuracy")
```

### Annotation Queues

```python
queue = client.create_annotation_queue(
    name="Review Queue",
    description="...",
    rubric_instructions="Score carefully.",
    rubric_items=[{
        "feedback_key": "accuracy",
        "description": "How accurate?",
        "score_descriptions": {"0": "Wrong", "1": "Correct"},
        "is_required": True,
    }]
)
```

### Prompt Hub

```python
from langchain_core.prompts import ChatPromptTemplate

# Push
prompt = ChatPromptTemplate([("system", "..."), ("user", "{q}")])
client.push_prompt("my-prompt", object=prompt)

# Pull (latest or specific version)
p = client.pull_prompt("my-prompt")
p = client.pull_prompt("my-prompt:commit-abc123")
```

### Projects

```python
client.create_project("my-project")
client.delete_project(project_name="old-project")
for proj in client.list_projects(): print(proj.name)
```

### Utility Functions

```python
from langsmith.run_helpers import get_current_run_tree
from langchain_core.tracers.langchain import wait_for_all_tracers

# Get current run (inside @traceable)
@traceable
def my_func():
    rt = get_current_run_tree()
    headers = rt.to_headers()   # For distributed tracing
    return headers

# Wait for async trace flush (important in scripts)
wait_for_all_tracers()
```

## LangChain Integration

```python
# Auto-trace: just set env vars
import os
os.environ["LANGSMITH_TRACING"] = "true"

from langchain_openai import ChatOpenAI
chain = ChatOpenAI()  # All invocations automatically traced

# Add metadata at invocation time
chain.invoke(
    {"input": "..."},
    {
        "tags": ["production"],
        "metadata": {"version": "2.0"},
        "run_name": "MyChain",
        "run_id": str(uuid.uuid4()),
    }
)
```

## Distributed Tracing

```python
import langsmith
from langsmith.run_helpers import get_current_run_tree

@langsmith.traceable
def parent(inputs):
    rt = get_current_run_tree()
    headers = rt.to_headers()
    # Pass headers to child microservice

@langsmith.traceable
def child(x, headers):
    with langsmith.tracing_context(parent=headers):
        return do_work(x)
```

## `openevals` — Prebuilt Evaluators

```bash
pip install -U openevals
```

```python
from openevals.llm import create_llm_as_judge
from openevals.prompts import CORRECTNESS_PROMPT, CONCISENESS_PROMPT

judge = create_llm_as_judge(
    prompt=CORRECTNESS_PROMPT,
    model="openai:o3-mini",
    feedback_key="correctness",
)
result = judge(inputs=inputs, outputs=outputs, reference_outputs=ref)
```

Available prompts: `CORRECTNESS_PROMPT`, `CONCISENESS_PROMPT`, `HELPFULNESS_PROMPT`, `HARMFULNESS_PROMPT`

## References

- [Official Docs](https://docs.langchain.com/langsmith)
- [SDK GitHub](https://github.com/langchain-ai/langsmith-sdk)
- [ReadTheDocs API Reference](https://langsmith-sdk.readthedocs.io/en/stable/)
- [openevals GitHub](https://github.com/langchain-ai/openevals)

# LangSmith TypeScript/JavaScript SDK Reference

> Source: https://docs.langchain.com/langsmith | SDK: `langsmith` (npm)
> Install: `npm install langsmith`

## Environment Variables

```bash
export LANGSMITH_API_KEY="lsv2_..."
export LANGSMITH_TRACING=true
export LANGSMITH_PROJECT="my-project"  # optional
export LANGSMITH_ENDPOINT="..."         # self-hosted only
```

## `traceable()` Wrapper

```typescript
import { traceable } from "langsmith/traceable";

// Wrap an async function
const pipeline = traceable(
    async (question: string): Promise<string> => {
        const result = await myLLM(question);
        return result;
    },
    {
        name: "My Pipeline",
        // run_type, tags, metadata also available
    }
);

await pipeline("What is LangSmith?");
```

## `wrapOpenAI()` and Other Wrappers

```typescript
import { wrapOpenAI } from "langsmith/wrappers";
import { OpenAI } from "openai";

const client = wrapOpenAI(new OpenAI());
// All chat.completions.create() calls are now traced
```

## `Client` — Core Methods

```typescript
import { Client } from "langsmith";

const client = new Client({
    apiKey: process.env.LANGSMITH_API_KEY,
    // apiUrl: "https://api.smith.langchain.com"  // self-hosted
});
```

### Datasets

```typescript
// Create
const dataset = await client.createDataset("My Dataset");

// Add examples
await client.createExamples({
    inputs: [{ question: "Capital of France?" }],
    outputs: [{ answer: "Paris" }],
    datasetId: dataset.id
});

// List
for await (const ds of client.listDatasets()) {
    console.log(ds.name);
}

// Delete
await client.deleteDataset({ datasetId: dataset.id });
```

### Evaluation

```typescript
import { evaluate } from "langsmith/evaluation";
import type { EvaluationResult } from "langsmith/evaluation";

// Target function
async function myApp(inputs: Record<string, any>) {
    return { answer: await callLLM(inputs.question) };
}

// Evaluator
function exactMatch({ inputs, outputs, referenceOutputs }: {
    inputs: Record<string, any>;
    outputs: Record<string, any>;
    referenceOutputs?: Record<string, any>;
}): EvaluationResult {
    return {
        key: "exact_match",
        score: outputs.answer === referenceOutputs?.answer ? 1 : 0
    };
}

// Run experiment
await evaluate(myApp, {
    data: "My Dataset",
    evaluators: [exactMatch],
    experimentPrefix: "v1-baseline",
    maxConcurrency: 4
});
```

### Feedback

```typescript
// Attach feedback to a run
await client.createFeedback(
    runId,          // string UUID
    "thumbs_up",    // feedback key
    {
        score: 1,
        comment: "Great response"
    }
);
```

### Feedback Config

```typescript
// Continuous (0-1 slider)
await client.createFeedbackConfig({
    feedbackKey: "accuracy",
    feedbackConfig: { type: "continuous", min: 0, max: 1 }
});

// Categorical
await client.createFeedbackConfig({
    feedbackKey: "label",
    feedbackConfig: {
        type: "categorical",
        categories: [
            { value: 1, label: "Pass" },
            { value: 0, label: "Fail" }
        ]
    }
});

// Freeform
await client.createFeedbackConfig({
    feedbackKey: "notes",
    feedbackConfig: { type: "freeform" }
});

// List
for await (const cfg of client.listFeedbackConfigs()) {
    console.log(cfg.feedbackKey);
}
```

### Annotation Queues

```typescript
const queue = await client.createAnnotationQueue({
    name: "Review Queue",
    rubricItems: [
        {
            feedback_key: "accuracy",
            description: "How accurate is the response?",
            is_required: true
        }
    ]
});
```

### Prompt Hub

```typescript
import { Client } from "langsmith";
import { ChatPromptTemplate } from "@langchain/core/prompts";
import { pull } from "langchain/hub";

const client = new Client();

// Push
const prompt = ChatPromptTemplate.fromMessages([
    ["system", "You are a helpful assistant."],
    ["user", "{question}"],
]);
await client.pushPrompt("my-prompt", { object: prompt });

// Pull
const pulled = await pull("my-prompt");
const formatted = await pulled.invoke({ question: "What is LangSmith?" });
```

### Projects

```typescript
await client.createProject({ projectName: "my-project" });
await client.deleteProject({ projectName: "old-project" });

for await (const proj of client.listProjects()) {
    console.log(proj.name);
}
```

## LangChain (TypeScript) Integration

```typescript
import { LangChainTracer } from "@langchain/core/tracers/tracer_langchain";
import { getLangchainCallbacks } from "langsmith/langchain";

// Static tracer
const tracer = new LangChainTracer({ projectName: "My Project" });
await chain.invoke({ input: "..." }, { callbacks: [tracer] });

// Dynamic callbacks inside traceable (recommended)
const main = traceable(async (input: string) => {
    const callbacks = await getLangchainCallbacks();
    return await chain.invoke({ input }, { callbacks });
}, { name: "main" });
```

## Wait for Async Trace Flush

```typescript
import { awaitAllCallbacks } from "@langchain/core/callbacks/promises";

try {
    const result = await llm.invoke("...");
} finally {
    await awaitAllCallbacks();  // Flush all pending traces
}
```

## Custom Run ID for Feedback

```typescript
import { v4 as uuidv4 } from "uuid";

const runId = uuidv4();
const result = await chain.invoke(
    { input: "..." },
    { runId }
);

// Later attach feedback
await client.createFeedback(runId, "correctness", { score: 1 });
```

## References

- [Official Docs](https://docs.langchain.com/langsmith)
- [langsmith npm](https://www.npmjs.com/package/langsmith)
- [SDK GitHub](https://github.com/langchain-ai/langsmith-sdk)
- [JS Reference Docs](https://docs.smith.langchain.com/reference/js/)

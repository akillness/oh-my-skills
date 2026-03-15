#!/usr/bin/env python3
"""
LangSmith Quickstart Script
Demonstrates: tracing, evaluation, datasets, feedback, and prompt hub.

Prerequisites:
    pip install -U langsmith openai openevals
    export LANGSMITH_API_KEY="lsv2_..."
    export LANGSMITH_TRACING=true
    export OPENAI_API_KEY="sk-..."

Usage:
    python3 quickstart.py [--trace | --eval | --prompt | --all]
"""
import os
import sys
import argparse
import uuid

def check_env():
    missing = []
    if not os.getenv("LANGSMITH_API_KEY"):
        missing.append("LANGSMITH_API_KEY")
    if not os.getenv("LANGSMITH_TRACING"):
        print("⚠  LANGSMITH_TRACING not set — setting to 'true' for this run")
        os.environ["LANGSMITH_TRACING"] = "true"
    if missing:
        print(f"✗ Missing env vars: {', '.join(missing)}")
        print("  Run: bash scripts/setup.sh")
        sys.exit(1)


# ── Demo 1: Basic tracing ─────────────────────────────────────────────────────
def demo_trace():
    print("\n── Demo 1: Tracing ──────────────────────────────────────────────")
    try:
        from langsmith import traceable
        from langsmith.wrappers import wrap_openai
        from openai import OpenAI

        client = wrap_openai(OpenAI())

        @traceable(name="LangSmith Quickstart / RAG")
        def pipeline(question: str) -> str:
            response = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": question}]
            )
            return response.choices[0].message.content

        result = pipeline("What is LangSmith used for?")
        print(f"✓ Response: {result[:120]}...")
        print("✓ Trace saved — view at: https://smith.langchain.com")
    except Exception as e:
        print(f"✗ Trace demo failed: {e}")


# ── Demo 2: Dataset + evaluation ─────────────────────────────────────────────
def demo_eval():
    print("\n── Demo 2: Evaluation ───────────────────────────────────────────")
    try:
        from langsmith import Client
        from langsmith.wrappers import wrap_openai
        from openai import OpenAI

        ls_client = Client()
        oai = wrap_openai(OpenAI())

        DATASET_NAME = "LangSmith-Quickstart-Demo"

        # Create (or reuse) dataset
        existing = [d for d in ls_client.list_datasets() if d.name == DATASET_NAME]
        if existing:
            dataset = existing[0]
            print(f"  Using existing dataset: {DATASET_NAME}")
        else:
            dataset = ls_client.create_dataset(DATASET_NAME)
            ls_client.create_examples(
                dataset_id=dataset.id,
                examples=[
                    {"inputs": {"q": "Capital of France?"}, "outputs": {"a": "Paris"}},
                    {"inputs": {"q": "Capital of Japan?"}, "outputs": {"a": "Tokyo"}},
                    {"inputs": {"q": "Capital of Brazil?"}, "outputs": {"a": "Brasília"}},
                ]
            )
            print(f"  Created dataset: {DATASET_NAME} (3 examples)")

        # Target function
        def target(inputs: dict) -> dict:
            res = oai.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": f"Answer in one word: {inputs['q']}"}]
            )
            return {"a": res.choices[0].message.content.strip()}

        # Evaluator
        def contains_answer(inputs, outputs, reference_outputs):
            expected = reference_outputs["a"].lower()
            got = outputs["a"].lower()
            return {"key": "contains_answer", "score": int(expected in got)}

        results = ls_client.evaluate(
            target,
            data=DATASET_NAME,
            evaluators=[contains_answer],
            experiment_prefix="quickstart-demo",
            max_concurrency=2
        )
        print(f"✓ Experiment complete — view at: https://smith.langchain.com")
        print(f"  Results: {results}")
    except Exception as e:
        print(f"✗ Eval demo failed: {e}")


# ── Demo 3: Feedback ──────────────────────────────────────────────────────────
def demo_feedback():
    print("\n── Demo 3: Feedback ─────────────────────────────────────────────")
    try:
        from langsmith import Client, traceable
        from langsmith.wrappers import wrap_openai
        from openai import OpenAI

        ls_client = Client()
        oai = wrap_openai(OpenAI())

        run_id = str(uuid.uuid4())

        @traceable(name="feedback-demo")
        def answer(question: str) -> str:
            res = oai.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": question}]
            )
            return res.choices[0].message.content

        result = answer.__wrapped__("What is 2 + 2?") if hasattr(answer, '__wrapped__') else answer("What is 2 + 2?")

        ls_client.create_feedback(
            key="thumbs_up",
            score=1,
            comment="Correct!",
            run_id=run_id
        )
        print(f"✓ Feedback attached to run: {run_id}")
    except Exception as e:
        print(f"✗ Feedback demo failed: {e}")


# ── Demo 4: Prompt Hub ────────────────────────────────────────────────────────
def demo_prompt():
    print("\n── Demo 4: Prompt Hub ───────────────────────────────────────────")
    try:
        from langsmith import Client

        ls_client = Client()

        try:
            from langchain_core.prompts import ChatPromptTemplate
        except ImportError:
            print("  langchain_core not installed — run: pip install langchain_core")
            return

        prompt = ChatPromptTemplate([
            ("system", "You are a helpful AI assistant."),
            ("user", "{question}"),
        ])

        PROMPT_NAME = "langsmith-quickstart-demo-prompt"
        ls_client.push_prompt(PROMPT_NAME, object=prompt)
        pulled = ls_client.pull_prompt(PROMPT_NAME)
        print(f"✓ Prompt pushed and pulled: {PROMPT_NAME}")
        print(f"  Messages: {[m.prompt.template for m in pulled.messages]}")
    except Exception as e:
        print(f"✗ Prompt demo failed: {e}")


def main():
    parser = argparse.ArgumentParser(description="LangSmith Quickstart")
    parser.add_argument("--trace", action="store_true")
    parser.add_argument("--eval", action="store_true")
    parser.add_argument("--feedback", action="store_true")
    parser.add_argument("--prompt", action="store_true")
    parser.add_argument("--all", action="store_true", default=True)
    args = parser.parse_args()

    check_env()

    run_all = args.all and not any([args.trace, args.eval, args.feedback, args.prompt])

    if args.trace or run_all:
        demo_trace()
    if args.eval or run_all:
        demo_eval()
    if args.feedback or run_all:
        demo_feedback()
    if args.prompt or run_all:
        demo_prompt()

    print("\n✓ Quickstart complete — view results at: https://smith.langchain.com\n")


if __name__ == "__main__":
    main()

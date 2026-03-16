"""
overnight-agent.py — Run Claude Agent SDK tasks autonomously overnight.

This uses the Agent SDK (pip install claude-agent-sdk) for more control
than the CLI: hooks, budget limits, structured output, and subagents.

Usage:
    python scripts/overnight-agent.py
    python scripts/overnight-agent.py --task "implement payment links"
    python scripts/overnight-agent.py --budget 10.0
    MAX_BUDGET_USD=20 python scripts/overnight-agent.py

Prerequisites:
    pip install claude-agent-sdk
    export ANTHROPIC_API_KEY=your-key
"""

import anyio
import os
import sys
import json
from datetime import datetime
from pathlib import Path

try:
    from claude_agent_sdk import (
        query,
        ClaudeAgentOptions,
        ResultMessage,
        SystemMessage,
        AgentDefinition,
    )
except ImportError:
    print("Install the Agent SDK: pip install claude-agent-sdk")
    sys.exit(1)


LOG_DIR = Path("logs/overnight")
LOG_DIR.mkdir(parents=True, exist_ok=True)

TIMESTAMP = datetime.now().strftime("%Y%m%d-%H%M%S")


def load_tasks(tasks_file: str = "scripts/tasks.txt") -> list[str]:
    """Load tasks from file, skipping comments and blank lines."""
    tasks = []
    path = Path(tasks_file)
    if not path.exists():
        return tasks
    for line in path.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            tasks.append(line)
    return tasks


async def run_task(
    task_num: int,
    total: int,
    prompt: str,
    cwd: str,
    budget: float,
    max_turns: int,
) -> dict:
    """Run a single task and return result summary."""
    log_file = LOG_DIR / f"task-{task_num}-{TIMESTAMP}.json"
    print(f"\n━━━ TASK {task_num}/{total} ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"  Prompt: {prompt[:100]}{'...' if len(prompt) > 100 else ''}")

    result = {
        "task_num": task_num,
        "prompt": prompt,
        "status": "unknown",
        "duration_s": 0,
        "output": "",
        "error": None,
        "session_id": None,
    }

    start = datetime.now()
    try:
        async for message in query(
            prompt=prompt,
            options=ClaudeAgentOptions(
                cwd=cwd,
                allowed_tools=[
                    "Read", "Write", "Edit", "Bash",
                    "Glob", "Grep", "Agent",
                    "WebSearch", "WebFetch",
                ],
                permission_mode="bypassPermissions",
                max_turns=max_turns,
                max_budget_usd=budget,
            ),
        ):
            if isinstance(message, ResultMessage):
                result["output"] = message.result or ""
                result["status"] = "passed"
                print(f"  ✅ PASSED")
            elif isinstance(message, SystemMessage) and message.subtype == "init":
                result["session_id"] = message.data.get("session_id")

    except Exception as e:
        result["status"] = "failed"
        result["error"] = str(e)
        print(f"  ❌ FAILED: {e}")

    result["duration_s"] = (datetime.now() - start).total_seconds()
    log_file.write_text(json.dumps(result, indent=2, default=str))
    print(f"  Duration: {result['duration_s']:.0f}s | Log: {log_file}")

    return result


async def main():
    import argparse

    parser = argparse.ArgumentParser(description="Overnight autonomous agent runner")
    parser.add_argument("--task", type=str, help="Single task to run")
    parser.add_argument("--file", type=str, default="scripts/tasks.txt", help="Tasks file")
    parser.add_argument("--budget", type=float, default=float(os.environ.get("MAX_BUDGET_USD", "5.0")))
    parser.add_argument("--max-turns", type=int, default=200)
    parser.add_argument("--cwd", type=str, default=os.getcwd())
    args = parser.parse_args()

    tasks = [args.task] if args.task else load_tasks(args.file)
    if not tasks:
        print("No tasks found. Add tasks to scripts/tasks.txt or use --task")
        return

    print(f"═══════════════════════════════════════════════")
    print(f"  OVERNIGHT AGENT RUN — {TIMESTAMP}")
    print(f"  Tasks: {len(tasks)} | Budget: ${args.budget}/task | Max turns: {args.max_turns}")
    print(f"═══════════════════════════════════════════════")

    results = []
    for i, task in enumerate(tasks, 1):
        r = await run_task(i, len(tasks), task, args.cwd, args.budget, args.max_turns)
        results.append(r)

    # Summary
    passed = sum(1 for r in results if r["status"] == "passed")
    failed = sum(1 for r in results if r["status"] == "failed")
    total_time = sum(r["duration_s"] for r in results)

    summary = {
        "timestamp": TIMESTAMP,
        "total": len(results),
        "passed": passed,
        "failed": failed,
        "total_duration_s": total_time,
        "tasks": results,
    }

    summary_file = LOG_DIR / f"summary-{TIMESTAMP}.json"
    summary_file.write_text(json.dumps(summary, indent=2, default=str))

    print(f"\n═══════════════════════════════════════════════")
    print(f"  COMPLETE: {passed}✅ {failed}❌ | {total_time:.0f}s total")
    print(f"  Summary: {summary_file}")
    print(f"═══════════════════════════════════════════════")

    sys.exit(1 if failed > 0 else 0)


if __name__ == "__main__":
    anyio.run(main)

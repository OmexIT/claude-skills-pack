#!/usr/bin/env python3
"""Summarize local Claude Code skill, command, prompt, and project usage."""

import argparse
import collections
import glob
import json
import os
import re


def parse_args():
    home = os.path.expanduser("~")
    parser = argparse.ArgumentParser(
        description=(
            "Summarize local Claude Code transcripts. The default run is read-only and "
            "does not persist prompt text."
        )
    )
    parser.add_argument(
        "--projects-root",
        default=os.path.join(home, ".claude", "projects"),
        help="Claude Code projects directory (default: ~/.claude/projects)",
    )
    parser.add_argument(
        "--history-file",
        default=os.path.join(home, ".claude", "history.jsonl"),
        help="Claude Code history file (default: ~/.claude/history.jsonl)",
    )
    parser.add_argument(
        "--corpus-dir",
        help=(
            "Explicitly write raw prompt excerpts to this directory. Treat the output as "
            "sensitive and never commit it."
        ),
    )
    parser.add_argument(
        "--max-prompt-chars",
        type=int,
        default=1500,
        help="Maximum characters per prompt when --corpus-dir is used (default: 1500)",
    )
    args = parser.parse_args()
    if args.max_prompt_chars < 1:
        parser.error("--max-prompt-chars must be positive")
    return args


def empty_project_stats():
    return {"sessions": 0, "user_msgs": 0, "first": None, "last": None}


def note_timestamp(project_stats, project, timestamp):
    if not timestamp:
        return
    stats = project_stats[project]
    if not stats["first"] or timestamp < stats["first"]:
        stats["first"] = timestamp
    if not stats["last"] or timestamp > stats["last"]:
        stats["last"] = timestamp


def message_text(content):
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        return None
    parts = [
        item.get("text", "")
        for item in content
        if isinstance(item, dict) and item.get("type") == "text"
    ]
    return "\n".join(part for part in parts if part)


def mine_transcripts(projects_root, max_prompt_chars, capture_prompts):
    skill_use = collections.Counter()
    command_use = collections.Counter()
    agent_use = collections.Counter()
    project_stats = collections.defaultdict(empty_project_stats)
    prompts = []
    prompt_count = 0

    pattern = os.path.join(os.path.expanduser(projects_root), "*", "*.jsonl")
    for path in glob.glob(pattern):
        project = os.path.basename(os.path.dirname(path))
        project_stats[project]["sessions"] += 1
        try:
            handle = open(path, "r", errors="replace", encoding="utf-8")
        except OSError:
            continue

        with handle:
            for line in handle:
                if len(line) > 3_000_000:
                    continue
                try:
                    record = json.loads(line)
                except (json.JSONDecodeError, TypeError, ValueError):
                    continue

                timestamp = record.get("timestamp")
                record_type = record.get("type")
                message = record.get("message") or {}
                content = message.get("content")

                if record_type == "assistant" and isinstance(content, list):
                    for item in content:
                        if not isinstance(item, dict) or item.get("type") != "tool_use":
                            continue
                        name = item.get("name")
                        tool_input = item.get("input") or {}
                        if name == "Skill":
                            skill = tool_input.get("skill") or tool_input.get("command") or "?"
                            skill_use[skill] += 1
                            note_timestamp(project_stats, project, timestamp)
                        elif name in ("Task", "Agent"):
                            agent = tool_input.get("subagent_type") or "general-purpose"
                            agent_use[agent] += 1
                    continue

                if record_type != "user" or record.get("isSidechain"):
                    continue

                text = message_text(content)
                if not text or not text.strip():
                    continue
                note_timestamp(project_stats, project, timestamp)

                command_match = re.search(
                    r"<command-name>\s*(/?[\w.:_-]+)\s*</command-name>", text
                )
                if command_match:
                    command_use[command_match.group(1).lstrip("/")] += 1
                    continue
                if record.get("isMeta"):
                    continue

                head = text[:80]
                ignored_markers = (
                    "system-reminder",
                    "local-command",
                    "command-name",
                    "task-notification",
                    "bash-",
                )
                if head.startswith("<") and any(marker in head for marker in ignored_markers):
                    continue
                if "Caveat: The messages below" in head:
                    continue

                project_stats[project]["user_msgs"] += 1
                prompt_count += 1
                if capture_prompts:
                    prompts.append(
                        {"p": project, "ts": timestamp, "t": text[:max_prompt_chars]}
                    )

    return {
        "skill_use": skill_use,
        "command_use": command_use,
        "agent_use": agent_use,
        "project_stats": project_stats,
        "prompts": prompts,
        "prompt_count": prompt_count,
    }


def mine_history(history_file, max_prompt_chars, capture_prompts):
    commands = collections.Counter()
    prompts = []
    prompt_count = 0
    path = os.path.expanduser(history_file)
    if not os.path.exists(path):
        return commands, prompts, prompt_count

    try:
        handle = open(path, "r", errors="replace", encoding="utf-8")
    except OSError:
        return commands, prompts, prompt_count

    with handle:
        for line in handle:
            try:
                record = json.loads(line)
            except (json.JSONDecodeError, TypeError, ValueError):
                continue
            display = (record.get("display") or "").strip()
            if not display:
                continue
            if display.startswith("/"):
                commands[display.split()[0].lstrip("/")] += 1
            else:
                prompt_count += 1
                if capture_prompts:
                    prompts.append(
                        {
                            "p": record.get("project", "?"),
                            "ts": record.get("timestamp"),
                            "t": display[:max_prompt_chars],
                        }
                    )
    return commands, prompts, prompt_count


def write_jsonl(path, records):
    with open(path, "w", encoding="utf-8") as handle:
        for record in records:
            handle.write(json.dumps(record) + "\n")


def format_timestamp(timestamp):
    return str(timestamp or "?")[:10]


def print_summary(results, history_commands, history_prompt_count):
    print("== PER-PROJECT ACTIVITY (sessions / user msgs / first..last) ==")
    project_stats = results["project_stats"]
    for project, stats in sorted(
        project_stats.items(), key=lambda item: -item[1]["user_msgs"]
    ):
        print(
            f"{stats['sessions']:4d} sess {stats['user_msgs']:5d} msgs  "
            f"{format_timestamp(stats['first'])}..{format_timestamp(stats['last'])}  "
            f"{project}"
        )

    print("\n== SKILL TOOL INVOCATIONS (all time, all projects) ==")
    for skill, count in results["skill_use"].most_common(80):
        print(f"{count:5d}  {skill}")

    print("\n== SLASH COMMANDS SEEN IN TRANSCRIPTS ==")
    for command, count in results["command_use"].most_common(60):
        print(f"{count:5d}  {command}")

    print("\n== SLASH COMMANDS TYPED (history.jsonl) ==")
    for command, count in history_commands.most_common(60):
        print(f"{count:5d}  {command}")

    print("\n== AGENT/TASK SUBAGENT TYPES ==")
    for agent, count in results["agent_use"].most_common(30):
        print(f"{count:5d}  {agent}")

    print(
        "\nTotal prompt records: "
        f"transcripts={results['prompt_count']} history={history_prompt_count}"
    )


def main():
    args = parse_args()
    capture_prompts = bool(args.corpus_dir)
    results = mine_transcripts(
        args.projects_root, args.max_prompt_chars, capture_prompts
    )
    history_commands, history_prompts, history_prompt_count = mine_history(
        args.history_file, args.max_prompt_chars, capture_prompts
    )
    print_summary(results, history_commands, history_prompt_count)

    if args.corpus_dir:
        corpus_dir = os.path.abspath(os.path.expanduser(args.corpus_dir))
        os.makedirs(corpus_dir, exist_ok=True)
        write_jsonl(
            os.path.join(corpus_dir, "corpus_transcripts.jsonl"), results["prompts"]
        )
        write_jsonl(
            os.path.join(corpus_dir, "corpus_history.jsonl"), history_prompts
        )
        print(f"Sensitive corpus files written to {corpus_dir}")
    else:
        print("Prompt corpus not written; use --corpus-dir for an explicit sensitive export.")


if __name__ == "__main__":
    main()

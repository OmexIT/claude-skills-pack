#!/usr/bin/env python3
"""Pre-Bash Hook — block irreversible or high-blast-radius commands.

Reads the PreToolUse JSON payload from stdin (tool_input.command). Exit 2 with a
stderr message blocks the call; exit 0 allows it. Patterns are tuned for fintech
work (protects databases, volumes, protected branches).
"""
import json
import re
import sys

BLOCK_PATTERNS = [
    (r"\brm\s+-rf\s+/($|\s)", "rm -rf /"),
    (r"\brm\s+-rf\s+~/?($|\s)", "rm -rf ~"),
    (r"\brm\s+-rf\s+/\*", "rm -rf /*"),
    (r"\bdd\s+.*\bof=/dev/(?!null\b)", "dd writing to raw device"),
    (r":\(\)\s*\{\s*:\s*\|\s*:\s*&\s*\}\s*;\s*:", "fork bomb"),
    (r"\bmkfs\.", "mkfs"),
    (r">\s*/dev/sd[a-z]", "direct disk write"),
    (r"\bgit\s+push\b(?=.*\s(-f|--force)(\s|$))(?=.*\b(main|master|production|prod)\b)",
     "force push protected branch"),
    (r"\bgit\s+reset\s+--hard\s+origin/(main|master|production)",
     "hard reset protected branch"),
    (r"\bDROP\s+DATABASE\b", "DROP DATABASE"),
    (r'\bDROP\s+SCHEMA\s+(IF\s+EXISTS\s+)?[\w"]+\s+CASCADE', "DROP SCHEMA CASCADE"),
    (r'\bTRUNCATE\s+(TABLE\s+)?[\w."]+', "TRUNCATE TABLE (use tenant-scoped delete instead)"),
    (r"\bdocker\s+system\s+prune\s+(-a|--all|--force)", "docker system prune -a"),
    (r"\bdocker\s+volume\s+rm\s+", "docker volume rm (data loss)"),
    (r"\bdocker\s+(volume\s+prune|system\s+prune\s+.*--volumes)", "docker volume prune (data loss)"),
]


def strip_commit_messages(cmd):
    """Blank out quoted -m payloads of git commit/tag: message text describing a
    blocked command is data, not an executed command. Other quoted args (psql -c,
    bash -c) are still scanned."""
    def clean(segment):
        return re.sub(r"""(-m\s+)('[^']*'|"[^"]*")""", r"\1''", segment.group(0))
    return re.sub(r"\bgit\s+(commit|tag)\b[^;|&]*", clean, cmd)


def main():
    try:
        data = json.loads(sys.stdin.read() or "{}")
    except (json.JSONDecodeError, ValueError):
        data = {}
    cmd = (data.get("tool_input", {}) or {}).get("command", "")
    if not cmd and len(sys.argv) > 1:  # legacy argv fallback
        cmd = sys.argv[1]
    scan = strip_commit_messages(cmd)
    for pat, label in BLOCK_PATTERNS:
        if re.search(pat, scan, re.IGNORECASE):
            print(
                f"[pre-bash] BLOCKED: {label}\n  command: {cmd[:200]}",
                file=sys.stderr,
            )
            sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Pre-Bash Hook — block irreversible or high-blast-radius commands."""
import re
import sys

BLOCK_PATTERNS = [
    (r"\brm\s+-rf\s+/($|\s)", "rm -rf /"),
    (r"\brm\s+-rf\s+~($|\s)", "rm -rf ~"),
    (r"\brm\s+-rf\s+/\*", "rm -rf /*"),
    (r"\bdd\s+if=", "dd if="),
    (r":\(\)\{:\|:&\};:", "fork bomb"),
    (r"\bmkfs\.", "mkfs"),
    (r">\s*/dev/sd[a-z]", "direct disk write"),
    (r"\bgit\s+push\s+(-f|--force)\s+.*\b(main|master|production|prod)\b",
     "force push protected branch"),
    (r"\bgit\s+reset\s+--hard\s+origin/(main|master|production)",
     "hard reset protected branch"),
    (r"\bDROP\s+DATABASE\b", "DROP DATABASE"),
    (r"\bDROP\s+SCHEMA\s+\w+\s+CASCADE", "DROP SCHEMA CASCADE"),
    (r"\bTRUNCATE\s+TABLE\s+\w+\s*;", "TRUNCATE TABLE (use tenant-scoped delete instead)"),
    (r"\bdocker\s+system\s+prune\s+(-a|--all|--force)", "docker system prune -a"),
    (r"\bdocker\s+volume\s+rm\s+", "docker volume rm (data loss)"),
]


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    for pat, label in BLOCK_PATTERNS:
        if re.search(pat, cmd, re.IGNORECASE):
            print(
                f"[pre-bash] BLOCKED: {label}\n  command: {cmd[:200]}",
                file=sys.stderr,
            )
            sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()

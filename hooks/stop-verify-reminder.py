#!/usr/bin/env python3
"""Stop Hook — remind to verify and commit if code was modified in this session.

Uses root-level `systemMessage` (the correct shape for Stop hooks — Stop does NOT
support `hookSpecificOutput`).
"""
import json
import os
import sys
from pathlib import Path


def main():
    log_dir = Path.cwd() / ".claude" / "state"
    if not log_dir.exists():
        sys.exit(0)

    session_id = os.environ.get("CLAUDE_CODE_SSE_PORT", "default")
    log_file = log_dir / f"session-{session_id}.log"
    if not log_file.exists():
        sys.exit(0)

    try:
        content = log_file.read_text().lower()
    except OSError:
        sys.exit(0)

    modification_keywords = ("implement", "add ", "fix ", "refactor", "create ", "build ", "write ")
    if any(kw in content for kw in modification_keywords):
        reminder = {
            "systemMessage": (
                "VERIFICATION REMINDER — code was modified this session:\n"
                "  1. Run tests: ./gradlew test  |  ./mvnw test  |  npm test\n"
                "  2. Verify compilation: ./gradlew compileJava  |  tsc --noEmit\n"
                "  3. Run /verify-impl for live testing if implementation is complete\n"
                "  4. Check git worktrees: /worktree-audit — ensure nothing left uncommitted\n"
                "  5. Commit with conventional commit format (feat/fix/refactor/...)"
            )
        }
        print(json.dumps(reminder))
    sys.exit(0)


if __name__ == "__main__":
    main()

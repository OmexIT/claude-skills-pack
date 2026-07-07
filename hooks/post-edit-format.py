#!/usr/bin/env python3
"""Post-Edit Hook — auto-format the edited file. Fast path only.

Prettier runs synchronously (typically <300ms, 10s cap) for web-stack files.
Java is deliberately NOT formatted here: a per-edit Gradle/Maven invocation
costs seconds to minutes each time; Spotless runs once in the `ship` gate
instead. Best-effort: never blocks, never errors.
"""
import json
import subprocess
import sys
from pathlib import Path

PRETTIER_EXTS = {".ts", ".tsx", ".js", ".jsx", ".json", ".css", ".md"}


def main():
    try:
        data = json.loads(sys.stdin.read() or "{}")
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    tool_input = data.get("tool_input", {}) or {}
    file_path = tool_input.get("file_path") or tool_input.get("path") or ""
    if not file_path:
        sys.exit(0)

    path = Path(file_path)
    if path.suffix.lower() not in PRETTIER_EXTS or not path.exists():
        sys.exit(0)

    # Nearest local prettier install wins; stop at the repo boundary.
    for parent in path.parents:
        prettier = parent / "node_modules" / ".bin" / "prettier"
        if prettier.exists():
            try:
                subprocess.run(
                    [str(prettier), "--write", str(path)],
                    cwd=parent, timeout=10, capture_output=True,
                )
            except (subprocess.TimeoutExpired, OSError):
                pass  # best-effort — never block
            break
        if (parent / ".git").exists():
            break
    sys.exit(0)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Post-Edit Hook — auto-format modified file based on extension + project root.

Best-effort: never blocks, never errors. Runs Spotless for Java (Gradle/Maven) and
Prettier for TS/JS/JSON/CSS/MD. Exits silently on any failure.
"""
import json
import subprocess
import sys
from pathlib import Path


def read_input() -> dict:
    try:
        return json.loads(sys.stdin.read() or "{}")
    except (json.JSONDecodeError, ValueError):
        return {}


def find_project_root(path: Path):
    for p in [path] + list(path.parents):
        for marker in ("build.gradle", "build.gradle.kts", "pom.xml", "package.json", ".git"):
            if (p / marker).exists():
                return p
    return None


def format_java(file: Path, root: Path):
    gradlew = root / "gradlew"
    mvnw = root / "mvnw"
    if gradlew.exists():
        subprocess.run(
            [str(gradlew), "spotlessApply", f"-PspotlessFiles={file}"],
            cwd=root, timeout=90, capture_output=True,
        )
    elif mvnw.exists():
        subprocess.run(
            [str(mvnw), "spotless:apply", f"-DspotlessFiles={file}"],
            cwd=root, timeout=90, capture_output=True,
        )


def format_js(file: Path, root: Path):
    prettier = root / "node_modules" / ".bin" / "prettier"
    if prettier.exists():
        subprocess.run(
            [str(prettier), "--write", str(file)],
            cwd=root, timeout=30, capture_output=True,
        )


def main():
    data = read_input()
    tool_input = data.get("tool_input", {}) or {}
    file_path = tool_input.get("file_path") or tool_input.get("path")
    if not file_path:
        sys.exit(0)

    path = Path(file_path)
    if not path.exists():
        sys.exit(0)

    root = find_project_root(path)
    if not root:
        sys.exit(0)

    ext = path.suffix.lower()
    try:
        if ext == ".java":
            format_java(path, root)
        elif ext in (".ts", ".tsx", ".js", ".jsx", ".json", ".css", ".md"):
            format_js(path, root)
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
        pass  # best-effort — never block

    sys.exit(0)


if __name__ == "__main__":
    main()

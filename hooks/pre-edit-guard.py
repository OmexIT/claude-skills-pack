#!/usr/bin/env python3
"""Pre-Edit Hook — warn on editing sensitive files (non-blocking).

NOTE: PreToolUse hookSpecificOutput only accepts permissionDecision /
permissionDecisionReason / updatedInput. It does NOT accept additionalContext.
For a non-blocking warning, print to stderr and exit 0 — Claude Code surfaces
stderr from hooks to the user without failing the tool call.
"""
import json
import sys
from pathlib import Path

SENSITIVE_PATTERNS = (
    ".env",
    ".env.production",
    ".env.prod",
    "secrets.yaml",
    "secrets.yml",
    "application-prod.yaml",
    "application-prod.yml",
    "application-production.yaml",
    "application-production.yml",
    "terraform.tfvars",
    "credentials.json",
    "id_rsa",
    ".pem",
    ".p12",
    ".keystore",
)


def main():
    try:
        data = json.loads(sys.stdin.read() or "{}")
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    file_path = (data.get("tool_input", {}) or {}).get("file_path", "")
    if not file_path:
        sys.exit(0)

    name = Path(file_path).name
    if any(p in name for p in SENSITIVE_PATTERNS):
        print(
            f"[pre-edit-guard] SENSITIVE FILE: {name} — verify no real secrets are "
            "being committed or logged. Prefer environment variables or a secret manager.",
            file=sys.stderr,
        )
    sys.exit(0)


if __name__ == "__main__":
    main()

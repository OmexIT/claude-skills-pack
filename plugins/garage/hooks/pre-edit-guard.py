#!/usr/bin/env python3
"""Pre-Edit Hook - warn on editing sensitive files (non-blocking).

NOTE: on exit 0, Claude Code sends hook stderr to the debug log only; it is never
shown to the user or Claude. For a non-blocking warning, print a JSON object on
stdout and exit 0: a top-level "systemMessage" is shown to the user, and
PreToolUse hookSpecificOutput supports "additionalContext" (shown to Claude).
"""
import json
import sys
from pathlib import Path

SENSITIVE_NAMES = frozenset({
    ".env",
    "secrets.yaml",
    "secrets.yml",
    "application-prod.yaml",
    "application-prod.yml",
    "application-prod.properties",
    "application-production.yaml",
    "application-production.yml",
    "application-production.properties",
    "terraform.tfvars",
    "credentials.json",
    "id_rsa",
    "id_dsa",
    "id_ecdsa",
    "id_ed25519",
    "service-account.json",
})
SENSITIVE_SUFFIXES = (".pem", ".key", ".p12", ".pfx", ".jks", ".keystore")
TEMPLATE_SUFFIXES = (".example", ".sample", ".template")


def main():
    try:
        data = json.loads(sys.stdin.read() or "{}")
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    file_path = (data.get("tool_input", {}) or {}).get("file_path", "")
    if not file_path:
        sys.exit(0)

    name = Path(file_path).name
    if (
        name in SENSITIVE_NAMES
        or name.endswith(SENSITIVE_SUFFIXES)
        or (name.startswith(".env.") and not name.endswith(TEMPLATE_SUFFIXES))
    ):
        print(json.dumps({
            "systemMessage": (
                f"[pre-edit-guard] SENSITIVE FILE: {name} - verify no real secrets are "
                "being committed or logged. Prefer environment variables or a secret manager."
            ),
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "additionalContext": (
                    f"Editing sensitive file {name}: do not write real secrets; "
                    "prefer environment variables or a secret manager."
                ),
            },
        }))
    sys.exit(0)


if __name__ == "__main__":
    main()

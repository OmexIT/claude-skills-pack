# Hooks

Wired automatically via `hooks/hooks.json` when the `garage` plugin is enabled — no manual
settings.json editing.

| Hook | Event | Purpose |
|---|---|---|
| `pre-bash.py` | `PreToolUse(Bash)` | Blocks destructive commands: `rm -rf /`, `DROP DATABASE`, `TRUNCATE`, `docker volume rm`, force-push to protected branches. Exit 2 = block. |
| `pre-edit-guard.py` | `PreToolUse(Edit\|Write\|MultiEdit)` | Non-blocking stderr warning when editing sensitive files (`.env*`, `secrets.*`, `application-prod.*`, keys/keystores). |
| `post-edit-format.py` | `PostToolUse(Edit\|Write\|MultiEdit)` | Best-effort autoformat: Spotless (Gradle/Maven) for `.java`, Prettier for TS/JS/JSON/CSS/MD. Never blocks. |

## Protocol notes

- Hooks receive the event payload as JSON on **stdin** (`tool_input.command`, `tool_input.file_path`).
- Block: exit code 2 + message on stderr. Warn without blocking: stderr + exit 0. Side-effect hooks: exit 0 silently.
- Tune the fintech blocklist in `pre-bash.py` `BLOCK_PATTERNS`.

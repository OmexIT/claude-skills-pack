# Hooks

Wired automatically via `hooks/hooks.json` when the `garage` plugin is enabled - no manual
settings.json editing. These hooks use the Claude Code lifecycle-hook protocol. Codex installs
the shared skills but does not load these hooks.

| Hook | Event | Purpose |
|---|---|---|
| `pre-bash.py` | `PreToolUse(Bash)` | Blocks destructive commands: `rm -rf /` and `rm -rf ~`, fork bombs, `dd` to raw devices, `DROP DATABASE` / `DROP SCHEMA ... CASCADE`, `TRUNCATE` (incl. schema-qualified and TABLE-less forms), `docker volume rm`/`prune`, force-push and hard-reset on protected branches. `git commit/tag -m` message payloads are exempt (data, not commands); `--force-with-lease` is allowed. Exit 2 = block. |
| `pre-edit-guard.py` | `PreToolUse(Edit\|Write\|MultiEdit)` | Non-blocking `systemMessage` warning (stdout JSON) when editing sensitive files (`.env*`, `secrets.*`, `application-prod.*`, keys/keystores). |
| `post-edit-format.py` | `PostToolUse(Edit\|Write\|MultiEdit)` | Best-effort Prettier autoformat for TS/JS/JSON/CSS/MD (<~300ms, 10s cap). Java is deliberately NOT formatted per edit - a Gradle/Maven invocation costs seconds to minutes; Spotless runs once in the `ship` gate. |

## Protocol notes

- Hooks receive the event payload as JSON on **stdin** (`tool_input.command`, `tool_input.file_path`).
- Block: exit code 2 + message on stderr. Warn without blocking: print `{"systemMessage": "..."}` JSON on stdout + exit 0 (exit-0 stderr goes only to the debug log). Side-effect hooks: exit 0 silently.
- Tune the fintech blocklist in `pre-bash.py` `BLOCK_PATTERNS`.
- After ANY pattern change, run `python3 plugins/garage/hooks/test_hooks.py` from the
  marketplace root - every pattern keeps a paired should-block / should-pass case there. All
  cases must pass before shipping.
- Hooks load at session start from the installed plugin copy: after shipping a hook change, run `claude plugin update garage@garage` and restart the session for it to take effect.

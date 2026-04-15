# Claude Code Hooks

Shell and Python hook scripts that pair with the skills in this pack. They're wired into `~/.claude/settings.json` and fire on Claude Code tool-call lifecycle events (`PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`).

## What each hook does

| Hook | Event | Purpose |
|---|---|---|
| `pre-bash.py` | `PreToolUse(Bash)` | Blocks destructive/irreversible commands: `rm -rf /`, fork bombs, `mkfs`, force push to protected branches, `DROP DATABASE`, `TRUNCATE`, `docker volume rm`, etc. Exit code 2 = block. |
| `pre-edit-guard.py` | `PreToolUse(Edit\|Write\|MultiEdit)` | Non-blocking warning when editing sensitive files (`.env*`, `secrets.*`, `application-prod.*`, `credentials.json`, `id_rsa`, `.pem`, `.keystore`, `terraform.tfvars`). Prints to stderr, never blocks. |
| `post-edit-format.py` | `PostToolUse(Edit\|Write\|MultiEdit)` | Auto-formats saved files: Spotless (Gradle/Maven) for `.java`, Prettier for `.ts`/`.tsx`/`.js`/`.jsx`/`.json`/`.css`/`.md`. Best-effort — never blocks or errors. |
| `stop-verify-reminder.py` | `Stop` | Emits a `systemMessage` reminding to run tests, verify compilation, run `/verify-impl`, check git worktrees, and commit. Fires only if the session log contains modification keywords (`implement`, `add`, `fix`, `refactor`, `create`, `build`, `write`). |
| `log-prompt.py` | `UserPromptSubmit` | Appends each user prompt to a session-local log file (`.claude/state/session-<port>.log`) — used by `stop-verify-reminder.py` to detect whether the session modified code. |

## Install

1. Copy the scripts into `~/.claude/hooks/`:

```bash
mkdir -p ~/.claude/hooks
cp hooks/*.py ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.py
```

2. Wire them into `~/.claude/settings.json` under the `hooks` block:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "python3 ${HOME}/.claude/hooks/pre-bash.py \"$CLAUDE_TOOL_INPUT\"" }
        ]
      },
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          { "type": "command", "command": "python3 ${HOME}/.claude/hooks/pre-edit-guard.py" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          { "type": "command", "command": "python3 ${HOME}/.claude/hooks/post-edit-format.py" }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          { "type": "command", "command": "python3 ${HOME}/.claude/hooks/log-prompt.py" }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "python3 ${HOME}/.claude/hooks/stop-verify-reminder.py" }
        ]
      }
    ]
  }
}
```

3. Restart Claude Code (or `/clear`) so the new hook config loads.

## Design notes

### Hook output contract per event

Claude Code validates hook output against a strict JSON schema per event type. Getting the shape wrong produces `Hook JSON output validation failed` errors on every invocation — the hooks in this directory encode the correct shapes:

| Event | Valid root fields | Valid `hookSpecificOutput` shape |
|---|---|---|
| `PreToolUse` | `continue`, `suppressOutput`, `decision`, `reason`, `systemMessage`, `permissionDecision` | `{hookEventName: "PreToolUse", permissionDecision?, permissionDecisionReason?, updatedInput?}` |
| `PostToolUse` | same root fields | `{hookEventName: "PostToolUse", additionalContext?}` |
| `UserPromptSubmit` | same root fields | `{hookEventName: "UserPromptSubmit", additionalContext}` (required) |
| `Stop` | `continue`, `suppressOutput`, `stopReason`, `decision`, `reason`, `systemMessage` | **not supported** — Stop hooks cannot use `hookSpecificOutput` |

**Common mistake**: trying to use `hookSpecificOutput.additionalContext` for `Stop` or `PreToolUse`. Neither accepts it. For Stop, use root-level `systemMessage`. For PreToolUse non-blocking warnings, print to stderr and exit 0.

### Non-blocking vs blocking

- **Blocking PreToolUse**: return `{"permissionDecision": "deny", "permissionDecisionReason": "..."}` inside `hookSpecificOutput`, or exit code 2 with a message to stderr. `pre-bash.py` uses exit code 2 for hardcoded block patterns.
- **Non-blocking warning**: print to stderr, exit 0. `pre-edit-guard.py` uses this pattern.
- **Showing the user a message from Stop**: use root-level `systemMessage`. `stop-verify-reminder.py` uses this pattern.
- **Best-effort side effect**: exit 0 silently. `post-edit-format.py` and `log-prompt.py` use this pattern — they never interfere with Claude Code's flow.

### Session log

`log-prompt.py` writes each prompt to `./.claude/state/session-<CLAUDE_CODE_SSE_PORT>.log` in the **project working directory** (not in `~/.claude`). This keeps session state scoped to the project so multiple concurrent sessions don't collide. `stop-verify-reminder.py` reads the same file to decide whether to show the reminder.

The `.claude/state/` directory can be safely gitignored in every project — it's ephemeral per-session state.

## Dependencies

Python 3 stdlib only. No third-party packages. `post-edit-format.py` shells out to `./gradlew`, `./mvnw`, or `./node_modules/.bin/prettier` if they exist in the project root — and exits silently if none exist.

## Troubleshooting

**"Hook JSON output validation failed"** — the hook emitted JSON that doesn't match the schema for that event. Check the event's allowed shape above, especially `hookSpecificOutput` restrictions.

**"can't open file"** — the hook script path in `settings.json` is wrong, or the script isn't executable (`chmod +x`). The `${HOME}` expansion in settings.json should resolve correctly; if it doesn't, hardcode the absolute path.

**Hooks not firing** — run `claude mcp list` and check that Claude Code loaded the settings. Restart with `/clear` after editing `settings.json`. The settings are loaded at session start; changes mid-session don't take effect until restart.

**Pre-bash blocker too aggressive** — edit `BLOCK_PATTERNS` in `pre-bash.py`. The current list is tuned for fintech (blocks `DROP DATABASE`, `TRUNCATE`, `docker volume rm`, `git push --force` to protected branches).

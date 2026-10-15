# Running these skills in Claude Code and Codex

The skills are written once for both clients. Where a skill shows delegation or tracking in
Claude Code notation, read it as intent and use what the current client offers.

## Delegation

| Skill notation | Claude Code | Codex and other clients |
|---|---|---|
| `Agent(subagent_type=..., prompt=...)`, "dispatch the X agent" | Agent tool with that subagent type, or `general-purpose` if the type is not installed | Spawn a subagent if the client supports it; otherwise do that role yourself, one role at a time, in this session |
| "Dispatch all in one message" | Several Agent calls in one response so they run in parallel | Parallel only if the client can run subagents concurrently; sequential is correct, just slower |
| `run_in_background: true` | Same parameter on the Agent call | Run that role last, after the roles that block others |
| `isolation: "worktree"` | Same parameter on the Agent call | `git worktree add ../<repo>-<role> -b <role-branch>` per parallel writer, merged back as the skill describes |
| `SendMessage` to a finished agent | Continue it with its context intact | Re-run the role with the earlier output and the feedback in its prompt |

Roles in a roster are review lenses, not a requirement to fan out. When the user asks for
speed over breadth, or the change is small, run the lenses inline.

## Model labels

Rosters label each role `opus`, `sonnet`, or `haiku`. These mark how much reasoning the role
needs: `opus` deepest, `sonnet` standard, `haiku` light.

- Claude Code: pass the label as the subagent's `model`, or omit it to inherit the session model.
- Codex: map to reasoning effort (`high`, `medium`, `low`) if the client lets you set it per task; otherwise ignore the label.

## Progress tracking

Where a skill says `TaskCreate` / `TaskUpdate`, use the client's plan or task tool (Codex:
the plan tool). A visible checklist in the reply is an acceptable fallback.

## Project instructions

"Read CLAUDE.md" means read whichever project instruction files exist: `AGENTS.md`,
`CLAUDE.md`, and their nested copies in the directories being changed.

## Invoking a skill by name

Skills refer to each other by bare name (for example `finalize`). Invoke them as
`/garage:<name>` in Claude Code and `$garage:<name>` in Codex, or just ask for the work in plain words.

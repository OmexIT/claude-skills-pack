# Execution Mechanics: Parallel Dispatch, Worktrees, Merge

Read when the plan fans out to parallel writing agents, or when merging their branches. Inline
runs (small scope) skip this file. Notation is Claude Code; Codex mapping is in
`../../references/cross-client.md`.

## Dispatch

```
# Independent tasks of one wave go out in a single message so they run concurrently.
Agent(subagent_type: "general-purpose", model: "sonnet", isolation: "worktree", prompt: <BE task>)
Agent(subagent_type: "general-purpose", model: "sonnet", isolation: "worktree", prompt: <FE task>)

# Non-blocking roles (docs) can run in the background.
Agent(subagent_type: "general-purpose", model: "haiku", run_in_background: true, prompt: <TECH_WRITER task>)

# Codebase scanning before dispatch: subagent_type "Explore" (read-only).
# Review lens between agent completion and the wave gate: a general-purpose agent given the
# wave's diff and the contracts, or the orchestrator reviewing inline.
```

Use a worktree per writer only when two or more agents write code at the same time, especially
when they may touch shared files (build files, `package.json`, shared config). A single writer,
or writers in strictly sequential waves, work on the current branch. ARCH works on the current
branch, never in a worktree.

Each worktree result reports its path and branch; record both on the task board. To continue a
failed agent with its context, use `SendMessage` with the failure output.

## Merge back

Merge into the branch the work started on (the feature branch), never into the default branch.
Check repo delivery policy first; pushing, PRs, and merging to the default branch belong to
`finalize` and happen only when the user asks.

```bash
BASE=$(git rev-parse --abbrev-ref HEAD)        # the feature branch the run started on
git rev-parse HEAD                              # record as the pre-merge SHA (rollback point)
git merge --no-ff <agent-branch> -m "merge: <role> <scope> [TASK-<id>]"   # one per agent branch
```

Conflict rules:
- Shared contracts (DTOs, interfaces, schema): ARCH decides, updates the contract, notifies the
  affected agents.
- Independent files: should not conflict; if they do, look for a naming collision.
- Build and dependency files: keep both dependency sets, then rebuild.
- After resolving, run the full test suite before integration checks.

Rollback if the merged result is wrong: `git reset --hard <pre-merge SHA>` only after the user
confirms, since it discards the merges.

## Cleanup after a successful merge

```bash
git worktree list                     # confirm each agent worktree's branch is merged
git worktree remove <path>            # per merged worktree; refuses if it has uncommitted changes
git worktree prune                    # drop entries whose directories are already gone
git branch -d <agent-branch>          # -d refuses unmerged branches; never -D without asking
```

Leave `.spec-to-impl/evidence/` and `e2e/` in place: `verify-impl` and `finalize` read them.
Remove `e2e/.captures.json` (ephemeral capture data). List any `*.orig` / `*.bak` files from the
merge and ask before deleting them.

## Test commands by stack

Prefer the command the repo already defines (project instructions, `package.json` scripts,
Makefile, CI config). Fallbacks:

| Stack | Command |
|---|---|
| Java / Maven | `mvn test -pl <module>` |
| Java / Gradle | `./gradlew test` (or `:<module>:test`) |
| React (Vitest / Jest) | `npx vitest run` / `npx jest --ci` |
| AngularJS (Karma) | `npx karma start --single-run` |
| Flutter | `flutter test` |
| React Native | `npx jest --ci` |
| Android | `./gradlew testDebugUnitTest` |
| Migrations | the repo's Liquibase or Flyway validate task (see `db-migration`) |
| E2E | `npx playwright test` |
| Docker | `docker build . && docker compose config` |

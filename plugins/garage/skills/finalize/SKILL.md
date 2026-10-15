---
name: finalize
description: "Use when implementation is done and the user wants to wrap it up: finalize, commit this, create a PR, ship it, or done implementing."
---

# Finalize

Wrap up finished work: check, lint, test, clean up, commit, and only then the delivery steps the
user asked for. Nothing ships with failing checks, and nothing goes further than requested.

## 1. Policy and scope (before touching git)

- Read the repo's delivery policy: AGENTS.md / CLAUDE.md (a `## Ship policy` block if present),
  CONTRIBUTING, PR templates. It decides branch naming, commit format, whether commits go on a
  feature branch, PR base, and whether attribution trailers are allowed or required.
- Determine exactly which steps the user asked for: commit only, commit and push, open a PR, or
  merge. "Commit this" means a local commit. A bare "finalize" or "wrap it up" means lint, test,
  and a local commit, then ask before pushing or opening a PR. Merge only on an explicit request
  that the policy allows.
- If you are on the default branch and the policy (or the user's habit) requires a feature
  branch, create one before committing.
- Never add AI or tool attribution (co-author trailers, "generated with" footers) to commits or
  PRs unless the repo policy requires it.

Inputs, asked only if unclear: the feature or branch name, the PR base (from policy, else the
detected default branch), and files to exclude.

## 2. Scan

```bash
git status --short
git worktree list
DEFAULT=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@')
git branch --no-merged "${DEFAULT:-main}"
find . -path ./node_modules -prune -o \( -name '*.orig' -o -name '*.bak' -o -name '.DS_Store' \) -print
```

Report what you found before changing anything.

## 3. Review the diff

Read `git diff` for the files you will commit and fix: leftover debug output, commented-out code,
unused imports, to-do comments with no tracked follow-up, secrets or credentials, unrelated
changes. Only code in this change; pre-existing issues get mentioned, not fixed.

## 4. Lint and test

Use the commands the repo defines, in this order: project instructions, CI config,
`package.json` scripts, Makefile or task runner, the build tool's aggregate task (`./gradlew
check`, `mvn verify`). Fall back to a stack default only for tools the repo actually configures:

| Stack | Lint | Test |
|---|---|---|
| Java (Gradle / Maven) | configured Checkstyle, SpotBugs, or Spotless tasks | `./gradlew test` / `mvn test` |
| TypeScript / React | `npx eslint .` and `npx tsc --noEmit` | `npx vitest run` or `npx jest --ci` |
| Flutter / Dart | `dart analyze`, `dart format --set-exit-if-changed .` | `flutter test` |
| Android / Kotlin | configured ktlint or detekt | `./gradlew testDebugUnitTest` |
| E2E (if the change touches flows it covers) | - | `npx playwright test` |

Independent stacks can run in parallel. Show the real output with counts. Apply auto-fixes
(`eslint --fix`, formatters), fix the rest, and re-run until clean. Do not continue with lint
errors or failing tests.

## 5. Clean up

Destructive steps run only after the user confirms the list:
- Worktrees: `git worktree prune` drops entries whose directories are gone. Remove a worktree
  with `git worktree remove <path>` only when its branch is merged; never `rm -rf .worktrees/`.
- Branches: list `git branch --merged <default branch>` (excluding the current and default branch) and
  delete with `git branch -d` only the ones the user approves.
- Temp files from the scan, and `e2e/.captures.json`: delete after confirmation.
- Check `.gitignore` covers build output (`node_modules`, `target`, `build`, `.gradle`,
  `.dart_tool`).

## 6. Stage and commit

```bash
git add <specific paths>      # never git add -A or git add . blindly
git diff --cached --stat
```

Show the staged list. Exclude `.env`, credentials, keys, large binaries, build output.
Commit in the repo's format (default: Conventional Commits `<type>(<scope>): <description>`,
type from the change, scope from the main area touched).

## 7. Push and PR (only when asked)

Push the branch, then open the PR against the base from policy:

```bash
gh pr create --base <base> --title "<title>" --body "<body>"
```

Body: summary bullets, test results (actual counts), a design reference if a handoff manifest has
`stitch.project_id` or a `figma:` block, and the repo's PR template sections if it has one.
Return the PR URL. Do not merge unless the user asked for that too.

## 8. Archive (after the commit succeeds)

Follow the `handoff` lifecycle: archive only manifests whose `lifecycle.archivable_after` skills
have all consumed them.

```bash
ARCHIVE="claudedocs/.archive/$(date +%Y%m%d-%H%M%S)-<feature>"
mkdir -p "$ARCHIVE"
mv claudedocs/<feature>-*.md "$ARCHIVE/" 2>/dev/null
# design/ only after the user confirms nothing still uses it
```

Keep `claudedocs/handoff-*.yaml`, `e2e/test-plan.yaml`, `e2e/reports/`, and verification
screenshots. Make sure `claudedocs/.archive/` is ignored by git.

## Quality bar

- Lint clean and all tests passing, with real output shown
- Only intended files committed; no secrets, temp files, or build output
- Delivery went exactly as far as the user asked, in the repo's format and policy
- No orphaned worktrees or merged branches left behind (with the user's approval)

## Workflow context

- Follows `spec-to-impl`, `verify-impl`, or manual implementation work.
- Delivery only: verification of behavior belongs to `verify-impl`, a full review to `code-audit`.
- Feeds `release-notes` (PR description) and code review on the opened PR.

## Output contract
```yaml
produces:
  - type: git_commit
    ref: "<commit SHA>"
  - type: pull_request           # only when a PR was requested and created
    url: "<PR URL>"
    branch: "<branch name>"
  - type: evidence
    lint_output: "<actual linter stdout>"
    test_output: "<actual test runner stdout>"
    files_committed: ["<list>"]
    handoff: "Write claudedocs/handoff-finalize-<timestamp>.yaml - suggest: code-review, release-notes"
```

---
name: finalize
description: >
  Post-implementation completion workflow: lint, test, clean up, commit, and create PR.
  Triggers: "finalize", "commit this", "wrap up", "create PR", "ship it", "done implementing".
argument-hint: "[branch name or feature description]"
context: fork
agent: general-purpose
---

# Finalize

## What I'll do
Run the full completion pipeline: lint → test → clean up → commit → PR. Ensures nothing ships without passing quality gates and nothing is left behind.

## Inputs I'll use (ask only if missing)
- What was implemented (feature name or branch)
- Target branch for PR (default: main)
- Any files to exclude from commit (.env, credentials, large binaries)

## How I'll think about this

### 1. SCAN — Detect what needs finalizing
```bash
git status                              # uncommitted changes
git worktree list                       # orphaned worktrees
git branch --no-merged main             # unmerged feature branches
find . -name "*.orig" -o -name "*.bak"  # temp files
ls .worktrees/ 2>/dev/null              # stale worktree dirs
```
Report what was found before proceeding.

### 2. LINT — Run language-appropriate linters

**Parallel execution**: When the project uses multiple languages/stacks, run linters and test suites concurrently:

```
┌──────────────────────────────────────┐
│ Phase 1: SCAN (sequential)            │
└──────────────┬───────────────────────┘
               │
  ┌────────────┼────────────┐
  ▼            ▼            ▼
┌──────┐  ┌──────┐  ┌──────────┐
│ Java │  │ TS/  │  │ Flutter/ │
│ Lint │  │ React│  │ Dart     │
│      │  │ Lint │  │ Lint     │
└──┬───┘  └──┬───┘  └────┬────┘
   │         │           │
   └─────────┼───────────┘
             ▼
  ┌────────────┼────────────┐
  ▼            ▼            ▼
┌──────┐  ┌──────┐  ┌──────────┐
│ Java │  │ TS/  │  │ Flutter/ │
│ Test │  │ React│  │ Dart     │
│      │  │ Test │  │ Test     │
└──┬───┘  └──┬───┘  └────┬────┘
   │         │           │
   └─────────┼───────────┘
             ▼
┌──────────────────────────────────────┐
│ Phase 4: CLEAN → STAGE → COMMIT → PR│
└──────────────────────────────────────┘
```

Detect stacks from project files, then launch lint agents in parallel. After all lints pass, launch test agents in parallel.

| Stack | Command |
|---|---|
| Java / Maven | `mvn checkstyle:check spotbugs:check -q` |
| Java / Gradle | `./gradlew checkstyleMain spotbugsMain` |
| React / TypeScript | `npx eslint . --ext .ts,.tsx && npx tsc --noEmit` |
| Flutter / Dart | `dart analyze && dart format --set-exit-if-changed .` |
| Android / Kotlin | `./gradlew ktlintCheck detekt` |
| AngularJS | `npx eslint . --ext .js` |

Show actual linter output. If lint fails:
- Auto-fix what can be auto-fixed (`eslint --fix`, `dart format`)
- Surface remaining issues and fix them
- Re-run to confirm clean

### 2.5 SIMPLIFY — Pre-commit quality review

Before proceeding to tests, optionally run a code quality sweep on changed files:
- Spawn three parallel review agents on recently changed files:
  1. **Reuse agent**: Check if changed code duplicates existing utilities
  2. **Quality agent**: Check for code smells, SOLID violations, dead code
  3. **Efficiency agent**: Check for unnecessary allocations, N+1 patterns, missed optimizations
- Only flag issues in code that was changed (not pre-existing issues)
- Auto-fix what can be auto-fixed, surface remaining issues

### 3. TEST — Run test suites
| Stack | Command |
|---|---|
| Java / Maven | `mvn test -q` |
| Java / Gradle | `./gradlew test` |
| React / Vitest | `npx vitest run` |
| Flutter | `flutter test` |
| Android | `./gradlew testDebugUnitTest` |
| Playwright | `npx playwright test` |

Show actual test output with pass/fail counts. If tests fail → fix and re-run. Do NOT proceed with failing tests.

### 4. CLEAN — Remove debris
```bash
# Worktree cleanup
git worktree prune
rm -rf .worktrees/ 2>/dev/null

# Stale branches (only merged ones)
git branch --merged main | grep -v main | grep -v '\*' | xargs -r git branch -d

# Temp files
find . -name "*.orig" -name "*.bak" -name ".DS_Store" -delete 2>/dev/null
rm -f e2e/.captures.json 2>/dev/null

# Build artifacts (don't commit these)
# Check .gitignore covers: node_modules, target, build, .gradle, .dart_tool
```

### 4.5 ARCHIVE — Move intermediate artifacts (after successful commit)
```bash
# Archive planning/design artifacts — NOT handoff manifests or test evidence
FEATURE="<feature-name>"
ARCHIVE="claudedocs/.archive/$(date +%Y%m%d-%H%M%S)-$FEATURE"
mkdir -p "$ARCHIVE"

# Move primary outputs (PRD, design docs, analysis files)
mv claudedocs/${FEATURE}-*.md "$ARCHIVE/" 2>/dev/null

# Move design artifacts if present
[ -d design/ ] && mv design/ "$ARCHIVE/design/" 2>/dev/null

# PRESERVE (do NOT archive):
#   claudedocs/handoff-*.yaml  — audit trail, never delete
#   e2e/test-plan.yaml         — needed for regression testing
#   e2e/reports/               — test evidence
#   e2e/verify-impl/           — screenshots and traces
```

Report what was archived:
```
📦 ARCHIVED intermediate artifacts to: $ARCHIVE
  Preserved: handoff manifests (audit trail)
  Preserved: e2e/ artifacts (regression + evidence)
```

> **Safety rule:** Only archive after the commit succeeds. If commit fails, artifacts are still needed. Add `claudedocs/.archive/` to `.gitignore`.

### 5. STAGE — Selective git add
```bash
# Stage specific files — NEVER git add -A blindly
# Exclude: .env, credentials, secrets, large binaries, build dirs
git add <specific files and directories>

# Review what's staged
git diff --cached --stat
```
Show the staged file list to user for confirmation.

### 6. COMMIT — Conventional commit
```bash
git commit -m "<type>(<scope>): <description>"
```
- Derive type from changes: feat, fix, refactor, test, docs, chore
- Derive scope from primary directory changed
- Description from the feature/task name

### 7. PR — Create pull request
```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<bullet points of what changed>

## Design Reference
<If handoff has stitch.project_id — include this section>
- Stitch Project: <project_id>
- Design System: <asset_id>
- Screens: <n> generated
<End if>

## Test Results
<paste actual test output summary>

## Checklist
- [ ] Lint: clean
- [ ] Tests: all passing
- [ ] No orphaned worktrees or temp files
- [ ] No secrets or credentials in diff
EOF
)"
```
Return the PR URL.

## Anti-patterns to flag
- ⚠️ Committing with failing tests
- ⚠️ `git add -A` without reviewing what's staged
- ⚠️ Committing .env, credentials, or secrets
- ⚠️ Leaving orphaned worktrees or feature branches
- ⚠️ Empty commit messages or non-conventional format
- ⚠️ Skipping lint because "it's just a small change"

## Quality bar
- ✅ Zero lint errors on committed code
- ✅ All tests pass with actual output shown
- ✅ No orphaned worktrees or stale branches remain
- ✅ No temp files, build artifacts, or secrets in the commit
- ✅ PR created with summary and test evidence
- ✅ Conventional commit message with correct type and scope

## Workflow context
- Follows: `/spec-to-impl`, `/verify-impl`, or any manual implementation work
- Feeds into: `/pr-review` (PR is ready for review)
- Related: `/release-notes` (PR description feeds release notes)

## Output contract
```yaml
produces:
  - type: git_commit
    ref: "<commit SHA>"
  - type: pull_request
    url: "<PR URL>"
    branch: "<branch name>"
  - type: evidence
    lint_output: "<actual linter stdout>"
    test_output: "<actual test runner stdout>"
    files_committed: ["<list>"]
    handoff: "Write claudedocs/handoff-finalize-<timestamp>.yaml — suggest: pr-review, release-notes"
```

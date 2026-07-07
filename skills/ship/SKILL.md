---
name: ship
description: >
  Use when work is ready to leave the machine — committing, opening a PR/MR, merging, or
  promoting branches ("commit and merge to develop-candidate", "promote develop to main",
  "commit, PR, merge").
argument-hint: "[target: commit | pr | merge | promote]"
---

# Ship

Encodes each repo's delivery policy so branch choreography is one word instead of twenty prompts.

## Repo policy (read first)
From the repo CLAUDE.md `## Ship policy` section — offer to add one if missing:
- **Host + CLI**: `gh` (GitHub) vs `glab` (GitLab — kifiya). Never the wrong one.
- **Branch flow**: feature → `develop-candidate` (kifiya) · feature → `develop`, promotion PR → `main` (onbilia, payser, gaming-hub) · ticket branch → MR only, NEVER merge — peer review is manual (logifuture).
- **Attribution**: employer repos — no AI/Claude mention anywhere: commits, PR bodies, branch names, comments; no generated-with footers. Personal repos: per repo preference (default: none).
- **Extras**: QA testing note on the ticket (logifuture: how to test the API, nothing more) · local pre-push hooks must pass · agent files (CLAUDE.md, .claude/) never committed where the repo bans them.

## Gate — before any commit
1. Full verify for the stack (`mvn verify` / `./gradlew build` / `pnpm test`) — show the output tail.
2. Behavior changes have `e2e` evidence; run it if missing.
3. Diff hygiene: no stale/debug files, no unrelated changes, no secrets; migrations note their rollback story; plan checkboxes complete.

## Flow
Conventional commit, imperative mood, human voice → push → PR/MR with a concise body (what / why / how to test) → merge or hand off per policy → promotion ("promote develop to main") as its own PR when asked. Release notes only when tagging a release: generated from merged changes, audience-split, no fluff.

Blocked — failing verify, denied push, red pipeline? Report the exact output. Investigate Jenkins/CI when asked, but never modify CI or repo settings unilaterally.

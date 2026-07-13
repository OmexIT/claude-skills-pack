---
name: ship
description: >
  Use when work is ready to leave the machine - committing, opening a PR/MR, merging,
  promoting branches, or tagging a release ("commit and merge to release-candidate",
  "promote develop to main", "commit, PR, merge").
---

# Ship

Encodes each repo's delivery policy so branch choreography is one word instead of twenty prompts.

## Repo policy (read first - never assume)
Read the repo's `## Ship policy` block in AGENTS.md or CLAUDE.md, or its existing git-workflow
section. If none exists, infer only from current branch protection, remote, CI, and recent history, report uncertainty, and add policy text only when asked. The policy defines:
- **Host + CLI**: `gh` (GitHub) vs `glab` (GitLab). Never the wrong one.
- **Branch flow**: which integration branch (`develop`, `release-candidate`, ...), whether merging is allowed or MRs are handed off for manual peer review, and how promotion to `main` happens (its own PR).
- **Attribution**: default none - no AI-tool mention in commits, PR bodies, branch names, or
  comments; no generated-with footers. Some repos ban it outright; respect stricter local rules.
- **Extras**: ticket updates (e.g. a QA note: how to test, nothing more) · required local
  pre-push hooks · whether agent files (AGENTS.md, CLAUDE.md, `.agents/`, `.claude/`) may be
  committed at all.

## Gate - before any commit
1. Format, then full verify for the stack (`./gradlew spotlessApply build` / `mvn spotless:apply verify` / `pnpm lint && pnpm build && pnpm test`) - show the output tail. Java formatting happens here, once - not per edit.
2. Risk-bearing runtime behavior changes have proportional `e2e` evidence, or an explicit reason live verification does not apply. Run the missing proof when it is in scope and safe.
3. Diff hygiene: no stale/debug files, no unrelated changes, no secrets; migrations note their rollback or restore story; plan checkboxes complete when a plan exists.

## Flow
Perform only the requested, policy-allowed delivery steps. Typical flow: conventional commit, imperative mood, human voice; push when requested; open a PR/MR when policy or the user requires it; merge or hand off per policy; create a separate promotion PR only when asked. Direct-main, commit-only, and manual-review repositories are valid. Release notes are only for a requested release or tag and are generated from the actual merged changes.

Blocked - failing verify, denied push, red pipeline? Report the exact output. Investigate Jenkins/CI when asked, but never modify CI or repo settings unilaterally.

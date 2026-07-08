---
name: build
description: >
  Use when executing an implementation plan or building a scoped feature or fix — after scope
  is clear, before code gets written. Triggers on "implement <plan path>", "start slice SP-2b".
argument-hint: "[plan path or slice id or scoped change]"
---

# Build

## Input
A plan doc path or slice id — or a small directly-scoped change. Non-trivial work with no plan? Write one first (`plan`).

## Execution rules
1. Work slice by slice in plan order. Update the plan doc's checkboxes as tasks complete — the plan is the durable state that survives context resets; "what's pending?" must be answerable from the doc alone.
2. Read before writing: the files to be touched, their tests, the module's conventions. Reuse before adding — if ≥80% exists, extend or refactor it.
3. Load `references/engineering-standards.md` (once per feature — its completion checklist gates every slice) and the matching domain skills — `spring-api` (endpoints), `migrations` (DDL), `ledger` (money movement), `temporal` (workflows) — plus repo CLAUDE.md. Detect the toolchain from the repo (Java, Boot, and build-tool versions differ across workspaces) — never assume.
4. Tests target business behavior, written with (and where practical before) the code. No DTO/getter tests, no framework tests, no log-assertion tests, no snapshot abuse.
5. Scope discipline: implement the plan, nothing else. No drive-by refactors, no CI/settings changes, no new abstractions, flags, or config beyond the plan. If the plan turns out wrong mid-slice: stop, flag, update the plan — never improvise silently. PRD divergence = bug to flag.
6. Subagents must earn their overhead — default is inline (each agent costs real minutes of round-trip):
   - Recon: one read-only Explore agent per unknown area; never a worktree.
   - Parallel implementation: only slices that share no files; dispatch ALL of them in a single message so they run concurrently; add `isolation: worktree` only because they mutate files at the same time.
   - Non-blocking side work (docs, test backfill): `run_in_background` and keep building.
   - Context diet: each agent gets its slice's plan excerpt and file paths, nothing more, and returns a compact summary (what changed, test output tail) — never a transcript. Don't redo delegated work inline.

## Slice completion gate
- Plan checkbox updated; build + tests green — run them and show the output tail, no claims.
- Cleanup executed: every legacy item listed in the plan actually deleted; no leftover TODOs, mocks, stale files, or commented-out code.
- Engineering-standards completion checklist passes (no new duplication, no consumer-less abstractions, obsolete tests and stale docs gone).
- Diff reread once for accidental scope.

All slices complete → `e2e` for live verification, then `ship`.

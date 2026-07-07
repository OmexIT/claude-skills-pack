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
3. Load the matching domain skills — `spring-api` (endpoints), `migrations` (DDL), `ledger` (money movement), `temporal` (workflows) — plus repo CLAUDE.md. Detect the toolchain from the repo (Java, Boot, and build-tool versions differ across workspaces) — never assume.
4. Tests target business behavior, written with (and where practical before) the code. No DTO/getter tests, no framework tests, no log-assertion tests, no snapshot abuse.
5. Scope discipline: implement the plan, nothing else. No drive-by refactors, no CI/settings changes, no new abstractions, flags, or config beyond the plan. If the plan turns out wrong mid-slice: stop, flag, update the plan — never improvise silently. PRD divergence = bug to flag.
6. Subagents only when they earn their overhead: Explore for recon; parallel implementation only for genuinely independent slices (worktree isolation). Default is inline.

## Slice completion gate
- Plan checkbox updated; build + tests green — run them and show the output tail, no claims.
- Cleanup executed: every legacy item listed in the plan actually deleted; no leftover TODOs, mocks, stale files, or commented-out code.
- Diff reread once for accidental scope.

All slices complete → `e2e` for live verification, then `ship`.

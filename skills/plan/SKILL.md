---
name: plan
description: >
  Use when a feature, refactor, or fix needs an implementation plan before coding - turning an
  approved spec, PRD section, or ticket into an executable, verifiable plan document.
argument-hint: "[what to plan]"
---

# Implementation plan

Plans are repo artifacts, not chat messages. They are also the durable session state - a fresh session must be able to pick one up and continue.

## Where plans live
Follow the repo's existing convention: `docs/superpowers/plans/` where established, else `docs/plans/`. Naming matches the repo's pattern: `YYYY-MM-DD-<slug>-plan.md`, with phase/ticket codes when in use (`sp2b`, `l7`, `2a-backend`). Split large work into paired plans (backend/frontend, a/b) like the existing corpus.

## Recon before writing (never plan blind)
1. Read the PRD/spec section or ticket this implements; cite requirement IDs where they exist. If no PRD, spec, or ticket covers the change: STOP and flag before planning.
2. Reuse inventory: search for existing models, services, components, utilities. If ≥80% exists, the plan extends or refactors it - never a parallel copy.
3. Read the target module's current patterns (naming, error handling, tests) and the repo CLAUDE.md constraints.
4. Note which domain skills apply (ledger, temporal, migrations, spring-api, igaming-ui) and cite the specific invariants this work must satisfy.

## Plan structure
- **Context** - requirement IDs, system-of-record/ownership boundaries, negative constraints (what NOT to touch: CI config, curated copy, other teams' modules).
- **Decisions** - for one-way choices, a 5-line inline ADR (options, choice, why); follow the repo's `docs/adr/` convention when one exists.
- **Slices** - vertical, independently shippable, ≤~1 day each. Per slice: files touched, reuse notes, migration (if any), tests to write (before the code where practical), verification command + expected output, checkbox.
- **Flow map** (only for stateful/risky flows: money movement, sagas, auth) - path table covering happy/failure/timeout/recovery, each row mapped to a test-case ID; plus a cleanup inventory (resource / allocated when / orphan risk / cleanup mechanism).
- **Cleanup list** - legacy code, tables, and files this work must delete. Greenfield repos: no compat layers, no deprecated columns, no half-migrations.

## Bar
Done when any slice could be executed by a fresh session without questions, and every slice says how it will be verified. As short as completeness allows - no essay sections. Execution proceeds slice by slice via `build`.

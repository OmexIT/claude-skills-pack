---
name: migration-plan
description: "Use when the user needs a plan to migrate a database, API, data format, or infrastructure safely, with staging, validation, and rollback, rather than a single schema changeset."
---

# Migration plan

Plans a move from state A to state B across several deploys or systems: stages, validation,
rollback, and the point of no return. It writes a plan, not changesets; each database step is then
written with `db-migration`.

## Inputs (ask only if missing)
- What moves: schema, API version, data format, store, or infrastructure.
- Current and target state.
- Data volume, traffic pattern, and downtime tolerance.
- Every reader and writer of the affected data or API.

## Decision rules
1. **Old and new coexist.** Code must work with both shapes during rollout so deploys can roll back.
   A synchronized big-bang cutover needs an explicit reason and an agreed maintenance window.
2. **Expand, migrate, contract**, in separate releases: add the new path alongside the old, move
   data and consumers, then remove the old path only after validation holds.
3. **Validate before, during, and after**: pre-checks on source data, live metrics while running,
   and completeness and correctness checks (counts, checksums, zero-row predicates) after.
4. **Batches with checkpoints**: large moves resume from the last committed checkpoint, can be paused,
   and are throttled against measured load and replication lag.
5. **Rehearse on realistic volume** (anonymized production-scale data) before production.
6. **Name the point of no return.** Every stage before it has a tested rollback. Contract steps,
   drops, and data rewrites are destructive: they need explicit confirmation and a restore story
   (verified backup restore, retained source column or table, or forward-fix script). A no-op
   rollback is not a restore story.
7. **Switch reads and writes with the repo's existing release controls**; no new flag system.

## Anti-patterns to flag
- Big-bang cutover with no rollback path, or contracting in the same release as expanding.
- Validation missing or run on a small sample only; no monitoring while it runs.
- Historical data left in the old format while only new writes change.

## Quality bar
- Every stage has a trigger, a rollback or restore path, and a validation check.
- Batch size, checkpointing, and throttling come from measurements.
- Every consumer of the old shape is listed with its migration step.
- Success criteria are measurable; who is told what, and when, is stated, including on rollback.

## Workflow context
- Follows `design-doc` or `adr`; feeds `ticket-breakdown`, `test-plan`, `runbook`.
- `db-migration` writes each database step as a concrete changeset; `data-design` owns the target model.

## Output
Fill `assets/migration-plan.md`.

## Output contract
```yaml
produces:
  - type: "migration-plan"
    format: "markdown"
    path: "claudedocs/<feature>-migration-plan.md"
    sections: [strategy, steps, rollback, validation, timeline]
    handoff: "Write claudedocs/handoff-migration-plan-<timestamp>.yaml - suggest: ticket-breakdown, test-plan, runbook"
```

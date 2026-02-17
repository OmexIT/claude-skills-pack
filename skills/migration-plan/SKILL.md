---
name: migration-plan
description: Plan safe migrations for databases, APIs, data formats, or infrastructure with rollback strategy, validation, and staged execution. Triggers: "migration plan", "database migration", "API migration", "data migration", "schema change".
argument-hint: "[what's being migrated]"
---

# Migration plan

## What I'll do
Produce a detailed migration plan that moves data, schemas, or systems from state A to state B safely, with rollback capability at every stage.

## Inputs I'll use (ask only if missing)
- What's being migrated (database schema, API version, data format, infrastructure)
- Current state and target state
- Data volume and traffic patterns
- Downtime tolerance (zero-downtime required?)
- Dependencies (what else reads/writes this data?)

## How I'll think about this
1. **Backwards compatibility is the default**: New code should work with old data AND new data simultaneously. This enables rolling deploys and instant rollback. Never require a synchronized cutover.
2. **Expand-migrate-contract pattern**: First, expand (add new columns/endpoints alongside old ones). Then, migrate (backfill data, update consumers). Finally, contract (remove old paths). Never skip steps.
3. **Validate before, during, and after**: Check data integrity before starting. Monitor during execution. Verify completeness and correctness after finishing. Build each validation into the plan.
4. **Small batches with checkpoints**: Large migrations should run in batches with progress tracking. If a batch fails, you should be able to resume from the last successful checkpoint, not start over.
5. **Test on realistic data**: A migration that works on 100 rows may fail on 10 million. Test with production-scale data volumes (anonymized if needed).
6. **Rollback at every stage**: At any point in the migration, you should be able to stop and revert to the previous working state. If you can't, your plan has a gap.

## Anti-patterns to flag
- Big-bang migrations with no rollback path
- Skipping the "expand" phase (adding new schema before removing old)
- No data validation after migration
- Testing only on small datasets
- Migrations that require downtime when zero-downtime is feasible
- Forgetting to migrate historical data (only new writes use new format)
- No monitoring during the migration itself

## Quality bar
- Every stage has a rollback procedure
- Data validation is automated, not manual
- Batch size and checkpoint strategy are defined
- Consumer compatibility is verified (what reads/writes this data)
- Performance impact during migration is estimated
- Communication plan exists (who needs to know, when)
- Success criteria are measurable ("all rows migrated and validated")

## Workflow context
- Typically follows: `/design-doc` (architectural change), `/adr` (decision to migrate)
- Feeds into: `/ticket-breakdown`, `/test-plan`, `/release-notes`
- Related: `/runbook` (execution procedures), `/monitoring-plan` (migration monitoring)

## Output
Fill `templates/migration-plan.md`.

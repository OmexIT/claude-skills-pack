---
name: migrations
description: >
  Use when creating or reviewing database migrations - Liquibase or Flyway, new tables, columns,
  indexes, constraints, backfills, or any DDL against Postgres.
---

# Database migrations

## House law (Postgres)
These defaults apply to service-owned schemas. Third-party and provider-managed schemas keep their
own versioned contract.

- **PKs**: `BIGINT` app-generated TSID, with UUIDv7 as a separate public identifier. Do not retrofit upstream package schemas or expose storage keys.
- **Audit fields by lifecycle**: every business row records creation time and actor when an actor exists. Mutable rows also record update time and actor. Append-only rows do not pretend to update.
- **Money**: `NUMERIC(precision, scale)` derived from the supported currency or asset contract; common two-decimal fiat may use `NUMERIC(20,2)`, but not when the asset set needs another scale. **Time**: `TIMESTAMPTZ` for instants.
- **Closed enums**: `TEXT` + `CHECK`; use a reference table when values evolve independently. Avoid native Postgres enums when rolling change is required.
- **Multi-tenant tables**: use tested RLS when the service relies on database tenant enforcement, including `ENABLE`, normally `FORCE ROW LEVEL SECURITY`, and a policy based on the correctly typed `current_setting('app.tenant_id', true)` value.
- **Naming**: `<scope>-<NNN>-<description>.sql` (Liquibase, established services) / timestamp versions (Flyway, newer services; avoids merge conflicts). Match what the repo already uses. Greenfield (unreleased) repos: edit the existing changeset instead of stacking history.

## Zero-downtime rules
- Two-phase renames (add → dual-write → switch → drop later).
- `CREATE INDEX CONCURRENTLY` in its own changeset with transactions off (`runInTransaction:false` Liquibase / `executeInTransaction=false` Flyway); it cannot run inside a transaction block.
- FKs as `NOT VALID`, then `VALIDATE CONSTRAINT`.
- Destructive ops (`DROP`, `TRUNCATE`, column removal) require explicit user confirmation and a documented rollback story.

## Backfills
Prefer a resumable application job for complex or long backfills. A PostgreSQL `DO` loop with per-batch commits is valid only when the exact runner executes it at top level outside a transaction: Liquibase puts `runInTransaction:false` on the `--changeset` line; Flyway uses `executeInTransaction=false` in script configuration. Irreversible changes have no fake rollback and must state restore or forward-fix steps. Pattern: `references/backfill-pattern.md`.

## Verification
Fresh-container run must apply cleanly from scratch; rollback tested where reversible; ledger-table changes also satisfy the `ledger` skill invariants.

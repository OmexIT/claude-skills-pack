---
name: migrations
description: >
  Use when creating or reviewing database migrations - Liquibase or Flyway, new tables, columns,
  indexes, constraints, backfills, or any DDL against Postgres.
argument-hint: "[change to migrate]"
---

# Database migrations

## House law (Postgres)
- **PKs**: `BIGINT` app-generated TSID. Never `SERIAL` / `IDENTITY` / UUID PKs. External identifiers: UUIDv7 in a separate column.
- **Audit quartet** on every table: `created_at`/`updated_at` (`TIMESTAMPTZ`), `created_by`/`updated_by` (actor ID, matching the actor's PK type).
- **Money**: `NUMERIC(20,2)` fiat / `NUMERIC(20,8)` crypto. **Time**: `TIMESTAMPTZ` only.
- **Enums**: `TEXT` + `CHECK` constraint - never native Postgres enums.
- **Multi-tenant tables**: full RLS - `ENABLE` + `FORCE ROW LEVEL SECURITY`, policy on `current_setting('app.tenant_id')`.
- **Naming**: `<scope>-<NNN>-<description>.sql` (Liquibase, established services) / timestamp versions (Flyway, newer services; avoids merge conflicts). Match what the repo already uses. Greenfield (unreleased) repos: edit the existing changeset instead of stacking history.

## Zero-downtime rules
- Two-phase renames (add → dual-write → switch → drop later).
- `CREATE INDEX CONCURRENTLY` in its own changeset with transactions off (`runInTransaction:false` Liquibase / `executeInTransaction=false` Flyway); it cannot run inside a transaction block.
- FKs as `NOT VALID`, then `VALIDATE CONSTRAINT`.
- Destructive ops (`DROP`, `TRUNCATE`, column removal) require explicit user confirmation and a documented rollback story.

## Backfills
Batched `DO` loop with `pg_sleep` throttle, `--runInTransaction:false` (Flyway: `executeInTransaction=false` in the migration's script config file); when rollback is `SELECT 1`, mark the changeset irreversible and say so in the plan/PR. Pattern: `references/backfill-pattern.md`.

## Verification
Fresh-container run must apply cleanly from scratch; rollback tested where reversible; ledger-table changes also satisfy the `ledger` skill invariants.

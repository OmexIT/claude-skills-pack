---
name: db-migration
description: "Use when the user needs a PostgreSQL schema or data change through Liquibase or Flyway: new table, add, rename, or drop a column, add an index, change a constraint, backfill or one-time data fix, zero-downtime migration, or a new entity that needs persistence."
---

# DB migration: PostgreSQL changesets

Writes concrete Liquibase or Flyway changesets that follow house schema law and are safe to run
against a populated production database.

## Steps

1. **Detect the tool and layout** and match what the repo already does (file naming, author, folder,
   SQL vs XML/YAML changelogs):
   ```bash
   grep -rlE "liquibase formatted sql" src/main/resources/db 2>/dev/null | head -3
   find src/main/resources/db/migration -name "V*__*.sql" 2>/dev/null | head -3
   grep -rE "liquibase-core|flyway-core|flyway-database-postgresql" build.gradle* pom.xml gradle/*.toml 2>/dev/null
   ```
   Neither found: ask. Never mix Liquibase syntax into Flyway scripts or the reverse.
2. **Classify the change.** Additive (new table, nullable column, index) goes straight to a changeset.
   Destructive or breaking (drop, rename, type change, `NOT NULL` on existing data, data rewrite)
   stops for the destructive gate below. A change that spans several deploys (expand, backfill,
   switch reads, contract) is planned with `migration-plan` first; this skill then writes one
   changeset per phase.
3. **Write verification SQL first**: zero-row queries that prove the post-migration state.
4. **Write the changeset** using the conventions and zero-downtime rules below.
5. **Verify before claiming done**: apply from scratch on a fresh container (Testcontainers or the
   repo's test DB), run the verification queries, then roll back and re-apply where the change is
   reversible. Show the output.

## Destructive gate

Never generate `DROP TABLE`, `DROP COLUMN`, `TRUNCATE`, a column rename or type change, or a data
rewrite without explicit user confirmation. Before asking, show the row count, dependent objects and
referencing foreign keys (or the queries for the user to run), and the restore story: a verified
backup restore, a retained source column or table, or a forward-fix script. A rollback that cannot
restore data is not a restore story.

## Conventions (service-owned schemas)

Third-party and provider-managed schemas (for example upstream pgledger) keep their own contract.

- **Keys**: `id BIGINT PRIMARY KEY`, an application-generated TSID. Never `SERIAL`, `IDENTITY`, or a
  UUID primary key. A row that is exposed outside the service also gets `public_id UUID NOT NULL
  UNIQUE` holding a UUIDv7; the TSID never leaves the service.
- **Audit columns by lifecycle**: `created_at TIMESTAMPTZ NOT NULL DEFAULT now()` and `created_by`
  where an actor exists; mutable rows add `updated_at` and `last_modified_by`. Append-only rows do not
  get update columns.
- **Money**: `NUMERIC(p, s)` with scale from the supported currency or asset contract
  (`NUMERIC(20,2)` for two-decimal fiat, more for assets that need it). Never `REAL`,
  `DOUBLE PRECISION`, or `MONEY`.
- **Time**: `TIMESTAMPTZ` for instants. Never `TIMESTAMP` without time zone; `DATE` only for true
  calendar dates.
- **Closed enums**: `TEXT` with a `CHECK` constraint; a reference table when values change
  independently. No native `CREATE TYPE ... AS ENUM`.
- **Foreign keys** always get an index on the referencing column.
- **Tenant-scoped tables** (when the service relies on database tenant enforcement):
  ```sql
  ALTER TABLE payment_links ENABLE ROW LEVEL SECURITY;
  ALTER TABLE payment_links FORCE ROW LEVEL SECURITY;
  CREATE POLICY tenant_isolation ON payment_links
    USING (tenant_id = current_setting('app.tenant_id', true)::BIGINT);
  ```
  The missing-ok form returns no rows when the setting is absent instead of erroring. Test it with
  the application role, which must not be a superuser or have `BYPASSRLS`.
- **Seeds** are idempotent: `INSERT ... ON CONFLICT DO NOTHING`.
- **One concern per changeset.** Greenfield (never released) repos may edit the existing changeset
  instead of stacking history; released changesets are immutable.

## Liquibase

File `src/main/resources/db/changelog/changes/sql/<scope>-<NNN>-<description>.sql` unless the repo
uses another layout. Changeset attributes go on the `--changeset` line.

```sql
--liquibase formatted sql
--changeset app:payment-link-001-schema

CREATE TABLE payment_links (
    id               BIGINT PRIMARY KEY,
    public_id        UUID NOT NULL UNIQUE,
    tenant_id        BIGINT NOT NULL,
    amount           NUMERIC(20,2) NOT NULL CHECK (amount > 0),
    currency         TEXT NOT NULL,
    expires_at       TIMESTAMPTZ NOT NULL,
    status           TEXT NOT NULL CHECK (status IN ('ACTIVE','EXPIRED','CANCELLED','USED')),
    created_by       TEXT NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_modified_by TEXT,
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_payment_links_tenant_status ON payment_links(tenant_id, status);
-- RLS block from Conventions when tenant-scoped

--rollback DROP TABLE payment_links;
```

Index on a populated table, in its own changeset:

```sql
--changeset app:payment-link-002-idx-expires-at runInTransaction:false
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payment_links_expires_at
  ON payment_links(expires_at) WHERE status = 'ACTIVE';
--rollback DROP INDEX CONCURRENTLY IF EXISTS idx_payment_links_expires_at;
```

## Flyway

Versioned scripts `V<version>__<snake_case_description>.sql` in `db/migration`, matching the repo's
version scheme (timestamp versions avoid merge conflicts on busy repos). Rollback is a new forward
migration; `U` undo scripts need a paid Flyway edition and are only written if the repo already uses
them. For `CREATE INDEX CONCURRENTLY` or a batched backfill, disable the transaction for that script
with a sibling `V<version>__<name>.sql.conf` containing `executeInTransaction=false`, after checking
the installed Flyway version supports script configuration. Never rely on SQL comments for this.

## Zero-downtime rules

- Renames and type changes are two-phase: add the new column, dual-write, backfill, switch reads,
  and drop the old column in a later, confirmed release.
- `CREATE INDEX CONCURRENTLY` on populated tables, in its own non-transactional changeset.
- Foreign keys on large tables: `ADD CONSTRAINT ... NOT VALID`, then `VALIDATE CONSTRAINT` in a
  separate changeset. `NOT NULL` on a large table: add a `CHECK (col IS NOT NULL) NOT VALID`,
  validate it, set `NOT NULL` (PostgreSQL 12+ uses the validated check to skip the scan), then drop
  the check.
- Set `lock_timeout` for DDL that takes strong locks on hot tables, so a blocked migration fails fast
  instead of queueing all traffic behind it.

## Backfills

Prefer a resumable application job for large, long, or operationally paused backfills. A migration
backfill is for a bounded, measured row set. Irreversible data changes carry no fake rollback (never
`--rollback SELECT 1`); they state the restore or forward-fix path instead. Read
`references/backfill-pattern.md` when writing any backfill or one-time data fix.

## Verification queries

Each returns zero rows when the migration is correct:

```sql
-- table and column exist
SELECT 'missing public_id' WHERE NOT EXISTS (
  SELECT 1 FROM information_schema.columns
   WHERE table_name = 'payment_links' AND column_name = 'public_id');
-- RLS enabled and forced
SELECT relname FROM pg_class
 WHERE relname = 'payment_links' AND NOT (relrowsecurity AND relforcerowsecurity);
-- no invalid index left behind by a failed CONCURRENTLY build
SELECT indexrelid::regclass FROM pg_index WHERE NOT indisvalid;
```

## Output contract

```yaml
produces:
  - type: "migration"
    format: "sql"
    paths:
      - "src/main/resources/db/changelog/changes/sql/<scope>-<NNN>-<description>.sql"  # Liquibase
      OR
      - "src/main/resources/db/migration/V<timestamp>__<description>.sql"              # Flyway
      - "src/main/resources/db/migration/U<timestamp>__<description>.sql"              # Flyway undo (optional)
  - type: "verification"
    format: "sql"
    paths: ["docs/migrations/verify-<description>.sql"]
  - type: "doc"
    format: "markdown"
    path: "docs/migrations/<description>.md"   # rollback plan, risks, expected downtime
  handoff: "Write claudedocs/handoff-db-migration-<timestamp>.yaml - suggest: verify-impl, api-first (if paired with endpoint)"
```

## Workflow context

- `migration-plan` owns multi-step, multi-deploy strategy; this skill writes the concrete changesets.
- Ledger tables also satisfy `fintech-ledger` invariants (append-only trigger stays).

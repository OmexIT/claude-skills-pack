# Backfill pattern (Liquibase, Postgres)

Split schema change and backfill into separate changesets. The backfill runs outside a
transaction, in throttled batches, so it never locks the table or bloats WAL:

```sql
--liquibase formatted sql
--changeset <author>:<scope>-NNN-backfill-<desc>
--runInTransaction:false

DO $$
DECLARE
    batch_size INT := 10000;
    rows_updated INT;
BEGIN
    LOOP
        UPDATE payment_links
           SET status = 'EXPIRED'
         WHERE id IN (
            SELECT id FROM payment_links
             WHERE status = 'ACTIVE' AND expires_at < now()
             LIMIT batch_size
         );
        GET DIAGNOSTICS rows_updated = ROW_COUNT;
        EXIT WHEN rows_updated = 0;
        PERFORM pg_sleep(0.05);  -- throttle
    END LOOP;
END $$;

--rollback SELECT 1; -- backfill is irreversible; say so in the plan/PR
```

Rules:
- `--runInTransaction:false` is mandatory for the batched loop.
- When rollback is `SELECT 1`, the changeset is irreversible — state that explicitly in the
  plan/ADR and the PR description.
- Tune `batch_size` to row width; keep the `pg_sleep` throttle for hot tables.
- Verify afterwards with a count query proving zero rows remain unmigrated.

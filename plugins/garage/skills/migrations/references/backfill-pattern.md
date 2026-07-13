# Backfill pattern for Liquibase and PostgreSQL

Use a migration only for a bounded backfill whose runtime and locking are understood. Prefer a
resumable application job for large, long-running, observable, or operationally paused work.

## Transaction-controlled `DO` example

PostgreSQL permits `COMMIT` inside a top-level `DO` only when the `DO` command itself is not run
inside a transaction block. Liquibase's attribute belongs on the changeset line.

```sql
--liquibase formatted sql
--changeset <author>:<scope>-NNN-backfill-<desc> runInTransaction:false splitStatements:false

DO $$
DECLARE
    batch_size integer := 10000;
    rows_updated integer;
BEGIN
    LOOP
        UPDATE payment_links
           SET status = 'EXPIRED'
         WHERE id IN (
             SELECT id
               FROM payment_links
              WHERE status = 'ACTIVE'
                AND expires_at < now()
              ORDER BY id
              LIMIT batch_size
              FOR UPDATE SKIP LOCKED
         );

        GET DIAGNOSTICS rows_updated = ROW_COUNT;
        COMMIT;

        EXIT WHEN rows_updated = 0;
        PERFORM pg_sleep(0.05);
    END LOOP;
END
$$;
```

There is intentionally no `--rollback SELECT 1`. A no-op does not restore changed data.

## Preconditions

- Verify the exact PostgreSQL, Liquibase or Flyway, JDBC, and execution mode in a disposable
  environment. The runner must send the `DO` command at top level with transaction wrapping off.
- Check whether repository policy allows transaction control inside a migration at all.
- Measure candidate row count, row width, write amplification, replication lag, lock behavior, and
  estimated duration before release.
- Make the predicate monotonic and safe to rerun. If the transformation is not naturally
  idempotent, use a durable checkpoint table or an application job.

For Flyway, configure `executeInTransaction=false` using the repository's supported per-script
configuration. Do not assume Liquibase comments work in Flyway or vice versa.

## Safer rollout

1. Deploy additive schema first.
2. Deploy code that tolerates old and new rows when mixed-version operation is required.
3. Run or release the backfill with metrics and a pause or abort mechanism.
4. Prove completion with a zero-row query.
5. Add validation or `NOT NULL` only after the data proof.
6. Remove temporary dual-write or compatibility code in an approved later step.

## Completion proof

Use a query tailored to the predicate:

```sql
SELECT count(*) AS remaining
FROM payment_links
WHERE status = 'ACTIVE'
  AND expires_at < now();
```

Record the command, result, duration, and any replication or lock impact. For an irreversible
transformation, document the actual restore path, such as a verified backup restore, retained
source column, audit reconstruction, or forward-fix script.

Primary references:

- <https://docs.liquibase.com/oss/reference-guide-4-33/changelog-attributes/runintransaction>
- <https://www.postgresql.org/docs/current/sql-do.html>

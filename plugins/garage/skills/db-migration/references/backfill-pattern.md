# Backfill pattern (PostgreSQL)

Use a migration only for a bounded backfill whose runtime and locking are understood. Prefer a
resumable application job for large, long-running, observable, or operationally paused work.

## Preconditions

- Verify the exact PostgreSQL, Liquibase or Flyway, JDBC driver, and execution mode in a disposable
  environment. The runner must send the `DO` command at top level with transaction wrapping off;
  PostgreSQL permits `COMMIT` inside `DO` only then.
- Check whether repository policy allows transaction control inside a migration at all.
- Measure candidate row count, row width, write amplification, replication lag, lock behavior, and
  estimated duration before release.
- Make the predicate monotonic and safe to rerun. If the transformation is not naturally
  idempotent, use a durable checkpoint table or an application job.

## Liquibase

Attributes belong on the `--changeset` line, not on a separate comment line.

```sql
--liquibase formatted sql
--changeset app:payment-link-003-backfill-expired runInTransaction:false splitStatements:false

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

There is intentionally no `--rollback SELECT 1`: a no-op does not restore changed data. Leave the
rollback out and document the restore path (below), so a rollback attempt fails loudly instead of
reporting false success.

## Flyway

Same `DO` block in a versioned script, with a sibling `V<version>__<name>.sql.conf` containing
`executeInTransaction=false` where the installed Flyway version supports script configuration. Do
not assume Liquibase comments work in Flyway or the reverse.

## Safer rollout

1. Deploy additive schema first.
2. Deploy code that tolerates old and new rows when mixed-version operation is required.
3. Run the backfill with metrics and a way to pause or abort.
4. Prove completion with a zero-row query.
5. Add validation or `NOT NULL` only after the data proof.
6. Remove temporary dual-write or compatibility code in an approved later step.

## Completion proof

A query tailored to the predicate:

```sql
SELECT count(*) AS remaining
FROM payment_links
WHERE status = 'ACTIVE'
  AND expires_at < now();
```

Record the command, result, duration, and any replication or lock impact. For an irreversible
transformation, document the actual restore path: a verified backup restore, a retained source
column, audit reconstruction, or a forward-fix script.

Primary references:

- <https://docs.liquibase.com/oss/reference-guide-4-33/changelog-attributes/runintransaction>
- <https://www.postgresql.org/docs/current/sql-do.html>

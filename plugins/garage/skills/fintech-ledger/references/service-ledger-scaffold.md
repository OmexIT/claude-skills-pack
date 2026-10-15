# Service-owned ledger scaffold

Starting point for a service-owned PostgreSQL ledger (not upstream pgledger). Adapt names, scale,
data-access style (JdbcClient, jOOQ, Spring Data), and migration tool to the repository; detect the
Spring Boot and Java versions before using version-specific APIs.

## Schema (Liquibase formatted SQL)

`NUMERIC(20,2)` fits two-decimal fiat; derive scale from the supported currency or asset contract.
Tenant-scoped tables also get RLS as `db-migration` describes. The rollback is safe only before the
ledger holds real data; after that, corrections are forward changesets.

```sql
--liquibase formatted sql
--changeset app:ledger-001-core

CREATE TABLE ledger_accounts (
    id             BIGINT PRIMARY KEY,        -- TSID, internal only
    public_id      UUID NOT NULL UNIQUE,      -- UUIDv7, the ID exposed outside the service
    tenant_id      BIGINT NOT NULL,
    account_code   TEXT NOT NULL,
    currency       TEXT NOT NULL,
    normal_balance TEXT NOT NULL CHECK (normal_balance IN ('DEBIT','CREDIT')),
    allow_negative BOOLEAN NOT NULL DEFAULT false,
    balance        NUMERIC(20,2) NOT NULL DEFAULT 0,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, account_code, currency)
);

CREATE TABLE ledger_transactions (
    id              BIGINT PRIMARY KEY,
    tenant_id       BIGINT NOT NULL,
    idempotency_key TEXT NOT NULL,
    intent_hash     TEXT NOT NULL,            -- canonical hash of accounts, amount, currency, type
    operation_type  TEXT NOT NULL,
    reverses_id     BIGINT UNIQUE REFERENCES ledger_transactions(id),  -- one reversal per original
    fx_rate         NUMERIC(20,10),           -- snapshot on FX legs only
    reason_code     TEXT NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, idempotency_key)
);

CREATE TABLE ledger_postings (
    id             BIGINT PRIMARY KEY,
    transaction_id BIGINT NOT NULL REFERENCES ledger_transactions(id),
    account_id     BIGINT NOT NULL REFERENCES ledger_accounts(id),
    direction      TEXT NOT NULL CHECK (direction IN ('DEBIT','CREDIT')),
    amount         NUMERIC(20,2) NOT NULL CHECK (amount > 0),
    currency       TEXT NOT NULL,
    balance_after  NUMERIC(20,2) NOT NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_postings_account_time ON ledger_postings(account_id, created_at);
CREATE INDEX idx_postings_transaction ON ledger_postings(transaction_id);

--rollback DROP TABLE ledger_postings;
--rollback DROP TABLE ledger_transactions;
--rollback DROP TABLE ledger_accounts;
```

The trigger function goes in its own changeset with `splitStatements:false` so the dollar-quoted
body is sent intact:

```sql
--changeset app:ledger-002-append-only splitStatements:false

CREATE FUNCTION ledger_reject_mutation() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION '% is append-only', TG_TABLE_NAME;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER postings_append_only BEFORE UPDATE OR DELETE ON ledger_postings
    FOR EACH ROW EXECUTE FUNCTION ledger_reject_mutation();
CREATE TRIGGER transactions_append_only BEFORE UPDATE OR DELETE ON ledger_transactions
    FOR EACH ROW EXECUTE FUNCTION ledger_reject_mutation();

--rollback DROP TRIGGER transactions_append_only ON ledger_transactions;
--rollback DROP TRIGGER postings_append_only ON ledger_postings;
--rollback DROP FUNCTION ledger_reject_mutation();
```

## Posting service

The idempotency lookup runs after the account locks: a concurrent post with the same key on the same
accounts has either committed (and is visible) or not started. The unique constraint is the backstop
for a same-key post on different accounts, which maps to an idempotency conflict.

```java
@Service
public class LedgerPostingService {

    private final JdbcClient jdbc;      // or the repository's existing data access
    private final IdGenerator ids;      // the project's TSID generator

    // constructor omitted

    @Transactional
    public long post(PostCommand cmd) {
        var accounts = jdbc.sql("""
                SELECT id, currency, normal_balance, allow_negative, balance
                  FROM ledger_accounts
                 WHERE id IN (:ids)
                 ORDER BY id
                   FOR UPDATE
                """)
            .param("ids", List.of(cmd.debitAccountId(), cmd.creditAccountId()))
            .query(LockedAccount.class).list().stream()
            .collect(toMap(LockedAccount::id, a -> a));

        var existing = findTransaction(cmd.tenantId(), cmd.idempotencyKey());
        if (existing.isPresent()) {
            if (!existing.get().intentHash().equals(cmd.intentHash())) {
                throw new IdempotencyConflictException(cmd.idempotencyKey());
            }
            return existing.get().id();
        }

        var debit = accounts.get(cmd.debitAccountId());
        var credit = accounts.get(cmd.creditAccountId());
        if (!debit.currency().equals(cmd.currency()) || !credit.currency().equals(cmd.currency())) {
            throw new CurrencyMismatchException(cmd);   // FX is two transactions, one per currency
        }
        var debitAfter = debit.apply("DEBIT", cmd.amount());
        var creditAfter = credit.apply("CREDIT", cmd.amount());
        rejectIfNegative(debit, debitAfter, cmd);
        rejectIfNegative(credit, creditAfter, cmd);

        var txId = ids.next();
        insertTransaction(txId, cmd);                     // carries intent_hash, reverses_id, fx_rate
        insertPosting(txId, debit, "DEBIT", cmd, debitAfter);
        insertPosting(txId, credit, "CREDIT", cmd, creditAfter);
        updateBalance(debit.id(), debitAfter);
        updateBalance(credit.id(), creditAfter);
        // When consumers exist: append LedgerPosted to the outbox here, in this transaction.
        return txId;
    }

    @Transactional
    public long reverse(long originalId, String idempotencyKey, String reasonCode) {
        // Swaps the original legs; reverses_id is UNIQUE, so a second reversal fails in the database.
        return post(PostCommand.reversalOf(loadTransaction(originalId), idempotencyKey, reasonCode));
    }

    record LockedAccount(long id, String currency, String normalBalance,
                         boolean allowNegative, BigDecimal balance) {
        BigDecimal apply(String direction, BigDecimal amount) {
            return normalBalance.equals(direction) ? balance.add(amount) : balance.subtract(amount);
        }
    }
}
```

If the ledger supports holds, available funds are the balance minus active holds on the debited
account, read under the same lock.

## Integration test

The application's own migration tool builds the schema in the container, so the test exercises the
real changesets. `@ServiceConnection` needs Spring Boot 3.1+; on older versions register the
datasource with `@DynamicPropertySource`. Pin the Postgres image to the production major version.

```java
@SpringBootTest
@Testcontainers
class LedgerPostingServiceIT {

    // transfer(key, source, target, amount) debits source and credits target.

    @Container @ServiceConnection
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");

    @Autowired LedgerPostingService ledger;
    @Autowired JdbcClient jdbc;

    @Test
    void transfer_keeps_postings_balanced_and_balances_reconciled() {
        var source = givenAccount("CREDIT", "1000.00");  // customer wallets: credit-normal liabilities
        var target = givenAccount("CREDIT", "0.00");

        ledger.post(transfer("k-1", source, target, "100.00"));

        assertThat(balanceOf(source)).isEqualByComparingTo("900.00");
        assertThat(balanceOf(target)).isEqualByComparingTo("100.00");
        assertThat(unbalancedTransactions()).isEmpty();      // queries from pgledger-invariants.md
        assertThat(balanceDrift()).isEmpty();
    }

    @Test
    void rejects_transfer_that_would_overdraw_source() {
        var source = givenAccount("CREDIT", "50.00");
        var target = givenAccount("CREDIT", "0.00");

        assertThatThrownBy(() -> ledger.post(transfer("k-1", source, target, "100.00")))
            .isInstanceOf(InsufficientFundsException.class);
    }

    @Test
    void replay_with_same_key_returns_original_and_posts_once() {
        var source = givenAccount("CREDIT", "1000.00");
        var target = givenAccount("CREDIT", "0.00");
        var cmd = transfer("k-dup", source, target, "100.00");

        assertThat(ledger.post(cmd)).isEqualTo(ledger.post(cmd));
        assertThat(balanceOf(source)).isEqualByComparingTo("900.00");
    }

    @Test
    void same_key_with_different_amount_is_a_conflict() {
        var source = givenAccount("CREDIT", "1000.00");
        var target = givenAccount("CREDIT", "0.00");
        ledger.post(transfer("k-1", source, target, "100.00"));

        assertThatThrownBy(() -> ledger.post(transfer("k-1", source, target, "200.00")))
            .isInstanceOf(IdempotencyConflictException.class);
    }
}
```

Add a concurrent-posting test (two threads moving money between the same pair in opposite
directions) when the change touches locking.

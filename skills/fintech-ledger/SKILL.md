---
name: fintech-ledger
description: >
  Use this skill whenever the user needs to design or implement double-entry ledger operations, wallet movements, balance tracking, or reconciliation for a fintech system. ALWAYS trigger on: "ledger", "double-entry", "debit credit", "wallet operation", "post to ledger", "ledger entry", "balance check", "reconciliation", "hold release", "capture funds", "refund capture", "multi-currency ledger", "fx conversion", "pgledger", "blnk", "ledger_accounts", "ledger_transfers", "ledger_postings". Implicit triggers: user describes money moving between two places (user wallet → merchant wallet, customer → escrow), user mentions "wallet credit" or "wallet debit", user talks about float management, user wants idempotent payment operations, user mentions remittance/payout/collection/settlement, user asks about balance invariants or "balance mismatch".
  Supports two modes: **Blnk** (Onbilia remittance — uses Blnk Finance engine with HTTP API) and **pgledger** (PayserFlow — pure PostgreSQL implementation with advisory locks, materialized balances, append-only triggers). Auto-detects which mode to use from the project (checks dependencies, configuration, existing tables). Encodes user patterns: posting rules (hold → settle → release / hold → reverse / authorize → capture → refund), idempotency keys on all postings, multi-currency support with FX rate snapshots, sorted account locking to prevent deadlocks, reconciliation hooks (expected vs actual), audit trail via domain events. Generates Java/Spring Boot code (services, DTOs, Liquibase migrations), test fixtures, and reconciliation queries.
argument-hint: "[operation name] [description] OR spec file path"
context: fork
agent: general-purpose
effort: high
---

# Fintech Ledger: Double-Entry Pattern Skill

Generates double-entry ledger operations with compensation, idempotency, multi-currency support, and reconciliation. Supports **Blnk** (API-based) or **pgledger** (pure PostgreSQL) depending on project.

---

## Before You Start — Superpowers Workflow

This skill generates money-moving code. **Every step of the superpowers workflow is mandatory — no exceptions.**

1. **superpowers:brainstorming** — mandatory. Explore: what accounts move, what currency, what FX rate snapshot strategy, what compensation strategy, what invariants (balance sum == posting sum), what idempotency key shape, what happens on partial failure. This is the single highest-ROI step — skipping it leads to unrecoverable balance corruption.
2. **superpowers:writing-plans** — produce a reviewable plan listing every posting, every account lock order, every reversal path, every reconciliation query. No inline code yet.
3. **superpowers:using-git-worktrees** — isolate the ledger work in its own branch. Never commingle ledger changes with unrelated refactors.
4. **superpowers:test-driven-development** — mandatory. Write Testcontainers integration tests FIRST that assert: balanced postings, idempotency (duplicate key returns same result), sorted locking (no deadlocks), reconciliation invariant (`SUM(postings) == materialized_balance`), insufficient-funds rejection, reversal correctness. Then implement. **Do not write ledger code without red tests first.**
5. Invoke **this skill** in the TDD green phase to produce the service, repository, Liquibase migration (pgledger mode), and domain events. May dispatch via **superpowers:subagent-driven-development** if generating multiple independent operations.
6. **superpowers:verification-before-completion** — mandatory. Run the integration test suite with real Postgres via Testcontainers. Paste actual output showing all assertions pass. Run a reconciliation query on the test DB and paste the zero-delta result. Claims without command output are rejected.
7. **superpowers:requesting-code-review** — mandatory for money code. Flag which invariants the reviewer must verify. Link to Blnk API docs (Onbilia mode) or pgledger correctness proof (PayserFlow mode).

**Special rule**: if the user asks to modify an existing ledger service without going through brainstorming → plans → TDD → verify, refuse politely and point them at this workflow. Ledger bugs do not self-correct; they compound into balance mismatches that require manual audit to fix.

---

## 0. Mode Detection

```bash
# Blnk mode indicators
grep -rE "blnkfinance|blnk-go|blnk-client" build.gradle* pom.xml 2>/dev/null && echo "Blnk mode"
grep -rE "docs\.blnkfinance\.com" . 2>/dev/null && echo "Blnk references present"

# pgledger mode indicators
grep -rE "ledger_accounts|ledger_postings|ledger_transfers" src/main/resources/db 2>/dev/null && echo "pgledger mode"
[ -f "backend/src/main/java/com/payser/flow/ledger" ] && echo "PayserFlow pgledger"

# Fallback: ask user
```

Report detected mode to user before generating code:
```
💰 LEDGER MODE DETECTED
  Project:    <name>
  Mode:       <blnk | pgledger>
  Engine:     <Blnk HTTP API | PostgreSQL native>
  Proceeding with <mode>-specific patterns.
```

---

## 1. Core Invariants (both modes)

These invariants hold regardless of engine. Every generated operation must preserve them:

1. **Balanced**: `SUM(debits) == SUM(credits)` for every transaction atomically. No partial posts.
2. **Idempotent**: every posting carries an idempotency key (`<domain>:<operation>:<business-id>`). Duplicate calls return the original posting without side effects.
3. **Sorted locking**: when locking multiple accounts, always acquire locks in canonical order (account ID ascending) to prevent deadlocks.
4. **Append-only**: postings are never updated or deleted. Corrections are new postings.
5. **FX snapshot**: cross-currency operations capture the FX rate at post-time as a field on the posting — never look it up later.
6. **Audit trail**: every state change publishes a domain event (`LedgerPosted`, `BalanceChanged`) consumed by audit/reporting.
7. **Reconciliation hooks**: after every operation, verify `materialized_balance == SUM(posting_amounts)` for affected accounts.

---

## 2. Mode A: Blnk (Onbilia)

### 2.1 Client Wrapper

```java
@Component
public class BlnkLedgerClient {

    private final RestClient restClient;
    private final BlnkProperties props;

    public BlnkLedgerClient(RestClient.Builder builder, BlnkProperties props) {
        this.restClient = builder
            .baseUrl(props.baseUrl())
            .defaultHeader("X-API-KEY", props.apiKey())
            .build();
        this.props = props;
    }

    public BlnkTransactionResponse createTransaction(BlnkTransactionRequest request) {
        return restClient.post()
            .uri("/transactions")
            .body(request)
            .retrieve()
            .body(BlnkTransactionResponse.class);
    }

    public BlnkBalanceResponse getBalance(String balanceId) {
        return restClient.get()
            .uri("/balances/{id}", balanceId)
            .retrieve()
            .body(BlnkBalanceResponse.class);
    }

    public List<BlnkBalance> searchBalances(String identifier) {
        return restClient.get()
            .uri(uriBuilder -> uriBuilder.path("/search/balances")
                .queryParam("q", identifier).build())
            .retrieve()
            .body(new ParameterizedTypeReference<>() {});
    }
}
```

### 2.2 Service Layer — Hold/Capture/Release Pattern

```java
@Service
@Transactional
public class WalletLedgerService {

    private final BlnkLedgerClient blnk;
    private final IdempotencyStore idempotency;
    private final DomainEventPublisher events;

    public WalletLedgerService(BlnkLedgerClient blnk,
                                IdempotencyStore idempotency,
                                DomainEventPublisher events) {
        this.blnk = blnk;
        this.idempotency = idempotency;
        this.events = events;
    }

    public TransactionId placeHold(HoldCommand cmd) {
        var key = "wallet:hold:" + cmd.correlationId();
        return idempotency.executeOnce(key, () -> {
            var request = BlnkTransactionRequest.builder()
                .amount(cmd.amount())
                .precision(100) // 2-decimal precision
                .reference(cmd.correlationId())
                .description("Hold for " + cmd.purpose())
                .currency(cmd.currency())
                .source(cmd.sourceBalanceId())
                .destination(props.holdBalanceId())    // escrow
                .inflightExpiryDate(cmd.expiresAt())
                .metadata(Map.of(
                    "tenant_id", cmd.tenantId(),
                    "purpose",   cmd.purpose(),
                    "user_id",   cmd.userId()
                ))
                .inflight(true)   // HOLD = inflight=true
                .build();

            var response = blnk.createTransaction(request);
            events.publish(new FundsHeldEvent(
                cmd.tenantId(), cmd.userId(), response.transactionId(),
                cmd.amount(), cmd.currency(), Instant.now()
            ));
            return new TransactionId(response.transactionId());
        });
    }

    public void commitHold(String transactionId, String correlationId) {
        var key = "wallet:commit:" + correlationId;
        idempotency.executeOnce(key, () -> {
            blnk.commitInflight(transactionId);
            events.publish(new FundsCapturedEvent(
                transactionId, Instant.now()
            ));
            return null;
        });
    }

    public void voidHold(String transactionId, String correlationId, String reason) {
        var key = "wallet:void:" + correlationId;
        idempotency.executeOnce(key, () -> {
            blnk.voidInflight(transactionId);
            events.publish(new FundsReleasedEvent(
                transactionId, reason, Instant.now()
            ));
            return null;
        });
    }
}
```

### 2.3 Balance Query

```java
public BigDecimal availableBalance(String balanceId) {
    var response = blnk.getBalance(balanceId);
    // Blnk returns (balance - inflight_balance) as available
    return response.balance()
        .subtract(response.inflightBalance())
        .divide(BigDecimal.valueOf(response.precision()), 2, RoundingMode.HALF_UP);
}
```

### 2.4 Reconciliation

Daily job that compares Blnk balance to internal expected balance (from audit events):

```java
@Component
public class BlnkReconciliationJob {
    @Scheduled(cron = "0 0 2 * * *") // 2am daily
    public void reconcile() {
        for (var account : ledgerAccounts.findAll()) {
            var blnkBalance = blnk.getBalance(account.balanceId()).balance();
            var expectedBalance = auditEvents.sumDeltas(account.id());
            if (blnkBalance.compareTo(expectedBalance) != 0) {
                alerts.raise(new BalanceMismatchAlert(
                    account.id(), blnkBalance, expectedBalance
                ));
            }
        }
    }
}
```

---

## 3. Mode B: pgledger (PayserFlow pattern)

### 3.1 Schema (Liquibase)

```sql
--liquibase formatted sql
--changeset payserflow:ledger-001-core

CREATE TABLE ledger_accounts (
    id                BIGINT PRIMARY KEY,
    tenant_id         BIGINT NOT NULL,
    account_code      TEXT NOT NULL,
    currency          TEXT NOT NULL,
    balance           NUMERIC(20,2) NOT NULL DEFAULT 0,
    pending_debits    NUMERIC(20,2) NOT NULL DEFAULT 0,
    pending_credits   NUMERIC(20,2) NOT NULL DEFAULT 0,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, account_code, currency)
);

CREATE TABLE ledger_transfers (
    id                BIGINT PRIMARY KEY,
    tenant_id         BIGINT NOT NULL,
    idempotency_key   TEXT NOT NULL,
    amount            NUMERIC(20,2) NOT NULL CHECK (amount > 0),
    currency          TEXT NOT NULL,
    source_account_id BIGINT NOT NULL REFERENCES ledger_accounts(id),
    target_account_id BIGINT NOT NULL REFERENCES ledger_accounts(id),
    status            TEXT NOT NULL CHECK (status IN ('PENDING','POSTED','REVERSED')),
    fx_rate           NUMERIC(20,8),
    reason_code       TEXT NOT NULL,
    metadata          JSONB NOT NULL DEFAULT '{}',
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    posted_at         TIMESTAMPTZ,
    UNIQUE (tenant_id, idempotency_key)
);

CREATE TABLE ledger_postings (
    id                BIGINT PRIMARY KEY,
    transfer_id       BIGINT NOT NULL REFERENCES ledger_transfers(id),
    account_id        BIGINT NOT NULL REFERENCES ledger_accounts(id),
    entry_type        TEXT NOT NULL CHECK (entry_type IN ('DEBIT','CREDIT')),
    amount            NUMERIC(20,2) NOT NULL CHECK (amount > 0),
    balance_after     NUMERIC(20,2) NOT NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_postings_account_time ON ledger_postings(account_id, created_at);
CREATE INDEX idx_transfers_tenant_status ON ledger_transfers(tenant_id, status);

-- Append-only trigger
CREATE OR REPLACE FUNCTION prevent_posting_mutation() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'ledger_postings is append-only';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER postings_append_only
BEFORE UPDATE OR DELETE ON ledger_postings
FOR EACH ROW EXECUTE FUNCTION prevent_posting_mutation();

--rollback DROP TRIGGER postings_append_only ON ledger_postings;
--rollback DROP FUNCTION prevent_posting_mutation();
--rollback DROP TABLE ledger_postings;
--rollback DROP TABLE ledger_transfers;
--rollback DROP TABLE ledger_accounts;
```

### 3.2 Service Layer — Sorted Account Locking

```java
@Service
@Transactional
public class PgLedgerService {

    private final LedgerAccountRepository accounts;
    private final LedgerTransferRepository transfers;
    private final LedgerPostingRepository postings;
    private final JdbcTemplate jdbc;
    private final DomainEventPublisher events;
    private final Tsid tsid;

    public TransferId post(PostCommand cmd) {
        // Idempotency check
        var existing = transfers.findByTenantAndKey(cmd.tenantId(), cmd.idempotencyKey());
        if (existing.isPresent()) return new TransferId(existing.get().id());

        // Sorted lock — always lock lowest account ID first to prevent deadlocks
        var sorted = Stream.of(cmd.sourceAccountId(), cmd.targetAccountId())
            .sorted()
            .toList();

        jdbc.update("SELECT id FROM ledger_accounts WHERE id = ANY(?) FOR UPDATE",
            sorted.toArray());

        var source = accounts.findByIdForUpdate(cmd.sourceAccountId()).orElseThrow();
        var target = accounts.findByIdForUpdate(cmd.targetAccountId()).orElseThrow();

        // Invariant: source must have enough balance
        if (source.balance().compareTo(cmd.amount()) < 0) {
            throw new InsufficientFundsException(source.accountCode(), source.balance(), cmd.amount());
        }

        // Write the transfer
        var transferId = tsid.next();
        var transfer = new LedgerTransfer(
            transferId, cmd.tenantId(), cmd.idempotencyKey(),
            cmd.amount(), cmd.currency(),
            cmd.sourceAccountId(), cmd.targetAccountId(),
            "POSTED", cmd.fxRate(), cmd.reasonCode(), cmd.metadata(),
            Instant.now(), Instant.now()
        );
        transfers.save(transfer);

        // Write balanced postings (debit + credit)
        var newSourceBalance = source.balance().subtract(cmd.amount());
        var newTargetBalance = target.balance().add(cmd.amount());

        postings.save(new LedgerPosting(tsid.next(), transferId, source.id(), "DEBIT",  cmd.amount(), newSourceBalance, Instant.now()));
        postings.save(new LedgerPosting(tsid.next(), transferId, target.id(), "CREDIT", cmd.amount(), newTargetBalance, Instant.now()));

        // Update materialized balances
        accounts.updateBalance(source.id(), newSourceBalance);
        accounts.updateBalance(target.id(), newTargetBalance);

        // Reconciliation check (defensive)
        verifyPostingSumEqualsBalance(source.id());
        verifyPostingSumEqualsBalance(target.id());

        events.publish(new LedgerPostedEvent(
            cmd.tenantId(), transferId, source.id(), target.id(),
            cmd.amount(), cmd.currency(), cmd.reasonCode(), Instant.now()
        ));
        return new TransferId(transferId);
    }

    private void verifyPostingSumEqualsBalance(long accountId) {
        var sumFromPostings = jdbc.queryForObject("""
            SELECT COALESCE(SUM(CASE WHEN entry_type = 'CREDIT' THEN amount ELSE -amount END), 0)
              FROM ledger_postings WHERE account_id = ?
            """, BigDecimal.class, accountId);
        var materialized = accounts.findById(accountId).orElseThrow().balance();
        if (sumFromPostings.compareTo(materialized) != 0) {
            throw new LedgerInvariantViolationException(accountId, sumFromPostings, materialized);
        }
    }
}
```

### 3.3 Reversal

```java
public TransferId reverse(long originalTransferId, String reasonCode, String idempotencyKey) {
    var original = transfers.findById(originalTransferId).orElseThrow();
    // Reverse by swapping source/target — produces DEBIT on original target, CREDIT on original source
    return post(new PostCommand(
        original.tenantId(),
        idempotencyKey,
        original.amount(),
        original.currency(),
        original.targetAccountId(),   // was destination, now source
        original.sourceAccountId(),   // was source, now destination
        original.fxRate(),
        reasonCode,
        Map.of("reverses", String.valueOf(originalTransferId))
    ));
}
```

---

## 4. Testing

### 4.1 Unit Tests (pgledger mode)

Use Testcontainers with real PostgreSQL — pgledger invariants depend on real DB behavior (triggers, advisory locks, check constraints).

```java
@SpringBootTest
@Testcontainers
class PgLedgerServiceTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16")
        .withInitScript("db/migration/V1__ledger_schema.sql");

    @DynamicPropertySource
    static void registerProps(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired private PgLedgerService service;
    @Autowired private LedgerAccountRepository accounts;

    @Test
    void should_maintain_balance_invariant_when_posting_transfer() {
        // Given
        var source = givenAccount("source", new BigDecimal("1000.00"));
        var target = givenAccount("target", BigDecimal.ZERO);

        // When
        service.post(new PostCommand(
            1L, "k-1", new BigDecimal("100.00"), "USD",
            source.id(), target.id(), null, "TRANSFER_OUT", Map.of()
        ));

        // Then
        assertThat(accounts.findById(source.id()).get().balance())
            .isEqualByComparingTo("900.00");
        assertThat(accounts.findById(target.id()).get().balance())
            .isEqualByComparingTo("100.00");
    }

    @Test
    void should_reject_posting_when_source_has_insufficient_funds() {
        // Given
        var source = givenAccount("source", new BigDecimal("50.00"));
        var target = givenAccount("target", BigDecimal.ZERO);

        // Then
        assertThatThrownBy(() -> service.post(new PostCommand(
            1L, "k-1", new BigDecimal("100.00"), "USD",
            source.id(), target.id(), null, "TRANSFER_OUT", Map.of()
        ))).isInstanceOf(InsufficientFundsException.class);
    }

    @Test
    void should_be_idempotent_when_same_key_posted_twice() {
        var source = givenAccount("source", new BigDecimal("1000.00"));
        var target = givenAccount("target", BigDecimal.ZERO);

        var cmd = new PostCommand(1L, "k-dup", new BigDecimal("100.00"), "USD",
            source.id(), target.id(), null, "TRANSFER_OUT", Map.of());

        var first  = service.post(cmd);
        var second = service.post(cmd);

        assertThat(second).isEqualTo(first);
        assertThat(accounts.findById(source.id()).get().balance())
            .isEqualByComparingTo("900.00");
    }
}
```

---

## 5. Output Contract

```yaml
produces:
  - type: "code"
    format: "java"
    paths:
      - "src/main/java/.../ledger/{Service}.java"
      - "src/main/java/.../ledger/{Repository}.java"
      - "src/main/java/.../ledger/events/*.java"    # domain events
      - "src/main/java/.../ledger/dto/*.java"       # commands + DTOs
  - type: "migration"
    format: "sql"
    paths:
      - "src/main/resources/db/changelog/changes/sql/ledger-NNN-description.sql"  # pgledger mode only
  - type: "test"
    format: "java"
    paths:
      - "src/test-integration/java/.../ledger/{Service}IntegrationTest.java"  # Testcontainers
  - type: "doc"
    format: "markdown"
    path: "docs/ledger/{operation}.md"
  handoff: "Write claudedocs/handoff-fintech-ledger-<timestamp>.yaml — suggest: temporal-workflow (if compensation needed), verify-impl, monitoring-plan"
```

---

## 6. Anti-patterns (never generate)

- **Floating point for money**: never `double`/`float`/`Double` for amounts — always `BigDecimal` with explicit scale
- **Single-leg postings**: every transfer must have a debit AND credit pair within one DB transaction
- **Update/delete on postings**: ledger is append-only; reversals create new postings
- **Cross-currency without FX snapshot**: always capture rate on the posting row
- **Unsorted multi-account locks**: sort by ID ascending before locking to prevent deadlock
- **Raw SQL in service layer (pgledger)**: use repositories or jOOQ, not string concatenation (except the FOR UPDATE lock statement which has no repository equivalent)
- **Balance check without FOR UPDATE**: read-modify-write without explicit lock is a race condition
- **Negative amounts in the amount column**: use `entry_type` to signal direction; `amount` is always positive
- **Missing idempotency key**: every POST-style operation must accept and dedupe on an idempotency key
- **Skipping reconciliation**: the materialized balance MUST equal the sum of postings — verify after every post

---

## 7. Reference Files

| File | When |
|---|---|
| `references/blnk-api-contract.md` | Full Blnk HTTP contract if generating Blnk-mode |
| `references/pgledger-invariants.md` | Deep invariants + proof of correctness for pgledger |

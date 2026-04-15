---
name: temporal-workflow
description: >
  Use this skill whenever the user needs to design, implement, or review a Temporal.io workflow in Java — especially SAGA compensation chains, long-running orchestrations, config-driven state machines, or multi-step business processes that survive service restarts. ALWAYS trigger when the user mentions: "temporal workflow", "saga", "compensation", "long-running workflow", "state machine workflow", "orchestration", "durable execution", "temporal activity", "workflow retry", "signal handler", "query handler", "workflow versioning", "child workflow", "continue as new". Implicit triggers: user describes a multi-step business process with failure rollback, user wants an idempotent pipeline with retries, user describes "forward execution with compensation on failure", user mentions Kifiya/Onbilia/PayserFlow payment orchestration, user references `io.temporal.workflow.*` imports, user asks how to implement X "that can recover from failure".
  Stack defaults: Java 25 + Spring Boot 4 + Temporal Java SDK 1.26+ + Gradle (or Maven). Encodes the user's established patterns: config-driven state machines from YAML (reason-codes, transition tables), SAGA with compensation registered BEFORE forward execution, three retry profiles (DEFAULT/LIMITED/AGGRESSIVE), idempotency keys on all activities, workflow/activity separation (workflows are deterministic, activities are idempotent), worker config with task queue routing, signal/query handlers for external inspection. Also produces Spring Boot integration glue (worker beans, activity beans, worker factory), Temporal-specific test setup (TestWorkflowEnvironment), and observability wiring (OpenTelemetry spans across workflow/activity boundaries).
argument-hint: "[workflow name] [brief description] OR path to spec file"
context: fork
agent: general-purpose
effort: high
---

# Temporal Workflow: Java SDK Implementation Skill

Generates production-ready Temporal workflows with SAGA compensation, config-driven state machines, Spring Boot integration, and full test harness. Encodes patterns proven in PayserFlow, Kifiya, and Onbilia.

---

## Before You Start — Superpowers Workflow

This skill generates production code for durable, money-adjacent orchestrations. It MUST run through the superpowers development workflow — do not invoke it in isolation.

1. **superpowers:brainstorming** — mandatory. Explore intent, failure modes, compensation chain, idempotency keys, and state machine shape before any code. Workflow mistakes are expensive to fix after deploy.
2. **superpowers:writing-plans** — produce a multi-step plan naming each activity, each compensation, each signal/query, and the retry profile per activity. Review the plan before touching code.
3. **superpowers:using-git-worktrees** — create an isolated worktree so the workflow generation does not collide with other parallel work.
4. **superpowers:test-driven-development** — write the `TestWorkflowEnvironment` test FIRST (asserting compensation order on failure), then implement. Rigid skill — don't skip.
5. Invoke **this skill** inside the TDD green phase to scaffold the `@WorkflowInterface`, `@WorkflowImpl`, activities, and Spring wiring. Use **superpowers:dispatching-parallel-agents** if workflow + activities + Spring config can be written by independent agents.
6. **superpowers:verification-before-completion** — run `./gradlew test` (or `./mvnw test`) and paste the output showing compensation order. Do not claim done without proof.
7. **superpowers:requesting-code-review** — before merging. Temporal workflows are hard to review blindly — be explicit about what reviewer must check.

**Non-negotiable**: brainstorming and TDD are mandatory here. Workflow determinism bugs, missing compensation, and non-idempotent activities are the top three failure modes — all caught by proper brainstorming + TDD.

---

## 0. Input Handling

```
/temporal-workflow $ARGUMENTS
```

Accepts:
- Workflow name + short description: `/temporal-workflow PaymentSaga "collect card, authorize, charge, notify"`
- Spec file path: `/temporal-workflow docs/payment-saga-spec.md`
- Interactive: no args → ask for workflow name, steps, compensation needs

**Step 1 — Parse and confirm scope:**
```
⚙️ WORKFLOW SCOPE
  Name:          <WorkflowInterfaceName>
  Package:       <com.company.module.workflow>
  Forward steps: <n>   (each becomes an activity)
  Compensation:  <n>   (matching reverse activities)
  Retry profile: DEFAULT | LIMITED | AGGRESSIVE
  Signals:       <list>
  Queries:       <list>
  Child flows:   <list or "none">
  Long-running?  yes/no  (if yes → ContinueAsNew strategy)
```

**Step 2 — Detect stack:**
```bash
grep -rE "io\.temporal\.|temporal-sdk|temporal-spring-boot" build.gradle* pom.xml 2>/dev/null
grep -rE "workerFactory|WorkflowServiceStubs" src/ 2>/dev/null | head -10
```

If Temporal isn't already wired up → generate worker factory + service stub config first. Otherwise reuse existing wiring.

---

## 1. Core Patterns

### 1.1 Workflow vs Activity Separation (non-negotiable)

**Workflows are deterministic.** No `Instant.now()`, no random, no direct I/O, no shared mutable state. Only:
- Call activities via `Workflow.newActivityStub(...)`
- Use `Workflow.sleep`, `Workflow.currentTimeMillis`, `Workflow.newRandom`
- Read workflow state and issue control flow

**Activities are idempotent.** Every activity must be safe to retry. Use an idempotency key in the input (usually `workflowId + step`). Database writes use `INSERT ... ON CONFLICT DO NOTHING` or upsert semantics.

### 1.2 SAGA Compensation Chain

Register compensation BEFORE executing the forward step. If the forward step throws, the compensation chain unwinds in reverse order.

```java
@WorkflowImpl(taskQueues = "payment-saga")
public class PaymentSagaWorkflowImpl implements PaymentSagaWorkflow {

    private final PaymentActivities activities = Workflow.newActivityStub(
        PaymentActivities.class,
        ActivityOptions.newBuilder()
            .setStartToCloseTimeout(Duration.ofSeconds(30))
            .setRetryOptions(RetryProfiles.DEFAULT)
            .build()
    );

    private final Saga saga = new Saga(new Saga.Options.Builder().setParallelCompensation(false).build());

    @Override
    public PaymentResult execute(PaymentCommand cmd) {
        var correlationId = cmd.correlationId();

        try {
            saga.addCompensation(activities::releaseHold, correlationId);
            var hold = activities.placeHold(cmd);

            saga.addCompensation(activities::reverseAuthorization, correlationId);
            var auth = activities.authorize(hold);

            saga.addCompensation(activities::refundCapture, correlationId);
            var capture = activities.capture(auth);

            activities.notifyCustomer(cmd.customerId(), capture.receipt());
            return new PaymentResult(capture.id(), capture.amount());

        } catch (ActivityFailure | ApplicationFailure e) {
            saga.compensate();
            throw Workflow.wrap(e);
        }
    }
}
```

### 1.3 Config-Driven State Machines

Behavior lives in YAML, not `if/switch`. Workflow reads transition tables at startup.

```yaml
# src/main/resources/config/payment-saga.yaml
states:
  PENDING:
    on:
      AUTHORIZE: { next: AUTHORIZED, activity: authorize }
      CANCEL:    { next: CANCELLED, activity: cancelPending }
  AUTHORIZED:
    on:
      CAPTURE:   { next: CAPTURED,  activity: capture }
      VOID:      { next: VOIDED,    activity: voidAuth }
  CAPTURED:
    terminal: true
  CANCELLED:
    terminal: true
  VOIDED:
    terminal: true
transitions:
  retry_policy: DEFAULT
  idempotency_key_pattern: "{workflowId}:{event}"
```

`@ConfigurationProperties(prefix = "payment.saga")` loads this into a `StateMachineConfig` bean — injected into the workflow via its activities (workflows cannot directly access Spring beans).

### 1.4 Three Retry Profiles

```java
public final class RetryProfiles {
    public static final RetryOptions DEFAULT = RetryOptions.newBuilder()
        .setInitialInterval(Duration.ofSeconds(1))
        .setBackoffCoefficient(2.0)
        .setMaximumInterval(Duration.ofMinutes(1))
        .setMaximumAttempts(5)
        .build();

    public static final RetryOptions LIMITED = RetryOptions.newBuilder()
        .setInitialInterval(Duration.ofSeconds(2))
        .setBackoffCoefficient(1.5)
        .setMaximumAttempts(2)
        .setDoNotRetry("io.temporal.failure.ApplicationFailure")
        .build();

    public static final RetryOptions AGGRESSIVE = RetryOptions.newBuilder()
        .setInitialInterval(Duration.ofMillis(250))
        .setBackoffCoefficient(2.0)
        .setMaximumInterval(Duration.ofSeconds(10))
        .setMaximumAttempts(20)
        .build();

    private RetryProfiles() {}
}
```

Choose per activity: external-API writes → `LIMITED`, internal idempotent writes → `DEFAULT`, read-only lookups → `AGGRESSIVE`.

### 1.5 Signals and Queries

```java
@WorkflowInterface
public interface PaymentSagaWorkflow {
    @WorkflowMethod PaymentResult execute(PaymentCommand cmd);
    @SignalMethod  void cancel(String reason);
    @SignalMethod  void updateAmount(BigDecimal newAmount);
    @QueryMethod   PaymentState currentState();
    @QueryMethod   List<String> completedSteps();
}
```

Signals mutate state and unblock `Workflow.await(...)`. Queries are read-only — never mutate state, never call activities.

### 1.6 Long-Running: ContinueAsNew

If a workflow accumulates large history (>50k events or >50MB), continue-as-new to reset history while preserving identity:

```java
if (eventCount > 10_000) {
    Workflow.continueAsNew(currentState);
}
```

---

## 2. Spring Boot Integration

### 2.1 Worker Factory + Bean Wiring

```java
@Configuration
public class TemporalConfig {

    @Bean
    public WorkflowServiceStubs workflowServiceStubs(TemporalProperties props) {
        return WorkflowServiceStubs.newServiceStubs(
            WorkflowServiceStubsOptions.newBuilder()
                .setTarget(props.target())
                .build()
        );
    }

    @Bean
    public WorkflowClient workflowClient(WorkflowServiceStubs stubs, TemporalProperties props) {
        return WorkflowClient.newInstance(stubs,
            WorkflowClientOptions.newBuilder().setNamespace(props.namespace()).build());
    }

    @Bean(destroyMethod = "shutdown")
    public WorkerFactory workerFactory(WorkflowClient client) {
        return WorkerFactory.newInstance(client);
    }

    @Bean
    public Worker paymentSagaWorker(WorkerFactory factory, PaymentActivitiesImpl activities) {
        Worker worker = factory.newWorker("payment-saga",
            WorkerOptions.newBuilder()
                .setMaxConcurrentActivityExecutionSize(50)
                .setMaxConcurrentWorkflowTaskExecutionSize(20)
                .build());
        worker.registerWorkflowImplementationTypes(PaymentSagaWorkflowImpl.class);
        worker.registerActivitiesImplementations(activities);
        return worker;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void startWorkers(WorkerFactory factory) { factory.start(); }
}
```

### 2.2 Activity Implementation (Spring-managed)

```java
@Component
public class PaymentActivitiesImpl implements PaymentActivities {

    private final PaymentGatewayClient gateway;
    private final IdempotencyStore idempotency;
    private final LedgerService ledger;

    public PaymentActivitiesImpl(PaymentGatewayClient gateway,
                                  IdempotencyStore idempotency,
                                  LedgerService ledger) {
        this.gateway = gateway;
        this.idempotency = idempotency;
        this.ledger = ledger;
    }

    @Override
    public HoldResult placeHold(PaymentCommand cmd) {
        var key = cmd.correlationId() + ":placeHold";
        return idempotency.executeOnce(key, () -> gateway.placeHold(cmd));
    }

    @Override
    public void releaseHold(String correlationId) {
        var key = correlationId + ":releaseHold";
        idempotency.executeOnce(key, () -> gateway.releaseHold(correlationId));
    }
    // ... etc
}
```

---

## 3. Test Harness

Use `TestWorkflowEnvironment` — no real Temporal server required for unit tests.

```java
@ExtendWith(MockitoExtension.class)
class PaymentSagaWorkflowTest {

    private TestWorkflowEnvironment env;
    private Worker worker;
    private WorkflowClient client;

    @Mock private PaymentActivities activities;

    @BeforeEach
    void setUp() {
        env = TestWorkflowEnvironment.newInstance();
        worker = env.newWorker("payment-saga");
        worker.registerWorkflowImplementationTypes(PaymentSagaWorkflowImpl.class);
        worker.registerActivitiesImplementations(activities);
        client = env.getWorkflowClient();
        env.start();
    }

    @AfterEach
    void tearDown() { env.close(); }

    @Test
    void should_compensate_when_capture_fails() {
        // Given
        given(activities.placeHold(any())).willReturn(new HoldResult("hold-1"));
        given(activities.authorize(any())).willReturn(new AuthResult("auth-1"));
        given(activities.capture(any())).willThrow(new ApplicationFailure("DECLINED", "CARD_DECLINED", true));

        var workflow = client.newWorkflowStub(PaymentSagaWorkflow.class,
            WorkflowOptions.newBuilder().setTaskQueue("payment-saga").build());

        // When / Then
        assertThatThrownBy(() -> workflow.execute(new PaymentCommand("c-1", new BigDecimal("100.00"))))
            .isInstanceOf(WorkflowException.class);

        // Then — compensations ran in reverse
        var inOrder = inOrder(activities);
        inOrder.verify(activities).placeHold(any());
        inOrder.verify(activities).authorize(any());
        inOrder.verify(activities).capture(any());
        inOrder.verify(activities).reverseAuthorization("c-1");
        inOrder.verify(activities).releaseHold("c-1");
    }
}
```

---

## 4. Observability Wiring

- Workflow start/complete: Micrometer counter `temporal.workflow.{name}.{status}.count`
- Activity duration: Micrometer timer `temporal.activity.{name}.duration`
- Span propagation: use `io.temporal:temporal-opentracing` bridge or the native Micrometer Tracing interceptor
- MDC context: put `workflowId`, `runId`, `activityType` at the start of each activity

Configure interceptors in `WorkerFactoryOptions` so every workflow and activity is traced automatically — do not add per-method instrumentation.

---

## 5. Output Contract

```yaml
produces:
  - type: "code"
    format: "java"
    paths:
      - "src/main/java/.../workflow/{WorkflowName}.java"            # @WorkflowInterface
      - "src/main/java/.../workflow/{WorkflowName}Impl.java"        # @WorkflowImpl
      - "src/main/java/.../workflow/{WorkflowName}Activities.java"  # Activity interface
      - "src/main/java/.../workflow/{WorkflowName}ActivitiesImpl.java"
      - "src/main/java/.../workflow/RetryProfiles.java"             # one-per-project
      - "src/main/java/.../config/TemporalConfig.java"              # one-per-project
      - "src/main/resources/config/{workflow-name}.yaml"            # state machine config
  - type: "test"
    format: "java"
    paths:
      - "src/test/java/.../workflow/{WorkflowName}Test.java"        # TestWorkflowEnvironment
  - type: "doc"
    format: "markdown"
    path: "docs/workflows/{workflow-name}.md"                       # sequence diagram + runbook
  handoff: "Write claudedocs/handoff-temporal-workflow-<timestamp>.yaml — suggest: verify-impl, monitoring-plan"
```

---

## 6. Failure Modes

| Symptom | Diagnosis | Fix |
|---|---|---|
| Workflow replay fails after redeploy | Non-deterministic code path added | Move to activity; use `Workflow.getVersion()` for versioning |
| Activity hangs forever | Missing StartToCloseTimeout | Set explicit timeout in `ActivityOptions` |
| Compensation doesn't run | Exception caught and swallowed | Only catch `ActivityFailure`/`ApplicationFailure`; let others propagate |
| Duplicate side-effects on retry | Activity not idempotent | Add idempotency key at entry; dedupe at DB layer |
| Signal race with completion | Signal arrives after `@WorkflowMethod` returns | Drain signals before returning: `Workflow.await(() -> pendingSignals.isEmpty())` |
| History grows unbounded | Long-running loop without continueAsNew | Add `Workflow.continueAsNew(...)` at checkpoint |

---

## 7. Reference Files

| File | When |
|---|---|
| `references/temporal-patterns.md` | Deep patterns: versioning, cron, child flows, dynamic dispatch |

## Anti-patterns (never generate this)

- Calling Spring beans directly from `@WorkflowMethod` — use activities
- `Thread.sleep` inside a workflow — use `Workflow.sleep`
- Random numbers or UUIDs from `java.util.UUID.randomUUID()` inside a workflow — use `Workflow.newRandom()` or `Workflow.randomUUID()`
- Catching `Throwable` inside a workflow — you'll mask replay failures
- Calling activity inside a query handler — queries must be pure reads
- Mutating workflow state from a query handler — undefined behavior
- Mixing retry and compensation logic inside a single activity — separate concerns

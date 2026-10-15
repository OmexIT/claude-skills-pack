---
name: temporal-workflow
description: "Use when the work involves Temporal in Java: workflows, activities, SAGA compensation, long-running or durable orchestration, config-driven state machines, retries, signals, queries, versioning, child workflows, or continue-as-new."
---

# Temporal workflow (Java SDK)

Builds or changes Temporal workflows, activities, and their Spring wiring and tests. Determinism
bugs, missing compensation, and non-idempotent activities are the top three failure modes; the
steps below exist to prevent them.

## Steps

1. **Scope.** Accept a workflow name plus steps, a spec file, or ask. Confirm before code:
   ```
   Workflow:      <InterfaceName>, task queue <name>
   Forward steps: <activities, in order>
   Compensation:  <reverse activity per forward step, or "none">
   Retry policy:  <per activity, from the rules below>
   Signals/updates/queries: <list>
   Child workflows: <list or none>
   Long-running:  <yes -> continue-as-new checkpoint>
   ```
2. **Detect the stack** before using any API: Temporal Java SDK version, Spring Boot version, and
   whether the repo uses `temporal-spring-boot-starter` (auto-discovered `@WorkflowImpl` /
   `@ActivityImpl`) or manual `WorkerFactory` wiring.
   ```bash
   grep -rE "io\.temporal|temporal-sdk|temporal-spring-boot" build.gradle* pom.xml gradle/*.toml 2>/dev/null
   grep -rlE "WorkerFactory|@WorkflowImpl|@ActivityImpl" src/ 2>/dev/null | head
   ```
   Reuse the existing wiring. Use exactly one style; never register the same workflow through both.
3. **Read `references/temporal-patterns.md`** before writing workflow code (versioning, handlers,
   continue-as-new, child vs activity, config-driven machines, failure-mode table).
4. **Test first** with `TestWorkflowEnvironment`: forward path, compensation order on failure, and
   any signal, timer, or unknown-outcome path the change adds. Read `references/java-scaffolds.md`
   when scaffolding a saga, retry options, Spring wiring, or the test harness from scratch.
5. **Implement**, then run `./gradlew test` or `./mvnw test` and show the output, including the
   compensation-order test. For command-affecting changes to a deployed workflow, also run replay
   tests against recorded histories.
6. **Summarize for review**: determinism risks, versioning markers added, retry bounds, and which
   compensations assume "nothing to undo" is a no-op.

## Rules

- **Determinism**: workflow code uses `Workflow.currentTimeMillis`, `Workflow.sleep`,
  `Workflow.newRandom`, `Workflow.randomUUID`; no `Instant.now()`, `Thread.sleep`, I/O, Spring beans,
  or mutable statics. Side effects belong in activities.
- **Idempotent activities**: every mutating activity takes a stable key (for example
  `workflowId + ":" + step`) and dedupes at the authoritative boundary (unique constraint, provider
  idempotency key).
- **SAGA**: register each compensation before its forward step; compensations run in reverse and
  must treat "nothing to undo" as success. An unknown financial result (timeout after dispatch) is
  reconciled before any compensation. Catch the failure types the call actually raises
  (`ActivityFailure`, `ChildWorkflowFailure`), compensate, and rethrow; never catch `Throwable` or
  swallow cancellation. Run compensation on cancellation inside a detached cancellation scope.
- **Retries are bounded by operation semantics and provider limits**, not by service name:
  - External writes: few attempts, backoff that respects the provider's rate limits, durable
    idempotency key, business rejections listed as non-retryable error types.
  - Internal idempotent writes: bounded by the workflow's business deadline.
  - Reads: retry transient failures only, with a cap that cannot amplify an incident.
  - Long-running activities: start-to-close plus heartbeat timeout, and heartbeat progress.
  Never rely on the workflow execution timeout as the only bound.
- **Handlers**: queries read only. Validate signal and update payloads. Before the workflow method
  returns or continues as new, wait for domain work and for running handlers:
  `Workflow.await(() -> pendingWork.isEmpty())` then `Workflow.await(Workflow::isEveryHandlerFinished)`.
- **Versioning**: `Workflow.getVersion` around any change to the commands an open history would
  replay; pure refactors need no marker.
- **Continue-as-new** when history grows with a loop, signals, or timers; carry only durable state
  and finish handlers first.
- **Config-driven state machines** only when several real products or jurisdictions share a proven
  shape; pass an immutable, versioned config snapshot in the workflow input. One stable flow is plain
  code.
- **Observability**: wire the SDK's metrics scope and tracing interceptor once on the client and
  worker factory; put `workflowId` and `runId` in activity logs. No per-method instrumentation.

## Output contract

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
  handoff: "Write claudedocs/handoff-temporal-workflow-<timestamp>.yaml - suggest: verify-impl, monitoring-plan"
```

`TemporalConfig.java` only with manual wiring, the state machine YAML only for a config-driven
machine.

## Workflow context

- Ledger posting semantics and reconciliation live in `fintech-ledger`; this skill orchestrates the
  calls and compensation around them.

## Anti-patterns (never generate)

- Activities called from a query handler, or state mutated in one.
- Retry and compensation logic mixed inside a single activity.
- Reversing a transfer because the initiating activity timed out, before reconciling.
- A child workflow that only wraps one activity.
- Unbounded `maximumAttempts` on an external write.

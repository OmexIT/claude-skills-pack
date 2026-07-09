---
name: temporal
description: >
  Use when writing or changing Temporal workflows or activities in Java - SAGA compensation,
  retry policies, signals, workflow versioning, replay/determinism issues, or Spring Boot wiring.
argument-hint: "[workflow or activity]"
---

# Temporal workflows (Java SDK)

## House patterns
- **SAGA**: register each compensation BEFORE executing its forward step. Catch only `ActivityFailure | ChildWorkflowFailure | ApplicationFailure`; run compensations in reverse order.
- **Retry profiles** - choose by side-effect class, not by service:
  - `LIMITED` - external-API writes (payments, KYC, provider calls): few attempts, short cap.
  - `DEFAULT` - internal idempotent operations.
  - `AGGRESSIVE` - reads and queries.
- **State machines**: when transitions already live in config (multi-brand/multi-jurisdiction tables), drive them from YAML per Dynamic Dispatch in the reference; otherwise plain code.
- **Spring wiring**: temporal-spring-boot-starter with `@WorkflowImpl`/`@ActivityImpl` on beans; Spring beans are touched only from activities.
- **Versioning**: `Workflow.getVersion` around every behavior change while executions are open. `continueAsNew` carries forward only durable state.
- **Signal races**: drain with `Workflow.await(() -> pendingSignals.isEmpty())` before completing.

## Before writing code
Read `references/temporal-patterns.md` - versioning rules, continueAsNew criteria, child-workflow vs activity decision rule, fail-closed dynamic dispatch, and the failure-modes table (symptom → diagnosis → fix).

## Tests
`TestWorkflowEnvironment` with time-skipping; assert compensation order with Mockito `inOrder`; replay test against recorded histories for versioned changes.

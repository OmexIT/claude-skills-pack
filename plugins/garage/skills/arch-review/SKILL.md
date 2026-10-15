---
name: arch-review
description: "Use when the user asks for an architecture review of existing Java or Spring Boot code: clean or hexagonal architecture boundaries, module boundaries, dependency direction, domain leakage, transaction boundaries, or business logic in controllers."
---

# Architecture Review: Java and Spring Boundaries

Reviews a Java/Spring module against its architecture invariants: dependency direction, transaction
and external-effect boundaries, API and persistence boundaries, resilience semantics, and module
rules. Read-only: it produces findings and, on request, a fix plan, never inline fixes.

## Review workflow

1. Parse scope: a module name, a package path, or nothing (then the git-changed files or the module
   the user is working in). Mode is `report-only` unless the user asks for `fix-plan`.
2. Read the accepted architecture first: AGENTS.md / CLAUDE.md, ADRs, existing ArchUnit or Modulith
   tests, and `package-info.java`. Judge against what the repository accepted, not a textbook
   layout. Package names below (`api`, `application`, `domain`, `infrastructure`) are examples; map
   them to the repo's real layout.
3. Inventory: Java files per layer, controllers, services, repositories, clients, listeners.
4. If ArchUnit or Modulith verification exists, run it and record the result. If not, analyze with
   grep and file reads; propose ArchUnit only for boundaries the team has accepted and that recur.
5. Check each invariant below; use the leads table to find candidates, then prove reachable impact
   before assigning severity.
6. Write the report, and in fix-plan mode the tickets.

For a CRITICAL or HIGH finding, explain why the violation exists (shortcut, legacy constraint,
missing port, unclear boundary) before recommending a fix. Fixes go through the implementation
skill for the area (`api-first`, `temporal-workflow`, `fintech-ledger`) and a review before merge.

## Invariants

**Dependency direction.** Domain behavior does not depend on HTTP, persistence clients, messaging,
provider clients, or framework configuration. Application use cases coordinate the domain and
depend on ports; infrastructure implements ports; API code validates transport input, calls a use
case, and maps the result. Some repositories deliberately keep Spring Data mapping annotations on
aggregates: when the local architecture accepts that, it is not a finding.

**Transactions and external effects.**
- Transaction boundaries sit on application use cases, not controllers or private helpers.
- Private methods and self-invocation (`this.` calls) do not get a proxied transaction boundary.
- Remote calls stay outside database transactions unless an outbox, saga, durable operation
  record, or equivalent design handles the coupling.
- A timed-out remote mutation has an unknown result: persist that state, keep the same idempotency
  key, and reconcile before retrying or compensating.

**Resilience, chosen per operation from failure semantics.**
- Timeouts on every remote call.
- Bounded retries only for retryable, idempotent operations, with backoff and jitter.
- Bulkheads or concurrency limits where a shared resource needs protection.
- Circuit breakers only where repeated failures would amplify load and the open-circuit result has
  safe semantics. A breaker is not required on every HTTP, queue, or database call.
- Fallbacks must be honest: a clearly marked stale read or a fast explicit failure. A fallback that
  returns a fabricated outcome for a mutation (for example a "declined" or "success" result the
  provider never sent) is a finding, never a fix.

**API and persistence boundaries.** No request binding to entities and no entities returned from
controllers. Controller thinness is judged by responsibilities (transport only), not a line count.
Repositories persist and load; business decisions and cross-aggregate orchestration live in use
cases or domain services. Public identifiers never expose internal keys (TSIDs stay internal;
external IDs are UUIDv7); errors are RFC 9457 Problem Details.

**Value objects.** Use them when a concept carries validation, units, comparison, formatting,
security, or repeated business meaning (`Money` wrapping `BigDecimal` with a currency, tenant IDs,
operation references). Money is never `double`; time is `Instant`/`OffsetDateTime`. Do not wrap
every primitive to satisfy a pattern.

**Events and modules.** Use events when consumers cross a real boundary, need an independent
lifecycle or delivery, or the event is part of the audit trail. Prefer a direct call for simple
in-process coordination with one owner. Apply Spring Modulith rules only when the repository uses
Modulith; then verify declared dependencies, cycles, public interfaces, and
`ApplicationModules.verify()` coverage.

## Evidence leads

| Lead | What to verify |
|---|---|
| Spring or provider imports in the domain package | Domain behavior now depends on infrastructure, versus an accepted mapping annotation |
| Repository injected into a controller | API bypasses authorization, use-case rules, or transaction ownership |
| Entity returned from or bound in a controller | Persistence fields or internal IDs leak into the public contract |
| `@Transactional` on a private method, or a `this.` call to one | Boundary is ineffective under proxy mode |
| `@Transactional` on a controller | Transaction spans transport concerns |
| Remote client call inside a transaction | Lock duration and partial failure are explicitly designed |
| Resilience annotation with a `fallbackMethod` | Fallback is honest for the operation, not a fabricated result |
| `catch (Exception e)` in a service | Code hides an unknown state or maps errors too broadly |
| Raw amount or ID primitives in the domain | Repeated business rules justify a value object |
| Static calls or persistence access across feature modules | Ownership or module boundaries are bypassed |

Severity: read `references/clean-architecture-patterns.md` for the severity guide and good and bad
dependency examples. Assign severity only after proving reachable impact; the same pattern can be
accepted in one repository and critical in another.

## Report

Save to `claudedocs/<module>-arch-review-<timestamp>.md`:

```markdown
# Architecture Review - <module>
Date: <timestamp>   Mode: report-only | fix-plan
Scope: <packages, file count>   Accepted architecture sources: <ADRs, ArchUnit, AGENTS.md or "none">
Verification run: <ArchUnit/Modulith command -> result, or "none present">

## Summary
CRITICAL <n> | HIGH <n> | MEDIUM <n> | LOW <n>

## Findings
### [CRIT-001] <title>
  Invariant: <which one>
  Location: <file:line>
  Evidence: <quote, grep output, or test result>
  Impact: <reachable consequence>
  Fix: <smallest corrective action>

## Dependency graph
<actual direction found, violations marked with finding IDs>

## Recommendations
<ordered; ArchUnit rules only for accepted, recurring boundaries>
```

A clean review is valid when the evidence supports it.

**Fix-plan mode** additionally writes `claudedocs/<module>-arch-fix-plan-<timestamp>.md`: ordered
tickets, each with severity, effort, files, dependencies on other tickets, and a "done when"
check (for example "domain package has no `org.springframework` imports; ArchUnit rule passes").
To propose an executable rule, read `references/archunit-setup.md`.

## Workflow context

- Java/Spring architecture only. For breadth across quality dimensions or other stacks, use `code-audit`.
- Threat modeling goes to `security-review`; SLO-driven latency or throughput work to `performance-review`.
- Downstream: `ticket-breakdown` for remediation tickets, `tech-debt-assessment` for deferred items.

## Output contract

```yaml
produces:
  - type: "arch-review"
    format: "markdown"
    path: "claudedocs/<module>-arch-review-<timestamp>.md"
  - type: "tickets"
    format: "markdown"
    path: "claudedocs/<module>-arch-fix-plan-<timestamp>.md"  # only in fix-plan mode
  - type: "code"
    format: "java"
    paths: ["src/test/java/.../<Module>ArchTest.java"]         # suggested ArchUnit test
  handoff: "Write claudedocs/handoff-arch-review-<timestamp>.yaml - suggest: ticket-breakdown, tech-debt-assessment"
```

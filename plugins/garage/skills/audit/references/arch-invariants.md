# Java and Spring architecture review heuristics

Apply these rules after reading the repository's accepted architecture. Package names and patterns
are evidence leads, not universal findings.

## Dependency direction

A clean package-by-feature service commonly uses:

```text
api -> application -> domain
infrastructure -> application or domain ports
```

- Domain behavior should not depend on HTTP, persistence clients, messaging, provider clients, or
  framework configuration.
- Application use cases coordinate domain behavior and depend on ports for external systems.
- Infrastructure implements ports and owns provider, database, queue, and framework details.
- API code validates transport input, calls a use case, and maps the result.

Some repositories deliberately use Spring Data annotations on aggregates. Treat that as an
accepted pragmatic boundary only when the local architecture says so. Do not report it as both an
allowed exception and a critical violation.

## Transactions and external effects

- Put database transaction boundaries around application use cases, not controllers or private
  helper methods.
- Verify Spring proxy behavior: private methods and self-invocation do not create a new proxied
  transaction boundary.
- Keep remote calls outside database transactions unless the design explicitly handles the
  coupling with an outbox, saga, durable operation record, or equivalent mechanism.
- A timed-out remote mutation has an unknown result. Persist that state, retain the same
  idempotency key, and reconcile before retrying or compensating.
- Reads may use an explicitly stale cache. Mutations must not return a cached or fabricated success.

## Resilience controls

Choose controls per operation and failure mode:

- Timeouts on all remote calls.
- Bounded retries only for retryable and idempotent operations, with backoff and jitter where
  appropriate.
- Bulkheads or concurrency limits for shared-resource protection.
- Circuit breakers when repeated failures would otherwise amplify load and an open-circuit result
  has safe semantics.
- Fallbacks only when the result is honest, such as a clearly marked stale read or a fast explicit
  failure.

A circuit breaker annotation is not required on every HTTP, queue, or database call.

## API and persistence boundaries

- Do not bind request bodies directly to persistence entities or return entities from controllers.
- Keep controllers focused on transport concerns. Judge thinness by responsibilities, not a line
  limit.
- Repositories persist and retrieve data. Business decisions and cross-aggregate orchestration
  belong in use cases or domain services.
- Public identifiers must not expose internal storage keys.

## Value objects

Use value objects when a concept has validation, units, comparison rules, formatting, security, or
repeated business meaning. `Money`, `Currency`, tenant IDs, and operation references often qualify.
Do not wrap every primitive solely to satisfy a pattern.

## Events and modules

- Use domain or application events when consumers cross a real boundary, need independent
  lifecycle or delivery, or when the event itself is part of the domain audit trail.
- Prefer a direct call for simple in-process coordination with one owner.
- Apply Spring Modulith rules only when the repository uses Modulith. Then verify declared module
  dependencies, cycles, public interfaces, and `ApplicationModules.verify()` coverage.

## Greppable evidence leads

| Lead | What to verify |
|---|---|
| Spring or provider imports in `domain/` | Whether domain behavior now depends on infrastructure rather than an accepted mapping annotation. |
| Repository injected into a controller | Whether the API bypasses authorization, use-case rules, or transaction ownership. |
| Entity returned by a controller | Whether persistence fields or internal IDs leak into the public contract. |
| `@Transactional` near a private method | Whether the annotation is ineffective under the configured proxy mode. |
| `this.` call to a transactional method | Whether self-invocation bypasses the required boundary. |
| Remote client call inside a transaction | Whether lock duration and partial failure are explicitly designed. |
| `catch (Exception)` | Whether the code hides an unknown state or maps errors too broadly. |
| Raw amount or ID primitives | Whether repeated business rules justify a value object. |
| Static calls across feature modules | Whether ownership or module boundaries are bypassed. |

Assign severity only after proving the reachable impact. For accepted recurring boundaries, see
`archunit-setup.md`. For good and bad dependency examples, see
`clean-architecture-patterns.md`.

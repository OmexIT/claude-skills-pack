# Clean Architecture Patterns

Use this reference to classify architecture findings and propose fixes.

## Dependency Direction

Domain code must not depend on web, persistence, messaging, or provider clients. Outer layers depend inward.

Good:

```text
web -> application -> domain
persistence -> application ports
provider client -> application ports
```

Bad:

```text
domain -> repository
domain -> rest client
controller -> repository
```

## Transaction Boundaries

- Put transaction boundaries at application-service use cases.
- Do not start transactions in controllers.
- Keep remote calls outside database transactions unless the system explicitly uses an outbox or saga.

## DTO And Entity Boundaries

- Controllers return response DTOs, not persistence entities.
- Request DTOs are validated at the edge and mapped into commands.
- Domain objects should not carry serialization annotations required only by HTTP.

## Ports And Adapters

- Application services depend on interfaces for external systems.
- Adapters implement those interfaces and handle provider-specific details.
- Provider errors are mapped to domain errors at the adapter boundary.

## Severity Guide

- CRITICAL: dependency inversion is broken around money movement, auth, tenant isolation, or transaction boundaries.
- HIGH: outer-layer types leak into domain/application code.
- MEDIUM: conventions are inconsistent but behavior is not currently at risk.
- LOW: naming or packaging drift that does not affect maintainability materially.

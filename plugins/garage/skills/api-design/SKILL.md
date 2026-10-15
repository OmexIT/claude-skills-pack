---
name: api-design
description: "Use when the user is designing, reviewing, or changing an API contract (REST, GraphQL, or RPC): endpoint shape, naming, errors, versioning, pagination, or developer experience, before or apart from implementing it."
---

# API design

Designs a new API contract or reviews an existing one, producing a contract document, not code.
Implementing the contract in Spring Boot is `api-first`.

## Inputs (ask only if missing)
- Consumers: frontend, mobile, third party, internal service.
- Operations and workflows needed, including non-CRUD actions (approve, cancel, export).
- Existing API patterns in the codebase or OpenAPI document: naming, auth, envelope, error format,
  versioning. An established public contract wins over house defaults.
- Constraints: backward compatibility, rate limits, payload size, latency.

## Decision rules
1. **Shape for the consumer, not the tables.** No storage details in the surface.
2. **Resources are plural nouns.** Actions that do not fit CRUD become a sub-resource or a command
   endpoint (`POST /payment-links/{id}/cancel`) with documented idempotency.
3. **Errors are a contract.** House default is RFC 9457 Problem Details with a stable `type`, field
   level `errors[]` with machine-readable codes, and `traceId`. Never `200 OK` with an error body.
4. **Pagination on every list** that can grow: opaque cursor, `pageSize` cap, stable ordering, and
   filters and tenant scope reapplied on every page.
5. **Versioning**: follow the service's existing strategy; otherwise prefer additive change and
   define what counts as breaking before the first release.
6. **Retry safety**: GET, PUT, and DELETE are idempotent by definition. POST commands that create
   state or move money take a required `Idempotency-Key`; same key and payload replays the original
   response, same key with a different payload is rejected. Concurrent PATCH uses `ETag` and
   `If-Match` when lost updates matter.
7. **House data rules**: public IDs are UUIDv7 strings and internal TSIDs never appear; money is a
   decimal string plus currency or asset code with scale from that currency; timestamps are ISO 8601
   UTC.
8. **Least surprise**: a consumer who guesses from the other endpoints should guess right.

For a review, cite the endpoint, the rule it breaks, consumer impact, and the fix. Impact decides
severity, not the count of findings.

## Anti-patterns to flag
- Mixed casing or pluralization; verbs in resource paths.
- Internal or sequential IDs, or storage-generated keys, in paths, bodies, or cursors.
- Floating-point money or timestamps without zone.
- Breaking changes without a versioning or deprecation path.
- Chatty flows needing several round trips for one common task.
- Public endpoints without documented auth and rate limits.

## Quality bar
- Every endpoint has method, path, auth, request, response, and error cases, with one complete
  example each.
- Error format, pagination, and naming conventions are written down once and followed everywhere.
- Breaking-change policy is defined.

## Workflow context
- Follows `design-doc`; feeds `ticket-breakdown`, `test-plan`, `security-review`.
- `api-first` implements this contract in Spring Boot; this skill writes no code.

## Output
Fill `assets/api-design.md`.

## Output contract
```yaml
produces:
  - type: "api-design"
    format: "markdown"
    path: "claudedocs/<feature>-api-design.md"
    sections: [endpoints, contracts, error_handling, pagination, versioning]
    handoff: "Write claudedocs/handoff-api-design-<timestamp>.yaml - suggest: spec-to-impl, test-plan, spec-panel"
```

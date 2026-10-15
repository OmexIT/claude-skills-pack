# Spring API conventions

Use the repository's OpenAPI document and established public contract first. These defaults apply
to new surfaces or deliberate migrations; do not break an existing API to match house style.

## Paths and methods

- Plural resource nouns in kebab case: `/api/v1/payment-links`.
- Use the repository's existing versioning strategy. Do not introduce path versioning into one
  endpoint when the service versions by media type, header, or gateway.
- GET reads, POST creates or invokes a non-idempotent command, PUT replaces, PATCH partially
  updates, DELETE removes. Document idempotency semantics for commands.

## Success envelope

House default:

```json
{
  "data": { "id": "0190f6b2-7c1e-7a3b-9c4d-2e5f6a7b8c9d" },
  "meta": { "requestId": "req_01HXXX", "timestamp": "2026-07-13T10:00:00Z", "traceId": "a1b2c3d4" }
}
```

List pagination lives in `meta.pagination` with only the fields the client needs:

```json
{ "nextCursor": "eyJ2IjoxLCJrIjoiLi4uIn0", "hasMore": true, "pageSize": 20 }
```

Do not wrap responses when the current public contract, a generated client, or a streaming format
requires another shape. Name the envelope type so it cannot clash with springdoc's `@ApiResponse`
annotation (for example `ApiEnvelope<T>`).

## Errors

RFC 9457 Problem Details when the service supports it:

```json
{
  "type": "https://errors.example.com/validation-failed",
  "title": "Validation failed",
  "status": 400,
  "detail": "One or more fields failed validation",
  "instance": "/api/v1/payment-links",
  "errors": [ { "field": "amount", "code": "NEGATIVE", "message": "amount must be positive" } ],
  "traceId": "a1b2c3d4"
}
```

- Spring's default `ProblemDetail` has no `errors[]`; the service's advice must map
  `MethodArgumentNotValidException` (and `HandlerMethodValidationException` on Spring 6.1+) into it.
- Keep `type`, status mapping, field codes, and extensions stable.
- Never expose stack traces, SQL, provider payloads, internal class names, or secrets.
- Map provider and persistence failures at their adapter boundary. Preserve unknown financial
  outcomes as an explicit state rather than a generic 500 followed by an unsafe retry.

## Money, identifiers, and time

- Money amounts are decimal strings with a currency or asset code. Validate scale from the
  authoritative ISO 4217 or asset configuration; fiat and crypto assets differ.
- Parse with `BigDecimal` and an explicit rounding policy where rounding is allowed. Never accept or
  emit binary floating-point money.
- Public resource IDs are UUIDv7. TSID or other database keys stay internal and are never returned,
  not even as a string.
- Timestamps are ISO 8601 UTC from `Instant`, or an explicit offset when the offset carries meaning.

## Idempotency

- Store key, a hash of the canonical request, status (in progress, completed), and the original
  response, scoped by tenant or caller.
- Same key and same payload: return the stored response with its original status code.
- Same key, different payload: reject (`422` or `409`, matching the service's convention).
- Same key while the first request is still running: `409`, and the client retries later.
- Required, not optional, on POSTs that create money-moving or externally visible state.

## Package-by-feature layout

```text
paymentlink/
  api/               controller, request and response records
  application/       use cases, commands, queries, ports
  domain/            domain behavior and value objects
  infrastructure/    Spring Data adapters and provider clients
```

- Controllers depend on application use cases, not Spring Data repositories.
- An application port expresses the persistence need; a Spring Data repository may stay an
  infrastructure detail behind an adapter.
- Manual mapping is fine. Add MapStruct only when mapping volume justifies the dependency.
- Match a simpler established layout instead of creating empty layers.

## Cursor pagination

- Use a stable, unique ordering tuple and fetch `pageSize + 1` to determine `hasMore`.
- The cursor is opaque and versioned. Sign or authenticate it when clients could alter it to bypass
  filters or tenant boundaries.
- Encode the internal ordering tuple without exposing it as a public identifier.
- Reapply authorization, tenant, and filter predicates on every page.
- Define behavior for deleted rows and equal sort values.

## HTTP clients and language features

- Detect Spring and Java versions from the build before choosing APIs.
- Prefer `RestClient` for new synchronous code on Spring Framework 6.1+ when the repo has no
  established client. Reuse `WebClient` in a reactive stack. Keep `RestTemplate` when maintaining an
  older service unless the requested scope includes migration.
- Configure timeouts, authentication, observability, and error mapping centrally.
- Use text blocks, records, sealed types, and `String.formatted` only when the configured source
  level supports them and they match the module.

## Verification

- Controller contract tests for changed status codes, validation, envelope, and Problem Details.
- Application tests for changed business behavior.
- Persistence integration tests against the real database when query or mapping behavior changed.
- OpenAPI compatibility checks when a public contract changed.

Do not require every layer for every endpoint. Each test covers a real changed risk.

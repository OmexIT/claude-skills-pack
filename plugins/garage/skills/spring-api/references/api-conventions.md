# Java Spring API conventions

Use the repository's OpenAPI document and established public contract first. These defaults apply
to new surfaces or deliberate migrations; do not break an existing API merely to match house style.

## Paths and methods

- Plural resource nouns and kebab case: `/api/v1/payment-links`.
- Use the repository's existing versioning strategy. Do not introduce path versioning into one
  endpoint when the service versions by media type, header, or gateway.
- GET reads, POST creates or invokes a non-idempotent command, PUT replaces, PATCH partially
  updates, and DELETE removes. Document idempotency semantics for commands.

## Success envelope

House default:

```json
{
  "data": { "id": "019..." },
  "meta": {
    "requestId": "req_01HXXX",
    "timestamp": "2026-07-13T10:00:00Z",
    "traceId": "a1b2c3d4"
  }
}
```

List pagination belongs in `meta.pagination` and includes only the fields the client needs:

```json
{
  "nextCursor": "eyJ2IjoxLCJrIjoiLi4uIn0",
  "hasMore": true,
  "pageSize": 20
}
```

Do not wrap responses when the current public contract, generated client, or streaming format
requires another shape.

## Errors

Use RFC 9457 Problem Details when the service supports it:

```json
{
  "type": "https://errors.example.com/validation-failed",
  "title": "Validation failed",
  "status": 400,
  "detail": "One or more fields failed validation",
  "instance": "/api/v1/payment-links",
  "errors": [
    { "field": "amount", "code": "NEGATIVE", "message": "amount must be positive" }
  ],
  "traceId": "a1b2c3d4"
}
```

- Keep `type`, status mapping, field codes, and optional extensions stable.
- Do not expose stack traces, SQL, provider payloads, internal class names, or secrets.
- Map provider and persistence failures at their adapter boundary. Preserve unknown financial
  outcomes as an explicit state rather than a generic 500 followed by an unsafe retry.

## Money, identifiers, and time

- Serialize money amounts as decimal strings with a currency or asset code. Validate scale from
  the authoritative ISO 4217 or asset configuration; do not assume every fiat or crypto asset has
  the same decimals.
- Parse with `BigDecimal` and an explicit rounding policy when rounding is allowed. Never accept or
  emit binary floating-point money.
- Public resource IDs use UUIDv7 where the house contract applies. TSID or other database keys stay
  internal and are never returned as an alternate public ID.
- Serialize timestamps as ISO 8601 UTC from `Instant` or an explicitly offset value. Do not lose
  the source offset when it carries business meaning.

## Package-by-feature layout

```text
paymentlink/
  api/               controller, request and response records
  application/       use cases, commands, queries, ports
  domain/            domain behavior and value objects
  infrastructure/    Spring Data adapters and provider clients
```

- Controllers depend on application use cases, not Spring Data repositories.
- An application port expresses the persistence need. A Spring Data repository may remain an
  infrastructure detail behind an adapter.
- Manual mapping is fine. Add MapStruct only when mapping volume justifies another dependency.
- Match a simpler established repository layout instead of creating empty layers.

## Cursor pagination

- Use a stable, unique ordering tuple and fetch `pageSize + 1` to determine `hasMore`.
- Treat the cursor as opaque and version it. Sign or authenticate it when clients could alter its
  content to bypass filters or tenant boundaries.
- Encode the internal ordering tuple without exposing it as a public resource identifier.
- Reapply authorization, tenant, and filter predicates on every page.
- Define behavior for deleted rows and equal sort values.

Example application port:

```java
interface PaymentLinkReader {
    CursorSlice<PaymentLinkSummary> findAfter(PageCursor cursor, int pageSize);
}
```

The infrastructure adapter can use Spring Data, JDBC, or jOOQ according to the existing stack.

## HTTP clients and language features

- Detect Spring and Java versions from the build before choosing APIs.
- Prefer `RestClient` for new synchronous code on Spring Framework 6.1 or newer.
- Reuse `WebClient` in a reactive stack. Keep `RestTemplate` when maintaining an older supported
  service unless the requested scope includes migration.
- Configure timeouts, authentication, observability, and error mapping centrally.
- Use language features such as text blocks, records, sealed types, and `String.formatted` only
  when supported by the configured source level and consistent with the module.

## Verification

- Controller contract tests for changed status codes, validation, envelope, and Problem Details.
- Application tests for changed business behavior.
- Persistence integration tests, preferably against the real database, when query or mapping
  behavior changed.
- OpenAPI compatibility checks when a public contract changed.

Do not require every layer for every endpoint. Each test must cover a real changed risk.

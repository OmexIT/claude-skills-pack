# House API style guide (Java Spring services)

## Paths & verbs
- Plural resource nouns, kebab-case: `/api/v1/payment-links`
- Versioned via path prefix (`/api/v1/...`)
- GET reads · POST creates · PATCH partial updates · PUT full replacement (rare) · DELETE removal

## Response envelope
```json
{
  "data": { "...": "resource" },
  "meta": {
    "requestId": "req_01HXXX",
    "timestamp": "2026-04-15T10:00:00Z",
    "traceId": "a1b2c3d4..."
  }
}
```

List responses add pagination inside `meta`:
```json
"pagination": {
  "cursor": "eyJpZCI6IjAxSFhYWCJ9",
  "nextCursor": "eyJpZCI6IjAxSFlZWSJ9",
  "hasMore": true,
  "pageSize": 20
}
```

## Errors - RFC 9457 Problem Details
```json
{
  "type": "https://errors.<org>.com/validation-failed",
  "title": "Validation failed",
  "status": 400,
  "detail": "One or more fields failed validation",
  "instance": "/api/v1/payment-links",
  "errors": [
    { "field": "amount", "code": "NEGATIVE", "message": "amount must be positive" }
  ],
  "traceId": "a1b2c3d4..."
}
```
Field-level `errors[]` array and `traceId` are mandatory on validation failures.

## Money
`{ "amount": "150.00", "currency": "USD" }` - never a float. Decimal string scaled to the
currency's ISO 4217 minor units (2 for most fiat, 0 for JPY, 3 for KWD); 8-decimal string
(crypto). Parsed into `BigDecimal` server-side.

## IDs & timestamps
- External: UUID v7 (time-sortable), exposed as string. Internal: TSID (64-bit) - still exposed as string. Never expose auto-increment IDs.
- Timestamps: `Instant`/`OffsetDateTime`, serialized ISO 8601 UTC (`2026-04-15T10:00:00Z`).

## Code layout - package-by-feature
```
src/main/java/.../paymentlink/
├── api/            controller + request/response records
├── application/    @Service + MapStruct mapper + sealed exceptions
├── domain/         aggregate root (record for Spring Data JDBC)
└── infrastructure/ repository interface
```
Tests: `@WebMvcTest` slice (contract shape) + Mockito unit + `@SpringBootTest` + Testcontainers
integration. New/changed endpoints update the OpenAPI fragment in the same PR.

## Cursor pagination repository (fetch pageSize+1)
```java
interface PaymentLinkRepository extends ListCrudRepository<PaymentLink, Long> {

    @Query("""
        SELECT * FROM payment_links
        WHERE (:cursor IS NULL OR id < :cursor)
        ORDER BY id DESC
        LIMIT :pageSize
    """)
    List<PaymentLink> findSlice(@Param("cursor") Long cursor, @Param("pageSize") int pageSize);

    default CursorPage<PaymentLink> findPage(Long cursor, int pageSize) {
        var items = findSlice(cursor, pageSize + 1);
        var hasMore = items.size() > pageSize;
        var trimmed = hasMore ? items.subList(0, pageSize) : items;
        var nextCursor = hasMore ? String.valueOf(trimmed.get(trimmed.size() - 1).id()) : null;
        return new CursorPage<>(trimmed, cursor, nextCursor, hasMore);
    }
}
```
The API layer base64-encodes/decodes the opaque `{"id": ...}` cursor; the repository sees only the raw last-seen id.

## House anti-patterns
- `RestTemplate` - use `RestClient`.
- String concatenation for messages - use `.formatted()`.
- Exposing auto-increment IDs externally - UUIDv7/TSID strings only.

# API Design: <service / feature>

## Overview
- **Consumers**: who calls this API
- **Protocol**: REST / GraphQL / gRPC
- **Base path**: `/api/v1` (or the service's versioning strategy)
- **Auth**: how consumers authenticate

## Conventions
- **Naming**: camelCase fields, kebab-case plural paths (or the established convention)
- **IDs**: UUIDv7 strings; internal keys never exposed
- **Money**: decimal string plus currency or asset code, e.g. `{ "amount": "150.00", "currency": "USD" }`
- **Timestamps**: ISO 8601 UTC
- **Envelope**: `{ data, meta { requestId, timestamp, traceId } }` (or the established shape)
- **Pagination**: opaque cursor in `meta.pagination { nextCursor, hasMore, pageSize }`

## Error format (RFC 9457 Problem Details)
```json
{
  "type": "https://errors.example.com/validation-failed",
  "title": "Validation failed",
  "status": 400,
  "detail": "One or more fields failed validation",
  "instance": "/api/v1/resources",
  "errors": [ { "field": "email", "code": "INVALID_FORMAT", "message": "Must be a valid email address" } ],
  "traceId": "a1b2c3d4"
}
```

| Status | `type` suffix | When |
| --- | --- | --- |
| 400 | validation-failed | Invalid input |
| 401 | unauthenticated | Missing or invalid auth |
| 403 | forbidden | Authenticated, not permitted |
| 404 | not-found | Resource does not exist or is not visible to the caller |
| 409 | conflict | State conflict, version mismatch, idempotent request still in progress |
| 422 | idempotency-key-reused | Same key, different payload (or 409, per service convention) |
| 429 | rate-limited | Too many requests |

## Endpoints

### `POST /resources`
- Auth: required (scope `resources:write`)
- Idempotency: `Idempotency-Key` header, required when it creates money-moving or external state
- Request:
```json
{ "name": "Example", "type": "standard" }
```
- Success (201, `Location` header):
```json
{ "data": { "id": "0190f6b2-7c1e-7a3b-9c4d-2e5f6a7b8c9d", "name": "Example", "type": "standard", "createdAt": "2026-01-15T10:30:00Z" },
  "meta": { "requestId": "req_01HXXX", "timestamp": "2026-01-15T10:30:00Z", "traceId": "a1b2c3d4" } }
```
- Errors: 400, 401, 403, 409, 422

### `GET /resources`
- Auth: required (scope `resources:read`)
- Query: `pageSize` (default 20, max 100), `cursor` (opaque), filters
- Success (200): `data` array, `meta.pagination`

### `GET /resources/{id}`
- Errors: 401, 403, 404

### `PATCH /resources/{id}`
- Partial update; omitted fields unchanged
- Concurrency: `If-Match` with `ETag` when lost updates matter
- Errors: 400, 401, 403, 404, 409, 412

### `DELETE /resources/{id}`
- Behavior: soft delete (state change) or hard delete, and why
- Success: 204
- Errors: 401, 403, 404

## Rate limiting
- Limit and window per consumer type, and the response headers used

## Versioning and deprecation
- Strategy, what counts as breaking, deprecation notice period

## Open questions
- ...

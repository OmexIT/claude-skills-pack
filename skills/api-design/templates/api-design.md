# API Design: <service / feature>

## Overview
- **Consumers**: Who calls this API
- **Protocol**: REST / GraphQL / gRPC
- **Base URL**: `https://api.example.com/v1`
- **Auth**: How consumers authenticate

## Conventions
- **Naming**: snake_case / camelCase
- **Dates**: ISO 8601 (UTC)
- **IDs**: Format and generation strategy
- **Pagination**: Cursor-based / offset-based

## Error format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description",
    "details": [
      { "field": "email", "message": "Must be a valid email address" }
    ],
    "request_id": "req_abc123"
  }
}
```

### Standard error codes
| HTTP Status | Code | When |
| --- | --- | --- |
| 400 | VALIDATION_ERROR | Invalid input |
| 401 | UNAUTHORIZED | Missing or invalid auth |
| 403 | FORBIDDEN | Valid auth, insufficient permissions |
| 404 | NOT_FOUND | Resource doesn't exist |
| 409 | CONFLICT | State conflict (duplicate, version mismatch) |
| 429 | RATE_LIMITED | Too many requests |
| 500 | INTERNAL_ERROR | Unexpected server error |

## Endpoints

### `POST /resources`
**Create a resource**
- Auth: Required (scope: `resources:write`)
- Idempotency: Idempotency-Key header supported
- Request:
```json
{
  "name": "Example",
  "type": "standard"
}
```
- Success (201):
```json
{
  "id": "res_abc123",
  "name": "Example",
  "type": "standard",
  "created_at": "2025-01-15T10:30:00Z"
}
```
- Errors: 400 (validation), 401, 403, 409 (duplicate)

### `GET /resources`
**List resources**
- Auth: Required (scope: `resources:read`)
- Pagination: cursor-based
- Query params:
  - `limit` (int, default 20, max 100)
  - `cursor` (string, opaque)
  - `status` (filter: active | archived)
- Success (200):
```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "cur_xyz",
    "has_more": true
  }
}
```

### `GET /resources/:id`
**Get a resource**
- Auth: Required (scope: `resources:read`)
- Errors: 401, 403, 404

### `PATCH /resources/:id`
**Update a resource**
- Auth: Required (scope: `resources:write`)
- Partial update (only send changed fields)
- Errors: 400, 401, 403, 404, 409 (version conflict)

### `DELETE /resources/:id`
**Delete a resource**
- Auth: Required (scope: `resources:write`)
- Behavior: Soft delete (sets status to archived) / Hard delete
- Success: 204 No Content
- Errors: 401, 403, 404

## Rate limiting
- Default: X requests/minute per API key
- Headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

## Versioning strategy
- Current version: v1
- Breaking change policy:
- Deprecation timeline:

## Migration notes (if applicable)
- Changes from previous version:
- Migration guide:

## Open questions
- ...

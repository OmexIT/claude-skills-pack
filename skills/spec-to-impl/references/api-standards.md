# API Standards Reference

This document defines the API design standards that ARCH produces in Wave 1 and every BE/FE agent must conform to. ARCH selects the API style (REST, GraphQL, gRPC, async) based on the spec, then the full contract below applies.

---

## 1. API Style Detection & Selection

ARCH selects the API style in Phase 1 based on these signals:

| Signal | Style | Rationale |
|---|---|---|
| CRUD operations, resource-oriented | REST | Standard for resource lifecycle management |
| Complex queries, nested relations, mobile clients | GraphQL | Reduces over-fetching, single endpoint |
| Low-latency inter-service, binary payloads | gRPC | Binary protocol, code generation, streaming |
| Fire-and-forget, event-driven | Async (Kafka/AMQP) | Decoupled, reliable delivery |
| Existing codebase pattern | Match existing | Consistency beats theoretical superiority |

**Document the decision:**
```
API STYLE DECISION
==================
Selected:    REST (OpenAPI 3.1)
Rationale:   Resource-oriented CRUD, public-facing API, browser consumers
Rejected:    GraphQL (no complex nested queries needed), gRPC (browser clients can't use directly)
Versioning:  URL path (/api/v1/...) — explicit, cacheable, tooling-friendly
```

---

## 2. REST API Standards (when REST is selected)

### 2.1 URL Design

```
Pattern:  /api/v{version}/{resource-plural}[/{id}][/{sub-resource-plural}]

Examples:
  GET    /api/v1/payments                    # list
  POST   /api/v1/payments                    # create
  GET    /api/v1/payments/{id}               # read
  PUT    /api/v1/payments/{id}               # full replace
  PATCH  /api/v1/payments/{id}               # partial update
  DELETE /api/v1/payments/{id}               # delete
  GET    /api/v1/payments/{id}/refunds       # sub-resource list
  POST   /api/v1/payments/{id}/refunds       # sub-resource create

Non-CRUD actions (use POST with verb):
  POST   /api/v1/payments/{id}/capture       # action on resource
  POST   /api/v1/payments/{id}/cancel        # action on resource
  POST   /api/v1/reports/generate            # trigger operation
```

**Rules:**
- Resources are **nouns, plural, lowercase, kebab-case**: `/payment-methods`, not `/PaymentMethod` or `/getPayments`
- Maximum 2 levels of nesting: `/payments/{id}/refunds` — deeper nesting signals a design issue
- No verbs in paths for CRUD (the HTTP method IS the verb)
- Non-CRUD actions use POST with a verb path segment
- IDs are always path parameters, filters are always query parameters
- Consistent trailing slash policy (no trailing slash)

### 2.2 HTTP Methods & Status Codes

| Method | Semantics | Request Body | Idempotent | Safe |
|---|---|---|---|---|
| GET | Read resource(s) | No | Yes | Yes |
| POST | Create resource / trigger action | Yes | No (use idempotency key) | No |
| PUT | Full replace | Yes | Yes | No |
| PATCH | Partial update | Yes | No | No |
| DELETE | Remove resource | No | Yes | No |

**Status codes — use precisely:**

| Code | When |
|---|---|
| `200 OK` | Successful GET, PUT, PATCH, DELETE |
| `201 Created` | Successful POST that creates a resource (include `Location` header) |
| `202 Accepted` | Async operation accepted, not yet completed |
| `204 No Content` | Successful DELETE with no response body |
| `400 Bad Request` | Validation failure, malformed request |
| `401 Unauthorized` | Missing or invalid authentication |
| `403 Forbidden` | Authenticated but not authorized |
| `404 Not Found` | Resource does not exist |
| `409 Conflict` | State conflict (duplicate, concurrent modification) |
| `422 Unprocessable Entity` | Semantically invalid (valid JSON, invalid business logic) |
| `429 Too Many Requests` | Rate limit exceeded (include `Retry-After` header) |
| `500 Internal Server Error` | Unhandled server error |
| `502 Bad Gateway` | Upstream service failure |
| `503 Service Unavailable` | Service overloaded or in maintenance |

**Anti-patterns:**
- `200 OK` with error in response body — use proper HTTP status codes
- `500` for validation errors — use `400`/`422`
- `404` for authorization failures — use `403`
- Custom status codes outside HTTP spec
- Missing `Location` header on `201 Created`

### 2.3 Response Envelope

All responses use a consistent envelope:

```json
{
  "data": { ... },
  "meta": {
    "requestId": "req-abc-123",
    "timestamp": "2026-03-20T14:30:00.123Z",
    "traceId": "abc123def456"
  }
}
```

**Error responses (RFC 9457 Problem Details):**

```json
{
  "type": "https://api.example.com/problems/validation-error",
  "title": "Validation Error",
  "status": 422,
  "detail": "The payment amount must be greater than zero",
  "instance": "/api/v1/payments",
  "traceId": "abc123def456",
  "errors": [
    {
      "field": "amount",
      "code": "POSITIVE_REQUIRED",
      "message": "Must be greater than 0",
      "rejectedValue": -5.00
    }
  ]
}
```

**Rules:**
- Error `type` is a URI that resolves to documentation about the error
- `traceId` in every error response — enables correlation with logs and traces
- Field-level `errors` array for validation failures
- Machine-readable `code` per field error (consumers write code against these)
- Human-readable `message` per field error (display to users)
- Never leak stack traces, SQL, or internal paths in error responses

### 2.4 Pagination

All list endpoints must support pagination from day one. Retrofitting pagination is a breaking change.

**Cursor-based pagination (preferred for real-time data):**
```
GET /api/v1/payments?limit=20&after=cursor_abc123

Response:
{
  "data": [ ... ],
  "meta": {
    "pagination": {
      "limit": 20,
      "hasMore": true,
      "nextCursor": "cursor_def456",
      "prevCursor": "cursor_abc123"
    }
  }
}
```

**Offset-based pagination (simpler, for admin/reporting):**
```
GET /api/v1/payments?page=2&size=20&sort=createdAt,desc

Response:
{
  "data": [ ... ],
  "meta": {
    "pagination": {
      "page": 2,
      "size": 20,
      "totalElements": 156,
      "totalPages": 8
    }
  }
}
```

**Rules:**
- Default page size: 20, max page size: 100 (configurable per endpoint)
- Always include pagination metadata in response
- Sort parameter format: `field,direction` (e.g., `sort=createdAt,desc`)
- Cursor pagination for high-volume, real-time data (avoids offset performance issues)
- Offset pagination acceptable for admin/internal APIs with bounded data

### 2.5 Filtering & Search

```
GET /api/v1/payments?status=completed&currency=USD&amount_gte=100&created_after=2026-01-01

Conventions:
  Exact match:    ?status=completed
  Range:          ?amount_gte=100&amount_lte=500  (gte/lte/gt/lt suffixes)
  Date range:     ?created_after=2026-01-01&created_before=2026-03-20
  Multiple values: ?status=completed,refunded  (comma-separated)
  Search:         ?q=search+term  (full-text search, if applicable)
```

### 2.6 Versioning

```
Strategy: URL path versioning (default)
  /api/v1/payments  ->  /api/v2/payments

Rules:
  - Major version in URL path: /api/v1/, /api/v2/
  - New version only for breaking changes
  - Additive changes (new fields, new endpoints) do NOT require version bump
  - Support N-1 version minimum (deprecate, don't remove immediately)
  - Version sunset policy: minimum 6 months notice
  - Document breaking changes in changelog
```

### 2.7 Idempotency

```
All state-changing operations (POST, PATCH) must be safe to retry.

POST requests:
  Header: Idempotency-Key: <client-generated UUID>
  Server: store result keyed by Idempotency-Key, return cached result on duplicate
  TTL: 24 hours minimum

PUT/DELETE:
  Naturally idempotent — same request produces same result

Implementation:
  1. Client sends Idempotency-Key header
  2. Server checks if key exists in cache/DB
  3. If exists: return cached response (same status code, same body)
  4. If not: process request, store response, return result
```

### 2.8 Rate Limiting

```
Headers in every response:
  X-RateLimit-Limit: 1000          # requests per window
  X-RateLimit-Remaining: 950       # remaining in current window
  X-RateLimit-Reset: 1679529600    # window reset timestamp (Unix epoch)

When exceeded (429 Too Many Requests):
  Retry-After: 30                  # seconds until client should retry

Tiers:
  - Public API: 100 req/min per API key
  - Authenticated: 1000 req/min per user
  - Internal service: 10000 req/min (circuit breaker instead of hard limit)
```

### 2.9 Security Headers & CORS

```
Required headers on every response:
  Content-Type: application/json
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Strict-Transport-Security: max-age=31536000; includeSubDomains
  Cache-Control: no-store (for authenticated endpoints)

CORS:
  Access-Control-Allow-Origin: <specific origin, not *>
  Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
  Access-Control-Allow-Headers: Authorization, Content-Type, Idempotency-Key, X-Request-ID
  Access-Control-Max-Age: 86400
```

### 2.10 Request/Response Standards

```
Content-Type: application/json (always)
Date format: ISO 8601 (2026-03-20T14:30:00.123Z) — always UTC
Money: { "amount": "150.00", "currency": "USD" } — string for amount, never float
IDs: UUID v7 (time-sortable) or string — never expose auto-increment integers
Nulls: omit null fields from response (reduces payload, clearer contract)
Booleans: never use 0/1 or "true"/"false" strings — use native JSON boolean
Enums: UPPER_SNAKE_CASE strings — never numeric codes
Arrays: always return array (empty []), never null for list fields
Timestamps: always include timezone (UTC), always ISO 8601
```

---

## 3. GraphQL Standards (when GraphQL is selected)

### 3.1 Schema Design
```graphql
# Type naming: PascalCase
type Payment {
  id: ID!
  amount: Money!
  status: PaymentStatus!
  createdAt: DateTime!
}

# Input types: suffixed with "Input"
input CreatePaymentInput {
  amount: MoneyInput!
  currency: CurrencyCode!
}

# Enums: UPPER_SNAKE_CASE values
enum PaymentStatus {
  PENDING
  COMPLETED
  FAILED
  REFUNDED
}

# Mutations return the affected object
type Mutation {
  createPayment(input: CreatePaymentInput!): CreatePaymentPayload!
}

# Payload type wraps result + errors
type CreatePaymentPayload {
  payment: Payment
  errors: [UserError!]!
}

type UserError {
  field: [String!]
  code: String!
  message: String!
}
```

### 3.2 Query Standards
- Connections pattern for pagination (Relay-style: `edges`, `nodes`, `pageInfo`)
- `first`/`after` for forward pagination, `last`/`before` for backward
- Always limit query depth (max 5 levels) and complexity (max 1000 cost)
- N+1 prevention via DataLoader pattern (mandatory for all resolvers with nested relations)

### 3.3 Error Handling
- Business errors in `errors` field of payload (not GraphQL errors)
- GraphQL errors reserved for infrastructure/auth failures
- Structured error codes (machine-readable) + messages (human-readable)

---

## 4. gRPC Standards (when gRPC is selected)

### 4.1 Proto Design
```protobuf
syntax = "proto3";
package example.payment.v1;

// Service naming: PascalCase + "Service"
service PaymentService {
  rpc CreatePayment(CreatePaymentRequest) returns (CreatePaymentResponse);
  rpc GetPayment(GetPaymentRequest) returns (Payment);
  rpc ListPayments(ListPaymentsRequest) returns (ListPaymentsResponse);
}

// Request/Response: verb + resource + Request/Response
message CreatePaymentRequest {
  Money amount = 1;
  string currency = 2;
  string idempotency_key = 3;
}

// Pagination via page_token pattern
message ListPaymentsRequest {
  int32 page_size = 1;
  string page_token = 2;
}

message ListPaymentsResponse {
  repeated Payment payments = 1;
  string next_page_token = 2;
  int32 total_size = 3;
}
```

### 4.2 Error Handling
- Use standard gRPC status codes (NOT_FOUND, INVALID_ARGUMENT, PERMISSION_DENIED, etc.)
- Rich error details via `google.rpc.Status` with `google.rpc.BadRequest` for field validation
- Never use UNKNOWN or INTERNAL for expected business errors

### 4.3 Patterns
- Unary RPCs for simple request-response
- Server streaming for large result sets or real-time feeds
- Deadline propagation on every call
- Retry with exponential backoff + jitter
- Health checking via `grpc.health.v1.Health` service

---

## 5. Async API Standards (when event-driven / messaging)

### 5.1 Event Design
```json
{
  "eventId": "evt-abc-123",
  "eventType": "payment.completed",
  "eventVersion": "1.0",
  "source": "payment-service",
  "timestamp": "2026-03-20T14:30:00.123Z",
  "traceId": "abc123def456",
  "data": {
    "paymentId": "pay-xyz-789",
    "amount": "150.00",
    "currency": "USD"
  },
  "metadata": {
    "tenantId": "tenant-123",
    "userId": "user-456",
    "correlationId": "corr-789"
  }
}
```

### 5.2 Naming
- Topic: `<domain>.<entity>.<event>` (e.g., `payments.payment.completed`)
- Event type: `<entity>.<past-tense-verb>` (e.g., `payment.completed`, `user.created`)
- Schema registry for event schema evolution (Avro or JSON Schema)

### 5.3 Guarantees
- At-least-once delivery (consumers must be idempotent)
- Ordering within partition key (use entity ID as partition key)
- Dead letter queue for poison messages (max 3 retries then DLQ)
- Schema evolution: backward-compatible changes only (add fields, don't remove)

---

## 6. Cross-Cutting API Standards (all styles)

### 6.1 Authentication & Authorization
```
Pattern: Bearer token (JWT) in Authorization header
  Authorization: Bearer <jwt-token>

Per-endpoint authorization:
  - Document required roles/scopes per operation
  - Enforce at controller/resolver level (@PreAuthorize, @Secured)
  - Return 401 for missing/invalid token, 403 for insufficient permissions
```

### 6.2 Request Tracing
```
Required headers:
  X-Request-ID: <client-generated or server-generated UUID>
  traceparent: <W3C Trace Context> (auto-propagated by OpenTelemetry)

Response includes:
  X-Request-ID: <same as request>
  traceId in error responses
```

### 6.3 Content Negotiation
```
Accept: application/json (default)
Content-Type: application/json (request bodies)

Reject unsupported content types with 415 Unsupported Media Type
Return 406 Not Acceptable for unsupported Accept headers
```

### 6.4 OpenAPI / Schema Documentation
```
Every API must have machine-readable documentation:
  REST:    OpenAPI 3.1 spec (YAML) with examples per endpoint
  GraphQL: Introspection schema + SDL export
  gRPC:    Proto files + buf lint compliance
  Async:   AsyncAPI 3.0 spec or JSON Schema for events

Documentation includes:
  - Every endpoint/operation with description
  - Request/response schemas with examples
  - Error responses with codes and meanings
  - Authentication requirements
  - Rate limiting details
  - Deprecation notices
```

### 6.5 API Compliance Checklist

```
API COMPLIANCE CHECKLIST
========================
[ ] URL/naming convention consistent across all endpoints
[ ] Correct HTTP methods and status codes (no 200-with-error-body)
[ ] Response envelope standardized (data + meta + errors)
[ ] Error format: RFC 9457 Problem Details (REST) or equivalent
[ ] Pagination on all list endpoints (cursor or offset)
[ ] Filtering/sorting documented and consistent
[ ] Versioning strategy documented and applied
[ ] Idempotency keys on POST/state-changing operations
[ ] Rate limiting with headers (Limit, Remaining, Reset)
[ ] Authentication documented per endpoint
[ ] Authorization documented per endpoint (roles/scopes)
[ ] Request tracing (X-Request-ID, traceId in errors)
[ ] Content-Type enforcement
[ ] Security headers (HSTS, nosniff, X-Frame-Options)
[ ] CORS configured for specific origins
[ ] OpenAPI/AsyncAPI spec generated and accurate
[ ] No internal IDs or implementation details leaked
[ ] Date/time always ISO 8601 UTC
[ ] Money as string/decimal, never float
[ ] Null handling policy documented
```

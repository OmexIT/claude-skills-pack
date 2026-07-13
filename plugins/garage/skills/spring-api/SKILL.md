---
name: spring-api
description: >
  Use when creating or modifying REST endpoints, controllers, DTOs, or error handling in Java
  Spring services - response envelopes, pagination, Problem Details, package layout.
---

# Spring API conventions

- **Envelope**: `{data, meta{requestId, timestamp, traceId}}`; cursor pagination fields live in `meta`.
- **Errors**: RFC 9457 Problem Details with a field-level `errors[]` array and `traceId`.
- **IDs**: UUIDv7 external, TSID internal - never expose auto-increment IDs.
- **Money on the wire**: string with ISO 4217 minor-unit decimals for fiat (most 2, JPY 0), 8 decimals crypto.
- **Paths**: kebab-case, plural, versioned (`/api/v1/payment-links`).
- **Layout**: package-by-feature - `api/`, `application/`, `domain/`, `infrastructure/` per feature. Thin controllers; domain logic in the domain layer; repositories persist only.
- **HTTP client**: `RestClient` (never `RestTemplate`). Strings: `.formatted()` (never concatenation).
- **Pagination**: fetch `pageSize + 1` to compute `hasMore`.
- **Contract-first**: when an OpenAPI spec exists, work from it; new/changed endpoints update the spec in the same PR.

Full style guide with snippets: `references/api-conventions.md` (read before scaffolding a new endpoint; reuse existing request/response models before defining new ones).

## Tests
`@WebMvcTest` slice for contract shape (status codes, envelope, Problem Details); Testcontainers for repository integration.

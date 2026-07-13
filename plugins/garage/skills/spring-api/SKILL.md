---
name: spring-api
description: >
  Use when creating or modifying REST endpoints, controllers, DTOs, or error handling in Java
  Spring services - response envelopes, pagination, Problem Details, package layout.
---

# Spring API conventions

- **Envelope**: for new house-style APIs, `{data, meta{requestId, timestamp, traceId}}`; cursor pagination fields live in `meta`. Preserve an established public contract unless a migration is approved.
- **Errors**: for new house-style APIs, RFC 9457 Problem Details with a field-level `errors[]` array and `traceId`; preserve an established error contract unless migration is approved.
- **IDs**: public resource IDs use UUIDv7; TSID database keys stay internal. Never expose storage-generated IDs.
- **Money on the wire**: decimal string plus currency or asset code, with scale from the authoritative ISO 4217 or asset configuration.
- **Paths**: kebab-case and plural; follow the service's existing versioning strategy (`/api/v1/payment-links` when it uses path versioning).
- **Layout**: follow the established package-by-feature boundaries. Where these layers exist, `api/`, `application/`, `domain/`, and `infrastructure/` have real responsibilities; do not add empty layers to a simpler module.
- **HTTP client**: reuse the repository's configured client. Prefer `RestClient` for synchronous Spring Framework 6.1+ code, `WebClient` for an existing reactive stack, and do not add a second client stack merely to modernize. Use `.formatted()` only when the detected Java version supports it and it matches local conventions.
- **Pagination**: fetch `pageSize + 1` to compute `hasMore`.
- **Contract-first**: when an OpenAPI spec exists, work from it; new/changed endpoints update the spec in the same PR.

Full style guide with snippets: `references/api-conventions.md` (read before scaffolding a new endpoint; reuse existing request/response models before defining new ones).

## Tests
Use `@WebMvcTest` when controller contract behavior changed and Testcontainers when persistence behavior changed. Add only the layers needed to prove the change.

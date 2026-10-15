---
name: api-first
description: "Use when the user wants to scaffold or implement a REST endpoint or resource in a Spring Boot project, especially from an OpenAPI snippet or spec: create endpoint, add API, add CRUD, generate controller, or implement POST/GET/PUT/PATCH/DELETE on a resource."
---

# API-first: Spring Boot endpoint implementation

Implements a REST resource in an existing Spring Boot service from an OpenAPI fragment or a short
resource spec: controller, application logic, persistence, error mapping, spec update, and the tests
the change needs. Designing or reviewing a contract without code is `api-design`.

## Steps

1. **Detect the stack** before choosing any API: Java source level, Spring Boot and Framework
   versions, persistence (Spring Data JDBC or JPA, jOOQ, JdbcClient), mapping (manual or MapStruct),
   HTTP client in use, test setup, and the existing package layout, error handler, and envelope.
   ```bash
   grep -nE "sourceCompatibility|languageVersion|<java.version>|spring-boot|mapstruct|jooq|springdoc" build.gradle* pom.xml gradle/*.toml 2>/dev/null
   grep -rlE "@(Rest)?ControllerAdvice|ProblemDetail" src/main/java 2>/dev/null | head
   ```
2. **Confirm the shape** with the user unless the OpenAPI fragment already pins it:
   ```
   Resource:    PaymentLink at /api/v1/payment-links (follow the service's versioning)
   Operations:  POST, GET /{id}, GET (cursor list), PATCH /{id}, DELETE /{id}
   Fields:      id (UUIDv7 public), amount (decimal string + currency), expiresAt (Instant), status
   Idempotency: POST requires Idempotency-Key when it creates money-moving state
   Errors:      RFC 9457 Problem Details (or the service's established error contract)
   ```
3. **Read `references/api-conventions.md`** for envelope, errors, money, IDs, pagination, and HTTP
   client rules. Read `references/endpoint-scaffold.md` when generating a new resource stack from
   scratch; for a change to an existing resource, follow the neighbouring code instead.
4. **Contract first**: update the OpenAPI document (when the repo has one) in the same change.
5. **Test first, proportionate to the change**: a controller slice test when status codes,
   validation, or error shape change; an application test when business rules change; a Testcontainers
   integration test when queries or mapping change. Skip layers the change does not touch.
6. **Implement**, then compile and run the affected tests (`./gradlew test` or `./mvnw test`, plus
   the repo's integration-test task when one exists) and show the output.
7. **Before handing off**, check error shape, idempotent replay behavior, cursor correctness across
   tenants and filters, and that no internal ID appears in a response, URL, or cursor.

## House rules (new surfaces; preserve an established public contract)

- **IDs**: public IDs are UUIDv7 (`public_id` column). The TSID primary key stays internal: it never
  appears in a path, response body, `Location` header, or readable cursor.
- **Money**: decimal string plus currency on the wire, `BigDecimal` in Java, `NUMERIC` in SQL; scale
  from the currency or asset contract. Never `double` or `float`.
- **Time**: `Instant` or `OffsetDateTime`, ISO 8601 UTC on the wire. Never `java.util.Date`.
- **Errors**: RFC 9457 Problem Details through the service's single `@RestControllerAdvice`; add a
  handler there, never catch-and-map inside controllers. No stack traces, SQL, or provider payloads.
- **Idempotency**: a replay with the same key and same payload returns the original response; the
  same key with a different payload is `422` or `409` as the service already defines; a request still
  in progress under that key is `409`.
- **Layering**: controllers call application services, not repositories; responses are DTOs, never
  entities. Constructor injection only.
- **Reuse before adding**: the existing envelope, error handler, mapper style, HTTP client, and
  `IdempotencyStore`. Add MapStruct only if the repo already uses it or mapping volume justifies it.
- **Versions decide APIs**: `RestClient` only on Spring Framework 6.1+ synchronous code and only when
  the repo has no established client; `String.formatted` and records only when the source level
  supports them; `@MockitoBean` on Spring Framework 6.2+, `@MockBean` on older Boot.

## Output contract

```yaml
produces:
  - type: "code"
    format: "java"
    paths: [<list above>]
  - type: "migration"
    format: "sql"
    paths: ["src/main/resources/db/changelog/changes/sql/<resource>-001-schema.sql"]
  - type: "openapi"
    format: "yaml"
    paths: ["src/main/resources/openapi/<resource>.yaml"]
  - type: "test"
    format: "java"
    paths: [<list above>]
  handoff: "Write claudedocs/handoff-api-first-<timestamp>.yaml - suggest: verify-impl, db-migration (if schema changes)"
```

Code paths follow the repo's layout (see the scaffold reference for the house default). The
migration follows `db-migration` and uses the repo's tool and folder.

## Workflow context

- `api-design` designs or reviews the contract (no code); this skill implements it in Spring Boot.
- `db-migration` writes the schema changeset; `fintech-ledger` owns any money-moving operation.

## Anti-patterns (never generate)

- Exposing the TSID or any storage-generated ID, or a cursor that decodes to one.
- `200 OK` with an error body, or error mapping inside controllers.
- One request record reused for create and PATCH (PATCH fields are optional).
- A second HTTP client stack, mapper library, or envelope when the repo already has one.
- Tests for DTOs, getters, or framework wiring.

---
name: api-design
description: Design or review an API for consistency, usability, error handling, versioning, pagination, and developer experience. Covers REST, GraphQL, and RPC patterns. Triggers: "API design", "endpoint design", "API review", "REST API", "GraphQL schema".
argument-hint: "[API / endpoint / service]"
effort: high
---

# API design

## What I'll do
Design a clear, consistent API (or review an existing one) that's easy for consumers to use correctly and hard to use incorrectly.

## Inputs I'll use (ask only if missing)
- Who consumes this API (frontend, mobile, third-party, internal service)?
- What operations are needed (CRUD, workflows, queries)?
- Existing API patterns in the codebase (naming, auth, error format)
- Constraints (backwards compatibility, rate limits, payload size)

## How I'll think about this
1. **Design for the consumer, not the database**: API shape should reflect what consumers need, not your internal data model. Don't expose implementation details through your API surface.
2. **Naming is the hardest part**: Resource names should be nouns, not verbs. Use consistent pluralization. Actions that don't fit CRUD (approve, archive, export) need thoughtful endpoint design.
3. **Error contract is as important as success**: Every error should include: HTTP status, error code (machine-readable), message (human-readable), and field-level details for validation errors. Consumers will write code against your error format.
4. **Pagination from day one**: Any endpoint that returns a list will eventually return too many items. Design pagination in from the start — retrofitting it is a breaking change.
5. **Versioning strategy**: Decide upfront how you'll evolve the API. URL versioning (/v2/), header versioning, or additive-only changes? Each has trade-offs.
6. **Idempotency for writes**: POST/PUT/PATCH operations should be safe to retry. Use idempotency keys for operations that create resources or trigger side effects.
7. **Least surprise principle**: If a consumer guesses how an endpoint works based on other endpoints in the API, they should be right.

## Anti-patterns to flag
- Inconsistent naming (mix of camelCase and snake_case, singular and plural)
- Leaking internal IDs or implementation details in responses
- 200 OK with an error in the response body
- No pagination on list endpoints
- Breaking changes without versioning strategy
- Overly chatty APIs requiring multiple round-trips for common operations
- Missing rate limiting on public-facing endpoints
- No idempotency on state-changing operations

## Quality bar
- Naming is consistent across all endpoints (convention documented)
- Every endpoint has: method, path, request shape, response shape, error cases
- Error format is standardized with machine-readable codes
- Pagination is present on all list endpoints
- Auth requirements are specified per endpoint
- Breaking change policy is defined
- At least one complete request/response example per endpoint

## Workflow context
- Typically follows: `/design-doc` (system architecture)
- Feeds into: `/ticket-breakdown`, `/test-plan`, `/security-review`
- Related: `/docs-review` (API documentation quality)

## Output
Fill `templates/api-design.md`.

## Learning & Memory

After API design completes, save:
- API patterns adopted in this codebase (naming conventions, error format, auth scheme) for consistency across future endpoints
- Versioning strategies chosen and the breaking-change policies that worked
- Pagination approaches that proved effective for the data characteristics encountered

## Output contract
```yaml
produces:
  - type: "api-design"
    format: "markdown"
    path: "claudedocs/<feature>-api-design.md"
    sections: [endpoints, contracts, error_handling, pagination, versioning]
    handoff: "Write claudedocs/handoff-api-design-<timestamp>.yaml — suggest: spec-to-impl, test-plan, spec-panel"
```

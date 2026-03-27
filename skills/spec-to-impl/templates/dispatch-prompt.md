# Agent Dispatch Prompt Template

Use this template when constructing the prompt for each sub-agent dispatch.

---

```
You are a <ROLE TITLE> working on the <PROJECT NAME> project.

## Tech Stack
<List the agreed tech stack -- language, framework, DB, messaging, observability, etc.>

## Coding Conventions
<Key conventions or reference conventions.md>
- Package structure: ...
- Naming conventions: ...
- Error handling approach: ...
- Test framework: ...
- Logging framework: ...

## MANDATORY: Codebase Scan (do this FIRST)

Before writing ANY new class, interface, or component:

1. Search for existing patterns in the codebase:
   - Controllers: find existing base classes, response patterns, error handling
   - Services: find existing service patterns, transaction handling, logging, metrics
   - Repositories: find existing data access patterns, custom queries
   - DTOs: find existing request/response patterns, validation annotations
   - Components: find existing component patterns, shared utilities, hooks
   - Models: find existing entity/document patterns, naming conventions
   - Observability: find existing logging patterns, metric registrations, health indicators

2. List what you found:
   EXISTING PATTERNS FOUND:
   - <PatternName> at <file path> -- <what it does>
   - ... (list ALL relevant existing patterns)

3. Confirm: "I will EXTEND these patterns, not create parallel ones."

Creating a new pattern when an existing one covers the same concern is a
BLOCKING issue. Reuse first. Extract and generalize if needed. Create new
only when existing patterns genuinely don't fit.

## Your Assigned Task(s)

<Paste the full TASK block(s) assigned to this agent>

TASK-<ID>
  title:       <title>
  type:        <design | implement | test | instrument | document>
  priority:    <P0 | P1 | P2>
  depends_on:  [<IDs or "none">]
  input:       <what you receive>
  output:      <what you must produce>
  patterns:    [<design patterns to apply>]
  observability: [<logging events, metrics, traces required>]
  notes:       <any special considerations>

## Shared Contracts (MUST CONFORM TO)

<Paste the ARCH-defined contracts this agent must use>

- Shared DTOs:
  <paste Java records or TypeScript interfaces>

## API Standards Contract (MUST IMPLEMENT — see references/api-standards.md)

<Paste the ARCH-defined API standards for this project>

- Style:       <REST (OpenAPI 3.1) | GraphQL | gRPC | Async>
- Versioning:  <URL path /api/v1/ | header | additive-only>
- Envelope:    { "data": <T>, "meta": { "requestId": string, "timestamp": string, "traceId": string } }
- Errors:      RFC 9457 Problem Details — { "type": URI, "title": string, "status": int, "detail": string, "errors": [{ "field", "code", "message" }] }
- Pagination:  <cursor (limit + after) | offset (page + size)> — include metadata in response
- Idempotency: Idempotency-Key header on POST endpoints — store and replay on duplicate
- Status codes: 200 OK, 201 Created+Location, 204 No Content, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 409 Conflict, 422 Unprocessable, 429 Rate Limited+Retry-After
- Naming:      /api/v1/{resource-plural}[/{id}] — nouns, plural, kebab-case
- Dates:       ISO 8601 UTC always. Money: { amount: "150.00", currency: "USD" }
- IDs:         UUID (v7) — never expose auto-increment

## UI Design Artifacts (FE agents only)

<If /ui-design skill was run, paste its outputs here. Check design/ directory and handoff artifacts.>

- Design source: <Stitch MCP | Figma MCP | DESIGN.md | manual | none>
- Wireframes: <component hierarchy, layout specs -- check design/wireframes/>
- Design tokens: <colors, typography, spacing, breakpoints -- check design/visual-spec/tokens.md>
- Component specs: <props, states, interactions, responsive behavior -- check design/components/>
- Accessibility: <ARIA roles, keyboard navigation, screen reader requirements -- check design/a11y/>
- Test IDs: <data-testid attributes for E2E automation -- check design/components/testid-registry.md>
- DESIGN.md: <portable design system spec -- check design/DESIGN.md>

IF STITCH SCREENS AVAILABLE (design/stitch-screens/*.md or handoff has stitch.project_id):
  Stitch screen specs describe the generated screen structure (layout, components, content).
  Use them as DESIGN REFERENCE alongside wireframes and component specs.

  If Stitch project ID is available in the handoff artifact:
    You can call get_screen(name, projectId, screenId) for live screen structure data.
    Screen IDs are listed in the handoff YAML under stitch.screens[].

  Stitch does NOT provide exported code -- generate all components from scratch
  using the component specs, tokens, wireframes, and Stitch screen structure as reference.

  For each screen:
  1. Read design/stitch-screens/SCR-XXX.md for Stitch-generated layout structure
  2. Read design/components/component-specs.md for props, state, and interactions
  3. Read design/visual-spec/tokens.md for design tokens (derived from Stitch design system config)
  4. Read design/a11y/a11y-spec.md for accessibility annotations
  5. Apply data-testid attributes from design/components/testid-registry.md
  6. Add state variants (empty, loading, error) -- Stitch only generates happy path

IF NO DESIGN ARTIFACTS EXIST:
  Flag this to the orchestrator. Suggest running /ui-design --stitch first for rapid screen structure generation.
  If proceeding without design artifacts, use the spec wireframes/descriptions as reference.

Reference: skills/ui-design/SKILL.md for the full design system output format.
FE agents MUST implement against these artifacts when available.

## Observability Contract (MUST INSTRUMENT)

<Paste the OBS-defined observability requirements for this task>

### Logging Requirements
- Business events to log:
  <event.name>: level=INFO, context=[fields], when=<trigger>
  <failure.name>: level=ERROR, context=[fields + exception], when=<trigger>
- Required MDC fields: traceId, spanId, userId, tenantId, requestId, operationName
- Format: structured JSON (logstash-logback-encoder or equivalent)
- NEVER log: passwords, tokens, full card numbers, PII

### Metrics Requirements
- Counters: <metric.name> tags=[service, tenant, status]
- Timers: <metric.name> tags=[service, tenant, status] (with percentile histogram)
- Gauges: <metric.name> tags=[service]

### Tracing Requirements
- Custom spans: <operation> at <boundary> with attributes [key=value]
- Auto-instrumented: HTTP handlers, DB queries, HTTP clients (verify present)
- Context propagation: ensure traceId flows across async boundaries

### Health Requirements
- Custom HealthIndicator for: <external dependencies>

## Design Patterns to Apply

<Paste ARCH pattern selection for this component>

- <Pattern Name>: <how to apply in this context>
  Anti-pattern to avoid: <what NOT to do>

## Relevant Spec Sections

<Paste ONLY the spec sections relevant to this agent's task -- not the whole doc>

FR-00X: ...
BR-00X: ...
Entity: ...

## Test Cases (Definition of Done)

<From QA test plan -- which TCs must pass for this task>

- TC-001: <description> -- must PASS
- TC-002: <description> -- must PASS

## Produce the Following Artifacts

List each file you must output:
1. <file path> -- <brief description>
2. <file path> -- <brief description>

## Output Format

Output each file in this exact format so it can be automatically extracted:

--- FILE: <relative/path/to/file.ext> ---
<full file content>
--- END FILE ---

Do not include any commentary between files. After all files, include:

## Notes & Assumptions
<List any assumptions made, trade-offs, or items needing follow-up>

## Done Criteria

You are NOT done until ALL of the following are true:
1. Implementation written following shared contracts + design patterns
2. API standards applied (correct methods, status codes, envelope, errors, pagination, idempotency)
3. Observability instrumented per contract (logging, metrics, traces, health)
4. UI design artifacts respected (FE only: components, tokens, accessibility, testIDs)
5. Tests written covering implementation (happy path + error cases)
6. Tests EXECUTED with real output shown (not claims)
7. All tests PASS (zero failures, zero errors)
8. No compilation warnings on new code

Include a TEST REPORT block at the end:
--- TEST REPORT ---
Command: <exact command run>
Output:
<actual stdout/stderr from running tests>
Result: PASSED <n> / FAILED <f> / ERRORS <e>
Coverage: <percentage if available>
---
```

---

## Tips for Effective Dispatch

1. **Trim the spec** — Only send sections relevant to the agent's domain. Sending the full 50-page PRD to the FE agent wastes tokens and dilutes focus.

2. **Front-load contracts** — Always include ARCH-defined contracts AND OBS-defined observability contract before the task description. Agents must know the interfaces before implementing against them.

3. **Be specific about output paths** — Use real file paths (`src/main/java/com/org/service/auth/AuthService.java`), not vague descriptions.

4. **Include a brief example** — For complex output formats (especially observability instrumentation), include a 5-line example from an existing service. This dramatically improves output quality.

5. **One agent, one wave** — Don't dispatch a QA agent before the BE agent's output is available. Feed actual outputs as inputs to dependent agents.

6. **Include observability context** — Every implementation agent must know what to log, measure, and trace. Missing instrumentation blocks the wave gate.

7. **Reference test cases** — Include the specific test case IDs from the QA test plan that define "done" for this task. Agents can read `e2e/test-plan.yaml` for details.

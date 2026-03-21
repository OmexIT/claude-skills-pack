# Spec Manifest Template

```
SPEC MANIFEST
=============
Project:      <project name>
Source Doc:   <document title / file name>
Parsed By:    ARCH
Parsed At:    <timestamp>
Version:      1.0

── SUMMARY ────────────────────────────────────────────────
Total Requirements:     <n>
  Functional (FR):      <n>
  Non-Functional (NFR): <n>
Ambiguities:            <n>  ← pause if >3 critical
Total Estimated Tasks:  <n>

── FUNCTIONAL REQUIREMENTS ────────────────────────────────
FR-001: <requirement title>
  Description: <what it does>
  Actor:       <who performs this>
  Priority:    P0 | P1 | P2
  Acceptance:  <how we know it's done>
  Tasks:       → TASK-XXX

FR-002: ...

── NON-FUNCTIONAL REQUIREMENTS ────────────────────────────
NFR-001: <performance | scalability | security | compliance>
  Metric: <e.g., p99 < 200ms, 99.9% uptime>
  Tasks:  → TASK-XXX

── ENTITIES / DATA MODELS ─────────────────────────────────
- <EntityName>: <brief description, key fields>
- ...

── API ENDPOINTS ───────────────────────────────────────────
- POST /api/v1/<resource>     — <description>
- GET  /api/v1/<resource>/{id} — <description>
- ...

── UI SCREENS / COMPONENTS ─────────────────────────────────
- <ScreenName>: <brief description, key interactions>
- ...

── INTEGRATION POINTS ──────────────────────────────────────
- <Service Name>: <purpose, protocol, auth method>
- ...

── BUSINESS RULES ──────────────────────────────────────────
- BR-001: <rule description>
- ...

── TEST SCENARIOS ───────────────────────────────────────────
- TS-001: <scenario name> (Happy path | Edge case | Error case)
- ...

── OBSERVABILITY REQUIREMENTS ──────────────────────────────
Business Events to Log:
  - <entity>.<action>: <description, context fields>
  - ...
Custom Metrics:
  - <metric.name> (<Counter|Timer|Gauge>): <what it measures>
  - ...
SLOs:
  - <endpoint or operation>: p99 < <Xms>, error rate < <Y%>
  - ...
Dashboard Needs:
  - <panel description>: <what stakeholders want to see>
  - ...

── DESIGN PATTERN CANDIDATES ──────────────────────────────
- <Component>: <Pattern> — driven by <FR/NFR-XXX>
  Justification: <why this pattern fits>
- ...

── API STYLE & STANDARDS ──────────────────────────────────
Style:      <REST (OpenAPI 3.1) | GraphQL | gRPC | Async>
Detection:  <from existing codebase | spec signals | user specified>
Versioning: <URL path /api/v1/ | header | additive-only>
Envelope:   <standardized response wrapper format>
Errors:     <RFC 9457 | UserError payload | gRPC Status>
Pagination: <cursor-based | offset-based>
Rationale:  <why this style was chosen over alternatives>

── AMBIGUITIES [CRITICAL / NON-CRITICAL] ────────────────────
- [CRITICAL] AMB-001: <description of ambiguity> — needs user input
- [NON-CRITICAL] AMB-002: <description> — assumed: <assumption>
```

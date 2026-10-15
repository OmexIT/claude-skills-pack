# Verify-impl report: <feature> (<timestamp>)

Environment: <API url>, <frontend url>, <DB>, commit <sha>
Plan: <e2e/test-plan.yaml | spec path | discovered>, filter <all | --tc ... | --api/--db/--ui>

## Layers
| Layer | Checks | Passed | Failed | Not run (reason) |
|---|---|---|---|---|
| API | | | | |
| DB | | | | |
| UI | | | | |
| Mobile | | | | |

Per-layer detail (API, DB, UI, mobile results) follows, in the result skeleton from each layer's
reference.

## Coverage (one row per requirement in scope)
| Requirement | Layers it touches | Evidence (command + output or artifact path) | Status |
|---|---|---|---|
| FR-001 | API, DB | `curl ...` 201 body; `SELECT ...` 1 row | Verified |
| FR-002 | API, UI | screenshot tc002-success.png; no DB check run | Gap: DB write not checked |

## Failures
- [<layer>] <check>: expected <x>, got <y>. Evidence: <output or path>. Likely cause: <file:line or
  "not diagnosed, routed to debug-triage">.

## Verified working
- <flow>: <which layers, which evidence>

## Gaps and limits
- <what was not verified and why: service down, no emulator, no test user for role X>

## Verdict
READY: every in-scope requirement has evidence from each layer it touches and nothing fails.
NOT READY: <failures and gaps that block>.

Evidence: e2e/verify-impl/screenshots/, e2e/reports/verify-<timestamp>.log

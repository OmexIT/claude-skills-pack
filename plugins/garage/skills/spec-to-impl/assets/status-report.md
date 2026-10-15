# Status Report and Task Board Templates

## Task board

```
TASK BOARD - <Project>   Updated: <timestamp>   Progress: <x>/<y> (<z>%)

| TASK-ID  | Title               | Agent  | Impl | Tests      | OBS      | Output   | Figma ref |
|----------|---------------------|--------|------|------------|----------|----------|-----------|
| TASK-000 | Extract Figma ctx   | DESIGN | Done | N/A        | N/A      | design   | <link>    |
| TASK-001 | System design       | ARCH   | Done | N/A        | N/A      | arch.md  | -         |
| TASK-003 | Auth service        | BE     | Done | 24/24 pass | Verified | auth/    | -         |
| TASK-005 | Login UI            | FE     | WIP  | Not run    | Pending  | -        | <link>    |
| TASK-006 | Payment service     | BE     | Done | 3 FAILING  | Partial  | pay/     | -         |
```

Drop the OBS and Figma columns when those roles are not in the plan.

## Status report

Send after each wave, when a blocker appears, or on request. Omit sections that do not apply.

```
PROJECT STATUS - <Project>   <timestamp>   Wave <n>/<m>

PROGRESS     Total <n> | Done <n> | In progress <n> | Blocked <n> | Remaining <n>
TESTS        Run <n> | Passing <n> | Failing <n> (wave blocked if > 0) | Not run <n> | P0/P1 tasks without tests <n>
OBSERVABILITY  Instrumented <n>/<n> services | Events covered <n>/<n> | Dashboard <ready|pending>
DESIGN       Screens <n>/<n> | Code Connect mapped <n>/<n> | Ambiguities open <n> | MCP <connected|disconnected>

COMPLETED SINCE LAST REPORT
  - TASK-001 System design (ARCH) -> docs/architecture.md
IN PROGRESS
  - TASK-005 Login UI (FE) - started
BLOCKERS
  - TASK-006 Payment service (BE): PaymentServiceTest.refundsWhenCaptureFails failing (3)
NEXT WAVE
  - TASK-007 API docs (TECH_WRITER)
DECISIONS NEEDED
  - <ambiguities or inputs the user must provide>
```

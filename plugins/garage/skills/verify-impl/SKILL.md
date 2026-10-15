---
name: verify-impl
description: "Use when a completed implementation needs live verification: test the implementation, verify this works, run API tests, check the database, test the UI with Playwright, smoke or sanity test, or any post-build check beyond unit tests."
---

# Verify-impl: live implementation verification

> Delegation, model labels, and task tracking below use Claude Code notation. In Codex or another client, follow `../../references/cross-client.md`.

Proves a completed implementation works against the running stack, layer by layer (API, DB, UI,
mobile), with real evidence: actual HTTP responses, real rows, real browser screenshots. Driven by
`e2e/test-plan.yaml` when it exists (written by `spec-to-impl`, schema in
`references/test-plan-schema.md`).

## 1. Pick the mode

| Arguments | Mode |
|---|---|
| path ending `.yaml`/`.yml` | load that test plan, run its layers |
| path ending `.md` | read the spec, derive test cases inline (happy path per requirement, flagged edge cases, data states each flow must leave) |
| `--tc TC-001 TC-002` | load the plan, run only those test cases |
| `--api` / `--db` / `--ui` | load the plan (or discover), run only those layers |
| none | `e2e/test-plan.yaml` if present, else discover from the codebase |

Discovery fallback: find controllers or routes for the API surface, migrations or `@Entity` classes
for tables, and existing `*.spec.ts` / `*.e2e.ts` files. Tell the user coverage is best-effort.

When a plan loads, summarize it before running: test case count by priority (P0/P1/P2), how many
have API, DB, and UI blocks, and the filter applied.

## 2. Establish the environment

1. Read the repo's verification config first: AGENTS.md, CLAUDE.md, `docs/verification.md`, or
   similar. It names boot command, ports, health checks, seed data, test users, and DB access.
   If none exists, discover it and offer to record what you learn in `docs/verification.md`.
2. Confirm each service is up (`docker compose ps`, the app's health endpoint, the frontend URL).
   A layer whose service is down does not run; report it as not run, with the reason.
3. Credentials come only from environment variables (`TEST_USER`, `TEST_PASS`, `PGPASSWORD`, or the
   names the repo documents) or a gitignored local config. Check that `.env` keys exist by name;
   never print secret values or tokens into the transcript or the report.
4. Target environment: run freely against local or disposable stacks. Verification creates data;
   against a shared environment ask first, and never run setup or teardown SQL against shared or
   production data.

## 3. Run the layers the change touches

Run only the layers the change touches. Layer order: API first when DB or UI checks depend on
captured IDs (`e2e/.captures.json`, keyed by test case ID); otherwise layers are independent.
Small scope (a handful of test cases or one layer) runs inline in one pass. Fan out one agent per
layer only when several layers each carry many test cases, and pass each agent its layer reference.

| Layer | Read before running it |
|---|---|
| API | `references/api-layer.md`: auth from env, step execution with captures, Problem Details and idempotent-replay checks |
| DB | `references/db-layer.md`: Postgres check-type SQL (including the ledger check that must prove entries exist), MongoDB, Elasticsearch, Typesense |
| UI | `references/ui-layer.md`: Playwright setup, locator prefixes, generating the spec from `assets/test-plan-spec.ts`, responsive check |
| Mobile | `references/mobile-layer.md`: Flutter, React Native, Android, iOS runners; device runs versus supporting unit runs |

Locators follow `references/data-testid-conventions.md`: role and accessible name first, label
next, test IDs only as a justified fallback.

## 4. Evidence gate

Judge evidence coverage, not defect count.

- Every claim carries the command and its actual output, or an artifact path (screenshot, trace,
  log). "Tests pass" without runner output is not verified. A design-tool image is not evidence
  from the running app.
- Each in-scope requirement needs evidence from every layer it touches (an API-only change needs no
  screenshot; a write needs a DB check; a UI change needs a screenshot and, if layout changed, the
  responsive check). A requirement without that evidence is a gap and blocks READY.
- Finding nothing wrong is a valid result. State the verified scope and the remaining gaps; never
  invent issues to look thorough.
- A check that passed only on retry is reported as flaky.

## 5. Failures

1. Record the failing check with its evidence (status, body, row, screenshot).
2. If the cause is obvious from the evidence (a missing validation, a wrong field), say where. If
   not, route it to `debug-triage` for diagnosis; do not patch from the symptom.
3. After a fix, re-run the failed checks, then the smallest end-to-end path that proves the layers
   still integrate. Update the report with the new output.

Track one task per layer so the user can see progress.

## 6. Report

Fill `assets/verify-report.md`: environment, per-layer counts, one coverage row per requirement,
failures, gaps, verdict. Save it to `e2e/reports/verify-<timestamp>.log`; when an earlier report
exists, diff against it to spot regressions.

## Workflow context
- `test-plan` writes the human test strategy before or during build; this skill executes checks against the live stack after build.
- Follows `spec-to-impl` (consumes `e2e/test-plan.yaml`), `api-first`, `db-migration`, `mobile-dev`.
- Failures needing diagnosis go to `debug-triage`; the finished evidence feeds `evidence-review` and `finalize`.

## Output contract
```yaml
produces:
  - type: "verification"
    format: "markdown"
    path: "e2e/reports/verify-<timestamp>.log"
    sections: [api_results, db_results, ui_results, mobile_results, verdict]
    handoff: "Write claudedocs/handoff-verify-impl-<timestamp>.yaml - suggest: finalize, evidence-review"
```

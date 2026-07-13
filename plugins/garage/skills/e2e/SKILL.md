---
name: e2e
description: >
  Use when an implementation needs proof against the live running stack: after build completes,
  before ship, or when asked to verify, e2e-test, smoke-test, or demo that an API, UI, or DB
  change actually works.
---

# Live verification

## Per-repo setup (read, never guess)
Read the repo's verification config: AGENTS.md, CLAUDE.md, `TESTING-NOTES.md`,
`docs/operations/`, `.agents/verify.md`, or `.claude/verify.md`. It should define: boot
command (compose file), health checks, ports, seed data, test credentials per role, newman
collection paths, Playwright config, DB connection. If none exists, offer to create
`docs/verification.md`; keep real credentials in a gitignored local file or secret store.

## Layers - run what the change touches
- **Boot**: use the repository's boot command (often `docker compose up -d`), wait on its health checks, confirm migrations applied, and capture logs on failure.
- **API**: newman collections when they exist; otherwise curl the changed endpoints - auth flow, happy path, validation errors (RFC 9457 shape), and idempotent replay for money operations.
- **DB**: psql/mongosh state checks after writes - rows exist, balances reconcile. Ledger changes must run the zero-row invariant queries from the `ledger` references.
- **UI**: Playwright against the running app - real login with configured credentials, the changed flows, screenshot evidence. Prefer role, label, and accessible-name locators; use stable test IDs only when a semantic locator is insufficient, per `../../references/ui-selector-conventions.md`.

Resource: `scripts/playwright-setup.sh` installs Playwright browsers. Pass `--with-deps` only when approved OS dependencies are needed. The repository must already declare `@playwright/test`; add it only when the requested scope includes test setup.

## Evidence rules (default-to-reject)
- "Tests pass" without runner output = not verified. A design-tool screenshot is not evidence from the running app. Every claim needs the command plus its actual output.
- Reject missing coverage, not a low defect count: requirements marked done without a verification command fail the gate, as does a UI change without the relevant responsive/mobile check. If no defect is found, state the verified scope and remaining gaps without inventing issues.
- On failure: diagnose via `debug`, fix via `build`, re-run the failed layer, then the smallest end-to-end path that proves the layers still integrate.

Put the report (what ran, evidence, gaps) in the existing plan doc or PR description when one exists; otherwise return a concise verification report. Do not create a separate schema or ceremony file.

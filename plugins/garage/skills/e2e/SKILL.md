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
- **Boot**: `docker compose up -d`, wait on health endpoints, confirm migrations applied; capture logs on failure.
- **API**: newman collections when they exist; otherwise curl the changed endpoints - auth flow, happy path, validation errors (RFC 9457 shape), and idempotent replay for money operations.
- **DB**: psql/mongosh state checks after writes - rows exist, balances reconcile. Ledger changes must run the zero-row invariant queries from the `ledger` references.
- **UI**: Playwright against the running app - real login with configured credentials, the changed flows, screenshot evidence. Use `data-testid` selectors per `references/data-testid-conventions.md`.

Resources: `references/test-plan-schema.md` (structured test-plan format for features that warrant one) · `scripts/playwright-setup.sh` (install Playwright browsers + OS deps; requires @playwright/test already in the repo - add it as a devDependency first if missing).

## Evidence rules (default-to-reject)
- "Tests pass" without runner output = not verified. A design-tool screenshot ≠ evidence from the running app. Every claim needs the command plus its actual output.
- Auto-FAIL: zero issues reported on a non-trivial change · requirements marked done without a verification command · UI change without a responsive/mobile check.
- On failure: diagnose via `debug`, fix via `build`, re-run only the failed layer.

Report (what ran, evidence, gaps) goes into the plan doc or the PR description - no separate ceremony files.

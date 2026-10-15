---
name: test-plan
description: "Use when the user wants a test plan, QA plan, or release checklist, or asks how a feature, PR, or release should be tested."
---

# Test plan

## Inputs
- Feature or PR description (or link), and the code it touches
- Target platforms (web, iOS, Android, backend)
- Risk level and rollout approach (staged release, flags if the project already uses them)

## Decision rules
1. **Risk first.** Money, data integrity, auth and permissions, and migrations are high-risk; plan them
   first and deepest. Low-risk areas get a line, not a matrix.
2. **Lowest level that proves the behavior.** Unit for isolated logic, integration for boundaries
   (DB, queues, external APIs), E2E only for critical user journeys, manual for UX and exploratory
   checks. Never an E2E test for what a unit test covers.
3. **Business behavior, not implementation.** No tests for DTOs, getters, or framework wiring.
4. **Unhappy paths named explicitly:** dependency failure, malformed input, permission denied,
   concurrency, and the top three to five failure scenarios for the change.
5. **Domain cases the house always checks:**
   - Money: exact decimal amounts and rounding at currency scale, idempotent replay of the same
     request (one effect), and reconciliation after partial failure.
   - Time: values stored with zone, behavior across time zones and DST boundaries.
   - Migrations: forward on realistic data, and rollback or the restore story if irreversible.
   - UI: role, label, and accessible-name locators; test IDs only where semantics cannot reach.
6. **Every bug fix gets a regression test** that fails without the fix.
7. **Verify in production** for risky changes: which log, metric, or alert confirms it works.

## Anti-patterns to flag
- Happy path only; E2E for unit-level logic; no migration or rollback verification
- Flaky tests ignored instead of fixed or quarantined with an owner
- "Tests later" for high-risk areas

## Output
Fill `assets/test-plan.md`; drop sections that do not apply to the change.

## Workflow context
- This skill writes the human test strategy before or during build; `verify-impl` executes checks against the live stack after build.
- Follows `design-doc`, `ticket-breakdown`, or a PR; feeds `spec-to-impl`, whose QA agent turns it into the machine-readable `e2e/test-plan.yaml`.
- Related: `security-review` and `performance-review` for their own test cases; `release-notes` for the shipped scope.

## Output contract
```yaml
produces:
  - type: "test-plan"
    format: "markdown"
    path: "claudedocs/<feature>-test-plan.md"
    sections: [strategy, coverage_matrix, edge_cases, release_checklist]
    handoff: "Write claudedocs/handoff-test-plan-<timestamp>.yaml - suggest: spec-to-impl"
```

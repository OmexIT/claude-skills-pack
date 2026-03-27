---
name: test-plan
description: Create a risk-based test plan for a feature, PR, or release. Includes test strategy, coverage matrix, edge cases, and rollout checks. Triggers: "test plan", "QA plan", "how should we test", "release checklist".
argument-hint: "[feature / PR / release]"
effort: medium
---

# Test plan

## Inputs I'll use
- Feature/PR description (or link)
- Target platforms (web/iOS/Android/backend)
- Risk level and rollout approach (flags, staged release)

## How I'll think about this
1. **Risk-first prioritization**: Start with what can go wrong, not what should go right. Money, data integrity, auth, permissions, and migrations are always high-risk. Test those first and most thoroughly.
2. **Choose the right test level**: Unit tests for isolated logic. Integration tests for boundaries between components. E2E tests for critical user journeys. Manual tests for UX, visual, and exploratory coverage. Don't write E2E tests for what a unit test covers.
3. **Test the boundaries**: Most bugs live at boundaries — between services, at data type edges, at permission transitions, at pagination limits, at time zone changes.
4. **Cover the unhappy path**: Test what happens when dependencies fail, when inputs are malformed, when the user does something unexpected. Error handling is where most bugs hide.
5. **Regression after bug fixes**: Every bug fix should add a test that would have caught the bug. No exceptions.
6. **Don't test implementation details**: Tests should verify behavior, not internal structure. If a refactor breaks your tests but not your functionality, your tests are too coupled.

## Anti-patterns to flag
- Testing only the happy path
- E2E tests for logic that unit tests cover (slow, flaky, expensive)
- No tests for error handling or edge cases
- Skipping migration/rollback verification
- "We'll add tests later" (they never get added)
- Flaky tests that are ignored instead of fixed

## Quality bar
- High-risk areas (money, auth, data) have thorough coverage
- Test matrix covers both happy path and top 3-5 failure scenarios
- Edge cases are identified and explicitly covered or marked as out of scope
- Release readiness checklist is concrete (not just "tests pass")
- Rollback plan is tested, not just documented
- Observability checks are included (how to verify in production)

## Workflow context
- Typically follows: `/design-doc`, `/ticket-breakdown`, `/pr-review`
- Feeds into: `/spec-to-impl` (QA planning input — shapes the machine-readable `e2e/test-plan.yaml`), `/release-notes`
- Related: `/security-review` (security test cases), `/performance-review` (perf test cases)

> **Note:** This skill produces a human-readable test strategy document (markdown).
> For automated test execution, `/spec-to-impl`'s QA agent generates `e2e/test-plan.yaml` (machine-readable YAML)
> which `/verify-impl` consumes directly. Use this skill for test planning; use `/spec-to-impl` + `/verify-impl` for automated execution.

## Output
Fill `templates/test-plan.md` and tailor it to the change.

## Learning & Memory

After test plan creation completes, save:
- Test strategies that proved effective for this type of feature (risk-based prioritization, boundary testing, integration test patterns)
- Coverage gaps found during testing or post-release that should inform future test plans
- Flaky test patterns encountered and the root causes identified (timing, shared state, external dependencies)

## Output contract
```yaml
produces:
  - type: "test-plan"
    format: "markdown"
    path: "claudedocs/<feature>-test-plan.md"
    sections: [strategy, coverage_matrix, edge_cases, release_checklist]
    handoff: "Write claudedocs/handoff-test-plan-<timestamp>.yaml — suggest: spec-to-impl"
```

---
name: evidence-review
description: >
  Default-to-rejection quality gate. Assumes NEEDS WORK until overwhelming evidence proves otherwise.
  Requires actual test output, screenshots, build logs — not claims.
  Triggers: "evidence review", "prove it works", "show me proof", "quality gate", "final review".
argument-hint: "[feature / PR / implementation to review]"
effort: high
---

# Evidence review (default-to-rejection)

## What I'll do
Act as the final quality gate before shipping. I default to **NEEDS WORK** and require concrete evidence to approve. Claims without proof are automatic failures.

## Inputs I'll use (ask only if missing)
- What was implemented (feature, PR, or spec reference)
- Test plan or acceptance criteria (or handoff artifact from /verify-impl, /spec-to-impl)
- Access to the codebase to verify claims

## Core philosophy

**NEEDS WORK until proven otherwise.**

This inverts the typical review pattern. Instead of "looks good unless I find problems," this skill assumes problems exist and requires evidence of quality.

## Automatic FAIL triggers
Any of these → immediate NEEDS WORK rating:
- ❌ Zero issues reported (impossible for any real implementation)
- ❌ "Tests pass" without actual test runner output pasted
- ❌ "Build succeeds" without actual build log
- ❌ Perfect scores without supporting documentation
- ❌ Specs marked "implemented" without a verification command to prove it
- ❌ "Works on my machine" without CI or reproducible evidence
- ❌ Screenshots from a design tool, not from the running application

## How I'll think about this

1. **Collect evidence inventory**: For every requirement marked "done," demand the proof:
   | Requirement | Evidence Type | Evidence Location | Verified? |
   |---|---|---|---|
   | FR-001: User can submit form | Screenshot of running app | e2e/screenshots/tc001.png | ✅/❌ |
   | FR-002: API validates input | curl output showing 400 | test-report.log line 45 | ✅/❌ |
   | FR-003: Data persists to DB | psql query result | db-verify.log | ✅/❌ |

2. **Verify evidence is real**: Run the verification commands myself. Don't trust pasted output — re-execute:
   ```bash
   # Re-run tests
   mvn test 2>&1 | tail -20
   # Re-check DB state
   docker compose exec db psql -U postgres -d appdb -c "SELECT count(*) FROM ..."
   # Re-take screenshot
   npx playwright test --grep "TC-001" 2>&1
   ```

3. **Check for missing coverage**: Cross-reference the spec/PRD against what was tested:
   - Every P0 requirement: needs test evidence
   - Every API endpoint: needs a request/response pair
   - Every DB write: needs a row existence check
   - Every UI flow: needs a screenshot or Playwright result

4. **Check for regressions**: Compare current test results against previous baseline:
   ```bash
   # Find previous test results
   ls -t e2e/reports/verify-*.log | head -2
   # Diff test counts
   ```

5. **Check code quality signals**:
   - Are there new TODO/FIXME comments? (incomplete work)
   - Are there commented-out code blocks? (uncertainty)
   - Are there `@Suppress` / `// eslint-disable` / `// ignore:` annotations? (suppressed warnings)
   - Are there duplicate patterns? (didn't reuse existing code)

6. **Rate the implementation**:
   - **REJECT**: Critical requirements unverified, tests failing, evidence missing
   - **NEEDS WORK**: Minor gaps in evidence, non-critical issues found
   - **CONDITIONAL PASS**: All P0 evidence provided, P1/P2 gaps documented as follow-up
   - **PASS**: All requirements have evidence, all tests pass, code quality clean

## Evidence types accepted

| Type | What constitutes valid evidence | Invalid evidence |
|---|---|---|
| **Test output** | Actual stdout from test runner with pass/fail counts | "All tests pass" (text claim) |
| **Screenshots** | Playwright/emulator screenshot of running app | Figma mockup or design file |
| **Build logs** | Actual compiler/bundler output showing success | "Build works" (text claim) |
| **API responses** | curl output with status code and response body | API spec showing expected response |
| **DB state** | psql/mongosh query result showing actual rows | Schema diagram |
| **Coverage report** | Coverage tool output with percentages and uncovered lines | "We have good coverage" |
| **Lint output** | Linter stdout showing zero errors | "Code is clean" |

## Anti-patterns to flag
- ⚠️ Accepting self-reported quality without verification
- ⚠️ "It works" without a reproducible verification command
- ⚠️ Reviewing only the code diff without running the application
- ⚠️ Skipping mobile/responsive verification for UI changes
- ⚠️ No regression check against previous test baseline
- ⚠️ Approving with known TODO comments in core logic

## Quality bar
- ✅ Every P0 requirement has at least one piece of concrete evidence
- ✅ All evidence was verified (re-executed, not just trusted)
- ✅ Code quality scan found no incomplete work markers
- ✅ No duplicate patterns introduced (checked against existing codebase)
- ✅ Rating is one of: REJECT / NEEDS WORK / CONDITIONAL PASS / PASS
- ✅ Follow-up items documented for anything not covered

## Workflow context
- Typically follows: `/verify-impl`, `/spec-to-impl`, `code-review:code-review` (official plugin)
- Feeds into: `/finalize` (if PASS or CONDITIONAL PASS)
- Related: `/test-plan` (defines what needs evidence), `/security-review`

## Learning & Memory
After completing this skill, store reusable insights in memory:
- **Evidence quality standards**: What constitutes sufficient proof for different requirement types, and minimum evidence thresholds that caught real issues
- **Common proof gaps**: Recurring areas where implementations lack verification -- untested edge cases, missing integration evidence, and overlooked regression checks
- **Verification patterns**: Effective re-execution commands, cross-referencing techniques, and evidence collection workflows that streamlined the review process

## Output contract
```yaml
produces:
  - type: "evidence-review"
    format: markdown
    path: "claudedocs/<feature>-evidence-review.md"
    sections: [evidence_inventory, verification_results, code_quality, rating, follow_ups]
    rating: "REJECT | NEEDS WORK | CONDITIONAL PASS | PASS"
    handoff: "Write claudedocs/handoff-evidence-review-<timestamp>.yaml — suggest: finalize"
```

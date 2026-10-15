---
name: evidence-review
description: "Use when work must pass a final quality gate backed by proof: evidence review, prove it works, show me proof, or deciding whether claimed test results, screenshots, and build logs justify calling something done."
---

# Evidence review (default-to-rejection)

Final gate before shipping. The rating starts at **NEEDS WORK** and moves up only as evidence
covers the requirements. This skill judges whether the proof is sufficient; it does not gather
fresh evidence at scale (`verify-impl` does) or audit code quality broadly (`code-audit` does).

## Inputs (ask only if missing)

- What was implemented (feature, PR, or spec reference) and its acceptance criteria or test plan
- Evidence already produced (handoff from `verify-impl` or `spec-to-impl`, logs, reports)
- Access to the codebase to re-check claims

## What fails the gate

The gate judges evidence coverage, never the number of issues found. A review that finds nothing
wrong passes when the evidence covers every requirement; a review that finds nothing because
nothing was checked fails. Any of these means NEEDS WORK or worse:

- "Tests pass" or "build succeeds" with no runner or build output
- A requirement marked done with no verification command or artifact behind it
- A zero-issue or perfect-score report that does not show what was checked
- "Works on my machine" with no CI run or reproducible command
- Screenshots from a design tool instead of the running application
- Evidence for a different commit, branch, or environment than the one being shipped

## Workflow

1. **Evidence inventory.** For every requirement claimed done, record the proof:

   | Requirement | Evidence type | Location | Verified? |
   |---|---|---|---|
   | FR-001 user can submit form | Playwright run against the app | e2e report, test TC-001 | PASS/FAIL |
   | FR-002 API rejects bad input | HTTP response with status and body | test log line 45 | PASS/FAIL |

2. **Re-check it.** Re-run the repository's own verification commands (tests, build, lint, the
   targeted e2e case) rather than trusting pasted output. Read-only queries against a local or
   test database are fine. Anything that resets, reseeds, migrates, or deletes data needs the
   user's explicit confirmation and a restore path first.
3. **Coverage, proportional to risk.** Every P0 requirement and every money, auth, data-mutation,
   or tenant-isolation path needs direct evidence. API changes need a request and response pair;
   persisted state needs a query or test that reads it back; UI flows need a run against the real
   app at the viewports the feature supports. Lower-risk items can rest on a covering automated test. Record anything uncovered.
4. **Regressions.** Compare against the previous baseline (prior CI run or report): test counts,
   newly skipped or disabled tests, new warnings.
5. **Incomplete-work signals** in the diff: new TODO/FIXME without a tracked follow-up,
   commented-out code, new lint or type suppressions, duplicated logic that existing code already
   provides.
6. **Rate:**
   - **REJECT**: a critical requirement unverified, tests failing, or evidence fabricated or stale
   - **NEEDS WORK**: evidence gaps on non-critical requirements, or minor issues found
   - **CONDITIONAL PASS**: all P0 evidence verified; P1/P2 gaps documented as follow-ups
   - **PASS**: every requirement has verified evidence, checks re-ran green, no incomplete-work signals

## Valid evidence

| Type | Valid | Not valid |
|---|---|---|
| Tests | Runner output with pass/fail counts for this commit | "All tests pass" |
| Build | Compiler or bundler output | "Build works" |
| API | Request plus status code and body | The OpenAPI example |
| Data | Query result or test that reads the state back | Schema diagram |
| UI | Automated run or screenshot of the running app | Design mockup |
| Coverage | Tool output with uncovered lines | "Good coverage" |
| Absence | Scoped search naming paths and terms | "Nothing else uses it" |

## Workflow context

- Typically follows: `verify-impl` (gathers live evidence), `spec-to-impl`, `code-review:code-review` (official plugin).
- Feeds into: `finalize` on PASS or CONDITIONAL PASS.
- `test-plan` defines what needs evidence; `code-audit` judges code quality, not proof.

## Output contract
```yaml
produces:
  - type: "evidence-review"
    format: markdown
    path: "claudedocs/<feature>-evidence-review.md"
    sections: [evidence_inventory, verification_results, code_quality, rating, follow_ups]
    rating: "REJECT | NEEDS WORK | CONDITIONAL PASS | PASS"
    handoff: "Write claudedocs/handoff-evidence-review-<timestamp>.yaml - suggest: finalize"
```

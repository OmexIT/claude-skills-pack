---
name: pr-review
description: Review a pull request or code diff for correctness, security, performance, tests, maintainability, and product impact. Triggers: "review this PR", "code review", "diff review", "LGTM?"
argument-hint: "[PR URL | branch | commit range | files]"
disable-model-invocation: true
effort: high
---

# PR review

## What I need
- The PR link, branch name, commit range, or the list of files to review
- The intended behavior (ticket/issue link or a 2-3 sentence summary)
- Anything you're worried about (risk areas, deadlines, migration concerns)

## Review approach
1. **Restate intent** in 2-4 bullets (so we're aligned).
2. **Scan for risk areas**: auth, data integrity, migrations, payments, concurrency, caching, rate limits.
3. **Read for correctness**: edge cases, error handling, default behavior.
4. **Read for "operability"**: logs, metrics, safe failures, rollback.
5. **Read for maintainability**: naming, structure, duplication, consistency with existing patterns.
6. **Verify with evidence when possible**:
   - run unit tests / typecheck / lint
   - grep for related call sites and invariants

## Anti-patterns to flag
- Style-only feedback on logic-heavy PRs (missing the forest for the trees)
- Approving without understanding the change ("looks good to me" without reading)
- Blocking on subjective preferences rather than correctness
- Missing authorization checks on new endpoints
- New dependencies without justification

## Checklist
### Correctness
- [ ] Logic matches intent and handles key edge cases
- [ ] Errors are handled explicitly (no silent failures)
- [ ] State changes are consistent and idempotent when needed

### Security & privacy
- [ ] Authorization checks are present where needed
- [ ] Inputs are validated/sanitized appropriately
- [ ] No secrets/PII in logs or error messages

### Performance & reliability
- [ ] No obvious N+1, unbounded loops, or expensive hot paths
- [ ] Timeouts/retries/backoff are reasonable (if applicable)

### Testing
- [ ] Tests cover the happy path and at least 1-2 important edge cases
- [ ] Regression test added for bug fixes

### Product & UX
- [ ] User-facing behavior matches the PRD/spec
- [ ] Error states are user-safe and understandable

## Quality bar
- Every must-fix finding includes: what's wrong, why it matters, and a suggested fix
- Review distinguishes between objective issues (bugs) and subjective preferences
- Positive feedback is included when appropriate (good patterns worth noting)
- Questions are genuine, not passive-aggressive suggestions

## Workflow context
- Typically follows: `/ticket-breakdown` (implementation of tickets)
- Feeds into: `/release-notes`, `/test-plan`
- Related: `/security-review` (deep security focus), `/performance-review` (deep perf focus)

## Output format
Return feedback in this structure:

## Summary
- ...

## Must-fix (blockers)
1. **Title** — file:line — why it matters — suggested fix

## Should-fix (important)
1. ...

## Nice-to-have (polish)
1. ...

## Questions
- ...

## Output contract
```yaml
produces:
  - type: "pr-review"
    format: "markdown"
    path: "claudedocs/<feature>-pr-review.md"
    sections: [correctness, security, performance, tests, maintainability]
    handoff: "Write claudedocs/handoff-pr-review-<timestamp>.yaml — suggest: release-notes"
```

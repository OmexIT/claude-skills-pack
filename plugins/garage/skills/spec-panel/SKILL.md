---
name: spec-panel
description: "Use when a spec, PRD, BRD, design doc, or RFC needs expert review before implementation starts: review this spec, is it ready to build, any gaps, am I missing anything, spec smells, or a devil's advocate pass."
---

# Spec Panel Analysis

> Delegation, model labels, and task tracking below use Claude Code notation. In Codex or another client, follow `../../references/cross-client.md`.

Readiness review of a specification before implementation: the spec is checked against the live
codebase and docs, audited for requirements quality, and critiqued through expert lenses.
Read-only: it writes a separate analysis and never edits the spec or produces implementation code.

## When to use a neighbour instead

- Writing or updating the PRD itself: `prd`. Writing a design doc: `design-doc`.
- Code that already exists: `code-audit` (breadth) or `arch-review` (Java/Spring boundaries).
- Proving finished work meets its spec: `verify-impl` to gather evidence, `evidence-review` to judge it.
- A focused threat model or performance budget: `security-review`, `performance-review`.

## Inputs (ask only what the spec and repo cannot answer)

The spec (path or inline), goal (new feature, refactor, fix), scope, audience, deadline pressure,
and hard constraints (APIs that cannot change, compliance). Ask at most a few questions, and only
when the answer changes the review. If the spec is an early draft, say so and limit the review to
structure, scope, and open decisions.

## Phase 1 - Evidence (gate before findings)

A spec reviewed without context is a guess. Verify the spec's claims instead of trusting them.

1. **Repo markers:** AGENTS.md / CLAUDE.md, README, build files (exact stack versions).
2. **Code the spec touches:** read every file it names plus direct collaborators and callers; grep
   the spec's keywords for prior or partial implementations; `git log --oneline -20 -- <path>` on
   touched paths to spot concurrent work.
3. **Docs that bind it:** ADRs, design docs, prior `claudedocs/*-panel-analysis.md` for this spec,
   OpenAPI contracts, migrations (schema reality), relevant tests and fixtures. A conflict with an
   accepted ADR or a published contract is at least HIGH.
4. **Drift:** for every place the spec and the live system disagree, classify it before
   recommending an edit: code defect, stale spec, approved but undocumented change, or unresolved
   decision. Only a stale spec is fixed by editing the spec; the others need a code fix or an owner's
   decision. If the spec references code that does not exist yet, say so.
5. **Versions and external facts, only where they matter:** when a requirement depends on
   version-specific framework behavior, a deprecation, an advisory, a regulation, or an RFC, confirm
   it with context7 or the primary source and cite the URL actually fetched. Note stack mismatches
   (spec assumes a version the project does not run).

**Gate:** read `assets/panel-analysis.md` before producing the context manifest; it holds every
table for the report. Produce the manifest before Phase 2. A finding with no Phase 1 evidence is labelled speculation. Blockers are surfaced, never skipped.

## Phase 2 - Requirements quality

1. **Quality attributes (IEEE 830):** score correct, unambiguous, complete, consistent, ranked, verifiable,
   modifiable, traceable, each with a quoted example or a scoped absence.
2. **Spec smells:** flag language that leaves behavior open: unquantified scope (all, never),
   vague frequency (usually, often), vague adjectives (fast, user-friendly, robust, seamless), weak
   verbs (handle, support, process), uncertainty (should, may, TBD), and implementation leaks
   (solution stated as requirement). Rewrite each flagged requirement into a testable one; ignore
   smells in narrative text that constrains nothing.
3. **Cross-cutting concerns:** check only the concerns the spec's scope raises: security and
   authorization, privacy and retention, observability, backward compatibility, rollback, failure
   handling, performance and capacity, multi-tenancy, accessibility, internationalization. List the
   rest as not applicable in one line. Never demand speculative feature flags, analytics, caching,
   or fixed NFR targets the change does not need; ask for a flag only when the rollout risk calls
   for one.
4. **House law, where the spec touches it:** money as `BigDecimal`/`NUMERIC`, time as
   `Instant`/`TIMESTAMPTZ`, TSID internal and UUIDv7 external IDs, RFC 9457 errors. A spec that
   mandates otherwise is a finding.
5. **Alternatives:** for each consequential or hard-to-reverse decision, check that alternatives and
   trade-offs are recorded. Size a missing alternatives section by the decision's reversibility; a
   small, reversible change does not need one.

## Phase 3 - Expert lenses

Severity: **CRITICAL** blocks delivery or risks data loss, security, or money (fix before
implementation); **HIGH** will cause bugs or rework (fix before ship); **MEDIUM** debt, test, or
operational gap (schedule); **LOW** polish.

Finding format, used by every lens:

```
[SEVERITY] Issue title
├─ Issue: what is wrong, with the spec location (section or quote)
├─ Evidence: spec quote, code or doc reference, or scoped absence
├─ Impact: what happens if not addressed
├─ Recommendation: concrete change to the spec or the design
└─ Rationale: why, citing the lens, source, or research
```

| Lens | Label | Runs when | Focus |
|---|---|---|---|
| Wiegers (requirements) | `sonnet` | Always | Completeness, testability, ambiguity, contradictions, acceptance criteria |
| Fowler (design) | `opus` | Always | Integration gaps, coupling, abstractions, alternatives |
| Adzic (examples) | `sonnet` | Always | Given/When/Then examples, missing edge cases |
| Crispin (testing) | `sonnet` | Always | Test gaps, risky paths, regression exposure |
| Nygard (operations) | `opus` | Always | Failure modes, deployment and migration safety, timeouts and retries chosen from failure semantics |
| Fielding (API) | `opus` | API or integration | Resource model, versioning, error contracts |
| Kleppmann (data) | `opus` | Data model or storage | Consistency, schema evolution, migration safety |
| Hunt (security) | `opus` | Auth, PII, compliance | Exposure, auth flows, secrets |
| Helland (money) | `opus` | Payments, ledgers, transactions | Idempotency, unknown outcomes, compensation, ledger integrity |
| Young (events) | `opus` | Event-driven design | Event boundaries, projections, replay |
| Ruecker (workflows) | `opus` | Orchestration, sagas | Compensation, timeouts, versioning |
| Majors (operability) | `sonnet` | Deployment, SLOs | Alerting, canaries, rollout safety |
| Cagan (product) | `sonnet` | Product or UX decisions | Right problem, discovery gaps |
| Abramov (frontend) | `sonnet` | Frontend or UI | Composition, state, rendering |
| Skeptic | `opus` | Always, after the others | Should this be built at all, what if we did nothing, simplest thing that works, which assumption invalidates the spec |

State which conditional lenses activated and why. Each lens reports only specific, evidenced
findings; a lens with nothing material says so in one line.

**Fan-out is conditional.** A short spec or a single-feature change runs all lenses inline in one
pass. Fan out only for a large spec (several services or domains): dispatch the active lenses as
parallel Agent calls in one message (`general-purpose`), each given the context manifest, the spec,
and its focus. The Skeptic runs after the others, on their findings.

## Phase 4 - Score, consolidate, save

1. Fill the quality scorecard. Scores follow evidence: a clean, high-scoring spec is a valid result
   when the manifest shows what was checked. Guide: 9-10 ready; 7-8 fix HIGH first; 5-6 another
   review cycle; 3-4 rework before implementation; 1-2 restart from the problem statement.
2. Consolidate: current-state versus spec table (with drift class), risk register, implementation
   plan (task, files, effort, dependencies, source lens), priority split into must-do, should-do,
   nice-to-have, and recommended reading from sources actually fetched.
3. Save to `claudedocs/<spec-name>-panel-analysis.md` using `assets/panel-analysis.md`, recommendation
   tracker first, every status `PENDING`.
4. Tell the user where it is and that the next step is updating the spec from the tracker (stale-spec
   drift only; route code defects and open decisions to their owners), then re-running `spec-panel`.

## Gates and anti-patterns

- **Pre-implementation gate:** do not chain to `spec-to-impl` while CRITICAL findings are open. If
  asked to, route back to spec revision first.
- Never produce implementation code or modify the spec in place.
- Root-cause each CRITICAL finding (missing context, unclear owner, legacy assumption, conflicting
  sources) before proposing the remediation.
- Do not trust the spec's description of current behavior; verify it.
- Findings are concrete and actionable ("define the refund cap and the response when a refund
  exceeds the original amount"), not generic ("improve error handling").
- Explain why an approach was chosen, not only how to build it.
- Do not bikeshed wording while a design flaw stands; do not let the lenses agree without the
  Skeptic testing the premise.

## Workflow context

- Upstream: `prd`, `design-doc`, `api-design`, `data-design`, `flow-map`, `ui-design` produce the documents reviewed here.
- Downstream: spec revision, then `spec-to-impl`, `ticket-breakdown`, `test-plan`.
- This is the gate before code exists; `code-audit` and `evidence-review` judge code and proof after it exists.

## Output contract

```yaml
produces:
  - type: "panel-analysis"
    format: "markdown"
    path: "claudedocs/<spec-name>-panel-analysis.md"
    sections:
      - clarification-answers
      - codebase-findings
      - internet-research
      - ieee-830-quality-audit
      - spec-smells-report
      - cross-cutting-concerns-checklist
      - alternatives-considered-check
      - expert-panel-findings
      - skeptic-challenges
      - quality-scorecard
      - current-state-summary
      - risk-register
      - implementation-plan
      - recommended-priority
      - recommended-reading
      - recommendation-tracker
  handoff: "Write claudedocs/handoff-spec-panel-<timestamp>.yaml - suggest: spec revision (apply recommendations), spec-to-impl (ONLY after CRITICAL findings are resolved), ticket-breakdown (turn analysis into tickets), remediation plan"
```

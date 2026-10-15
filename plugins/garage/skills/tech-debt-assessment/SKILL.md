---
name: tech-debt-assessment
description: "Use when the user wants technical debt inventoried or prioritized: tech debt, code health, refactoring priorities, or a cleanup roadmap."
---

# Tech debt assessment

Inventory debt across a codebase or system, categorize it, and produce a repayment plan ordered by
cost of delay. This prioritizes across areas; for evidence-level findings inside specific code, run
`code-audit` first and feed its Tier 2/3 findings in here.

## Inputs (ask only if missing)

- Codebase or area to assess
- Known pain points (slow builds, flaky tests, difficult deploys, recurring incidents)
- Upcoming roadmap (which planned work the debt blocks or slows)

## Workflow

1. **Gather evidence, not impressions:** churn hotspots
   (`git log --since="6 months ago" --format= --name-only | grep . | sort | uniq -c | sort -rn | head`), build and CI durations, flaky or disabled tests, incident and
   postmortem history, prior `claudedocs/*-code-audit.md` reports, and team pain points. Each debt
   item cites at least one of these.
2. **Categorize:** code (duplication, poor abstractions), architecture (wrong boundaries, scaling
   limits), testing (missing or flaky tests), infrastructure (manual steps, outdated tooling),
   documentation (missing runbooks, stale docs). The type decides the remediation approach.
3. **Cost of delay, not ugliness:** ugly code nobody touches costs little; a module changed weekly
   costs on every change. Score each item by how often it is touched and what it slows or risks.
4. **Compounding debt first:** debt that grows with every feature built on it (a bad abstraction, a
   duplicated source of truth) gets more expensive to fix each month.
5. **Connect to the roadmap:** debt blocking planned work comes first; debt in areas untouched for
   months waits.
6. **Right-size fixes:** many items need an extracted function, a deleted dead path, or one missing
   test, not a rewrite. List quick wins separately.
7. **Plan repayment:** a steady allocation alongside feature work, owners, done criteria, and the
   metrics that will show improvement.

Flag these when you see them: "rewrite everything" as strategy, a one-off cleanup sprint with no
ongoing allocation, a debt list with no priorities, priorities driven by preference rather than
cost, and treating every item as equally severe.

## Output

Fill `assets/tech-debt-assessment.md`. Each item has evidence, cost-of-delay, blast radius, and
remediation effort.

## Workflow context

- Typically follows: `code-audit`, `arch-review`, retrospectives, postmortems, painful feature work.
- Feeds into: `ticket-breakdown` (repayment tickets), `design-doc` (architectural changes).
- Related: `performance-review` and `security-review` for debt in those areas.

## Output contract
```yaml
produces:
  - type: "assessment"
    format: "markdown"
    path: "claudedocs/<feature>-tech-debt-assessment.md"
    sections: [inventory, prioritization, cost_of_delay, roadmap]
    handoff: "Write claudedocs/handoff-tech-debt-assessment-<timestamp>.yaml - suggest: ticket-breakdown, design-doc"
```

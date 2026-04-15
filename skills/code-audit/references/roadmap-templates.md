# Code Audit — Scorecard & Roadmap Templates

Load this when producing Phase 3 (scorecard) and Phase 4 (improvement roadmap) output during `/code-audit`.

---

## Quality Scorecard

| Dimension | Score (1-10) | Findings (C/H/M/L) | Key Issue |
|---|---|---|---|
| **Code Smells & Clean Code** | | | |
| **SOLID Compliance** | | | |
| **Duplication** | | | |
| **Algorithm Efficiency** | | | |
| **Security** | | | |
| **Performance** | | | |
| **Design Pattern Fitness** | | | |
| **Architecture Conformance** | | | |
| **Technology Fitness** | | | |
| **Test Coverage & Quality** | | | |
| **Overall** | | | |

**Scoring guide**:
- **9-10**: Exemplary — use as reference implementation for the team
- **7-8**: Solid — minor issues, safe to ship
- **5-6**: Concerning — address HIGH findings before merging
- **3-4**: Significant problems — rework required
- **1-2**: Fundamentally unsound — major redesign needed

---

## Findings Summary Format

```
FINDINGS SUMMARY
================
CRITICAL: <n>  ← must fix immediately
HIGH:     <n>  ← must fix before merge
MEDIUM:   <n>  ← should fix
LOW:      <n>  ← nice to have
POSITIVE: <n>  ← good practices to keep

Top 3 risks:
1. <highest impact finding>
2. <second highest>
3. <third highest>
```

---

## Improvement Roadmap — Action Tiers

Group all findings into action tiers:

### Tier 1 — Fix Now (blocks merge/release)

All CRITICAL + HIGH findings, ordered by effort (quick wins first).

| # | Finding | Dimension | File:Line | Effort | Fix Description |
|---|---|---|---|---|---|

### Tier 2 — Fix This Sprint

MEDIUM findings that reduce tech debt or prevent future bugs.

| # | Finding | Dimension | File:Line | Effort | Fix Description |
|---|---|---|---|---|---|

### Tier 3 — Schedule for Later

LOW findings and structural improvements.

| # | Finding | Dimension | File:Line | Effort | Fix Description |
|---|---|---|---|---|---|

---

## Refactoring Plan Template (per Tier 1 finding)

```
REFACTORING: <Finding title>
  Current:     <what the code does now, with file:line>
  Target:      <what it should do>
  Steps:
    1. <step with specific file and change>
    2. <step>
    3. <step>
  Tests:       <what tests to add/modify to verify the refactoring>
  Risk:        <what could break>
  Verify:      <how to confirm the refactoring is correct>
```

---

## Final Report Header Template

```markdown
# Code Audit: <target name>
**Date:** <today>
**Scope:** <files/modules reviewed>
**Quality Score:** <overall>/10
**Findings:** <n> CRITICAL, <n> HIGH, <n> MEDIUM, <n> LOW, <n> POSITIVE

## Action Tracker
| # | Finding | Severity | Dimension | Status | Owner | Notes |
|---|---|---|---|---|---|---|
```

Set all statuses to `PENDING`.

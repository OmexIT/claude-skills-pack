# Code Audit - Report Templates

Load this for the Evidence Manifest (end of Phase 1) and for Phases 3 to 5 of `code-audit`.

---

## Evidence Manifest

Include it verbatim in the final report. Write "n/a" or "absent" rather than dropping a line.

```
EVIDENCE MANIFEST - <target>
  Files:          <n> in scope ({<lang>: <n>}), <n> read (<%>; sampling rationale if partial)
  Tests read:     <n>; test commands run: <command -> result>
  Callers:        <n> reverse-import sites outside the target
  API surface:    <n> REST / <n> events / <n> jobs / <n> CLI
  Git (30d):      <n> commits, <n> contributors, hotspots: <file (n)>, open PRs touching target
  Stack:          <language + version>, <framework + version>, <test stack>, <build tool>
  Conventions:    [AGENTS.md, CLAUDE.md, lint configs, ArchUnit, ADRs] or "none found"
  Research:       [library @ version -> source URL -> insight], advisories checked
  Prior audits:   <paths>; reopened findings <n>; never addressed <n>
  Blockers:       <anything that limits reliability of the review>
```

---

## Quality Scorecard

| Dimension | Score (1-10) | Findings (C/H/M/L) | Key Issue |
|---|---|---|---|
| **Code Smells & Clean Code** | | | |
| **SOLID Compliance** | | | |
| **Duplication** | | | |
| **Algorithm Efficiency** | | | |
| **Security** | | | |
| **Performance & Reliability** | | | |
| **Design Pattern Fitness** | | | |
| **Architecture Conformance** | | | |
| **Technology Fitness** | | | |
| **Test Coverage & Quality** | | | |
| **Overall** | | | |

Mark a dimension N/A with the reason when it did not apply. Scores follow the evidence; a high
score with no findings is valid when the manifest shows what was checked.

- **9-10**: Exemplary - use as a reference implementation
- **7-8**: Solid - minor issues, safe to ship
- **5-6**: Concerning - address HIGH findings before merging
- **3-4**: Significant problems - rework required
- **1-2**: Fundamentally unsound - redesign needed

---

## Findings Summary

```
FINDINGS SUMMARY
CRITICAL: <n>   HIGH: <n>   MEDIUM: <n>   LOW: <n>   POSITIVE: <n>
Top risks:
1. <highest impact finding>
2. <next>
Not reviewed / evidence gaps: <list>
```

---

## Improvement Roadmap - Action Tiers

| Tier | Contents |
|---|---|
| 1 - Fix now (blocks merge or release) | CRITICAL and HIGH, quick wins first |
| 2 - This sprint | MEDIUM findings that prevent future bugs or reduce real debt |
| 3 - Schedule | LOW findings and structural improvements |

Each tier uses:

| # | Finding | Dimension | File:Line | Effort | Fix Description |
|---|---|---|---|---|---|

---

## Refactoring Plan (per Tier 1 finding)

```
REFACTORING: <Finding title>
  Current:  <what the code does now, with file:line>
  Target:   <what it should do>
  Steps:    1. <specific file and change>  2. ...
  Tests:    <behavior tests to add or change>
  Risk:     <what could break>
  Verify:   <command or check that confirms it>
```

---

## Final Report Header

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

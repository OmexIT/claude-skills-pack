# Integration Checklist

Per-class audit items. Each item is yes/no. Score: `(passed / total) * 10`, rounded. Anything below 9 needs upgrade.

---

## Universal checks (all classes EXCEPT meta-class integrator)

| # | Check | Pass condition | Fix if failing |
|---|---|---|---|
| U1 | Has "Before You Start — Superpowers Workflow" H2 section | Section exists with exact title | Insert rendered block from templates/blocks.md |
| U2 | Section is positioned correctly | After title, before first numbered section (`## 0.` or `## 1.`) | Move the section |
| U3 | References the correct superpowers skills for the classified class | Every required superpowers skill for the class is named in the block | Re-render block from template |
| U4 | Output contract handoff field references superpowers chain | `handoff:` mentions `superpowers:verification-before-completion` AND (for code-gen classes) `superpowers:requesting-code-review` | Append superpowers chain to handoff field |
| U5 | Has an "Anti-patterns" or equivalent section | Section exists listing "never do" rules | Already skill-specific, no auto-fix — flag for manual addition |

---

## code-generator class checks

| # | Check | Pass condition |
|---|---|---|
| CG1 | Pre-flight lists all 4 phases | brainstorming, writing-plans, using-git-worktrees, test-driven-development all mentioned in order |
| CG2 | Execution mentions subagent-driven-development OR dispatching-parallel-agents | Either skill is referenced in the execute phase |
| CG3 | Post-flight lists verification-before-completion AND requesting-code-review | Both superpowers skills referenced |
| CG4 | TDD marked rigid/mandatory | Text contains "MANDATORY", "rigid skill", "don't skip", or "non-negotiable" near TDD |

---

## code-generator-money-critical class checks

Includes all `code-generator` checks (CG1-CG4) PLUS:

| # | Check | Pass condition |
|---|---|---|
| CGM1 | All steps marked MANDATORY | Every pre-flight step uses the word MANDATORY |
| CGM2 | Has a mandatory-rules block | Contains explicit "refuse to proceed" or "refuse politely" rule for money operations |
| CGM3 | Verification mentions reconciliation/invariant check | Text references reconciliation query, invariant, SUM == balance, or similar |
| CGM4 | Verification requires paste-actual-output | Text contains "paste output", "paste actual", or "claims without command output are rejected" |

---

## code-generator-sql class checks

| # | Check | Pass condition |
|---|---|---|
| CGS1 | Pre-flight lists brainstorming (for risky) + writing-plans (for multi-phase) | Both phases referenced with the correct context |
| CGS2 | TDD replaced with verification-SQL-first | Section explicitly says "write verification SQL first" or "replaces TDD" |
| CGS3 | Verification mentions rollback test | Text contains "test rollback" or "run rollback" |
| CGS4 | Destructive-op safety gate | Text references explicit confirmation requirement for DROP/rename |

---

## reviewer class checks

| # | Check | Pass condition |
|---|---|---|
| R1 | Pre-flight is explicitly empty | Text says "nothing — reviewers can be invoked directly" or equivalent |
| R2 | Post-flight chains systematic-debugging per finding | superpowers:systematic-debugging referenced as post-finding action |
| R3 | Findings-first rule explicit | Text contains "never produce fixes inline" or equivalent |
| R4 | Handoff chains to writing-plans + requesting-code-review + finishing-a-development-branch | All three superpowers skills referenced |

---

## refactor class checks

| # | Check | Pass condition |
|---|---|---|
| RF1 | Pre-flight lists all 4 phases | brainstorming, writing-plans, test-driven-development (characterization), using-git-worktrees |
| RF2 | Explicitly mentions characterization tests | Text contains "characterization tests FIRST" or equivalent |
| RF3 | Verification requires characterization tests still pass | Text contains "still pass" or "no regression" |
| RF4 | Post-flight lists requesting-code-review | Referenced |

---

## debugger class checks

| # | Check | Pass condition |
|---|---|---|
| DBG1 | Pre-flight names systematic-debugging as primary | Text contains "primary workflow" or "this IS the primary" near systematic-debugging |
| DBG2 | TDD explicitly says regression test FIRST | Text contains "regression test FIRST" or "reproduction test FIRST" |
| DBG3 | Verification checks BOTH regression test + original bug | Text mentions both "regression test passes" AND "original bug no longer reproduces" |

---

## planner class checks

| # | Check | Pass condition |
|---|---|---|
| P1 | Pre-flight lists brainstorming (mandatory) | Referenced as MANDATORY |
| P2 | Pre-flight lists writing-plans conditionally | Referenced with "if this document is a plan" qualifier |
| P3 | Post-flight lists verification-before-completion | Referenced as quality gate |
| P4 | Does NOT include TDD, worktrees, or requesting-code-review | Absence check — these are wrong for planner class |

---

## Scoring

Total items per class:
- code-generator: 5 (U) + 4 (CG) = 9 items → each item worth ~1.1 points
- code-generator-money-critical: 5 (U) + 4 (CG) + 4 (CGM) = 13 items → each worth ~0.77 points
- code-generator-sql: 5 (U) + 4 (CGS) = 9 items → each worth ~1.1 points
- reviewer: 5 (U) + 4 (R) = 9 items → each worth ~1.1 points
- refactor: 5 (U) + 4 (RF) = 9 items → each worth ~1.1 points
- debugger: 5 (U) + 3 (DBG) = 8 items → each worth 1.25 points
- planner: 5 (U) + 4 (P) = 9 items → each worth ~1.1 points

Threshold: score ≥ 9 → compliant. score < 9 → needs upgrade.

## Audit output format

```
📋 AUDIT — <skill-name> [<class>]
    Universal:
      U1 ✅ Before You Start section present
      U2 ✅ Positioned correctly
      U3 ❌ Missing superpowers:using-git-worktrees (required for class)
      U4 ⚠️  handoff field missing verification-before-completion
      U5 ✅ Anti-patterns section present
    Class (<class>):
      CG1 ❌ Pre-flight missing writing-plans
      CG2 ✅ subagent-driven-development referenced
      CG3 ⚠️  verification-before-completion mentioned but requesting-code-review missing
      CG4 ❌ TDD not marked MANDATORY
    Score: 5/9 → 5.6/10 (needs upgrade)
    Fix actions:
      1. Insert updated "Before You Start" block from templates/blocks.md#code-generator
      2. Append superpowers chain to handoff field
```

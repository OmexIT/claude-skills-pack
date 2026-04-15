---
name: superpowers-integrator
description: >
  Use this skill whenever you need to audit or upgrade a custom skill's integration with the superpowers plugin workflow. ALWAYS trigger on: "integrate with superpowers", "upgrade skill integration", "audit my skill", "add superpowers workflow to X", "make this skill superpowers-aware", "check skill integration", "re-sync superpowers workflow", "refresh superpowers integration", "superpowers compliance check". Implicit triggers: user just created a new custom skill and wants it aligned with the superpowers development workflow; user wants to know whether an existing skill correctly routes through brainstorming/plans/TDD/verification/review; superpowers ships a new skill and existing custom skills need re-audit; user is maintaining a skills pack and wants a single source of truth for integration patterns.
  This is a META-skill: it reads other skills' SKILL.md files and produces either a findings report or an applied upgrade. It does NOT generate domain code. It is IDEMPOTENT — safe to re-run against the same skill at any time. The taxonomy (`references/skill-class-taxonomy.md`) and block templates (`templates/blocks.md`) are the single source of truth for "how custom skills integrate with superpowers". When superpowers adds a new skill, the user's learned a better pattern, or the skill has drifted, update the source-of-truth files and re-run this integrator against every custom skill — one command, full pack re-synced.
arguments: >
  One skill name, a path to a SKILL.md, or a glob of skill directories.
  Examples:
    /superpowers-integrator fintech-ledger               → audit+upgrade one skill
    /superpowers-integrator skills/*/                    → audit all skills in a dir
    /superpowers-integrator skills/temporal-workflow/SKILL.md  → direct file
    /superpowers-integrator --audit-only fintech-ledger  → audit without applying
context: fork
agent: general-purpose
effort: medium
---

# Superpowers Integrator: Custom Skill Upgrade Skill

Audits and upgrades custom skills to integrate with the superpowers plugin workflow. Re-runnable. Single source of truth lives in `references/skill-class-taxonomy.md` + `templates/blocks.md` — update those to change the pattern for every custom skill in one shot.

---

## 0. Input Handling

Parse `$ARGUMENTS`:

- **Single skill name** (`fintech-ledger`): look up under `skills/<name>/SKILL.md`
- **Direct path**: `skills/temporal-workflow/SKILL.md`
- **Glob of skill dirs**: `skills/*/` → run phases 1-5 for each target
- **`--audit-only` flag**: run phases 1-3 only, skip application
- **No args**: prompt the user for target(s)

For each target, run phases 1-5 in order.

Report per-target outcome:
```
──────────────────────────────────────────────
TARGET: <skill-name>
  Classification: <class>
  Audit score:    <current>/10 → <proposed>/10
  Status:         <no-change | upgrade-proposed | upgrade-applied | error>
──────────────────────────────────────────────
```

---

## 1. Classify the Skill

Read the target `SKILL.md`. Apply heuristics from `references/skill-class-taxonomy.md` **in priority order** (specific first):

1. **code-generator-money-critical** — name contains `ledger|payment|wallet|settlement|saga|escrow|balance` OR description mentions BigDecimal/double-entry/reconciliation/pgledger/blnk → class = `code-generator-money-critical`
2. **code-generator-sql** — name contains `migration|schema|changelog|liquibase|flyway|ddl` OR output contract produces `.sql` files → class = `code-generator-sql`
3. **reviewer** — description uses "review", "audit", "analyze" AND output contract produces markdown/findings (NOT code) → class = `reviewer`
4. **debugger** — description mentions "debug", "triage", "root cause", "reproduction", "bisection" → class = `debugger`
5. **refactor** — description uses "refactor", "restructure", "clean up" AND skill only edits existing files → class = `refactor`
6. **planner** — output contract produces only markdown/yaml/docs, no code file paths → class = `planner`
7. **code-generator** (default fallback) — output contract produces code files → class = `code-generator`

If a skill fits multiple classes, always pick the most specific (money-critical > sql > code-generator).
If a skill genuinely spans classes, report `AMBIGUOUS` and ask the user to confirm.

Report classification:
```
🔍 CLASSIFIED — <skill-name>
    Class:  <class>
    Reason: <which heuristic matched>
    Evidence:
      - name contains: <match>
      - description mentions: <match>
      - output contract: <match>
```

---

## 2. Audit

Load `references/integration-checklist.md`. Apply the universal checks (U1-U5) plus the class-specific checks to the target SKILL.md.

For each check:
- ✅ passed
- ❌ failed — record the fix action
- ⚠️ partial — record what's missing

Compute score: `(passed_items / total_items) * 10`, rounded.

Rule: any skill scoring < 9 needs upgrade. Skills scoring 9-10 are compliant; report and move on without changes.

Report:
```
📋 AUDIT — <skill-name> [<class>]
    Universal checks:
      U1 ✅ Has "Before You Start" H2 section
      U2 ❌ Section is positioned wrong (should be after title, before section 0)
      U3 ⚠️  References wrong superpowers skills for this class
      U4 ❌ handoff field doesn't mention verification-before-completion
      U5 ✅ Anti-patterns section present
    Class-specific checks (<class>):
      <CG1, CG2, ...>
    Score: <n>/10  (needs upgrade)
```

---

## 3. Propose Upgrade

If score ≥ 9, skip to phase 5 (report no-change).

Otherwise, load `templates/blocks.md` and extract the block matching the classified class. Substitute these placeholders:

| Placeholder | Source |
|---|---|
| `{SKILL_NAME}` | Target skill's `name:` frontmatter field |
| `{SKILL_PURPOSE}` | One-line purpose extracted from the skill's first paragraph or description sentence |
| `{DOMAIN_RIGOR_NOTE}` | Optional additional rigor note — leave empty unless the target skill has domain-specific hard rules worth preserving |

Then compute the diff:

**Insert** (always):
- The rendered block after the first `# Title` heading and before section `## 0.` (or the first `##` section)

**Modify** (if any of these fail):
- Output contract `handoff:` field — append reference to `superpowers:verification-before-completion` and `superpowers:requesting-code-review` as appropriate for the class
- Failure handling section — add reference to `superpowers:systematic-debugging` if missing
- Anti-patterns section — no changes here (already skill-specific)

Show the proposed diff to the user:
```
📝 PROPOSED UPGRADE — <skill-name>

  INSERT after line <n> (after title, before section 0):
  ──────────────────────────────────────────
  ## Before You Start — Superpowers Workflow

  <rendered block>
  ──────────────────────────────────────────

  MODIFY line <n> (handoff):
  - handoff: "<current>"
  + handoff: "<current + superpowers chain>"

  Apply? [yes/no/audit-only]
```

---

## 4. Apply

On user confirmation (`yes`):
- Use Edit tool to insert the "Before You Start" block
- Use Edit tool to modify `handoff:` line if needed
- Re-parse the SKILL.md and verify the frontmatter is still valid
- Re-run phase 2 audit and confirm score is now ≥ 9

On `audit-only` or `no`: report findings without applying and move on.

Report:
```
✅ UPGRADED — <skill-name>
    Class:  <class>
    Score:  <old> → <new>
    Files:  skills/<name>/SKILL.md
    Changes:
      - Inserted "Before You Start" block (<n> lines)
      - Modified handoff field
```

---

## 5. Re-run Contract

This skill is **idempotent**. Safe to re-run at any time. Use cases:

| Trigger | Action |
|---|---|
| New custom skill added | `/superpowers-integrator <new-skill>` |
| superpowers ships a new skill | Update `references/skill-class-taxonomy.md` and `templates/blocks.md`, then `/superpowers-integrator skills/*/` |
| User learns a better pattern | Update `templates/blocks.md`, then re-run against affected classes |
| Monthly maintenance check | `/superpowers-integrator skills/*/ --audit-only` to identify drift without applying |
| Single skill drifted | `/superpowers-integrator <skill>` to re-sync |

---

## 6. Continuous Improvement Loop

The intended workflow for keeping custom skills in sync with superpowers:

```
┌────────────────────────────────────────────────────┐
│ 1. Notice: a skill feels stale or superpowers new  │
└──────────────────┬─────────────────────────────────┘
                   ▼
┌────────────────────────────────────────────────────┐
│ 2. Edit the source of truth:                       │
│    - references/skill-class-taxonomy.md            │
│    - templates/blocks.md                           │
│    - references/integration-checklist.md           │
└──────────────────┬─────────────────────────────────┘
                   ▼
┌────────────────────────────────────────────────────┐
│ 3. Re-audit the pack:                              │
│    /superpowers-integrator skills/*/ --audit-only  │
└──────────────────┬─────────────────────────────────┘
                   ▼
┌────────────────────────────────────────────────────┐
│ 4. Review the findings, then apply:                │
│    /superpowers-integrator skills/*/               │
└──────────────────┬─────────────────────────────────┘
                   ▼
┌────────────────────────────────────────────────────┐
│ 5. Commit the pack + re-install to ~/.claude/      │
└────────────────────────────────────────────────────┘
```

**One source of truth. One command to re-sync. No drift.**

---

## 7. Output Contract

```yaml
produces:
  - type: "audit-report"
    format: "markdown"
    path: "claudedocs/superpowers-audit-<timestamp>.md"
    sections: [per_skill_audit, pack_summary, proposed_upgrades]
  - type: "skill-upgrade"
    format: "markdown-edit"
    paths: ["skills/<name>/SKILL.md"]
  handoff: "Write claudedocs/handoff-superpowers-integrator-<timestamp>.yaml — suggest: verify (run a sample skill invocation to confirm upgraded workflow), superpowers:requesting-code-review (for the pack if committed to git)"
```

---

## 8. Reference Files

| File | When to read |
|---|---|
| `references/skill-class-taxonomy.md` | Classifying a skill, adding a new class, updating class workflows |
| `references/integration-checklist.md` | Running the audit phase |
| `templates/blocks.md` | Rendering the "Before You Start" block for a classified skill |

## 9. Anti-patterns (this skill refuses these)

- Modifying a skill's domain content (section 1 onward) — this skill ONLY inserts the "Before You Start" block and updates handoff. Never touches domain logic.
- Classifying a skill as code-generator when it's money-critical — always pick the most specific class.
- Applying upgrades silently without showing the diff — always print the diff and wait for confirmation (unless `--apply-all` is explicitly passed).
- Running on a skill that doesn't have valid frontmatter — abort and report parse error.
- Overwriting existing "Before You Start" content without a re-audit — always re-audit first; only upgrade if score < 9.

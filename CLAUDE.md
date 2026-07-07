# garage plugin (claude-skills-pack)

## Overview
Single-plugin Claude Code marketplace delivering a 12-skill engineering copilot: a 7-verb
workflow spine (spec → plan → build → audit → e2e → ship, plus debug) and 5 domain-law skills
(ledger, temporal, migrations, spring-api, igaming-ui), with 3 lifecycle hooks. Rebuilt
2026-07-07 from usage evidence; the previous 48-skill generation is preserved at git tag
`pre-redesign` (branch `archive/v1`).

## Structure
```
.claude-plugin/        marketplace.json + plugin.json (bump version on every change)
skills/<name>/         SKILL.md (+ references/ for heavy knowledge, scripts/ for tools)
hooks/                 hooks.json + 3 python hooks (stdin JSON protocol)
docs/                  non-loaded knowledge: global-CLAUDE.md (canonical), ops.md,
                       frontend-mobile-defaults.md
scripts/usage-audit.py transcript miner for the quarterly usage review
```

## Skill format rules
- `name` matches directory name (kebab-case). Frontmatter: `name`, `description`, optional `argument-hint`.
- Description starts "Use when…", states triggering conditions ONLY — never summarize the
  skill's workflow (Claude would follow the summary and skip the body). Keep ≤500 chars.
- Body ≤~60 lines. Heavy knowledge goes in `references/`, loaded on demand.
- Banned ceremony (the old pack's failure modes): output-contract YAML, handoff manifests,
  "Learning & Memory" sections, "Workflow context" webs, model-routing tables, multi-agent
  rosters, ASCII wave diagrams.
- Every `references/` path cited in a SKILL.md must exist — grep before committing.

## Rules
- Never commit `claudedocs/` (local working files, gitignored).
- The pack stays context-neutral: no attribution footers, no branch assumptions, no
  credentials. Per-repo policy lives in each project's CLAUDE.md (`## Ship policy` block).
- Hooks: read JSON on stdin; block = exit 2 + stderr; warn = stderr + exit 0; side-effects
  exit 0 silently.
- Quarterly: run `scripts/usage-audit.py`; delete skills unused for 2 quarters; when an
  official plugin reaches parity with a skill, delete the skill.
- New domain skills require ≥3 real uses of the pattern first — no speculative skills.

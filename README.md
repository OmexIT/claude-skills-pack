# garage — engineering copilot plugin for Claude Code

A 12-skill plugin encoding one engineer's actual workflow and house engineering law, rebuilt
2026-07-07 from usage evidence (2,597 real prompts) after the previous 48-skill generation
recorded zero invocations. The old pack lives at tag `pre-redesign`.

## Install

```bash
claude plugin marketplace add OmexIT/claude-skills-pack   # or the local repo path
# in Claude Code: /plugin → enable "garage" → restart session
```

Skills, references, and hooks all ship together — no copy scripts.

## The skills

**Workflow spine** — mirrors the real loop, each step optional:

| Skill | Use when |
|---|---|
| `spec` | Defining/changing WHAT to build; PRD create/update; challenging scope |
| `plan` | Turning an approved spec or ticket into a sliced, verifiable plan doc in `docs/` |
| `build` | Executing a plan ("implement docs/…plan.md", "start slice SP-2b") |
| `audit` | Reviewing code/diffs/docs against house standards; expert panels |
| `e2e` | Live verification: boot stack, newman, Playwright, DB checks — evidence, not claims |
| `ship` | Commit / PR / MR / branch promotion per each repo's delivery policy |
| `debug` | Any bug or unexpected behavior, before proposing fixes |

**Domain law** — auto-triggers on subject matter:

| Skill | Carries |
|---|---|
| `ledger` | Double-entry invariants, idempotency key grammar, Blnk + pgledger contracts |
| `migrations` | TSID PKs, audit columns, RLS recipe, zero-downtime rules, throttled backfills |
| `temporal` | SAGA compensation, retry profiles, versioning, failure-mode table |
| `spring-api` | Response envelope, RFC 9457, package-by-feature layout, cursor pagination |
| `igaming-ui` | Odds/betslip/live-state patterns, data-testid contract |

**Hooks** (`hooks/hooks.json`): destructive-command blocker, sensitive-file warning,
Spotless/Prettier autoformat.

## The golden path

```
spec ──► plan ──► build ──► audit ──► e2e ──► ship
                    ▲                           │
                    └────────── debug ◄─────────┘
```

Plans live in each repo's `docs/…/plans/` with checkboxes as durable session state.
Per-repo delivery rules (branch flow, gh vs glab, attribution policy, verify commands) live
in that repo's CLAUDE.md under a `## Ship policy` block — the pack stays context-neutral.

## Global rules

`docs/global-CLAUDE.md` is the canonical copy of `~/.claude/CLAUDE.md` — the standing
voice/simplicity/testing/verification rules distilled from recurring corrections.

## Evolution policy

- Quarterly: `python3 scripts/usage-audit.py` — skills unused for 2 quarters get deleted.
- When an official plugin reaches parity with a skill here, delete the skill the same week.
- New domain skills require ≥3 real uses of the pattern first. No speculative skills.
- Bump `.claude-plugin/plugin.json` on every change.

## License

MIT — see LICENSE.

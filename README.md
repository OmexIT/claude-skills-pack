# garage: engineering copilot for Claude Code and Codex

A 12-skill plugin encoding one engineer's actual workflow and house engineering law, rebuilt
2026-07-07 from usage evidence (2,597 real prompts) after the previous 48-skill generation
recorded zero invocations. The old pack lives at tag `pre-redesign`.

## Install

### Claude Code

```bash
claude plugin marketplace add OmexIT/claude-skills-pack   # or the local repo path
# in Claude Code: /plugin, enable "garage", restart session
```

### Codex

```bash
codex plugin marketplace add OmexIT/claude-skills-pack   # or the local repo path
codex plugin add garage@garage
# start a new Codex thread so the installed skills are loaded
```

Both clients install the same 12 skills, references, and skill scripts. The three lifecycle
hooks use Claude Code's hook protocol and are loaded only by Claude Code; Codex's plugin
manifest intentionally does not declare them.

## The skills

**Workflow spine** (mirrors the real loop; each step optional):

| Skill | Use when |
|---|---|
| `spec` | Defining or changing WHAT to build; PRD create/update; challenging scope |
| `plan` | Turning an approved spec, ticket, or explicit request into a sliced, verifiable plan doc in `docs/` |
| `build` | Executing a plan ("implement docs/...plan.md", "start slice SP-2b") |
| `audit` | Reviewing code, diffs, or docs against house standards; expert panels |
| `e2e` | Live verification: boot the stack, newman, Playwright, DB checks. Evidence, not claims |
| `ship` | Commit / PR / MR / branch promotion per each repo's delivery policy |
| `debug` | Any bug or unexpected behavior, before proposing fixes |

**Domain law** (auto-triggers on subject matter):

| Skill | Carries |
|---|---|
| `ledger` | Double-entry invariants, idempotency key grammar, Blnk + pgledger contracts |
| `migrations` | TSID PKs, audit columns, RLS recipe, zero-downtime rules, throttled backfills |
| `temporal` | SAGA compensation, retry profiles, versioning, failure-mode table |
| `spring-api` | Response envelope, RFC 9457, package-by-feature layout, cursor pagination |
| `igaming-ui` | Odds/betslip/live-state patterns, accessible selector contract |

**Claude Code hooks** (`plugins/garage/hooks/hooks.json`): destructive-command blocker,
sensitive-file warning, Prettier autoformat (web files only; Java/Spotless runs once in the
`ship` gate).

## The golden path

```
spec ──► plan ──► build ──► audit ──► e2e ──► ship
                    ▲                           │
                    └────────── debug ◄─────────┘
```

Plans live in each repo's `docs/.../plans/` with checkboxes as durable session state.

## Usage samples

Skills fire on natural phrasing. Force one explicitly with `/garage:<skill>` in Claude Code
or `$garage:<skill>` in Codex.

**Single skills**

```
"should we build bulk payouts, or does the batch API already cover it?"   -> spec (challenge: keep/shrink/kill)
"write the PRD for payment links"                                         -> spec (create)
"sync the PRD with what we actually built"                                -> spec (update, drift check)
"plan the wallet top-up feature from docs/prd/topups.md"                  -> plan (sliced plan doc)
"implement docs/plans/2026-07-08-topups-plan.md"                          -> build
"start slice 2b"                                                          -> build (resumes at that slice)
"review this diff against our standards"                                  -> audit
"audit the payments module, include a DDD expert"                         -> audit (expert panel)
"simplification sweep: what can we remove from this product?"             -> audit (removal-first, whole app)
"run and test orders end to end, api and ui"                              -> e2e (newman + Playwright + DB proof)
"why is the balance negative after a refund?"                             -> debug (diagnosis only, no fix yet)
"commit and merge to release-candidate"                                   -> ship (repo's branch policy)
"promote develop to main"                                                 -> ship (promotion PR)
```

Domain skills load themselves when the work touches their subject: a hold/void flow pulls
`ledger`, a new column pulls `migrations`, a saga with compensation pulls `temporal`, a new
endpoint pulls `spring-api`, a betslip component pulls `igaming-ui`.

**A feature, end to end**

```
"challenge the scope of X"        spec   is the smallest version still worth building?
"write the PRD for X"             spec   AC + edge cases + non-goals
"plan X from the PRD"             plan   vertical slices, each with its verification command
"implement the plan"              build  slice by slice, checkboxes updated as it goes
"audit the diff"                  audit  evidence-mandatory findings, then "fix all"
"run X end to end"                e2e    real output, screenshots, zero-row ledger checks
"ship it"                         ship   format, verify, commit, PR/MR per repo policy
```

**A bug**

```
"debug: refunds double-post when the provider times out"   debug -> root cause + failing repro
"fix it"                                                   build -> minimal fix + regression test
"ship to develop"                                          ship
```

**A product review of a whole platform**

```
"Product review: audit docs/prd with a product strategy expert and a domain
expert, validate each PRD against the implementation for drift, challenge the
scope of every major module (keep/shrink/kill with reasoning), then walk the
core user flows live. Ranked findings only, fix nothing."
```

**Resuming after a context reset**

```
"what's pending?"          answered from the plan doc's checkboxes, no memory ritual
"continue the plan"        build picks up at the first unchecked slice
```

## Per-repo ship policy

Delivery rules stay out of the plugin: each repo's own AGENTS.md or CLAUDE.md carries a
`## Ship policy` block that the `ship` skill reads. Template:

```markdown
## Ship policy
- CLI: glab                                # or gh
- Flow: feature -> release-candidate; promotion by MR
- Merge: MR only, peer review is manual    # or: merge allowed after checks pass
- Attribution: none                        # never mention AI in commits/PRs
- Verify: mvn -q verify && newman run postman/regression.json
- Extras: QA testing note on the ticket (how to test the API, nothing more)
```

## Global rules

`docs/global-CLAUDE.md` is an optional reference for personal Claude Code instructions: standing
voice, simplicity, testing, and verification rules. It is repository maintenance material, not
part of either installed plugin, and local global instructions may deliberately differ.

## Evolution policy

- Quarterly: run `python3 scripts/usage-audit.py`; skills unused for two quarters get deleted. The
  default run is read-only. Use `--corpus-dir <private-path>` only when raw prompt excerpts are
  genuinely needed, and never commit that sensitive output.
- When an official plugin reaches parity with a skill here, delete the skill the same week.
- New domain skills require at least 3 real uses of the pattern first. No speculative skills.
- Bump both `plugins/garage/.claude-plugin/plugin.json` and
  `plugins/garage/.codex-plugin/plugin.json` on every plugin change.

## License

MIT, see LICENSE.

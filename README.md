# garage: engineering skill pack for Claude Code and Codex

48 skills covering product discovery, specs and design, implementation from a spec, review,
live verification, operations, and fintech domain work. Version 2.0.0 restores the original
pack (tag `pre-redesign`) in place of the 12-skill rebuild (last released as 1.3.0), ported so
the same files install in both Claude Code and Codex.

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

Both clients install the same skills, references, templates, and scripts. The three lifecycle
hooks use Claude Code's hook protocol and load only in Claude Code.

## Using the skills

Skills fire on natural phrasing ("write the PRD for payment links", "implement this spec",
"audit the payments module"). To force one, use `/garage:<skill>` in Claude Code or
`$garage:<skill>` in Codex. Skills that are marked manual-only below never fire on their own in Codex.

Orchestrating skills describe delegation (agent rosters, parallel waves, worktrees, model
labels) in Claude Code notation. `plugins/garage/references/cross-client.md` says how each of
those maps to Codex, which runs the same roles with subagents when available or sequentially.

## The skills

**Product discovery and strategy**

| Skill | Use when |
|---|---|
| `opportunity-assessment` | Deciding whether a feature is worth building |
| `competitive-analysis` | Comparing competitors and market positioning |
| `go-to-market` | Planning a launch: messaging, channels, enablement |

**Planning and requirements**

| Skill | Use when |
|---|---|
| `prd` | Writing a PRD, or surgically updating one to match what was built |
| `design-doc` | Writing or reviewing a system design doc or RFC |
| `adr` | Recording an architecture decision and its alternatives |
| `user-flow` | Mapping user journeys, decision points, and error states |
| `flow-map` | Mapping every system path before coding; each path becomes a test case |
| `ui-design` | Producing wireframes, tokens, component specs, and a11y notes from a spec |
| `api-design` | Designing or reviewing an API contract |
| `data-design` | Designing a data layer across PostgreSQL, MongoDB, Elasticsearch, Typesense |
| `search-design` | Designing Elasticsearch or Typesense search |
| `infra-design` | Designing Docker, Kubernetes, Terraform, and CI/CD |
| `ticket-breakdown` | Breaking a PRD or design into epics and tickets |
| `experiment-design` | Designing an A/B test or staged rollout |
| `decision-matrix` | Weighing options against criteria |
| `migration-plan` | Planning a database, API, or infrastructure migration |

**Implementation and verification**

| Skill | Use when |
|---|---|
| `spec-to-impl` | Implementing a spec end to end with a role-based agent team |
| `verify-impl` | Verifying an implementation live: API, database, Playwright UI, mobile |
| `mobile-dev` | Working on Flutter, React Native, or Android apps |
| `temporal-workflow` | Building Temporal workflows in Java: SAGA, retries, versioning |
| `fintech-ledger` | Double-entry ledger operations on Blnk or pgledger |
| `api-first` | Scaffolding a Spring Boot endpoint from OpenAPI |
| `db-migration` | Writing Liquibase or Flyway migrations with house conventions |
| `finalize` | Lint, test, clean up, commit, and open the PR |

**Quality and review**

| Skill | Use when |
|---|---|
| `spec-panel` | Expert-panel review of a spec before implementation |
| `code-audit` | Multi-dimensional review of existing code |
| `arch-review` | Checking clean-architecture invariants in a Java/Spring module |
| `evidence-review` | Default-to-rejection final gate that demands proof |
| `test-plan` | Writing a risk-based test plan |
| `security-review` | Threat-model-lite review of a feature or PR |
| `performance-review` | Performance and reliability review |
| `ux-review` | Heuristic, accessibility, and cognitive-walkthrough review |
| `docs-review` | Reviewing documentation for clarity and correctness |
| `metrics-review` | Auditing analytics instrumentation and data quality |
| `tech-debt-assessment` | Inventorying and prioritizing technical debt |
| `debug-triage` | Triaging a bug into a reproduction, hypotheses, and a minimal fix |

**Release and operations**

| Skill | Use when |
|---|---|
| `release-notes` | Drafting release notes (manual-only) |
| `monitoring-plan` | Designing metrics, alerts, dashboards, and SLOs |
| `runbook` | Writing an operational runbook |
| `incident-response` | Running an active incident (manual-only) |
| `postmortem` | Writing a blameless postmortem (manual-only) |

**Team and communication**

| Skill | Use when |
|---|---|
| `stakeholder-update` | Writing a status update for leadership (manual-only) |
| `sprint-retro` | Running a retrospective (manual-only) |
| `onboarding-doc` | Writing an onboarding guide |
| `linkedin-post` | Drafting a LinkedIn post |

**Supporting skills**

| Skill | Use when |
|---|---|
| `handoff` | Chaining skills through `claudedocs/handoff-*.yaml` manifests |
| `repo-conventions` | Repos with no conventions in AGENTS.md or CLAUDE.md; its references are placeholders until filled |

**Claude Code hooks** (`plugins/garage/hooks/hooks.json`): destructive-command blocker,
sensitive-file warning, Prettier autoformat (web files only; Java formatting runs in the
`finalize` lint step).

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

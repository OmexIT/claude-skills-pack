# Claude Code Skills Pack

## Project Overview
A collection of 52 Claude Code skills covering the full software development lifecycle. Skills range from lightweight methodology guides (~80 lines) to comprehensive multi-agent orchestrators (~1500 lines). Skills that overlap with official Claude Code plugins (figma, code-review, claude-md-management, frontend-design) have been removed in favor of the official plugin equivalents. Every code-generation skill is wired into the [superpowers](https://github.com/anthropics/claude-plugins-official) development workflow via a "Before You Start" block that routes through brainstorming → plans → TDD → verification → review; the `superpowers-integrator` meta-skill keeps all custom skills in sync as superpowers evolves.

## Structure
```
skills/
├── <skill-name>/
│   ├── SKILL.md              # Required: frontmatter + instructions
│   ├── agents/               # Optional: agent persona definitions
│   ├── references/           # Optional: reference documentation
│   └── templates/            # Optional: output templates
├── INDEX.md                  # Categorized skill index + chaining map
```

## Skill Categories
- **Discovery** (3): opportunity-assessment, competitive-analysis, go-to-market
- **Planning** (14): prd, design-doc, adr, user-flow, flow-map, ui-design, api-design, data-design, search-design, infra-design, ticket-breakdown, experiment-design, decision-matrix, migration-plan
- **Implementation** (8): spec-to-impl, verify-impl, mobile-dev, finalize, temporal-workflow, fintech-ledger, api-first, db-migration
- **Quality** (12): evidence-review, spec-panel, code-audit, arch-review, test-plan, security-review, performance-review, ux-review, docs-review, metrics-review, tech-debt-assessment, debug-triage
- **Release** (5): release-notes, monitoring-plan, runbook, incident-response, postmortem
- **Communication** (4): stakeholder-update, sprint-retro, onboarding-doc, linkedin-post
- **Auto-guidance** (2): repo-conventions, handoff
- **Meta / Custom Skill Maintenance** (1): superpowers-integrator

## Superpowers Integration
All code-generation skills include a "Before You Start — Superpowers Workflow" section chaining through brainstorming → writing-plans → using-git-worktrees → test-driven-development → (invoke skill) → verification-before-completion → requesting-code-review. Skill-class-specific variants live in `skills/superpowers-integrator/templates/blocks.md` (code-generator, code-generator-money-critical, code-generator-sql, reviewer, refactor, debugger, planner). To re-sync the whole pack after superpowers or templates change, run `/superpowers-integrator skills/*/`.

## Conventions

### Skill File Format
Every SKILL.md follows this frontmatter:
```yaml
---
name: skill-name           # kebab-case, matches directory name
description: >             # Triggers auto-invocation
argument-hint: "[context]" # Autocomplete hint
---
```

### Thin Skills (~80 lines)
Standard sections: What I'll do → Inputs → How I'll think → Anti-patterns → Quality bar → Workflow context → Output contract

### Comprehensive Skills (500+ lines)
Multi-agent orchestrators (spec-to-impl, verify-impl, ui-design) with: agent rosters, execution phases, wave-based dispatch, evidence-based quality gates.

### Output Contracts
Every skill ends with an `## Output contract` section defining:
```yaml
produces:
  - type: "<artifact type>"
    format: "markdown"
    path: "claudedocs/<feature>-<skill>.md"
    sections: [<key sections>]
```

### Handoff Protocol
Skills chain via `claudedocs/handoff-<skill>-<timestamp>.yaml` artifacts. The `handoff` auto-guidance skill defines the schema.

## Rules
- Never commit `claudedocs/` — it's in .gitignore (local working files only)
- Skill names are kebab-case, must match directory name
- All thin skills must have an output contract section
- New skills must be added to `skills/INDEX.md`
- Manual-only skills use `disable-model-invocation: true`
- Auto-guidance skills use `user-invocable: false`

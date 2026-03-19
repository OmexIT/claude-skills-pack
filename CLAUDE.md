# Claude Code Skills Pack

## Project Overview
A collection of 45 Claude Code skills covering the full software development lifecycle. Skills range from lightweight methodology guides (~80 lines) to comprehensive multi-agent orchestrators (~700 lines).

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
- **Implementation** (4): spec-to-impl, verify-impl, mobile-dev, finalize
- **Quality** (12): pr-review, evidence-review, spec-panel, code-audit, test-plan, security-review, performance-review, ux-review, docs-review, metrics-review, tech-debt-assessment, debug-triage
- **Release** (5): release-notes, monitoring-plan, runbook, incident-response, postmortem
- **Communication** (4): stakeholder-update, sprint-retro, onboarding-doc, linkedin-post
- **Setup** (1): claude-md
- **Auto-guidance** (2): repo-conventions, handoff

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

# Claude Code Skills Pack

**30 ready-to-use skills for Claude Code** that cover the entire product development lifecycle — from discovery and planning through quality, release, operations, and team communication.

Each skill teaches Claude *how to think* about a problem, not just what to output. They include methodology, anti-patterns to avoid, quality bars, and templates — so you get consistently high-quality artifacts every time.

---

## What are Claude Code Skills?

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) is Anthropic's AI coding agent that runs in your terminal and IDE. **Skills** are reusable prompt packages that extend Claude Code with domain-specific expertise. They're invoked as slash commands:

```
> /prd Build a collaborative document editor
> /security-review Check the auth middleware
> /ticket-breakdown Break the design doc into engineering tickets
```

When you invoke a skill, Claude loads the methodology, applies structured thinking, and produces output using professional templates — turning a one-line request into a comprehensive, review-ready artifact.

---

## What's Included

### Product Discovery & Strategy
| Skill | What it does |
|-------|-------------|
| `/opportunity-assessment` | Evaluate whether to build a feature — cost, benefit, risk, strategic alignment |
| `/competitive-analysis` | Structured competitor landscape, feature comparison, differentiation opportunities |
| `/go-to-market` | Launch plan with messaging, audience segmentation, enablement, and measurement |

### Planning & Requirements
| Skill | What it does |
|-------|-------------|
| `/prd` | Product requirements document — problem, goals, users, scope, metrics, rollout |
| `/design-doc` | System design / RFC — architecture, data model, APIs, alternatives, rollout |
| `/adr` | Architecture decision record — context, decision, alternatives, consequences |
| `/user-flow` | User journey mapping — states, decisions, error recovery, accessibility |
| `/api-design` | API design review — naming, versioning, error contracts, pagination |
| `/ticket-breakdown` | Break specs into epics + engineering tickets with acceptance criteria |
| `/experiment-design` | A/B test or staged rollout — hypothesis, metrics, guardrails, decision rules |
| `/decision-matrix` | Weighted criteria evaluation for complex choices |
| `/migration-plan` | Safe database/API/infrastructure migration with rollback at every stage |

### Quality & Review
| Skill | What it does |
|-------|-------------|
| `/pr-review` | Structured code review — correctness, security, performance, testing, UX |
| `/test-plan` | Risk-based test strategy with coverage matrix and release checklist |
| `/security-review` | Threat-model-lite with OWASP-aligned checks and exploitation-based prioritization |
| `/performance-review` | Performance analysis — hot paths, query patterns, caching, measurement plan |
| `/ux-review` | Heuristic evaluation + WCAG accessibility audit + cognitive walkthrough |
| `/docs-review` | Documentation clarity, correctness, and consistency review |
| `/metrics-review` | Analytics instrumentation and data quality audit |
| `/tech-debt-assessment` | Inventory, categorize, and prioritize technical debt by cost-of-delay |

### Release & Operations
| Skill | What it does |
|-------|-------------|
| `/release-notes` | Release notes for users and operators — highlights, breaking changes, rollback |
| `/monitoring-plan` | Observability strategy — golden signals, SLOs, alerts, dashboards, logging |
| `/runbook` | Operational runbook — deployment, scaling, failure recovery, escalation |
| `/incident-response` | Incident workflow — severity, roles, stabilization, status updates |
| `/postmortem` | Blameless postmortem — timeline, root causes, contributing factors, action items |

### Team & Communication
| Skill | What it does |
|-------|-------------|
| `/stakeholder-update` | Structured status update — progress, risks, blockers, decisions needed |
| `/sprint-retro` | Sprint retrospective — patterns, wins, improvements, SMART action items |
| `/onboarding-doc` | New team member guide — setup, architecture, tribal knowledge, first task |

### Auto-guidance
| Skill | What it does |
|-------|-------------|
| `repo-conventions` | Repo-specific conventions applied automatically (not a slash command) |

---

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Works with: **Terminal CLI**, **VS Code extension**, **JetBrains plugin** (IntelliJ, PyCharm, WebStorm, etc.), and **Cursor**

### Quick install (personal — all projects)

**macOS / Linux:**
```bash
git clone https://github.com/OmexIT/claude-skills-pack.git
mkdir -p ~/.claude/skills
cp -R claude-skills-pack/skills/* ~/.claude/skills/
```

**Windows (WSL 2):**
```bash
git clone https://github.com/OmexIT/claude-skills-pack.git
mkdir -p ~/.claude/skills
cp -R claude-skills-pack/skills/* ~/.claude/skills/
```

> **Note:** Windows requires WSL 2 for full Claude Code support including Bash sandboxing. Native Windows has limited support.

Skills are immediately available in all your Claude Code sessions — no restart needed.

### Team install (per-repository)

Add skills to your project so every team member gets the same workflows:

```bash
# From your project root
git clone https://github.com/OmexIT/claude-skills-pack.git /tmp/skills-pack
mkdir -p .claude/skills
cp -R /tmp/skills-pack/skills/* .claude/skills/
rm -rf /tmp/skills-pack

# Commit to share with your team
git add .claude/skills
git commit -m "Add Claude Code skills pack"
```

Skills in `.claude/skills/` are auto-discovered. Team members get them on `git pull`.

### Monorepo install

Claude Code supports nested skill discovery. Place skills where they're relevant:

```
monorepo/
├── .claude/skills/              # Shared skills (all packages)
├── packages/
│   ├── frontend/.claude/skills/ # Frontend-specific skills
│   └── backend/.claude/skills/  # Backend-specific skills
```

### Install via Claude Code plugins

```bash
# If published as a plugin
/plugin install claude-skills-pack
```

---

## Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| **macOS** | Full | macOS 10.15+. All features work natively. |
| **Linux** | Full | Ubuntu 20.04+. Best stability and sandboxing. |
| **Windows (WSL 2)** | Full | Recommended for Windows. Full feature parity. |
| **Windows (WSL 1)** | Partial | No Bash sandboxing. Consider upgrading to WSL 2. |
| **Windows (Native)** | Limited | Use the native installer. Some syntax conflicts possible. |

### IDE Support

| IDE | How it works |
|-----|-------------|
| **Terminal CLI** | Full support. Type `/skill-name` at the prompt. |
| **VS Code** | Full support via Claude Code extension. Type `/` to see available skills. |
| **JetBrains** | Works via integrated terminal. All IDEs supported (IntelliJ, PyCharm, WebStorm, GoLand, PhpStorm). |
| **Cursor** | Works via the VS Code extension (`cursor:extension/anthropic.claude-code`). |

---

## Usage

### Basic invocation

Type `/` followed by the skill name and your context:

```
> /prd User authentication with SSO support
> /design-doc Payment processing service
> /pr-review https://github.com/org/repo/pull/42
> /debug-triage "TypeError: Cannot read property 'id' of undefined"
```

### Passing arguments

Skills accept free-form arguments. Some examples:

```
> /ticket-breakdown @design-doc.md
> /security-review src/api/auth/
> /competitive-analysis "project management tools market"
> /release-notes v2.4.0
```

### Auto-invocation

Skills with descriptions matching your request are invoked automatically. Ask Claude to "write a PRD for user notifications" and it will activate `/prd` without you typing the slash command.

To prevent auto-invocation (for sensitive skills like `/incident-response`), the skill uses `disable-model-invocation: true` in its frontmatter.

### Chaining skills

Skills are designed to flow into each other:

```
/opportunity-assessment → /prd → /design-doc → /ticket-breakdown → build → /pr-review → /release-notes
```

Each skill's "Workflow context" section tells you what comes before and after.

---

## How Skills Work

Each skill is a folder with a `SKILL.md` file:

```
skills/
├── prd/
│   ├── SKILL.md              # Instructions + methodology
│   └── templates/
│       └── prd.md            # Output template
├── security-review/
│   ├── SKILL.md
│   └── templates/
│       └── security-review.md
└── repo-conventions/
    ├── SKILL.md
    └── references/
        ├── architecture.md   # Customizable per-repo
        ├── api-style.md
        └── testing.md
```

### Skill anatomy

Every skill follows a consistent structure:

| Section | Purpose |
|---------|---------|
| **What I'll do** | Clear deliverable — what you'll get |
| **How I'll think about this** | Methodology — step-by-step reasoning approach |
| **Anti-patterns to flag** | Common mistakes the skill actively prevents |
| **Quality bar** | What "good output" looks like — concrete criteria |
| **Workflow context** | How this skill connects to others in the lifecycle |
| **Output** | Template reference for structured output |

This means Claude doesn't just fill in a template — it applies a thinking methodology, checks for anti-patterns, and validates against a quality bar before producing output.

### SKILL.md frontmatter

```yaml
---
name: prd                                    # Slash command name
description: Write a PRD...                  # Triggers auto-invocation
argument-hint: "[feature / problem]"         # Autocomplete hint
disable-model-invocation: true               # Manual-only (optional)
user-invocable: false                        # Auto-guidance only (optional)
---
```

---

## Customization

### Adapt to your team (recommended)

1. **Edit repo conventions** — Fill in `skills/repo-conventions/references/*` with your actual architecture, API style, and testing standards.

2. **Tune trigger phrases** — Modify the `description` field in each skill's frontmatter to match your team's vocabulary.

3. **Swap templates** — Replace templates with your org's existing formats (RFC, postmortem, PRD, etc.).

4. **Adjust quality bars** — Modify anti-patterns and quality criteria to match your team's standards.

### Create your own skills

Follow the same structure:

```
my-custom-skill/
├── SKILL.md          # Required: frontmatter + instructions
└── templates/
    └── output.md     # Optional: output template
```

See any existing skill as a reference.

---

## Workflow

Skills cover the complete product development lifecycle:

```
 Discover          Plan             Build           Quality          Release         Operate
 ────────          ────             ─────           ───────          ───────         ───────
 /opportunity   →  /prd          →  /ticket-     →  /pr-review   →  /release-   →  /monitoring
 -assessment       /design-doc      breakdown       /test-plan      notes          -plan
 /competitive   →  /adr                             /security-   →  /go-to-     →  /runbook
 -analysis         /user-flow                       review          market
                   /api-design                      /performance-   /stakeholder →  /incident-
                   /decision-                       review          -update         response
                   matrix                           /ux-review                  →  /postmortem
                   /migration-                      /metrics-
                   plan                             review
                   /experiment-                     /tech-debt-
                   design                           assessment
```

---

## Contributing

Contributions welcome! To add a new skill:

1. Create a folder in `skills/` with your skill name
2. Add a `SKILL.md` following the standard structure (see any existing skill)
3. Add a template in `templates/` if the skill produces a document
4. Update `skills/INDEX.md` with your skill in the appropriate category
5. Submit a PR

Please follow the existing conventions: methodology-driven prompts, anti-patterns, quality bars, and workflow context.

---

## License

MIT — use, modify, and distribute freely. See [LICENSE](LICENSE).

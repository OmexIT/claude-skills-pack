---
name: code-audit
description: >
  Use this skill whenever existing implementation code needs a rigorous multi-dimensional review — covering code smells, SOLID violations, duplication, algorithm efficiency, security, performance, design pattern fitness, architecture conformance, technology fitness, and a devil's advocate challenge. ALWAYS trigger on: "code audit", "code review", "review this code", "code quality", "code smells", "design patterns review", "architecture review", "is this code good", "review the implementation", "audit this module", "quality check", "assess this codebase". Implicit triggers: user asks whether code is "production-ready", user wants a second opinion on a module, user suspects tech debt but wants specifics, user is onboarding and wants a map of problem areas, user needs evidence for a refactoring ticket.
  Orchestrates a multi-agent expert panel with model routing (opus for LEAD/ARCH/SEC/SKEPTIC, sonnet for SMELL/DUP/ALGO/PERF/PATTERN/TECH). Reviews **code that exists** — for reviewing **specs before implementation**, use `/spec-panel` instead. Produces a findings report with severity ratings, a quality scorecard, and an ordered improvement roadmap. Does NOT modify code inline — findings route through the fix workflow (systematic-debugging → writing-plans → code-generator skill → requesting-code-review).
argument-hint: "[file, module, directory, or feature path]"
context: fork
agent: general-purpose
effort: high
---

# Code Audit: Multi-Agent Implementation Review

Orchestrates a **multi-agent expert panel** to conduct a comprehensive review of implemented code — combining static analysis, internet research, expert perspectives, and quantified quality scoring across 10 review dimensions.

This skill reviews **code that exists** (implementation). For reviewing **specs before implementation**, use `/spec-panel`.

---

## Before You Start — Superpowers Workflow

This skill is read-only — it produces a findings report, never inline fixes. It sits at a specific point in the superpowers workflow.

**Before invoking this skill**: nothing. Reviewers analyze existing work and don't need brainstorming or planning upfront.

**Invoke this skill** (`code-audit`) to audit existing code across 10 dimensions. Produces findings with severity ratings (CRITICAL/HIGH/MEDIUM/LOW/POSITIVE), quality scorecard, and improvement roadmap.

**After findings are produced** — for each CRITICAL or HIGH finding, route through the fix workflow:

1. **superpowers:systematic-debugging** — MANDATORY per finding. Understand the root cause before proposing a fix. Do not skip to fixes.
2. **superpowers:writing-plans** — turn findings into a reviewable remediation plan with ordered tickets and dependencies.
3. Chain to a code-generator skill for actual code changes:
   - `api-first` for controller/service/DTO restructuring
   - `temporal-workflow` for saga/orchestration extraction
   - `fintech-ledger` for money-code restructuring
   - `arch-review` (paired with this skill for deeper architecture analysis)
4. **superpowers:requesting-code-review** — after fixes are in place, before merging.
5. **superpowers:finishing-a-development-branch** — if remediation spans multiple branches, decide merge strategy.

**Hard rule**: this skill NEVER produces inline fixes. It produces findings. Fixes happen in a separate pass through the code-generator workflow.

---

## 0. Input Handling

```
/code-audit $ARGUMENTS
```

**Step 1 — Parse target:**
- File path(s): `src/payment/PaymentService.java`
- Directory: `src/payment/`
- Feature scope: `"the payment processing module"`
- PR reference: `#123` or branch name

**Step 2 — Scope determination.** Ask only if unclear:
- What's the review scope? (single file, module, feature, full codebase)
- What's the primary concern? (general quality, security, performance, architecture, all)
- What's the context? (pre-merge review, tech debt audit, incident investigation, onboarding)

**Step 3 — Codebase scan:**
```bash
# Map the target
find <target> -type f -name "*.java" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.dart" | head -50
wc -l <target files>

# Identify test coverage
find <target> -path "*/test*" -type f | head -20

# Check git activity
git log --oneline -20 -- <target>
git shortlog -sn -- <target>
```

**Step 4 — Confirm:**
```
🔍 CODE AUDIT TARGET
  Scope:     <n> files, ~<n> lines
  Language:  <detected>
  Framework: <detected>
  Tests:     <n> test files found
  Recent activity: <n> commits in last 30 days, <n> contributors

  Review dimensions activating: [list based on scope]
  Proceeding to Phase 1: Research...
```

---

## 1. Agent Roster (11 agents)

| Agent ID | Role | Review Dimension | Activated When |
|---|---|---|---|
| `LEAD` | Lead Reviewer / Orchestrator | Overall quality, synthesis | Always |
| `ARCH` | Architecture Analyst | Architecture conformance, coupling, modularity | Module+ scope |
| `SMELL` | Code Quality Analyst | Code smells + SOLID violations | Always |
| `DUP` | Duplication Detective | Code clones (Types 1-4), feature duplication | Always |
| `ALGO` | Algorithm Analyst | Complexity, data structures, optimization | Always |
| `SEC` | Security Reviewer | OWASP, auth, injection, secrets, crypto | Always |
| `PERF` | Performance Analyst | N+1 queries, memory, concurrency, caching | Always |
| `PATTERN` | Design Pattern Evaluator | Pattern fitness, anti-patterns, over-engineering | Module+ scope |
| `ARCH2` | Deep Architecture (optional — delegated to `/arch-review`) | Clean arch invariants, dep direction | Module+ scope, when deeper structural review needed |
| `TECH` | Technology Evaluator | Stack fitness, dependency health, alternatives | Feature/codebase scope |
| `TESTING` | Test Coverage & Quality | Coverage gaps, test smells, flake signals, assertion quality | Always |
| `SKEPTIC` | Devil's Advocate | Challenges design decisions, finds hidden assumptions | Always |

**`LEAD` always orchestrates** and produces the final synthesis. Other agents activate based on scope:
- Single-file reviews: skip `ARCH`, `ARCH2`, `TECH`
- Module reviews: skip `TECH` unless dependencies are in scope
- Full-codebase reviews: all agents active
- When the user asks specifically about architecture: delegate to `/arch-review` via chain, not `ARCH2` inline

### Agent Model Routing (Claude 4.6 family)

| Agent | Model family | Rationale |
|---|---|---|
| `LEAD` | `opus` (claude-opus-4-6) | Synthesis across 10 parallel finding streams — deepest reasoning |
| `ARCH`, `SEC`, `SKEPTIC` | `opus` | Structural reasoning + vulnerability analysis + independent challenge |
| `SMELL`, `DUP`, `ALGO`, `PERF`, `PATTERN`, `TESTING` | `sonnet` (claude-sonnet-4-6) | Pattern-recognition tasks — best coding model |
| `TECH` | `sonnet` | Dependency and technology evaluation |

### Parallel Execution Strategy

All 11 agents execute in a **single parallel wave** during Phase 2:
- Launch via the Agent tool in ONE message (parallel Agent calls)
- Each agent receives the Evidence Manifest + only the files relevant to its dimension
- Use `run_in_background: true` for `TECH` and `PATTERN` (lower criticality)
- LEAD waits for ALL agents before synthesizing

```
Phase 1: LEAD runs Phase 1 — tools + Evidence Manifest  (sequential, ~15 tool calls)
    ↓
Phase 2: 10 analysis agents launch in one message       (parallel, 1 wave)
    ↓
Phase 3: LEAD synthesizes scorecard + roadmap           (sequential)
```

### Parallel Dispatch Template

When moving from Phase 1 to Phase 2, launch agents using this exact pattern in a single message:

```
Agent(subagent_type="code-reviewer", description="Code smells + SOLID",
      model="sonnet",
      prompt="<Evidence Manifest> + agents/review-dimensions.md §1-2 + files: [...]")

Agent(subagent_type="code-reviewer", description="Duplication detective",
      model="sonnet",
      prompt="<Evidence Manifest> + agents/review-dimensions.md §3 + files: [...]")

Agent(subagent_type="security-auditor", description="Security review",
      model="opus",
      prompt="<Evidence Manifest> + agents/review-dimensions.md §5 + files: [...]")

Agent(subagent_type="performance-engineer", description="Performance review",
      model="sonnet",
      prompt="<Evidence Manifest> + agents/review-dimensions.md §6 + files: [...]")

Agent(subagent_type="quality-engineer", description="Test coverage + quality",
      model="sonnet",
      prompt="<Evidence Manifest> + agents/review-dimensions.md §11 + files: [...]")

Agent(subagent_type="backend-architect", description="Architecture conformance",
      model="opus",
      prompt="<Evidence Manifest> + agents/review-dimensions.md §8 + files: [...]")

Agent(subagent_type="general-purpose", description="Devil's advocate",
      model="opus",
      prompt="<Evidence Manifest> + agents/review-dimensions.md §10 + files: [...]")

# ...plus ALGO, PATTERN, TECH in the same message
```

Each agent receives:
1. The Evidence Manifest verbatim (so they share grounding)
2. Their dimension section from `agents/review-dimensions.md`
3. Only the specific files they need (not the full repo dump)
4. The structured finding format with MANDATORY Evidence field

### Agent Teams Mode (Experimental)

For large codebases (1000+ files), enable Agent Teams for competing-hypothesis investigation:
- `SMELL` and `SKEPTIC` can challenge each other's findings
- `SEC` and `PERF` can identify tradeoffs between security and performance
- Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` for this mode
- Higher token cost but better finding quality for complex audits

---

## 1.5 What This Skill Is NOT

Frequently confused with `/spec-panel` and `/arch-review`. Distinctions:

| Skill | When to use | Input | Output |
|---|---|---|---|
| **`/code-audit`** (this) | Reviewing **existing implemented code** across 11 quality dimensions | Files / modules / directories of real code | Multi-dimensional findings report with scorecard and roadmap |
| `/spec-panel` | Reviewing a **spec before implementation** (PRD, BRD, design doc, RFC) | A markdown spec document | IEEE 830 audit + expert panel findings + pre-impl gate |
| `/arch-review` | Deep dive on **clean-architecture invariants** (dep direction, tx boundaries, etc.) | A Java/Spring module | Architecture-specific findings + optional ArchUnit setup |

**Boundaries**:
- If the user says "review this spec" → route to `/spec-panel`, not here
- If the user says "check the architecture of module X" → route to `/arch-review` (or chain: code-audit first, then arch-review for deeper structure)
- If the user says "does this code follow our patterns" → `/code-audit` with focus on PATTERN + ARCH dimensions
- If the user says "is this production-ready" → `/code-audit` full run

**What this skill will refuse**:
- Generating fixes inline — findings only; fixes go through systematic-debugging → writing-plans → code-generator
- Auditing without running Phase 1 tools — speculation is a quality failure mode
- Auditing a spec document — bounce to `/spec-panel` with a note

---

## 2. Phase 1 — Deep Research

**Phase 1 is non-negotiable and must complete before any agent is dispatched.** A code audit that reviews without reading the real files is speculation. Every step below uses real tools — don't fabricate findings from memory.

### 2A: Codebase Investigation (MANDATORY — read real files)

Use `Glob`, `Grep`, `Read`, and `Bash(git ...)`. Do not assume — verify.

**Enumerate**:
```bash
# Glob every source file in scope
Glob("<target>/**/*.{java,kt,ts,tsx,js,jsx,py,go,rs,rb,dart}")
Glob("<target>/**/test/**/*.{java,ts,py}")  # tests
Glob("<target>/**/*.sql")                    # migrations / DDL
```

**Read targeted files**:
- Read every source file in scope — don't sample, read all (up to 50; if >50, sample by dependency centrality via reverse-import count)
- Read every test file — tests encode the team's understanding of requirements
- Read shared kernel / utility files that this code depends on
- Read the module's `package-info.java` / `index.ts` / `__init__.py` for public API surface

**Map dependencies via Grep**:
- `Grep("import .*<target-package>", "*.java")` → reverse-imports (who uses this code)
- `Grep("new <ClassName>|<ClassName>\\.", <parent>)` → instantiation sites
- `Grep("@RestController|@Controller", <target>)` → API surface
- `Grep("@Entity|@Table|@Document", <target>)` → persistence surface

**Git activity** — use `Bash` with explicit git commands:
- `git log --oneline -30 -- <target>` → recent change frequency (high churn = smell signal)
- `git shortlog -sn -- <target>` → ownership (one author = bus factor risk; many = coordination cost)
- `git log --format="%ad %an %s" --date=short -20 -- <target>` → authorship over time
- `git blame <hotspot-file>` on suspicious files only — overuse wastes tokens

**Convention detection** — read these files if present:
- `CLAUDE.md` (project root, `.claude/`, and any subdirectory of the target)
- `README.md` (architecture section)
- `.editorconfig`, `.prettierrc`, `checkstyle.xml`, `ruff.toml`, `pyproject.toml`
- `build.gradle*`, `pom.xml`, `package.json` → detect versions, test framework, lint tools
- ArchUnit test files (`*ArchTest.java`) → codified architecture rules
- `docs/adr/**/*.md` → architectural decisions that constrain the code

**Minimum evidence required before Phase 2** (this is a hard gate):
- [ ] Glob enumerated — file count and language breakdown known
- [ ] Build file read — framework versions and dependency versions confirmed
- [ ] CLAUDE.md read (or noted absent)
- [ ] ≥ 80% of in-scope source files read (or sampled with rationale if > 50 files)
- [ ] All in-scope tests read
- [ ] `git log` run — recent commit count and top contributors known
- [ ] At least 2 reverse-import searches run

### 2B: Dependency & Version Research (MANDATORY — context7 FIRST)

Training data goes stale. Use real tools.

**`mcp__context7__resolve-library-id` + `mcp__context7__query-docs`** — use this FIRST for every library/framework the code depends on. Required trigger cases:

- Spring Boot version detected → query context7 for current best practices + deprecations
- React / Next.js version → query for current patterns (Server Components, `use`, etc.)
- Temporal SDK version → query for current workflow patterns + retry policy shape
- Any ORM (JPA, Hibernate, Prisma, SQLAlchemy) → query for idiomatic patterns
- Any auth library → query for current security posture

**WebSearch / WebFetch** for:
- Known CVEs at the exact dependency versions (check NVD/GitHub advisories)
- Breaking changes in the next major version of each dependency (informs `TECH` findings)
- OWASP Top 10 / CWE references cited in `SEC` findings
- NIST / RFC / ISO citations for `SEC` and `PERF` findings

**Rules**:
- Cite every source with a real URL in the final report
- Never invent URLs
- When context7 contradicts training data, trust context7 and quote the current version
- No citations → the finding has no external backing, mark it as "stack heuristic" not "best practice"

### 2C: Existing Standards & Prior Reviews

- Read `CLAUDE.md` and quote relevant conventions in the final report
- Read lint/format configs and note which rules exist and which would catch the problems we're about to flag
- Read ArchUnit rules and note coverage gaps
- **Read prior audit reports** if present: `claudedocs/*-code-audit.md` — if this code has been audited before, check whether old findings were addressed, reopened, or ignored. Reopened findings are especially valuable signals.

### 2D: Evidence Manifest (mandatory output of Phase 1)

Before Phase 2, produce this manifest and include it verbatim in the final report:

```
EVIDENCE MANIFEST — <target>
==============================

CODEBASE
  Files enumerated:   <n>  ({<lang>: <n>, <lang>: <n>})
  Files read:         <n> / <n> in scope  (<%>)
  Tests read:         <n>
  Reverse-imports:    <n> callers outside target
  API surface:        <n> public entrypoints ({<n> REST, <n> events, <n> CLI})

GIT ACTIVITY (30d)
  Commits on target:   <n>
  Contributors:        <n>
  Hotspots (top 3):    <file1> (<n>), <file2> (<n>), <file3> (<n>)
  Concurrent work:     <yes/no> — flag files in open PRs touching the target

STACK VERIFICATION
  Language:            <e.g. Java 25>
  Framework:           <e.g. Spring Boot 4.0.4>
  Test framework:      <e.g. JUnit 5 + Mockito 5 + Testcontainers>
  Build tool:          <Gradle / Maven / pnpm>
  Detected convention sources: [CLAUDE.md, .editorconfig, ArchUnit, ...]

EXTERNAL RESEARCH
  context7 queries:    [library @ version → key insight]
  WebSearch queries:   [query → finding]
  CVEs surfaced:       <n>
  Standards consulted: [OWASP / CWE / NIST / RFC ...]

PRIOR AUDIT HISTORY
  Previous audits:     <n> (paths)
  Reopened findings:   <n>  (these get severity boost)
  Never-addressed:     <n>

BLOCKERS
  <anything preventing reliable review — surface here, do not proceed silently>
```

**Phase 2 cannot start until the Evidence Manifest is produced.** Findings without manifest-backed evidence are speculation and must be marked `[EVIDENCE: missing]` — a reviewer's failure mode.

---

## 3. Phase 2 — Multi-Dimensional Analysis

**Read `agents/review-dimensions.md`** for the full 10-dimension protocol. That file defines:

- The structured finding format used by every agent (Location, Issue, Impact, Recommendation, Rationale, Effort)
- Severity levels (CRITICAL / HIGH / MEDIUM / LOW / POSITIVE)
- Per-dimension checklists for: Code Smells, SOLID, Duplication, Algorithms, Security, Performance, Design Patterns, Architecture, Technology, Skeptic challenges

Dispatch all 10 agents in parallel after loading that file. Each agent uses its relevant sections and produces findings in the standard format.

---

## 4. Phase 3 — Quality Scorecard

**Read `references/roadmap-templates.md`** for the scorecard template, findings summary format, and scoring guide (1-10 with interpretation). Populate the scorecard from the agent outputs.

---

## 5. Phase 4 — Improvement Roadmap

**Read `references/roadmap-templates.md`** for the action-tier tables (Tier 1 — fix now, Tier 2 — this sprint, Tier 3 — schedule) and the refactoring plan template. Group findings into tiers, populate the tables, and produce a concrete refactoring plan for each Tier 1 finding.

---

## 6. Phase 5 — Save Report

Save the full analysis to:
```
claudedocs/<target-name>-code-audit.md
```

Use the final report header template from `references/roadmap-templates.md` at the top of the file.

Tell the user: "Audit saved to claudedocs/<name>-code-audit.md. Next steps: run superpowers:systematic-debugging on CRITICAL findings, then superpowers:writing-plans to turn findings into tickets, then route to a code-generator skill for fixes, then /finalize to commit."

---

## Anti-patterns

- **Surface-level review** — Checking only naming and formatting while ignoring architecture, security, and performance. Style is the least important dimension.
- **Trusting tests exist** — A test file existing does not mean coverage is adequate. Read the tests. Check what they actually verify.
- **Generic advice** — "Add error handling" is useless. "Add try-catch in PaymentService.processRefund():47 — unhandled NPE when refund amount exceeds original" is useful.
- **Reviewing without context** — Not reading git history, related modules, or project conventions before judging code.
- **Bikeshedding** — Spending review time on variable names while a SQL injection sits three lines below.
- **Rubber-stamping** — Large PRs / complex modules need more scrutiny, not less. Complexity should increase thoroughness.
- **Pattern worship** — Flagging code for not using a design pattern when the simple approach is correct. Three similar lines are better than a premature abstraction.
- **Ignoring what's good** — Only reporting problems creates a hostile review. Acknowledge well-written code (POSITIVE findings).
- **Reviewing to your style, not the project's** — The project's conventions win. Flag deviations from project style, not from your personal preference.
- **Missing the forest for the trees** — 50 LOW findings about naming but missing the one CRITICAL architectural flaw.
- **Producing inline fixes** — This skill produces findings. Fixes go through a separate code-generator skill pass.

---

## Quality bar

- Every finding uses the structured format with Location, Issue, Impact, Recommendation, Rationale, Effort
- All 10 dimensions were evaluated (or explicitly marked N/A with reason)
- Internet research was conducted via context7 and cited for the specific technologies in use
- Project conventions were checked and deviations flagged
- POSITIVE findings included — good code was acknowledged
- The Skeptic challenged at least 3 assumptions
- Quality scorecard was produced with per-dimension scores
- Tier 1 findings have concrete refactoring plans with steps
- Security checklist was completed (no unchecked items — mark N/A or flag)
- Performance checklist was completed

---

## Workflow context

**Upstream skills that feed into this:**
- `/spec-to-impl` — Code produced from spec implementation
- `/finalize` — Code ready for final review before commit
- Any implementation work that needs quality verification

**Downstream skills that consume this output:**
- `superpowers:systematic-debugging` — per CRITICAL finding
- `superpowers:writing-plans` — remediation plan
- `api-first` / `temporal-workflow` / `fintech-ledger` — for code-generator fixes
- `arch-review` — deeper architecture-specific analysis
- `/test-plan` — Test planning informed by coverage gaps found
- `/tech-debt-assessment` — Tier 2/3 findings feed debt inventory
- `/performance-review` — Deep-dive on performance findings
- `/security-review` — Deep-dive on security findings
- `superpowers:requesting-code-review` — after fixes, before merging
- `/finalize` — Commit after fixing Tier 1 findings

---

### Learning & Memory

After audit completes, save reusable patterns:
- Code quality patterns specific to this project's stack
- Common anti-patterns found that should inform future reviews
- Effective review checklist items for this technology combination
- Architecture conformance rules that should be codified as ArchUnit/lint rules

---

## 7. Reference Files

| File | When to read |
|---|---|
| `agents/review-dimensions.md` | Phase 2 — dispatching the 10 analysis agents with their dimension-specific checklists |
| `references/roadmap-templates.md` | Phase 3-5 — scorecard, action tiers, refactoring plan, final report header |

---

## Output contract

```yaml
produces:
  - type: "code-audit"
    format: "markdown"
    path: "claudedocs/<target-name>-code-audit.md"
    sections:
      - scope-and-context
      - codebase-investigation
      - internet-research
      - code-smells-findings
      - solid-violations
      - duplication-report
      - algorithm-analysis
      - security-checklist
      - performance-checklist
      - design-pattern-fitness
      - architecture-conformance
      - technology-evaluation
      - skeptic-challenges
      - quality-scorecard
      - findings-summary
      - improvement-roadmap-tier-1
      - improvement-roadmap-tier-2
      - improvement-roadmap-tier-3
      - refactoring-plans
      - recommended-reading
      - action-tracker
  handoff: "Run superpowers:systematic-debugging per CRITICAL finding. Write claudedocs/handoff-code-audit-<timestamp>.yaml — suggest: superpowers:writing-plans, api-first/temporal-workflow/fintech-ledger (for fixes), arch-review (deeper structure), superpowers:requesting-code-review, /finalize"
```

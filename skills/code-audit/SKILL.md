---
name: code-audit
description: "Orchestrates a multi-agent expert panel to review existing implementation code across 10 dimensions -- code smells, SOLID violations, duplication, algorithm efficiency, security, performance, design pattern fitness, architecture conformance, technology fitness, and devil's advocate challenge. Uses model routing (opus for LEAD/ARCH/SEC/SKEPTIC, sonnet for SMELL/DUP/ALGO/PERF/PATTERN/TECH). Produces a findings report with severity ratings, quality scorecard, and ordered improvement roadmap. Use when running a code audit, code review, quality check, assessing a codebase, or checking if code is production-ready. For reviewing specs before implementation, use /spec-panel instead."
argument-hint: "[file, module, directory, or feature path]"
context: fork
agent: general-purpose
effort: high
---

# Code Audit: Multi-Agent Implementation Review

Orchestrates a **multi-agent expert panel** to conduct a comprehensive review of implemented code -- combining static analysis, internet research, expert perspectives, and quantified quality scoring across 10 review dimensions.

**Routing rules:**
- "Review this spec" -> route to `/spec-panel`
- "Check the architecture of module X" -> route to `/arch-review`
- "Is this production-ready" or "does this code follow our patterns" -> this skill

This skill is read-only -- it produces findings, never inline fixes. Fixes go through systematic-debugging -> writing-plans -> code-generator.

---

## Before You Start -- Superpowers Workflow

**Before**: Nothing required. Reviewers analyze existing work.

**After findings are produced** -- for each CRITICAL or HIGH finding:
1. **superpowers:systematic-debugging** -- MANDATORY per finding. Understand root cause first.
2. **superpowers:writing-plans** -- turn findings into a remediation plan.
3. Chain to a code-generator skill (`api-first`, `temporal-workflow`, `fintech-ledger`, or `arch-review`).
4. **superpowers:requesting-code-review** -- after fixes, before merging.
5. **superpowers:finishing-a-development-branch** -- if remediation spans branches.

---

## 0. Input Handling

```
/code-audit $ARGUMENTS
```

**Step 1 -- Parse target:** File path(s), directory, feature scope, or PR reference.

**Step 2 -- Scope determination.** Ask only if unclear: review scope, primary concern, context (pre-merge, tech debt audit, incident, onboarding).

**Step 3 -- Codebase scan:**
```bash
find <target> -type f -name "*.java" -o -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.dart" | head -50
wc -l <target files>
find <target> -path "*/test*" -type f | head -20
git log --oneline -20 -- <target>
git shortlog -sn -- <target>
```

**Step 4 -- Confirm:**
```
CODE AUDIT TARGET
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
| `ARCH2` | Deep Architecture (optional) | Clean arch invariants, dep direction | Delegated to `/arch-review` |
| `TECH` | Technology Evaluator | Stack fitness, dependency health, alternatives | Feature/codebase scope |
| `TESTING` | Test Coverage & Quality | Coverage gaps, test smells, flake signals | Always |
| `SKEPTIC` | Devil's Advocate | Challenges design decisions, hidden assumptions | Always |

**Activation rules:**
- Single-file reviews: skip `ARCH`, `ARCH2`, `TECH`
- Module reviews: skip `TECH` unless dependencies in scope
- Full-codebase reviews: all agents active
- Architecture-specific questions: delegate to `/arch-review`, not `ARCH2` inline

### Model Routing (Claude 4.6 family)

| Model | Agents | Rationale |
|---|---|---|
| `opus` | LEAD, ARCH, SEC, SKEPTIC | Synthesis, structural reasoning, vulnerability analysis |
| `sonnet` | SMELL, DUP, ALGO, PERF, PATTERN, TESTING, TECH | Pattern-recognition tasks |

### Parallel Execution

```
Phase 1: LEAD runs research + Evidence Manifest  (sequential, ~15 tool calls)
    |
Phase 2: 10 analysis agents in one message       (parallel, 1 wave)
    |
Phase 3: LEAD synthesizes scorecard + roadmap    (sequential)
```

Launch all agents in a single message using the Agent tool. Each agent receives: (1) the Evidence Manifest verbatim, (2) their dimension section from `agents/review-dimensions.md`, (3) only the specific files they need, (4) the structured finding format with MANDATORY Evidence field. Use `run_in_background: true` for `TECH` and `PATTERN` (lower criticality). LEAD waits for ALL agents before synthesizing.

### Dispatch Template

```
Agent(subagent_type="code-reviewer", description="Code smells + SOLID",
      model="sonnet",
      prompt="<Evidence Manifest> + agents/review-dimensions.md S1-2 + files: [...]")

Agent(subagent_type="code-reviewer", description="Duplication detective",
      model="sonnet",
      prompt="<Evidence Manifest> + agents/review-dimensions.md S3 + files: [...]")

Agent(subagent_type="security-auditor", description="Security review",
      model="opus",
      prompt="<Evidence Manifest> + agents/review-dimensions.md S5 + files: [...]")

Agent(subagent_type="performance-engineer", description="Performance review",
      model="sonnet",
      prompt="<Evidence Manifest> + agents/review-dimensions.md S6 + files: [...]")

Agent(subagent_type="quality-engineer", description="Test coverage + quality",
      model="sonnet",
      prompt="<Evidence Manifest> + agents/review-dimensions.md S11 + files: [...]")

Agent(subagent_type="backend-architect", description="Architecture conformance",
      model="opus",
      prompt="<Evidence Manifest> + agents/review-dimensions.md S8 + files: [...]")

Agent(subagent_type="general-purpose", description="Devil's advocate",
      model="opus",
      prompt="<Evidence Manifest> + agents/review-dimensions.md S10 + files: [...]")

# ...plus ALGO, PATTERN, TECH in the same message
```

---

## 2. Phase 1 -- Deep Research

**Phase 1 is non-negotiable and must complete before any agent is dispatched.** Every step uses real tools -- do not fabricate findings from memory.

### 2A: Codebase Investigation (MANDATORY)

Use `Glob`, `Grep`, `Read`, and `Bash(git ...)`. Do not assume -- verify.

**Enumerate**: Glob all source files, test files, and SQL/migration files in scope.

**Read targeted files**:
- Read every source file in scope (up to 50; if >50, sample by reverse-import count)
- Read every test file and shared kernel/utility dependencies
- Read module entry points (`package-info.java` / `index.ts` / `__init__.py`)

**Map dependencies via Grep**: reverse-imports, instantiation sites, API surface (`@RestController`), persistence surface (`@Entity`).

**Git activity**: `git log --oneline -30`, `git shortlog -sn`, authorship timeline. Use `git blame` only on suspicious hotspot files.

**Convention detection** -- read if present: `CLAUDE.md`, `README.md`, `.editorconfig`, lint/format configs, build files, ArchUnit tests, ADRs.

**Minimum evidence gate before Phase 2**:
- Glob enumerated -- file count and language breakdown known
- Build file read -- framework and dependency versions confirmed
- CLAUDE.md read (or noted absent)
- >= 80% of in-scope source files read (or sampled with rationale)
- All in-scope tests read
- `git log` run -- recent commits and top contributors known
- At least 2 reverse-import searches run

### 2B: Dependency & Version Research (MANDATORY)

Use **context7** FIRST (`resolve-library-id` + `query-docs`) for every library/framework detected. Required for: Spring Boot, React/Next.js, Temporal SDK, any ORM, any auth library.

Use **WebSearch/WebFetch** for: CVEs at exact dependency versions, breaking changes in next major versions, OWASP/CWE/NIST references.

**Rules**: Cite every source with a real URL. Never invent URLs. When context7 contradicts training data, trust context7. No citations = mark finding as "stack heuristic" not "best practice".

### 2C: Existing Standards & Prior Reviews

Read `CLAUDE.md`, lint/format configs, ArchUnit rules. Read prior audit reports (`claudedocs/*-code-audit.md`) -- reopened findings get severity boost.

### 2D: Evidence Manifest (mandatory Phase 1 output)

Produce this manifest before Phase 2 and include it verbatim in the final report:

```
EVIDENCE MANIFEST -- <target>
  Files: <n> ({lang: n, lang: n}) | Read: <n>/<n> (<pct>%) | Tests: <n>
  API surface: <n> public entrypoints ({REST, events, CLI})
  Git (30d): <n> commits, <n> contributors
  Hotspots: <file1> (<n>), <file2> (<n>), <file3> (<n>)
  Stack: <language version>, <framework version>, <test framework>, <build tool>
  Conventions: [CLAUDE.md, .editorconfig, ArchUnit, ...]
  context7 queries: [library @ version -> key insight]
  WebSearch: [query -> finding]
  CVEs: <n> | Standards: [OWASP / CWE / NIST / RFC ...]
  Prior audits: <n> | Reopened: <n> | Never-addressed: <n>
  BLOCKERS: <anything preventing reliable review>
```

**Phase 2 cannot start until the Evidence Manifest is produced.** Findings without manifest-backed evidence must be marked `[EVIDENCE: missing]`.

---

## 3. Phase 2 -- Multi-Dimensional Analysis

**Read `agents/review-dimensions.md`** for the full 10-dimension protocol defining: structured finding format (Location, Evidence, Issue, Impact, Recommendation, Rationale, Blast radius, Effort), severity levels (CRITICAL/HIGH/MEDIUM/LOW/POSITIVE), and per-dimension checklists.

Dispatch all 10 agents in parallel after loading that file.

---

## 4. Phase 3 -- Quality Scorecard

**Read `references/roadmap-templates.md`** for the scorecard template, findings summary format, and scoring guide (1-10). Populate from agent outputs.

---

## 5. Phase 4 -- Improvement Roadmap

**Read `references/roadmap-templates.md`** for action-tier tables (Tier 1 -- fix now, Tier 2 -- this sprint, Tier 3 -- schedule) and refactoring plan template. Group findings into tiers and produce concrete refactoring plans for each Tier 1 finding.

---

## 6. Phase 5 -- Save Report

Save to `claudedocs/<target-name>-code-audit.md` using the final report header template from `references/roadmap-templates.md`.

Tell the user: "Audit saved to claudedocs/<name>-code-audit.md. Next steps: run superpowers:systematic-debugging on CRITICAL findings, then superpowers:writing-plans to turn findings into tickets, then route to a code-generator skill for fixes, then /finalize to commit."

---

## Anti-patterns

- **Surface-level review**: Checking naming/formatting while ignoring architecture, security, and performance.
- **Generic advice**: "Add error handling" is useless. Cite file:line with a specific fix.
- **Reviewing without context**: Not reading git history, related modules, or conventions first.
- **Producing inline fixes**: This skill produces findings only. Fixes go through a separate code-generator pass.

---

## Quality bar

- Every finding uses structured format with Location, Evidence, Issue, Impact, Recommendation, Rationale, Effort
- All 10 dimensions evaluated (or explicitly marked N/A with reason)
- Internet research conducted via context7 and cited for specific technologies in use
- Project conventions checked and deviations flagged
- POSITIVE findings included -- good code acknowledged
- Skeptic challenged at least 3 assumptions
- Quality scorecard produced with per-dimension scores
- Tier 1 findings have concrete refactoring plans
- Security and performance checklists completed

---

## 7. Reference Files

| File | When to read |
|---|---|
| `agents/review-dimensions.md` | Phase 2 -- dispatching the 10 analysis agents with dimension-specific checklists |
| `references/roadmap-templates.md` | Phase 3-5 -- scorecard, action tiers, refactoring plan, final report header |

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
  handoff: "Run superpowers:systematic-debugging per CRITICAL finding. Write claudedocs/handoff-code-audit-<timestamp>.yaml -- suggest: superpowers:writing-plans, api-first/temporal-workflow/fintech-ledger (for fixes), arch-review (deeper structure), superpowers:requesting-code-review, /finalize"
```
